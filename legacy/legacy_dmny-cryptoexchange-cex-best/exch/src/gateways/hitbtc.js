const ws = require('ws');
const fetch = require("node-fetch");

const NAME = "HITBTC";

/*
docs:
  https://api.hitbtc.com/
  https://api.hitbtc.com/api/2/public/symbol
*/

const API = {
    rest_url:"https://api.hitbtc.com/api/2",
    market_url:"wss://api.hitbtc.com/api/2/ws/public",
    trading_url:"wss://api.hitbtc.com/api/2/ws/trading",
};

let symbols_full = {
  "BTCUSD": { pair1: "BTC", pairN: "USD" },
  "ETHUSD": { pair1: "ETH", pairN: "USD" },
}


let symbols_online = {
  "BTCUSD": { pair1: "BTC", pairN: "USD" },
  "ETHUSD": { pair1: "ETH", pairN: "USD" },
  "BCHUSD": { pair1: "BCH", pairN: "USD" },
  "LTCUSD": { pair1: "LTC", pairN: "USD" },
  "EURSUSD": { pair1: "EURS", pairN: "USD" },
}

let symbols=symbols_online;


class HitbtcGateway {

  constructor(args) {
    this.symbols = symbols;
    this.rates = symbols;
  }

  parseRates(rates, json) {
    //console.log(json);
    /*
    Object.keys(json).forEach(function (key) {
      let ticker = json[key];
      let name = ticker[0];
      let bid = ticker[1];
      let ask = ticker[3];
      rates[name].bid = bid;
      rates[name].ask = ask;
    });*/
    return rates;
  }

  async getRates() {
    //const response = await fetch(API.tickers_url);
    //const json = await response.json();
    //this.rates = this.parseRates(this.rates, json);
    //console.log(this.rates);
  }

  async onMsg(msg) {
    //const response = await fetch(API.tickers_url);
    //const json = await response.json();
    //this.rates = this.parseRates(this.rates, json);
    //console.log(this.rates);
    if(msg.method=="ticker"){
      //console.log(msg.params);
      //console.log(this.rates);
      this.rates[msg.params.symbol].ask=msg.params.ask;
      this.rates[msg.params.symbol].bid=msg.params.bid;
      //console.log(this.rates);
    } else {
      console.log(msg);
    }
  }

  async connect() {
    console.log(NAME + ".connect");
        const w = new ws(API.market_url)
        w.on('message', (msg) => {
          this.onMsg(JSON.parse(msg));
        });

        
        w.on('open', () => {
          let msg = { "method": "subscribeTicker", "params": {"symbol": "ETHBTC" }, "id": 0 };
          Object.keys(this.rates).forEach(function (key) {
            console.log(msg);
            msg.params.symbol=key;
            msg.id++;
            w.send(JSON.stringify(msg));
          });
          //send connected
        
        });

        w.on('error',(msg)=> {
          console.log("ERROR!!!");
          console.log(msg);
        });





        console.log(`🚀  ${NAME} Gateway connected`);
        console.log(`   =================================\n\n`);  
  }
}











module.exports = {
  HitbtcGateway: HitbtcGateway,
}