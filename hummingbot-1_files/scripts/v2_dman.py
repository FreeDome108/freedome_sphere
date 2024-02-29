from decimal import Decimal
from typing import Dict

from hummingbot.connector.connector_base import ConnectorBase
from hummingbot.core.data_type.common import OrderType, PositionAction, PositionSide, TradeType
from hummingbot.data_feed.candles_feed.candles_factory import CandlesConfig
from hummingbot.smart_components.controllers.dman import DMan, DManConfig
from hummingbot.smart_components.strategy_frameworks.data_types import ExecutorHandlerStatus, TripleBarrierConf
from hummingbot.smart_components.strategy_frameworks.advanced.advanced_executor_handler import (
    AdvancedExecutorHandler,
)
from hummingbot.smart_components.utils.distributions import Distributions
from hummingbot.smart_components.utils.order_level_builder import OrderLevelBuilder
from hummingbot.strategy.script_strategy_base import ScriptStrategyBase

from hummingbot.core.event.events import MarketEvent, OrderFilledEvent
from hummingbot.core.event.event_listener import EventListener


class DManMultiplePairs(ScriptStrategyBase):
    # Account configuration
    
    # Develop config
    exchange = "okx"
    trading_pairs = ["XRP-USDT"]
    trading_pair1 = "XRP-USDT"
    candles_exchange = "binance_perpetual"

    # Production config
    '''
    exchange = "whitebit"
    trading_pairs = ["XMR-USDT"]
    trading_pair1 = "XMR-USDT"
    candles_exchange = "binance_perpetual"
    '''
    

 
    # Orders configuration
    order_amount = Decimal("10")
    n_levels = 3
    leverage = 1

    #candles
    candles_interval = "1m"
    candles_max_records = 300


    
    '''   
    #Develop TO Fast order 
    start_spread = 0.0006
    step_between_orders = 0.009
    '''
    #Production profit
    start_spread = 4
    step_between_orders = 6
    '''
    taker_profitability_min = 0.5 # При ниже - если лимитник не открыт - перепроставляется
    taker_profitability_targer = 0.6 # - Минимальный начальный уровень естанавливается через start spread, может быть разным
    Внутри spread
    '''


    #Test
    order_refresh_time = 10 
    #Original
    #order_refresh_time = 60 * 15  # 15 minutes
    
    cooldown_time = 5

    # Triple barrier configuration
    #stop_loss = Decimal("0.2")
    # Disabled
    stop_loss = 0
    # Without arbitrage
    
    # Test profit, don't left or minus all finanecs because of fees?
    # take_profit = Decimal("0.003")
    # Standart
    take_profit = Decimal("0.06")
    time_limit = 60 * 60 * 12
    trailing_stop_activation_price_delta = Decimal(str(step_between_orders / 2))
    trailing_stop_trailing_delta = Decimal(str(step_between_orders / 3))

    '''
    #Original    
    stop_loss = Decimal("0.2")
    take_profit = Decimal("0.06")
    time_limit = 60 * 60 * 12
    trailing_stop_activation_price_delta = Decimal(str(step_between_orders / 2))
    trailing_stop_trailing_delta = Decimal(str(step_between_orders / 3))
    '''

    # Advanced configurations
    natr_length = 100
    
    '''
    # Production config
    # Account configuration
    exchange = "whitebit"
    trading_pairs = ["XMR-USDT"]
    trading_pair1 = "XMR-USDT"
    leverage = 1

    # Candles configuration
    candles_exchange = "binance_perpetual"
    candles_interval = "1m"
    candles_max_records = 300

    # Orders configuration
    order_amount = Decimal("10")
    n_levels = 3
    start_spread = 0.0006
    step_between_orders = 0.009
    order_refresh_time = 60 # 1min # 60 * 15  # 15 minutes
    cooldown_time = 5

    # Triple barrier configuration
    stop_loss = Decimal("0.2")
    take_profit = Decimal("0.06")
    time_limit = 60 * 60 * 12
    trailing_stop_activation_price_delta = Decimal(str(step_between_orders / 2))
    trailing_stop_trailing_delta = Decimal(str(step_between_orders / 3))

    # Advanced configurations
    natr_length = 100
    '''    

    # Applying the configuration
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
    controllers = {}
    markets = {}
    executor_handlers = {}

    for trading_pair in trading_pairs:
        config = DManConfig(
            exchange=exchange,
            trading_pair=trading_pair,
            order_levels=order_levels,
            candles_config=[
                CandlesConfig(connector=candles_exchange, trading_pair=trading_pair,
                              interval=candles_interval, max_records=candles_max_records),
            ],
            leverage=leverage,
            natr_length=natr_length,
            # Advanced
            maker_perpetual_only_close = False,
            taker_exchange = candles_exchange,
            taker_pair = trading_pair,
            taker_profitability = 0.6, #taker_profitability_targer = 0.6
            taker_profitability_min = 0.5
        )
        controller = DMan(config=config)
        markets = controller.update_strategy_markets_dict(markets)
        markets[candles_exchange]={trading_pair}

        controllers[trading_pair] = controller

    def __init__(self, connectors: Dict[str, ConnectorBase]):
        super().__init__(connectors)
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

    '''        
    def execute_taker_trade(self, trade_type, amount):
        # Выполнение торговой операции на taker рынке
        # [TODO] fix self.trading_pair1
        order_type = OrderType.MARKET
        if trade_type == TradeType.BUY:
            self.connectors[self.candles_exchange]
            self.buy(self.candles_exchange, self.trading_pair1, amount, order_type)
        else:
            self.sell(self.candles_exchange, self.trading_pair1, amount, order_type)
    '''

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
