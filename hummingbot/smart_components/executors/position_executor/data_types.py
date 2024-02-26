from enum import Enum
from typing import Optional

from hummingbot.smart_components.executors.position_executor.data_types_base import (
    CloseType as CloseTypeBase,
    PositionConfig as PositionConfigBase,
    PositionExecutorStatus,
    TrailingStop,
    TrackedOrder
)
from pydantic import BaseModel
from pydantic.types import Decimal

from hummingbot.core.data_type.common import OrderType, TradeType
from hummingbot.core.data_type.in_flight_order import InFlightOrder


class CloseType(Enum):
    TIME_LIMIT = 1
    STOP_LOSS = 2
    TAKE_PROFIT = 3
    EXPIRED = 4
    EARLY_STOP = 5
    TRAILING_STOP = 6
    INSUFFICIENT_BALANCE = 7
    # Additional
    INSUFFICIENT_BALANCE_TAKER = 8
    TAKER = 9
    
class PositionConfig(PositionConfigBase):
    maker_perpetual_only_close: Optional[bool] = None
    taker_exchange: str
    taker_pair: str
    taker_profitability: Optional[Decimal] = None
    taker_order_type: OrderType = OrderType.MARKET
    taker_perpetual_only_close: Optional[bool] = None

'''
# Not use yet
class PositionExecutorStatus(PositionExecutorStatusBase):
    ACTIVE_TAKER = 5 
'''