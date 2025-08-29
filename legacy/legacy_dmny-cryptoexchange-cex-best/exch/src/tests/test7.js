const ws = require('ws')
const w = new ws('wss://ws-api.exmo.com:443/v1/public')

w.on('message', (msg) => console.log(msg))

/*
let msg = JSON.stringify({ 
  event: 'subscribe', 
  channel: 'ticker', 
  symbol: 'tBTCUSD' 
})*/
//let msg='{"id":1,"method":"subscribe","topics":["spot/trades:BTC_USD","spot/order_book_snapshots:BTC_USD","spot/order_book_updates:BTC_USD","spot/ticker:LTC_USD"]}';
let msg='{"id":1,"method":"subscribe","topics":["spot/trades:BTC_USD","spot/ticker:ETH_USD"]}';

w.on('open', () => w.send(msg))