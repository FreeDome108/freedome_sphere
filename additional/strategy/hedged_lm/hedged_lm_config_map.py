from decimal import Decimal
from typing import Optional
from hummingbot.client.config.config_var import ConfigVar
from hummingbot.client.config.config_validators import (
    validate_market_trading_pair,
    validate_exchange,
    validate_decimal,
    validate_derivative,
    validate_int,
    validate_bool
)
from hummingbot.client.settings import (
    required_exchanges,
    requried_connector_trading_pairs,
    EXAMPLE_PAIRS
)


def exchange_on_validated(value: str) -> None:
    required_exchanges.append(value)


def token_validate(value: str) -> Optional[str]:
    value = value.upper()
    markets = list(hedged_lm_config_map["markets"].value.split(","))
    tokens = set()
    for market in markets:
        tokens.update(set(market.split("-")))
    if value not in tokens:
        return f"Invalid token. {value} is not one of {','.join(tokens)}"

def order_size_prompt() -> str:
    token = hedged_lm_config_map["token"].value
    return f"What is the size of each order (in {token} amount)? >>> "

def derivative_market_validator(value: str) -> None:
    mkts = ','.split(value)
    for m in mkts:
        exchange = hedged_lm_config_map["derivative_connector"].value
        r = validate_market_trading_pair(exchange, m)
        if r:            
            return r

def derivative_market_on_validated(value: str) -> None:
    mkts = ','.split(value)
    requried_connector_trading_pairs[hedged_lm_config_map["derivative_connector"].value] = mkts

def derivative_market_prompt() -> str:
    connector = hedged_lm_config_map.get("derivative_connector").value
    example = EXAMPLE_PAIRS.get(connector)
    return "Enter the token trading pair you would like to trade on %s%s >>> " \
           % (connector, f" (e.g. {example})" if example else "")

hedged_lm_config_map = {
    "strategy": ConfigVar(
        key="strategy",
        prompt="",
        default="hedged_lm"),
    "exchange":
        ConfigVar(key="exchange",
                  prompt="Enter the spot connector to use for liquidity mining >>> ",
                  validator=validate_exchange,
                  on_validated=exchange_on_validated,
                  prompt_on_new=True),
    "markets":
        ConfigVar(key="markets",
                  prompt="Enter a list of markets (comma separated, e.g. LTC-USDT,ETH-USDT) >>> ",
                  type_str="str",
                  prompt_on_new=True,
                  validator=derivative_market_validator,
                  on_validated=derivative_market_on_validated),
    "token":
        ConfigVar(key="token",
                  prompt="What asset (base or quote) do you want to use to provide liquidity? (you have most balance of) >>> ",
                  type_str="str",
                  validator=token_validate,
                  prompt_on_new=True),
    "order_amount":
        ConfigVar(key="order_amount",
                  prompt=order_size_prompt,
                  type_str="decimal",
                  validator=lambda v: validate_decimal(v, 0, inclusive=False),
                  prompt_on_new=True),
    "spread":
        ConfigVar(key="spread",
                  prompt="How far away from the mid price do you want to place bid and ask orders? "
                         "(Enter 1 to indicate 1%) >>> ",
                  type_str="decimal",
                  validator=lambda v: validate_decimal(v, 0, 100, inclusive=False),
                  prompt_on_new=True),
    "inventory_skew_enabled":
        ConfigVar(key="inventory_skew_enabled",
                  prompt="Would you like to enable inventory skew? (Yes/No) >>> ",
                  type_str="bool",
                  default=True,
                  validator=validate_bool),
    "target_base_pct":
        ConfigVar(key="target_base_pct",
                  prompt="For each pair, what is your target base asset percentage? (Enter 20 to indicate 20%) >>> ",
                  type_str="decimal",
                  validator=lambda v: validate_decimal(v, 0, 100, inclusive=False),
                  prompt_on_new=True),
    "order_refresh_time":
        ConfigVar(key="order_refresh_time",
                  prompt="How often do you want to cancel and replace bids and asks "
                         "(in seconds)? >>> ",
                  type_str="float",
                  validator=lambda v: validate_decimal(v, 0, inclusive=False),
                  default=10.),
    "order_refresh_tolerance_pct":
        ConfigVar(key="order_refresh_tolerance_pct",
                  prompt="Enter the percent change in price needed to refresh orders at each cycle "
                         "(Enter 1 to indicate 1%) >>> ",
                  type_str="decimal",
                  default=Decimal("0.2"),
                  validator=lambda v: validate_decimal(v, -10, 10, inclusive=True)),
    "inventory_range_multiplier":
        ConfigVar(key="inventory_range_multiplier",
                  prompt="What is your tolerable range of inventory around the target, "
                         "expressed in multiples of your total order size? ",
                  type_str="decimal",
                  validator=lambda v: validate_decimal(v, min_value=0, inclusive=False),
                  default=Decimal("1")),
    "volatility_interval":
        ConfigVar(key="volatility_interval",
                  prompt="What is an interval, in second, in which to pick historical mid price data from to calculate "
                         "market volatility? >>> ",
                  type_str="int",
                  validator=lambda v: validate_int(v, min_value=1, inclusive=False),
                  default=60 * 5),
    "avg_volatility_period":
        ConfigVar(key="avg_volatility_period",
                  prompt="How many interval does it take to calculate average market volatility? >>> ",
                  type_str="int",
                  validator=lambda v: validate_int(v, min_value=1, inclusive=False),
                  default=10),
    "volatility_to_spread_multiplier":
        ConfigVar(key="volatility_to_spread_multiplier",
                  prompt="Enter a multiplier used to convert average volatility to spread "
                         "(enter 1 for 1 to 1 conversion) >>> ",
                  type_str="decimal",
                  validator=lambda v: validate_decimal(v, min_value=0, inclusive=False),
                  default=Decimal("1")),
    "max_spread":
        ConfigVar(key="max_spread",
                  prompt="What is the maximum spread? (Enter 1 to indicate 1% or -1 to ignore this setting) >>> ",
                  type_str="decimal",
                  validator=lambda v: validate_decimal(v),
                  default=Decimal("-1")),
    "max_order_age":
        ConfigVar(key="max_order_age",
                  prompt="What is the maximum life time of your orders (in seconds)? >>> ",
                  type_str="float",
                  validator=lambda v: validate_decimal(v, min_value=0, inclusive=False),
                  default=60. * 60.),
    "derivative_connector": ConfigVar(
        key="derivative_connector",
        prompt="Enter a derivative name (Exchange/AMM) >>> ",
        prompt_on_new=True,
        validator=validate_derivative,
        on_validated=exchange_on_validated),
    # "derivative_market": ConfigVar(
    #     key="derivative_market",
    #     prompt=derivative_market_prompt,
    #     prompt_on_new=True,
    #     validator=derivative_market_validator,
    #     on_validated=derivative_market_on_validated),
    "derivative_leverage": ConfigVar(
        key="derivative_leverage",
        prompt="How much leverage would you like to use on the derivative exchange? (Enter 1 to indicate 1X) ",
        type_str="int",
        default=1,
        validator= lambda v: validate_int(v),
        prompt_on_new=True),
}
