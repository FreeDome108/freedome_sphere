global.ws = require('ws');
global.fetch = require("node-fetch");
global.fs = require('fs');

const config=require('./config/config');
global.config = config;

const Log=require('./modules/log');
global.Log = Log;

const settings=require('./config/settings');

const { ver } =require('../package.json');
global.version = ver;
console.log("ℹ️  version:\n",version);

//const { HttpServer } = require("./server/httpserver")
const { Gateways } = require("./modules/gateways")

const { rates_show,best_rates_cross_show,get_rate, rates_rename } =require('./modules/modules');

const { local_rates } = require("./local/rates")

//global.httpServer = new HttpServer();

global.fast=true;
//global.local=true;
global.online=true;


global.gateways = new Gateways();


(async () => {
    let rates;
    if(global.local!=true)
    {
        await gateways.connect();
        console.log(gateways.rates);
        rates=gateways.rates;
    } else {
        rates=local_rates;
    }

    /*
    rates=rates_rename(rates);
    //console.log("!!--------------");
    //console.log(rates);  
        //rates_show(rates,"RUR","XAU");           
        rates_show(rates,"BTC","USD");           
        //rates_show(rates,"BTC","RUR");           

        let r=get_rate(rates,"BTC","USD");
        console.log(r);
        //best_rates_cross_show(rates,"RUR","BTC",["EUR","USD","LTC","XAU"]);

        //best_rates_cross_show(rates,"RUR","EUR",["BTC","BCH","BCL","USD","LTC","XAU"]);
        //best_rates_cross_show(rates,"RUR","BTC",["EUR","BCH","BCL","USD","LTC","XAU"]);
        best_rates_cross_show(rates,"RUR","ETH",["EUR","BCH","BCL","USD","LTC","XAU"]);
        best_rates_cross_show(rates,"USD","ETH",["EUR","BCH","BCL","USD","LTC","XAU"]);
        best_rates_cross_show(rates,"EUR","ETH",["EUR","BCH","BCL","USD","LTC","XAU"]);
        best_rates_cross_show(rates,"XAU","ETH",["EUR","BCH","BCL","USD","LTC","XAU"]);
*/

        /*
        best_path_find("BANK","RUR","CRYPTO","BTC");
        best_path_find("CRYPTO","BTC","BANK","RUR");
        */
   
})();





const express = require('express')
const app = express()
const port = 3001

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})
