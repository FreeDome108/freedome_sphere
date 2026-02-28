# Specifications: FreeDome Calibration System

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-02-28
> Requirements: [01-requirements.md](./01-requirements.md)

## Overview

FreeDome Calibration System provides software-based audio/video calibration for dome environments. This specification details the calibration algorithms, interfaces, and data models.

**Key Design Principles:**
1. **Simulation First** - Safe testing without hardware
2. **Standardized Results** - Consistent CalibrationResult structure
3. **Async Operations** - Non-blocking calibration
4. **Extensible Options** - Flexible configuration via Maps
5. **Error Resilience** - Graceful failure with recovery

---

## Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                  FreedomeCalibration                        │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Calibration Controller                   │   │
│  └──────────────────────────────────────────────────────┘   │
│         │                                    │                │
│  ┌──────▼──────────────┐          ┌─────────▼────────┐      │
│  │  Audio Calibration  │          │ Video Calibration│      │
│  │      Engine         │          │     Engine       │      │
│  └─────────────────────┘          └──────────────────┘      │
│         │                                    │                │
│  ┌──────▼──────────────┐          ┌─────────▼────────┐      │
│  │  Device Detection   │          │  Measurement     │      │
│  │      (Audio)        │          │   (Video)        │      │
│  └─────────────────────┘          └──────────────────┘      │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           Calibration History & Persistence           │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Audio Calibration Specification

### Algorithm

```
1. Scan available audio devices
2. For each device:
   a. Query supported sample rates
   b. Query supported channel configurations
   c. Measure baseline latency
   d. Test spatial audio capability
3. Calculate optimal settings:
   - Sample rate: Highest supported ≤ 48000 Hz
   - Channels: Match dome configuration (default 8)
   - Latency: Minimize while maintaining stability
4. Apply settings and verify
5. Return CalibrationResult
```

### Data Structure

```json
{
  "sampleRate": 48000,
  "channels": 8,
  "latency": 12.5,
  "devices": [
    {
      "id": "audio_device_1",
      "name": "Default Audio Device",
      "type": "audio",
      "isAvailable": true,
      "capabilities": {
        "maxSampleRate": 192000,
        "maxChannels": 16,
        "spatialAudioSupported": true
      }
    }
  ],
  "spatialAudioEnabled": true,
  "quantumResonanceEnabled": false,
  "calibratedAt": "2026-02-28T12:00:00Z"
}
```

### Timing Budget

- Device scan: 500ms
- Per-device analysis: 500ms × N devices
- Optimization calculation: 500ms
- Verification: 500ms
- **Total: ~3000ms (target)**

---

## Video Calibration Specification

### Algorithm

```
1. Detect display devices
2. For each display:
   a. Query native resolution
   b. Query supported refresh rates
   c. Measure brightness/contrast baseline
   d. Detect projection type (flat/spherical/fisheye)
3. Calculate optimal settings:
   - Resolution: Native dome resolution (default 4096x2048)
   - FPS: 60 or highest supported ≤ 120
   - Brightness: 0.85 for dark domes
   - Contrast: 0.9 for better definition
4. Apply fisheye correction if spherical
5. Return CalibrationResult
```

### Data Structure

```json
{
  "resolution": "4096x2048",
  "fps": 60,
  "projection": "spherical",
  "brightness": 0.85,
  "contrast": 0.9,
  "fisheyeCorrection": true,
  "hdrEnabled": false,
  "colorSpace": "Rec.2020",
  "displays": [
    {
      "id": "video_device_1",
      "name": "Primary Display",
      "type": "video",
      "isAvailable": true,
      "nativeResolution": "4096x2048",
      "maxRefreshRate": 120
    }
  ],
  "calibratedAt": "2026-02-28T12:00:00Z"
}
```

### Timing Budget

- Display detection: 500ms
- Per-display analysis: 1000ms × N displays
- Optimization calculation: 1000ms
- Verification: 500ms
- **Total: ~4000ms (target)**

---

## Interface Specification

### Calibration Service Interface

```dart
abstract class IFreedomeCalibration {
  // Lifecycle
  Future<void> initialize();
  void dispose();
  
  // Audio Calibration
  Future<CalibrationResult> calibrateAudio({
    List<String>? devices,
    Map<String, dynamic>? options,
  });
  
  // Video Calibration
  Future<CalibrationResult> calibrateVideo({
    Map<String, dynamic>? settings,
    Map<String, dynamic>? options,
  });
  
  // Device Detection
  Future<List<DeviceInfo>> getAvailableDevices();
  
  // Calibration History (optional)
  Future<List<CalibrationRecord>> getCalibrationHistory();
  Future<void> saveCalibration(CalibrationResult result, String type);
  Future<void> clearCalibrationHistory();
}
```

### Result Classes

```dart
class CalibrationResult {
  final bool success;
  final String status;
  final Map<String, dynamic>? data;
  final String? error;
  
  CalibrationResult({
    required this.success,
    required this.status,
    this.data,
    this.error,
  });
}

class DeviceInfo {
  final String id;
  final String name;
  final String type;  // 'audio' | 'video'
  final bool isAvailable;
  final Map<String, dynamic>? capabilities;
  
  DeviceInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.isAvailable,
    this.capabilities,
  });
}

class CalibrationRecord {
  final String id;
  final String type;  // 'audio' | 'video'
  final CalibrationResult result;
  final DateTime timestamp;
  final String venue;
  
  CalibrationRecord({
    required this.id,
    required this.type,
    required this.result,
    required this.timestamp,
    required this.venue,
  });
}
```

---

## Error Handling

### Error Types

| Error | Cause | Response |
|-------|-------|----------|
| `NoDevicesException` | No devices detected | List troubleshooting steps |
| `CalibrationTimeoutException` | Calibration > 10s | Timeout, allow retry |
| `InvalidSettingsException` | Unsupported settings | Suggest defaults |
| `DeviceUnavailableException` | Device in use | Wait or select other |
| `CalibrationFailedException` | Algorithm failure | Detailed error message |

### Error Response Pattern

```dart
try {
  final result = await calibrateAudio();
  return result;
} on NoDevicesException catch (e) {
  return CalibrationResult(
    success: false,
    status: 'No audio devices detected',
    error: 'No devices found. Please check connections.',
  );
} on CalibrationTimeoutException catch (e) {
  return CalibrationResult(
    success: false,
    status: 'Calibration timed out',
    error: 'Calibration took too long. Please retry.',
  );
}
```

---

## Testing Strategy

### Unit Tests

- [ ] Audio calibration algorithm
- [ ] Video calibration algorithm
- [ ] Device detection
- [ ] Result structure validation
- [ ] Error handling

### Integration Tests

- [ ] Full calibration workflow
- [ ] Multi-device scenarios
- [ ] Error scenario handling

### Performance Tests

- [ ] Audio calibration timing (< 3s)
- [ ] Video calibration timing (< 4s)
- [ ] Memory usage (< 50MB)

---

## Open Design Questions

- [ ] **Hardware Integration:** What APIs when real packages arrive?
- [ ] **Calibration Profiles:** Share profiles between venues?
- [ ] **Auto-Calibration:** Schedule periodic recalibration?
- [ ] **Remote Calibration:** Network-based calibration support?

---

## Approval

- [ ] Reviewed by: _pending_
- [ ] Approved on: _pending_
- [ ] Notes: _pending_
