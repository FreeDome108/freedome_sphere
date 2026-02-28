# Requirements: FreeDome Calibration System

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-02-28
> Author: Qwen (Code Analysis)

## Problem Statement

**What problem are we solving?**

Dome/immersive environments require precise audio and video calibration for optimal playback:
1. Audio must be calibrated for dome acoustics (multi-channel, spatial audio)
2. Video must be calibrated for spherical projection (fisheye correction, brightness)
3. Traditional calibration requires expensive physical equipment and expertise
4. Manual calibration is time-consuming (hours per session)

**Why does this matter?**

Current dome calibration requires:
- Physical microphone rigs for audio calibration ($5,000+ equipment)
- Professional calibration expertise
- 2-4 hours per calibration session
- Re-calibration for each venue/setup

FreeDome Calibration System provides software-based calibration, reducing time from hours to seconds and eliminating hardware requirements.

## User Stories

### Primary Users

#### Venue Operator
**As a** dome venue operator
**I want** one-click audio calibration
**So that** I can optimize sound for my specific dome acoustics without hiring engineers

**As a** venue operator
**I want** automatic video calibration for my projection system
**So that** content displays correctly without manual adjustment

#### Content Creator
**As a** content creator
**I want** to know the calibration settings of a venue
**So that** I can optimize my content for that specific setup

**As a** content creator
**I want** calibration history and comparison
**So that** I can track changes and revert if needed

### Secondary Users

#### System Integrator
**As a** system integrator
**I want** device detection and capability reporting
**So that** I can verify all equipment is properly connected

#### Developer
**As a** developer
**I want** calibration APIs with stub implementations
**So that** I can develop without physical hardware

## Acceptance Criteria

### Must Have

#### 1. Audio Calibration

**Given** the calibration service is initialized
**When** audio calibration is requested
**Then** the system analyzes available audio devices and returns optimal settings

**Given** audio calibration completes
**When** results are returned
**Then** they include:
- Sample rate (default: 48000 Hz)
- Channels (default: 8)
- Latency in ms (target: < 20ms)
- Device list with availability
- Calibration timestamp

**Given** audio calibration runs
**When** progress is monitored
**Then** it completes within 3 seconds

#### 2. Video Calibration

**Given** the calibration service is initialized
**When** video calibration is requested
**Then** the system analyzes video settings and returns optimal parameters

**Given** video calibration completes
**When** results are returned
**Then** they include:
- Resolution (default: 4096x2048 for dome)
- FPS (default: 60)
- Projection type (spherical/fisheye)
- Brightness (0.0-1.0)
- Contrast (0.0-1.0)
- Calibration timestamp

**Given** video calibration runs
**When** progress is monitored
**Then** it completes within 4 seconds

#### 3. Device Detection

**Given** the system has audio/video devices
**When** device list is requested
**Then** all devices are returned with:
- Unique ID
- Human-readable name
- Type (audio/video)
- Availability status

**Given** a device becomes unavailable
**When** device list is refreshed
**Then** availability status updates accordingly

#### 4. Calibration Options

**Given** calibration is requested
**When** custom options are provided
**Then** the system respects:
- Specific devices to calibrate
- Custom calibration parameters
- Advanced settings (if supported)

**Given** no options provided
**When** calibration runs
**Then** default optimal settings are used

#### 5. Calibration Result Structure

**Given** any calibration completes
**When** result is returned
**Then** it follows standard structure:
```dart
CalibrationResult(
  success: bool,
  status: String,        // Human-readable status
  data: Map?,            // Calibration metrics
  error: String?,        // Error message if failed
)
```

#### 6. Error Handling

**Given** calibration fails
**When** error occurs
**Then** user receives:
- Clear error message
- Suggested recovery steps
- Option to retry

**Given** no devices found
**When** calibration attempted
**Then** error: "No calibration devices detected" with troubleshooting steps

#### 7. Integration

**Given** FreedomeIntegrationService is initialized
**When** calibration methods are called
**Then** they delegate to FreedomeCalibration correctly

**Given** calibration completes
**When** service listeners are active
**Then** UI updates via notifyListeners()

### Should Have

#### Calibration History

- Store last 10 calibration results per type
- Compare current vs. previous calibration
- Rollback to previous calibration settings

#### Advanced Features

- Multi-point audio calibration (simulated)
- HDR video calibration
- Automatic brightness adjustment based on ambient light
- Phase alignment for multi-channel audio

#### Performance

- Audio calibration: < 3 seconds
- Video calibration: < 4 seconds
- Device detection: < 1 second
- Memory usage: < 50MB during calibration

### Won't Have (This Iteration)

- Physical hardware calibration rig integration
- Real acoustic measurement (requires hardware)
- Real light/color measurement (requires hardware)
- Multi-room calibration
- Remote calibration (network-based)
- Automatic calibration scheduling

## Constraints

### Technical

- **Platform:** Flutter (iOS, Android, Quest 3)
- **API:** Currently stub implementations
- **State Management:** ChangeNotifier pattern
- **Async:** All calibration operations asynchronous
- **Language:** Dart with Russian/English comments

### Performance

- **Mobile:** Must run on Quest 3
- **Memory:** Efficient for mobile constraints
- **Battery:** Minimize drain during calibration

### Dependencies

- **FreedomeCalibration:** Core calibration API (stubs)
- **FreedomeConnectivity:** For device detection
- **SharedPreferences:** For calibration history

## Open Questions

### Hardware Integration

- [ ] When real FreeDome packages arrive, what hardware APIs are available?
- [ ] Can we integrate with USB measurement devices?
- [ ] Should we support external calibration tools (REW, etc.)?

### Algorithm

- [ ] What accuracy level for simulated calibration?
- [ ] Should calibration adapt over time (machine learning)?
- [ ] How to validate calibration quality without hardware?

### Business

- [ ] Is calibration a free feature or premium?
- [ ] Should venues share calibration profiles?
- [ ] Certification for calibrated venues?

## References

### Internal

- `lib/services/freedome_api_stubs.dart` - FreedomeCalibration stub
- `lib/services/freedome_integration_service.dart` - Integration service
- `test/freedome_integration_test.dart` - Calibration tests

### External

- **FreeDome Calibration API:** Target integration
- **anAntaSound:** Quantum audio processing
- **REW (Room EQ Wizard):** Reference calibration tool

---

## Approval

- [ ] Reviewed by: _pending_
- [ ] Approved on: _pending_
- [ ] Notes: _pending_

---

## Appendix: Calibration Metrics

### Audio Metrics

| Metric | Range | Default | Target |
|--------|-------|---------|--------|
| Sample Rate | 44100-192000 Hz | 48000 Hz | 48000 Hz |
| Channels | 2-64 | 8 | 8-16 |
| Latency | 5-100 ms | 12.5 ms | < 20 ms |
| Frequency Response | 20Hz-20kHz | Flat | Flat ±3dB |

### Video Metrics

| Metric | Range | Default | Target |
|--------|-------|---------|--------|
| Resolution | 1920x1080-8192x4096 | 4096x2048 | Native dome |
| FPS | 30-120 | 60 | 60-120 |
| Brightness | 0.0-1.0 | 0.85 | 0.8-0.9 |
| Contrast | 0.0-1.0 | 0.9 | 0.85-0.95 |
| Color Temp | 3200K-9300K | 6500K | 6500K |
