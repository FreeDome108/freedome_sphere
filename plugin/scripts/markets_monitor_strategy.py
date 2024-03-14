import os
from decimal import Decimal
from typing import Dict

from pydantic import Field

from hummingbot.client.config.config_data_types import BaseClientModel, ClientFieldData
from hummingbot.connector.connector_base import ConnectorBase
from hummingbot.core.data_type.common import OrderType, PositionAction, PositionSide
from hummingbot.data_feed.candles_feed.candles_factory import CandlesConfig
from hummingbot.smart_components.controllers.dman_controller import DManController, DManConfig
from hummingbot.smart_components.executors.position_executor.data_types import TrailingStop, TripleBarrierConf
from hummingbot.smart_components.models.base import SmartComponentStatus
from hummingbot.smart_components.order_level_distributions.distributions import Distributions
from hummingbot.smart_components.order_level_distributions.order_level_builder import OrderLevelBuilder
from hummingbot.smart_components.strategy_frameworks.advanced.advanced_executor_handler import (
    AdvancedExecutorHandler,
)
from hummingbot.smart_components.strategy_frameworks.advanced.markets_monitor import MarketsMonitor
from hummingbot.strategy.script_strategy_base import ScriptStrategyBase

#from scripts.markets_monitor_strategy_config import MarketsMonitorStrategyConfig

class MarketsMonitorStrategy(ScriptStrategyBase):
    exchange="binance_perpetual"
    trading_pair="XRP-USDT"
    
    markets={exchange:[trading_pair]}

    #@classmethod
    #def init_markets(cls, config: MarketsMonitorStrategyConfig):
    #    cls.markets = {config.exchange: set(config.trading_pairs.split(","))}

    # def __init__(self, connectors: Dict[str, ConnectorBase],config: MarketsMonitorStrategyConfig):
    def __init__(self, connectors: Dict[str, ConnectorBase]):
        super().__init__(connectors)        

        self.controllers = {}
        #self.executor_handlers = {}
    
        self.markets_monitor = MarketsMonitor(strategy=self,connectors=connectors);
        
        self.executor_handlers = {"markets_monitor":self.markets_monitor}

    def on_stop(self):
        pass


    def on_tick(self):
        """
        This shows you how you can start meta controllers. You can run more than one at the same time and based on the
        market conditions, you can orchestrate from this script when to stop or start them.
        """
        for executor_handler in self.executor_handlers.values():
            if executor_handler.status == SmartComponentStatus.NOT_STARTED:
                executor_handler.start()
            else:
                takers_price=executor_handler.get_taker_prices();
                self.logger().warning(f"takers_price={takers_price}")

    def format_status(self) -> str:
        if not self.ready_to_trade:
            return "Market connectors are not ready."
        lines = []
        #for trading_pair, executor_handler in self.executor_handlers.items():
        #    lines.extend(
        #        [f"Strategy: {executor_handler.controller.config.strategy_name} | Trading Pair: {trading_pair}",
        #         executor_handler.to_format_status()])
        return "\n".join(lines)
