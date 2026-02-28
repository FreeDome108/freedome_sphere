# Specifications: FreeDome Manager Integration

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-02-28
> Requirements: [01-requirements.md](./01-requirements.md)

## Overview

FreeDome Manager is a comprehensive dome display management system built with Flutter that provides:
1. **Integration Layer** - Abstraction over FreeDome ecosystem APIs
2. **Calibration System** - Automated audio/video calibration for dome environments
3. **AI Understanding** - Lyubomir system for intelligent content analysis
4. **User Interface** - Intuitive controls for artists and operators

This specification documents the architectural design, interfaces, data models, and behavior derived from the requirements analysis and existing codebase.

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| `FreedomeIntegrationService` | Modify | Enhance with additional features |
| `FreedomeCalibration` | Modify | Extend calibration capabilities |
| `LyubomirUnderstandingService` | Modify | Complete implementation |
| `FreedomeIntegrationScreen` | Modify | Enhance UI/UX |
| `LyubomirLearningSystemScreen` | Modify | Complete UI implementation |
| API Stubs | Replace | Transition to real FreeDome packages |
| Test Suite | Extend | Add comprehensive test coverage |

## Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
├─────────────────────────────────────────────────────────────┤
│  FreedomeIntegrationScreen  │  LyubomirLearningSystemScreen │
│  SettingsPanel              │  UnderstandingDetailsScreen   │
└──────────────┬────────────────────────────────┬──────────────┘
               │                                │
┌──────────────▼────────────────────────────────▼──────────────┐
│                     Service Layer                             │
├─────────────────────────────────────────────────────────────┤
│  FreedomeIntegrationService  │  LyubomirUnderstandingService│
│  - FreedomeCore              │  - ZelimService              │
│  - FreedomeCalibration       │  - ColladaService            │
│  - FreedomeConnectivity      │  - Analysis Engines          │
└──────────────┬────────────────────────────────┬──────────────┘
               │                                │
┌──────────────▼────────────────────────────────▼──────────────┐
│                      Data Layer                               │
├─────────────────────────────────────────────────────────────┤
│  SharedPreferences            │  File System                 │
│  - Settings                   │  - .zelim files              │
│  - Understandings             │  - .dae files                │
│  - Cache                      │  - Media files               │
└─────────────────────────────────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────────────────┐
│                  External Systems                             │
├─────────────────────────────────────────────────────────────┤
│  FreeDome API (stubs → real)  │  Blender Export              │
│  - Core                       │  - .zelim format             │
│  - Calibration                │  - .dae (COLLADA)            │
│  - Connectivity               │  - Standard formats          │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

#### Initialization Flow
```
User Opens App
    ↓
Initialize FreedomeIntegrationService
    ↓
Initialize FreedomeCore → FreedomeCalibration → FreedomeConnectivity
    ↓
Load Settings from SharedPreferences
    ↓
Load Existing Understandings
    ↓
UI Displays Status (Ready/Connected)
```

#### Content Analysis Flow
```
User Requests Analysis (file or manual)
    ↓
Detect Content Type (extension/metadata)
    ↓
Create Understanding Record
    ↓
Route to Appropriate Analysis Engine
    ↓
Perform Analysis (1-5 seconds)
    ↓
Generate UnderstandingResults
    ↓
Calculate Confidence Scores
    ↓
Generate Recommendations
    ↓
Save to SharedPreferences
    ↓
Update UI with Results
```

#### Calibration Flow
```
User Requests Calibration (Audio/Video)
    ↓
Scan Available Devices
    ↓
Run Calibration Algorithm
    ↓
Measure Performance Metrics
    ↓
Generate CalibrationResult
    ↓
Apply Optimal Settings
    ↓
Display Results to User
```

## Interfaces

### Core Service Interface

```dart
/// Main integration service for FreeDome ecosystem
abstract class IFreedomeIntegrationService extends ChangeNotifier {
  // State
  bool get isInitialized;
  bool get isConnected;
  ConnectionStatus get connectionStatus;
  
  // Lifecycle
  Future<void> initialize();
  Future<bool> connect({String? serverUrl, int? port, Map<String, dynamic>? options});
  Future<void> disconnect();
  void dispose();
  
  // Calibration
  Future<CalibrationResult> calibrateAudio({List<String>? devices, Map<String, dynamic>? options});
  Future<CalibrationResult> calibrateVideo({Map<String, dynamic>? settings, Map<String, dynamic>? options});
  Future<List<DeviceInfo>> getAvailableDevices();
  
  // Operations
  Future<void> sendData(Map<String, dynamic> data);
  Future<SystemStatus> getSystemStatus();
}
```

### Understanding Service Interface

```dart
/// AI-powered content understanding service
abstract class ILyubomirUnderstandingService extends ChangeNotifier {
  // State
  bool get isInitialized;
  bool get isEnabled;
  LyubomirSettings get settings;
  List<LyubomirUnderstanding> get understandings;
  int get totalAnalyzed;
  double get successRate;
  
  // Lifecycle
  Future<void> initialize();
  Future<void> dispose();
  
  // Understanding Management
  Future<LyubomirUnderstanding> createUnderstanding({
    required String name,
    required String description,
    required UnderstandingType type,
    Map<String, dynamic>? metadata,
  });
  Future<void> deleteUnderstanding(String id);
  LyubomirUnderstanding? getUnderstanding(String id);
  
  // Analysis
  Future<void> analyzeContent(String understandingId, {String? filePath});
  Future<LyubomirUnderstanding?> autoAnalyzeFile(String filePath);
  Future<void> analyzeZelimDirectory(String directoryPath);
  Future<void> analyzeSamskaraModels(String samskaraPath);
  
  // Recommendations
  List<String> getRecommendations(String understandingId);
  
  // Settings
  Future<void> updateSettings(LyubomirSettings settings);
  Future<void> resetToDefaults();
  Future<void> clearAllData();
  
  // Export
  Future<String> exportAnalysisResults(String format);
}
```

### Understanding Result Interface

```dart
/// Result of content analysis
abstract class IUnderstandingResult {
  String get id;
  UnderstandingType get type;
  double get confidence;  // 0.0 to 1.0
  Map<String, dynamic> get data;
  UnderstandingStatus get status;
  DateTime get timestamp;
  List<String> get tags;
  
  Map<String, dynamic> toJson();
  factory IUnderstandingResult.fromJson(Map<String, dynamic> json);
}
```

## Data Models

### Core Models

```dart
/// Connection status enumeration
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// Calibration result
class CalibrationResult {
  final bool success;
  final String status;        // Human-readable status
  final Map<String, dynamic>? data;  // Calibration metrics
  final String? error;        // Error message if failed
  
  // Example data fields:
  // Audio: sampleRate, channels, latency, devices
  // Video: resolution, fps, projection, brightness, contrast
}

/// System status
class SystemStatus {
  final bool isRunning;
  final Map<String, dynamic> info;      // version, platform, uptime, etc.
  final List<String> activeServices;    // List of running services
}

/// Device information
class DeviceInfo {
  final String id;
  final String name;
  final String type;          // 'audio' or 'video'
  final bool isAvailable;
}
```

### Understanding Models

```dart
/// Understanding type enumeration
enum UnderstandingType {
  visual,           // Image/video analysis
  audio,            // Sound analysis
  text,             // NLP analysis
  spatial,          // 3D model analysis
  temporal,         // Time-based analysis
  semantic,         // Meaning analysis
  interactive,      // UX analysis
  emotional,        // Emotional impact
  quantum,          // Quantum properties
  holistic,         // Whole-system analysis
  threedimensional, // Specialized 3D content
}

/// Understanding status
enum UnderstandingStatus {
  pending,      // Awaiting analysis
  processing,   // Currently processing
  analyzing,    // Active analysis
  completed,    // Successfully completed
  optimized,    // Optimized after analysis
  idle,         // Ready for analysis
  failed,       // Failed permanently
  error,        // Error occurred
  paused,       // Temporarily paused
}

/// Understanding settings
class LyubomirSettings {
  final bool enabled;
  final double learningRate;      // 0.01 default
  final int maxIterations;        // 1000 default
  final String algorithm;         // 'quantum_neural' default
  final Map<String, dynamic> parameters;
  final bool autoAnalyze;         // Auto-analyze new content
  final double sensitivity;       // 0.7 default
  final List<UnderstandingType> enabledTypes;
}

/// Main understanding entity
class LyubomirUnderstanding {
  final String id;
  final String name;
  final String description;
  final UnderstandingType type;
  final UnderstandingStatus status;
  final double confidence;        // Overall confidence 0.0-1.0
  final Map<String, dynamic> metadata;
  final List<UnderstandingResult> results;
  final DateTime created;
  final DateTime updated;
  final DateTime? createdAt;
  final DateTime? lastAnalyzed;
}

/// Individual analysis result
class UnderstandingResult {
  final String id;
  final UnderstandingType type;
  final double confidence;
  final Map<String, dynamic> data;
  final UnderstandingStatus status;
  final DateTime timestamp;
  final List<String> tags;
}
```

### Example Result Data Structures

```dart
// Visual Analysis Result
{
  'dominantColors': ['#FF6B6B', '#4ECDC4', '#45B7D1'],
  'colorTemperature': 'warm',
  'brightness': 0.7,
  'contrast': 0.8,
  'objects': ['person', 'building', 'tree'],
  'count': 3,
  'positions': [{'x': 0.3, 'y': 0.4, 'width': 0.2, 'height': 0.3}]
}

// Audio Analysis Result
{
  'frequency': 440.0,
  'amplitude': 0.6,
  'duration': 120.5,
  'format': 'stereo',
  'quality': 'high',
  'spatial_audio_compatible': true,
  'quantum_resonance_detected': false
}

// Spatial Analysis Result
{
  'dimensions': {'width': 10, 'height': 10, 'depth': 10},
  'objects': [
    {'type': 'sphere', 'position': {'x': 0, 'y': 0, 'z': 0}, 'radius': 5}
  ],
  'lighting': 'ambient',
  'materials': ['metal', 'glass'],
  'vertices': 2847,
  'faces': 5694,
  'dome_optimized': true
}

// Text Analysis Result
{
  'sentiment': 'positive',
  'emotions': ['joy', 'excitement'],
  'keywords': ['любомир', 'понимание', 'анализ'],
  'language': 'ru',
  'complexity': 'medium',
  'word_count': 150
}
```

## Behavior Specifications

### Happy Path

#### Initialization
1. User opens FreeDome Integration screen
2. System automatically initializes all components
3. Status indicators show "Initialized" (green)
4. User can proceed to connect or calibrate

#### Connection
1. User enters server URL and port
2. User presses "Connect" button
3. Status changes to "Connecting..." (orange)
4. Connection established within 3 seconds
5. Status changes to "Connected" (green)
6. System information becomes available

#### Audio Calibration
1. User presses "Calibrate Audio" button
2. System scans available audio devices
3. Calibration runs for 2-3 seconds
4. Results displayed with metrics (sample rate, channels, latency)
5. Success message shown (green)

#### Video Calibration
1. User presses "Calibrate Video" button
2. System analyzes video settings
3. Calibration runs for 3-4 seconds
4. Results displayed (resolution, FPS, projection type)
5. Success message shown (green)

#### Content Analysis
1. User creates new understanding or imports file
2. System detects content type automatically
3. Analysis runs for 1-5 seconds (type-dependent)
4. Results displayed with confidence scores
5. Recommendations generated based on analysis

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| Not Initialized | User tries to connect before init | Show error: "Initialize first" |
| Connection Failed | Server unavailable | Show error, status = error (red) |
| Calibration Failed | No devices found | Show error with recovery suggestions |
| Analysis Timeout | Analysis > 10 seconds | Timeout with error, allow retry |
| File Not Found | Auto-analyze missing file | Create error result, notify user |
| Unsupported Format | Unknown file extension | Return null from autoAnalyzeFile |
| Storage Full | Cannot save understandings | Show warning, clear cache option |
| Memory Pressure | Low memory scenario | GC, reduce cache, warn user |

### Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `Exception('FreeDome not initialized')` | Missing initialize() call | User message + auto-initialize option |
| `Exception('FreeDome not connected')` | Missing connect() call | User message + connect prompt |
| `CalibrationException('No devices')` | Hardware not detected | List troubleshooting steps |
| `AnalysisException('Unknown type')` | Unsupported content | Graceful fallback, log warning |
| `StorageException('Quota exceeded')` | SharedPreferences full | Clear old data prompt |
| `NetworkException('Timeout')` | Network unreachable | Retry with backoff |

## Dependencies

### Requires

- Flutter SDK 3.x or later
- `provider` package for state management
- `shared_preferences` for persistence
- `path` package for file operations
- FreeDome packages (currently stubs)

### Blocks

- Dome content playback system
- Automated publishing workflow
- MBHARATA platform integration
- anAntaSound quantum audio processing

## Integration Points

### External Systems

#### FreeDome Ecosystem
- **FreedomeCore**: Main dome control and data management
- **FreedomeCalibration**: Audio/video calibration algorithms
- **FreedomeConnectivity**: Network communication with dome systems

#### File Formats
- **ZELIM**: Quantum 3D model format (.zelim files)
- **COLLADA**: 3D interchange format (.dae files from samskara)
- **Standard Media**: Images, video, audio, text files

#### Development Tools
- **Blender**: 3D modeling tool (export target)
- **Quest 3**: Primary deployment platform

### Internal Systems

#### ZelimService
- Parses .zelim quantum 3D model files
- Extracts geometry, materials, quantum elements
- Provides dome compatibility analysis

#### ColladaService
- Parses COLLADA (.dae) files
- Extracts 3D model data
- Integrates with samskara pipeline

## Testing Strategy

### Unit Tests

- [ ] `FreedomeCore` - Initialization, data sending, status retrieval
- [ ] `FreedomeCalibration` - Audio/video calibration algorithms
- [ ] `FreedomeConnectivity` - Connection lifecycle, status streams
- [ ] `LyubomirUnderstandingService` - Analysis algorithms per type
- [ ] `LyubomirSettings` - Serialization/deserialization
- [ ] `UnderstandingResult` - Data structure validation

### Integration Tests

- [ ] Full initialization flow
- [ ] Connection → Calibration → Analysis workflow
- [ ] File auto-analysis pipeline
- [ ] UI state updates via ChangeNotifier
- [ ] SharedPreferences persistence

### Manual Verification

- [ ] UI responsiveness on Quest 3
- [ ] Calibration accuracy with real hardware
- [ ] Analysis quality across content types
- [ ] Error handling in all failure scenarios
- [ ] Bilingual text display (Russian/English)

## Migration / Rollout

### Phase 1: Current (Stubs)
- All FreeDome components implemented as stubs
- Simulation delays mimic real behavior
- Ready for real package integration

### Phase 2: Hybrid
- Gradual replacement of stubs with real packages
- Feature flags for stub vs. real
- Backward compatibility maintained

### Phase 3: Production
- All stubs replaced
- Real hardware calibration
- Full dome integration

## Open Design Questions

- [ ] **Package Structure**: Should this be a monolithic package or modular (core, calibration, understanding separate)?
- [ ] **State Persistence**: SharedPreferences vs. SQLite vs. cloud sync?
- [ ] **Analysis Extensibility**: Plugin architecture for custom analysis types?
- [ ] **Real-time Collaboration**: Multiple users analyzing same content?
- [ ] **Offline Mode**: Full functionality without network vs. limited mode?

---

## Approval

- [ ] Reviewed by: _pending_
- [ ] Approved on: _pending_
- [ ] Notes: _pending_

---

## Appendix: Analysis Time Specifications

| Understanding Type | Simulation Time | Real Expected Time |
|-------------------|-----------------|-------------------|
| Visual | 2000ms | 500-2000ms |
| Audio | 3000ms | 1000-3000ms |
| Text | 1000ms | 100-500ms |
| Spatial | 4000ms | 2000-5000ms |
| Temporal | 3500ms | 1000-3000ms |
| Semantic | 2500ms | 500-2000ms |
| Interactive | 3500ms | 1000-3000ms |
| Emotional | 2000ms | 500-1500ms |
| Quantum | 5000ms | 3000-8000ms |
| Holistic | 4500ms | 2000-6000ms |
| ThreeDimensional | 4000ms | 2000-5000ms |
