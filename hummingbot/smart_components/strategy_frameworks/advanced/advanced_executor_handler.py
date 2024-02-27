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

    def on_start(self):
        super().on_start()
        if self.controller.taker_is_perpetual:
            self.taker_set_leverage_and_position_mode()

    def taker_set_leverage_and_position_mode(self):
        connector = self.strategy.connectors[self.controller.config.exchange]
        connector.set_position_mode(self.controller.config.position_mode)
        connector.set_leverage(trading_pair=self.controller.config.trading_pair, leverage=self.controller.config.leverage)