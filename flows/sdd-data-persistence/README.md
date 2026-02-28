# FreeDome Data Persistence

> **Надежное хранение данных** | **Reliable Data Storage**

## 📖 Overview

SharedPreferences-based persistence with JSON export/import and LRU caching.

## 🔧 Features

- **Settings Persistence** - Lyubomir, FreeDome configurations
- **Export/Import** - JSON and CSV formats
- **LRU Caching** - Analysis result caching
- **Migration** - Schema versioning and updates

## 🚀 Usage

```dart
// Export understandings
final json = await service.exportAnalysisResults('json');
final csv = await service.exportAnalysisResults('csv');

// Import data
await service.importAnalysisResults(json);

// Cache usage
cache.put('key', result, ttl: Duration(hours: 24));
final cached = cache.get('key');
```

## 📊 Storage

- **SharedPreferences:** Settings, small data
- **File System:** Exports, backups
- **Memory:** LRU cache

---

**Last Updated:** 2026-02-28
