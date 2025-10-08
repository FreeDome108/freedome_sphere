# 🌐 FreeDome Sphere - Professional Content Editor

[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md) [![ไทย](https://img.shields.io/badge/lang-ไทย-green.svg)](README_th.md) [![Русский](https://img.shields.io/badge/lang-Русский-red.svg)](README_ru.md)

---

## 🎯 Operating Mode Selection

FreeDome Sphere supports two fundamentally different approaches to content creation:

### 🔬 Quantum Mode
**Quantum content editor for holographic projections**

- **Technology**: 108 quantum elements with fractal structure
- **Content**: Quantum scenes with interference patterns
- **Formats**: .zelim (quantum format)
- **Audio**: anAntaSound with quantum resonances
- **Application**: Scientific visualizations, quantum simulations

### 🖥️ Classical Mode  
**Traditional content editor for dome projections**

- **Technology**: Standard media formats and 3D content
- **Content**: Videos, 3D scenes, comics, animations
- **Formats**: .dome, .boranko, standard media
- **Audio**: Spatial audio with REW calibration
- **Application**: Planetariums, entertainment centers

---

## 🎯 About the Editor

**FreeDome Sphere** is a professional editor for creating interactive content for the MBHARATA platform. The editor enables the creation of dome presentations, integration of Baranko comics, working with 3D content from Unreal Engine and Blender, and professional work with the anAntaSound system.

## ✨ Key Features

### 📚 Content Import:
- **Baranko Comics** - Support for original formats (.comics) and modern format (.boranko)
- **Z-Depth and 3D Effects** - Transform flat images into volumetric dome content
- **Unreal Engine** - Import 3D scenes and animations (.uasset, .umap)
- **Blender** - Work with 3D models (.blend, .fbx, .obj, .gltf, .glb)
- **Audio Files** - Support for multiple formats

### 🎨 Editing:
- **Dome Projection** - Editing for spherical display
- **3D Scenes** - Create and configure 3D environments
- **Animations** - Timeline editor for animations
- **Effects** - Visual and audio effects

### 🔊 anAntaSound Audio System:
- **3D Positioning** - Spatial sound placement
- **Multiple Sources** - Work with multiple audio streams
- **Synchronization** - Precise synchronization with visuals
- **Export** - Optimization for mbharata_client

### 📱 Export:
- **mbharata_client** - Native format for mobile applications (.mbp)
- **Dome Systems** - Optimization for various dome installations (.dome)
- **Streaming** - Preparation for online broadcasts

## 🔗 Integration with FreeDome Manager via Deeplinks

### 📱 `freedome://` Scheme for Calibration

FreeDome Sphere integrates with FreeDome Manager through a unified deeplinks scheme `freedome://`. To launch calibration from FreeDome Sphere, use:

```dart
import 'package:url_launcher/url_launcher.dart';

// Launch calibration for FreeDome Sphere
Future<void> startCalibration() async {
  await launchUrl(Uri.parse('freedome://app/calibrate?name=freedome_sphere'));
}

// Quick calibration
Future<void> quickCalibrate() async {
  await launchUrl(Uri.parse('freedome://quick/calibrate'));
}

// Launch quantum calibration
Future<void> quantumCalibrate() async {
  await launchUrl(Uri.parse('freedome://calibration/quantum'));
}
```

### 🎯 Integration Benefits:
- **Unified Calibration** - all settings applied automatically
- **Consistent UI** - uniform calibration interface
- **Automatic Synchronization** with other FreeDome applications
- **Centralized Management** of dome system settings

## 🚀 Installation and Launch

### Requirements:
- Flutter 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Git
- FreeDome Manager (for calibration)

### Installation:
```bash
cd freedome_sphere
flutter pub get
```

### Quantum Mode:
```bash
# Run in development mode (quantum)
flutter run --dart-define=MODE=quantum

# Build (quantum)
flutter build --dart-define=MODE=quantum
```

### Classical Mode:
```bash
# Run in development mode (classical)
flutter run --dart-define=MODE=classical

# Build (classical)
flutter build --dart-define=MODE=classical
```

## 📖 User Guide

### 1. Creating a New Project:
1. Launch FreeDome Sphere
2. Click "New Project"
3. Configure dome parameters (radius, projection type)
4. Set up anAntaSound audio system

### 2. Importing Baranko Comics:
1. File → Import → Baranko Comics
2. Select folder with comics (.comics files)
3. Configure import parameters
4. Apply automatic processing

### 3. Working with 3D Content:
1. Import → 3D Content → Unreal Engine/Blender
2. Select file to import
3. Configure materials and lighting
4. Optimize for dome display

### 4. Setting Up anAntaSound Audio:
1. Audio → anAntaSound Setup
2. Add audio sources
3. Configure 3D positioning
4. Synchronize with visuals

### 5. Export for mbharata_client:
1. File → Export → mbharata_client
2. Choose save path (.mbp file)
3. Configure compression settings
4. Launch export

## ⚠️ IMPORTANT WARNING

### 🚨 DEPRECATION NOTICE - .comics Format

**The .comics format is supported ONLY in ASIS mode for the single legacy mbharata application (with comics drawn by Boranko).**

- ⚠️ **Current Status**: DEPRECATED
- 🚨 **Planned Removal**: Next major version
- ✅ **Recommendation**: Use modern .boranko format for all new 2D projects
- 📅 **Legacy Support**: Only for existing Boranko comics in mbharata

## 🎭 Advantages of .boranko Format over .comic

### 🚀 Z-Depth Revolution:
The .boranko format, unlike .comic format, allows adding **z-depth** (depth) to objects, which enables converting flat images into **dome content with 3D effects**. This is called **"Quantum Stereoscopy"** - a technology that automatically analyzes flat images and creates depth maps to transform them into volumetric dome content.

### ✨ Key Advantages of .boranko:

| Feature | .comic (Legacy) | .boranko (Modern) |
|---------|-----------------|-------------------|
| **Z-Depth Support** | ❌ Absent | ✅ Full support with quantum algorithms |
| **3D Dome Effects** | ❌ Flat images only | ✅ Volumetric effects with parallax and stereoscopy |
| **Quantum Stereoscopy** | ❌ Not supported | ✅ Automatic 2D→3D conversion |
| **Dome Optimization** | ⚠️ Basic | ✅ Special optimization for domes |
| **Metadata** | ⚠️ Limited | ✅ Rich metadata and versioning |
| **Performance** | ⚠️ Outdated | ✅ Mobile device optimization |
| **Compatibility** | ⚠️ Legacy mbharata only | ✅ Full compatibility with mbharata_client |

### 🎨 Technical Capabilities of .boranko:
- **Volumetric Lighting**: Realistic 3D lighting simulation
- **Parallax Effects**: Create depth perception with camera movement
- **Quantum Resonances**: Integration with anAntaSound system for immersive experience
- **Automatic Optimization**: Adaptation to different dome sizes
- **Mobile Compatibility**: Optimization for low-end devices

## 🎮 Supported Formats

### Import:
- **Comics**: 
  - **.comics** - Original Baranko format (ZIP archive with images + metadata)
  - **.boranko** - Modern format with Z-Depth and 3D effects support
  - .cbr, .cbz (standard formats, converted to .boranko)
- **3D**: .blend, .fbx, .obj, .gltf, .glb, .uasset, .umap, .dae, .3ds, .max (converted to .zelim)
- **Audio**: .wav, .mp3, .ogg, .flac, .aac (converted to .daga)
- **Video**: .mp4, .mov, .avi
- **Images**: .jpg, .png, .tiff, .exr

### Export:
- **mbharata_client**: .mbp (native format)
- **Dome Systems**: .dome (standard formats)
- **Streaming**: HLS, DASH
- **Audio**: .daga (advanced format for anAntaSound)
- **2D Projects**: .boranko (modern format for 2D content)
- **3D Projects**: .zelim (modern format for 3D content)

## 🔬 Quantum Technologies of FreeDome Sphere

### 🌌 Quantum Geometry (108 Elements)
FreeDome Sphere uses revolutionary quantum geometry with 108 quantum elements organized into various structures:
- **Spherical Geometry** - 108 elements on sphere for uniform distribution
- **Toroidal Geometry** - 108 elements on torus for dynamic effects
- **Icosahedral Geometry** - 108 elements on icosahedron for crystalline structures
- **Fractal Geometry** - 108 elements in fractal structure for self-similar patterns
- **Holographic Geometry** - 108 elements in holographic projection for volumetric effects
- **Quantum Lattice** - 108 elements in quantum lattice for quantum computing

### 🎵 Quantum Resonances
The quantum resonance system includes:
- **Schumann Resonance** (7.83 Hz) - Earth's fundamental frequency
- **Solfeggio Frequencies** (528 Hz, 741 Hz, 852 Hz, 963 Hz) - therapeutic frequencies
- **Chakra Frequencies** - for energy centers
- **DNA Frequencies** - for biological synchronization
- **Quantum Resonances** - for quantum states

### 🎯 Quantum Calibration
Automatic quantum calibration includes:
- **Interference Grids** - for aligning 108 elements
- **Quantum Crosshairs** - for precise positioning
- **Quantum Checkerboards** - for corner detection
- **Quantum Circles** - for high-precision calibration
- **Quantum Lines** - for axis alignment
- **Quantum Points** - for precise positioning

### 🧠 Quantum States
Each of the 108 elements can exist in various quantum states:
- **Ground** - ground state
- **Excited** - excited state
- **Superposition** - superposition of states
- **Entangled** - entangled state

## 🏗️ Architecture

### Technology Stack:
- **Frontend**: Flutter + Dart
- **3D Engine**: flutter_3d_controller
- **Audio**: audioplayers + anAntaSound SDK
- **Files**: path_provider for file system operations
- **Export**: Custom formats + compatibility

### Modular Structure:
```
freedome_sphere/
├── lib/
│   ├── main.dart            # Main application entry
│   ├── core/                # Core engine
│   ├── importers/           # Content importers
│   ├── screens/             # UI screens
│   ├── services/            # Business logic services
│   ├── models/              # Data models
│   ├── widgets/             # Reusable UI components
│   └── exporters/           # Content exporters
├── assets/                  # Resources
├── plugin/                  # Plugins
└── docs/                    # Documentation
```

## 🔧 API and Extensions

### Project Structure:
```dart
{
  name: "Project Name",
  domeRadius: 10,
  projectionType: "spherical",
  scenes: [],
  audio: [],
  comics: [],
  created: "2024-01-01T00:00:00.000Z"
}
```

## 💼 Business Value

FreeDome Sphere solves the problem of creating quality content for dome systems - a niche not covered by existing solutions. This allows businesses to:

- **Create Unique Immersive Experiences** for customers
- **Optimize Content for Mobile Devices** (critical for modern planetariums)
- **Integrate with MBHARATA Ecosystem** for content monetization
- **Automatically Publish** to Google Play and Apple Store
- **Accelerate Time to Market** with ready-to-use tools

### 🎯 Target Markets:
- **Entertainment & Tourism** - Planetariums, science centers, entertainment complexes, museums
- **Education** - Universities, schools, corporate training, online education
- **Corporate Sector** - Presentations, architecture, medicine, engineering

## 🐛 Debugging and Logs

### Enable Debugging:
```bash
flutter run --verbose
```

### Logs:
- Developer console
- System logs in console

## 📄 License

NativeMindNONC - All rights reserved.

## 🌐 Links

- **Website**: [FreeDome Ecosystem](https://freedome.earth)
- **Documentation**: [docs/](docs/)
- **Support**: support@freedome.earth

---

*FreeDome Sphere - Professional tool for creating immersive content with quantum technologies.*

