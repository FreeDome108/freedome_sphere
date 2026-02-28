# Specifications: FreeDome User Experience

> Version: 1.0 | Status: DRAFT | Last Updated: 2026-02-28

## Overview

Material Design 3-based UI with color-coded status, real-time updates, and accessibility.

## Screens

### 1. FreedomeIntegrationScreen

**Components:**
- Status cards (Initialization, Connection, Calibration)
- Server configuration form
- Calibration buttons (Audio/Video)
- System information panel

**State Flow:**
```
Initializing → Ready → Connecting → Connected → Calibrating → Complete
```

### 2. LyubomirLearningSystemScreen

**Tabs:**
1. **Understandings** - List with CRUD
2. **Analysis** - Results viewer
3. **Settings** - Configuration

### 3. Settings Panels

**FreeDome Settings:**
- Server URL, port
- Connection timeout
- Auto-reconnect

**Lyubomir Settings:**
- Enabled types
- Sensitivity
- Auto-analyze toggle

## Color System

| Status | Color | Usage |
|--------|-------|-------|
| Success | Green (#4CAF50) | Connected, completed |
| Warning | Orange (#FF9800) | Connecting, processing |
| Error | Red (#F44336) | Disconnected, failed |
| Info | Blue (#2196F3) | Available, idle |

## Accessibility

- Contrast ratio ≥ 4.5:1
- Screen reader support
- Keyboard navigation
- Font size scaling

---

## Approval

- [ ] Reviewed: _pending_
- [ ] Approved: _pending_
