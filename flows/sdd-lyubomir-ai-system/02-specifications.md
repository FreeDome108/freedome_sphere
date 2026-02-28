# Specifications: Lyubomir AI Understanding System

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-02-28
> Requirements: [01-requirements.md](./01-requirements.md)

## Overview

Lyubomir AI Understanding System is a modular, extensible content analysis engine with 11 understanding types. This specification details the architecture, algorithms, interfaces, and data models for implementing the system.

**Key Design Principles:**
1. **Type Safety** - Enum-based understanding types prevent invalid states
2. **Extensibility** - Easy to add new analysis types without breaking existing code
3. **Performance** - Async operations with type-specific time budgets
4. **Confidence Scoring** - Quantifiable result reliability (0.0-1.0)
5. **Bilingual** - Russian/English support throughout

---

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| `LyubomirUnderstandingService` | Modify | Core implementation |
| `LyubomirUnderstanding` (model) | Modify | Data structure enhancements |
| `UnderstandingResult` (model) | Modify | Result structure |
| `ZelimService` | Integrate | File parsing integration |
| `ColladaService` | Integrate | File parsing integration |
| `SharedPreferences` | Use | Settings persistence |

---

## Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                  LyubomirUnderstandingService               │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Understanding Type Router                │   │
│  └──────────────────────────────────────────────────────┘   │
│         │         │         │         │         │            │
│  ┌──────▼──┐ ┌───▼────┐ ┌──▼────┐ ┌──▼────┐ ┌──▼────┐      │
│  │ Visual  │ │ Audio  │ │ Text  │ │Spatial│ │Temporal│     │
│  │ Analyzer│ │Analyzer│ │Analyzer│ │Analyzer│ │Analyzer│   │
│  └─────────┘ └────────┘ └───────┘ └───────┘ └───────┘      │
│         │         │         │         │         │            │
│  ┌──────▼──┐ ┌───▼────┐ ┌──▼────┐ ┌──▼────┐ ┌──▼────┐      │
│  │Semantic │ │Interactive│ │Emotional│ │Quantum│ │Holistic│ │
│  │Analyzer │ │Analyzer │ │Analyzer │ │Analyzer│ │Analyzer│ │
│  └─────────┘ └─────────┘ └────────┘ └───────┘ └────────┘    │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           Recommendation Engine                       │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           Settings & Persistence Layer                │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Analysis Flow

```
Content Submitted
    ↓
Detect Content Type (by extension/metadata)
    ↓
Create Understanding Record
    ↓
Route to Appropriate Analyzer
    ↓
┌─────────────────────────────────────┐
│  Type-Specific Analysis Algorithm   │
│  (Simulation → Real ML Model)       │
└─────────────────────────────────────┘
    ↓
Generate UnderstandingResult(s)
    ↓
Calculate Confidence Score
    ↓
Generate Type-Specific Recommendations
    ↓
Save to Persistence
    ↓
Update UI via ChangeNotifier
```

---

## Understanding Type Specifications

### 1. Visual Understanding

**Purpose:** Analyze images and video for visual properties

**Input:** Image/video files (.jpg, .png, .gif, .mp4)

**Analysis Algorithm:**
```
1. Extract dominant colors (top 3-5)
2. Calculate color temperature (warm/cool/neutral)
3. Measure brightness (0.0-1.0)
4. Measure contrast (0.0-1.0)
5. Detect objects (if ML model available)
6. Assess dome projection suitability
```

**Output Data Structure:**
```json
{
  "dominantColors": ["#hex1", "#hex2", "#hex3"],
  "colorTemperature": "warm|cool|neutral",
  "brightness": 0.0-1.0,
  "contrast": 0.0-1.0,
  "objects": ["object1", "object2"],
  "objectCount": int,
  "positions": [{"x": 0.0-1.0, "y": 0.0-1.0, "width": 0.0-1.0, "height": 0.0-1.0}],
  "dome_projection_suitable": boolean
}
```

**Confidence Factors:**
- Color detection accuracy: +0.3
- Object detection confidence: +0.3
- Brightness/contrast validity: +0.2
- Overall image quality: +0.2

**Timing:** 2000ms

---

### 2. Audio Understanding

**Purpose:** Analyze audio content for sonic properties

**Input:** Audio files (.mp3, .wav, .ogg)

**Analysis Algorithm:**
```
1. Extract frequency spectrum
2. Calculate average amplitude
3. Measure duration
4. Detect channel configuration
5. Assess spatial audio compatibility
6. Check for quantum resonance (anAntaSound)
```

**Output Data Structure:**
```json
{
  "frequency": float (Hz),
  "amplitude": 0.0-1.0,
  "duration": float (seconds),
  "format": "mono|stereo|surround",
  "quality": "low|medium|high",
  "sampleRate": int (Hz),
  "channels": int,
  "spatial_audio_compatible": boolean,
  "quantum_resonance_detected": boolean
}
```

**Confidence Factors:**
- Frequency detection accuracy: +0.3
- Channel detection: +0.2
- Spatial audio detection: +0.3
- Audio quality: +0.2

**Timing:** 3000ms

---

### 3. Text Understanding

**Purpose:** NLP analysis of text content

**Input:** Text files (.txt, .md, .json)

**Analysis Algorithm:**
```
1. Detect language
2. Count words
3. Analyze sentiment (-1.0 to 1.0)
4. Extract keywords
5. Assess readability
6. Determine complexity level
```

**Output Data Structure:**
```json
{
  "wordCount": int,
  "language": "en|ru|...",
  "sentiment": -1.0 to 1.0,
  "emotions": ["emotion1", "emotion2"],
  "keywords": ["keyword1", "keyword2"],
  "complexity": "low|medium|high",
  "readabilityScore": 0.0-1.0
}
```

**Confidence Factors:**
- Language detection: +0.4
- Sentiment analysis: +0.3
- Keyword extraction: +0.3

**Timing:** 1000ms

---

### 4. Spatial Understanding

**Purpose:** Analyze 3D models for spatial properties

**Input:** 3D model files (.zelim, .dae, .blend)

**Analysis Algorithm:**
```
1. Parse 3D file format
2. Extract geometry (vertices, faces)
3. Identify materials
4. Check UV mapping
5. Assess dome optimization
6. Detect quantum elements (ZELIM only)
```

**Output Data Structure:**
```json
{
  "vertices": int,
  "faces": int,
  "materials": ["material1", "material2"],
  "dimensions": {"width": float, "height": float, "depth": float},
  "objects": [{"type": string, "position": {"x": float, "y": float, "z": float}}],
  "lighting": "ambient|directional|point|...",
  "uv_mapping_valid": boolean,
  "dome_optimized": boolean,
  "quantum_elements_detected": int
}
```

**Confidence Factors:**
- Geometry validity: +0.3
- Material detection: +0.2
- UV mapping check: +0.3
- Dome optimization: +0.2

**Timing:** 4000ms

---

### 5. Temporal Understanding

**Purpose:** Analyze time-based content

**Input:** Video files (.mp4, .mov, .avi)

**Analysis Algorithm:**
```
1. Extract duration
2. Identify keyframes
3. Detect transitions
4. Analyze time flow (forward/reverse/variable)
5. Calculate frame rate
```

**Output Data Structure:**
```json
{
  "timeFlow": "forward|reverse|variable",
  "duration": float (seconds),
  "fps": float,
  "keyframes": [int, int, ...],
  "transitions": ["fade", "slide", "zoom"],
  "frameCount": int
}
```

**Confidence Factors:**
- Duration accuracy: +0.3
- Keyframe detection: +0.3
- Transition detection: +0.2
- FPS accuracy: +0.2

**Timing:** 3500ms

---

### 6. Semantic Understanding

**Purpose:** Analyze meaning and concepts

**Input:** Any content type (uses metadata)

**Analysis Algorithm:**
```
1. Extract concepts/themes
2. Determine context (domain)
3. Calculate relevance score
4. Identify relationships
5. Generate meaning summary
```

**Output Data Structure:**
```json
{
  "meaning": "text summary",
  "concepts": ["concept1", "concept2"],
  "context": "domain/field",
  "relevance": 0.0-1.0,
  "relationships": [{"from": string, "to": string, "type": string}]
}
```

**Confidence Factors:**
- Concept extraction: +0.3
- Context accuracy: +0.3
- Relevance calculation: +0.2
- Relationship mapping: +0.2

**Timing:** 2500ms

---

### 7. Interactive Understanding

**Purpose:** Analyze interactivity and UX

**Input:** Interactive content (VR apps, web)

**Analysis Algorithm:**
```
1. Identify interaction types
2. Measure responsiveness
3. Assess accessibility
4. Evaluate user experience
5. Count interaction points
```

**Output Data Structure:**
```json
{
  "interactions": ["click", "hover", "drag", "gesture"],
  "responsiveness": 0.0-1.0,
  "userExperience": "poor|fair|good|excellent",
  "accessibility": boolean,
  "interactionCount": int,
  "averageResponseTime": float (ms)
}
```

**Confidence Factors:**
- Interaction detection: +0.3
- Responsiveness measurement: +0.3
- Accessibility check: +0.2
- UX assessment: +0.2

**Timing:** 3500ms

---

### 8. Emotional Understanding

**Purpose:** Analyze emotional impact

**Input:** Media content

**Analysis Algorithm:**
```
1. Detect emotions present
2. Measure intensity
3. Determine valence (positive/negative/neutral)
4. Identify emotional arcs (for temporal content)
```

**Output Data Structure:**
```json
{
  "emotions": ["joy", "sadness", "anger", "fear", "surprise", "disgust"],
  "intensity": 0.0-1.0,
  "valence": "positive|negative|neutral",
  "emotionalArc": [{"time": float, "emotion": string, "intensity": float}]
}
```

**Confidence Factors:**
- Emotion detection: +0.4
- Intensity accuracy: +0.3
- Valence determination: +0.3

**Timing:** 2000ms

---

### 9. Quantum Understanding

**Purpose:** Analyze quantum properties (ZELIM-specific)

**Input:** ZELIM files, quantum content

**Analysis Algorithm:**
```
1. Measure coherence
2. Detect entanglement
3. Identify superposition states
4. Calculate quantum metrics
5. Assess quantum-classical boundary
```

**Output Data Structure:**
```json
{
  "coherence": 0.0-1.0,
  "entanglement": boolean,
  "superposition": ["state1", "state2"],
  "quantumCount": int,
  "decoherenceTime": float (ms),
  "fidelity": 0.0-1.0
}
```

**Confidence Factors:**
- Coherence measurement: +0.3
- Entanglement detection: +0.3
- Superposition identification: +0.2
- Fidelity calculation: +0.2

**Timing:** 5000ms

---

### 10. Holistic Understanding

**Purpose:** Analyze whole-system properties

**Input:** Complete projects, multi-file content

**Analysis Algorithm:**
```
1. Assess wholeness/completeness
2. Count interconnections
3. Identify emergent properties
4. Evaluate system integration
5. Calculate holistic score
```

**Output Data Structure:**
```json
{
  "wholeness": 0.0-1.0,
  "interconnections": int,
  "emergentProperties": ["property1", "property2"],
  "systemIntegration": "poor|fair|good|excellent",
  "holisticScore": 0.0-1.0,
  "componentCount": int
}
```

**Confidence Factors:**
- Wholeness assessment: +0.3
- Interconnection mapping: +0.3
- Emergent property detection: +0.2
- Integration evaluation: +0.2

**Timing:** 4500ms

---

### 11. ThreeDimensional Understanding

**Purpose:** Specialized 3D content analysis

**Input:** 3D models, scenes

**Analysis Algorithm:**
```
1. Count vertices and faces
2. Analyze LOD levels
3. Check material quality
4. Assess dome compatibility
5. Evaluate optimization level
```

**Output Data Structure:**
```json
{
  "vertices": int,
  "faces": int,
  "materials": [{"name": string, "type": string}],
  "lodLevels": int,
  "domeCompatible": boolean,
  "optimizationLevel": "low|medium|high",
  "boundingBox": {"min": {"x": float, "y": float, "z": float}, "max": {...}},
  "manifold": boolean
}
```

**Confidence Factors:**
- Geometry analysis: +0.3
- LOD detection: +0.2
- Material analysis: +0.2
- Dome compatibility: +0.3

**Timing:** 4000ms

---

## Recommendation Engine Specifications

### Recommendation Generation Rules

**For Each Type:**

#### Visual Recommendations
```
IF brightness < 0.5:
  ADD "Увеличьте яркость для лучшей видимости в куполе"
IF contrast < 0.6:
  ADD "Увеличьте контраст для темных планетариев"
IF dome_projection_suitable == false:
  ADD "Рассмотрите применение рыбий глаз проекции"
ADD "Используйте HDR тональное отображение"
```

#### Spatial Recommendations
```
IF vertices > 10000:
  ADD "Рассмотрите оптимизацию полигонов для купольной проекции"
IF uv_mapping_valid == false:
  ADD "Проверьте UV-маппинг для корректного отображения текстур"
IF quantum_elements_detected > 0:
  ADD "Проверьте квантовые резонансы для anAntaSound интеграции"
```

#### Audio Recommendations
```
IF spatial_audio_compatible == false:
  ADD "Настройте пространственное аудио для купольной акустики"
IF quantum_resonance_detected == true:
  ADD "Используйте квантовые резонансы anAntaSound"
IF channels < 8:
  ADD "Рассмотрите многоканальную настройку для купола"
```

#### Confidence-Based Recommendations
```
IF average_confidence < 0.7:
  ADD "Рекомендуется дополнительная обработка для повышения качества"
IF average_confidence > 0.9:
  ADD "Отличное качество! Готово к использованию в производстве"
```

---

## Interfaces

### Service Interface

```dart
abstract class ILyubomirUnderstandingService extends ChangeNotifier {
  // State getters
  bool get isInitialized;
  bool get isEnabled;
  LyubomirSettings get settings;
  List<LyubomirUnderstanding> get understandings;
  int get totalAnalyzed;
  double get successRate;
  DateTime? get lastAnalysisTime;
  
  // Lifecycle
  Future<void> initialize();
  Future<void> dispose();
  
  // Understanding CRUD
  Future<LyubomirUnderstanding> createUnderstanding({...});
  void deleteUnderstanding(String id);
  LyubomirUnderstanding? getUnderstanding(String id);
  
  // Analysis
  Future<void> analyzeContent(String id, {String? filePath});
  Future<LyubomirUnderstanding?> autoAnalyzeFile(String filePath);
  Future<void> analyzeZelimDirectory(String path);
  Future<void> analyzeSamskaraModels(String path);
  
  // Recommendations
  List<String> getRecommendations(String id);
  
  // Settings
  Future<void> updateSettings(LyubomirSettings settings);
  Future<void> resetToDefaults();
  Future<void> clearAllData();
  
  // Export/Import
  Future<String> exportAnalysisResults(String format);
  Future<void> importAnalysisResults(String data);
}
```

---

## Error Handling

### Error Types

| Error | Cause | Response |
|-------|-------|----------|
| `UnderstandingNotFoundException` | Invalid understanding ID | Return null, log warning |
| `AnalysisTimeoutException` | Analysis > 10 seconds | Timeout, allow retry |
| `FileNotFoundException` | File path invalid | Create error result |
| `UnsupportedFormatException` | Unknown file type | Return null from autoAnalyze |
| `StorageQuotaExceededException` | SharedPreferences full | Warn user, offer cleanup |
| `AnalysisException` | Analysis algorithm failure | Create error result with message |

### Error Result Pattern

```dart
UnderstandingResult(
  id: _generateId(),
  confidence: 0.0,
  type: understandingType,
  status: UnderstandingStatus.error,
  timestamp: DateTime.now(),
  tags: ['ошибка', 'анализ'],
  data: {'error': 'Error message here'},
)
```

---

## Testing Strategy

### Unit Tests

- [ ] Each understanding type analyzer
- [ ] Confidence score calculation
- [ ] Recommendation generation
- [ ] Settings serialization/deserialization
- [ ] Auto-analysis file type detection
- [ ] Export/import functionality

### Integration Tests

- [ ] Full analysis workflow
- [ ] Multi-type analysis
- [ ] Settings persistence
- [ ] ChangeNotifier updates

### Performance Tests

- [ ] Analysis timing per type
- [ ] Memory usage during batch analysis
- [ ] Cache hit rate

---

## Open Design Questions

- [ ] **ML Model Integration:** Which ML models for real analysis?
- [ ] **Custom Types:** Allow user-defined understanding types?
- [ ] **Cloud Processing:** Offload heavy analysis to cloud?
- [ ] **Result Expiration:** Should cached results expire?
- [ ] **Batch Analysis:** Optimize for analyzing 100+ files?

---

## Approval

- [ ] Reviewed by: _pending_
- [ ] Approved on: _pending_
- [ ] Notes: _pending_
