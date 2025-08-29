//Описывает алиасы валют

let aliases={
    //webmoney
    "WMG": {to:"XAU", rate:31.1035}, // 1XAU = 31.1035WMG
    "WMZ": {to:"USD", rate:1},
    "WMR": {to:"RUR", rate:1},
    "WMP": {to:"RUR", rate:1},
    "WME": {to:"EUR", rate:1},
    "WMX": {to:"BTC", rate:1000},
    "WMH": {to:"BCH", rate:1000},
    "WML": {to:"LTC", rate:1000},
    
    "WMY": {to:"UZS", rate:1},   // 1 RUR=133 UZS узбекский сум
    "WMB": {to:"BYN", rate:1},   // 1 RUR=30 BYN белорусский рубль
    "WMK": {to:"KZT", rate:1},   // 1 RUR=5,5 KZT казахский тенге

    //indx
    "nWMG": {to:"XAU", rate:31.1035*100},
    "mBTC": {to:"BTC", rate:1000},
    "mETH": {to:"ETH", rate:1000},
    "mBCH": {to:"BCH", rate:1000},
    "mLTC": {to:"LTC", rate:1000},
    
    //XAU
    "XAUt": {to:"XAU", rate:1},
    "XAUc": {to:"XAU", rate:1/1.07},  //За валюту принята монета 1oz, коэффициент 1,07 до получения унции
    "XAUc4": {to:"XAU", rate:4/1.07}, //За валюту принята монета георгия победоносца ММД 1/4oz, коэффициент 1,07 до получения унции
    "XAGc": {to:"XAG", rate:1/1.07},  //За валюту принята монета георгия победоносца ММД 1oz, коэффициент 1,07 до получения унции
    
    //bitfinex 
    "BAB": {to:"BCH", rate:1},        //BCH name
};

module.exports = {
    aliases:aliases,
} 