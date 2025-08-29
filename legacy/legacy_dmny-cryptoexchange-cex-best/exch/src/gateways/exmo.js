const ws = require('ws');
const fetch = require("node-fetch");
const fs = require('fs');

const NAME = "EXMO";

const VERBOSE_LEVEL=3;
const DEBUG_LEVEL=9;
const ERROR_LEVEL=9;


/*
docs:
  https://github.com/exmo-dev/exmo_api_lib/blob/master/ws/js/client.js
  https://documenter.getpostman.com/view/10287440/SzYXWKPi#79d1a9d4-14f4-4cd5-8032-f39f47c2f584
*/


const API = {

  EXMO_WS_BASE_URL : `wss://ws-api.exmo.com:443/v1`,
  EXMO_WS_PUBLIC_URL : `wss://ws-api.exmo.com:443/v1/public`,
  EXMO_WS_PRIVATE_URL : `wss://ws-api.exmo.com:443/v1/private`
};


let currency = {
  "BTC":{usdPrice:1651},
  "USD":{usdPrice:1},
  "EUR":{usdPrice:1.2},
  "USDT":{usdPrice:1},
  "RUB":{usdPrice:1/73},
}

let alias = {
  "WMZ": {to:"USD", rate:1},
}

let symbol = {
  "BTC_USD": { base: "BTC", quote: "USD" },
  "ETH_USD": { base: "ETH", quote: "USD" },
  
  "BCH_USD": { base: "BCH", quote: "USD" },
  "LTC_USD": { base: "LTC", quote: "USD" },
  "USDT_EUR": { base: "USDT", quote: "EUR" },

  "BTC_USDT": { base: "BTC", quote: "USDT" },
  "GUSD_BTC": { base: "GUSD", quote: "BTC" },

  "BTC_RUB": { base: "EUT", quote: "RUB" },
  "GUSD_RUB": { base: "EUT", quote: "RUB" },
  "USDT_RUB": { base: "EUT", quote: "RUB" },
}

//let symbol=symbol_online;


class ExmoGateway {
  constructor(args) {
    this.log=new Log(NAME,VERBOSE_LEVEL,DEBUG_LEVEL,ERROR_LEVEL);
    
    this.symbol = symbol;
    this.currency = currency;
    this.symbol = initVolumes(this.symbol,this.currency);
    this.rates = symbol;
    this.volume={};
    this.orders={}; //orderBook

    //specific
    this.channels={};
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
    });
    */
    return rates;
  }

  async getRates() {
    //const response = await fetch(API.tickers_url);
    //const json = await response.json();
    //this.rates = this.parseRates(this.rates, json);
    //console.log(this.rates);
  }





  async onMessage(msg) {
    this.log.debug(9,"onMessage");
    this.log.debug(3,msg);
    //const response = await fetch(API.tickers_url);
    //const json = await response.json();
    //this.rates = this.parseRates(this.rates, json);
    //console.log(msg);
    
    if(msg.event=="subscribed"){
      //console.log(msg.params);
      //console.log(this.rates);
      //this.channels[msg.chanId]=msg.symbol;
      

    } else if(msg.event=="update") {
      this.log.debug(4,`msg.event=="update"`);
      this.log.debug(9,msg.topic.substring(0,11));
      if(msg.topic.startsWith("spot/ticker")) {
        this.log.debug(7,"spot/ticker");
        let sym=msg.topic.substring(11+1);
        this.log.debug(9,`sym=${sym}`)
        this.symbol[sym].ask=msg.data.buy_price;
        this.symbol[sym].bid=msg.data.sell_price;
      } else if(msg.topic.startsWith("spot/order_book_snapshots")) {
        this.log.debug(7,"spot/order_book_snapshots");
        let sym=msg.topic.substring(25+1);
        this.log.debug(9,`sym=${sym}`)
        this.orders[sym]=msg.data;
        this.volume[sym]={
          price:{
            ask:this.symbol[sym].volumes.map((n)=>(getVolumePQA(msg.data.ask,n).price)),
            bid:this.symbol[sym].volumes.map((n)=>(getVolumePQA(msg.data.bid,n).price))},
          quantity:{
            ask:this.symbol[sym].volumes.map((n)=>(getVolumePQA(msg.data.ask,n).quantity)),
            bid:this.symbol[sym].volumes.map((n)=>(getVolumePQA(msg.data.bid,n).quantity))
          }
        };
        
        this.log.debug(9,`symbol[${sym}].volumes:`);
        this.log.debug(9,this.symbol[sym].volumes);
        this.log.debug(9,`volume[${sym}]`);
        this.log.debug(9,this.volume[sym]);

        this.orders[sym]=msg.data;
      } else if(msg.topic.startsWith("spot/trades")) {
        this.log.debug(7,"spot/trades");
        let sym=msg.topic.substring(11+1);
        this.log.debug(9,`sym=${sym}`)
        fs.appendFileSync(`res/exmo_${sym}.csv`, `,\n`+JSON.stringify(msg.data));


      }
    } else {
      this.log.verb(3,`unknown msg`);
      this.log.verb(3,msg);
    }
    this.rates=this.symbol;
    this.ticker=this.symbol;
  }

  async onOpen() {
    this.log.verb(1,`🚀  ${NAME} Gateway connected`);
    this.log.verb(1,`   =================================\n\n`);

    //send subs
    let msg = {
      "id":1,
      "method":"subscribe",
      "topics":[], //["spot/trades:BTC_USD","spot/ticker:LTC_USD"]
    };
    
    Object.keys(this.rates).forEach(function (key) {
      msg.topics.push(`spot/ticker:${key}`);
      msg.topics.push(`spot/trades:${key}`);
      msg.topics.push(`spot/order_book_snapshots:${key}`);
      msg.topics.push(`spot/order_book_updates:${key}`);
      //msg.id++;
    });
    this.log.debug(5,"subscribe");
    this.log.debug(5,msg);

    this.w.send(JSON.stringify(msg));
  }

  async connect() {
        this.log.verb(1, "gateway.connect()");

        let url=API.EXMO_WS_PUBLIC_URL;
        this.log.debug(1,`url=${url}`);

        this.w = new ws(url);

        this.w.on('open', () => {

          this.log.verb(1,`onOpen()`);
          this.onOpen();        
        })

        this.w.on('message', (msg) => {
          this.log.verb(1,`onMessage(msg)`);
          this.log.debug(1,msg);
          this.onMessage(JSON.parse(msg));
        });
        
        this.w.on('error',(msg)=> {
          this.log.error(1,`onError(msg)`);
          this.log.debug(1,msg);
          this.onError(msg);
        });

  }
}











module.exports = {
  ExmoGateway: ExmoGateway,
}