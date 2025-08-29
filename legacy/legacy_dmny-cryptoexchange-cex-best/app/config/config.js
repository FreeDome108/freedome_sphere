const config = {
  currencies: ['BTC','ETH','USDT'],
  symbols:['BTCUSDT','BTCETH'],
  markets:[
    { name: 'exchanger.web.money', apiKey: '', enabled: true },
    { name: 'binance.com', apiKey: '', enabled: true },
    { name: 'hitbtc.com', apiKey: '', enabled: true },
    { name: 'bitfinex.com', apiKey: '', enabled: true },
    { name: 'okex.com', apiKey: '', enabled: true },
    { name: 'exmo.com', apiKey: '', enabled: true }
  ],
  // timeout for API requests in milliseconds
  apiTimeout: 500,
  // desired rate of return for investments
  needROI: 1.07,
  // minimum acceptable rate of return for investments (should at least cover 2comissions),
  // if actualROI is less than minROI, server stops
  minROI: 1.02,
};

module.exports = {
  config
};