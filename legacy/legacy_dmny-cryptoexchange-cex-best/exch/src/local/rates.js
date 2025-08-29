let local_rates=
{
  EXCHANGER: {
    WMZWMP: {
      pair1: 'WMZ',
      pairN: 'WMP',
      bexchtype: 118,
      aexchtype: 117,
      bid: 76.286,
      ask: 76.9098
    },
    WMEWMP: {
      pair1: 'WME',
      pairN: 'WMP',
      bexchtype: 119,
      aexchtype: 120,
      bid: 0.0108,
      ask: 0.0111
    },
    WMXWMP: {
      pair1: 'WMX',
      pairN: 'WMP',
      bexchtype: 129,
      aexchtype: 130,
      bid: 881.0882,
      ask: 894
    },
    WMGWMP: {
      pair1: 'WMG',
      pairN: 'WMP',
      bexchtype: 127,
      aexchtype: 128,
      bid: 4699.5,
      ask: 4900
    },
    WMEWMZ: {
      pair1: 'WME',
      pairN: 'WMZ',
      bexchtype: 3,
      aexchtype: 4,
      bid: 1.1865,
      ask: 1.1941
    },
    WMXWMZ: {
      pair1: 'WMX',
      pairN: 'WMZ',
      bexchtype: 33,
      aexchtype: 34,
      bid: 11.5593,
      ask: 11.6162
    },
    WMGWMZ: {
      pair1: 'WMG',
      pairN: 'WMZ',
      bexchtype: 25,
      aexchtype: 26,
      bid: 61.4375,
      ask: 62
    },
    WMLWMZ: {
      pair1: 'WML',
      pairN: 'WMZ',
      bexchtype: 97,
      aexchtype: 98,
      bid: 0.0472,
      ask: 0.0479
    },
    WMHWMZ: {
      pair1: 'WMH',
      pairN: 'WMZ',
      bexchtype: 79,
      aexchtype: 80,
      bid: 0.2468,
      ask: 0.2589
    },
    WMGWME: {
      pair1: 'WMG',
      pairN: 'WME',
      bexchtype: 27,
      aexchtype: 28,
      bid: 50.4451,
      ask: 54.8667
    },
    WMGWMX: {
      pair1: 'WMG',
      pairN: 'WMX',
      bexchtype: 59,
      aexchtype: 60,
      bid: 0.1586,
      ask: 0.2081
    },
    WMGWMH: {
      pair1: 'WMG',
      pairN: 'WMH',
      bexchtype: 91,
      aexchtype: 92,
      bid: 0.0036,
      ask: 0.0053
    },
    WMXWMH: {
      pair1: 'WMX',
      pairN: 'WMH',
      bexchtype: 95,
      aexchtype: 96,
      bid: 41.09,
      ask: 47.9011
    },
    WMGWML: {
      pair1: 'WMG',
      pairN: 'WML',
      bexchtype: 109,
      aexchtype: 110,
      bid: 0.0007,
      ask: 0.0009
    },
    WMXWML: {
      pair1: 'WMX',
      pairN: 'WML',
      bexchtype: 113,
      aexchtype: 114,
      bid: 232.84,
      ask: 253.5
    },
    WMHWML: {
      pair1: 'WMH',
      pairN: 'WML',
      bexchtype: 115,
      aexchtype: 116,
      bid: 4.9737,
      ask: 5.3999
    },
    WMHWMP: {
      pair1: 'WMH',
      pairN: 'WMP',
      bexchtype: 135,
      aexchtype: 136,
      bid: 12.839,
      ask: 38.9798
    },
    WMLWMP: {
      pair1: 'WML',
      pairN: 'WMP',
      bexchtype: 137,
      aexchtype: 138,
      bid: 3.6999,
      ask: 3.85
    }
  },
  INDX: {
    '60': { pair1: 'mBTC', pairN: 'WMZ', bid: 11.506, ask: 11.5299 },
    '62': { pair1: 'WME', pairN: 'WMZ', bid: 1.1764, ask: 1.18 },
    '64': { pair1: 'mETH', pairN: 'WMZ', bid: 0.3777, ask: 0.3798 },
    '66': { pair1: 'mBCH', pairN: 'WMZ', bid: 0.2478, ask: 0.2497 },
    '69': { pair1: 'mLTC', pairN: 'WMZ', bid: 0.0478, ask: 0.0479 },
    '72': { pair1: 'nWMG', pairN: 'WMZ', bid: 0.6224, ask: 0.6289 }
  },
  BITFINEX: {
    tBTCUSD: { pair1: 'BTC', pairN: 'USD', bid: 11491, ask: 11492 },
    tBTCEUR: { pair1: 'BTC', pairN: 'EUR', bid: 9774, ask: 9774.1 },
    tETHBTC: { pair1: 'ETH', pairN: 'BTC', bid: 0.032741, ask: 0.03275 },
    tETHUSD: { pair1: 'ETH', pairN: 'USD', bid: 376.26, ask: 376.27 },
    tBABUSD: { pair1: 'BCH', pairN: 'USD', bid: 248.07, ask: 248.18 },
    tBABBTC: { pair1: 'BCH', pairN: 'BTC', bid: 0.021576, ask: 0.021599 },
    tLTCUSD: { pair1: 'LTC', pairN: 'USD', bid: 47.355, ask: 47.358 },
    tLTCBTC: { pair1: 'LTC', pairN: 'BTC', bid: 0.004119, ask: 0.004122 },
    'tXAUT:BTC': { pair1: 'XAUt', pairN: 'BTC', bid: 0.16483, ask: 0.16531 },
    'tXAUT:USD': { pair1: 'XAUt', pairN: 'USD', bid: 1898.6, ask: 1900.1 }
  }
}

;


  module.exports = {
    local_rates: local_rates,
}