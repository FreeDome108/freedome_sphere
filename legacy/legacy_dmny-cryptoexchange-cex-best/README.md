# Legacy DMNY Crypto Exchange CEX.Best

## Обзор проекта
Экспериментальная система для межбиржевого арбитража криптовалют с фокусом на WebMoney экосистему и российский рынок. Проект разработан для автоматизации торговых операций и поиска арбитражных возможностей.

## Архитектура системы

### Компоненты проекта

#### 1. APP - Основное приложение
**Технологии**: Node.js, Express, Swagger
- Центральная API система для управления торговыми операциями
- Конфигурационные файлы для различных бирж
- Система переводов для интернационализации
- OpenAPI документация через Swagger

#### 2. EXCH - Торговый движок
**Технологии**: Node.js, TypeScript, WebSocket
- Коннекторы к популярным биржам
- Система агрегации данных и ценообразования
- Модульная архитектура для добавления новых бирж

### Поддерживаемые биржи и протоколы

#### Криптобиржи:
- **Bitfinex**: REST API + WebSocket для real-time данных
- **HitBTC**: Полная интеграция с поддержкой маржинальной торговли
- **EXMO**: Российская биржа с рублевыми парами
- **Kraken**: Европейская биржа с высокой ликвидностью
- **Binance**: Крупнейшая мировая биржа

#### Платежные системы:
- **exchanger.ru**: WebMoney обменник с высокими спредами
- **indx.ru**: Мост между криптовалютами и WebMoney
- **EXMO**: RUR пары для фиатного арбитража

## Ключевые торговые стратегии

### 1. WebMoney арбитраж
**Основная идея**: Использование разницы курсов между WebMoney и криптобиржами

#### Прибыльные пары:
- **WMX/WMZ** (BTC/USD): Спред <1%, высокие объемы
- **WMX/WMR** (BTC/RUB): Спред >10%, требует активного управления
- **WMX/WMP** (USD/RUR): Спред <0.5%, валютный арбитраж

#### Особенности:
- Инертность российского рынка создает арбитражные окна
- Возможность получения до 10% прибыли на валютных перекосах
- Автоматическое отслеживание курса ЦБ РФ

### 2. Треугольный арбитраж
**Механизм**: Поиск несоответствий в кросс-курсах различных валютных пар

#### Поддерживаемые инструменты:
- BTC/ETH/USD треугольники
- Фиатные валюты через WebMoney
- Стейблкойн арбитраж (USDT/USDC/TUSD)

### 3. Маркет-мейкинг
**Стратегия**: Создание ликвидности на биржах с низкими объемами

#### Подходы:
- Выставление лимитных ордеров с +1 к объему конкурентов
- Дублирование позиций для видимости активности
- Постепенное наращивание портфеля через спреды

### 4. Волатильность-зависимый арбитраж
**Концепция**: Адаптация стратегии в зависимости от рыночных условий

#### Условия применения:
- **Низкая волатильность**: DEX ↔ CEX арбитраж
- **Высокая волатильность**: CEX ↔ PERPETUAL арбитраж
- **Ночная торговля**: Фокус на ботов CНГ-бирж

Высокоспециализированная система межбиржевого арбитража с глубокой интеграцией WebMoney экосистемы. Система создана для автоматического выявления и использования ценовых диспропорций между традиционными платежными системами (WebMoney) и глобальными криптобиржами.

## Детальная архитектура системы

### Двухкомпонентная структура

#### 1. APP - REST API Gateway
**Технологический стек**: Node.js v12+, Express 4.x, Swagger OpenAPI 3.0
```javascript
// Основная структура сервера из server.js
const express = require('express');
const config = require('./config/config');
const trades = require('./config/trades');
```

**Ключевые модули**:
- **config.js**: Центральная конфигурация PostgreSQL, API endpoints
- **trades.js**: Конфигурация торговых пар и лимитов
- **translate.js**: i18n система для многоязычности
- **other.js**: Утилитарные функции и helper методы

**API Endpoints Structure**:
```
GET  /api/rates         - Текущие курсы всех бирж
POST /api/trade         - Размещение арбитражного ордера  
GET  /api/portfolio     - Состояние портфеля
GET  /api/opportunities - Активные арбитражные возможности
```

#### 2. EXCH - Core Trading Engine
**Технологический стек**: Node.js, native async/await, WebSocket clients

**Модульная архитектура**:
```
exch/src/
├── index.js           # Главный orchestrator
├── modules/           # Основная бизнес-логика
│   ├── gateways.js    # Менеджер подключений к биржам
│   ├── modules.js     # Арбитражные алгоритмы
│   └── log.js         # Logging система
├── gateways/          # Коннекторы к биржам
│   ├── exchanger.js   # WebMoney exchanger
│   ├── bitfinex.js    # Bitfinex REST/WS API
│   ├── hitbtc.js      # HitBTC integration
│   ├── exmo.js        # EXMO (российская биржа)
│   └── indx.js        # INDX crypto-WebMoney bridge
├── config/            # Конфигурации
├── const/             # Константы и справочники
└── tests/             # Unit тесты
```

## Глубокий анализ торгового движка

### Core Trading Loop (oloop в gateways.js)
**Основной цикл обновления данных каждые 1000ms**:

```javascript
async oloop() {
    await this.updateAll();  // Параллельное обновление всех бирж
    
    // Расчет арбитражных возможностей BTC/USD
    let sellSpread = (this.rates.EXCHANGER.WMXWMZ.ask * 1000 / 
                     this.rates.BITFINEX.tBTCUSD.bid - 1) * 100;
    let buySpread = (this.rates.EXCHANGER.WMXWMZ.bid * 1000 / 
                    this.rates.BITFINEX.tBTCUSD.ask - 1) * 100;
    
    // Логирование возможностей в CSV для анализа
    fs.appendFileSync('res/d_btc.csv', data);
}
```

### Детальные Gateway коннекторы

#### ExchangerGateway (WebMoney integration)
**Ключевая особенность**: Использование специфичных exchtype для каждой валютной пары

```javascript
// Структура валютных пар WebMoney
let rates_online = {
    "WMXWMZ": {pair1:"WMX", pairN:"WMZ", bexchtype:33, aexchtype:34}, // BTC/USD
    "WMLWMZ": {pair1:"WML", pairN:"WMZ", bexchtype:97, aexchtype:98}, // LTC/USD  
    "WMHWMZ": {pair1:"WMH", pairN:"WMZ", bexchtype:79, aexchtype:80}, // BCH/USD
    "WMEWMZ": {pair1:"WME", pairN:"WMZ", bexchtype:3,  aexchtype:4}   // EUR/USD
};
```

**API интеграция**:
- **Rate fetching**: `https://wm.exchanger.ru/asp/JSONWMList.asp?exchtype={ID}`
- **Bid/Ask parsing**: Разные exchtype ID для покупки и продажи
- **Error handling**: Graceful degradation при недоступности API

#### BitfinexGateway - Professional Exchange Integration
**WebSocket + REST hybrid**:
```javascript
// Real-time тикеры через Bitfinex API v2
const SYMBOLS = ['tBTCUSD', 'tETHUSD', 'tLTCUSD', 'tEUTUST'];
const API_URL = 'https://api-pub.bitfinex.com/v2/tickers?symbols=ALL';
```

#### HitBTC Gateway - European Market Access
**Особенности**:
- Margin trading support (leverage до 10x)
- Fee structure: 0.25% maker, 0.15% taker
- High-frequency API with rate limiting compliance

### Математические алгоритмы арбитража

#### Volume-Weighted Average Price Calculation
```javascript
// Из modules.js - расчет VWAP для больших ордеров
global.getVolumeQA = (orders, amount) => {
    let gAmount = 0;
    let gQuantity = 0;
    
    orders.every(function(order, index) {
        let nAmount = amount - gAmount;
        let p = parseFloat(order[0]); // price
        let q = parseFloat(order[1]); // quantity  
        let a = parseFloat(order[2]); // amount
        
        if (nAmount <= a) {
            gQuantity += nAmount / p; 
            gAmount += nAmount;
            return false; // break loop
        }
        gAmount += a;
        gQuantity += q;
        return true; // continue
    });
    
    return {quantity: gQuantity, amount: gAmount};
}
```

#### Cross-Exchange Rate Analysis
```javascript
// Поиск лучших кросс-курсов через промежуточные валюты
function best_rates_cross_show(rates, from, to, cross_array) {
    // Прямые котировки
    let direct_rates = get_rate(rates, from, to);
    
    // Кросс-курсы через промежуточные валюты
    for (const cross of cross_array) {
        let r1 = get_rate(rates, from, cross);  // from -> cross
        let r2 = get_rate(rates, cross, to);    // cross -> to
        
        // Расчет эффективного курса
        let effective_bid = r1.bid * r2.bid;
        let effective_ask = r1.ask * r2.ask;
    }
}
```

### Поддерживаемые биржи - техническая детализация

#### 1. Bitfinex Integration
- **REST API v2**: `https://api-pub.bitfinex.com/v2/`
- **WebSocket**: Real-time orderbook и trade updates
- **Supported pairs**: tBTCUSD, tETHUSD, tLTCUSD, tEUTUST
- **Rate limits**: 90 requests/minute для public endpoints

#### 2. HitBTC Professional Trading
- **REST API v2**: `https://api.hitbtc.com/api/2/`
- **WebSocket**: `wss://api.hitbtc.com/api/2/ws`
- **Margin trading**: Leverage до 10x на основные пары
- **Fee structure**: Maker 0.1%, Taker 0.25%

#### 3. EXMO - Russian Market Leader
- **API Endpoint**: `https://api.exmo.com/v1/`
- **Unique advantage**: RUB trading pairs (BTC/RUB, ETH/RUB)
- **Verification levels**: Различные лимиты в зависимости от KYC
- **Payment methods**: Банковские карты, QIWI, WebMoney

#### 4. WebMoney Exchanger - Traditional Finance Bridge
- **API Base**: `https://wm.exchanger.ru/asp/`
- **Key endpoints**:
  - `JSONbestRates.asp` - Лучшие курсы
  - `JSONWMList.asp?exchtype={ID}` - Конкретные пары
- **Supported currencies**: WMZ(USD), WMR(RUB), WME(EUR), WMX(BTC), WML(LTC), WMH(BCH), WMG(Gold)

#### 5. INDX - Crypto-WebMoney Bridge
- **Niche role**: Единственный мост между криптовалютами и WebMoney
- **Low volume**: Подходит для тестирования стратегий
- **Supported pairs**: BTC/WMZ, ETH/WMZ, USDT/WMZ

## Глубокий анализ торговых стратегий

### 1. WebMoney Arbitrage Engine - Core Strategy

#### Математическая модель арбитража
**Основная формула из oloop():**
```javascript
// Sell opportunity (Продать на WebMoney, купить на Bitfinex)
let sellSpread = (exchanger_wmx_ask * 1000 / bitfinex_btc_bid - 1) * 100;

// Buy opportunity (Купить на WebMoney, продать на Bitfinex)  
let buySpread = (exchanger_wmx_bid * 1000 / bitfinex_btc_ask - 1) * 100;
```

**Коэффициент 1000**: WebMoney WMX представлен в mBTC (милли-биткоинах), поэтому необходимо умножение на 1000 для конвертации в полные BTC.

#### Реальные спреды по парам (из анализа readme.txt):

**WMX/WMZ (BTC/USD) - Основная пара**:
- **Типичный спред**: 0.1-1% в нормальных условиях
- **Экстремальные возможности**: До 10% при рыночной неэффективности
- **Объем**: Высокий, позволяет операции до $10,000
- **Проблемы**: Требует постоянного движения ордеров за рынком

**WMX/WMR (BTC/RUB) - Высокорисковая пара**:
- **Типичный спред**: >10% (очень высокий!)
- **Инертность**: Российский рынок отстает от глобального на 15-30 минут
- **Валютные риски**: Волатильность рубля добавляет дополнительный риск
- **Операционная сложность**: Нужно живое управление позициями

**WME/WMZ (EUR/USD) - Валютный арбитраж**:
- **Спред**: <0.5% обычно
- **Особенность**: Перекосы до 10% при операциях "китов"
- **Benchmark**: Отклонения от курса ЦБ РФ
- **Долгосрочность**: Позиции можно держать дни/недели

### 2. Advanced Cross-Rate Triangular Arbitrage

#### Реализация в modules.js
```javascript
function best_rates_cross_show(rates, from, to, cross_array) {
    // Анализ прямых путей
    let direct = get_rate(rates, from, to);
    
    // Анализ треугольных путей
    cross_array.forEach(cross => {
        let leg1 = get_rate(rates, from, cross);  // RUR -> EUR
        let leg2 = get_rate(rates, cross, to);    // EUR -> BTC
        
        // Эффективный курс = произведение курсов
        let triangular_rate = leg1.bid * leg2.bid;
        let arbitrage_opportunity = triangular_rate / direct.ask - 1;
    });
}
```

#### Profitable Triangular Patterns:
1. **RUR → EUR → BTC**: Использование EUR как промежуточной валюты
2. **RUR → USD → BTC**: Классический путь через доллар  
3. **RUR → XAU → BTC**: Через золото (WMG) при валютной нестабильности

### 3. Market Making Strategy - Liquidity Provision

#### Концепция из readme.txt:
```
"По сути мы выставляем в стакан заявки, чтобы они были на первом месте и ждем как рыбак рыбку"
```

**Tactical Implementation**:
- **Order Positioning**: "+1 к объему чем заявка конкурента"
- **Spread Management**: Ориентация на реальные предложения с других бирж + маржа
- **Volume Scaling**: При увеличении объема → увеличение дельты
- **Competition Balance**: "Даем немного конкурентам продавать (50%) чтобы не убивать рынок"

#### Low-Liquidity Pair Strategy:
```
"В парах, где низкие объемы - стакан наполняем заявками для видимости работы, 
разбавляем разными позициями. Типа ликвидность делаем."
```

### 4. Portfolio Balancing & Risk Management

#### Основной принцип:
```javascript
// При выполнении заявки на одной бирже - 
// делаем корректировку активов на арбитражной бирже
// Поддерживаем примерно один и тот же портфель, постепенно его наращивая
```

#### Currency Allocation Strategy:
- **Base Currency**: BTC как основа для расчетов
- **Fiat Exposure**: Минимизация валютных рисков через хеджирование
- **Geographic Distribution**: Разделение активов между юрисдикциями

### 5. Time-Based Arbitrage - Regional Lag Exploitation

#### Инертность рынков (из readme.txt):
```
"Основная прибыль появляется за счет инертности между пользователями всего мира 
и пользователями webmoney(России)"
```

**Temporal Patterns**:
- **Asian Session**: WebMoney более активен, больше возможностей
- **European Hours**: Максимальная ликвидность на EUR парах
- **US Market**: Синхронизация с Bitfinex/HitBTC

#### Lag Exploitation Strategy:
1. **Price Discovery Delay**: WebMoney отстает на 2-5 минут от глобальных бирж
2. **Volume Surge Detection**: Крупные движения на Bitfinex → предвосхищение на WebMoney
3. **News Reaction**: Медленная реакция российского рынка на новости

### 6. Volatility-Dependent Strategy Selection

#### Strategy Matrix из hummingbot README:
```
Низкая волатильность: DEX ↔ CEX арбитраж
Высокая волатильность: CEX ↔ PERPETUAL арбитраж  
```

**Implementation Logic**:
- **VIX-like Indicator**: Расчет волатильности на основе спредов
- **Strategy Switching**: Автоматическое переключение стратегий
- **Risk Scaling**: Размер позиций обратно пропорционален волатильности

## Технические особенности

### Система мониторинга
- Real-time отслеживание спредов между биржами
- Автоматические уведомления о арбитражных возможностях
- Логирование всех операций для анализа

### Управление рисками
- Автоматические стоп-лоссы
- Лимиты на размер позиций
- Диверсификация активов между биржами

### API интеграции
- Стандартизированные коннекторы для всех бирж
- Обработка ошибок и переподключения
- Rate limiting для соблюдения ограничений API

## Экономическая модель

### Источники прибыли:
1. **Спред capture**: 0.1-10% за операцию в зависимости от пары
2. **Market making**: Постоянный доход от предоставления ликвидности
3. **Timing arbitrage**: Использование временных лагов между регионами
4. **Volume discounts**: Снижение комиссий при больших оборотах

### Операционные принципы:
- Поддержание сбалансированного портфеля
- Минимизация времени экспозиции к риску
- Автоматическая корректировка позиций
- Реинвестирование прибыли для роста капитала

## Данные и аналитика

### Исторические данные:
- CSV файлы с историей торгов по основным парам
- Данные о спредах и объемах торгов
- Логи выполненных арбитражных операций

### Аналитические инструменты:
- Расчет эффективности различных стратегий
- Бэктестинг на исторических данных
- Прогнозирование волатильности

## Статус проекта
Экспериментальная разработка, содержащая ценные наработки в области автоматизированного трейдинга. Код требует модернизации для современного использования, но концептуальные решения остаются актуальными.

## Перспективы развития
- Интеграция с DeFi протоколами
- Поддержка новых географических рынков
- Машинное обучение для предсказания арбитражных возможностей
- Масштабирование на institutional уровень
