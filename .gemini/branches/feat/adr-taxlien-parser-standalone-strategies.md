# Branch ADR: adr-taxlien-parser-standalone-strategies

## Meta
- **Branch**: adr-taxlien-parser-standalone-strategies
- **Type**: feat
- **Created**: 2026-01-31
- **Status**: Active
- **Author**: Gemini

## Problem Statement
### Context
Standalone-режим (автономный воркер) требует механизма выбора задач, который не зависит от центрального Gateway API. При этом необходимо обеспечить не просто выполнение списка, но и интеллектуальное исследование данных (Ripple Effect, Discovery) и поддержание их актуальности (Chronos).

### Goals
1. Интеграция модуля `StrategyMixer` в автономный цикл воркера.
2. Обеспечение баланса между обновлением старых данных (Chronos), отработкой пользовательских сигналов (Hotspot) и поиском новых связей (Ripple).
3. Реализация независимого управления приоритетами через локальный LPM.

## Decision Record
### Options Considered
1. **Hardcoded Logic**: Вшить логику выбора задач прямо в воркер. (Просто, но не гибко).
2. **External Strategy Module**: Использовать модуль из `sdd-taxlien-parser-strategy`. (Сложнее в интеграции, но обеспечивает единый "мозг" для всех режимов).

### Decision
Выбран **Вариант 2**. Мы интегрируем `StrategyMixer` как независимую прослойку между `Worker` и `LPM`. Это позволит Standalone-воркеру использовать те же алгоритмы приоритезации, что и облачному, но на локальных данных.

## Implementation
1. В режиме `--standalone` воркер инициализирует `StrategyMixer` с набором локальных стратегий:
   - `ChronosStrategy` (локальный SQLite)
   - `RippleStrategy` (графовые связи в локальной базе)
   - `HotspotStrategy` (чтение `user_signals` из локальной таблицы)
2. Воркер запрашивает пакет задач через `Mixer.get_next_tasks(limit)`.
3. Результаты парсинга через `LPM` могут порождать новые "сигналы" или задачи, которые `Mixer` подхватит на следующем цикле.

## Outcome & Lessons
[TBD: Будет заполнено после реализации и тестирования]
