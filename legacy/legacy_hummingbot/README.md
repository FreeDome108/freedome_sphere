# План
* максимально быстрый запуск в работу
первый тейкер и первый мейкер из списка
конфиг как сейчас
* сейчас закрывается внутри position executor

Задачи позже
* Конфиг с мульти рынками внутрь dman
* expire_min_profit
* умные рекурсивные конфиги

Верхнеуровнево - делаем лимитники на N оюменниках, смысла делать лимитники внутри нет. Если будут позиции верхнуровнево в разных направлениях - схлопываем их там.
Внутри делаем только маркет ордеры

В данный момент делаем базовую реализацию, что тэйкер только один.
Позиции закрываем сразу

1 cemm wb -> okx
2 cemm okx -> wb
3 perp wb -> binance_perp (hb-perp)
4 perp okx -> binance_perp (hb3)

https://github.com/QuantGeekDev/custom-arbitrage-bot/blob/master/hummingbot/strategy/dev_1_get_order_book/dev_1_get_order_book.py




Flow: DEX -> CEX -> PERPETUAL

DEX -> CEX or CEX -> CEX gives profit when volatility is low
CEX -> PERPETUAL gives profit when volatility is high

Если на бирже большой спред - это шанс поставить нормальный лимитники, откупить их и делать market making.
Тем не менее биржа должна быть живая и хорошо, елси там не хватает ликвидности и кто-то двигает рынок.

Так же есть смысл в DEX обменниках, поскольку они менее волатильны и проще делать marketmaking на CEX


ERC20/TRC20

Ликвидность страдает:
XMR - monero - сильно
XRP - ripple
LTC
USDT

zcash - странный

Отдельно - 
solana-200тр, 50 MNR - просадка.

TRON
SOLANA
USDT
USDC


Whitebit

снг биржа, ночью только боты.

XRP/USDC
XRP/BTC
XRP/USDC
"""
XRP/EUR
XRP/USD
XRP/TRY


XMR/USDT

LTC/USDT
LTC/BTC



XMR/USDT
XRP/USDT
LTC/USDT



# Installation

make certs
Start Hummingbot. After entering your password, run gateway generate-certs : Enter a secure passphrase, and write it down. Hummingbot will generate self-signed certificates that a server can use to authenticate its connection with this clie


# Legacy Hummingbot Extension

## Обзор проекта
Расширенная конфигурация Hummingbot с кастомными стратегиями, коннекторами и multi-instance архитектурой для профессиональной автоматизированной торговли на множественных биржах и DeFi протоколах.

## Архитектура системы

### Multi-instance конфигурация
Система организована для параллельного запуска 4 независимых экземпляров Hummingbot:
- **Instance 1**: CEMM WhiteBit → OKX
- **Instance 2**: CEMM OKX → WhiteBit  
- **Instance 3**: PERP WhiteBit → Binance Perpetual
- **Instance 4**: PERP OKX → Binance Perpetual

### Gateway интеграция
**DeFi протоколы**: Подключение к децентрализованным биржам через Hummingbot Gateway
- Ethereum-based DEX (Uniswap, Curve, OpenOcean)
- BSC протоколы (PancakeSwap, VVS)
- Polygon DEX (QuickSwap)
- Альтернативные сети (Avalanche, Solana, NEAR)

## Торговые стратегии

### 1. Cross-Exchange Market Making (CEMM)
**Концепция**: Арбитраж между централизованными биржами с немедленным хеджированием

#### Поддерживаемые пары:
- **Спот арбитраж**: BTC/USDT, ETH/USDT между WhiteBit/OKX
- **Региональные особенности**: СНГ биржи vs. глобальные платформы
- **Временные зоны**: Оптимизация для азиатских/европейских сессий

### 2. Spot-Perpetual Arbitrage
**Механизм**: Использование расхождений между спотом и фьючерсами

#### Стратегические направления:
- **Низкая волатильность**: Спот арбитраж с немедленным закрытием
- **Высокая волатильность**: Перп арбитраж с удержанием позиций
- **Funding rate mining**: Получение прибыли от финансирования

### 3. DEX-CEX-PERP треугольники
**Инновационная схема**: Трехстороннийарбитраж между различными типами площадок

#### Flow направления:
1. **DEX → CEX**: Низковолатильные условия
2. **CEX → PERPETUAL**: Высоковолатильные условия  
3. **DEX → PERPETUAL**: Комплексные операции

### 4. Токен-специфичные стратегии

#### Низколиквидные активы:
- **XMR (Monero)**: Повышенные спреды из-за regulatory pressure
- **XRP (Ripple)**: Арбитраж между различными листингами
- **LTC (Litecoin)**: Классический альткойн с предсказуемыми паттернами

#### Стейблкойн арбитраж:
- **USDT/USDC**: Микро-арбитраж с высокой частотой
- **Multi-chain**: Арбитраж между различными сетями (ERC20/TRC20/BSC)

## Кастомные компоненты

### Smart Components Framework
**Модульная архитектура** для сложных торговых логик:

#### Controllers:
- Высокоуровневая логика принятия решений
- Управление множественными executors
- Риск-менеджмент на портфельном уровне

#### Executors:
- Атомарные торговые операции
- Position management
- Order lifecycle management

#### Models:
- Данные и состояние системы
- Market data aggregation
- Performance metrics

### Кастомные коннекторы

#### WhiteBit коннектор:
- Полная интеграция с российской биржей
- Обработка специфичных особенностей API
- Оптимизация для региональных условий

#### Gateway расширения:
- Поддержка новых DeFi протоколов
- Cross-chain операции
- Yield farming интеграция

## Конфигурационная система

### Адаптивные настройки
- **Dynamic spread adjustment**: Автоматическая корректировка спредов
- **Market regime detection**: Определение рыночных условий
- **Risk parameter scaling**: Масштабирование под волатильность

### Multi-market конфигурации
- Параллельная работа на множественных парах
- Кросс-валютное хеджирование
- Portfolio-level position management

## Мониторинг и аналитика

### Performance tracking
- Real-time P&L мониторинг
- Sharpe ratio и других метрик риска
- Детализированная торговая статистика

### Operational monitoring
- Статус всех инстансов
- API connectivity health
- Error tracking и alerting

## Технические особенности

### Deployment архитектура
- **Docker контейнеризация**: Изоляция различных стратегий
- **Automated startup**: Скрипты для массового запуска
- **Configuration management**: Централизованная конфигурация

### Интеграционные возможности
- **Plugin система**: Модульная архитектура для расширений
- **External data feeds**: Интеграция с внешними источниками данных
- **Notification systems**: Alerts через различные каналы

## Экономическая эффективность

### Источники alpha:
1. **Geographic arbitrage**: Разница между регионами
2. **Structural inefficiencies**: Использование особенностей различных типов бирж
3. **Liquidity provision**: Доходы от маркет-мейкинга
4. **Volatility harvesting**: Адаптация к рыночным режимам

### Risk management:
- Position size limits
- Maximum drawdown controls
- Correlation-based hedging
- Dynamic leverage adjustment

## Статус проекта
Продвинутая торговая система с модульной архитектурой. Содержит уникальные решения для multi-instance управления и кросс-платформенного арбитража. Требует обновления зависимостей, но архитектурные принципы остаются актуальными.

## Развитие концепции
- Интеграция с AI/ML для предиктивной торговли
- Расширение на новые географические рынки
- Поддержка institutional-grade volume
- Соответствие evolving regulatory requirements