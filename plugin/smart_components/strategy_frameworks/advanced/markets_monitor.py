import json
import logging
from decimal import Decimal
from typing import Dict, Optional, List, Tuple, Union


from hummingbot.core.data_type.common import TradeType
from hummingbot.logger import HummingbotLogger

#from hummingbot.smart_components.executors.position_executor.data_types import CloseType
from hummingbot.smart_components.strategy_frameworks.advanced.order_book_component import OrderBookComponent

from hummingbot.strategy.script_strategy_base import ScriptStrategyBase

# Сюда вынесена логика по мониторингу цен на всех рынках при срабатывании событий получения новой книги ордеров или покупках.
# TODO: 
# 1. Обрабатывание события получения новой книги ордеров, перестройка taker_price и вызов событий.
# 2. Работа с мультирынками, пока только один

# Старая информация:
# Сюда вынесена вся логика по работе с рынком taker_exchange.
# Обращения идут из:
# 1. dman.py, для него выдается информация по цене выставления позиций
# 2. position_executor.py, для него методы по закрытию позиций и контролю цены
# Для внешних источников taker - единый рынок сбыта, но по факту внутри логика реализована по закрытию на лучшем из рынков takers.
# В текущей имплементации takers рынки состоят тоже из одного рынка.

# Контролить:
# 1. изменения книги
# 2. изменения бюджетов и ассетов.

class MarketsMonitor(OrderBookComponent):
    _logger = None
    profiler = True
    debug = True

    #exchange = os.getenv("EXCHANGE", "binance_paper_trade")
    #trading_pairs = os.getenv("TRADING_PAIRS", "BTC-USDT")
    
    # Profiler:
    last_dump_timestamp = 0
    time_between_csv_dumps = 10

    current_date = None
    ob_file_paths = {}
    ob_diff_file_paths = {}
    trades_file_paths = {}



    @classmethod
    def logger(cls) -> HummingbotLogger:
        if cls._logger is None:
            cls._logger = logging.getLogger(__name__)
        return cls._logger

    def __init__(self, strategy: ScriptStrategyBase, connectors: List[str], update_interval: float = 0.1):
        super().__init__(strategy=strategy, connectors=connectors, update_interval=update_interval)
        self.strategy=strategy
        self.connectors=connectors
        self.taker_prices = {}
        # self.get_order_book(self.strategy.taker_exchange, self.strategy.taker_pair)
        #Поже изменить на механизм подписки
        #self.subscribe_to_order_book(self.strategy.taker_exchange, self.strategy.taker_pair)

        # Profiler:
        self.strategy=strategy
        self.maker_exchange=strategy.maker_exchange
        self.taker_exchange=strategy.taker_exchange
        self.exchanges=[self.maker_exchange,self.taker_exchange]
        self.trading_pair=strategy.trading_pair
        

        self.ob_temp_storage = {exchange: [] for exchange in self.exchanges}

        self.exchange_pairs={"bin_whitebit":[self.maker_exchange,self.taker_exchange]}
        self.ob_diff_temp_storage = {exchange_pair: [] for exchange_pair in self.exchange_pairs.keys()}
        
        self.logger().warning(f"ob_diff_temp_storage={json.dumps(self.ob_diff_temp_storage)}")

        self.trades_temp_storage = {exchange: [] for exchange in self.exchanges}

        self.create_order_book_and_trade_files()
    
    def control_task(self):
        self.logger().info(f"control_task")
        super().control_task()

        if not self.profiler: return        
        current_datetime = datetime.now()
        current_timestamp=current_datetime.timestamp()
        self.current_timestamp=current_timestamp;


        self.logger().info(f"self.current_timestamp={self.current_timestamp}")
        self.check_and_replace_files()
        for exchange in self.exchanges:
            order_book_data = self.get_order_book_dict(exchange, self.trading_pair, self.depth)
            self.ob_temp_storage[exchange].append(order_book_data)
        for exchange_pair in self.exchange_pairs.keys():
            order_book_diff_data = self.get_order_book_diff_dict(self.exchange_pairs[exchange_pair][0],self.exchange_pairs[exchange_pair][1], self.trading_pair, self.depth)
            self.ob_diff_temp_storage[exchange_pair].append(order_book_diff_data)
        if self.last_dump_timestamp < self.current_timestamp:
            self.dump_and_clean_temp_storage()

        #if(self.order_book_changed):
        #    self.order_book_changed=False

    def on_stop(self):
        #if self.controller.is_perpetual:
        #    self.close_open_positions(connector_name=self.controller.config.exchange, trading_pair=self.controller.config.trading_pair)
        super().on_stop()

    def on_start(self):
        super().on_start()
        #if self.controller.is_perpetual:
        #    self.set_leverage_and_position_mode()


    #def get_order_book(self, connector_exchange:str, connector_pair: str):
    #    order_book=self.strategy.connectors[connector_exchange].get_order_book(connector_pair)
    #    self.on_order_book_change(order_book,connector_exchange,connector_pair)




    def on_order_book_change(self, order_book_snapshot, connector_name: str, trading_pair: str):
        self.logger().warning(f"on_order_book_change connector_name={connector_name}")
        self.calculate_taker_prices(order_book_snapshot, connector_name, trading_pair, TradeType.SELL);
        self.calculate_taker_prices(order_book_snapshot, connector_name, trading_pair, TradeType.BUY);

    def calculate_taker_prices(self, order_book_snapshot, connector_exchange: str, connector_pair: str, trade_type: TradeType):
        depth=50
        order_book={
            "bids": order_book_snapshot[0].loc[:(depth - 1), ["price", "amount"]].values.tolist(),
            "asks": order_book_snapshot[1].loc[:(depth - 1), ["price", "amount"]].values.tolist(),
        }
        #self.logger().warning(f"order_book: {json.dumps(order_book)}")
        
        position_size = self.strategy.order_amount
        positions_count = self.strategy.n_levels
        volumes = [Decimal(position_size) for _ in range(positions_count)]

        prices = []

        for volume in volumes:
            total_volume = Decimal("0")
            weighted_price = Decimal("0")
            #orders = order_book_snapshot[1] if trade_type == TradeType.BUY else order_book_snapshot[0]
            orders = order_book['asks'] if trade_type == TradeType.BUY else order_book['bids']

            for order in orders:
                order_price = order[0]
                order_volume = order[1]
                available_volume = Decimal(order_volume)
                required_volume = volume - total_volume

                if available_volume > required_volume:
                    available_volume = required_volume

                weighted_price += Decimal(order_price) * available_volume
                total_volume += available_volume

                if total_volume >= volume:
                    break

            if total_volume == 0:
                prices.append(Decimal("0"))
            else:
                prices.append(weighted_price / total_volume)

        self.taker_prices[trade_type] = prices


    def get_taker_price(self,trade_type,level) -> Decimal:
        return self.taker_prices[trade_type][level]

    def get_taker_prices(self,exchange,trading_pair) -> Decimal:
        order_book = self.connectors[exchange].get_order_book(trading_pair)
        order_book_snapshot = order_book.snapshot
        self.on_order_book_change(order_book_snapshot,exchange,trading_pair)
        return self.taker_prices

    '''        
    def execute_taker_trade(self, trade_type, amount):
        # Выполнение торговой операции на taker рынке
        # [TODO] fix self.trading_pair1
        order_type = OrderType.MARKET
        if trade_type == TradeType.BUY:
            self.connectors[self.candles_exchange]
            self.buy(self.candles_exchange, self.trading_pair1, amount, order_type)
        else:
            self.sell(self.candles_exchange, self.trading_pair1, amount, order_type)
    '''

    # Profiler
    def get_order_book_diff_dict(self, exchange1: str, exchange2: str, trading_pair: str, depth: int = 50):
        order_book1 = self.connectors[exchange1].get_order_book(trading_pair)
        snapshot1 = order_book1.snapshot
        bids1=snapshot1[0].loc[:(depth - 1), ["price", "amount"]].values.tolist()
        asks1=snapshot1[1].loc[:(depth - 1), ["price", "amount"]].values.tolist()
        order_book2 = self.connectors[exchange2].get_order_book(trading_pair)
        snapshot2 = order_book2.snapshot
        bids2=snapshot2[0].loc[:(depth - 1), ["price", "amount"]].values.tolist()
        asks2=snapshot2[1].loc[:(depth - 1), ["price", "amount"]].values.tolist()

        diff1=100*(bids1[0][0]-asks2[0][0]) / bids1[0][0];
        diff2=100*(bids2[0][0]-asks1[0][0]) / bids2[0][0];
        res={
            "ts": self.current_timestamp,
            "diff1": str(Decimal(diff1)),
            "diff2": str(Decimal(diff2)),
        }
        if(diff1>1): res["notes"]=">1%@1"
        if(diff2>1): res["notes"]=">1%@2"

        if(diff1>3): res["notes"]=">3%@1"
        if(diff2>3): res["notes"]=">3%@2"

        return res
    

    def dump_and_clean_temp_storage(self):
        for exchange, order_book_info in self.ob_temp_storage.items():
            file = self.ob_file_paths[exchange]
            json_strings = [json.dumps(obj) for obj in order_book_info]
            json_data = '\n'.join(json_strings)
            file.write(json_data+'\n')
            self.ob_temp_storage[exchange] = []
        for exchange_pair, order_book_info in self.ob_diff_temp_storage.items():
            file = self.ob_diff_file_paths[exchange_pair]
            json_strings = [json.dumps(obj) for obj in order_book_info]
            json_data = '\n'.join(json_strings)
            file.write(json_data+'\n')
            self.ob_diff_temp_storage[exchange_pair] = []
        for exchange, trades_info in self.trades_temp_storage.items():
            file = self.trades_file_paths[exchange]
            json_strings = [json.dumps(obj) for obj in trades_info]
            json_data = '\n'.join(json_strings)
            file.write(json_data+'\n')
            self.trades_temp_storage[exchange] = []
        self.last_dump_timestamp = self.current_timestamp + self.time_between_csv_dumps

    def check_and_replace_files(self):
        current_date = datetime.now().strftime("%Y-%m-%d")
        if current_date != self.current_date:
            for file in self.ob_file_paths.values():
                file.close()
            for file in self.ob_diff_file_paths.values():
                file.close()
            self.create_order_book_and_trade_files()

    def create_order_book_and_trade_files(self):
        if not self.profiler: return
        self.current_date = datetime.now().strftime("%Y-%m-%d")
        self.ob_file_paths = {exchange: self.get_file(exchange, self.trading_pair, "order_book_snapshots", self.current_date) for
                              exchange in self.exchanges}
        self.ob_diff_file_paths = {exchange_pair: self.get_file(exchange_pair, self.trading_pair, "order_book_diff", self.current_date) for
                              exchange_pair in self.exchange_pairs.keys()}
        self.trades_file_paths = {exchange: self.get_file(exchange, self.trading_pair, "trades", self.current_date) for
                                  exchange in self.exchanges}

    @staticmethod
    def get_file(exchange: str, trading_pair: str, source_type: str, current_date: str):
        file_path = data_path() + f"/{exchange}_{trading_pair}_{source_type}_{current_date}.txt"
        return open(file_path, "a")