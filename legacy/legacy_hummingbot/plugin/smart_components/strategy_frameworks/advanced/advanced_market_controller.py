import logging
from decimal import Decimal
from typing import Dict, Optional, List

from hummingbot.core.data_type.common import TradeType
from hummingbot.logger import HummingbotLogger

#from hummingbot.smart_components.executors.position_executor.data_types import CloseType
from hummingbot.smart_components.strategy_frameworks.advanced.order_book_component import OrderBookComponent

from hummingbot.strategy.script_strategy_base import ScriptStrategyBase


class AdvancedMarketController(OrderBookComponent):
    _logger = None

    @classmethod
    def logger(cls) -> HummingbotLogger:
        if cls._logger is None:
            cls._logger = logging.getLogger(__name__)
        return cls._logger

    def __init__(self, strategy: ScriptStrategyBase, connectors: List[str], update_interval: float = 1.0):
        super().__init__(strategy=strategy, connectors=connectors, update_interval=update_interval)

        #self.taker_prices = {}
        #self.get_order_book(self.config.taker_exchange, self.config.taker_pair)
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

        # self.add_listener(MarketEvent.OrderFilled, self.on_order_filled)

    #def on_order_filled(self, event: OrderFilledEvent):
    def did_fill_order(self, event: OrderFilledEvent):
        self.logger().info(f"Order {event.order_id} filled, {event.trade_type}, {event.amount} @ {event.price}")

        # [TODO] Если ордер не создан именно этим ботом, то игнорировать
        # if event.exchange == self.maker_exchange and event.trading_pair == self.maker_pair:

        # Исполняем арбитражную позицию на taker рынке
        # taker_action = TradeType.SELL if event.trade_type == TradeType.BUY else TradeType.BUY
        # self.execute_taker_trade(taker_action, event.amount)

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