const ccxt = require('ccxt');

async function loadAndDisplayMarkets() {
    // Define the exchange ID here to ensure it's available within this function's scope
    const exchangeId = 'deribit'; // Replace 'binance' with the exchange you're interested in
    const exchange = new ccxt[exchangeId](); // No need for API keys for public methods like fetching markets

    try {
        const markets = await exchange.loadMarkets();
        console.log(`Available trading pairs on ${exchangeId}:`);
        Object.keys(markets).forEach(market => {
            console.log(market);
        });
    } catch (error) {
        console.error(`An error occurred: ${error.message}`);
    }
}

loadAndDisplayMarkets();