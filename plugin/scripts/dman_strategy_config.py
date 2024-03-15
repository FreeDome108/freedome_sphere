from decimal import Decimal
from hummingbot.client.config.config_data_types import BaseClientModel, ClientFieldData
#from scripts.dman_strategy import DManStrategy

class DManStrategyConfig(BaseClientModel):
    config_types = {
        "dev":"dev1",
        "prod":"prod1"
    }

    # параметры можно указать в maker_defaults и taker_defaults, и если нужно можно их прописать к конкретной бирже
    # perpetual_exclude_open  - только снимать позиции
    # weights рекурсивно умножаются, другие параметры берутся рекурсивно самый глубокий
    # total_limit
    # В фьючерсную пружинку помещаем общее количество маркетов при одинаковых вложениях как на других ранках. Поскольку там плечо, то есть риски при больших движениях цены (например при плече 5 - риск при движениях более 20%, поэтому стараемся оттуда выйти как можно быстрее)

    #На перпетуальном мейкере есть смысл если позиций открыто больше,чем order_amount - выставлять БОЛЬШЕ (по крайней мере, что сможем удовлетворить)

    
    defaults_dev = {
        "trading_pair": "XRP-USDT",
        
        "order_amount": Decimal("10"), # Позже можно массивом уровни и спреды
        "amount_ratio_increase": 1.5,
        
        "n_levels": 3,
        "leverage": 1,

        "profitability_min": 0.5, # вместо stoploss, есть механизм что если профильность ордера уменьшилась ниже минимума, то его нужно снять
        #profitability_target: 0.6 # такого понятия не существует, т.к ордера выставились


        "top_order_start_spread": 0.0002,
        "start_spread": 0.002,
        "spread_ratio_increase": 2.0,


        "top_order_refresh_time": 15,
        "order_refresh_time": 60,
        "cooldown_time": 5,
    }

    defaults_prod = {
        "trading_pair": "XMR-USDT",
        
        "order_amount": Decimal("10"), # Позже можно массивом уровни и спреды
        "amount_ratio_increase": 1.5,
        
        "n_levels": 3,
        "leverage": 1,

        "profitability_min": 0.5, # вместо stoploss, есть механизм что если профильность ордера уменьшилась ниже минимума, то его нужно снять
        #profitability_target: 0.6 # такого понятия не существует, т.к ордера выставились

        "top_order_start_spread": 0.0002,
        "start_spread": 0.02,
        "spread_ratio_increase": 2.0,

        "top_order_refresh_time": 15, #!!!
        "order_refresh_time": 30, #!!!
        "cooldown_time": 5,
    }

    markets_configs = {
        "dev1":
        {
            "makers":
            [
                {
                    "exchange": "whitebit",
                },
            ],
            "takers":
            [
                {
                    "exchange": "binance_perpetual",
                },       
            ],
            "maker_defaults":
            {
                "order_amount": Decimal("10")
            },
            "taker_defaults":
            {
                "trading_pair": "XRP-USDT",
            },
            "defaults": defaults_dev
        },
        "prod1":
        {
            "makers":
            [
                {
                    "exchange": "whitebit",
                },
            ],
            "takers":
            [
                {
                    "exchange": "binance_perpetual",
                },       
            ],
            "maker_defaults":
            {
                "order_amount": Decimal("10")
            },
            "taker_defaults":
            {
                "trading_pair": "XRP-USDT",
            },
            "defaults": defaults_prod
        },        
        "prodN":
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
                    "spread_discount": 0.99, #!!!!

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
                    "comment": "фьючерсы<=>спот 1:1",
                    "perpetual_exclude_open": True,
                    # нужен для простого арбитража 1:1 фьючерсов к споту, поскольку возможны арбитражные варианты
                },
                {
                    "exchange": "binance_perpetual",
                    "spread_extra": 0.05, # 5% - именно движение, 10% - уже что-то серьезное, важно учесть что при 20% изменения цены - уже margin call!
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
                    "spread_extra": 0.05,
                    # в том числе, когда закрыться негде, закрываемся тут и потом откупимся или что-то в этом роде, продумать позже.
                    # или вынести это на объемную перпетуалку, а мелкие разницы - смотреть 1:1
                },
                {
                    "exchange": "dydx_perpetual",
                },
                {
                    "exchange": "binance_perpetual",
                    "leverage": 5,
                    "spread_discount": 0.99, # !!!!
                    "perpetual_exclude_open": True,
                },
            ],
            "maker_defaults":
            {
                "order_amount": Decimal("30"), # Лучше чтобы было больше чем на taker рынке минимум чем в количество рынков, на которое будет раскидано
            },
            "taker_defaults":
            {
                "trading_pair": "XRP-USDT",
            },
            "defaults":defaults_prod
        }
    }

