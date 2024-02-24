from hummingbot.smart_components.executors.position_executor.base_data_types import (
    CloseType As OriginalCloseType,
    PositionConfig as OriginalPositionConfig,
    PositionExecutorStatus as OriginalPositionExecutorStatus,
)

class CloseType(PositionCloseType):
    INSUFFICIENT_BALANCE_TAKER = 8
    TAKER = 9
    
class PositionConfig(OriginalPositionConfig):
    taker_exchange: str
    taker_pair: str
    taker_order_type OrderType = OrderType.MARKET

class PositionExecutorStatus(OriginalPositionExecutorStatus):
    ACTIVE_TAKER = 5
