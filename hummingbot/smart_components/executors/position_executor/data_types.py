from hummingbot.smart_components.executors.position_executor.base_data_types import (
    CloseType as BaseCloseType,
    PositionConfig as BasePositionConfig,
    PositionExecutorStatus as BasePositionExecutorStatus,
)

from hummingbot.core.data_type.common import OrderType

class CloseType(PositionCloseType):
    INSUFFICIENT_BALANCE_TAKER = 8
    TAKER = 9
    
class PositionConfig(BasePositionConfig):
    maker_perpetual_only_close: Optional[bool] = None
    taker_exchange: str
    taker_pair: str
    taker_profitability: Optional[Decimal] = None
    taker_order_type: OrderType = OrderType.MARKET
    taker_perpetual_only_close: Optional[bool] = None

class PositionExecutorStatus(BasePositionExecutorStatus):
    ACTIVE_TAKER = 5 #not use yet