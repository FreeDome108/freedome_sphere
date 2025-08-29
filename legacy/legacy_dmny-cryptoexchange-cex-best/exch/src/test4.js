const ws = require('ws')
const w = new ws('wss://ws-api.exmo.me:443/v1')

w.on('message', (msg) => console.log(msg))

let msg = JSON.stringify({ "method": "subscribeTicker", "params": {"symbol": "ETHBTC" }, "id": 123 })

w.on('open', () => w.send(msg))