
from decimal import Decimal

from pydantic import Field

from hummingbot.client.config.config_data_types import ClientFieldData
from hummingbot.client.config.strategy_config_data_types import BaseTradingStrategyMakerTakerConfigMap


class CrossExchangeMarketMakingSpotPerpClobAmmConfigMap(BaseTradingStrategyMakerTakerConfigMap):
    strategy: str = Field(default="xemm", client_data=None)

    maker_market: str = Field(
        default=...,
        description="The exchange name for the maker market.",
        client_data=ClientFieldData(
            prompt="Enter the exchange name for the maker market.",
            prompt_on_new=True,
        ),
    )

    taker_market: str = Field(
        default=...,
        description="The exchange name for the taker market.",
        client_data=ClientFieldData(
            prompt="Enter the exchange name for the taker market.",
            prompt_on_new=True,
        ),
    )

    maker_pair: str = Field(
        default=...,
        description="The trading pair for the maker market.",
        client_data=ClientFieldData(
            prompt="Enter the trading pair for the maker market (e.g., BTC-USDT).",
            prompt_on_new=True,
        ),
    )

    taker_pair: str = Field(
        default=...,
        description="The trading pair for the taker market.",
        client_data=ClientFieldData(
            prompt="Enter the trading pair for the taker market (e.g., BTC-USDT).",
            prompt_on_new=True,
        ),
    )

    order_amount: Decimal = Field(
        default=Decimal("10"),
        description="The amount of the order to place.",
        ge=Decimal('0'),
        client_data=ClientFieldData(
            prompt="Enter the amount of the order to place.",
            prompt_on_new=True,
        ),
    )

    profit_target: Decimal = Field(
        default=Decimal("0.6"),
        description="The target profitability for open limit order on maker market in percentage.",
        ge=Decimal('-100'),
        le=Decimal('100'),
        client_data=ClientFieldData(
            prompt="What is the target profitability for open limit order on maker market? (Enter 0.6 to indicate 0.6%)",
            prompt_on_new=True,
        ),
    )

    profit_min: Decimal = Field(
        default=Decimal("0.5"),
        description="The minimum profitability for open limit order on maker market in percentage.",
        ge=Decimal('-100'),
        le=Decimal('100'),
        client_data=ClientFieldData(
            prompt="What is the minimum profitability for open limit order on maker market? (Enter 0.5 to indicate 0.5%)",
            prompt_on_new=True,
        ),
    )

    profit_max: Decimal = Field(
        default=Decimal("0.7"),
        description="The maximum profitability for open limit order on maker market in percentage.",
        ge=Decimal('-100'),
        le=Decimal('100'),
        client_data=ClientFieldData(
            prompt="What is the maximum profitability for open limit order on maker market? (Enter 0.7 to indicate 0.7%)",
            prompt_on_new=True,
        ),
    )