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

from hummingbot.core.data_type.common import OrderType

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

    @property
    def taker_is_perpetual(self):
        """
        Checks if the exchange is a perpetual market.
        """
        return "perpetual" in self.config.exchange

    def update_strategy_markets_dict(self, markets_dict: dict[str, Set] = {}):
        super().update_strategy_markets_dict(markets_dict)
        if self.config.taker_exchange not in markets_dict:
            markets_dict[self.config.taker_exchange] = {self.config.taking_pair}
        else:
            markets_dict[self.config.taker_exchange].add(self.config.taking_pair)
        return markets_dict