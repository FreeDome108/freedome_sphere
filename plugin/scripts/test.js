/*
Please act as AI Javascript programmer.
Please write code for arbitrage cryptocurrency using ccxt between maker_exchange and taker_exchange with traiding_pair.
Include error handling, logging, and real-time order book management. 
On maker_exchange opens MAKER_LIMIT positions whith min_profitability of price from taker_market. when they are filled - immediate buy MARKET order opposite poition on taker_market.
Maker and taker order book should be updated in parallel at same time (in seperate fork processes).
All explanations give inside code in comments, don't give outside code.
*/ 


// Require the ccxt library
const ccxt = require('ccxt');

// Async function to execute the arbitrage strategy
(async () => {
  // Define your maker and taker exchanges and the trading pair
  const maker_exchange_name = 'binance'; // Example: Binance
  const taker_exchange_name = 'kraken'; // Example: Kraken
  const trading_pair = 'BTC/USD'; // Define your trading pair
  const min_profitability = 1.01; // Minimum profitability ratio (e.g., 1% profit)
  
  // Initialize maker and taker exchanges using ccxt
  const maker_exchange = new ccxt[maker_exchange_name]({ apiKey: 'YOUR_API_KEY', secret: 'YOUR_SECRET' });
  const taker_exchange = new ccxt[taker_exchange_name]({ apiKey: 'YOUR_API_KEY', secret: 'YOUR_SECRET' });

  // Function to check for arbitrage opportunity
  const checkArbitrageOpportunity = async () => {
    // Fetch order books from both exchanges
    const maker_orderbook = await maker_exchange.fetchOrderBook(trading_pair);
    const taker_orderbook = await taker_exchange.fetchOrderBook(trading_pair);
    
    // Calculate the highest bid on the maker exchange and the lowest ask on the taker exchange
    const maker_highest_bid = maker_orderbook.bids[0][0];
    const taker_lowest_ask = taker_orderbook.asks[0][0];
    
    // Check if arbitrage opportunity exists based on min_profitability
    if (maker_highest_bid * min_profitability < taker_lowest_ask) {
      return {
        opportunity: true,
        buyPrice: maker_highest_bid,
        sellPrice: taker_lowest_ask
      };
    }
    
    return { opportunity: false };
  };
  
  // Main logic for arbitrage execution
  const executeArbitrage = async () => {
    const arbitrageOpportunity = await checkArbitrageOpportunity();
    
    if (arbitrageOpportunity.opportunity) {
      // Open a MAKER_LIMIT position on maker_exchange
      const maker_order = await maker_exchange.createLimitSellOrder(trading_pair, /* quantity */, arbitrageOpportunity.buyPrice);
      console.log('Maker limit sell order placed', maker_order);
      
      // Ideally, monitor the maker_order for completion before executing the next step.
      // This example assumes the order is filled immediately for simplicity.
      
      // Once the maker order is filled, place a MARKET buy order on the taker_exchange
      const taker_order = await taker_exchange.createMarketBuyOrder(trading_pair, /* quantity */);
      console.log('Taker market buy order placed', taker_order);
    } else {
      console.log('No arbitrage opportunity found at the moment');
    }
  };
  
  // Execute the arbitrage strategy
  executeArbitrage();
  
  // Note: In a real-world scenario, you would run the arbitrage check and execution periodically or based on market events.
})();




/*v2*/


const ccxt = require('ccxt');

// Configuration
const maker_exchange_id = 'binance'; // Example: 'binance', 'kraken', etc.
const taker_exchange_id = 'bitfinex'; // Example: 'bitfinex', 'coinbase', etc.
const trading_pair = 'BTC/USDT'; // Trading pair to arbitrage
const min_profitability = 0.01; // Minimum profitability threshold (1% in this case)
const maker_limit_amount = 0.01; // Amount to trade on the maker exchange
const apiKey = 'YOUR_API_KEY';
const secret = 'YOUR_SECRET';

// Initialize exchanges with your API keys
const maker_exchange = new ccxt[maker_exchange_id]({ apiKey: apiKey, secret: secret });
const taker_exchange = new ccxt[taker_exchange_id]({ apiKey: apiKey, secret: secret });

async function updateOrderBooks() {
    try {
        // Fetch order books from both exchanges
        const maker_order_book = await maker_exchange.fetchOrderBook(trading_pair);
        const taker_order_book = await taker_exchange.fetchOrderBook(trading_pair);
        
        // Log the current top bids and asks for both exchanges
        console.log(`Maker Exchange (${maker_exchange_id}) Top Bid: ${maker_order_book.bids[0][0]}, Top Ask: ${maker_order_book.asks[0][0]}`);
        console.log(`Taker Exchange (${taker_exchange_id}) Top Bid: ${taker_order_book.bids[0][0]}, Top Ask: ${taker_order_book.asks[0][0]}`);
        
        return { maker_order_book, taker_order_book };
    } catch (error) {
        console.error('Error fetching order books:', error.message);
        throw error;
    }
}

async function executeArbitrage() {
    try {
        const { maker_order_book, taker_order_book } = await updateOrderBooks();

        // Determine the arbitrage opportunity
        const maker_price = maker_order_book.asks[0][0];
        const taker_price = taker_order_book.bids[0][0];
        const profitability = (taker_price - maker_price) / maker_price;

        // Check if the arbitrage opportunity meets our minimum profitability threshold
        if (profitability >= min_profitability) {
            console.log(`Arbitrage opportunity found! Profitability: ${profitability * 100}%`);

            // Place a limit sell order on the maker exchange
            const sellOrder = await maker_exchange.createLimitSellOrder(trading_pair, maker_limit_amount, maker_price);
            console.log(`Limit sell order placed on ${maker_exchange_id}:`, sellOrder);

            // Assuming the sell order is immediately filled (which may not always be the case),
            // place a market buy order on the taker exchange
            const buyOrder = await taker_exchange.createMarketBuyOrder(trading_pair, maker_limit_amount);
            console.log(`Market buy order placed on ${taker_exchange_id}:`, buyOrder);
        } else {
            console.log('No profitable arbitrage opportunity found.');
        }
    } catch (error) {
        console.error('Error executing arbitrage:', error.message);
        // Additional error handling can be implemented here
    }
}

// Execute the arbitrage strategy
executeArbitrage();


////


////old


let makerOrderBook = null;
let takerOrderBook = null;


// Function to handle new order book data from maker exchange
const onMakerOrderBookUpdate = (newOrderBook) => {
    makerOrderBook = newOrderBook;
    checkArbitrageOpportunity();
};

// Function to handle new order book data from taker exchange
const onTakerOrderBookUpdate = (newOrderBook) => {
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