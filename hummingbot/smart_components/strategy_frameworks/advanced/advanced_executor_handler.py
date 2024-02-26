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
