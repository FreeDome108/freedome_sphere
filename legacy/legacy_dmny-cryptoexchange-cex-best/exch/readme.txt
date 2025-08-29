/*
//cash
//wm
//bitfinex
//from:"cash"
//to:"wm"
// todo: добавить кошелек WM отдельно от EWM
// TOTAL in RUR
// CASH(нал), WM(WM-кошелек), CRYPTO(крипто-кошельки)
// 1,000 WMZ=1 BTC
// 1 XAUt = 1once gold
// 1 WMG = 1gramm gold
// 1 унция = 31.1035 WMG
// Делаем замены
// WMG -> XAU и делим на 31.1035
// mBTC -> BTC
// XAU в oz

Биржи с платежными системами
https://profinvestment.com/fiat-cryptocurrency-exchanges/

Bitfinex -? 
Hitbtc - Фиат?



Боты
https://github.com/butor/blackbird
https://github.com/tiagosiebler/TriangularArbitrage
https://github.com/michaelgrosner/tribeca



=EXCHANGE
==blackbird
Bitfinex	✓	✓	✓	
OKCoin	✓		✓	their API now offers short selling: link here
Bitstamp	✓		✓	
Gemini	✓		✓	
Kraken	✓	✓		Validation in progress. Shorting is currently in testing
EXMO	✓			New exchange from PR #336. Might be a scam
QuadrigaCX	✓			
GDAX	✓			Validation in progress. Shorting is not currently supported.
==triangular???
binance
==tribeca 
coinbase - uses the WebSocket API. Ensure the Coinbase-specific properties have been set with your correct account information if you are using the sandbox or live-trading environment.
hitbtc - WebSocket + socket.io API. Ensure the HitBtc-specific properties have been set with your correct account information if you are using the dev or prod environment.
okcoin - Websocket.Ensure the OKCoin-specific properties have been set with your correct account information. Production environment only.
bitfinex REST API only. Ensure the Bitfinex-specific properties have been filled out. REST API is not suitable to millisecond latency trading. Production environment only.


Uniswap:
https://github.com/Uniswap

Как можно заработать на арбитраже:

1. Обменник со своим курсом.

Человек заказывает необходимую валюту. Бэк подбирает биржу, на которой курс наиболее выгодный, закупает там. Выводим оттуда.
Не совсем так. ВОзможно посмотреть где есть что, может уже есть в наличии и нужно отдать оттуда где лежит, а закупить в другом месте.
Еще вопрос - куда принимаем. Обдумать алгоритм.

2. Обменник на бирже, где большая маржа (например exchanger).

По сути мы выставляем в стакан заявки, чтобы они были на первом месте и ждем как рыбак рыбку. Когда на эту заявку клюнут.
В стакан можно выставлять заявки, ориентируясь на реальные предложения с других бирж.
Дополнительно сразу закладывая свою маржу(дельту). С повышением объема - повышаем дельту. Так же даем немного конкурентам продавать (например 50%) чтобы не убивать рынок.

2.1 Создание ликвидности по не очень рабочим парам
В парах, где низкие объемы - стакан наполняем заявками для видимости работы, разбавляем разными позициями. Типа ликвидность длаем.

2.2. Обменник на вводе-выводе (особенно редкие, например WME, разные карты, QIWI(QIWI/WME 3 заявки в день), Yandex(/wme - 7 заявок в день. Возможно в ручном режиме по рекомендации))

3. Поиск треугольников на одной бирже (актуально например к exchanger, не актуально к большинству бирж)


4. Поиск разных спредов на разных биржах, чтобы портфель сохранялся, а за счет переливов (параллельной закупке в одном месте и продаже в другом - объем сохранялся)
Гипотезу о ликвидности реального инструмента. Действительно ли он соответствует фиату. Можно ли его реально вывести, или он будет закуплен, но по факту перекупив его на одной бирже, дальше его никуда не деть и реальная стоимость его просто нарисована.

5. Автообменник на exchanger с всегда верхней строкой для закупки себе активов по самой лучшей цене. ()

6. Игра на понижение меж биржевой арбитраж
Если мы можем играть на понижение - то мы можем найти момент, когда на одной бирже цена завышена, а на другой занижена. Закупить где занижена, продать где завышена и ждать когда произойдет уравнение.
Так же мы можем делать аналогичное на бирже без возможности понижения - имея там свою корзину и уменьшая позиции в ней. Если у нас на бирже есть своя корзина.


Мысли:
Крипта везде стандартная. За исключением комиссии - её можно переливать между биржами. Фиат так просто не перелить.
Поэтому нужно отталкиваться от значений крипты.
Скорее всего за основу - взять BTC. 

Скорее всего достаточно пару криптобирж и webmoney exchange

План такой:
Там, где большой спред(например webmoney exchanger - ставим заявки на +1 к объему чем заявка конкурента, дублируем позиции)
При выполнении заявки - делаем корректировку активов на арбитражной бирже.
Тем самым поддерживаем примерно один и тот же портфель, постепенно его наращивая.
Можно ли использовать форекс биржу как арбитражную для RUR/USD/EUR???
Найти биржу, на которой можно зашортить все активы в золото. Желательно с плечем 1:2 минимум.


EXMO - curl ca

OkCoinEnable=false
BitstampEnable=false
ItBitEnable=false
WEXEnable=false
QuadrigaEnable=false
ExmoEnable=false


[ 10/15/2020 15:10:00 ]
+   Bitfinex: 	11323.00 / 11324.00
   Gemini: 	11322.55 / 11324.82
   Kraken: 	11320.30 / 11320.40
   Poloniex: 	11314.15 / 11314.15
   GDAX: 	11320.83 / 11320.91
+   Cexio: 	11318.10 / 11336.50
   Bittrex: 	11309.88 / 11316.83
+   Binance: 	11316.67 / 11316.68
   ----------------------------
   Bitfinex/Poloniex:	-0.09% [target  0.80%, min -0.09%, max -0.05%]
   Gemini/Bitfinex:	-0.02% [target  0.80%, min -0.07%, max -0.01%]
   Gemini/Poloniex:	-0.09% [target  0.80%, min -0.13%, max -0.08%]
   Kraken/Bitfinex:	 0.02% [target  0.80%, min -0.00%, max  0.03%]
   Kraken/Poloniex:	-0.06% [target  0.80%, min -0.06%, max -0.01%]
   Poloniex/Bitfinex:	 0.08% [target  0.80%, min  0.03%, max  0.08%]
   GDAX/Bitfinex:	 0.02% [target  0.80%, min  0.01%, max  0.03%]
   GDAX/Poloniex:	-0.06% [target  0.80%, min -0.06%, max -0.02%]
   Cexio/Bitfinex:	-0.12% [target  0.80%, min -0.17%, max -0.06%]
   Cexio/Poloniex:	-0.20% [target  0.80%, min -0.23%, max -0.12%]
   Bittrex/Bitfinex:	 0.05% [target  0.80%, min  0.03%, max  0.07%]
   Bittrex/Poloniex:	-0.02% [target  0.80%, min -0.03%, max -0.00%]
   Binance/Bitfinex:	 0.06% [target  0.80%, min  0.02%, max  0.07%]
   Binance/Poloniex:	-0.02% [target  0.80%, min -0.05%, max  0.00%]


https://api.bitfinex.com/v1/ticker/btcusd
{"mid":"11385.5","bid":"11385.0","ask":"11386.0","last_price":"11381.4131616","timestamp":"1602765303.010722311"}


https://api-pub.bitfinex.com/v2/tickers?symbols=tBTCUSD,tLTCUSD,fUSD
https://api-pub.bitfinex.com/v2/tickers?symbols=ALL


https://wm.exchanger.ru/asp/JSONbestRatesMinus.asp
https://wm.exchanger.ru/asp/JSONWMList.asp?exchtype=7




https://github.com/hitbtc-com/hitbtc-api

https://api.hitbtc.com/api/2/public/symbol/
https://api.hitbtc.com/api/2/public/symbol/ETHBTC
{"id":"ETHBTC","baseCurrency":"ETH","quoteCurrency":"BTC","quantityIncrement":"0.0001","tickSize":"0.000001","takeLiquidityRate":"0.0025","provideLiquidityRate":"0.001","feeCurrency":"BTC","marginTrading":true,"maxInitialLeverage":"10.00"}

https://api.hitbtc.com/api/2/public/orderbook/ETHBTC?limit=100

{
  "symbol": "ETHBTC",
  "timestamp": "2020-10-15T12:59:43.888Z",
  "batchingTime": "2020-10-15T12:59:43.895Z",
  "ask": [
    {
      "price": "0.032985",
      "size": "25.8000"
    },...



Для личных целей - закупать выгоднее у большого поставщика.
У малых бирж идет переток капитала постепенный и на этом съедании зарабатывают.
Кажется спред больше становится и в связи с этим нет возможности купить по рынку.
На съедании маржи можно пробовать заработать. Но это только автоматом получится.

Выйти на биржу побольше (через резервные валюты), там уже правильно распределять ресурсы.

Биткоин / Etherium

Etherium - обладает лагом по сравнению c Etherium 
Возможно оттуда в биток идет отток капитала.

Как это можно использовать?
Хранить сбережения в Битке. После роста и пика битка - переводить в эфириум. После отката - возвращаться в биток.
Возможно при падении битка - фиксируются обратно в эфир.
Опять- же если цена на эфир падает - это знак что его продают и готовятся вкладываться в биток.
*/