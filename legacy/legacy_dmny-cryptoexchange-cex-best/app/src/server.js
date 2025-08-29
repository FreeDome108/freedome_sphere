const express = require('express');
const bodyParser = require('body-parser');
const swaggerUi = require('swagger-ui-express');
const WebSocket = require('ws');
const swaggerDocument = require('../swagger/swagger.json');
const { config } = require('../config/config');

const app = express();
app.use(bodyParser.json());
var orderbook = { "BTCUSD": [1, 2] };


function subscribeToOrderBookUpdates(symbol, exchange, callback) {
  if (exchange == 'binance.com') {



    const ws = new WebSocket(`wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}@depth`);

    ws.on('message', (data) => {
      const update = JSON.parse(data);
      callback(update.bids, update.asks);
    });
  } else {

    throw new Error('This function only works for Binance API.');
  }
}




// Serve the Swagger documentation at "/api-docs/v1"
app.use('/api-docs/v1', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

// Main route for the API version 1 "/api/v1"
const apiRouter = express.Router();

// Get currencies endpoint at "/api/v1/currency"
apiRouter.get('/currency', async (req, res) => {
  res.json({ currencies: config.currencies });
});

// Get symbols endpoint at "/api/v1/symbol"
apiRouter.get('/symbol', async (req, res) => {
  res.json({ symbols: config.symbols });
});


apiRouter.get('/orderbook', async (req, res) => {
  res.json(orderbook);
});

// Get order book endpoint at "/api/v1/orderbook/:symbol"
apiRouter.get('/orderbook/:symbol', async (req, res) => {
  const { symbol } = req.params;
  //if (!orderbook.includes(symbol)) {
  //  return res.status(400).json({ 'error': `Symbol ${symbol} not supported` });
  //}
  res.json(orderbook[symbol]);
});


app.use('/api/v1', apiRouter);

app.listen(3000, () => {
  console.log('Server listening on port 3000');
});

