
const fetch = require("node-fetch");

const NAME = "BITFINEX";
const API = {
  //https://docs.bitfinex.com/reference#rest-public-platform-status
  //https://api.bitfinex.com/v1/symbols
  //https://api-pub.bitfinex.com/v2/platform/status
  //https://api-pub.bitfinex.com/v2/tickers?symbols=ALL
  //tickers_url: `https://api-pub.bitfinex.com/v2/tickers?symbols=tBTCUSD,tBTCEUR,tETHBTC,tETHUSD,tBABUSD,tBABBTC,tLTCUSD,tLTCBTC,tXAUT:BTC,tXAUT:USD`
  tickers_url: `https://api-pub.bitfinex.com/v2/tickers?symbols=tBTCUSD,tETHUSD,tLTCUSD,tBABUSD,tEUTUST`

};

let rates_full = {
  "tBTCUSD": { pair1: "BTC", pairN: "USD" },
  "tBTCEUR": { pair1: "BTC", pairN: "EUR" },

  "tETHBTC": { pair1: "ETH", pairN: "BTC" },
  "tETHUSD": { pair1: "ETH", pairN: "USD" },
  "tBABUSD": { pair1: "BCH", pairN: "USD" },
  "tBABBTC": { pair1: "BCH", pairN: "BTC" },
  "tLTCUSD": { pair1: "LTC", pairN: "USD" },
  "tLTCBTC": { pair1: "LTC", pairN: "BTC" },

  "tXAUT:BTC": { pair1: "XAUt", pairN: "BTC" },
  "tXAUT:USD": { pair1: "XAUt", pairN: "USD" },

  //TETHER LATER
  //{pair1:"USDt", pairN:"USD",  bid:1.00160, ask:1.00170},
  //{pair1:"mBTC", pairN:"USDt",  bid:11408, ask:11411},
  //{pair1:"EURt", pairN:"EUR",  bid:0.94114000, ask:0.998},
  //{pair1:"EURt", pairN:"USD",  bid:1.1760, ask:1.1800},
  //{pair1:"mXAUt", pairN:"USDt",  bid:0.6227, ask:0.6289},
}


let rates_online = {
  "tBTCUSD": { pair1: "BTC", pairN: "USD" },
  "tETHUSD": { pair1: "ETH", pairN: "USD" },
  "tBABUSD": { pair1: "BCH", pairN: "USD" },
  "tLTCUSD": { pair1: "LTC", pairN: "USD" },
  "tEUTUST": { pair1: "EUT", pairN: "UST" },
}

let rates=rates_online;


class BitfinexGateway {

  constructor(args) {
    this.rates = rates;
  }

  parseRates(rates, json) {
    //console.log(json);
    Object.keys(json).forEach(function (key) {
      let ticker = json[key];
      let name = ticker[0];
      let bid = ticker[1];
      let ask = ticker[3];
      rates[name].bid = bid;
      rates[name].ask = ask;
    });
    return rates;
  }

  async getRates() {
    const response = await fetch(API.tickers_url);
    const json = await response.json();
    this.rates = this.parseRates(this.rates, json);
    //console.log(this.rates);
  }

  async connect() {
    console.log(NAME + ".connect");
        let rates = await this.getRates();

        console.log(`🚀  ${NAME} Gateway connected`);
        console.log(`   =================================\n\n`);  
  }
}











module.exports = {
  BitfinexGateway: BitfinexGateway,
}