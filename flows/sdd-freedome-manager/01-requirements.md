# Requirements: FreeDome Manager Integration

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-02-28
> Author: Qwen (Code Analysis)

## Problem Statement

**What problem are we solving?**

The FreeDome Sphere project requires a comprehensive dome display management system that:
1. Integrates with FreeDome ecosystem for spherical/immersive content playback
2. Provides AI-powered content understanding and optimization
3. Enables 3D artists to rapidly deploy content to dome environments without technical expertise
4. Automates calibration, optimization, and publishing workflows

**Why does this matter?**

Current dome content creation workflow requires:
- 27 hours of manual technical work per project
- Multiple specialized roles (programmer, sound engineer, tester)
- Complex hardware calibration setups
- Manual store publication processes

FreeDome Manager aims to reduce this to 5 minutes of automated processing, saving 83% costs ($4,995 per project) and 99.7% time (26 hours 55 minutes).

## User Stories

### Primary Users

#### 3D Artist (Yan - Primary User)
**As a** 3D artist creating immersive dome content
**I want** to import my Blender models and automatically get a published dome application
**So that** I can focus on creativity while the system handles technical complexity

#### Content Creator
**As a** content creator for planetariums/immersive venues
**As a** I want AI-powered analysis of my content's visual, audio, and spatial properties
**So that** I can optimize for the best dome experience

#### Developer
**As a** developer integrating with FreeDome ecosystem
**I want** well-documented APIs with stub implementations
**So that** I can develop against the interface before real hardware is available

### Secondary Users

#### Venue Operator
**As a** dome venue operator
**I want** simple calibration tools for audio and video systems
**So that** I can quickly set up and maintain my installation

#### End User
**As a** viewer of dome content
**I want** seamless, optimized immersive experiences
**So that** I can enjoy content without technical distractions

## Acceptance Criteria

### Must Have

#### 1. FreeDome Integration Core

**Given** the FreeDome system is available
**When** a user initializes the integration service
**Then** all components (Core, Calibration, Connectivity) initialize successfully within 1.2 seconds

**Given** the service is initialized
**When** a user connects to a FreeDome server
**Then** connection status is tracked and reported via streams

**Given** a connection is established
**When** data is sent to the FreeDome system
**Then** data is transmitted with error handling and logging

#### 2. Calibration System

**Given** the calibration service is initialized
**When** audio calibration is requested
**Then** audio devices are analyzed and optimal settings are returned (sample rate, channels, latency)

**Given** the calibration service is initialized
**When** video calibration is requested
**Then** video settings are analyzed and optimal settings are returned (resolution, FPS, projection type)

**Given** calibration is complete
**When** device information is requested
**Then** a list of available audio/video devices with availability status is returned

#### 3. Lyubomir Understanding System

**Given** the understanding service is initialized
**When** content analysis is requested for a file
**Then** the system automatically detects content type and performs appropriate analysis

**Given** content has been analyzed
**When** analysis results are queried
**Then** results include confidence scores, tags, and dome-specific recommendations

**Given** multiple understanding types exist (visual, audio, spatial, semantic, etc.)
**When** content is analyzed
**Then** relevant understanding types are applied and results are aggregated

#### 4. User Interface

**Given** the integration screen is displayed
**When** system status changes
**Then** UI updates in real-time via ChangeNotifier/Provider pattern

**Given** the user wants to calibrate audio/video
**When** calibration buttons are pressed
**Then** progress is shown and results are displayed with success/failure feedback

**Given** the user wants to manage understandings
**When** the Lyubomir learning screen is opened
**Then** three tabs (Understandings, Analysis, Settings) are available with full CRUD operations

### Should Have

#### Performance Requirements

- Initialization time: < 1.5 seconds total
- Connection establishment: < 3 seconds
- Audio calibration: < 3 seconds
- Video calibration: < 4 seconds
- Content analysis: 1-5 seconds depending on type
- UI responsiveness: 60 FPS during all operations

#### Error Handling

- Graceful degradation when FreeDome packages are unavailable (stub fallback)
- Clear error messages in user's language (Russian/English)
- Automatic retry logic for transient failures
- Comprehensive logging with emoji indicators

### Won't Have (This Iteration)

- Real FreeDome hardware integration (stubs only)
- Physical calibration rig automation
- Direct store publication (Google Play/Apple Store)
- Multi-user collaboration features
- Cloud-based processing
- Real-time collaborative editing

## Constraints

### Technical

- **Platform**: Flutter (iOS, Android, potentially desktop/web)
- **State Management**: ChangeNotifier + Provider pattern
- **Persistence**: SharedPreferences for settings and understandings
- **API Compatibility**: Must work with stub implementations until real FreeDome packages available
- **Language Support**: Bilingual code comments (Russian/English)

### Performance

- **Mobile**: Must run smoothly on Quest 3 and similar mobile VR hardware
- **Memory**: Efficient memory usage for mobile platforms
- **Battery**: Minimize battery drain during calibration and analysis

### Dependencies

- **FreeDome Packages**: Core, Calibration, Connectivity (currently stubs)
- **Flutter SDK**: Latest stable version
- **Provider**: State management
- **SharedPreferences**: Local persistence
- **Path Package**: File path manipulation

### Non-Goals

- Replace Blender or other 3D modeling tools
- Provide video editing capabilities
- Act as a general-purpose media player
- Support non-dome content formats

## Open Questions

### Architecture

- [ ] Should FreeDome Manager be a standalone app or a plugin/package?
- [ ] What is the strategy for transitioning from stubs to real FreeDome packages?
- [ ] How should the system handle multiple simultaneous dome installations?

### Business

- [ ] What is the pricing model for FreeDome Manager?
- [ ] Who is the primary customer (individual artists vs. venues)?
- [ ] What is the go-to-market strategy?

### Technical

- [ ] What are the exact FreeDome API specifications when real packages arrive?
- [ ] What dome projection standards must be supported (fisheye, equirectangular, etc.)?
- [ ] What audio formats and channel configurations are required?

## References

### Internal Documentation

- `DEMO_GUIDE.md` - Business value proposition and workflow comparison
- `demo_freedome_integration.dart` - Full integration demonstration
- `demo_freedome_simple.dart` - Simple API stub demonstration
- `flows/sdd.md` - Spec-Driven Development flow reference

### Code Artifacts

- `lib/services/freedome_integration_service.dart` - Main integration service
- `lib/services/freedome_api_stubs.dart` - API stub implementations
- `lib/services/freedome_learning_service.dart` - Learning service (placeholder)
- `lib/services/freedome_learning_complex/freedome_learning_service.dart` - Advanced learning service
- `lib/services/lyubomir_understanding_service.dart` - AI understanding system
- `lib/models/lyubomir_understanding.dart` - Understanding data models
- `lib/screens/freedome_integration_screen.dart` - Integration UI
- `lib/screens/lyubomir_learning_system_screen.dart` - Learning system UI
- `test/freedome_integration_test.dart` - Integration tests
- `test/freedome_learning_service_test.dart` - Learning service tests

### External Systems

- **FreeDome Ecosystem**: Target integration platform
- **Blender**: 3D modeling tool integration
- **anAntaSound**: Quantum audio processing system
- **ZELIM**: Quantum 3D model format
- **COLLADA/samskara**: 3D model interchange format
- **MBHARATA**: Platform integration

---

## Approval

- [ ] Reviewed by: _pending_
- [ ] Approved on: _pending_
- [ ] Notes: _pending_

---

## Appendix: Understanding Types

The Lyubomir system supports 11 understanding types:

1. **Visual** - Image/video analysis (colors, objects, composition)
2. **Audio** - Sound analysis (frequency, amplitude, spatial audio)
3. **Text** - NLP analysis (sentiment, keywords, language)
4. **Spatial** - 3D model analysis (geometry, materials, UV mapping)
5. **Temporal** - Time-based analysis (duration, keyframes, transitions)
6. **Semantic** - Meaning analysis (concepts, context, relevance)
7. **Interactive** - UX analysis (interactions, responsiveness, accessibility)
8. **Emotional** - Emotional impact analysis (emotions, intensity, valence)
9. **Quantum** - Quantum property analysis (coherence, entanglement, superposition)
10. **Holistic** - Whole-system analysis (wholeness, interconnections, emergent properties)
11. **ThreeDimensional** - Specialized 3D content analysis (vertices, faces, LOD)

Each type has specific analysis algorithms, result structures, and dome-specific recommendations.
