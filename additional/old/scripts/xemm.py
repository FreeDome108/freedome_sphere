import logging

import pandas as pd

from decimal import Decimal
from hummingbot.core.data_type.common import OrderType, TradeType
from hummingbot.core.data_type.order_candidate import OrderCandidate
from hummingbot.core.event.events import OrderFilledEvent
from hummingbot.strategy.script_strategy_base import ScriptStrategyBase

class CrossExchangeMarketMakingSpotPerpClobAmmStrategy(ScriptStrategyBase):
    """
    Арбитражная стратегия между двумя рынками: maker и taker.

    Описание алгоритма:
    1. Стратегия начинается с мониторинга цен на taker рынке для заданной торговой пары.
    2. На основе полученных данных, стратегия рассчитывает цены покупки и продажи на maker рынке,
       используя заданную целевую прибыльность (profit_set).
    3. Стратегия создает лимитные ордера на покупку и продажу на maker рынке с учетом рассчитанных цен
       и объема, который не превышает доступный объем на taker рынке.
    4. Стратегия постоянно мониторит изменения в прибыльности. Если прибыльность выходит за пределы
       заданных значений (profit_min и profit_max), ордера на maker рынке отменяются и процесс начинается заново.
    5. При полном или частичном исполнении ордера на maker рынке, стратегия немедленно исполняет соответствующую
       арбитражную позицию на taker рынке. Если ордер исполнен не полностью, оставшийся объем отменяется.

    Технические требования:
    - Тип поддерживаемых рынков maker: spot, perpetual
    - Тип поддерживаемых рынков taker: spot, perpetual
    - Тип поддерживаемых спосоов торговли рынков maker: clob, amm
    - Тип поддерживаемых спосоов торговли рынков taker: clob, amm
    - Fee, gas не учитываются
    - Лимитные ордера выставляется по одному в обоих направлениях: один на buy + один на sell
    - Учитывается баланс, если баланса или актива для потенциальной сделки на taker не хватает - на maker ордер не выставляется

    Параметры ввода:
    - maker_market: Имя рынка для создания лимитных ордеров 
    - taker_market: Имя рынка для исполнения арбитражных сделок
    - maker_pair: Торговая пара на maker рынке.
    - taker_pair: Торговая пара на taker рынке.
    - order_amount: Объем ордера.
    - profit_min, profit_set, profit_max: Минимальная, целевая и максимальная прибыльность для сделок в процентах. Например 0.5 - означает 0.5%
    """

    base = "XMR"
    quote = "USDT"

    maker_exchange = "whitebit"
    maker_pair = f"{base}-{quote}"
    taker_exchange = "binance_perpetual"
    taker_pair = f"{base}-{quote}"

    order_amount = 10 
    profit_min = 0.5
    profit_set = 0.6
    profit_max = 0.7

    markets = {maker_exchange: {maker_pair}, taker_exchange: {taker_pair}}

    #buy_order_placed = False
    #sell_order_placed = False

    # Подписываемся на событие исполнения ордера на maker_exchange
    # self.add_event_listener(MarketEvent.OrderFilled, self.did_fill_maker_order)
    # self.
    order_ids = {"BUY": None, "SELL": None}

    def on_tick(self):
        # Основная логика вызывается на каждом тике (обновлении данных)
        taker_buy_price, taker_sell_price = self.get_taker_prices()
        self.manage_orders(TradeType.BUY, taker_buy_price)
        self.manage_orders(TradeType.SELL, taker_sell_price)

    def get_taker_prices(self):
        # Получаем текущие цены на taker_exchange
        taker_buy_price = self.connectors[self.taker_exchange].get_price(self.taker_pair, True)
        taker_sell_price = self.connectors[self.taker_exchange].get_price(self.taker_pair, False)
        return taker_buy_price, taker_sell_price

    def manage_orders(self, trade_type, taker_price):
        # Идентифицируем текущий ордер для данного типа сделки
        current_order = self.get_current_order(trade_type)
        
        # 1. Если ордер отсутствует, то рассчитываем цену с учетом profit_set и ставим ордер
        if current_order is None:
            maker_price_set = self.calculate_order_price(trade_type, taker_price, self.profit_set)
            order_id = self.place_order(trade_type, maker_price_set)
            if order_id:
                self.order_ids[trade_type.name] = order_id 
            else:
                print("Ошибка при размещении лимитного ордера на maker_exchange")
            return

        # 2. Если объем текущего лимитного ордера на maker_exchange не равен order_amount, отменяем ордер
        if current_order.amount != self.order_amount:
            self.cancel_order(current_order)
            return

        # 3. Расчитываем диапазон цен с учетом profit_min и profit_max
        maker_price_min = self.calculate_order_price(trade_type, taker_price, self.profit_min)
        maker_price_max = self.calculate_order_price(trade_type, taker_price, self.profit_max)

        # 4. Если цена текущего лимитного ордера на maker_exchange не попадает в диапазон min;max, отменяем ордер
        if not maker_price_min <= current_order.price <= maker_price_max:
            self.cancel_order(current_order)
            return

    def get_current_order(self, trade_type):
        order_id = self.order_ids[trade_type.name]
        if order_id:
            return self.connectors[self.maker_exchange].get_order_by_id(order_id)
        else:
            return None

    def calculate_order_price(self, trade_type, taker_price, profit):
        # Рассчитываем цену ордера для maker рынка с учетом заданной прибыльности
        profit_decimal = Decimal(profit) / Decimal(100)
        
        if trade_type == TradeType.BUY:
            return taker_price * (Decimal(1) - profit_decimal)
        else:  # TradeType.SELL
            return taker_price * (Decimal(1) + profit_decimal)
    

    def place_order(self, trade_type, price):
        order_result = self.connectors[self.maker_exchange].place_limit_order(self.maker_pair, trade_type, price, self.order_amount)
        
        # Проверяем, успешно ли был размещен ордер, и если да, возвращаем id ордера
        if order_result and 'id' in order_result:
            return order_result['id']
        else:
            # Если ордер не был успешно размещен, возвращаем None или выбрасываем исключение
            return None

    def cancel_order(self, order):
        self.connectors[self.maker_exchange].cancel_order(order.id)
        
    def did_fill_maker_order(self, event: OrderFilledEvent):
        # Примечание: каждое частичное исполнение срабатывает как отдельное событие OrderFilled.
        msg = (
            f"{event.trade_type.name} {round(event.amount, 2)} {event.trading_pair} at {round(event.price, 2)}")
        self.log_with_clock(logging.INFO, msg)
        self.notify_hb_app_with_timestamp(msg)


        # [TODO] Если ордер не создан именно этим ботом, то игнорировать
        if event.exchange == self.maker_exchange and event.trading_pair == self.maker_pair:
            # Исполняем арбитражную позицию на taker рынке
            taker_action = TradeType.SELL if event.trade_type == TradeType.BUY else TradeType.BUY
            order_type = OrderType.MARKET
            self.execute_taker_trade(taker_action, event.amount, order_type)
            self.cancel_all_orders(self.maker_exchange, self.maker_pair)  # Отменяем оставшиеся ордера


    def execute_taker_trade(self, trade_type, amount, order_type):
        # Выполнение торговой операции на taker рынке
        if trade_type == TradeType.BUY:
            self.buy(self.taker_exchange, self.taker_pair, amount, order_type)
        else:
            self.sell(self.taker_exchange, self.taker_pair, amount, order_type)

    def exchanges_df(self) -> pd.DataFrame:
        """
        Return a custom data frame of prices on maker vs taker exchanges for display purposes
        """
        mid_price = self.connectors[self.maker_exchange].get_mid_price(self.maker_pair)
        maker_buy_result = self.connectors[self.maker_exchange].get_price_for_volume(self.taker_pair, True, self.order_amount)
        maker_sell_result = self.connectors[self.maker_exchange].get_price_for_volume(self.taker_pair, False, self.order_amount)
        taker_buy_result = self.connectors[self.taker_exchange].get_price_for_volume(self.taker_pair, True, self.order_amount)
        taker_sell_result = self.connectors[self.taker_exchange].get_price_for_volume(self.taker_pair, False, self.order_amount)
        maker_buy_spread_bps = (maker_buy_result.result_price - taker_buy_result.result_price) / mid_price * 10000
        maker_sell_spread_bps = (taker_sell_result.result_price - maker_sell_result.result_price) / mid_price * 10000
        columns = ["Exchange", "Market", "Mid Price", "Buy Price", "Sell Price", "Buy Spread", "Sell Spread"]
        data = []
        data.append([
            self.maker_exchange,
            self.maker_pair,
            float(self.connectors[self.maker_exchange].get_mid_price(self.maker_pair)),
            float(maker_buy_result.result_price),
            float(maker_sell_result.result_price),
            int(maker_buy_spread_bps),
            int(maker_sell_spread_bps)
        ])
        data.append([
            self.taker_exchange,
            self.taker_pair,
            float(self.connectors[self.taker_exchange].get_mid_price(self.maker_pair)),
            float(taker_buy_result.result_price),
            float(taker_sell_result.result_price),
            int(-maker_buy_spread_bps),
            int(-maker_sell_spread_bps)
        ])
        df = pd.DataFrame(data=data, columns=columns)
        return df

    def active_orders_df(self) -> pd.DataFrame:
        """
        Returns a custom data frame of all active maker orders for display purposes
        """
        columns = ["Exchange", "Market", "Side", "Price", "Amount", "Spread Mid", "Spread Cancel", "Age"]
        data = []
        mid_price = self.connectors[self.maker_exchange].get_mid_price(self.maker_pair)
        taker_buy_result = self.connectors[self.taker_exchange].get_price_for_volume(self.taker_pair, True, self.order_amount)
        taker_sell_result = self.connectors[self.taker_exchange].get_price_for_volume(self.taker_pair, False, self.order_amount)
        buy_cancel_threshold = taker_sell_result.result_price * Decimal(1 - self.min_spread_bps / 10000)
        sell_cancel_threshold = taker_buy_result.result_price * Decimal(1 + self.min_spread_bps / 10000)
        for connector_name, connector in self.connectors.items():
            for order in self.get_active_orders(connector_name):
                age_txt = "n/a" if order.age() <= 0. else pd.Timestamp(order.age(), unit='s').strftime('%H:%M:%S')
                spread_mid_bps = (mid_price - order.price) / mid_price * 10000 if order.is_buy else (order.price - mid_price) / mid_price * 10000
                spread_cancel_bps = (buy_cancel_threshold - order.price) / buy_cancel_threshold * 10000 if order.is_buy else (order.price - sell_cancel_threshold) / sell_cancel_threshold * 10000
                data.append([
                    self.maker_exchange,
                    order.trading_pair,
                    "buy" if order.is_buy else "sell",
                    float(order.price),
                    float(order.quantity),
                    int(spread_mid_bps),
                    int(spread_cancel_bps),
                    age_txt
                ])
        if not data:
            raise ValueError
        df = pd.DataFrame(data=data, columns=columns)
        df.sort_values(by=["Market", "Side"], inplace=True)
        return df

    def format_status(self) -> str:
        """
        Returns status of the current strategy on user balances and current active orders. This function is called
        when status command is issued. Override this function to create custom status display output.
        """
        if not self.ready_to_trade:
            return "Market connectors are not ready."
        lines = []

        balance_df = self.get_balance_df()
        lines.extend(["", "  Balances:"] + ["    " + line for line in balance_df.to_string(index=False).split("\n")])

        exchanges_df = self.exchanges_df()
        lines.extend(["", "  Exchanges:"] + ["    " + line for line in exchanges_df.to_string(index=False).split("\n")])

        try:
            orders_df = self.active_orders_df()
            lines.extend(["", "  Active Orders:"] + ["    " + line for line in orders_df.to_string(index=False).split("\n")])
        except ValueError:
            lines.extend(["", "  No active maker orders."])

        return "\n".join(lines)




