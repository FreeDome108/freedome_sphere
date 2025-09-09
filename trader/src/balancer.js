/*
Производит ребалансировку позиций во соответствии с текущим состоянием рынка (чем больше потенциальная прибыль - тем больше открывается позиции)
*/

import fs from 'fs';
import path from 'path';

import { getMath } from './math.js';



// Function to log data to a file
const logToFile = (filename, data) => {
        fs.appendFile(filename, `${data}\n`, (err) => {
            if (err) {
                console.error('Error writing to log file:', err);
            }
        });
};

export function balancer(makerOrderBook, takerOrderBook, maker, taker)
{
  console.log("balancer");
  const safeTradingPair = maker.trading_pair.replace(/\//g, '_');
  const logFilename = path.join("logs/", safeTradingPair + "_" + maker.exchange + "_" + taker.exchange + '_balancer.txt');
  let data=getMath(makerOrderBook, takerOrderBook, maker, taker);
  data.t=Date.now();
  logToFile(logFilename,JSON.stringify(data));
}