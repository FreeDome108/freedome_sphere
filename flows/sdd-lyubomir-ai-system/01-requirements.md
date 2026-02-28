# Requirements: Lyubomir AI Understanding System

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-02-28
> Author: Qwen (Code Analysis)

## Problem Statement

**What problem are we solving?**

Content creators for dome/immersive environments need intelligent analysis of their content to:
1. Understand visual, audio, spatial, and semantic properties automatically
2. Receive actionable recommendations for dome optimization
3. Analyze content without manual technical expertise
4. Support multiple content types (3D models, images, audio, video, text)

**Why does this matter?**

Manual content analysis requires:
- Multiple specialized tools (image analysis, audio analysis, 3D analysis)
- Technical expertise in each domain
- Hours of manual inspection per content piece
- No unified recommendation system for dome environments

Lyubomir provides unified AI-powered analysis with 11 understanding types, reducing analysis time from hours to seconds.

## User Stories

### Primary Users

#### 3D Artist (Yan)
**As a** 3D artist creating dome content
**I want** automatic analysis of my 3D models for dome compatibility
**So that** I know if my content will work in spherical projection without manual testing

**As a** 3D artist
**I want** recommendations for optimizing my models
**So that** I can improve quality without hiring technical specialists

#### Content Curator
**As a** content curator for planetariums
**I want** batch analysis of multiple content files
**So that** I can quickly assess my content library's suitability for dome display

**As a** curator
**I want** confidence scores on analysis results
**So that** I know which analyses are reliable vs. need manual review

### Secondary Users

#### Developer
**As a** developer
**I want** extensible understanding type system
**So that** I can add custom analysis types for specific use cases

#### Venue Operator
**As a** venue operator
**I want** analysis results in simple language
**So that** I can understand technical recommendations without expertise

## Acceptance Criteria

### Must Have

#### 1. Understanding Type System

**Given** the system is initialized
**When** a new understanding is created
**Then** it must be assigned one of 11 understanding types (Visual, Audio, Text, Spatial, Temporal, Semantic, Interactive, Emotional, Quantum, Holistic, ThreeDimensional)

**Given** an understanding type is selected
**When** analysis runs
**Then** type-specific analysis algorithm is executed

#### 2. Analysis Engine

**Given** content is submitted for analysis
**When** analysis completes
**Then** results include:
- Confidence score (0.0-1.0)
- Structured data based on type
- Timestamp
- Tags for categorization
- Status (completed/error/failed)

**Given** analysis is running
**When** progress is queried
**Then** status shows "analyzing" with appropriate timing per type:
- Text: 1 second
- Visual/Emotional: 2 seconds
- Semantic: 2.5 seconds
- Audio/Temporal/Interactive: 3-3.5 seconds
- Spatial/Holistic/ThreeDimensional: 4-4.5 seconds
- Quantum: 5 seconds

#### 3. Result Generation

**Given** analysis completes successfully
**When** results are generated
**Then** each type produces appropriate data:

| Type | Example Data Fields |
|------|---------------------|
| Visual | dominantColors, brightness, contrast, objects |
| Audio | frequency, amplitude, duration, spatial_audio_compatible |
| Text | sentiment, keywords, language, complexity |
| Spatial | dimensions, objects, materials, dome_optimized |
| Temporal | duration, keyframes, transitions |
| Semantic | meaning, concepts, context, relevance |
| Interactive | interactions, responsiveness, accessibility |
| Emotional | emotions, intensity, valence |
| Quantum | coherence, entanglement, superposition |
| Holistic | wholeness, interconnections, emergent_properties |
| ThreeDimensional | vertices, faces, materials, LOD |

#### 4. Recommendation Engine

**Given** analysis results exist
**When** recommendations are requested
**Then** type-specific recommendations are returned:

**Example (Spatial):**
- "Рассмотрите оптимизацию полигонов для купольной проекции"
- "Проверьте квантовые резонансы для anAntaSound интеграции"
- "Убедитесь в правильности UV-маппинга для сферической проекции"

**Given** confidence < 0.7
**When** recommendations generated
**Then** include: "Рекомендуется дополнительная обработка для повышения качества"

**Given** average confidence > 0.9
**When** recommendations generated
**Then** include: "Отличное качество! Готово к использованию в производстве"

#### 5. Auto-Analysis

**Given** auto-analysis is enabled
**When** a file is detected in monitored directory
**Then** content type is auto-detected by extension and analysis is triggered

**Given** file extension is .zelim/.dae
**When** auto-analysis runs
**Then** type is set to Spatial and description reflects 3D model analysis

**Given** file extension is .jpg/.png/.mp4
**When** auto-analysis runs
**Then** type is set to Visual

**Given** file extension is .mp3/.wav/.ogg
**When** auto-analysis runs
**Then** type is set to Audio

**Given** file extension is .txt/.md/.json
**When** auto-analysis runs
**Then** type is set to Text

#### 6. Settings Management

**Given** user modifies settings
**When** settings are saved
**Then** the following persist across app restarts:
- enabled (bool)
- learningRate (double, default 0.01)
- maxIterations (int, default 1000)
- algorithm (String, default 'quantum_neural')
- autoAnalyze (bool, default true)
- sensitivity (double, default 0.7)
- enabledTypes (List<UnderstandingType>)

#### 7. Export/Import

**Given** understandings exist
**When** export is requested in JSON format
**Then** valid JSON is returned with export_info, settings, and understandings

**Given** export data exists
**When** import is requested
**Then** understandings are restored with original state

### Should Have

#### Performance

- Analysis completion within type-specific time budgets (see timing above)
- Memory usage < 100MB during analysis
- No UI freezing during analysis (async operations)
- Cache hit rate > 50% for repeated analyses

#### Error Handling

- Graceful handling of missing files
- Clear error messages in Russian/English
- Retry logic for transient failures
- Fallback to simulation when real analyzers unavailable

### Won't Have (This Iteration)

- Real ML model integration (simulation only)
- Cloud-based processing
- Real-time collaborative analysis
- Custom user-defined analysis types
- Video frame-by-frame analysis
- Speech-to-text transcription

## Constraints

### Technical

- **Platform:** Flutter (iOS, Android, Quest 3)
- **State Management:** ChangeNotifier pattern
- **Persistence:** SharedPreferences
- **Language:** Dart
- **Code Comments:** Bilingual (Russian/English)

### Performance

- **Mobile:** Must run on Quest 3 (limited CPU/GPU)
- **Memory:** Efficient for mobile constraints
- **Battery:** Minimize drain during batch analysis

### Dependencies

- **ZelimService:** For .zelim file parsing
- **ColladaService:** For .dae file parsing
- **SharedPreferences:** For settings persistence
- **Path package:** For file operations

## Open Questions

### Algorithm

- [ ] What ML models will replace simulation?
- [ ] Will quantum analysis be metaphorical or use actual quantum computing?
- [ ] How to validate confidence score accuracy?

### Integration

- [ ] Should third parties create custom understanding types?
- [ ] How to integrate with external AI services (OpenAI, etc.)?
- [ ] Should analysis results be cached indefinitely or expire?

### Business

- [ ] Is Lyubomir a standalone product or feature of FreeDome Manager?
- [ ] What is the pricing model for AI analysis?
- [ ] Should there be usage limits (analyses per month)?

## References

### Internal

- `lib/services/lyubomir_understanding_service.dart` - Main implementation
- `lib/models/lyubomir_understanding.dart` - Data models
- `test/lyubomir_understanding_service_test.dart` - Tests
- `flows/sdd-freedome-manager/01-requirements.md` - Parent requirements

### External

- **ZELIM Format:** Quantum 3D model specification
- **COLLADA:** 3D asset interchange format
- **anAntaSound:** Quantum audio processing system

---

## Approval

- [ ] Reviewed by: _pending_
- [ ] Approved on: _pending_
- [ ] Notes: _pending_

---

## Appendix: Understanding Type Matrix

| Type | Input Formats | Analysis Time | Confidence Factors |
|------|---------------|---------------|-------------------|
| Visual | .jpg, .png, .gif, .mp4 | 2s | Color detection accuracy, object count |
| Audio | .mp3, .wav, .ogg | 3s | Frequency detection, spatial compatibility |
| Text | .txt, .md, .json | 1s | Language detection, sentiment accuracy |
| Spatial | .zelim, .dae, .blend | 4s | Geometry validity, material detection |
| Temporal | .mp4, .mov, .avi | 3.5s | Duration accuracy, keyframe detection |
| Semantic | All types | 2.5s | Concept extraction, context relevance |
| Interactive | VR apps, web | 3.5s | Interaction count, responsiveness |
| Emotional | Media content | 2s | Emotion detection, intensity accuracy |
| Quantum | .zelim, specialized | 5s | Coherence metrics, entanglement detection |
| Holistic | Complete projects | 4.5s | System integration, emergent properties |
| ThreeDimensional | 3D models | 4s | Vertex count, LOD quality |
