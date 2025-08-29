const fetch = require("node-fetch");
const CryptoJS = require("crypto-js");

const keys = require("../config/keys");



const NAME = "INDX";
const API = {
    
  //http://wiki.web.money/projects/webmoney/wiki/INDX_API_Tools
  pairs_url: `https://api.indx.ru/api/v2/trade/Tools`,
  //http://wiki.web.money/projects/webmoney/wiki/INDX_API_OfferList
  tickers_url: `https://api.indx.ru/api/v2/trade/OfferList`
};

let rates_full = 
    {
        60:{pair1:"mBTC", pairN:"WMZ",  bid:11.4997, ask:11.5293},
        64:{pair1:"mETH", pairN:"WMZ",  bid:383.2, ask:385.0},
        66:{pair1:"mBCH", pairN:"WMZ",  bid:250.2, ask:256.4},
        69:{pair1:"mLTC", pairN:"WMZ",  bid:50.8, ask:51.1},
        62:{pair1:"WME", pairN:"WMZ",  bid:1.1760, ask:1.1800},
        72:{pair1:"nWMG", pairN:"WMZ",  bid:0.6320, ask:0.6342},
    };

let rates_fast = 
    {
        60:{pair1:"mBTC", pairN:"WMZ",  bid:11.4997, ask:11.5293},
    };

let rates_online = 
    {
        60:{pair1:"mBTC", pairN:"WMZ",  bid:11.4997, ask:11.5293},
        64:{pair1:"mETH", pairN:"WMZ",  bid:383.2, ask:385.0},
        69:{pair1:"mLTC", pairN:"WMZ",  bid:50.8, ask:51.1},
        66:{pair1:"mBCH", pairN:"WMZ",  bid:250.2, ask:256.4},
    };


//let rates=(global.fast?rates_fast:rates_full);
//    rates=(global.online?rates_online:rates);
let rates=rates_online;

class IndxGateway {

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

  async getList() {
    let Signature=CryptoJS.SHA256(`${keys.indx.Login};${keys.indx.Pass};ru-RU`).toString(CryptoJS.enc.Base64);
    console.log(Signature);

    const post=`{"ApiContext":{"Login":"${keys.indx.Login}","Wmid":"${keys.indx.Wmid}","Culture":"ru-RU","Signature":"${Signature}"}}`;
    const response = await fetch(API.pairs_url,{ method: 'POST', body: post,headers: { 'Content-Type': 'application/json' } });
    
    const json = await response.json();
    console.log(json);
    return json;
  }

  async getRate(exch) {
    let Signature=CryptoJS.SHA256(`${keys.indx.Login};${keys.indx.Pass};ru-RU;${keys.indx.Wmid};${exch}`).toString(CryptoJS.enc.Base64);
    //console.log(Signature);

    const post=`{"ApiContext":{"Login":"${keys.indx.Login}","Wmid":"${keys.indx.Wmid}","Culture":"ru-RU","Signature":"${Signature}"},"Trading":{"ID":${exch}}}`;
    const response = await fetch(API.tickers_url,{ method: 'POST', body: post,headers: { 'Content-Type': 'application/json' } });
    
    const json = await response.json();
    //console.log(json);
    return json;
  }



  async getRates() {
    //let list = await this.getList();
    console.log(rates);
    for (const key of Object.keys(rates)) {
        //console.log(key);
        let crates = await this.getRate(key);
        //console.log(crates);
        if (crates.value==undefined) continue;
        let bid=crates.value.filter(order => (order.kind === 1));
        let ask=crates.value.filter(order => (order.kind === 0));
        //console.log(bid);
        //let bid = await getExch(rates[key].bexchtype, true);
        //let ask = await getExch(rates[key].aexchtype, false);

        rates[key].bid = bid[0].price;
        rates[key].ask = ask[0].price;
    };
    return rates;

  }

  async connect() {
    console.log(NAME + ".connect");
        let rates = await this.getRates();

        console.log(`🚀  ${NAME} Gateway connected`);
        console.log(`   =================================\n\n`);  
  }
}











module.exports = {
    IndxGateway: IndxGateway,
}