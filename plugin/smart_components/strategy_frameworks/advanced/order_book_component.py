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
    

    depth = int(os.getenv("DEPTH", 50))
    subscribed_to_order_book_trade_event: bool = False


    @classmethod
    def logger(cls) -> HummingbotLogger:
        if cls._logger is None:
            cls._logger = logging.getLogger(__name__)
        return cls._logger

    def __init__(self, strategy: ScriptStrategyBase, connectors: List[str], update_interval: float = 0.5):
        self.logger().warning(f"OrderBookComponent initializing")
        self.order_book_trade_event = SourceInfoEventForwarder(self._process_public_trade)
        self.order_book_data_source_update_event = SourceInfoEventForwarder(self._process_data_source_update)

        # Somehow doesn't work
        # self.terminated = asyncio.Event()
        # safe_ensure_future(self.control_loop())
        # self.logger().warning(f"OrderBookComponent initialized")

    @property
    def status(self):
        return self._status

    '''
     # Somehow doesn't work
    async def control_loop(self):
        self.on_start()
        self._status = SmartComponentStatus.ACTIVE
        while not self.terminated.is_set():
            # await self.control_task()
            await asyncio.sleep(self.update_interval)
        self._status = SmartComponentStatus.TERMINATED
        self.on_stop()

    def on_stop(self):
        pass

    def on_start(self):
        pass

    def terminate_control_loop(self):
        self.terminated.set()

    async def control_task(self):
        self.control_task2()
    '''    

    def control_task(self):
        if not self.subscribed_to_order_book_trade_event:
            self.subscribe_to_order_book_trade_event()
        #if(self.order_book_changed):
        #    self.order_book_changed=False

    def on_order_book_change(self, order_book, connector_name: str, trading_pair: str):
        pass

    def on_order_book_trade(self, order_book, connector_name: str, trading_pair: str):
        pass

    def get_order_book_dict(self, exchange: str, trading_pair: str, depth: int = 50):
        order_book = self.connectors[exchange].get_order_book(trading_pair)
        snapshot = order_book.snapshot
        return {
            "ts": self.current_timestamp,
            "bids": snapshot[0].loc[:(depth - 1), ["price", "amount"]].values.tolist(),
            "asks": snapshot[1].loc[:(depth - 1), ["price", "amount"]].values.tolist(),
        }



    def _process_public_trade(self, event_tag: int, market: ConnectorBase, event: OrderBookTradeEvent):
        self.logger().warning(f"_process_public_trade")
        self.logger().warning(f"market.name: {json.dumps(market.name)}")
        # self.logger().warning(f"market: {json.dumps(market)}")
        
        # return

        current_datetime = datetime.now()
        current_timestamp=current_datetime.timestamp()
        self.current_timestamp=current_timestamp;
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
    def _process_data_source_update(self, event_tag: int, market: ConnectorBase, event: Union[OrderBookEvent, OrderBookTradeEvent, OrderBookDataSourceEvent]):
        self.logger().warning(f"_process_data_source_update")


    def subscribe_to_order_book_trade_event(self):
        self.logger().warning(f"subscribe_to_order_book_trade_event")
        for market in self.connectors.values():
            self.logger().warning(f"market")
            for order_book in market.order_books.values():
                self.logger().warning(f"orderbook")
                order_book.add_listener(OrderBookEvent.TradeEvent, self.order_book_trade_event)
                order_book.add_listener(OrderBookEvent.OrderBookDataSourceUpdateEvent, self.order_book_data_source_update_event)

                #order_book.add_listener(OrderBookDataSourceEvent.TRADE_EVENT, self.order_book_data_source_update_event)
                #order_book.add_listener(OrderBookDataSourceEvent.SNAPSHOT_EVENT, self.order_book_data_source_update_event)
                #order_book.add_listener(OrderBookDataSourceEvent.DIFF_EVENT, self.order_book_data_source_update_event)
        self.subscribed_to_order_book_trade_event = True
