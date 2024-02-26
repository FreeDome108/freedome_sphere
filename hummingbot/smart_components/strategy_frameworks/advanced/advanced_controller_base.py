from decimal import Decimal
from typing import Dict, List, Optional, Set

from hummingbot.core.data_type.common import PositionMode, TradeType
from hummingbot.smart_components.executors.position_executor.data_types import PositionConfig, TrailingStop
from hummingbot.smart_components.executors.position_executor.position_executor import PositionExecutor
from hummingbot.smart_components.strategy_frameworks.controller_base import ControllerBase, ControllerConfigBase
from hummingbot.smart_components.strategy_frameworks.data_types import OrderLevel

from hummingbot.smart_components.strategy_frameworks.market_making.market_making_controller_base import (
    MarketMakingControllerBase,
    MarketMakingControllerConfigBase,
)

class AdvancedControllerConfigBase(MarketMakingControllerConfigBase):
    maker_perpetual_only_close: Optional[bool] = None
    taker_exchange: str
    taker_pair: str
    taker_profitability: Optional[Decimal] = None
    taker_order_type: OrderType = OrderType.MARKET
    taker_perpetual_only_close: Optional[bool] = None

class AdvancedControllerBase(MarketMakingControllerBase):

    def __init__(self,
                 config: AdvancedControllerConfigBase,
                 excluded_parameters: Optional[List[str]] = None):
        super().__init__(config, excluded_parameters)
        self.config = config  # this is only for type hints

