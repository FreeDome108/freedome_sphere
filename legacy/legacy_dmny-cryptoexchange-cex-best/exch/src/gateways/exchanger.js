
const fetch = require("node-fetch");

const NAME = "EXCHANGER";

const VERBOSE_LEVEL=3;
const DEBUG_LEVEL=0;
const ERROR_LEVEL=9;
log=new Log(NAME,VERBOSE_LEVEL,DEBUG_LEVEL,ERROR_LEVEL);


const API = {
    pairs_url: `https://wm.exchanger.ru/asp/JSONbestRates.asp`,
    tickers_url: `https://wm.exchanger.ru/asp/JSONWMList.asp?exchtype=`
};

/*
no EUR-BTC exchange :(

WME-> WMP, WMZ

WMX-> WMP, WMZ, WMG, WMH, WML
WMH-> WMP, WMZ, WMG, WMX, WML
WML-> WMP, WMZ, WMG, WMX, WMH
WMG-> WMP, WMZ, WME, WMX, WMH, WML

TRIPLETS
RUR/EUR/USD
RUR/USD/BTC
RUR/USD/BY
LTC/USD/RUR
L/USD/RUR
Y/USD/RUR



RUR/USD/BTC

RUR/EUR/XAU

BTC/XAU

*/

let rates_full = {
        "WMZWMP": { pair1: "WMZ", pairN: "WMP", bexchtype: 118, aexchtype: 117 },
        "WMEWMP":{pair1:"WME", pairN:"WMP", bexchtype:119,aexchtype:120},
        "WMXWMP":{pair1:"WMX", pairN:"WMP", bexchtype:129,aexchtype:130},
        "WMGWMP":{pair1:"WMG", pairN:"WMP", bexchtype:127,aexchtype:128},
    
        "WMEWMZ":{pair1:"WME", pairN:"WMZ", bexchtype:3,aexchtype:4},
        "WMXWMZ":{pair1:"WMX", pairN:"WMZ", bexchtype:33,aexchtype:34},
        "WMGWMZ":{pair1:"WMG", pairN:"WMZ", bexchtype:25,aexchtype:26},
    
        "WMLWMZ":{pair1:"WML", pairN:"WMZ", bexchtype:97,aexchtype:98},
        "WMHWMZ":{pair1:"WMH", pairN:"WMZ", bexchtype:79,aexchtype:80},
    
        "WMGWME":{pair1:"WMG", pairN:"WME", bexchtype:27,aexchtype:28},
        "WMGWMX":{pair1:"WMG", pairN:"WMX", bexchtype:59,aexchtype:60},

        "WMGWMH":{pair1:"WMG", pairN:"WMH", bexchtype:91,aexchtype:92},
        "WMXWMH":{pair1:"WMX", pairN:"WMH", bexchtype:95,aexchtype:96},

        "WMGWML":{pair1:"WMG", pairN:"WML", bexchtype:109,aexchtype:110},
        "WMXWML":{pair1:"WMX", pairN:"WML", bexchtype:113,aexchtype:114},

        "WMHWML":{pair1:"WMH", pairN:"WML", bexchtype:115,aexchtype:116},
        "WMHWMP":{pair1:"WMH", pairN:"WMP", bexchtype:135,aexchtype:136},
        "WMLWMP":{pair1:"WML", pairN:"WMP", bexchtype:137,aexchtype:138},
        //WMY, WMK, WMB

        //"WMZWMY":{pair1:"WMZ", pairN:"WMY", bexchtype:,aexchtype:},
        //"WMEWMY":{pair1:"WMZ", pairN:"WMY", bexchtype:,aexchtype:},
};


let rates_fast = {
    "WMZWMP": { pair1: "WMZ", pairN: "WMP", bexchtype: 118, aexchtype: 117 },
};


let rates_online = {
        "WMXWMZ":{pair1:"WMX", pairN:"WMZ", bexchtype:33,aexchtype:34},
        "WMLWMZ":{pair1:"WML", pairN:"WMZ", bexchtype:97,aexchtype:98},
        "WMHWMZ":{pair1:"WMH", pairN:"WMZ", bexchtype:79,aexchtype:80},
        "WMEWMZ":{pair1:"WME", pairN:"WMZ", bexchtype:3,aexchtype:4},
};


//let rates=(global.fast?rates_fast:rates_full);
//    rates=(global.online?rates_online:rates);
// console.log("1231111",global.online,global.fast,rates);
rates=rates_online;


class ExchangerGateway {

    constructor(args) {
        this.rates = rates;
    }

    async getExch(exchtype, bid) {
        try {
            const response = await fetch(API.tickers_url + exchtype);
            const json = await response.json();
        } catch {
            console.log("ERROR%%%%%")
        };
        log.debug(3,"E");
        //console.log(json);
        return (bid ? json.WMExchnagerQuerys[0].inoutrate : json.WMExchnagerQuerys[0].outinrate);
    }

    async getRates() {
        log.debug(5,rates);
        for (const key of Object.keys(rates)) {
            log.debug(5,key);
            let bid = await this.getExch(rates[key].bexchtype, true);
            let ask = await this.getExch(rates[key].aexchtype, false);

            rates[key].bid = bid;
            rates[key].ask = ask;
        };
        return rates;
    }

    makePairs(rates, json) {
        //console.log(json);
        json = json.response;
        Object.keys(json).forEach(function (key) {
            let ticker = json[key];
            //let name = ticker[0];
            //let bid = ticker[1];
            //let ask = ticker[3];
            //rates[name].bid = bid;
            //rates[name].ask = ask;
            console.log(`"${ticker.Direct}":{pair:"${ticker.Direct.replace(' - ', '')}",bid:true,exchtype:${ticker.exchtype}},`);
        });
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
    ExchangerGateway: ExchangerGateway,
}





/*
let pairs={
//    "WMZ - WMR":{pair:"WMZWMR",bid:true,exchtype:1},
//    "WMR - WMZ":{pair:"WMRWMZ",bid:true,exchtype:2},
    "WMZ - WME":{pair:"WMZWME",bid:true,exchtype:3},
    "WME - WMZ":{pair:"WMEWMZ",bid:true,exchtype:4},
//    "WME - WMR":{pair:"WMEWMR",bid:true,exchtype:5},
//    "WMR - WME":{pair:"WMRWME",bid:true,exchtype:6},
//    "WMY - WMZ":{pair:"WMYWMZ",bid:true,exchtype:13},
//    "WMZ - WMY":{pair:"WMZWMY",bid:true,exchtype:14},
//    "WMY - WME":{pair:"WMYWME",bid:true,exchtype:15},
//    "WME - WMY":{pair:"WMEWMY",bid:true,exchtype:16},
//    "WMB - WMZ":{pair:"WMBWMZ",bid:true,exchtype:17},
//    "WMZ - WMB":{pair:"WMZWMB",bid:true,exchtype:18},
//    "WMB - WME":{pair:"WMBWME",bid:true,exchtype:19},
//    "WME - WMB":{pair:"WMEWMB",bid:true,exchtype:20},
//    "WMR - WMY":{pair:"WMRWMY",bid:true,exchtype:21},
//    "WMY - WMR":{pair:"WMYWMR",bid:true,exchtype:22},
//    "WMR - WMB":{pair:"WMRWMB",bid:true,exchtype:23},
//    "WMB - WMR":{pair:"WMBWMR",bid:true,exchtype:24},
    "WMZ - WMG":{pair:"WMZWMG",bid:true,exchtype:25},
    "WMG - WMZ":{pair:"WMGWMZ",bid:true,exchtype:26},
    "WME - WMG":{pair:"WMEWMG",bid:true,exchtype:27},
    "WMG - WME":{pair:"WMGWME",bid:true,exchtype:28},
//    "WMR - WMG":{pair:"WMRWMG",bid:true,exchtype:29},
//    "WMG - WMR":{pair:"WMGWMR",bid:true,exchtype:30},
    "WMZ - WMX":{pair:"WMZWMX",bid:true,exchtype:33},
    "WMX - WMZ":{pair:"WMXWMZ",bid:true,exchtype:34},
//    "WMR - WMX":{pair:"WMRWMX",bid:true,exchtype:37},
//    "WMX - WMR":{pair:"WMXWMR",bid:true,exchtype:38},
//    "WMK - WMZ":{pair:"WMKWMZ",bid:true,exchtype:41},
//    "WMZ - WMK":{pair:"WMZWMK",bid:true,exchtype:42},
//    "WMK - WME":{pair:"WMKWME",bid:true,exchtype:43},
//    "WME - WMK":{pair:"WMEWMK",bid:true,exchtype:44},
//    "WMR - WMK":{pair:"WMRWMK",bid:true,exchtype:45},
//    "WMK - WMR":{pair:"WMKWMR",bid:true,exchtype:46},
//    "WMB - WMX":{pair:"WMBWMX",bid:true,exchtype:49},
//    "WMX - WMB":{pair:"WMXWMB",bid:true,exchtype:50},
//    "WMK - WMX":{pair:"WMKWMX",bid:true,exchtype:51},
//    "WMX - WMK":{pair:"WMXWMK",bid:true,exchtype:52},
//    "WMB - WMG":{pair:"WMBWMG",bid:true,exchtype:53},
//    "WMG - WMB":{pair:"WMGWMB",bid:true,exchtype:54},
//    "WMB - WMK":{pair:"WMBWMK",bid:true,exchtype:55},
//    "WMK - WMB":{pair:"WMKWMB",bid:true,exchtype:56},
//    "WMG - WMK":{pair:"WMGWMK",bid:true,exchtype:57},
//    "WMK - WMG":{pair:"WMKWMG",bid:true,exchtype:58},
    "WMG - WMX":{pair:"WMGWMX",bid:true,exchtype:59},
    "WMX - WMG":{pair:"WMXWMG",bid:true,exchtype:60},
    "WMZ - WMH":{pair:"WMZWMH",bid:true,exchtype:79},
    "WMH - WMZ":{pair:"WMHWMZ",bid:true,exchtype:80},
//    "WMR - WMH":{pair:"WMRWMH",bid:true,exchtype:83},
//    "WMH - WMR":{pair:"WMHWMR",bid:true,exchtype:84},
//    "WMB - WMH":{pair:"WMBWMH",bid:true,exchtype:87},
//    "WMH - WMB":{pair:"WMHWMB",bid:true,exchtype:88},
//    "WMK - WMH":{pair:"WMKWMH",bid:true,exchtype:89},
//    "WMH - WMK":{pair:"WMHWMK",bid:true,exchtype:90},
    "WMG - WMH":{pair:"WMGWMH",bid:true,exchtype:91},
    "WMH - WMG":{pair:"WMHWMG",bid:true,exchtype:92},
    "WMH - WMX":{pair:"WMHWMX",bid:true,exchtype:95},
    "WMX - WMH":{pair:"WMXWMH",bid:true,exchtype:96},
    "WMZ - WML":{pair:"WMZWML",bid:true,exchtype:97},
    "WML - WMZ":{pair:"WMLWMZ",bid:true,exchtype:98},
//    "WMR - WML":{pair:"WMRWML",bid:true,exchtype:101},
//    "WML - WMR":{pair:"WMLWMR",bid:true,exchtype:102},
//    "WMB - WML":{pair:"WMBWML",bid:true,exchtype:105},
//    "WML - WMB":{pair:"WMLWMB",bid:true,exchtype:106},
//    "WMK - WML":{pair:"WMKWML",bid:true,exchtype:107},
//    "WML - WMK":{pair:"WMLWMK",bid:true,exchtype:108},
    "WMG - WML":{pair:"WMGWML",bid:true,exchtype:109},
    "WML - WMG":{pair:"WMLWMG",bid:true,exchtype:110},
    "WML - WMX":{pair:"WMLWMX",bid:true,exchtype:113},
    "WMX - WML":{pair:"WMXWML",bid:true,exchtype:114},
    "WML - WMH":{pair:"WMLWMH",bid:true,exchtype:115},
    "WMH - WML":{pair:"WMHWML",bid:true,exchtype:116},
    "WMZ - WMP":{pair:"WMZWMP",bid:true,exchtype:117},
    "WMP - WMZ":{pair:"WMPWMZ",bid:true,exchtype:118},
    "WME - WMP":{pair:"WMEWMP",bid:true,exchtype:119},
    "WMP - WME":{pair:"WMPWME",bid:true,exchtype:120},
//    "WMP - WMY":{pair:"WMPWMY",bid:true,exchtype:123},
//    "WMY - WMP":{pair:"WMYWMP",bid:true,exchtype:124},
//    "WMP - WMB":{pair:"WMPWMB",bid:true,exchtype:125},
//    "WMB - WMP":{pair:"WMBWMP",bid:true,exchtype:126},
    "WMP - WMG":{pair:"WMPWMG",bid:true,exchtype:127},
    "WMG - WMP":{pair:"WMGWMP",bid:true,exchtype:128},
    "WMP - WMX":{pair:"WMPWMX",bid:true,exchtype:129},
    "WMX - WMP":{pair:"WMXWMP",bid:true,exchtype:130},
//    "WMP - WMK":{pair:"WMPWMK",bid:true,exchtype:131},
//    "WMK - WMP":{pair:"WMKWMP",bid:true,exchtype:132},
    "WMP - WMH":{pair:"WMPWMH",bid:true,exchtype:135},
    "WMH - WMP":{pair:"WMHWMP",bid:true,exchtype:136},
    "WMP - WML":{pair:"WMPWML",bid:true,exchtype:137},
    "WML - WMP":{pair:"WMLWMP",bid:true,exchtype:138},
//    "WMK - WMY":{pair:"WMKWMY",bid:true,exchtype:139},
//    "WMY - WMK":{pair:"WMYWMK",bid:true,exchtype:140},
};
*/