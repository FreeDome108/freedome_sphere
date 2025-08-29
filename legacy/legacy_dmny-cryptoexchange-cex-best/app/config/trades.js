const numbers = {
  // desired rate of return for investments (in percent)
  needROI: 108,
  // minimum acceptable rate of return for investments (should at least cover 2comissions),
  // if actualROI is less than minROI, server stops
  minROI: 102,

  //ROI distribution (ROI, )
  tableROI: {
    10000:0.1,
    5000:0.1,
    1000:0.1,
    500:0.1,
    200:0.1,
    150:0.1,
    120:0.1,
    110:0.1,
    109:0.1,
    108:0.1
    
  },

  //orders
  orderMinUSD:1,
  orderMaxUSD:10,

  //atomic operation(sum of all trades)
  atomicMaxUSD: 200,
  atomicMinUSD: 100,
};

module.exports = {
  numbers
};