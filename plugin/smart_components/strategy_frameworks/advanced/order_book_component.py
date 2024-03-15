import json
import os
from datetime import datetime
from hummingbot import data_path

import logging
import asyncio
from decimal import Decimal
from enum import Enum
from typing import List, Tuple, Union, Dict

from hummingbot.connector.connector_base import ConnectorBase

from hummingbot.core.event.event_forwarder import SourceInfoEventForwarder
from hummingbot.core.event.events import OrderBookEvent, OrderBookTradeEvent, OrderBookDataSourceEvent

from hummingbot.core.utils.async_utils import safe_ensure_future
from hummingbot.strategy.script_strategy_base import ScriptStrategyBase

from hummingbot.logger import HummingbotLogger




class SmartComponentStatus(Enum):
    NOT_STARTED = 1
    ACTIVE = 2
    TERMINATED = 3


class OrderBookComponent:
    _logger = None
    
    profiler = True
    debug = True


    #exchange = os.getenv("EXCHANGE", "binance_paper_trade")
    #exchange = os.getenv("EXCHANGE", "whitebit")
    #exchange = os.getenv("EXCHANGE", "dydx_perpetual")
    #exchange = os.getenv("EXCHANGE", "binance_perpetual")
    #trading_pairs = os.getenv("TRADING_PAIRS", "ETH-USD,BTC-USD")
    #trading_pairs = os.getenv("TRADING_PAIRS", "ETH-USDT,BTC-USDT")
    trading_pairs = os.getenv("TRADING_PAIRS", "BTC-USDT")
    depth = int(os.getenv("DEPTH", 50))
    trading_pairs = [pair for pair in trading_pairs.split(",")]
    last_dump_timestamp = 0
    time_between_csv_dumps = 10

    ob_temp_storage = {trading_pair: [] for trading_pair in trading_pairs}
    trades_temp_storage = {trading_pair: [] for trading_pair in trading_pairs}
    current_date = None
    ob_file_paths = {}
    trades_file_paths = {}
    #markets = {exchange: set(trading_pairs)}
    subscribed_to_order_book_trade_event: bool = False


    @classmethod
    def logger(cls) -> HummingbotLogger:
        if cls._logger is None:
            cls._logger = logging.getLogger(__name__)
        return cls._logger

    def __init__(self, strategy: ScriptStrategyBase, connectors: List[str], update_interval: float = 0.5):
        self.logger().warning(f"OrderBookComponent initializing")
        
        self.strategy=strategy
        self.exchange=strategy.exchange
        self.trading_pair=strategy.trading_pair


        self.create_order_book_and_trade_files()
        self.order_book_trade_event = SourceInfoEventForwarder(self._process_public_trade)

        self.terminated = asyncio.Event()
        safe_ensure_future(self.control_loop())
        self.logger().warning(f"OrderBookComponent initialized")

    @property
    def status(self):
        return self._status

    async def control_loop(self):
        self.on_start()
        self._status = SmartComponentStatus.ACTIVE
        while not self.terminated.is_set():
            await self.control_task()
            await asyncio.sleep(self.update_interval)
        self._status = SmartComponentStatus.TERMINATED
        self.on_stop()

    def on_stop(self):
        pass

    def on_start(self):
        #self.logger().warning(f"OrderBookComponent on_start")
        pass

    def terminate_control_loop(self):
        self.terminated.set()
        

    async def control_task(self):
        self.logger().warning(f"control_task")

        if not self.subscribed_to_order_book_trade_event:
            self.subscribe_to_order_book_trade_event()
        
        if not self.profiler: return
        self.check_and_replace_files()
        for trading_pair in self.trading_pairs:
            order_book_data = self.get_order_book_dict(self.exchange, trading_pair, self.depth)
            self.ob_temp_storage[trading_pair].append(order_book_data)
        if self.last_dump_timestamp < self.current_timestamp:
            self.dump_and_clean_temp_storage()

        #if(self.order_book_changed):
        #    self.order_book_changed=False
    def on_order_book_change(self, order_book, connector_name: str, trading_pair: str):
        pass


    def get_order_book_dict(self, exchange: str, trading_pair: str, depth: int = 50):
        order_book = self.connectors[exchange].get_order_book(trading_pair)
        snapshot = order_book.snapshot
        return {
            "ts": self.current_timestamp,
            "bids": snapshot[0].loc[:(depth - 1), ["price", "amount"]].values.tolist(),
            "asks": snapshot[1].loc[:(depth - 1), ["price", "amount"]].values.tolist(),
        }

    def dump_and_clean_temp_storage(self):
        for trading_pair, order_book_info in self.ob_temp_storage.items():
            file = self.ob_file_paths[trading_pair]
            json_strings = [json.dumps(obj) for obj in order_book_info]
            json_data = '\n'.join(json_strings)
            file.write(json_data)
            self.ob_temp_storage[trading_pair] = []
        for trading_pair, trades_info in self.trades_temp_storage.items():
            file = self.trades_file_paths[trading_pair]
            json_strings = [json.dumps(obj) for obj in trades_info]
            json_data = '\n'.join(json_strings)
            file.write(json_data)
            self.trades_temp_storage[trading_pair] = []
        self.last_dump_timestamp = self.current_timestamp + self.time_between_csv_dumps

    def check_and_replace_files(self):
        current_date = datetime.now().strftime("%Y-%m-%d")
        if current_date != self.current_date:
            for file in self.ob_file_paths.values():
                file.close()
            self.create_order_book_and_trade_files()

    def create_order_book_and_trade_files(self):
        if not self.profiler: return
        self.current_date = datetime.now().strftime("%Y-%m-%d")
        self.ob_file_paths = {trading_pair: self.get_file(self.exchange, trading_pair, "order_book_snapshots", self.current_date) for
                              trading_pair in self.trading_pairs}
        self.trades_file_paths = {trading_pair: self.get_file(self.exchange, trading_pair, "trades", self.current_date) for
                                  trading_pair in self.trading_pairs}

    @staticmethod
    def get_file(exchange: str, trading_pair: str, source_type: str, current_date: str):
        file_path = data_path() + f"/{exchange}_{trading_pair}_{source_type}_{current_date}.txt"
        return open(file_path, "a")

    def _process_public_trade(self, event_tag: int, market: ConnectorBase, event: OrderBookTradeEvent):
        # self.logger().warning(f"_process_public_trade")
        current_datetime = datetime.now()
        current_timestamp=current_datetime.timestamp()
        timestamp_str = str(current_timestamp)
        lag=float(float(current_timestamp)-float(event.timestamp))
        self.logger().warning(f"_process_public_trade {lag} {event.timestamp} {timestamp_str} ")
        
        if not self.profiler: return
        self.trades_temp_storage[event.trading_pair].append({
            "ts": event.timestamp,
            "tslocal": timestamp_str,
            "lag": lag,
            "price": event.price,
            "q_base": event.amount,
            "side": event.type.name.lower(),
        })

    # def _process_order_book_event(self, order_book_diff: OrderBookMessage):
    #def _process_data_source_update(self, event_tag: int, market: ConnectorBase, event: Union[OrderBookEvent, OrderBookTradeEvent, OrderBookDataSourceEvent]):
    #    self.logger().warning(f"_process_data_source_update")


    def subscribe_to_order_book_trade_event(self):
        for market in self.connectors.values():
            for order_book in market.order_books.values():
                order_book.add_listener(OrderBookEvent.TradeEvent, self.order_book_trade_event)
                #order_book.add_listener(OrderBookDataSourceEvent.TRADE_EVENT, self.order_book_data_source_update_event)
                #order_book.add_listener(OrderBookDataSourceEvent.SNAPSHOT_EVENT, self.order_book_data_source_update_event)
                #order_book.add_listener(OrderBookDataSourceEvent.DIFF_EVENT, self.order_book_data_source_update_event)
        self.subscribed_to_order_book_trade_event = True
