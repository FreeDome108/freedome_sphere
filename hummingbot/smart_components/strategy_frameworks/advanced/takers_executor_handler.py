import logging
from decimal import Decimal
from typing import Dict, Optional

from hummingbot.core.data_type.common import TradeType
from hummingbot.logger import HummingbotLogger
from hummingbot.smart_components.executors.position_executor.data_types import CloseType, PositionExecutorStatus
from hummingbot.smart_components.strategy_frameworks.executor_handler_base import ExecutorHandlerBase
#from hummingbot.smart_components.strategy_frameworks.advanced.takers_controller_base import (
#    TakersControllerBase,
#)

from hummingbot.strategy.script_strategy_base import ScriptStrategyBase

# Сюда вынесена вся логика по работе с рынком taker_exchange.
# Обращения идут из:
# 1. dman.py, для него выдается информация по цене выставления позиций
# 2. position_executor.py, для него методы по закрытию позиций и контролю цены
# Для внешних источников taker - единый рынок сбыта, но по факту внутри логика реализована по закрытию на лучшем из рынков takers.
# В текущей имплементации takers рынки состоят тоже из одного рынка.


class TakersExecutorHandler(ExecutorHandlerBase):
    _logger = None

    @classmethod
    def logger(cls) -> HummingbotLogger:
        if cls._logger is None:
            cls._logger = logging.getLogger(__name__)
        return cls._logger

    def __init__(self, strategy: ScriptStrategyBase):
        #def __init__(self, strategy: ScriptStrategyBase, controller: TakersControllerBase,
        #         update_interval: float = 1.0, executors_update_interval: float = 1.0):
        #super().__init__(strategy, controller, update_interval, executors_update_interval)
        #self.controller = controller
        #self.global_trailing_stop_config = self.controller.config.global_trailing_stop_config
        #self._trailing_stop_pnl_by_side: Dict[TradeType, Optional[Decimal]] = {TradeType.BUY: None, TradeType.SELL: None}
        self.taker_prices = {}
        self.get_order_book(self.config.taker_exchange, self.config.taker_pair)
        #Поже изменить на механизм подписки
        #self.subscribe_to_order_book(self.config.taker_exchange, self.config.taker_pair)

    def on_stop(self):
        #if self.controller.is_perpetual:
        #    self.close_open_positions(connector_name=self.controller.config.exchange, trading_pair=self.controller.config.trading_pair)
        super().on_stop()

    def on_start(self):
        super().on_start()
        #if self.controller.is_perpetual:
        #    self.set_leverage_and_position_mode()


    def get_order_book(self, connector_exchange:str, connector_pair: str):
        order_book=self.strategy.connectors[connector_exchange].get_order_book(connector_pair)
        self.on_order_book_change(order_book,connector_exchange,connector_pair)

    def on_order_book_change(self, order_book, connector_exchange: str, connector_pair: str):
        self.calculate_taker_prices(order_book, connector_exchange, connector_pair, TradeType.SELL);
        self.calculate_taker_prices(order_book, connector_exchange, connector_pair, TradeType.BUY);

    def calculate_taker_prices(self, order_book, connector_exchange: str, connector_pair: str, trade_type: TradeType):
        position_size = self.config.order_amount
        positions_count = self.config.n_levels
        volumes = [Decimal(position_size) for _ in range(positions_count)]

        prices = []

        for volume in volumes:
            total_volume = Decimal("0")
            weighted_price = Decimal("0")
            orders = order_book['asks'] if trade_type == TradeType.BUY else order_book['bids']

            for order_price, order_volume in orders:
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