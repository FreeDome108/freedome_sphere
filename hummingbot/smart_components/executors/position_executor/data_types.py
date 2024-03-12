from enum import Enum
from typing import Optional

from hummingbot.smart_components.executors.position_executor.data_types_base import (
    CloseType as CloseTypeBase,
    PositionExecutorConfig as PositionExecutorConfigBase,
    PositionExecutorStatus,
    TrailingStop,
    TripleBarrierConf
)
from pydantic import BaseModel
from pydantic.types import Decimal

from hummingbot.core.data_type.common import OrderType, TradeType
from hummingbot.smart_components.executors.data_types import ExecutorConfigBase


    
class PositionExecutorConfig(PositionExecutorConfigBase):
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