import asyncio
from decimal import Decimal
from enum import Enum
from typing import List, Tuple, Union

from hummingbot.connector.connector_base import ConnectorBase

from hummingbot.core.event.event_forwarder import SourceInfoEventForwarder
from hummingbot.core.event.events import OrderBookEvent, OrderBookTradeEvent

from hummingbot.core.utils.async_utils import safe_ensure_future
from hummingbot.strategy.script_strategy_base import ScriptStrategyBase


class SmartComponentStatus(Enum):
    NOT_STARTED = 1
    ACTIVE = 2
    TERMINATED = 3

'''

class MarketEvent(Enum):
    ReceivedAsset = 101
    BuyOrderCompleted = 102
    SellOrderCompleted = 103
    # Trade = 104  Deprecated
    WithdrawAsset = 105  # Locally Deprecated, but still present in hummingsim
    OrderCancelled = 106
    OrderFilled = 107
    OrderExpired = 108
    OrderUpdate = 109
    TradeUpdate = 110
    OrderFailure = 198
    TransactionFailure = 199
    BuyOrderCreated = 200
    SellOrderCreated = 201
    FundingPaymentCompleted = 202
    FundingInfo = 203
    RangePositionLiquidityAdded = 300
    RangePositionLiquidityRemoved = 301
    RangePositionUpdate = 302
    RangePositionUpdateFailure = 303
    RangePositionFeeCollected = 304
    RangePositionClosed = 305

class AccountEvent(Enum):
    PositionModeChangeSucceeded = 400
    PositionModeChangeFailed = 401
    !!!!BalanceEvent = 402
    !!!PositionUpdate = 403
    MarginCall = 404
    LiquidationEvent = 405

        return self.connectors[connector_name].get_balance(asset)

    def get_available_balance(self, connector_name: str, asset: str):
        return self.connectors[connector_name].get_available_balance(asset)
'''

class OrderBookComponent:
    _logger = None

    @classmethod
    def logger(cls) -> HummingbotLogger:
        if cls._logger is None:
            cls._logger = logging.getLogger(__name__)
        return cls._logger

    def __init__(self, strategy: ScriptStrategyBase, connectors: List[str], update_interval: float = 0.5):
        self.order_book_changed=False
        
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
        pass

    def terminate_control_loop(self):
        self.terminated.set()
        self.unregister_events()

    async def control_task(self):
        if(self.order_book_changed):
            self.order_book_changed=False
            connector_name=market.exchange
            trading_pair=market.trading_pai
            self.order_book[connector_name][trading_pair]=self.connectors[connector_name].get_order_book(connector_name, trading_pair)
            self.on_order_book_change(self,order_book, connector_name, trading_pair)


    def on_order_book_change(self, order_book, connector_name: str, trading_pair: str):
        pass

    def register_events(self):
        """Start listening to events from the given market."""
        for connector in self.connectors.values():
            for event_pair in self._event_pairs:
                connector.add_listener(event_pair[0], event_pair[1])

    def unregister_events(self):
        """Stop listening to events from the given market."""
        for connector in self.connectors.values():
            for event_pair in self._event_pairs:
                connector.remove_listener(event_pair[0], event_pair[1])


    def process_order_book_data_event(self,
                                      event_tag: int,
                                      market: ConnectorBase,
                                      event: Union[OrderBookEvent, OrderBookTradeEvent]):
        
        self.logger().warning(f"process_order_book_data_event market={market}")
        self.order_book_changed=True
        pass

    def process_order_book_trade_event(self,
                                      event_tag: int,
                                      market: ConnectorBase,
                                      event: Union[OrderBookEvent, OrderBookTradeEvent]):
        self.logger().warning(f"process_order_book_trade_event market={market}")
        self.order_book_changed=True
        pass

