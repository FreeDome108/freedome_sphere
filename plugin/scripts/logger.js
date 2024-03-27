// Require CCXT Pro for real-time data
const ccxt = require('ccxt');

// Instantiate exchanges with CCXT Pro
const maker_exchange = new ccxt["derebit"]({
    apiKey: 'KL4mbyYU',
    secret: 'L5Du7D5B2GO0PePrmTJsZ1aoNyqfvaAS2S1hHd8jin8',
});
const taker_exchange = new ccxt["binance"]({
    apiKey: 'fFJjfZfoiRQNv5Kt4DAJ7waI7XAOT6pHg6NnQd4POdiOz2zrR8MhJa36RQhaiEqS',
    secret: 'KY0eIWVS5i0PLtmF5IJkLH6WwzBSuu7fxzVGvTQyhLYSUsVHaekjUaeHT5bR6F2l',
});

let makerOrderBook = null;
let takerOrderBook = null;
let makerLatency = 0; // Latency for the maker exchange
let takerLatency = 0; // Latency for the taker exchange

// Define the trading pair and minimum profitability
const trading_pair = 'BTC/USD'; // Example trading pair, adjust as needed
const min_profitability = 0.01; // Example minimum profitability threshold

// Log file path
const logFilePath = path.join(__dirname, 'arbitrage_log.txt');

// Function to log data to a file
const logToFile = (data) => {
    fs.appendFile(logFilePath, `${data}\n`, (err) => {
        if (err) {
            console.error('Error writing to log file:', err);
        }
    });
};

// Function to handle new order book data from maker exchange
const onMakerOrderBookUpdate = (newOrderBook) => {
    const localTimestamp = Date.now();
    makerLatency = localTimestamp - newOrderBook.timestamp; // Calculate latency in milliseconds
    makerOrderBook = newOrderBook;
    checkArbitrageOpportunity();
};

// Function to handle new order book data from taker exchange
const onTakerOrderBookUpdate = (newOrderBook) => {
    const localTimestamp = Date.now();
    takerLatency = localTimestamp - newOrderBook.timestamp; // Calculate latency in milliseconds
    takerOrderBook = newOrderBook;
    checkArbitrageOpportunity();
};

// Function to continuously monitor for arbitrage opportunities
const checkArbitrageOpportunity = () => {
    if (!makerOrderBook || !takerOrderBook) return; // Wait until both order books are initialized

    try {
        const makerHighestBid = makerOrderBook.bids[0][0];
        const takerLowestAsk = takerOrderBook.asks[0][0];
        const profitability = (takerLowestAsk - makerHighestBid) / makerHighestBid;

        // Prepare log data with latency
        const logData = `Timestamp: ${new Date().toISOString()}, Maker Highest Bid: ${makerHighestBid}, Taker Lowest Ask: ${takerLowestAsk}, Profitability: ${profitability}, Maker Latency: ${makerLatency}ms, Taker Latency: ${takerLatency}ms`;

        // Log the current state, profitability, and latency to the console and file
        console.log(logData);
        logToFile(logData);

        if (profitability >= min_profitability) {
            console.log('Arbitrage opportunity found!');
            // Implement your arbitrage logic here
        }
    } catch (error) {
        console.error('Error in arbitrage opportunity check:', error.message);
    }
};

// Subscribe to order book updates
const subscribeToOrderBooks = async () => {
    // Subscribe to the maker exchange order book updates
    maker_exchange.watchOrderBook(trading_pair).then(orderBook => {
        onMakerOrderBookUpdate(orderBook);
    }).catch(error => {
        console.error('Error subscribing to maker exchange order book:', error.message);
    });

    // Subscribe to the taker exchange order book updates
    taker_exchange.watchOrderBook(trading_pair).then(orderBook => {
        onTakerOrderBookUpdate(orderBook);
    }).catch(error => {
        console.error('Error subscribing to taker exchange order book:', error.message);
    });
};

// Start the subscription
subscribeToOrderBooks();





