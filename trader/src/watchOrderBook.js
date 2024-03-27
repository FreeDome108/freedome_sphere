import { workerData, parentPort } from 'worker_threads';
import ccxt from 'ccxt';

import fs from 'fs';
import path from 'path';

// Access trading pair from workerData
const exchange = workerData.exchange;
const trading_pair = workerData.tradingPair;
const log = workerData.log;
const debug = workerData.debug;

const exchangeConnector = new ccxt.pro[exchange](); //.ccxt.pro.deribit

const safeTradingPair = trading_pair.replace(/\//g, '_');
const logOrderBookFilePath = path.join("logs/", safeTradingPair + "_" + exchange + '_order_book_snapshots.txt');



// Function to log data to a file
const logToFile = (data) => {
        fs.appendFile(logOrderBookFilePath, `${data}\n`, (err) => {
            if (err) {
                console.error('Error writing to log file:', err);
            }
        });
};

const doLog = (message) => {
    
    const highestBid = message.orderBook.bids[0][0];
    const lowestAsk = message.orderBook.asks[0][0];

    const logData = `Timestamp: ${new Date().toISOString()}, Latency: ${message.latency}  Highest Bid: ${highestBid}, Lowest Ask: ${lowestAsk}`;

    if (debug) console.log(logData);
    if (log) logToFile(logData);
}


async function watchOrderBook() {
    while (true) {
        try {
            const orderBook = await exchangeConnector.watchOrderBook(trading_pair);
            const latency = Date.now() - orderBook.timestamp;

            const message = {
                orderBook,
                latency
            };

            parentPort.postMessage(message);
            if(debug || log) doLog(message);
        } catch (error) {
            console.error('watchOrderBook: Error in worker:', error.message);
            // Optionally, send error message to parent thread
            parentPort.postMessage({ error: error.message });
        }
    }
}

watchOrderBook();