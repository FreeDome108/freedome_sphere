from enum import Enum
from typing import Optional

from _decimal import Decimal

from hummingbot.smart_components.models.executors_base import TrackedOrder

class CloseType(Enum):
    TIME_LIMIT = 1
    STOP_LOSS = 2
    TAKE_PROFIT = 3
    EXPIRED = 4
    EARLY_STOP = 5
    TRAILING_STOP = 6
    INSUFFICIENT_BALANCE = 7
    FAILED = 8
    # Additional
    INSUFFICIENT_BALANCE_TAKER = 101
    TAKER = 102