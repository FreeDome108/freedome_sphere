import asyncio
from decimal import Decimal
from enum import Enum
from typing import List, Tuple, Union

from hummingbot.connector.connector_base import ConnectorBase

from hummingbot.core.event.event_forwarder import SourceInfoEventForwarder
from hummingbot.core.event.events import OrderBookEvent, OrderBookTradeEvent

)
from hummingbot.core.utils.async_utils import safe_ensure_future
from hummingbot.strategy.script_strategy_base import ScriptStrategyBase


class SmartComponentStatus(Enum):
    NOT_STARTED = 1
    ACTIVE = 2
    TERMINATED = 3


class OrderBookComponent:
        def __init__(self, strategy: ScriptStrategyBase, connectors: List[str], update_interval: float = 0.5):
        self._strategy: ScriptStrategyBase = strategy
        self.update_interval = update_interval
        self.connectors = {connector_name: connector for connector_name, connector in strategy.connectors.items() if
                           connector_name in connectors}
        self._status: SmartComponentStatus = SmartComponentStatus.NOT_STARTED
        self._states: list = []

        self._order_book_data_forwarder = SourceInfoEventForwarder(self.process_order_book_data_event)
        self._order_book_trade_forwarder = SourceInfoEventForwarder(self.process_order_book_trade_event)


        self._event_pairs: List[Tuple[MarketEvent, SourceInfoEventForwarder]] = [
            (OrderBookEvent.TradeEvent, self._order_book_data_forwarder),
            (OrderBookEvent.OrderBookDataSourceUpdateEvent, self._order_book_trade_forwarder),
        ]
        self.register_events()
        self.terminated = asyncio.Event()
        safe_ensure_future(self.control_loop())