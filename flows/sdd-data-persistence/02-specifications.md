# Specifications: FreeDome Data Persistence

> Version: 1.0 | Status: DRAFT

## Architecture

```
┌─────────────────────────────────────┐
│         Persistence Layer            │
├─────────────────────────────────────┤
│  SharedPreferences  │  File System  │
│  - Settings         │  - Exports    │
│  - Cache            │  - Backups    │
└─────────────────────────────────────┘
```

## Data Models

### Settings
```json
{
  "lyubomir": { "enabled": true, "sensitivity": 0.7 },
  "freedome": { "serverUrl": "localhost", "port": 8080 }
}
```

### Export Format
```json
{
  "export_info": { "timestamp": "...", "format": "json" },
  "understandings": [...],
  "calibrations": [...]
}
```

## Caching Strategy

- LRU (Least Recently Used)
- Max 100 items
- TTL: 24 hours
- Memory-efficient

---

**Approval:** _pending_
