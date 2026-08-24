<p align="center">
  <img src="https://www.mediasfu.com/logo192.png" width="96" alt="MediaSFU Logo">
</p>

<p align="center">
  <a href="https://pub.dev/packages/mediasfu_sdk"><img src="https://img.shields.io/pub/v/mediasfu_sdk.svg?style=flat-square" alt="pub.dev version" /></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square" alt="MIT License" /></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.38.1+-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter 3.38.1+" /></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.10+-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart 3.10+" /></a>
</p>

# MediaSFU Flutter SDK

Build video meetings, webinars, broadcasts, live streams, and collaborative rooms in Flutter without assembling the whole real-time experience from scratch.

`mediasfu_sdk` is the official MediaSFU Flutter WebRTC SDK. It combines ready-made room UI with headless APIs for audio, video, chat, screen sharing, whiteboards, breakout rooms, recording, real-time translation, and AI-assisted meeting workflows across Android, iOS, web, macOS, Windows, and Linux.

<p align="center">
  <a href="https://mediasfu.com/storybook/?path=/story/mediasfu-components-modern-mediasfu-generic--default">
    <img src="https://mediasfu.com/images/demos/showcase_all.webp" width="960" alt="MediaSFU product showcase: video calls, classrooms, broadcasts, live commerce, podcasts, and AI experiences" />
  </a>
</p>

<p align="center"><a href="https://mediasfu.com/storybook/?path=/story/mediasfu-components-modern-mediasfu-generic--default">Open the live ModernMediasfuGeneric preview →</a></p>

[Quick start](#quick-start-prebuilt-room) · [Try the sandbox](https://www.mediasfu.com/sandbox) · [Flutter guide](https://www.mediasfu.com/docs/sdks/flutter/) · [API reference](https://www.mediasfu.com/api/flutter/) · [Self-host with MediaSFU Open](https://github.com/MediaSFU/MediaSFUOpen)

## Why Product Teams Choose MediaSFU

- **Launch sooner:** start with a complete meeting, webinar, broadcast, or chat interface instead of building every room interaction yourself.
- **Keep control as you grow:** customize individual cards and modals, or switch to headless mode and own the entire UI without replacing the room runtime.
- **Choose your deployment:** use MediaSFU Cloud for a managed backend, MediaSFU Open for self-hosting, or route room creation through your own secure proxy.
- **Build beyond basic calls:** use one SDK surface for collaboration features such as polls, breakout rooms, whiteboards, recording, translation, and telephony-ready rooms.
- **Ship across Flutter targets:** share the same integration model across mobile, web, and desktop while handling each platform's permissions and media requirements.

## Choose The Right Starting Point

| Your goal | Start with | Why |
| --- | --- | --- |
| Add a working room to a Flutter app quickly | `ModernMediasfuGeneric` | Current premium participant, media, chat, and collaboration UI |
| Match an existing product design | SDK components and `MediasfuUICustomOverrides` | Replace selected surfaces while retaining the room runtime |
| Own every pixel and interaction | Headless mode with `returnUI: false` | Receive `MediasfuParameters` state and helpers in your own widgets |
| Run managed production infrastructure | [MediaSFU Cloud](https://www.mediasfu.com/documentation/) | Hosted room creation, signaling, media routing, and platform services |
| Keep media infrastructure in your environment | [MediaSFU Open](https://github.com/MediaSFU/MediaSFUOpen) with `localLink` | Self-hosted deployment and infrastructure control |
| Work directly with mediasoup transports and producers | [`mediasfu_mediasoup_client`](https://pub.dev/packages/mediasfu_mediasoup_client) | Lower-level client primitives without this SDK's complete product layer |

Within this package, choose the integration depth that fits the product today:

| Integration style | Use this when | Main APIs |
| --- | --- | --- |
| Prebuilt UI | You want a complete room UI quickly | `MediasfuGeneric`, `MediasfuConference`, `MediasfuWebinar`, `MediasfuBroadcast`, `MediasfuChat`, `ModernMediasfuGeneric` |
| Headless runtime | You want MediaSFU connection/media logic but your own UI | `returnUI: false`, `updateSourceParameters`, `MediasfuParameters` |
| Custom UI with SDK components | You want to replace selected cards, modals, or layouts | custom builders, `MediasfuUICustomOverrides`, exported components |

For the complete implementation guide, see [README_DETAILED.md](./README_DETAILED.md). For native permissions and platform setup, see [PLATFORM_SETUP.md](./PLATFORM_SETUP.md).

## Table Of Contents

- [Why Product Teams Choose MediaSFU](#why-product-teams-choose-mediasfu)
- [Choose The Right Starting Point](#choose-the-right-starting-point)
- [Install](#install)
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
- [Resources And Support](#resources-and-support)

## Install

```bash
flutter pub add mediasfu_sdk
```

Minimum package requirements:

| Requirement | Version |
| --- | --- |
| Dart | `>=3.10.0 <4.0.0` |
| Flutter | `>=3.38.1` |

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
dart_webrtc: ^1.8.1
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

For local-only development, a restricted and revocable MediaSFU API key is the fastest route. Before distributing an app, keep reusable credentials on an authenticated backend and inject **both** room callbacks. The client credentials below are syntactically valid placeholders only; the callbacks ignore them and send only the room payload.

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

const clientPlaceholders = Credentials(
  apiUserName: 'client00',
  apiKey: '0000000000000000000000000000000000000000000000000000000000000000',
);

Future<String> currentAppAccessToken() async {
  // Return a short-lived token from your app's signed-in session.
  throw UnimplementedError('Connect this to your application authentication.');
}

Future<CreateJoinRoomResult> _proxyRoom(
  String operation,
  Map<String, dynamic> payload,
) async {
  final response = await http.post(
    Uri.parse('https://api.example.com/api/mediasfu/$operation'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await currentAppAccessToken()}',
    },
    body: jsonEncode(payload),
  );
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode < 200 || response.statusCode >= 300 || body['success'] == false) {
    return CreateJoinRoomResult(
      success: false,
      data: CreateJoinRoomError(
        error: body['error']?.toString() ?? 'Room request failed (${response.statusCode}).',
      ),
    );
  }
  final data = (body['data'] ?? body) as Map<String, dynamic>;
  return CreateJoinRoomResult(
    success: true,
    data: CreateJoinRoomResponse.fromJson(data),
  );
}

Future<CreateJoinRoomResult> createViaBackend(CreateMediaSFUOptions options) =>
    _proxyRoom('create-room', options.payload.toMap());

Future<CreateJoinRoomResult> joinViaBackend(JoinMediaSFUOptions options) =>
    _proxyRoom('join-room', options.payload.toMap());

final room = ModernMediasfuGeneric(
  options: ModernMediasfuGenericOptions(
    credentials: clientPlaceholders,
    createMediaSFURoom: createViaBackend,
    joinMediaSFURoom: joinViaBackend,
  ),
);
```

Your backend must authenticate the app user, validate and allowlist the payload, enforce room/role/duration/capacity policy, rate-limit requests, replace the placeholders with server-only credentials, call MediaSFU, and return only the authorized room result. Never let either callback fall back to the default client credential path. Use the [REST API Sandbox](https://mediasfu.com/sandbox) for GET/POST experiments, create credentials at [API Keys](https://mediasfu.com/api-keys), and read the room API contract in the [Developer Console guide](https://mediasfu.com/documentation).

## Quick Start: Prebuilt Room

This is the fastest working path for MediaSFU Cloud. Get your API username and key from the [MediaSFU developer dashboard](https://www.mediasfu.com/dashboard?mode=regular), or use the [self-hosted path](#self-hosted-mediasfu-open) instead.

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
      home: ModernMediasfuGeneric(
        options: ModernMediasfuGenericOptions(
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

The default `ModernMediasfuGeneric` flow shows the pre-join page, lets the user create or join a room, then renders the meeting experience with media controls, chat, participants, recording controls, polls, whiteboard, and related modals.

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

Start with `ModernMediasfuGeneric` when you are still shaping the product. Use `MediasfuGeneric` for the classic shell, or move to an event-specific widget when the room type is fixed.

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
        ModernMediasfuGeneric(
          options: ModernMediasfuGenericOptions(
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
    final current = parameters.getCurrentParams();
    final readiness = getRoomReadiness(current);
    final screen = getScreenShareStream(current);
    final remote = getRemoteVideoStreams(current);
    final local = getLocalVideoStream(current);
    final primary = screen.stream ?? (remote.isNotEmpty ? remote.first.stream : local);

    return Column(
      children: [
        Text(readiness.ready ? 'Room ready' : readiness.reason),
        Text('Participants: ${listParticipantMediaStates(current).length}'),
        Expanded(
          child: primary == null
              ? const Center(child: Text('Waiting for media…'))
              : CardVideoDisplay(
                  options: CardVideoDisplayOptions(
                    remoteProducerId: screen.active ? current.screenId : 'primary',
                    eventType: current.eventType,
                    videoStream: primary,
                    forceFullDisplay: !screen.active,
                    doMirror: !screen.active && remote.isEmpty,
                  ),
                ),
        ),
        ElevatedButton(
          onPressed: readiness.ready
              ? () async {
                  final result = await runMediaControl(
                    current,
                    () => clickAudio(ClickAudioOptions(parameters: current)),
                  );
                  if (!result.ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.error)),
                    );
                  }
                }
              : null,
          child: Text(current.audioAlreadyOn ? 'Mute' : 'Unmute'),
        ),
        // Audio is independent from the visible video page. Mount every item.
        ...getAudioGridComponents(current),
      ],
    );
  }
}
```

For headless mode you usually provide one of these pre-join payloads:

```dart
ModernMediasfuGeneric(
  options: ModernMediasfuGenericOptions(
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
ModernMediasfuGeneric(
  options: ModernMediasfuGenericOptions(
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

For larger app-owned surfaces, use `MediasfuHeadlessController` as the
`updateSourceParameters` callback and rebuild with `AnimatedBuilder`. It accepts
every publication and exposes `readiness`, `remoteVideos`, `remoteAudios`,
`localVideo`, `localAudio`, `screenShare`, and participant state. The remaining
headless helpers cover permissions, moderation, recording, polls, breakout
rooms, whiteboards, session state, viewer sessions, safe media-production
capabilities, chat, and leave/end actions.

Headless rules that prevent the most common broken-call states:

- keep the room component mounted for the complete call;
- accept every parameter publication and call `getCurrentParams()` for pure
  reads—do not retain an older bag or use `getUpdatedAllParams()` in a build,
  timer, or listener;
- select screen share first, then remote camera, then local camera; render
  screens unmirrored with contain sizing;
- mount every value returned by `getAudioGridComponents`, independent of the
  visible video page;
- wait for `getRoomReadiness(parameters).ready` before enabling controls;
- display every `HeadlessActionResult.error`, gate host actions with the
  permission helpers, await leave/end, and dispose app-created tracks.

See [HEADLESS_GUIDE.md](./HEADLESS_GUIDE.md) and the [cross-SDK headless guide](https://mediasfu.com/docs/usage/headless/) for the complete state, action, moderation, session, and verification walkthrough.

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

**MediaSFU Open is a media server that you deploy and operate yourself.** Start
and verify that server first, then set `localLink` to its URL. The Flutter prop
does not download or start MediaSFU Open; `localhost` reaches the device itself
and only works when the app and server truly share that host.

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
| `containerWidthFraction` / `containerHeightFraction` | `double` | Size `ModernMediasfuGeneric` relative to an embedded parent; each defaults to `1` |
| `uiOverrides` | `MediasfuUICustomOverrides?` | Wrap or replace specific SDK widgets/functions |

Modern-only extras include `useFixedLink`, `localAppKey`, `localApiUserName`, `localApiKey`, `localSubUserName`, `initialMeetingId`, `canUsePersonalTranslation`, `personalTranslationUsername`, `userVoiceClones`, `onBack`, and `optimizeVideoRecord`.

Embed a room without letting it claim the complete viewport:

```dart
SizedBox(
  width: 720,
  height: 540,
  child: ModernMediasfuGeneric(
    options: ModernMediasfuGenericOptions(
      credentials: credentials,
      containerWidthFraction: 0.75,
      containerHeightFraction: 0.75,
    ),
  ),
)
```

When either fraction is below `1`, internal layout calculations use the
embedded room dimensions instead of assuming a full-screen route.

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

## Resources And Support

Use the shortest path for the question you have:

| Need | Link |
| --- | --- |
| Flutter setup and concepts | [Flutter SDK guide](https://www.mediasfu.com/docs/sdks/flutter/) |
| Copy-and-run first integration | [Quick start guide](https://www.mediasfu.com/docs/usage/quickstart/) |
| Fully custom Flutter UI | [Headless guide](https://www.mediasfu.com/docs/usage/headless/) |
| Exact classes and signatures | [Generated Flutter API reference](https://www.mediasfu.com/api/flutter/) |
| Browse all developer material | [MediaSFU docs portal](https://www.mediasfu.com/docs/) |
| Developer console and API configuration | [Developer console guide](https://www.mediasfu.com/documentation/) |
| Create and manage MediaSFU API credentials | [MediaSFU API Keys](https://www.mediasfu.com/api-keys) |
| Dashboard user guide | [mediasfu.com/user-guide](https://www.mediasfu.com/user-guide) |
| Test before integrating | [MediaSFU sandbox](https://www.mediasfu.com/sandbox) |
| Prototype embeddable experiences | [Widget Studio](https://www.mediasfu.com/widget-studio) |
| Self-host the media backend | [MediaSFU Open](https://github.com/MediaSFU/MediaSFUOpen) |
| AI agents | [mediasfu.com/agents](https://www.mediasfu.com/agents) |
| AI notes | [mediasfu.com/ai-notes-guide](https://www.mediasfu.com/ai-notes-guide) |
| Translation | [mediasfu.com/translation](https://www.mediasfu.com/translation) |
| SIP / telephony | [mediasfu.com/telephony](https://www.mediasfu.com/telephony) |
| Community support | [mediasfu.com/forums](https://www.mediasfu.com/forums) |
| Contact | [mediasfu.com/contact](https://www.mediasfu.com/contact) |
| GitHub organization | [github.com/MediaSFU](https://github.com/MediaSFU) |

Complete products and staged examples:

- [MediaSFU QuickStart Apps](https://github.com/MediaSFU/MediaSFU-QuickStart-Apps) — Cloud, MediaSFU Open, backend-proxy, custom-prejoin, and custom-UI starters.
- [SpacesTek Initial](https://github.com/MediaSFU/SpacesTekInitial) → [Final](https://github.com/MediaSFU/SpacesTekFinal) → [Advanced](https://github.com/MediaSFU/SpacesTekAdvanced) — a progressive app-owned collaboration product.
- [MediaSFU Agents](https://github.com/MediaSFU/Agents) — multimodal voice/vision agent clients.
- [MediaSFU VOIP](https://github.com/MediaSFU/VOIP) — telephony, dialer, and human/agent handoff clients.

For faster help, include the `mediasfu_sdk` version, Flutter target, chosen room widget, backend mode (MediaSFU Cloud or `localLink`), exact error text, and a minimal reproducible snippet. Those details also give coding assistants the context needed to suggest the correct MediaSFU APIs.

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

### Host leave and rejoin

The host exit modal now offers **Leave room** and **End for everyone**. Programmatic callers can keep the room active with `ConfirmExitOptions(..., endRoomOnHostExit: false)` or `leaveRoom(parameters, endRoomOnHostExit: false)`. The default remains `true`.

MIT. See [LICENSE](./LICENSE).
