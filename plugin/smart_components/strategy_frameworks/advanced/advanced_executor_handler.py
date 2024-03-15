import logging
from decimal import Decimal
from typing import Dict, Optional

from hummingbot.core.data_type.common import TradeType
from hummingbot.logger import HummingbotLogger
from hummingbot.smart_components.executors.position_executor.data_types import (
    PositionExecutorConfig,
    PositionExecutorStatus,
)
from hummingbot.smart_components.models.executors import CloseType, TrackedOrder

from hummingbot.smart_components.strategy_frameworks.executor_handler_base import ExecutorHandlerBase
from hummingbot.smart_components.strategy_frameworks.advanced.advanced_controller_base import (
    AdvancedControllerBase,
)
from hummingbot.smart_components.strategy_frameworks.advanced.advanced_market_controller import AdvancedMarketController

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

        self.markets_monitor=self.strategy.markets_monitor # -> вот здесь можно получить состояние маркета
        

    def on_start(self):
        super().on_start()
        if self.controller.taker_is_perpetual:
            self.taker_set_leverage_and_position_mode()
        #self.get_order_book(self.controller.config.taker_exchange, self.controller.config.taker_pair)

    def taker_set_leverage_and_position_mode(self):
        connector = self.strategy.connectors[self.controller.config.taker_exchange]
        connector.set_position_mode(self.controller.config.position_mode)
        connector.set_leverage(trading_pair=self.controller.config.taker_pair, leverage=self.controller.config.leverage)




    async def control_task(self):
        if self.controller.all_candles_ready:
            current_metrics = {
                TradeType.BUY: self.empty_metrics_dict(),
                TradeType.SELL: self.empty_metrics_dict()}
            for order_level in self.controller.config.order_levels:
                current_executor = self.position_executors[order_level.level_id]
                if current_executor:
                    closed_and_not_in_cooldown = current_executor.is_closed and not self.controller.cooldown_condition(
                        current_executor, order_level) or current_executor.close_type == CloseType.EXPIRED
                    active_and_early_stop_condition = current_executor.executor_status == PositionExecutorStatus.ACTIVE_POSITION and self.controller.early_stop_condition(
                        current_executor, order_level)
                    order_placed_and_refresh_condition = current_executor.executor_status == PositionExecutorStatus.NOT_STARTED and self.controller.refresh_order_condition(
                        current_executor, order_level)
                    if closed_and_not_in_cooldown:
                        self.store_position_executor(order_level.level_id)
                    elif active_and_early_stop_condition or order_placed_and_refresh_condition:
                        current_executor.early_stop()
                    elif current_executor.executor_status == PositionExecutorStatus.ACTIVE_POSITION:
                        current_metrics[current_executor.side]["amount"] += current_executor.filled_amount * current_executor.entry_price
                        current_metrics[current_executor.side]["net_pnl_quote"] += current_executor.net_pnl_quote
                        current_metrics[current_executor.side]["executors"].append(current_executor)
                else:
                    # Вот именно здесь мы пытались слать цены taker рынков, но возможно нужно по другому.
                    taker_prices=self.markets_monitor.get_taker_prices(self.strategy.taker_exchange,self.strategy.trading_pair);
                    position_config = self.controller.get_position_config(taker_prices, order_level)
                    # position_config = self.controller.get_position_config(order_level)
                    if position_config:
                        self.create_position_executor(position_config, order_level.level_id)
            if self.global_trailing_stop_config:
                for side, global_trailing_stop_conf in self.global_trailing_stop_config.items():
                    if current_metrics[side]["amount"] > 0:
                        current_pnl_pct = current_metrics[side]["net_pnl_quote"] / current_metrics[side]["amount"]
                        trailing_stop_pnl = self._trailing_stop_pnl_by_side[side]
                        if not trailing_stop_pnl and current_pnl_pct > global_trailing_stop_conf.activation_price:
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


        '''
        if self.controller.all_candles_ready:
            current_metrics = {
                TradeType.BUY: self.empty_metrics_dict(),
                TradeType.SELL: self.empty_metrics_dict()}
            for order_level in self.controller.config.order_levels:
                current_executor = self.position_executors[order_level.level_id]
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
                    # Вот именно здесь мы пытались слать цены taker рынков, но возможно нужно по другому.
                    taker_prices=self.markets_monitor.get_taker_prices(self.strategy.taker_exchange,self.strategy.trading_pair);
                    position_config = self.controller.get_position_config(taker_prices, order_level)
                    #position_config = self.controller.get_position_config(order_level)
                    if position_config:
                        self.create_position_executor(position_config, order_level.level_id)
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
        '''