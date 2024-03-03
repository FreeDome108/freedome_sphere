import os
from decimal import Decimal
from typing import Dict
from pydantic import Field


from hummingbot.connector.connector_base import ConnectorBase
from hummingbot.core.data_type.common import OrderType, PositionAction, PositionSide
from hummingbot.strategy.script_strategy_base import ScriptStrategyBase

from hummingbot.scripts.dman_strategy import Dma


class DManStrategyConfig(BaseClientModel):
    script_file_name: str = Field(default_factory=lambda: os.path.basename(__file__))


    # параметры можно указать в maker_defaults и taker_defaults, и если нужно можно их прописать к конкретной бирже
    # perpetual_exclude_open  - только снимать позиции
    # weights рекурсивно умножаются, другие параметры берутся рекурсивно самый глубокий
    # total_limit
    # В фьючерсную пружинку помещаем общее количество маркетов при одинаковых вложениях как на других ранках. Поскольку там плечо, то есть риски при больших движениях цены (например при плече 5 - риск при движениях более 20%, поэтому стараемся оттуда выйти как можно быстрее)

    #На перпетуальном мейкере есть смысл если позиций открыто больше,чем order_amount - выставлять БОЛЬШЕ (по крайней мере, что сможем удовлетворить)

    markets_config = {
        "prod":
        {
            "makers":
            [
                {
                    "exchange": "whitebit",
                    "weight": 2
                },
                {
                    "exchange": "okx",
                },
                {
                    "exchange": "whitebit",
                    "trading_pair": "XRP-PERP",
                    "weight": 6,
                    "leverage": 5,
                    "perpetual_exclude_open": True,
                    "spread_discount": 0.99, !!!!

                    # обратная ситуация с гипотезой про движение лидера.
                    # фьючерсы небольшого рынка могут тоже обладать арбитражными возможностями
                    # позже проверить гипотезы 
                    # 1. 1:1 возможности мэйкера
                    # 2. 1:1 возможности тэйкера
                    # 3. 1,2 + 1:1 режим perpetual_exclude_open
                    # возможности могут быть отдельно
                },
                {
                    "exchange": "dydx_perpetual",
                    "leverage": 1,
                    "comment": "фьючерсы<=>спот 1:1"
                    "perpetual_exclude_open": True,
                    # нужен для простого арбитража 1:1 фьючерсов к споту, поскольку возможны арбитражные варианты
                },
                {
                    "exchange": "binance_perpetual",
                    "spread_extra"= 0.05, # 5% - именно движение, 10% - уже что-то серьезное, важно учесть что при 20% изменения цены - уже margin call!
                    "weight": 6, # по количеству суммы весов рынков (чтобы было сбалансированно)
                    "leverage": 5, # поскольку пружинка
                    "comment": "фьючерсная пружинка"
                    # сработает если рынок пришел в большое движение, остальным рынкам нужно перестраиваться под него
                },
                '''
                {
                    #еще один вариант возможен. 
                }
                '''
            ],
            "takers":
            [
                {
                    "exchange": "okx",
                    "weight": 2
                },
                {
                    "exchange": "whitebit",
                },
                            {
                    "exchange": "whitebit",
                    "trading_pair": "XRP-PERP",
                    "leverage": 5,
                    "spread_extra"= 0.05,
                    # в том числе, когда закрыться негде, закрываемся тут и потом откупимся или что-то в этом роде, продумать позже.
                    # или вынести это на объемную перпетуалку, а мелкие разницы - смотреть 1:1
                },
                {
                    "exchange": "dydx_perpetual",
                },
                {
                    "exchange": "binance_perpetual",
                    "leverage": 5,
                    "spread_discount": 0.99, !!!!
                    "perpetual_exclude_open": True,
                },
            ],
            "maker_defaults":
            {
                    "order_amount" = Decimal("30"), # Лучше чтобы было больше чем на taker рынке минимум чем в количество рынков, на которое будет раскидано
            },
            "taker_defaults":
            {
                    "trading_pair": "XRP-USDT",
            },
            "defaults":
            {
                    "trading_pair": "XRP-USDT",
                    "order_amount" = Decimal("10"),
                    "n_levels" = 3,
                    "leverage": 1
            },
        }
    }
    def get_config_param(self, config_market, config_exchange, config_param):
        #market = maker | taker
        
        if config_param="amount_weight":
            return self.config[config_market.get[]
        if markets_config



    config=markets_config[config_type]


Only close, spread discount, чтобы выйти с марджинального рынка максимально быстро
comment только для закрытия, уже учтен профит при открытии
Высокопрофильная пружинка сжмиается

> Oldmy:
Пружинка для растяжения обычных маркетов
Total limit 100
Spread extra spread multiplier = 10

Когда не хватает ликвидности на обычных рынках




    taker_markets_config = [
        {"exchange": "binance_perpetual",
         "trading_pair": "XRP-USDT",
         "leverage": 1},
    ]

    # Later add dydx_perp to develop multitaker


    '''
    # Prod config
    maker_markets_config = [
        {"exchange": "whitebit",
         "trading_pair": "XRP-USDT"},
        {"exchange": "okx",
         "trading_pair": "XRP-USDT"},
        {"exchange": "binance_perpetual",
         "trading_pair": "XRP-USDT",
         "leverage": 1},
        {"exchange": "dydx_perpetual",
         "trading_pair": "XRP-USDT",
         "leverage": 1},
    ]

    taker_markets_config = [
        {"exchange": "whitebit",
         "trading_pair": "XRP-USDT"},
        {"exchange": "okx",
         "trading_pair": "XRP-USDT"},
        {"exchange": "binance_perpetual",
         "trading_pair": "XRP-USDT",
         "leverage": 1},
        {"exchange": "dydx_perpetual",
         "trading_pair": "XRP-USDT",
         "leverage": 1},
    ]
    '''



    # Account configuration
    
    '''
    # Depreteated
    # Develop config
    exchange = "okx"
    trading_pairs = ["XRP-USDT"]
    trading_pair1 = "XRP-USDT"
    

    # Production confiп
    exchange = "whitebit"
    trading_pairs = ["XMR-USDT"]
    trading_pair1 = "XMR-USDT"
    
    '''
    

 
    # Orders configuration

    #temporary for compatibility, to be depreceated or additional to taker....
    #candles 
    candles_exchange = "binance_perpetual"
    candles_pair = "XRP-USDT"
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
