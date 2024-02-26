from hummingbot.smart_components.executors.position_executor.base_data_types import (
    CloseType as CloseTypeBase,
    PositionConfig as PositionConfigBase,
    PositionExecutorStatus as PositionExecutorStatusBase,
)

from hummingbot.core.data_type.common import OrderType

class CloseType(CloseTypeBase):
    INSUFFICIENT_BALANCE_TAKER = 8
    TAKER = 9
    
class PositionConfig(PositionConfigBase):
    maker_perpetual_only_close: Optional[bool] = None
    taker_exchange: str
    taker_pair: str
    taker_profitability: Optional[Decimal] = None
    taker_order_type: OrderType = OrderType.MARKET
    taker_perpetual_only_close: Optional[bool] = None

class PositionExecutorStatus(PositionExecutorStatusBase):
    ACTIVE_TAKER = 5 #not use yet
    