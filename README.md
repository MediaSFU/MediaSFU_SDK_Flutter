<p align="center">
  <img src="https://www.mediasfu.com/logo192.png" width="96" alt="MediaSFU Logo">
</p>

<p align="center">
  <a href="https://pub.dev/packages/mediasfu_sdk"><img src="https://img.shields.io/pub/v/mediasfu_sdk.svg?style=flat-square" alt="pub.dev version" /></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square" alt="MIT License" /></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.3+-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter 3.3+" /></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.3+-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart 3.3+" /></a>
</p>

# MediaSFU Flutter SDK

`mediasfu_sdk` is the official Flutter WebRTC SDK for building MediaSFU-powered video conferencing, webinar, broadcast, live streaming, chat, whiteboard, recording, translation, and AI-assisted meeting experiences across Android, iOS, Web, macOS, Windows, and Linux.

## Why Teams Choose MediaSFU

- Start with a prebuilt room UI, then move to headless or deeply customized layouts when your product matures.
- Use MediaSFU Cloud for managed infrastructure or `localLink` for self-hosted MediaSFU Open and proxy-backed deployments.
- Ship one SDK for voice, video, chat, screen sharing, whiteboard, breakout rooms, recording, real-time translation, and AI-adjacent meeting workflows.
- Lean on public docs, generated API docs, sandbox tools, and the MediaSFU community forum when integration questions come up.

## Search-Friendly Use Cases

Developers usually arrive here looking for one or more of these real use cases:

- Flutter video conferencing SDK
- Flutter WebRTC SDK
- Flutter webinar SDK
- Flutter broadcast or live streaming SDK
- Flutter chat and meeting room SDK
- Flutter whiteboard and collaboration SDK
- Flutter real-time translation SDK
- Flutter headless video room SDK
- Flutter AI meeting or AI notes integration surface

The package is designed for three integration styles:

| Integration style | Use this when | Main APIs |
| --- | --- | --- |
| Prebuilt UI | You want a complete room UI quickly | `MediasfuGeneric`, `MediasfuConference`, `MediasfuWebinar`, `MediasfuBroadcast`, `MediasfuChat`, `ModernMediasfuGeneric` |
| Headless runtime | You want MediaSFU connection/media logic but your own UI | `returnUI: false`, `updateSourceParameters`, `MediasfuParameters` |
| Custom UI with SDK components | You want to replace selected cards, modals, or layouts | custom builders, `MediasfuUICustomOverrides`, exported components |

For the full long-form guide, see [README_DETAILED.md](./README_DETAILED.md). For native permissions and platform setup, see [PLATFORM_SETUP.md](./PLATFORM_SETUP.md).

## Table Of Contents

- [Install](#install)
- [Why Teams Choose MediaSFU](#why-teams-choose-mediasfu)
- [Search-Friendly Use Cases](#search-friendly-use-cases)
- [Backend Model](#backend-model)
- [Quick Start: Prebuilt Room](#quick-start-prebuilt-room)
- [Try The UI Without A Live Room](#try-the-ui-without-a-live-room)
- [Choose A Room Widget](#choose-a-room-widget)
- [Headless Mode](#headless-mode)
- [Create And Join Rooms Programmatically](#create-and-join-rooms-programmatically)
- [Self-Hosted MediaSFU Open](#self-hosted-mediasfu-open)
- [Platform Setup](#platform-setup)
- [Common Options](#common-options)
- [Customization](#customization)
- [Feature Map](#feature-map)
- [Troubleshooting](#troubleshooting)
- [Docs, Support, And Search Map](#docs-support-and-search-map)
- [LLM And Code Search Hints](#llm-and-code-search-hints)

## Install

```bash
flutter pub add mediasfu_sdk
```

Minimum package requirements:

| Requirement | Version |
| --- | --- |
| Dart | `>=3.3.3 <4.0.0` |
| Flutter | `>=1.17.0` |

Use the package barrel import in application code:

```dart
import 'package:mediasfu_sdk/mediasfu_sdk.dart';
```

Optional features may need extra dependencies in your app:

```yaml
# Android / iOS virtual backgrounds
google_mlkit_selfie_segmentation: ^0.10.0

# Web whiteboard and capture helpers
web: ^1.1.1
dart_webrtc: ^1.4.6
```

## Backend Model

MediaSFU is not a standalone offline video widget. The Flutter package needs a MediaSFU-compatible backend for room creation, signaling, media routing, and runtime coordination.

| Backend | Best for | What the Flutter app passes |
| --- | --- | --- |
| MediaSFU Cloud | Managed production rooms with minimal infrastructure | `Credentials(apiUserName, apiKey)` |
| MediaSFU Open / self-hosted | On-premise, private, or custom backend deployments | `localLink`, and optional local auth fields such as `localAppKey`, `localApiUserName`, `localApiKey`, `localSubUserName` |
| Your backend proxy | Production apps that should not expose privileged API keys | App-specific token/room data returned by your backend, then passed into SDK options |

The built-in helper endpoints are:

| Helper | MediaSFU Cloud endpoint | Self-hosted endpoint when `localLink` is not a MediaSFU domain |
| --- | --- | --- |
| `createRoomOnMediaSFU` | `https://mediasfu.com/v1/rooms` | `${localLink}/createRoom` |
| `joinRoomOnMediaSFU` | `https://mediasfu.com/v1/rooms/` | `${localLink}/joinRoom` |

Security note: avoid embedding privileged production credentials in public clients unless that is an intentional part of your architecture. A backend proxy is usually safer for production mobile and web apps.

## Quick Start: Prebuilt Room

This is the fastest working path for MediaSFU Cloud.

```dart
import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediasfuGeneric(
        options: MediasfuGenericOptions(
          credentials: Credentials(
            apiUserName: 'your-api-username',
            apiKey: 'your-64-character-api-key',
          ),
        ),
      ),
    );
  }
}
```

Run it:

```bash
flutter run
```

The default `MediasfuGeneric` flow shows the pre-join page, lets the user create or join a room, then renders the meeting experience with media controls, chat, participants, recording controls, polls, whiteboard, and related modals.

## Try The UI Without A Live Room

Use local UI mode when you want to test layouts, demos, screenshots, or custom components without connecting to a live room.

```dart
MediasfuGeneric(
  options: MediasfuGenericOptions(
    useLocalUIMode: true,
    useSeed: true,
    seedData: SeedData(
      member: 'Demo User',
      eventType: EventType.conference,
    ),
  ),
)
```

This is useful for frontend work, visual QA, and rapid prototyping. It does not replace a real backend validation pass before release.

## Choose A Room Widget

Start with `MediasfuGeneric` or `ModernMediasfuGeneric` when you are still shaping the product. Move to the event-specific widgets when the room type is fixed.

| Widget | Use case |
| --- | --- |
| `MediasfuGeneric` | General room experience that can support multiple event types |
| `ModernMediasfuGeneric` | Modern UI path with extra translation, fixed-link, and navigation options |
| `MediasfuConference` | Meeting and team collaboration rooms |
| `MediasfuWebinar` | Host, panelist, and attendee workflows |
| `MediasfuBroadcast` | Broadcast and one-to-many streaming experiences |
| `MediasfuChat` | Chat-first rooms with optional media workflows |

Example:

```dart
MediasfuConference(
  options: MediasfuConferenceOptions(
    credentials: Credentials(
      apiUserName: 'your-api-username',
      apiKey: 'your-64-character-api-key',
    ),
  ),
)
```

Modern UI example:

```dart
ModernMediasfuGeneric(
  options: ModernMediasfuGenericOptions(
    credentials: Credentials(
      apiUserName: 'your-api-username',
      apiKey: 'your-64-character-api-key',
    ),
    initialMeetingId: 'optional-room-id',
    onBack: () {
      // Route back with your app router.
    },
  ),
)
```

## Headless Mode

Set `returnUI: false` when your app should own the visual interface while MediaSFU owns connection setup, room state, media state, and helper methods.

```dart
import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

class HeadlessMeeting extends StatefulWidget {
  const HeadlessMeeting({super.key});

  @override
  State<HeadlessMeeting> createState() => _HeadlessMeetingState();
}

class _HeadlessMeetingState extends State<HeadlessMeeting> {
  MediasfuParameters? parameters;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MediasfuGeneric(
          options: MediasfuGenericOptions(
            credentials: Credentials(
              apiUserName: 'your-api-username',
              apiKey: 'your-64-character-api-key',
            ),
            returnUI: false,
            updateSourceParameters: (nextParameters) {
              setState(() => parameters = nextParameters);
            },
          ),
        ),
        if (parameters == null)
          const Center(child: CircularProgressIndicator())
        else
          MyMeetingSurface(parameters: parameters!),
      ],
    );
  }
}

class MyMeetingSurface extends StatelessWidget {
  final MediasfuParameters parameters;

  const MyMeetingSurface({super.key, required this.parameters});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Room: ${parameters.roomName}'),
        Text('Participants: ${parameters.participants.length}'),
        ElevatedButton(
          onPressed: () => parameters.updateIsMessagesModalVisible(true),
          child: const Text('Open chat'),
        ),
      ],
    );
  }
}
```

For headless mode you usually provide one of these pre-join payloads:

```dart
MediasfuGeneric(
  options: MediasfuGenericOptions(
    returnUI: false,
    credentials: credentials,
    noUIPreJoinOptionsCreate: CreateMediaSFURoomOptions(
      action: 'create',
      duration: 60,
      capacity: 25,
      userName: 'Host User',
      eventType: EventType.conference,
    ),
    updateSourceParameters: (parameters) {
      // Store parameters in app state.
    },
  ),
)
```

or:

```dart
MediasfuGeneric(
  options: MediasfuGenericOptions(
    returnUI: false,
    credentials: credentials,
    noUIPreJoinOptionsJoin: JoinMediaSFURoomOptions(
      action: 'join',
      meetingID: 'room-id',
      userName: 'Guest User',
    ),
    updateSourceParameters: (parameters) {
      // Store parameters in app state.
    },
  ),
)
```

## Create And Join Rooms Programmatically

You can call the room helpers directly when your app has its own lobby, schedule screen, or invite flow.

```dart
final createResult = await createRoomOnMediaSFU(
  CreateMediaSFUOptions(
    apiUserName: 'your-api-username',
    apiKey: 'your-64-character-api-key',
    payload: CreateMediaSFURoomOptions(
      action: 'create',
      duration: 60,
      capacity: 25,
      userName: 'Host User',
      eventType: EventType.conference,
      supportTranslation: true,
    ),
  ),
);

if (createResult.success) {
  final room = createResult.data as CreateJoinRoomResponse;
  debugPrint('Created ${room.roomName}: ${room.link}');
} else {
  final error = createResult.data as CreateJoinRoomError;
  debugPrint('Room creation failed: ${error.error}');
}
```

Join an existing room:

```dart
final joinResult = await joinRoomOnMediaSFU(
  JoinMediaSFUOptions(
    apiUserName: 'your-api-username',
    apiKey: 'your-64-character-api-key',
    payload: JoinMediaSFURoomOptions(
      action: 'join',
      meetingID: 'room-id',
      userName: 'Guest User',
    ),
  ),
);

if (joinResult.success) {
  final room = joinResult.data as CreateJoinRoomResponse;
  debugPrint('Joined ${room.roomName}');
}
```

## Self-Hosted MediaSFU Open

Use `localLink` for self-hosted or proxy-backed deployments.

```dart
MediasfuGeneric(
  options: MediasfuGenericOptions(
    localLink: 'https://media.example.com',
    connectMediaSFU: true,
    credentials: Credentials(
      apiUserName: 'proxy-or-local-user',
      apiKey: 'your-64-character-api-key',
    ),
  ),
)
```

Modern self-hosted example with local socket handshake fields:

```dart
ModernMediasfuGeneric(
  options: ModernMediasfuGenericOptions(
    localLink: 'https://media.example.com',
    connectMediaSFU: true,
    credentials: credentials,
    localAppKey: 'your-app-key',
    localApiUserName: 'local-api-user',
    localApiKey: 'local-api-key',
    localSubUserName: 'team-member',
    useFixedLink: true,
    initialMeetingId: 'room-id',
  ),
)
```

When `localLink` is set to a non-MediaSFU domain, `createRoomOnMediaSFU` uses `${localLink}/createRoom` and `joinRoomOnMediaSFU` uses `${localLink}/joinRoom`.

## Platform Setup

Most media failures are caused by missing host-app permissions. Configure each target platform before testing production flows.

| Platform | Required setup |
| --- | --- |
| Android | Camera, microphone, internet permissions; min SDK and ProGuard rules as needed |
| iOS | `NSCameraUsageDescription`, `NSMicrophoneUsageDescription`, local network permissions if applicable |
| macOS | Camera, microphone, and network entitlements |
| Web | HTTPS in production, browser media permissions, CORS for self-hosted servers |
| Windows | Flutter desktop setup and camera/microphone device permissions |
| Linux | Flutter desktop setup plus system media dependencies |

See [PLATFORM_SETUP.md](./PLATFORM_SETUP.md) for copy-ready native configuration snippets.

## Common Options

These options appear across the prebuilt room widgets.

| Option | Type | Purpose |
| --- | --- | --- |
| `credentials` | `Credentials?` | MediaSFU Cloud or backend auth values |
| `localLink` | `String?` | Self-hosted/proxy server base URL |
| `connectMediaSFU` | `bool?` | Whether the SDK should connect to MediaSFU services |
| `returnUI` | `bool?` | `true` renders the prebuilt UI; `false` runs headless |
| `updateSourceParameters` | `Function(MediasfuParameters?)?` | Receives the runtime helper/state bundle |
| `noUIPreJoinOptionsCreate` | `CreateMediaSFURoomOptions?` | Create-room payload for headless mode |
| `noUIPreJoinOptionsJoin` | `JoinMediaSFURoomOptions?` | Join-room payload for headless mode |
| `createMediaSFURoom` | `CreateRoomOnMediaSFUType?` | Replace the create-room helper |
| `joinMediaSFURoom` | `JoinRoomOnMediaSFUType?` | Replace the join-room helper |
| `useLocalUIMode` | `bool?` | Run the UI without live room connections |
| `seedData` / `useSeed` | `SeedData?` / `bool?` | Seed demo participant and room data |
| `customVideoCard` | `VideoCardType?` | Replace video cards |
| `customAudioCard` | `AudioCardType?` | Replace audio cards |
| `customMiniCard` | `MiniCardType?` | Replace mini participant cards |
| `customComponent` | `CustomComponentType?` | Replace the whole room workspace |
| `containerStyle` | `ContainerStyleOptions?` | Style the room container |
| `uiOverrides` | `MediasfuUICustomOverrides?` | Wrap or replace specific SDK widgets/functions |

Modern-only extras include `useFixedLink`, `localAppKey`, `localApiUserName`, `localApiKey`, `localSubUserName`, `initialMeetingId`, `canUsePersonalTranslation`, `personalTranslationUsername`, `userVoiceClones`, `onBack`, and `optimizeVideoRecord`.

## Customization

### Replace common media cards

```dart
MediasfuGeneric(
  options: MediasfuGenericOptions(
    credentials: credentials,
    customVideoCard: ({
      required participant,
      required stream,
      required width,
      required height,
      imageSize,
      doMirror,
      showControls,
      showInfo,
      name,
      backgroundColor,
      onVideoPress,
      parameters,
    }) {
      return SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.black,
            border: Border.all(color: Colors.blueAccent, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              name ?? participant.name,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    },
  ),
)
```

The exact builder signatures are exported by the package types. Use your editor autocomplete from `package:mediasfu_sdk/mediasfu_sdk.dart` for the required parameters.

### Wrap one SDK component with `MediasfuUICustomOverrides`

```dart
final overrides = MediasfuUICustomOverrides(
  participantsModal: ComponentOverride<ParticipantsModalOptions>(
    render: (context, options, defaultBuilder) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
        child: defaultBuilder(context, options),
      );
    },
  ),
);

MediasfuGeneric(
  options: MediasfuGenericOptions(
    credentials: credentials,
    uiOverrides: overrides,
  ),
)
```

Frequently overridden slots include `mainContainer`, `mainGrid`, `controlButtons`, `participantsModal`, `messagesModal`, `recordingModal`, `pollModal`, `breakoutRoomsModal`, `configureWhiteboardModal`, `backgroundModal`, `preJoinPage`, and `welcomePage`.

### Replace the full workspace

```dart
MediasfuGeneric(
  options: MediasfuGenericOptions(
    credentials: credentials,
    customComponent: ({required parameters}) {
      return MyFullMeetingWorkspace(parameters: parameters);
    },
  ),
)
```

Use this when you want MediaSFU to provide the runtime state and methods while your app owns the complete room UI.

### Custom icons and Font Awesome v11

The package uses `font_awesome_flutter` v11. When rendering Font Awesome icons directly, use `FaIcon`:

```dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const FaIcon(FontAwesomeIcons.xmark)
```

For SDK share button options, both Flutter `IconData` values and Font Awesome `FaIconData` values are supported:

```dart
ShareButtonOptions(
  icon: FontAwesomeIcons.whatsapp,
  action: () {},
)
```

## Feature Map

| Feature area | SDK surface |
| --- | --- |
| Audio/video rooms | `MediasfuGeneric`, `MediasfuConference`, `MediasfuParameters`, media card builders |
| Webinars and panelists | `MediasfuWebinar`, panelist methods, modern panelist modal |
| Broadcasts | `MediasfuBroadcast` |
| Chat rooms | `MediasfuChat`, messages modal, message methods |
| Screen sharing | screen-share methods, screen producer helpers, screenboard components |
| Recording | recording modal and recording methods |
| Polls | poll modal and poll methods |
| Breakout rooms | breakout room modal and launch methods |
| Whiteboard | whiteboard, screenboard, configure whiteboard modal, capture helpers |
| Virtual backgrounds | background modal, processor service, platform-specific ML dependency |
| Waiting rooms | waiting modal and waiting methods |
| Co-hosts | co-host modal and co-host methods |
| Permissions | permission methods and modern permissions modal |
| Translation | modern translation settings, translation room config, personal translation options |
| SIP / telephony-ready rooms | `CreateMediaSFURoomOptions.supportSIP`, `directionSIP`, `preferPCMA` |
| AI notes and agents | configure from the MediaSFU dashboard/docs, then use room/runtime features in the SDK |

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Pre-join shows credential errors | `apiUserName` must not be a placeholder and `apiKey` must be a valid 64-character key |
| Camera or microphone does not open | Native platform permissions, HTTPS on web, and OS privacy settings |
| Web works locally but not in production | HTTPS, browser permission prompts, CORS for self-hosted APIs, and TURN/STUN reachability |
| Self-hosted create/join fails | Verify `localLink`, `/createRoom`, `/joinRoom`, TLS, CORS, and backend auth headers |
| Headless mode renders no UI | This is expected with `returnUI: false`; render your own widgets from `MediasfuParameters` |
| Demo mode connects unexpectedly | Use `useLocalUIMode: true` with seed data and avoid live credentials for visual-only demos |
| Font Awesome compile error with `Icon(FontAwesomeIcons.xmark)` | Use `FaIcon(FontAwesomeIcons.xmark)` with `font_awesome_flutter` v11 |
| Analyzer reports only info-level lints | The package may still build; clean those lints separately if your CI treats infos as fatal |

## Docs, Support, And Search Map

Current MediaSFU documentation and support entry points:

| Need | Link |
| --- | --- |
| Flutter SDK docs | [mediasfu.com/flutter](https://www.mediasfu.com/flutter) |
| Developer docs portal | [mediasfu.com/docs](https://www.mediasfu.com/docs/) |
| Quick start guide | [mediasfu.com/docs/usage/quickstart](https://www.mediasfu.com/docs/usage/quickstart/) |
| Headless guide | [mediasfu.com/docs/usage/headless](https://www.mediasfu.com/docs/usage/headless/) |
| Documentation map | [mediasfu.com/docs/guide-map](https://www.mediasfu.com/docs/guide-map/) |
| Generated API docs | [mediasfu.com/docs/api](https://www.mediasfu.com/docs/api/) |
| Developer console / API configuration | [mediasfu.com/documentation](https://www.mediasfu.com/documentation) |
| Dashboard user guide | [mediasfu.com/user-guide](https://www.mediasfu.com/user-guide) |
| Sandbox | [mediasfu.com/sandbox](https://www.mediasfu.com/sandbox) |
| Widget Studio | [mediasfu.com/widget-studio](https://www.mediasfu.com/widget-studio) |
| AI agents | [mediasfu.com/agents](https://www.mediasfu.com/agents) |
| AI notes | [mediasfu.com/ai-notes-guide](https://www.mediasfu.com/ai-notes-guide) |
| Translation | [mediasfu.com/translation](https://www.mediasfu.com/translation) |
| SIP / telephony | [mediasfu.com/telephony](https://www.mediasfu.com/telephony) |
| Community support | [mediasfu.com/forums](https://www.mediasfu.com/forums) |
| Contact | [mediasfu.com/contact](https://www.mediasfu.com/contact) |
| GitHub organization | [github.com/MediaSFU](https://github.com/MediaSFU) |

Community forum categories include General Help, Deployment Issues, Mobile SDK, Web SDK, Integrations, Announcements, and Feature Requests. For Flutter package questions, use the Mobile SDK category and include your platform, Flutter version, package version, backend mode, and the smallest reproducible snippet.

## LLM And Code Search Hints

This section intentionally repeats the canonical names that developers and AI coding tools should use when searching or generating integrations.

- Package name: `mediasfu_sdk`
- Import: `package:mediasfu_sdk/mediasfu_sdk.dart`
- Main prebuilt Flutter widgets: `MediasfuGeneric`, `MediasfuConference`, `MediasfuWebinar`, `MediasfuBroadcast`, `MediasfuChat`, `ModernMediasfuGeneric`
- Main options classes: `MediasfuGenericOptions`, `MediasfuConferenceOptions`, `MediasfuWebinarOptions`, `MediasfuBroadcastOptions`, `MediasfuChatOptions`, `ModernMediasfuGenericOptions`
- Credentials class: `Credentials(apiUserName, apiKey)`
- Room helper payloads: `CreateMediaSFURoomOptions`, `JoinMediaSFURoomOptions`
- Room helper functions: `createRoomOnMediaSFU`, `joinRoomOnMediaSFU`
- Runtime state and methods: `MediasfuParameters`
- UI override type: `MediasfuUICustomOverrides`
- Demo mode types: `SeedData`, `EventType`
- Backend keywords: MediaSFU Cloud, MediaSFU Open, self-hosted, `localLink`, `/createRoom`, `/joinRoom`
- Feature keywords: Flutter video conferencing, Flutter WebRTC meeting SDK, Flutter webinar SDK, Flutter broadcast SDK, Flutter whiteboard, Flutter breakout rooms, Flutter live translation, Flutter AI meeting notes, Flutter SIP room, Flutter headless video SDK

When asking an AI assistant for help, include the package version, the selected widget, whether you use MediaSFU Cloud or `localLink`, the target platform, and the exact error text.

## Related SDKs

| Platform/framework | Package or docs |
| --- | --- |
| Flutter | [pub.dev/packages/mediasfu_sdk](https://pub.dev/packages/mediasfu_sdk) |
| React | [mediasfu.com/reactjs](https://www.mediasfu.com/reactjs) |
| Angular | [mediasfu.com/angular](https://www.mediasfu.com/angular) |
| Vue | [mediasfu.com/vue](https://www.mediasfu.com/vue) |
| React Native CLI | [mediasfu.com/reactnative](https://www.mediasfu.com/reactnative) |
| React Native Expo | [mediasfu.com/reactnativeexpo](https://www.mediasfu.com/reactnativeexpo) |
| JavaScript | [mediasfu.com/javascript](https://www.mediasfu.com/javascript) |

## License

MIT. See [LICENSE](./LICENSE).
