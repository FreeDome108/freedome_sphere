# Сюда вынесена вся логика по работе с рынком taker_exchange.
# Обращения идут из:
# 1. dman.py, для него выдается информация по цене выставления позиций
# 2. position_executor.py, для него методы по закрытию позиций и контролю цены
# Для внешних источников taker - единый рынок сбыта, но по факту внутри логика реализована по закрытию на лучшем из рынков takers.
# В текущей имплементации takers рынки состоят тоже из одного рынка.


        self.taker_prices = {}
        self.get_order_book(self.config.taker_exchange, self.config.taker_pair)
        #Поже изменить на механизм подписки
        #self.subscribe_to_order_book(self.config.taker_exchange, self.config.taker_pair)

    def get_order_book(self, connector_exchange:str, connector_pair: str):
        order_book=self.strategy.connectors[connector_exchange].get_order_book(connector_pair)
        self.on_order_book_change(order_book,connector_exchange,connector_pair)

    def on_order_book_change(self, order_book, connector_exchange: str, connector_pair: str):
        self.calculate_taker_prices(order_book, connector_exchange, connector_pair, TradeType.SELL);
        self.calculate_taker_prices(order_book, connector_exchange, connector_pair, TradeType.BUY);

    def calculate_taker_prices(self, order_book, connector_exchange: str, connector_pair: str, trade_type: TradeType):
        position_size = self.config.order_amount
        positions_count = self.config.n_levels
        volumes = [Decimal(position_size) for _ in range(positions_count)]

        prices = []

        for volume in volumes:
            total_volume = Decimal("0")
            weighted_price = Decimal("0")
            orders = order_book['asks'] if trade_type == TradeType.BUY else order_book['bids']

            for order_price, order_volume in orders:
                available_volume = Decimal(order_volume)
                required_volume = volume - total_volume

                if available_volume > required_volume:
                    available_volume = required_volume

                weighted_price += Decimal(order_price) * available_volume
                total_volume += available_volume

                if total_volume >= volume:
                    break

            if total_volume == 0:
                prices.append(Decimal("0"))
            else:
                prices.append(weighted_price / total_volume)

        self.taker_prices[trade_type] = prices


        def get_taker_price(self,trade_type,level) -> Decimal:
            return self.taker_prices[trade_type][level]
