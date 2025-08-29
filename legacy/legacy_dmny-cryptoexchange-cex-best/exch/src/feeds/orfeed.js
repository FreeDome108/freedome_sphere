
const fetch = require("node-fetch");

const NAME = "ORFEED";
const API = {
  // https://github.com/ProofSuite/OrFeed
  // tickers_url: `https://api.orfeed.org/getExchangeRate?fromSymbol=JPY&toSymbol=USD&venue=DEFAULT&amount=10000000000000000`
  // tickers_url: `https://api.orfeed.org/getExchangeRate?fromSymbol=BTC&toSymbol=USD&venue=DEFAULT&amount=10000000000000000`
  tickers_url: `https://api.orfeed.org/getExchangeRate`
};

let symbols_full = {
  "BTCUSD": { pair1: "BTC", pairN: "USDT" },
  "ETHUSD": { pair1: "ETH", pairN: "USDT" },
  "BABUSD": { pair1: "BCH", pairN: "USDT" },
  "LTCUSD": { pair1: "LTC", pairN: "USDT" },
}


let symbols_online = {
  "BTCUSD": { pair1: "BTC", pairN: "USDT" },
  "ETHUSD": { pair1: "ETH", pairN: "USDT" },
  "BABUSD": { pair1: "BCH", pairN: "USDT" },
  "LTCUSD": { pair1: "LTC", pairN: "USDT" },
}

let freeRateTokenSymbols={};
freeRateTokenSymbols["SAI"] = "0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359";
freeRateTokenSymbols["DAI"] = "0x6b175474e89094c44da98b954eedeac495271d0f";
freeRateTokenSymbols["USDC"] = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48";
freeRateTokenSymbols["MKR"] = "0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2";
freeRateTokenSymbols["LINK"] = "0x514910771af9ca656af840dff83e8264ecf986ca";
freeRateTokenSymbols["BAT"] = "0x0d8775f648430679a709e98d2b0cb6250d2887ef";
freeRateTokenSymbols["WBTC"] = "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599";
freeRateTokenSymbols["BTC"] = "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599";
freeRateTokenSymbols["OMG"] = "0xd26114cd6EE289AccF82350c8d8487fedB8A0C07";
freeRateTokenSymbols["ZRX"] = "0xe41d2489571d322189246dafa5ebde1f4699f498";
freeRateTokenSymbols["TUSD"] = "0x0000000000085d4780B73119b644AE5ecd22b376";
// ETH is typically always better off as 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
freeRateTokenSymbols["ETH"] = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";
freeRateTokenSymbols["WETH"] = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2";
freeRateTokenSymbols["ETH2"] = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2";
freeRateTokenSymbols["SNX"] = "0xc011a72400e58ecd99ee497cf89e3775d4bd732f";
freeRateTokenSymbols["CSAI"] = "0xf5dce57282a584d2746faf1593d3121fcac444dc";
freeRateTokenSymbols["CUSDC"] = "0x39aa39c021dfbae8fac545936693ac917d5e7563";
freeRateTokenSymbols["KNC"] = "0xdd974d5c2e2928dea5f71b9825b8b646686bd200";
freeRateTokenSymbols["USDT"] = "0xdac17f958d2ee523a2206206994597c13d831ec7";
freeRateTokenSymbols["GST1"] = "0x88d60255F917e3eb94eaE199d827DAd837fac4cB";
freeRateTokenSymbols["GST2"] = "0x0000000000b3F879cb30FE243b4Dfee438691c04";
//commented list of tokens added post deployment
freeRateTokenSymbols["LEND"] = "0x80fb784b7ed66730e8b1dbd9820afd29931aab03";
freeRateTokenSymbols["ADAI"] = "0xfc1e690f61efd961294b3e1ce3313fbd8aa4f85d";
freeRateTokenSymbols["REP"] = "0x1985365e9f78359a9B6AD760e32412f4a445E862";
freeRateTokenSymbols["ZIL"] = "0x05f4a42e251f2d52b8ed15e9fedaacfcef1fad27";
freeRateTokenSymbols["AST"] = "0x27054b13b1b798b345b591a4d22e6562d47ea75a";
freeRateTokenSymbols["HOT"] = "0x6c6ee5e31d828de241282b9606c8e98ea48526e2";
freeRateTokenSymbols["KCS"] = "0x039b5649a59967e3e936d7471f9c3700100ee1ab";
freeRateTokenSymbols["MXM"] = "0x8e766f57f7d16ca50b4a0b90b88f6468a09b0439";
freeRateTokenSymbols["CRO"] = "0xa0b73e1ff0b80914ab6fe0444e65848c4c34450b";
freeRateTokenSymbols["BNB"] = "0xB8c77482e45F1F44dE1745F52C74426C631bDD52";
freeRateTokenSymbols["BNT"] = "0x1f573d6fb3f13d689ff844b4ce37794d79a7ff1c";
freeRateTokenSymbols["HT"] = "0x6f259637dcd74c767781e37bc6133cd6a68aa161";
freeRateTokenSymbols["PAX"] = "0x8e870d67f660d95d5be530380d0ec0bd388289e1";
freeRateTokenSymbols["CDAI"] = "0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643";
freeRateTokenSymbols["CSAI"] = "0xf5dce57282a584d2746faf1593d3121fcac444dc";
freeRateTokenSymbols["USDT"] = "0xdac17f958d2ee523a2206206994597c13d831ec7";
freeRateTokenSymbols["SUSD"] = "0x57ab1e02fee23774580c119740129eac7081e9d3";
freeRateTokenSymbols["SEUR"] = "0xd71ecff9342a5ced620049e616c5035f1db98620";
freeRateTokenSymbols["SGBP"] = "0x97fe22e7341a0cd8db6f6c021a24dc8f4dad855f";
freeRateTokenSymbols["SETH"] = "0x57ab1e02fee23774580c119740129eac7081e9d3";
freeRateTokenSymbols["SJPY"] = "0xf6b1c627e95bfc3c1b4c9b825a032ff0fbf3e07d";
freeRateTokenSymbols["PAY"] = "0xB97048628DB6B661D4C2aA833e95Dbe1A905B280";



let symbols=symbols_online;


class OrfeedGateway {

  constructor(args) {
    this.symbols = symbols;
  }

  parseRates(rates,symbol,json1,json2) {
    console.log(json1);
    console.log(json2);
    this.symbols[symbol].ask=json1.data;
    this.symbols[symbol].bid=1/json2.data;
    return this.symbols;
  }

  async getRates() {
    await Object.keys(this.symbols).forEach(async (key) =>  {
      //let url1=API.tickers_url+`?fromSymbol=${freeRateTokenSymbols[this.symbols[key].pair1]}&toSymbol=${freeRateTokenSymbols[this.symbols[key].pairN]}&venue=UNISWAPBYADDRESSV2&amount=100000000000000`;
      //let url1=API.tickers_url+`?fromSymbol=${this.symbols[key].pair1}&toSymbol=${this.symbols[key].pairN}&venue=UNISWAPBYSYMBOLV1&amount=100000000000000`;
      let url1=API.tickers_url+`?fromSymbol=${this.symbols[key].pair1}&toSymbol=${this.symbols[key].pairN}&venue=BANCOR&amount=100000000000000`;
      console.log(url1);
      const response1 = await fetch(url1);
      const json1 = await response1.json();
      //let url2=API.tickers_url+`?fromSymbol=${freeRateTokenSymbols[this.symbols[key].pairN]}&toSymbol=${freeRateTokenSymbols[this.symbols[key].pair1]}&venue=UNISWAPBYADDRESSV2&amount=100000000000000`;
      //let url2=API.tickers_url+`?fromSymbol=${this.symbols[key].pairN}&toSymbol=${this.symbols[key].pair1}&venue=UNISWAPBYSYMBOLV1&amount=100000000000000`;
      let url2=API.tickers_url+`?fromSymbol=${this.symbols[key].pairN}&toSymbol=${this.symbols[key].pair1}&venue=BANCOR&amount=100000000000000`;
      console.log(url2);
      const response2 = await fetch(url2);
      const json2 = await response2.json();

      this.symbols = this.parseRates(this.symbols, key,json1,json2);
      this.rates=this.symbols;

      
    });
    console.log(NAME + ".getRates");
    console.log(this.symbols);
  }

  async connect() {
    console.log(NAME + ".connect");
        let rates = await this.getRates();

        console.log(`🚀  ${NAME} Gateway connected`);
        console.log(`   =================================\n\n`);  
  }
}











module.exports = {
  OrfeedGateway: OrfeedGateway,
}