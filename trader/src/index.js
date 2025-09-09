import('dotenv').then(({ config }) => config());
//process.env.MAKER_EXCHANGE

import { Worker } from 'worker_threads';
import ccxt from 'ccxt';

import { markets_configs } from './conf/conf.js';
import { balancer } from './balancer.js';

console.log ('CCXT Version:', ccxt.version)


const makerWorker = new Worker('./src/watchOrderBook.js', {
    workerData: {
        exchange: markets_configs.makers[0].exchange,
        tradingPair: markets_configs.makers[0].trading_pair,
        log: true
    }
});

const takerWorker = new Worker('./src/watchOrderBook.js', {
    workerData: {
        exchange: markets_configs.takers[0].exchange,
        tradingPair: markets_configs.takers[0].trading_pair,
        log: true
    }
});

let makerOrderBook = null;
let takerOrderBook = null;

makerWorker.on('message', (message) => {
    console.log("makerWorker on message");  
    makerOrderBook=message.orderBook;
    checkArbitrageOpportunity();
});

takerWorker.on('message', (message) => {
    console.log("takerWorker on message");  
    takerOrderBook=message.orderBook;
    checkArbitrageOpportunity();
});


// Function to continuously monitor for arbitrage opportunities
const checkArbitrageOpportunity = () => {
    //console.log(makerOrderBook);
    if (!makerOrderBook || !takerOrderBook) {console.log("Not all markets connected"); return;} // Wait until both order books are initialized

    //try {
        balancer(makerOrderBook, takerOrderBook, markets_configs.makers[0], markets_configs.takers[0])
    //} catch (error) {
    //    console.error('Error in arbitrage opportunity check:', error.message);
    //}
};




