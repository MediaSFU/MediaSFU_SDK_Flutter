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

**Ship production-ready voice, video, and AI communication in minutes — not months.**

MediaSFU gives you prebuilt, fully-featured event room components with real-time video/audio, screen sharing, recording, chat, polls, whiteboards, real-time translation, and more. Drop them into your Flutter app with a few lines of code and go live on **all 6 platforms**.

### Why MediaSFU?

| What you need | Without MediaSFU | With MediaSFU |
|---------------|------------------|---------------|
| **Video conferencing** | 6–12 months of WebRTC, TURN/STUN, codec work | `flutter pub add mediasfu_sdk` → done |
| **Pricing** | $1–5 per 1,000 minutes (Twilio, Vonage, Daily) | **$0.10 per 1,000 minutes** — 10–50x cheaper |
| **UI components** | Build every modal, card, and control from scratch | Prebuilt components — classic & modern themes |
| **AI features** | Wire up third-party AI, TTS, vision APIs yourself | Built-in AI agents, voice translation, transcription |
| **Platform coverage** | Separate codebases per platform | One SDK → Android, iOS, Web, macOS, Windows, Linux |
| **Time to first call** | Weeks of infrastructure setup | **Under 5 minutes** |

---

## 🔥 What Makes MediaSFU Different

<table>
<tr>
<td width="50%">

### Embeddable by Design
Other platforms give you raw APIs and leave you to build the UI. MediaSFU gives you **finished, production-ready components** — video grids, control bars, modals, chat panels, recording controls — that you drop in and customize.

### AI-Native, Not Bolted On
AI agents, real-time voice translation (50+ languages), live transcription, and intelligent routing are **built into the platform** — not third-party add-ons you wire up yourself.

</td>
<td width="50%">

### Pricing That Makes Sense
**$0.10 per 1,000 minutes.** This isn't a loss-leader — MediaSFU runs its own media infrastructure. No reselling. No hidden fees. Free tier included, no credit card required.

### Full Stack, One Platform
Voice + video + chat + screen sharing + recording + polls + whiteboards + breakout rooms + AI + translation + SIP. **All included.** Replace 5 communication tools with one SDK.

</td>
</tr>
</table>

---

## ⚠️ Important: Backend Server Required

**MediaSFU is a frontend SDK that requires a backend media server to function.**

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

## 📖 Table of Contents

- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Platform Support](#-platform-support)
- [Platform Features](#-platform-features)
- [Prebuilt Event Rooms](#-prebuilt-event-rooms)
- [Modern UI Components](#-modern-ui-components)
- [Usage Examples](#-usage-examples)
- [Customization](#-customization)
- [Self-Hosting / Community Edition](#-self-hosting--community-edition)
- [Advanced Features](#-advanced-features)
- [SDKs for Every Framework](#-sdks-for-every-framework)
- [Detailed Documentation](#-detailed-documentation)

---

## 🚀 Quick Start

**Three steps. Under 5 minutes. First video call live.**

**1. Install**
```bash
flutter pub add mediasfu_sdk
```

**2. Import & Build**
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

**3. Run**
```bash
flutter run
```

**That's it.** You have a fully-featured video conferencing room with screen sharing, chat, recording, and more — running on any platform Flutter supports.

> **Want to try without a server?** Use demo mode:
> ```dart
> MediasfuGeneric(
>   options: MediasfuGenericOptions(
>     useLocalUIMode: true,
>     useSeed: true,
>     seedData: SeedData(member: "DemoUser", eventType: EventType.conference),
>   ),
> )
> ```

---

## 📦 Installation

```bash
flutter pub add mediasfu_sdk
```

### Requirements

- **Flutter**: 3.3.3 or higher
- **Dart**: 3.3.3 or higher

---

## 🌍 Platform Support

**One codebase. Six platforms. No compromises.**

| Platform | Supported | Notes |
|----------|-----------|-------|
| **Android** | ✅ | Min SDK 23 |
| **iOS** | ✅ | iOS 12.0+ |
| **Web** | ✅ | HTTPS required |
| **macOS** | ✅ | macOS 10.15+ |
| **Windows** | ✅ | Native desktop |
| **Linux** | ✅ | Native desktop |

Each platform requires specific permissions and configurations. See the **[Platform Setup Guide](./PLATFORM_SETUP.md)** for detailed instructions:

- [Android Setup](./PLATFORM_SETUP.md#android-setup) — Camera, microphone, internet permissions
- [iOS Setup](./PLATFORM_SETUP.md#ios-setup) — Camera, microphone usage descriptions
- [macOS Setup](./PLATFORM_SETUP.md#macos-setup) — Entitlements for camera, microphone, network
- [Web Setup](./PLATFORM_SETUP.md#web-setup) — HTTPS for production; browser permissions
- [Windows / Linux Setup](./PLATFORM_SETUP.md#windows-setup) — Standard Flutter desktop setup

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

## ✨ Platform Features

Everything you need for enterprise-grade real-time communication — **included at $0.10/1K min**:

### 🎥 Video & Audio
- Multi-party video conferencing with adaptive quality
- Screen sharing with real-time annotation
- Virtual backgrounds and video effects (Android/iOS)
- Audio-only participant support

### 🎤 Real-time Translation 🌍
- **Speak in any language** — The system auto-detects what language you're speaking
- **Listen in any language** — Hear others translated to your preferred language in real time
- **Live transcription** — See real-time transcripts during meetings
- **50+ languages supported** — True borderless communication
- No interpreters. No delay. Works with voice, video, and chat.

### 🤖 AI-Powered Features
- AI voice agents that answer, resolve, and escalate
- Multimodal AI with voice + vision capabilities
- AI-generated meeting summaries and transcription
- Intelligent call routing and warm handoffs
- Voice cloning options with custom TTS configurations

### 👥 Participant Management
- **Panelists Mode** — Designate speakers in webinars with audience Q&A
- **Individual Permissions** — Granular per-participant control (video/audio/screen/chat)
- **Group Permissions** — Apply permission templates to participant groups
- Waiting room with manual admit
- Co-host delegation with configurable responsibilities
- Breakout rooms for focused discussions

### 📊 Engagement Tools
- Live polls with real-time results
- In-meeting chat (direct & group)
- Collaborative whiteboards

### 🎬 Recording & Analytics
- Cloud recording with track-based customization
- Watermarks, name tags, custom backgrounds
- Real-time call analytics

### 🔒 Security & Control
- End-to-end encryption option
- Domain-locked API keys
- Managed events with time/capacity limits
- Abandoned participant handling

---

## 🏛️ Prebuilt Event Rooms

Choose the room type that fits your use case — or use `MediasfuGeneric` for maximum flexibility:

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

`ModernMediasfuGeneric` is the premium, theme-aware variant featuring:

- **Glassmorphism design** with backdrop blur effects
- **Dark/Light theme** with automatic system detection
- **Smooth animations** and micro-interactions
- **Premium color system** with gradient support
- **Responsive layouts** for every screen size

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

| Modern Component | Classic Equivalent | Highlights |
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

### Headless Mode (Build Your Own UI)

Use MediaSFU as a pure backend engine while rendering a completely custom UI:

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
            returnUI: false, // Headless mode — no default UI rendered
            updateSourceParameters: _updateParams,
          ),
        ),
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

Override specific UI components while keeping the defaults for everything else:

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

For complete control over your infrastructure:

```dart
// Self-hosted only
MediasfuGeneric(
  options: MediasfuGenericOptions(
    localLink: "https://your-mediasfu-server.com",
    connectMediaSFU: false,
  ),
)

// Hybrid mode — local server + MediaSFU cloud features
MediasfuGeneric(
  options: MediasfuGenericOptions(
    localLink: "https://your-server.com",
    connectMediaSFU: true,
    credentials: Credentials(apiUserName: "user", apiKey: "key"),
  ),
)
```

---

## 🌐 Advanced Features

### sourceParameters — The Power API

Access all MediaSFU functionality programmatically through `sourceParameters`:

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

Designate specific participants as **panelists** who can speak, while others remain audience members:

```dart
final panelists = params.panelists;
final panelistsFocused = params.panelistsFocused;

// Events: panelistsUpdated, addedAsPanelist, removedFromPanelists, panelistFocusChanged
params.updateIsPanelistsModalVisible(true);
```

### Individual & Group Permissions

Fine-grained control over what each participant can do:

```dart
// Permission levels: "0" Standard, "1" Elevated (co-host), "2" Host (full control)
// Configurable per participant: video, audio, screen sharing, chat access
final permissionConfig = params.permissionConfig;
params.updateIsPermissionsModalVisible(true);
```

### Real-time Translation 🌍

Participants speak in their native language and listen in any language — powered by live AI translation:

```dart
// Translation is configured via TranslationSettingsModal (ModernMediasfuGeneric)
// Events: translation:roomConfig, translation:languageSet, translation:subscribed,
//         translation:transcript, translation:speakerOutputChanged
final translationMeta = params.translationMeta;
final translationConfig = params.translationConfig;
```

- **50+ languages** — real-time speech translation during live calls
- **No interpreters, no delay** — AI-powered, built into every call
- **Voice cloning options** — advanced TTS with custom voice configurations

### Virtual Backgrounds (Android/iOS)

```yaml
# Add to your pubspec.yaml (Android/iOS only):
google_mlkit_selfie_segmentation: ^0.8.0
```

Virtual backgrounds are automatically available in MediaSettingsModal. Users can select blur or image backgrounds. See [Platform Setup](./PLATFORM_SETUP.md) for ML Kit configuration.

### Get Participant Media

```dart
final videoStream = getParticipantMedia(
  options: GetParticipantMediaOptions(
    participantId: 'producer-123',
    mediaType: 'video',
    parameters: params,
  ),
);
```

---

## 🛠️ SDKs for Every Framework

MediaSFU isn't just Flutter. The same communication platform is available across **7 frameworks** — same API surface, same capabilities, same pricing:

| Framework | Package |
|-----------|---------|
| **Flutter** | [mediasfu_sdk](https://pub.dev/packages/mediasfu_sdk) (you are here) |
| **React** | [@mediasfu/mediasfu-reactjs](https://www.npmjs.com/package/@mediasfu/mediasfu-reactjs) |
| **React Native** | [@mediasfu/mediasfu-reactnative](https://www.npmjs.com/package/@mediasfu/mediasfu-reactnative) |
| **Expo** | [@mediasfu/mediasfu-reactnative-expo](https://www.npmjs.com/package/@mediasfu/mediasfu-reactnative-expo) |
| **Angular** | [@mediasfu/mediasfu-angular](https://www.npmjs.com/package/@mediasfu/mediasfu-angular) |
| **Vue** | [@mediasfu/mediasfu-vue](https://www.npmjs.com/package/@mediasfu/mediasfu-vue) |
| **Android (Kotlin)** | [MediaSFU Android](https://github.com/MediaSFU/MediaSFU_SDK_Android) |

Plus **native apps** for Windows, Linux, macOS, iOS, Android, and Web. Not Electron — real native apps.

---

## 📖 Detailed Documentation

For comprehensive documentation including full API reference, 200+ methods, socket event handling, recording configuration, breakout rooms, whiteboard integration, troubleshooting, and more:

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
  <strong>Built with ❤️ by MediaSFU</strong><br>
  <sub>Voice · Video · AI · Translation · 6 Platforms · $0.10/1K min</sub>
</p>
