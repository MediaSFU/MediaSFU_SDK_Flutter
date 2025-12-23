<p align="center">
  <img src="https://www.mediasfu.com/logo192.png" width="100" alt="MediaSFU Logo">
</p>

<p align="center">
  <a href="https://twitter.com/media_sfu">
    <img src="https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white" alt="Twitter" />
  </a>
  <a href="https://www.mediasfu.com/forums">
    <img src="https://img.shields.io/badge/Community-Forum-blue?style=for-the-badge&logo=discourse&logoColor=white" alt="Community Forum" />
  </a>
  <a href="https://github.com/MediaSFU">
    <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" alt="Github" />
  </a>
  <a href="https://www.mediasfu.com/">
    <img src="https://img.shields.io/badge/Website-4285F4?style=for-the-badge&logo=google-chrome&logoColor=white" alt="Website" />
  </a>
</p>

<p align="center">
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square" alt="License: MIT" />
  </a>
  <a href="https://pub.dev/packages/mediasfu_sdk">
    <img src="https://img.shields.io/pub/v/mediasfu_sdk.svg?style=flat-square" alt="pub version" />
  </a>
  <a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/Flutter-3.3+-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter 3.3+" />
  </a>
  <a href="https://dart.dev">
    <img src="https://img.shields.io/badge/Dart-3.3+-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart 3.3+" />
  </a>
</p>

---

# MediaSFU Flutter SDK

**Build production-ready video conferencing, webinars, broadcasts, and chat in minutes.**

MediaSFU Flutter SDK provides prebuilt, fully-featured event room components with real-time video/audio, screen sharing, recording, chat, polls, whiteboards, and more — ready to drop into your Flutter app.

---

## ⚠️ Important: Backend Server Required

**MediaSFU is a frontend SDK that requires a backend media server to function.**

You have two options:

| Option | Description | Best For |
|--------|-------------|----------|
| **☁️ MediaSFU Cloud** | Managed service at [mediasfu.com](https://www.mediasfu.com) | Production apps, zero infrastructure |
| **🏠 MediaSFU Open** | Self-hosted open-source server | Full control, on-premise requirements |

```bash
# Option 1: Use MediaSFU Cloud
# Sign up at https://www.mediasfu.com and get your API credentials

# Option 2: Self-host with MediaSFU Open
git clone https://github.com/MediaSFU/MediaSFUOpen
cd MediaSFUOpen
docker-compose up -d
```

📖 **[MediaSFU Cloud Documentation →](https://www.mediasfu.com/documentation#rooms)**  
📖 **[MediaSFU Open Repository →](https://github.com/MediaSFU/MediaSFUOpen)**

---

## ✨ Platform Features

MediaSFU delivers enterprise-grade real-time communication with these core capabilities:

### 🎥 **Video & Audio**
- Multi-party video conferencing with adaptive quality
- Screen sharing with real-time annotation
- Virtual backgrounds and video effects (Android/iOS)
- Audio-only participant support

### 🎤 **Real-time Translation** 🌍
- **Speak in any language** — The system knows what language you're speaking
- **Listen in any language** — Hear others translated to your preferred language
- **Live transcription** — Real-time transcripts during meetings
- **50+ languages supported** — Global communication made seamless

### 👥 **Participant Management**
- **Panelists Mode** — Designate speakers in webinars with audience Q&A
- **Individual Permissions** — Granular control per-participant (video/audio/screen/chat)
- **Group Permissions** — Apply permission templates to participant groups
- Waiting room with manual admit
- Co-host delegation with configurable responsibilities
- Breakout rooms for focused discussions

### 📊 **Engagement Tools**
- Live polls with real-time results
- In-meeting chat (direct & group)
- Collaborative whiteboards

### 🎬 **Recording & Analytics**
- Cloud recording with track-based customization
- Watermarks, name tags, custom backgrounds
- Real-time call analytics

### 🔒 **Security & Control**
- End-to-end encryption option
- Managed events with time/capacity limits
- Abandoned participant handling

---

## 📖 Table of Contents

- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Platform Setup](#-platform-setup)
- [Prebuilt Event Rooms](#-prebuilt-event-rooms)
- [Modern UI Components](#-modern-ui-components)
- [Usage Examples](#-usage-examples)
- [Customization](#-customization)
- [Self-Hosting / Community Edition](#-self-hosting--community-edition)
- [Advanced Features](#-advanced-features)
- [Detailed Documentation](#-detailed-documentation)

---

## 🚀 Quick Start

```bash
flutter pub add mediasfu_sdk
```

```dart
import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MediasfuGeneric(
        options: MediasfuGenericOptions(
          credentials: Credentials(
            apiUserName: "yourUsername",
            apiKey: "yourAPIKey",
          ),
        ),
      ),
    );
  }
}
```

**That's it!** You now have a fully-featured video conferencing room.

---

## 📦 Installation

```bash
flutter pub add mediasfu_sdk
```

### Requirements

- **Flutter**: 3.3.3 or higher
- **Dart**: 3.3.3 or higher

### Platform Support

| Platform | Supported | Notes |
|----------|-----------|-------|
| **Android** | ✅ | Min SDK 23 |
| **iOS** | ✅ | iOS 12.0+ |
| **Web** | ✅ | HTTPS required |
| **macOS** | ✅ | macOS 10.15+ |
| **Windows** | ✅ | - |
| **Linux** | ✅ | - |

---

## 🔧 Platform Setup

Each platform requires specific permissions and configurations. See the **[Platform Setup Guide](./PLATFORM_SETUP.md)** for detailed instructions:

- [Android Setup](./PLATFORM_SETUP.md#android-setup)
- [iOS Setup](./PLATFORM_SETUP.md#ios-setup)
- [macOS Setup](./PLATFORM_SETUP.md#macos-setup)
- [Web Setup](./PLATFORM_SETUP.md#web-setup)
- [Windows Setup](./PLATFORM_SETUP.md#windows-setup)
- [Linux Setup](./PLATFORM_SETUP.md#linux-setup)

### Quick Platform Checklist

| Platform | Key Requirements |
|----------|------------------|
| **Android** | Camera, microphone, internet permissions in `AndroidManifest.xml` |
| **iOS** | Camera, microphone usage descriptions in `Info.plist` |
| **macOS** | Entitlements for camera, microphone, network access |
| **Web** | HTTPS for production; browser permissions |
| **Windows/Linux** | Standard Flutter desktop setup |

### Optional Dependencies

Some features require platform-specific dependencies. **If installing from pub.dev**, add these to your app's `pubspec.yaml` based on your target platforms:

```yaml
# pubspec.yaml - Add as needed:

# Virtual Backgrounds (Android/iOS only)
google_mlkit_selfie_segmentation: ^0.8.0

# Web platform enhancements (Web only)
web: ^1.1.1
dart_webrtc: ^1.4.6
```

| Feature | Dependency | Platforms |
|---------|------------|-----------|
| Virtual Backgrounds | `google_mlkit_selfie_segmentation` | Android, iOS |
| Whiteboard Canvas (Web) | `web`, `dart_webrtc` | Web |

> **Note**: If you clone from [GitHub](https://github.com/MediaSFU/MediaSFU_SDK_Flutter), all dependencies are already included. The pub.dev version excludes platform-specific deps so it shows support for all platforms.

---

## 🏛️ Prebuilt Event Rooms

| Component | Use Case | Description |
|-----------|----------|-------------|
| `MediasfuGeneric` | **Universal** | Supports all event types dynamically |
| `ModernMediasfuGeneric` | **Universal (Premium)** | Theme-aware, glassmorphism UI |
| `MediasfuConference` | **Meetings** | Multi-party video conferencing |
| `MediasfuWebinar` | **Webinars** | Presenters + audience model |
| `MediasfuBroadcast` | **Broadcasting** | One-to-many live streaming |
| `MediasfuChat` | **Chat Rooms** | Text-based with optional media |

All prebuilt components share the same options interface:

```dart
MediasfuGenericOptions(
  // Authentication
  credentials: Credentials(apiUserName: "user", apiKey: "key"),
  
  // Connection
  localLink: "",                    // Self-hosted server URL
  connectMediaSFU: true,            // Toggle auto-connection
  
  // Customization
  preJoinPageWidget: customPreJoin, // Custom pre-join page
  customVideoCard: customVideoCard, // Custom video display
  customAudioCard: customAudioCard, // Custom audio display
  customMiniCard: customMiniCard,   // Custom mini display
  
  // Advanced
  returnUI: true,                   // Set false for headless mode
  useLocalUIMode: false,            // Demo/local mode
  seedData: seedData,               // Pre-populate for demos
)
```

---

## 🎨 Modern UI Components

`ModernMediasfuGeneric` is the most advanced, theme-aware variant featuring:

- **Premium glassmorphism design** with backdrop blur effects
- **Dark/Light theme support** built-in with automatic detection
- **Smooth animations** and micro-interactions
- **Premium color system** with gradient support
- **Responsive layouts** for all screen sizes

```dart
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ModernMediasfuGeneric(
      options: ModernMediasfuGenericOptions(
        credentials: Credentials(apiUserName: "user", apiKey: "key"),
        // Theme automatically adapts to system preference
      ),
    );
  }
}
```

### Modern Components Available

| Modern Component | Classic Equivalent | Features |
|-----------------|-------------------|----------|
| `ModernVideoCard` | `VideoCard` | Glass effect, animated borders |
| `ModernAudioCard` | `AudioCard` | Gradient waveforms, glow effects |
| `ModernMiniCard` | `MiniCard` | Sleek thumbnails with status |
| `ModernMenuModal` | `MenuModal` | Slide animations, blur backdrop |
| `ModernMessagesModal` | `MessagesModal` | Chat bubbles, typing indicators |
| `ModernRecordingModal` | `RecordingModal` | Status animations, progress rings |
| `ModernParticipantsModal` | `ParticipantsModal` | Search, filters, role badges |
| `ModernBackgroundModal` | `BackgroundModal` | Image gallery, blur previews |
| `ModernPollModal` | `PollModal` | Real-time voting, animations |
| `ModernBreakoutRoomsModal` | `BreakoutRoomsModal` | Drag-and-drop, room previews |
| `ModernPanelistsModal` | — | Panelist management for webinars |
| `ModernPermissionsModal` | — | Per-participant permission control |
| `TranslationSettingsModal` | — | Real-time translation configuration |
```

---

## 💡 Usage Examples

### Basic Conference Room

```dart
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

class ConferenceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediasfuConference(
      options: MediasfuConferenceOptions(
        credentials: Credentials(
          apiUserName: "yourUsername",
          apiKey: "yourAPIKey",
        ),
      ),
    );
  }
}
```

### Demo/Preview Mode (No Server)

```dart
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

class DemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediasfuGeneric(
      options: MediasfuGenericOptions(
        useLocalUIMode: true,
        useSeed: true,
        seedData: SeedData(
          member: "DemoUser",
          eventType: EventType.conference,
        ),
      ),
    );
  }
}
```

### Headless Mode (Custom UI)

```dart
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

class CustomApp extends StatefulWidget {
  @override
  State<CustomApp> createState() => _CustomAppState();
}

class _CustomAppState extends State<CustomApp> {
  final ValueNotifier<MediasfuParameters?> _params = ValueNotifier(null);

  void _updateParams(MediasfuParameters? params) {
    _params.value = params;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MediasfuGeneric(
          options: MediasfuGenericOptions(
            credentials: Credentials(apiUserName: "user", apiKey: "key"),
            returnUI: false, // Headless mode
            updateSourceParameters: _updateParams,
          ),
        ),
        // Your custom UI using _params
        ValueListenableBuilder<MediasfuParameters?>(
          valueListenable: _params,
          builder: (context, params, _) {
            if (params == null) return CircularProgressIndicator();
            return MyCustomMeetingUI(parameters: params);
          },
        ),
      ],
    );
  }
}
```

### Custom Video Cards

```dart
VideoCardType myCustomVideoCard({
  required Participant participant,
  required Stream stream,
  required double width,
  required double height,
  // ... other parameters
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.purple, width: 2),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: VideoCard(
        options: VideoCardOptions(
          participant: participant,
          videoStream: stream.stream,
          // ... configure as needed
        ),
      ),
    ),
  );
}

// Use it
MediasfuGeneric(
  options: MediasfuGenericOptions(
    credentials: credentials,
    customVideoCard: myCustomVideoCard,
  ),
)
```

---

## 🎨 Customization

### UI Overrides

Override specific UI components while keeping the rest:

```dart
final uiOverrides = MediasfuUICustomOverrides(
  mainContainer: ComponentOverride<MainContainerComponentOptions>(
    render: (context, options, defaultBuilder) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.purple, width: 3),
        ),
        child: defaultBuilder(context, options),
      );
    },
  ),
  // Override other components...
);

MediasfuGeneric(
  options: MediasfuGenericOptions(
    credentials: credentials,
    uiOverrides: uiOverrides,
  ),
)
```

### Available Override Keys

| Category | Keys |
|----------|------|
| **Layout** | `mainContainer`, `mainAspect`, `mainScreen`, `mainGrid`, `subAspect`, `otherGrid`, `flexibleGrid`, `audioGrid`, `pagination` |
| **Controls** | `controlButtons`, `controlButtonsAlt`, `controlButtonsTouch` |
| **Participant** | `miniAudio`, `miniAudioPlayer`, `meetingProgressTimer` |
| **Modals** | `loadingModal`, `alert`, `menuModal`, `participantsModal`, `messagesModal`, `recordingModal`, `pollModal`, `breakoutRoomsModal`, and more... |
| **Entry** | `preJoinPage`, `welcomePage` |
| **Functions** | `consumerResume`, `addVideosGrid`, `prepopulateUserMedia` |

---

## 🏠 Self-Hosting / Community Edition

For self-hosted MediaSFU servers:

```dart
MediasfuGeneric(
  options: MediasfuGenericOptions(
    localLink: "https://your-mediasfu-server.com",
    connectMediaSFU: false,  // Don't connect to cloud
  ),
)
```

### Hybrid Mode (Local + Cloud)

```dart
MediasfuGeneric(
  options: MediasfuGenericOptions(
    localLink: "https://your-server.com",
    connectMediaSFU: true,   // Also connect to MediaSFU cloud
    credentials: Credentials(apiUserName: "user", apiKey: "key"),
  ),
)
```

---

## 🌐 Advanced Features

### sourceParameters - The Power API

Access all MediaSFU functionality through `sourceParameters`:

```dart
// Get all video/audio streams
final videoStreams = params.allVideoStreams;
final audioStreams = params.allAudioStreams;

// Control media
params.clickVideo(ClickVideoOptions(parameters: params));
params.clickAudio(ClickAudioOptions(parameters: params));
params.clickScreenShare(ClickScreenShareOptions(parameters: params));

// Toggle modals
params.updateIsParticipantsModalVisible(true);
params.updateIsMessagesModalVisible(true);
params.updateIsRecordingModalVisible(true);

// Access room state
final participants = params.participants;
final roomName = params.roomName;
final isRecording = params.recordStarted;
```

### Panelists Mode (Webinars)

In webinar mode, designate specific participants as **panelists** who can speak, while others remain audience members:

```dart
// Access panelists from sourceParameters
final panelists = params.panelists;
final panelistsFocused = params.panelistsFocused;

// Listen for panelist events:
// - panelistsUpdated
// - addedAsPanelist
// - removedFromPanelists
// - panelistFocusChanged

// Toggle panelists modal
params.updateIsPanelistsModalVisible(true);
```

### Individual & Group Permissions

Control each participant's capabilities with granular permissions:

```dart
// Permission levels:
// "0" - Standard participant
// "1" - Elevated (co-host level)
// "2" - Host (full control)

// Configure per-participant capabilities:
// - Video on/off
// - Audio on/off  
// - Screen sharing
// - Chat access

// Access permission config
final permissionConfig = params.permissionConfig;

// Toggle permissions modal
params.updateIsPermissionsModalVisible(true);
```

### Real-time Translation 🌍

Enable participants to **speak in their native language** and **listen in any language** with live AI translation:

```dart
// Translation is configured via TranslationSettingsModal
// Available in ModernMediasfuGeneric

// Translation events:
// - translation:roomConfig
// - translation:languageSet
// - translation:subscribed
// - translation:transcript
// - translation:speakerOutputChanged

// Access translation state
final translationMeta = params.translationMeta;
final translationConfig = params.translationConfig;
```

**Translation Features:**
- **Set your spoken language** — The system knows what language you're speaking
- **Choose listening language** — Hear others translated to your preferred language
- **Real-time transcription** — See live transcripts during meetings
- **50+ languages supported** — Global communication made seamless
- **Voice cloning options** — Advanced TTS with custom voice configurations

### Get Participant Media

Retrieve specific participant streams:

```dart
final videoStream = getParticipantMedia(
  options: GetParticipantMediaOptions(
    participantId: 'producer-123',
    mediaType: 'video',
    parameters: params,
  ),
);

// Or by name
final audioStream = getParticipantMedia(
  options: GetParticipantMediaOptions(
    participantName: 'John Doe',
    mediaType: 'audio',
    parameters: params,
  ),
);
```

### Virtual Backgrounds (Android/iOS)

The SDK supports virtual backgrounds on Android and iOS using ML Kit:

```dart
// Virtual backgrounds are automatically available in MediaSettingsModal
// Users can select blur or image backgrounds
```

> **Note**: Virtual backgrounds require an **optional dependency**. Add to your `pubspec.yaml`:
> ```yaml
> # Android/iOS only - for virtual backgrounds
> google_mlkit_selfie_segmentation: ^0.8.0
> ```
> See [Platform Setup](./PLATFORM_SETUP.md) for ML Kit configuration.

---

## 📖 Detailed Documentation

For comprehensive documentation including:

- Full API reference
- All component props
- 200+ methods documentation
- Socket event handling
- Recording configuration
- Breakout rooms
- Whiteboard integration
- Troubleshooting guide
- And much more...

**📄 See [README_DETAILED.md](./README_DETAILED.md)**

---

## 🔗 Links

- **Website**: [mediasfu.com](https://www.mediasfu.com)
- **Documentation**: [mediasfu.com/flutter](https://www.mediasfu.com/flutter/)
- **API Documentation**: [mediasfu.com/developers](https://mediasfu.com/developers)
- **MediaSFU Open**: [github.com/MediaSFU/MediaSFUOpen](https://github.com/MediaSFU/MediaSFUOpen)
- **Sandbox**: [mediasfu.com/sandbox](https://www.mediasfu.com/sandbox)
- **Community Forum**: [mediasfu.com/forums](https://www.mediasfu.com/forums)

---

## 📄 License

MIT © [MediaSFU](https://www.mediasfu.com)

---

<p align="center">
  <strong>Built with ❤️ by MediaSFU</strong>
</p>
