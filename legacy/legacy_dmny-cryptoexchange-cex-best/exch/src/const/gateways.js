//Описывает комиссии при внутренних операциях
/*
EXMO
rub in:
QIWI - 2.99%
advcash - 0.49
visa=3.49
rub out:
3.49%+60
advcash 1.99
payeer 0.49
qiwi 2.99
yandex 2.99


usd in
visa 3.99+0.35USD
advcash 0

*/


let comissions=
{
    //feeOpen - при исполнении заявки которую мы открыли
    //feeClose - при исполнении заявки которую мы закрыли
    //feeIn - комиссия при вводе средств по дефолту, может быть уточнена в конкретном символе
    //feeOut - комиссия при выводе среств, может быть уточнена в конкретном символе
    EXCHANGER: {
        feeOpen:0.15/100,
        feeClose:0.25/100,
        feeIn:0.8/100,
        feeOut:0
        },
    BITFINEX: {
        feeOpen:0.2/100,
        feeClose:0.2/100,
        feeIn:0,
        feeOut:0,
    },
    INDX: {
        feeOpen:0,
        feeClose:0,
        feeIn:0.8/100,
        feeOut:0
    },
    FOREX: {
        ratio:5 // маржинальная торговля 1:5
    }    
};

// need - веса - которые пытаемся держать в балансе (указаныне в каждой валюте)
// min - минимальные неснижаемые балансы (там где 0 - в принципе нам эта валюта не особо нужна, скорее не стабильная)
// max - максимальный баланс (с учетом перекупа в других системах. Там где 0 - не закупать в принципе. И в других системах не перекредитоваться)

let balance={
    EXCHANGER:{
        immediate:false, // Мгновенный выход на норму
        min:{
            "WMR":10000,
            "WMZ":2000,
            "WME":2000,
            "WMX":300,
            "WMG":10,
            "WML":0,
            "WMH":0,
            "WMK":0,
        },
        weights:{
            "WMR":50000,
            "WMZ":10000,
            "WME":10000,
            "WMX":1000,
            "WMG":20,
            "WML":2000,
            "WMH":1000,
            "WMK":10000,
        },
        max:{
            "WMR":100000,
            "WMZ":30000,
            "WME":30000,
            "WMX":1000,
            "WMG":30,
            "WML":4000,
            "WMH":2000,
            "WMK":20000,
        },
    }

}
//Описывает возможности перемещения средств  между биржами и кошельками, а так же комиссии при переводе
let moves=[    
    //BANK <-> YANDEX
    {currency:"RUR",from:"BANK",to:"YANDEX", fee:0},
    {currency:"RUR",from:"YANDEX",to:"BANK", fee:2/100},

    //BANK <-> QIWI
    {currency:"RUR",from:"BANK",to:"QIWI", fee:0},
    {currency:"RUR",from:"QIWI",to:"BANK", fee:2/100},

    //Можно вывести WMP
    
    // cards.exchanger.money BANK
    {currency:"WMP",from:"BANK",to:"WM", fee:0.8/100, rate: -2.49/100},
    {currency:"WMP",from:"WM",to:"BANK", fee:0.8/100, rate: +1.8/100},
    
    // cards.exchanger.money QIWI,YANDEX
    {currency:"WMP",from:"YANDEX",to:"WM", fee:0.8/100, rate: -2.95/100},
    {currency:"WMP",from:"WM",to:"YANDEX", fee:0.8/100, rate: +2.5/100},    
    {currency:"WMP",from:"QIWI",to:"WM", fee:0.8/100, rate: -2.5/100}, /*Курс биржи=-rate*/
    {currency:"WMP",from:"WM",to:"QIWI", fee:0.8/100, rate: +2.12/100},
    
    //Можно вывести WMZ,WME через биржу на карточку РУ банка, курс плавающий
    
    // cards.exchanger.money BANK
    {currency:"WMZ",currencyTo:"RUR",from:"BANK",to:"WM", fee:0.8/100, rateTo: 77.6322},
    {currency:"WMZ",currencyTo:"RUR",from:"WM",to:"BANK", fee:0.8/100, rateTo: 77.2800},
    
    // cards.exchanger.money QIWI,YANDEX
    {currency:"WMZ",currencyTo:"RUR",from:"YANDEX",to:"WM", fee:0.8/100, rateTo: 79.2999},
    {currency:"WMZ",currencyTo:"RUR",from:"WM",to:"YANDEX", fee:0.8/100, rateTo: 79.1500},
    {currency:"WMZ",currencyTo:"RUR",from:"QIWI",to:"WM", fee:0.8/100, rate: 77.7000}, /*Курс биржи=-rate*/
    {currency:"WMZ",currencyTo:"RUR",from:"WM",to:"QIWI", fee:0.8/100, rate: 77.5967},
    
    // cards.exchanger.money BANK
    {currency:"WME",currencyTo:"RUR",from:"BANK",to:"WM", fee:0.8/100, rateTo: 90.8000},
    {currency:"WME",currencyTo:"RUR",from:"WM",to:"BANK", fee:0.8/100, rateTo: 89.0093},
    
    // cards.exchanger.money QIWI,YANDEX
    {currency:"WME",currencyTo:"RUR",from:"YANDEX",to:"WM", fee:0.8/100, rateTo: 92.0000},
    {currency:"WME",currencyTo:"RUR",from:"WM",to:"YANDEX", fee:0.8/100, rateTo: 90.2100},
    {currency:"WME",currencyTo:"RUR",from:"QIWI",to:"WM", fee:0.8/100, rate: 95.0000}, /*Курс биржи=-rate*/
    {currency:"WME",currencyTo:"RUR",from:"WM",to:"QIWI", fee:0.8/100, rate: 88.5034},


    // https://wmx.wmtransfer.com/#
    //wm - crypto
    {currency:"BTC",from:"CRYPTO",to:"WM", fee:0.8/100},
    {currency:"BTC",from:"WM",to:"CRYPTO", fee:0.8/100},
    {currency:"LTC",from:"CRYPTO",to:"WM", fee:0.8/100},
    {currency:"LTC",from:"WM",to:"CRYPTO", fee:0.8/100},
    {currency:"BCH",from:"CRYPTO",to:"WM", fee:0.8/100},
    {currency:"BCH",from:"WM",to:"CRYPTO", fee:0.8/100},


    //wm.exchanger.money
    {currency:"WMP",from:"EXCHANGER",to:"WM", fee:0.8/100},
    {currency:"WMP",from:"WM",to:"EXCHANGER", fee:0.8/100},
    {currency:"WMZ",from:"EXCHANGER",to:"WM", fee:0.8/100},
    {currency:"WMZ",from:"WM",to:"EXCHANGER", fee:0.8/100},
    {currency:"WME",from:"EXCHANGER",to:"WM", fee:0.8/100},
    {currency:"WME",from:"WM",to:"EXCHANGER", fee:0.8/100},
    {currency:"WMG",from:"EXCHANGER",to:"WM", fee:0.8/100},
    {currency:"WMG",from:"WM",to:"EXCHANGER", fee:0.8/100},
    {currency:"WMG",from:"EXCHANGER",to:"WM", fee:0.8/100},
    {currency:"WMX",from:"WM",to:"EXCHANGER", fee:0.8/100},
    {currency:"WML",from:"EXCHANGER",to:"WM", fee:0.8/100},
    {currency:"WML",from:"WM",to:"EXCHANGER", fee:0.8/100},
    {currency:"WMX",from:"EXCHANGER",to:"WM", fee:0.8/100},
    {currency:"WMX",from:"WM",to:"EXCHANGER", fee:0.8/100},


    //indx
    {currency:"WMZ",from:"WM",to:"INDX", fee:0.8/100},
    {currency:"WMZ",from:"INDX",to:"WM", fee:0.8/100},
    {currency:"EUR",from:"WM",to:"INDX", fee:0.8/100},
    {currency:"EUR",from:"INDX",to:"WM", fee:0.8/100},
    {currency:"WMG",from:"INDX",to:"WM", fee:0.8/100},
    {currency:"WMG",from:"WM",to:"INDX", fee:0.8/100},
    {currency:"BTC",from:"INDX",to:"CRYPTO", fee:0,valueMin:0.001,valueMax:0.6},
    {currency:"BTC",from:"CRYPTO",to:"INDX", fee:0.8/100},
    {currency:"LTC",from:"INDX",to:"CRYPTO", fee:0,valueMin:0.01,valueMax:100},
    {currency:"LTC",from:"CRYPTO",to:"INDX", fee:0.8/100},
    {currency:"BCH",from:"INDX",to:"CRYPTO", fee:0,valueMin:0.01,valueMax:15},
    {currency:"BCH",from:"CRYPTO",to:"INDX", fee:0.8/100},
    {currency:"ETH",from:"INDX",to:"CRYPTO", fee:0,feeFix:0.01,valueMin:0.1}, /*Вывод на адреса контрактов не доступен???*/
    {currency:"ETH",from:"CRYPTO",to:"INDX", fee:0.8/100},
    
    //bitfinex
    {currency:"USD",from:"BANK",to:"BTIFINEX", fee:0.2/100},
    {currency:"USD",from:"BITFINEX",to:"BANK", fee:0.2/100},
    {currency:"XAUt",from:"CRYPTO",to:"BITFINEX", fee:0.2/100},
    {currency:"XAUt",from:"BITFINEX",to:"CRYPTO", fee:0.2/100},
    {currency:"BTC",from:"BITFINEX",to:"CRYPTO", fee:0.2/100},
    {currency:"BTC",from:"CRYPTO",to:"BITFINEX", fee:0.2/100},
    {currency:"LTC",from:"BITFINEX",to:"CRYPTO", fee:0.2/100},
    {currency:"LTC",from:"CRYPTO",to:"BITFINEX", fee:0.2/100},
    {currency:"BCH",from:"BITFINEX",to:"CRYPTO", fee:0.2/100},
    {currency:"BCH",from:"CRYPTO",to:"BITFINEX", fee:0.2/100},
    {currency:"ETH",from:"BITFINEX",to:"CRYPTO", fee:0.2/100},
    {currency:"ETH",from:"CRYPTO",to:"BITFINEX", fee:0.2/100},
    
    //BTCBANKER
    {currency:"BTC",from:"BTCBANKER",to:"CRYPTO", fee:0.8/100},
    {currency:"BTC",from:"CRYPTO",to:"BTCBANKER", fee:0.8/100},

    {currency:"RUR",from:"BTCBANKER",to:"BANK", fee:0.8/100},
    {currency:"RUR",from:"BANK",to:"BTCBANKER", fee:0.8/100},
    {currency:"RUR",from:"BTCBANKER",to:"QIWI", fee:0.8/100},
    {currency:"RUR",from:"QIWI",to:"BTCBANKER", fee:0.8/100},
    {currency:"RUR",from:"BTCBANKER",to:"YANDEX", fee:0.8/100},
    {currency:"RUR",from:"YANDEX",to:"BTCBANKER", fee:0.8/100},


    //binance
    //coinbase
    //bitfinex XAUT
    //hitbtc
    //bitmex

];

module.exports = {
    comissions:comissions,
    moves:moves,
}