from decimal import Decimal
from typing import Dict

from hummingbot.connector.connector_base import ConnectorBase
from hummingbot.core.data_type.common import OrderType, PositionAction, PositionSide, TradeType
from hummingbot.data_feed.candles_feed.candles_factory import CandlesConfig
from hummingbot.smart_components.controllers.dman_controller import DManController, DManConfig
from hummingbot.scripts.dman_strategy import DManStrategyConfig
#from hummingbot.smart_components.strategy_frameworks.advanced.taker_controller import TakerController


from hummingbot.smart_components.strategy_frameworks.data_types import ExecutorHandlerStatus, TripleBarrierConf
from hummingbot.smart_components.strategy_frameworks.advanced.advanced_executor_handler import (
    AdvancedExecutorHandler,
)

from hummingbot.smart_components.strategy_frameworks.advanced.advanced_market_controller import AdvancedMarketController


from hummingbot.smart_components.utils.distributions import Distributions
from hummingbot.smart_components.utils.order_level_builder import OrderLevelBuilder
from hummingbot.strategy.script_strategy_base import ScriptStrategyBase

from hummingbot.core.event.events import MarketEvent, OrderFilledEvent
from hummingbot.core.event.event_listener import EventListener





# Стратегия торгует над одним и тем же инструментом, названия торговых пар у разных exchanges нужны в случае отличий внутренних наименований
class DManStrategy(ScriptStrategyBase):
    # config_type="prod"
    
    # Dev config
    config_type="test_perp"

    def __init__(self, connectors: Dict[str, ConnectorBase],config: DManV1ScriptConfig):
        super().__init__(connectors)        
        self.config = config[config_type]

        # For maker
        order_level_builder = OrderLevelBuilder(n_levels=n_levels)
        order_levels = order_level_builder.build_order_levels(
            amounts=order_amount,
            spreads=Distributions.arithmetic(n_levels=n_levels, start=start_spread, step=step_between_orders),
            triple_barrier_confs=TripleBarrierConf(
                stop_loss=stop_loss, take_profit=take_profit, time_limit=time_limit,
                trailing_stop_activation_price_delta=trailing_stop_activation_price_delta,
                trailing_stop_trailing_delta=trailing_stop_trailing_delta),
            order_refresh_time=order_refresh_time,
            cooldown_time=cooldown_time,
        )

        # For taker are dynamical
        self.controllers = {}
        self.markets = {}
        self.executor_handlers = {}

        #takersController=TakersController(config=taker_markets_config)
        #markets = controller.update_strategy_markets_dict(markets)
        #This is wrong, because no add:
        #for conf in taker_markets_config:
        #    markets[conf["exchange"]]={conf["trading_pair"]}
        #controllers['TAKERS'] = TakersController(config=taker_markets_config)


        
        config = DManConfig(
            config=self.config,
            trading_pair=conf["trading_pair"],
            order_levels=order_levels,
            candles_config=[
                CandlesConfig(connector=candles_exchange, trading_pair=candles_pair,
                            interval=candles_interval, max_records=candles_max_records),
            ],
            leverage=conf.get("leverage", 1),
            natr_length=natr_length,
            # Advanced
            maker_perpetual_only_close = False,
            taker_exchange = candles_exchange,
            taker_pair = candles_pair,
            taker_profitability = 0.6, #taker_profitability_targer = 0.6
            taker_profitability_min = 0.5
        )
        controller = DManController(config=config)

        
        markets = controller.update_strategy_markets_dict(markets)
        controllers[conf["trading_pair"]] = controller

    
        self.markets_controller = AdvancedMarketController(strategy=self,connectors);

        for trading_pair, controller in self.controllers.items():
            self.executor_handlers[trading_pair] = AdvancedExecutorHandler(strategy=self, controller=controller)
        
        # self.add_listener(MarketEvent.OrderFilled, self.on_order_filled)

    #def on_order_filled(self, event: OrderFilledEvent):
    def did_fill_order(self, event: OrderFilledEvent):    
        self.logger().info(f"Order {event.order_id} filled, {event.trade_type}, {event.amount} @ {event.price}")
        
        # [TODO] Если ордер не создан именно этим ботом, то игнорировать
        # if event.exchange == self.maker_exchange and event.trading_pair == self.maker_pair:

        # Исполняем арбитражную позицию на taker рынке
        # taker_action = TradeType.SELL if event.trade_type == TradeType.BUY else TradeType.BUY
        # self.execute_taker_trade(taker_action, event.amount)



    @property
    def is_perpetual(self):
        """
        Checks if the exchange is a perpetual market.
        """
        return "perpetual" in self.exchange

    def on_stop(self):
        if self.is_perpetual:
            self.close_open_positions()
        for executor_handler in self.executor_handlers.values():
            executor_handler.stop()

    def close_open_positions(self):
        # we are going to close all the open positions when the bot stops
        for connector_name, connector in self.connectors.items():
            for trading_pair, position in connector.account_positions.items():
                if trading_pair in self.markets[connector_name]:
                    if position.position_side == PositionSide.LONG:
                        self.sell(connector_name=connector_name,
                                  trading_pair=position.trading_pair,
                                  amount=abs(position.amount),
                                  order_type=OrderType.MARKET,
                                  price=connector.get_mid_price(position.trading_pair),
                                  position_action=PositionAction.CLOSE)
                    elif position.position_side == PositionSide.SHORT:
                        self.buy(connector_name=connector_name,
                                 trading_pair=position.trading_pair,
                                 amount=abs(position.amount),
                                 order_type=OrderType.MARKET,
                                 price=connector.get_mid_price(position.trading_pair),
                                 position_action=PositionAction.CLOSE)

    def on_tick(self):
        """
        This shows you how you can start meta controllers. You can run more than one at the same time and based on the
        market conditions, you can orchestrate from this script when to stop or start them.
        """
        for executor_handler in self.executor_handlers.values():
            if executor_handler.status == ExecutorHandlerStatus.NOT_STARTED:
                executor_handler.start()

    def format_status(self) -> str:
        if not self.ready_to_trade:
            return "Market connectors are not ready."
        lines = []
        for trading_pair, executor_handler in self.executor_handlers.items():
            lines.extend(
                [f"Strategy: {executor_handler.controller.config.strategy_name} | Trading Pair: {trading_pair}",
                 executor_handler.to_format_status()])
        return "\n".join(lines)
