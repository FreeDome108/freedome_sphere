import logging
from decimal import Decimal
from typing import Dict, Optional

from hummingbot.core.data_type.common import TradeType
from hummingbot.logger import HummingbotLogger
from hummingbot.smart_components.executors.position_executor.data_types import CloseType, PositionExecutorStatus
from hummingbot.smart_components.strategy_frameworks.executor_handler_base import ExecutorHandlerBase
from hummingbot.smart_components.strategy_frameworks.advanced.advanced_controller_base import (
    AdvancedControllerBase,
)

from hummingbot.smart_components.strategy_frameworks.market_making.market_making_executor_handler import (
    MarketMakingExecutorHandler,
)

from hummingbot.strategy.script_strategy_base import ScriptStrategyBase


class AdvancedExecutorHandler(MarketMakingExecutorHandler):
    def __init__(self, strategy: ScriptStrategyBase, controller: AdvancedControllerBase,
                 update_interval: float = 1.0, executors_update_interval: float = 1.0):
        super().__init__(strategy, controller, update_interval, executors_update_interval)
        self.controller = controller
        self.taker_prices = {}
        

    def on_start(self):
        super().on_start()
        if self.controller.taker_is_perpetual:
            self.taker_set_leverage_and_position_mode()
        self.get_order_book(self.config.taker_exchange, self.config.taker_pair)

    def taker_set_leverage_and_position_mode(self):
        connector = self.strategy.connectors[self.controller.config.taker_exchange]
        connector.set_position_mode(self.controller.config.position_mode)
        connector.set_leverage(trading_pair=self.controller.config.taker_pair, leverage=self.controller.config.leverage)


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

    async def control_task(self):
        if self.controller.all_candles_ready:
            current_metrics = {
                TradeType.BUY: self.empty_metrics_dict(),
                TradeType.SELL: self.empty_metrics_dict()}
            for order_level in self.controller.config.order_levels:
                current_executor = self.level_executors[order_level.level_id]
                if current_executor:
                    closed_and_not_in_cooldown = current_executor.is_closed and not self.controller.cooldown_condition(
                        current_executor, order_level) or current_executor.close_type == CloseType.EXPIRED
                    active_and_early_stop_condition = current_executor.executor_status == PositionExecutorStatus.ACTIVE_POSITION and self.controller.early_stop_condition(
                        current_executor, order_level)
                    order_placed_and_refresh_condition = current_executor.executor_status == PositionExecutorStatus.NOT_STARTED and self.controller.refresh_order_condition(
                        current_executor, order_level)
                    if closed_and_not_in_cooldown:
                        self.store_executor(current_executor, order_level)
                    elif active_and_early_stop_condition or order_placed_and_refresh_condition:
                        current_executor.early_stop()
                    elif current_executor.executor_status == PositionExecutorStatus.ACTIVE_POSITION:
                        current_metrics[current_executor.side]["amount"] += current_executor.filled_amount * current_executor.entry_price
                        current_metrics[current_executor.side]["net_pnl_quote"] += current_executor.net_pnl_quote
                        current_metrics[current_executor.side]["executors"].append(current_executor)
                else:
                    position_config = self.controller.get_position_config(self.taker_prices, order_level)
                    if position_config:
                        self.create_executor(position_config, order_level)
            if self.global_trailing_stop_config:
                for side, global_trailing_stop_conf in self.global_trailing_stop_config.items():
                    if current_metrics[side]["amount"] > 0:
                        current_pnl_pct = current_metrics[side]["net_pnl_quote"] / current_metrics[side]["amount"]
                        trailing_stop_pnl = self._trailing_stop_pnl_by_side[side]
                        if not trailing_stop_pnl and current_pnl_pct > global_trailing_stop_conf.activation_price_delta:
                            self._trailing_stop_pnl_by_side[side] = current_pnl_pct - global_trailing_stop_conf.trailing_delta
                            self.logger().info("Global Trailing Stop Activated!")
                        if trailing_stop_pnl:
                            if current_pnl_pct < trailing_stop_pnl:
                                self.logger().info("Global Trailing Stop Triggered!")
                                for executor in current_metrics[side]["executors"]:
                                    executor.early_stop()
                                self._trailing_stop_pnl_by_side[side] = None
                            elif current_pnl_pct - global_trailing_stop_conf.trailing_delta > trailing_stop_pnl:
                                self._trailing_stop_pnl_by_side[side] = current_pnl_pct - global_trailing_stop_conf.trailing_delta
