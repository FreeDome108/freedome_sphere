/*
Математика и функции, описывающие торговый процесс
используя дефолты из ccxt
*/


export function getAPR(makerOrderBook, takerOrderBook, makerConfig, takerConfig, shortMaker = true, fee = false) {
    let shortPrice, longPrice;
    const today = new Date();
    const expireDate = new Date(makerConfig.future.expire_date);

    const secondsToExpiration = (expireDate - today) / 1000;
console.log("getAPR");
console.log(today);
console.log(expireDate);
console.log(secondsToExpiration);
console.log(makerOrderBook);    
/*
    const makerFee = makerConfig.fee; 
    const takerFee = takerConfig.fee; 
    const makerSlippage = makerConfig.slippage; 
    const takerSlippage = takerConfig.slippage; 
    */

    const makerFee = fee ? 0.02 / 100 : 0; // Примерная комиссия maker
    const takerFee = fee ? 0.05 / 100 : 0; // Примерная комиссия taker
    const makerSlippage = fee ? 0.05 / 100 : 0; // Процент проскальзывания maker
    const takerSlippage = fee ? 0.05 / 100 : 0; // Процент проскальзывания taker

    if (shortMaker) {
        // Maker открывает короткую позицию, а taker — длинную
        shortPrice = makerOrderBook.bids[0][0] * (1 - makerSlippage) * (1 - makerFee);
        longPrice = takerOrderBook.asks[0][0] * (1 + takerSlippage) * (1 + takerFee);
    } else {
        // Maker открывает длинную позицию, а taker — короткую
        longPrice = makerOrderBook.asks[0][0] * (1 + makerSlippage) * (1 + makerFee);
        shortPrice = takerOrderBook.bids[0][0] * (1 - takerSlippage) * (1 - takerFee);
    }

    // Расчет прибыли/убытков и APR
    const pl = shortPrice - longPrice;
    const apr = (pl / longPrice) * (365 * 24 * 3600 / secondsToExpiration) * 100;



    console.log(apr);   
    return apr;
}

export function getMath(makerOrderBook, takerOrderBook, makerConfig, takerConfig)
{
    return {
        s:getAPR(makerOrderBook, takerOrderBook, makerConfig, takerConfig, true, false),
        l:getAPR(makerOrderBook, takerOrderBook, makerConfig, takerConfig, false, false),
        sr:getAPR(makerOrderBook, takerOrderBook, makerConfig, takerConfig, true, true),
        lr:getAPR(makerOrderBook, takerOrderBook, makerConfig, takerConfig, false, true)}
}