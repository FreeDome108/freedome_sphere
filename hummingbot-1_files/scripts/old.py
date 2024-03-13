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