import time
from decimal import Decimal
from typing import List
from enum import Enum

import pandas_ta as ta 

from hummingbot.core.data_type.common import TradeType
from hummingbot.smart_components.executors.position_executor.data_types import PositionExecutorConfig, TrailingStop
from hummingbot.smart_components.executors.position_executor.position_executor import PositionExecutor
from hummingbot.smart_components.order_level_distributions.order_level_builder import OrderLevel
from hummingbot.smart_components.strategy_frameworks.advanced.advanced_controller_base import (
    AdvancedControllerBase,
    AdvancedControllerConfigBase,
)


from hummingbot.core.data_type.common import OrderType

# Отличие от оригинального контроллера -
# внутри обрабатываются несколько рынков (не один)
# внутри обрабатываются позиции maker(как в оригинале) + taker (добавлено)

# Если exchange и пара у taker и maker совпадает, то они обрабатываются по внутреннему правилу take_profit

class OrderPlacementStrategy(Enum):
    TAKER_BASED = 1 # Основано на цене закрытия позиции по маркет цене на рынке taker_echange c таргетом на спред price_multiplier (например 0.006 - означает 0.6%) и шагом спреда spread_multiplier (например 0.001 - означает 0.1%)
    NATR_BASED = 2
    BOLLINGER_BANDS_BASED = 3


class DManConfig(AdvancedControllerConfigBase):
    strategy_name: str = "dman"
    natr_length: int = 14
    order_placement_strategy: OrderPlacementStrategy = OrderPlacementStrategy.TAKER_BASED
    def get(self, param):
        return self.config["defaults"].get(param);
    def get_makers(self, param):
        return self.config["maker_defaults"].get(param,self.config["defaults"].get(param));
    def get_maker(self, param, maker):
        return self.config["makers"][maker].get(param,self.config["maker_defaults"].get(param,self.config["defaults"].get(param)));
    def get_takers(self, param):
        return self.config["taker_defaults"].get(param,self.config["defaults"].get(param));
    def get_taker(self, param, taker):
        return self.config["takers"][taker].get(param,self.config["taker_defaults"].get(param,self.config["defaults"].get(param)));


class DManController(AdvancedControllerBase):
    """
    Directional Market Making Strategy making use of NATR indicator to make spreads dynamic.
    """

    def __init__(self, config: DManConfig):
        super().__init__(config)
        self.config = config

    def refresh_order_condition(self, executor: PositionExecutor, order_level: OrderLevel) -> bool:
        """
        Checks if the order needs to be refreshed.
        You can reimplement this method to add more conditions.
        """
        if executor.position_config.timestamp + order_level.order_refresh_time > time.time():
            return False
        return True

    def early_stop_condition(self, executor: PositionExecutor, order_level: OrderLevel) -> bool:
        """
        If an executor has an active position, should we close it based on a condition.
        """
        return False

    def cooldown_condition(self, executor: PositionExecutor, order_level: OrderLevel) -> bool:
        """
        After finishing an order, the executor will be in cooldown for a certain amount of time.
        This prevents the executor from creating a new order immediately after finishing one and execute a lot
        of orders in a short period of time from the same side.
        """
        if executor.close_timestamp and executor.close_timestamp + order_level.cooldown_time > time.time():
            return True
        return False

    def get_processed_data(self):
        """
        Gets the price and spread multiplier from the last candlestick.
        """
        candles_df = self.candles[0].candles_df
        natr = ta.natr(candles_df["high"], candles_df["low"], candles_df["close"], length=self.config.natr_length) / 100

        candles_df["spread_multiplier"] = natr
        candles_df["price_multiplier"] = 0.0
        return candles_df

    def get_position_config(self, taker_prices, order_level: OrderLevel) -> PositionExecutorConfig:
        """
        Creates a PositionExecutorConfig object from an OrderLevel object.
        Here you can use technical indicators to determine the parameters of the position config.
        """
        
        if self.config.order_placement_strategy == OrderPlacementStrategy.TAKER_BASED:
            close_price = taker_prices[order_level.side][order_level.level]
            
            price_multiplier = 1.01 #self.config.price_multiplier
            spread_multiplier = 1.01 #self.config.spread_multiplier

        else:
            close_price = self.get_close_price(self.close_price_trading_pair)
            price_multiplier, spread_multiplier = self.get_price_and_spread_multiplier()



        price_adjusted = Decimal(float(close_price) * (1 + price_multiplier))
        side_multiplier = -1 if order_level.side == TradeType.BUY else 1
        order_price = Decimal(float(price_adjusted) * (1 + float(order_level.spread_factor) * float(spread_multiplier) * float(side_multiplier)))
        amount = order_level.order_amount_usd / order_price

        if order_level.triple_barrier_conf.trailing_stop_trailing_delta and order_level.triple_barrier_conf.trailing_stop_trailing_delta:
            trailing_stop = None
            #STRANGE, FIX because was somw bug, cannot resolve
            #trailing_stop = TrailingStop(
            #    activation_price=order_level.triple_barrier_conf.trailing_stop_activation_price,
            #    trailing_delta=order_level.triple_barrier_conf.trailing_stop_trailing_delta,
            #)
        else:
            trailing_stop = None
        position_config = PositionExecutorConfig(
            timestamp=time.time(),
            trading_pair=self.config.trading_pair,
            exchange=self.config.exchange,
            side=order_level.side,
            amount=amount,
            take_profit=order_level.triple_barrier_conf.take_profit,
            stop_loss=order_level.triple_barrier_conf.stop_loss,
            time_limit=order_level.triple_barrier_conf.time_limit,
            entry_price=Decimal(order_price),
            open_order_type=order_level.triple_barrier_conf.open_order_type,
            take_profit_order_type=order_level.triple_barrier_conf.take_profit_order_type,
            trailing_stop=trailing_stop,
            leverage=self.config.leverage,

            # Advanced
            maker_perpetual_only_close = False,
            taker_exchange = self.config.taker_exchange,
            taker_pair = self.config.taker_pair,
            #taker_order_type= self.config.taker_order_type
            taker_profitability = self.config.taker_profitability,
        )
        return position_config
