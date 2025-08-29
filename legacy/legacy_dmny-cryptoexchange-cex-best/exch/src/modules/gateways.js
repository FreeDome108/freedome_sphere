const fs = require('fs');

const UPDATE_DELAY=1000;

const NAME="GATEWAYS";
const VERBOSE_LEVEL=3;
const DEBUG_LEVEL=0;
const ERROR_LEVEL=9;
log=new Log(NAME, VERBOSE_LEVEL,DEBUG_LEVEL,ERROR_LEVEL);


const { info } =require("../const/info");

const { ExchangerGateway } =require("../gateways/exchanger");
const { BitfinexGateway } =require("../gateways/bitfinex");
const { HitbtcGateway } =require("../gateways/hitbtc");
const { ExmoGateway } =require("../gateways/exmo");
const { IndxGateway } =require("../gateways/indx");



class Gateways {
    constructor(args)
    {
        //console.log("rates:",info.rates);
        //this.rates=rates_rename(info.rates);
        //console.log("this.rates:",this.rates);
        
        this.BITFINEX=new BitfinexGateway();
        this.HITBTC=new HitbtcGateway();
        this.EXMO=new ExmoGateway();

        this.EXCHANGER=new ExchangerGateway();
        this.INDX=new IndxGateway();

    }




    async updateAll()
    {
        let results = await Promise.all([
            this.BITFINEX.getRates(),
            this.HITBTC.getRates(),            
            this.EXCHANGER.getRates(),
            this.EXMO.getRates(),
            this.INDX.getRates()]).then(()=>console.log("ok"));

        this.rates=info.rates;
        this.rates.BITFINEX=this.BITFINEX.rates;
        this.rates.HITBTC=this.HITBTC.rates;
        this.rates.EXCHANGER=this.EXCHANGER.rates;
        this.rates.EXMO=this.EXMO.rates;
        this.rates.INDX=this.INDX.rates;
            
        //console.log(this.rates);
        //console.log(results);
    
    }

    async oloop() {
        await this.updateAll();
        //this.onUpdate(rates);
        //console.log(`🚀🚀🚀🚀🚀🚀🚀🚀 oloop`);
    
        log.verb(1,this.rates);

	    this.rates.timestamp=Date.now().toString();


        fs.appendFileSync('res/sb.txt', `\n`+"SELL:"+((this.rates.EXCHANGER.WMXWMZ.ask*1000/this.rates.BITFINEX.tBTCUSD.bid-1)*100).toString());
        fs.appendFileSync('res/sb.txt', `\n`+"BUY:"+((this.rates.EXCHANGER.WMXWMZ.bid*1000/this.rates.BITFINEX.tBTCUSD.ask-1)*100).toString());

        fs.appendFileSync('res/btc_s.txt', `\n`+"SELL:"+((this.rates.EXCHANGER.WMXWMZ.ask*1000/this.rates.BITFINEX.tBTCUSD.bid-1)*100).toString());
        fs.appendFileSync('res/btc_b.txt', `\n`+"BUY:"+((this.rates.EXCHANGER.WMXWMZ.bid*1000/this.rates.BITFINEX.tBTCUSD.ask-1)*100).toString());

        fs.appendFileSync('res/btci_s.txt', `\n`+"SELL:"+((this.rates.INDX[60].ask*1000/this.rates.BITFINEX.tBTCUSD.bid-1)*100).toString());
        fs.appendFileSync('res/btci_b.txt', `\n`+"BUY:"+((this.rates.INDX[60].bid*1000/this.rates.BITFINEX.tBTCUSD.ask-1)*100).toString());

        fs.appendFileSync('res/eth_s.txt', `\n`+"SELL:"+((this.rates.INDX[64].ask*1000/this.rates.BITFINEX.tETHUSD.bid-1)*100).toString());
        fs.appendFileSync('res/eth_b.txt', `\n`+"BUY:"+((this.rates.INDX[64].bid*1000/this.rates.BITFINEX.tETHUSD.ask-1)*100).toString());

	    fs.appendFileSync('res/btc.csv', `\n${this.rates.timestamp};${(this.rates.EXCHANGER.WMXWMZ.ask*1000/this.rates.BITFINEX.tBTCUSD.bid-1)*100};${(this.rates.EXCHANGER.WMXWMZ.bid*1000/this.rates.BITFINEX.tBTCUSD.ask-1)*100};${this.rates.EXCHANGER.WMXWMZ.ask*1000};${this.rates.BITFINEX.tBTCUSD.bid};${this.rates.EXCHANGER.WMXWMZ.bid*1000};${this.rates.BITFINEX.tBTCUSD.ask};${this.rates.INDX[60].ask*1000};${this.rates.INDX[60].bid*1000}`);

        let best1=(this.rates.EXCHANGER.WMXWMZ.ask*1000/this.rates.BITFINEX.tBTCUSD.bid-1)*100;
        let best2=(this.rates.EXCHANGER.WMXWMZ.bid*1000/this.rates.BITFINEX.tBTCUSD.ask-1)*100;

        fs.appendFileSync('res/d_btc.csv', `\n${this.rates.timestamp};${best1};${best2};${this.rates.EXCHANGER.WMXWMZ.ask*1000};${this.rates.EXCHANGER.WMXWMZ.bid*1000};${this.rates.BITFINEX.tBTCUSD.ask};${this.rates.BITFINEX.tBTCUSD.bid};${this.rates.INDX[60].ask*1000};${this.rates.INDX[60].bid*1000};${this.rates.HITBTC.BTCUSD.ask};${this.rates.HITBTC.BTCUSD.bid}`);
        fs.appendFileSync('res/d_eth.csv', `\n${this.rates.timestamp};${this.rates.BITFINEX.tETHUSD.ask};${this.rates.BITFINEX.tETHUSD.bid};${this.rates.INDX[64].ask*1000};${this.rates.INDX[64].bid*1000};${this.rates.HITBTC.ETHUSD.ask};${this.rates.HITBTC.ETHUSD.bid}`);
        fs.appendFileSync('res/d_ltc.csv', `\n${this.rates.timestamp};${this.rates.EXCHANGER.WMLWMZ.ask*1000};${this.rates.EXCHANGER.WMLWMZ.bid*1000};${this.rates.BITFINEX.tLTCUSD.ask};${this.rates.BITFINEX.tLTCUSD.bid};${this.rates.INDX[69].ask*1000};${this.rates.INDX[69].bid*1000};${this.rates.HITBTC.LTCUSD.ask};${this.rates.HITBTC.LTCUSD.bid}`);
        fs.appendFileSync('res/d_bch.csv', `\n${this.rates.timestamp};${this.rates.EXCHANGER.WMHWMZ.ask*1000};${this.rates.EXCHANGER.WMHWMZ.bid*1000};${this.rates.INDX[66].ask*1000};${this.rates.INDX[66].bid*1000};${this.rates.HITBTC.BCHUSD.ask};${this.rates.HITBTC.BCHUSD.bid}`);

        fs.appendFileSync('res/d_usdeur.csv', `\n${this.rates.timestamp};${this.rates.EXCHANGER.WMEWMZ.ask*1000};${this.rates.EXCHANGER.WMEWMZ.bid*1000};${this.rates.BITFINEX.tEUTUST.ask};${this.rates.BITFINEX.tEUTUST.bid};${this.rates.HITBTC.EURSUSD.ask};${this.rates.HITBTC.EURSUSD.bid};`);




        //let best1=(this.rates.EXCHANGER.WMXWMZ.ask*1000/this.rates.BITFINEX.tBTCUSD.bid-1)*100;
        //let best2=(this.rates.EXCHANGER.WMXWMZ.bid*1000/this.rates.BITFINEX.tBTCUSD.ask-1)*100;

        let best=`${best1};${best2}`;
        let btc=`${this.rates.timestamp};${this.rates.EXCHANGER.WMXWMZ.ask*1000};${this.rates.BITFINEX.tBTCUSD.bid};${this.rates.EXCHANGER.WMXWMZ.bid*1000};${this.rates.BITFINEX.tBTCUSD.ask};${this.rates.INDX[60].ask*1000};${this.rates.INDX[60].bid*1000}`;
        let eth=`${this.rates.BITFINEX.tETHUSD.ask};${this.rates.BITFINEX.tETHUSD.bid};${this.rates.INDX[64].ask*1000};${this.rates.INDX[64].bid*1000};${this.rates.HITBTC.ETHUSD.ask};${this.rates.HITBTC.ETHUSD.bid}`;
        let ltc=`${this.rates.EXCHANGER.WMLWMZ.ask*1000};${this.rates.EXCHANGER.WMLWMZ.bid*1000};${this.rates.BITFINEX.tLTCUSD.ask};${this.rates.BITFINEX.tLTCUSD.bid};${this.rates.INDX[69].ask*1000};${this.rates.INDX[69].bid*1000};${this.rates.HITBTC.LTCUSD.ask};${this.rates.HITBTC.LTCUSD.bid}`;
        let bch=`${this.rates.EXCHANGER.WMHWMZ.ask*1000};${this.rates.EXCHANGER.WMHWMZ.bid*1000};${this.rates.INDX[66].ask*1000};${this.rates.INDX[66].bid*1000};${this.rates.HITBTC.BCHUSD.ask};${this.rates.HITBTC.BCHUSD.bid}`;
        let usdeur=`${this.rates.EXCHANGER.WMEWMZ.ask*1000};${this.rates.EXCHANGER.WMEWMZ.bid*1000};${this.rates.BITFINEX.tEUTUST.ask};${this.rates.BITFINEX.tEUTUST.bid};${this.rates.HITBTC.EURSUSD.ask};${this.rates.HITBTC.EURSUSD.bid};`;
        let all=`${this.rates.timestamp};${best};${btc};${eth};${ltc};${bch};${usdeur}`;

        fs.appendFileSync('res/all.csv', `\n${all}`);






        fs.appendFileSync('res/all.txt', `\n====`);
        fs.appendFileSync('res/all.txt', `\n`+JSON.stringify(this.rates));

        log.verb(2,"SELL:",best1);
        log.verb(2,"BUY:",best2);

        log.verb(2,"ORDERBOOK:",this.EXMO.orderBook);

        setTimeout(()=>this.oloop(), 1000);
    }

    async connect() {
        let results = await Promise.all([
            this.BITFINEX.connect(),
            this.HITBTC.connect(),            
            this.EXCHANGER.connect(),
            this.EXMO.connect(),
            this.INDX.connect()]).then(()=>console.log("ok"));

        //await this.updateAll();

        console.log(`🚀  Gateways connected`);
        console.log(`   =================================\n\n`);   

        console.log("global.online=",global.online);
        if(global.online==true)
        {
            console.log("start oloop");
            setTimeout(()=>this.oloop(), 1000);

        }



    }
}

module.exports = {
    Gateways:Gateways,
}