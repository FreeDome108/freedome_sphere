import logging
import math
from decimal import Decimal
from typing import Union

from hummingbot.core.data_type.common import OrderType, PositionAction, PriceType, TradeType
from hummingbot.core.data_type.order_candidate import OrderCandidate, PerpetualOrderCandidate
from hummingbot.core.event.events import (
    BuyOrderCompletedEvent,
    BuyOrderCreatedEvent,
    MarketOrderFailureEvent,
    OrderCancelledEvent,
    OrderFilledEvent,
    SellOrderCompletedEvent,
    SellOrderCreatedEvent,
)
from hummingbot.logger import HummingbotLogger
from hummingbot.smart_components.executors.position_executor.data_types import (
    CloseType,
    PositionConfig,
    PositionExecutorStatus,
    TrackedOrder,
)
from hummingbot.strategy.script_strategy_base import ScriptStrategyBase
from hummingbot.smart_components.executors.position_executor.position_executor_base import PositionExecutor as PositionExecutorBase

#TODO: отменять позицию, если вышли из profitability
class PositionExecutor(PositionExecutorBase):


    def __init__(self, strategy: ScriptStrategyBase, position_config: PositionConfig, update_interval: float = 1.0):
        # Taker order tracking
        self._taker_order: TrackedOrder = TrackedOrder()
        super().__init__(strategy=strategy, position_config=position_config, update_interval=update_interval)

    @property
    def taker_is_perpetual(self):
        return "perpetual" in self.taker_exchange

    @property
    def taker_exchange(self):
        return self.position_config.taker_exchange

    @property
    def taker_pair(self):
        return self.position_config.taker_pair

    @property
    def taker_order_type(self):
        return self.position_config.taker_order_type

    def taker_price(self):
        taker_price = self.entry_price * (1 + self._position_config.taker_profitability) if self.side == TradeType.BUY else \
            self.entry_price * (1 - self._position_config.taker_profitability)
        return take_profit_price

    @property
    def taker_order(self):
        return self._taker_order


    def taker_condition(self):
        if self.side == TradeType.BUY:
            return self.close_price >= self.taker_price
        else:
            return self.close_price <= self.taker_price

    def on_stop(self):
        super().on_stop()
        if self.taker_order.order and self.taker_order.order.is_open:
            self.logger().info(f"Taker order status: {self.taker_.order.current_state}")
            self.remove_taker()

    def control_barriers(self):
        super().control_barriers()
        if not self.close_order.order_id:
            if self.position_config.taker_profitability:
                self.control_taker()


    def place_close_order(self, close_type: CloseType, price: Decimal = Decimal("NaN")):
        tp_partial_execution = self.take_profit_order.executed_amount_base if self.take_profit_order.executed_amount_base else Decimal("0")
        taker_partial_execution = self.taker_order.executed_amount_base if self.taker_order.executed_amount_base else Decimal("0")

        order_id = self.place_order(
            connector_name=self.exchange,
            trading_pair=self.trading_pair,
            order_type=OrderType.MARKET,
            amount=self.filled_amount - tp_partial_execution-taker_partial_execution,
            price=price,
            side=TradeType.SELL if self.side == TradeType.BUY else TradeType.BUY,
            position_action=PositionAction.CLOSE,
        )
        self.close_type = close_type
        self._close_order.order_id = order_id
        self.logger().info(f"Placing close order --> Filled amount: {self.filled_amount} | TP Partial execution: {tp_partial_execution} | Taker Partial execution: {taker_partial_execution}")


    def place_close_taker_order(self, close_type: CloseType, price: Decimal = Decimal("NaN")):
        tp_partial_execution = self.take_profit_order.executed_amount_base if self.take_profit_order.executed_amount_base else Decimal("0")
        taker_partial_execution = self.taker_order.executed_amount_base if self.taker_order.executed_amount_base else Decimal("0")

        order_id = self.place_order(
            connector_name=self.taker_exchange,
            trading_pair=self.taker_pair,
            order_type=OrderType.MARKET,
            amount=self.filled_amount - tp_partial_execution-taker_partial_execution,
            price=price,
            side=TradeType.SELL if self.side == TradeType.BUY else TradeType.BUY,
            position_action=PositionAction.CLOSE,
        )
        self.close_type = close_type
        self._close_order.order_id = order_id
        self.logger().info(f"Placing close taker order --> Filled amount: {self.filled_amount} | TP Partial execution: {tp_partial_execution} | Taker Partial execution: {taker_partial_execution}")


    def control_take_profit(self):
        if self.take_profit_order_type.is_limit_type():
            if not self.take_profit_order.order_id:
                self.place_take_profit_limit_order()
            else:
                if self.taker_order.order_id and self.taker_order_type.is_limit_type():  
                    if not math.isclose(self.taker_order.order.amount+self.take_profit_order.order.amount, self.open_order.executed_amount_base):
                        self.renew_taker_order()
                else:
                    if not math.isclose(self.take_profit_order.order.amount, self.open_order.executed_amount_base):
                        self.renew_take_profit_order()
        elif self.take_profit_condition():
            self.place_close_order(close_type=CloseType.TAKE_PROFIT)

    
    def control_taker(self):
        if self.taker_order_type.is_limit_type():
            if not self.taker_order.order_id:
                self.place_taker_limit_order()
            else:
                if self.take_profit_order.order_id and self.take_profit_order_type.is_limit_type():  
                    if not math.isclose(self.taker_order.order.amount+self.take_profit_order.order.amount, self.open_order.executed_amount_base):
                        self.renew_taker_order()
                else:
                    if not math.isclose(self.taker_order.order.amount, self.open_order.executed_amount_base):
                        self.renew_taker_order()
        elif self.taker_condition():
            self.place_close_taker_order(close_type=CloseType.TAKER)
            

    def place_taker_limit_order(self):
        order_id = self.place_order(
            connector_name=self._position_config.taker_exchange,
            trading_pair=self._position_config.taker_pair,
            amount=self.filled_amount,
            price=self.take_profit_price,#!!!!!
            order_type=self.taker_order_type,
            position_action=PositionAction.CLOSE,
            side=TradeType.BUY if self.side == TradeType.SELL else TradeType.SELL,
        )
        self.taker_order.order_id = order_id
        self.logger().info("Placing taker order")

    def renew_taker_order(self):
        self.remove_taker()
        self.place_taker_limit_order()
        self.logger().info("Renewing taker order")

    def remove_taker(self):
        self._strategy.cancel(
            connector_name=self.taker_exchange,
            trading_pair=self.taker_pair,
            order_id=self._taker_order.order_id
        )
        self.logger().info("Removing taker")




    def process_order_created_event(self, _, market, event: Union[BuyOrderCreatedEvent, SellOrderCreatedEvent]):
        super().process_order_created_event(_, market, event)
        if self.taker_order.order_id == event.order_id:
            self.taker_order.order = self.get_in_flight_order(self.exchange, event.order_id)
            self.logger().info("Taker Order Created")



    def process_order_completed_event(self, _, market, event: Union[BuyOrderCompletedEvent, SellOrderCompletedEvent]):
        super().process_order_completed_event(_, market, event)
        if self.taker_order.order_id == event.order_id:
            #!!!!!
            self.close_type = CloseType.TAKER #!!!!!
            self.executor_status = PositionExecutorStatus.COMPLETED
            self.close_timestamp = event.timestamp #!!!!!
            self.close_order.order_id = event.order_id
            self.close_order.order = self.taker_order.order
            self.logger().info(f"Closed by {self.close_type}")
            self.terminate_control_loop() #!!!!!



    def process_order_filled_event(self, _, market, event: OrderFilledEvent):
        # На данный момент не видно доработок
        super().process_order_filled_event(_, market, event)

    def process_order_failed_event(self, _, market, event: MarketOrderFailureEvent):
        super().process_order_failed_event (_, market, event)
        if self.taker_order.order_id == event.order_id:
            self.taker_order.order_id = None

    def to_json(self):
        return {
            "timestamp": self.position_config.timestamp,
            "exchange": self.exchange,
            "trading_pair": self.trading_pair,
            "taker_exchange": self.taker_exchange,
            "taker_pair": self.taker_pair,
            "side": self.side.name,
            "amount": self.filled_amount,
            "trade_pnl": self.trade_pnl,
            "trade_pnl_quote": self.trade_pnl_quote,
            "cum_fee_quote": self.cum_fee_quote,
            "net_pnl_quote": self.net_pnl_quote,
            "net_pnl": self.net_pnl,
            "close_timestamp": self.close_timestamp,
            "executor_status": self.executor_status.name,
            "close_type": self.close_type.name if self.close_type else None,
            "entry_price": self.entry_price,
            "close_price": self.close_price,
            "sl": self.position_config.stop_loss,
            "tp": self.position_config.take_profit,
            "tl": self.position_config.time_limit,
            "open_order_type": self.open_order_type.name,
            "taker_order_type": self.taker_order_type.name,
            "take_profit_order_type": self.take_profit_order_type.name,
            "stop_loss_order_type": self.stop_loss_order_type.name,
            "time_limit_order_type": self.time_limit_order_type.name,
            "leverage": self.position_config.leverage,
        }

    def to_format_status(self, scale=1.0):
        lines = []
        current_price = self.get_price(self.exchange, self.trading_pair)
        amount_in_quote = self.entry_price * (self.filled_amount if self.filled_amount > Decimal("0") else self.amount)
        quote_asset = self.trading_pair.split("-")[1]
        if self.is_closed:
            lines.extend([f"""
| Trading Pair: {self.trading_pair} | Exchange: {self.exchange} | Side: {self.side}
| Entry price: {self.entry_price:.6f} | Close price: {self.close_price:.6f} | Amount: {amount_in_quote:.4f} {quote_asset}
| Realized PNL: {self.trade_pnl_quote:.6f} {quote_asset} | Total Fee: {self.cum_fee_quote:.6f} {quote_asset}
| PNL (%): {self.net_pnl * 100:.2f}% | PNL (abs): {self.net_pnl_quote:.6f} {quote_asset} | Close Type: {self.close_type}
"""])
        else:
            lines.extend([f"""
| Trading Pair: {self.trading_pair} | Exchange: {self.exchange} | Side: {self.side} |
| Entry price: {self.entry_price:.6f} | Close price: {self.close_price:.6f} | Amount: {amount_in_quote:.4f} {quote_asset}
| Unrealized PNL: {self.trade_pnl_quote:.6f} {quote_asset} | Total Fee: {self.cum_fee_quote:.6f} {quote_asset}
| PNL (%): {self.net_pnl * 100:.2f}% | PNL (abs): {self.net_pnl_quote:.6f} {quote_asset} | Close Type: {self.close_type}
        """])

        if self.executor_status == PositionExecutorStatus.ACTIVE_POSITION:
            progress = 0
            if self.position_config.time_limit:
                time_scale = int(scale * 60)
                seconds_remaining = (self.end_time - self._strategy.current_timestamp)
                time_progress = (self.position_config.time_limit - seconds_remaining) / self.position_config.time_limit
                time_bar = "".join(['*' if i < time_scale * time_progress else '-' for i in range(time_scale)])
                lines.extend([f"Time limit: {time_bar}"])

            if self.position_config.take_profit and self.position_config.stop_loss:
                price_scale = int(scale * 60)
                stop_loss_price = self.stop_loss_price
                take_profit_price = self.take_profit_price
                if self.side == TradeType.BUY:
                    price_range = take_profit_price - stop_loss_price
                    progress = (current_price - stop_loss_price) / price_range
                elif self.side == TradeType.SELL:
                    price_range = stop_loss_price - take_profit_price
                    progress = (stop_loss_price - current_price) / price_range
                price_bar = [f'--{current_price:.5f}--' if i == int(price_scale * progress) else '-' for i in range(price_scale)]
                price_bar.insert(0, f"SL:{stop_loss_price:.5f}")
                price_bar.append(f"TP:{take_profit_price:.5f}")
                lines.extend(["".join(price_bar)])
            if self.trailing_stop_config:
                lines.extend([f"Trailing stop status: {self._trailing_stop_activated} | Trailing stop price: {self._trailing_stop_price:.5f}"])
            lines.extend(["-----------------------------------------------------------------------------------------------------------"])
        return lines



    def check_budget(self):
        super().check_budget()
        self.check_taker_budget()

    def check_taker_budget(self):
        if self.taker_is_perpetual:
            order_candidate = PerpetualOrderCandidate(
                trading_pair=self.taker_pair,
                is_maker=self.taker_order_type.is_limit_type(),
                order_type=self.taker_order_type,
                order_side=TradeType.SELL if self.side == TradeType.BUY else TradeType.BUY,
                amount=self.amount,
                price=self.entry_price,
                leverage=Decimal(self.position_config.leverage),
            )
        else:
            order_candidate = OrderCandidate(
                trading_pair=self.taker_pair,
                is_maker=self.taker_order_type.is_limit_type(),
                order_type=self.taker_order_type,
                order_side=TradeType.SELL if self.side == TradeType.BUY else TradeType.BUY,
                amount=self.amount,
                price=self.entry_price,
            )
        adjusted_order_candidate = self.taker_adjust_order_candidate(order_candidate)
        if not adjusted_order_candidate:
            self.terminate_control_loop()
            self.close_type = CloseType.INSUFFICIENT_BALANCE_TAKER
            self.executor_status = PositionExecutorStatus.COMPLETED
            error = "Not enough budget on taker to open position in case need!"
            self.logger().error(error)


    def taker_adjust_order_candidate(self, order_candidate):
        adjusted_order_candidate: OrderCandidate = self.connectors[self.taker_exchange].budget_checker.adjust_candidate(order_candidate)
        if adjusted_order_candidate.amount > Decimal("0"):
            return adjusted_order_candidate
