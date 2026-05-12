# MediaSFU Flutter SDK Guide

> Need the lightweight package overview first? See [README.md](./README.md).
> Need platform permissions and native project setup? See [PLATFORM_SETUP.md](./PLATFORM_SETUP.md).

`mediasfu_sdk` is the Flutter package for shipping MediaSFU-powered calling, conferencing, webinars, chat, recording, whiteboards, translation, and custom room experiences across Android, iOS, Web, macOS, Windows, and Linux.

This guide focuses on the Flutter package itself:

- what the package exports
- how to connect it to MediaSFU Cloud or MediaSFU Open
- when to use the prebuilt widgets vs. headless mode
- how to customize UI with builders and overrides
- how to use the room helpers and media utilities safely

## What Ships In The Package

The public barrel file is `package:mediasfu_sdk/mediasfu_sdk.dart`. It exports the package barrels in `lib/`:

- `components.dart` for widgets and widget option classes
- `methods.dart` for user actions, launch helpers, and utilities
- `producers.dart` and `consumers.dart` for advanced media and signaling helpers
- `misc.dart` and `types.dart` for shared types and contracts

At the product level, most Flutter apps start from one of these widgets:

| Widget | Best for |
| --- | --- |
| `MediasfuGeneric` | General-purpose room UI with the widest configuration surface |
| `MediasfuConference` | Meeting-style layouts with participant and collaboration tools |
| `MediasfuWebinar` | Host/panelist-focused experiences |
| `MediasfuBroadcast` | Broadcast-style experiences with presenter emphasis |
| `MediasfuChat` | Chat-first MediaSFU rooms |
| `ModernMediasfuGeneric` | The modern Flutter UI path with the same underlying room/runtime model |

All of the prebuilt experiences share the same core ideas:

- a pre-join flow that creates or joins rooms
- MediaSFU signaling and mediasoup transport orchestration
- access to a `MediasfuParameters` helper bundle for advanced control
- custom builders and UI overrides when you outgrow the stock layout

## Backend Model

This package is a frontend SDK. It needs a MediaSFU-compatible backend for room creation, signaling, and media routing.

| Backend | Use it when | What you pass |
| --- | --- | --- |
| MediaSFU Cloud | You want the managed platform | `Credentials(apiUserName, apiKey)` |
| MediaSFU Open / self-hosted | You control the server deployment | `localLink` and, when needed, local backend auth fields |

The built-in room helpers target MediaSFU Cloud by default:

- `createRoomOnMediaSFU` posts to `https://mediasfu.com/v1/rooms`
- `joinRoomOnMediaSFU` posts to `https://mediasfu.com/v1/rooms/`

If you pass a non-MediaSFU `localLink`, those helpers switch to:

- `${localLink}/createRoom`
- `${localLink}/joinRoom`

### Security note

Do not ship real production credentials directly in a public client app unless that is an intentional part of your threat model. For production apps, prefer a backend proxy that stores the real API credentials and returns only the room data or tokens your Flutter app needs.

## Installation

Add the package:

```bash
flutter pub add mediasfu_sdk
```

Base requirements from `pubspec.yaml`:

- Flutter `>=1.17.0`
- Dart `>=3.3.3 <4.0.0`

### Optional feature dependencies

The published package keeps platform-specific dependencies out of the default pub.dev install path when possible. Add the extras your app actually needs:

```yaml
# Android / iOS virtual backgrounds
google_mlkit_selfie_segmentation: ^0.10.0

# Web whiteboard and capture helpers
web: ^1.1.1
dart_webrtc: ^1.4.6
```

| Feature | Dependency | Platforms |
| --- | --- | --- |
| Virtual backgrounds | `google_mlkit_selfie_segmentation` | Android, iOS |
| Whiteboard canvas helpers | `web`, `dart_webrtc` | Web |

Platform permission and host app setup still matter. Use [PLATFORM_SETUP.md](./PLATFORM_SETUP.md) for:

- Android permissions
- iOS and macOS privacy keys / entitlements
- Web HTTPS guidance
- Windows and Linux desktop notes

## Quick Start

The fastest path is `MediasfuGeneric` with MediaSFU Cloud credentials.

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

For a room that joins against your own server instead of MediaSFU Cloud, pass a `localLink`:

```dart
MediasfuGeneric(
  options: MediasfuGenericOptions(
    localLink: 'http://localhost:3000',
    connectMediaSFU: true,
    credentials: Credentials(
      apiUserName: 'local-proxy-user',
      apiKey: 'your-64-character-api-key',
    ),
  ),
)
```

## Choosing An Experience Widget

All of the room widgets follow the same options pattern. Choose the widget that best matches the room you are building, then swap in a different experience later without rewriting your backend wiring.

```dart
MediasfuConference(options: MediasfuConferenceOptions(...))
MediasfuWebinar(options: MediasfuWebinarOptions(...))
MediasfuBroadcast(options: MediasfuBroadcastOptions(...))
MediasfuChat(options: MediasfuChatOptions(...))
ModernMediasfuGeneric(options: ModernMediasfuGenericOptions(...))
```

In practice, the easiest development loop is:

1. Start with `MediasfuGeneric` or `ModernMediasfuGeneric`.
2. Validate the backend and permissions.
3. Move to the event-specific widget when you know your final room mode.
4. Introduce builders or overrides only when you need them.

## The Three Usage Modes

The Flutter package supports three broad integration styles.

### 1. Prebuilt UI

This is the default path. MediaSFU renders the pre-join flow, room UI, control bars, modals, and participant surfaces for you.

```dart
MediasfuWebinar(
  options: MediasfuWebinarOptions(
    credentials: Credentials(
      apiUserName: 'your-api-username',
      apiKey: 'your-64-character-api-key',
    ),
  ),
)
```

Use this when you want the fastest route to production or when you only need light branding and targeted overrides.

### 2. Headless / no-UI mode

Set `returnUI: false` to keep the MediaSFU runtime alive while your app owns the screen.

```dart
import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

class HeadlessRoomDemo extends StatefulWidget {
  const HeadlessRoomDemo({super.key});

  @override
  State<HeadlessRoomDemo> createState() => _HeadlessRoomDemoState();
}

class _HeadlessRoomDemoState extends State<HeadlessRoomDemo> {
  MediasfuParameters? _parameters;

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
            updateSourceParameters: (value) {
              setState(() => _parameters = value);
            },
            noUIPreJoinOptionsJoin: JoinMediaSFURoomOptions(
              action: 'join',
              meetingID: 'room123',
              userName: 'Ada',
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _parameters == null
                    ? null
                    : () => _parameters!.clickAudio(
                          ClickAudioOptions(parameters: _parameters!),
                        ),
                child: const Text('Toggle Mic'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _parameters == null
                    ? null
                    : () => _parameters!.clickVideo(
                          ClickVideoOptions(parameters: _parameters!),
                        ),
                child: const Text('Toggle Camera'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

Use this when:

- your app already owns the full page shell
- you want MediaSFU transports and state, but not the stock UI
- you are progressively migrating from stock MediaSFU UI to a custom interface

### 3. Custom UI on top of the MediaSFU runtime

If you still want MediaSFU to render most of the room but need to swap specific surfaces, use:

- `customVideoCard`
- `customAudioCard`
- `customMiniCard`
- `customComponent` / `customWorkspaceBuilder`
- `uiOverrides`

This is the right path when you want a branded product surface without rebuilding the entire media/session layer from scratch.

## Shared Options Reference

`MediasfuGenericOptions`, `MediasfuConferenceOptions`, `MediasfuWebinarOptions`, `MediasfuBroadcastOptions`, and `MediasfuChatOptions` share the same core fields.

| Option | Type | Default | Purpose |
| --- | --- | --- | --- |
| `preJoinPageWidget` | `PreJoinPageType?` | built-in pre-join flow | Replace the stock pre-join widget |
| `localLink` | `String?` | `''` | Point to MediaSFU Open or your own compatible backend |
| `connectMediaSFU` | `bool?` | `true` | Enables socket/WebRTC connection behavior |
| `credentials` | `Credentials?` | `null` | Cloud credentials for MediaSFU-hosted flows |
| `useLocalUIMode` | `bool?` | `null` | Run UI/demo paths without contacting a backend |
| `seedData` / `useSeed` | `SeedData?` / `bool?` | `null` | Pre-populate room state for demos and previews |
| `imgSrc` | `String?` | MediaSFU artwork | Replace default artwork |
| `sourceParameters` | `MediasfuParameters?` | `null` | Feed an existing helper bundle back into the widget |
| `updateSourceParameters` | `void Function(MediasfuParameters?)?` | `null` | Capture helper state/actions for headless or hybrid flows |
| `returnUI` | `bool?` | `true` | Set to `false` for headless mode |
| `noUIPreJoinOptionsCreate` | `CreateMediaSFURoomOptions?` | `null` | Prejoin payload for headless create flows |
| `noUIPreJoinOptionsJoin` | `JoinMediaSFURoomOptions?` | `null` | Prejoin payload for headless join flows |
| `joinMediaSFURoom` | `JoinRoomOnMediaSFUType?` | built-in helper | Replace room-join networking |
| `createMediaSFURoom` | `CreateRoomOnMediaSFUType?` | built-in helper | Replace room-create networking |
| `customVideoCard` | `VideoCardType?` | `null` | Replace participant video cards |
| `customAudioCard` | `AudioCardType?` | `null` | Replace participant audio cards |
| `customMiniCard` | `MiniCardType?` | `null` | Replace mini/tile cards |
| `customComponent` | `CustomComponentType?` | `null` | Replace the entire MediaSFU layout |
| `customWorkspaceBuilder` | `CustomWorkspaceBuilder?` | `null` | Alias for full-workspace replacement |
| `containerStyle` | `ContainerStyleOptions?` | `null` | Apply root-level layout and decoration control |
| `uiOverrides` | `MediasfuUICustomOverrides?` | `null` | Override specific components/functions without replacing the full UI |

### Modern-only extras

`ModernMediasfuGenericOptions` adds a few deployment and UX fields that do not exist on every classic options class.

| Option | Purpose |
| --- | --- |
| `localAppKey` | Send an app-level key to local backends during handshake |
| `localApiUserName` / `localApiKey` | Local backend auth values when your deployment expects them |
| `localSubUserName` | Sub-account or org-member identifier for local deployments |
| `initialMeetingId` | Pre-fill the meeting id in the pre-join flow |
| `onBack` | Override default back navigation behavior |
| `canUsePersonalTranslation` | Allow translation billing against a user-level account |
| `personalTranslationUsername` | Username paired with personal translation mode |
| `userVoiceClones` | Provide available voice clone metadata to translation UI |
| `optimizeVideoRecord` | Preserve the video-orientation RTP extension to improve recording fidelity |

## Room Create/Join Helpers

The package exports room helper functions if you want to call MediaSFU directly instead of relying on the built-in pre-join UX.

### Create a room

```dart
final result = await createRoomOnMediaSFU(
  CreateMediaSFUOptions(
    payload: CreateMediaSFURoomOptions(
      action: 'create',
      userName: 'Host',
      duration: 60,
      capacity: 25,
    ),
    apiUserName: 'your-api-username',
    apiKey: 'your-64-character-api-key',
    localLink: '',
  ),
);
```

### Join a room

```dart
final result = await joinRoomOnMediaSFU(
  JoinMediaSFUOptions(
    payload: JoinMediaSFURoomOptions(
      action: 'join',
      meetingID: 'room123',
      userName: 'Guest',
    ),
    apiUserName: 'your-api-username',
    apiKey: 'your-64-character-api-key',
    localLink: '',
  ),
);
```

Use custom `joinMediaSFURoom` / `createMediaSFURoom` implementations when:

- your backend should proxy room creation and joining
- you need analytics or request signing around room APIs
- you want to hide raw MediaSFU credentials from the client

## Working With `MediasfuParameters`

When you capture `MediasfuParameters` through `updateSourceParameters`, you get access to the package's live room state and helper actions.

Common uses:

- toggle camera, microphone, or screen share
- inspect participants, streams, layout state, and room params
- open MediaSFU modals from your own UI shell
- coordinate custom recording, translation, or whiteboard UI

Typical helper calls from custom UI:

```dart
await parameters.clickVideo(ClickVideoOptions(parameters: parameters));
await parameters.clickAudio(ClickAudioOptions(parameters: parameters));
await parameters.clickScreenShare(
  ClickScreenShareOptions(parameters: parameters),
);
```

### Utility methods exported by the package

The package also exports lightweight media utilities that are useful even outside the default room widgets.

#### `getMediaDevicesList`

```dart
final cameras = await getMediaDevicesList('videoinput');
final microphones = await getMediaDevicesList('audioinput');
```

#### `getParticipantMedia`

```dart
final stream = await getParticipantMedia(
  GetParticipantMediaOptions(
    id: 'producer-id-123',
    kind: 'video',
    parameters: parameters,
  ),
);
```

Use these utilities for device pickers, diagnostics, custom media dashboards, or participant spotlight tooling.

## UI Overrides

`MediasfuUICustomOverrides` lets you replace or wrap specific pieces of the stock Flutter UI without replacing the full room surface.

Two primitives power the system:

- `ComponentOverride<TOptions>` for widgets
- `FunctionOverride<TFunction>` for runtime helpers

### Example

```dart
final uiOverrides = MediasfuUICustomOverrides(
  mainContainer: ComponentOverride<MainContainerComponentOptions>(
    render: (context, options, defaultBuilder) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.blueAccent, width: 2),
        ),
        child: defaultBuilder(context, options),
      );
    },
  ),
  messagesModal: ComponentOverride<MessagesModalOptions>(
    component: (context, options) => MyMessagesModal(options: options),
  ),
  consumerResume: FunctionOverride<ConsumerResumeType>(
    wrap: (original) {
      return (options) async {
        final startedAt = DateTime.now();
        await original(options);
        debugPrint(
          'consumerResume took ${DateTime.now().difference(startedAt)}',
        );
      };
    },
  ),
);
```

### Override keys

#### Layout and display

| Key |
| --- |
| `mainContainer` |
| `mainAspect` |
| `mainScreen` |
| `mainGrid` |
| `subAspect` |
| `otherGrid` |
| `flexibleGrid` |
| `flexibleGridAlt` |
| `flexibleVideo` |
| `audioGrid` |
| `pagination` |
| `controlButtons` |
| `controlButtonsAlt` |
| `controlButtonsTouch` |
| `meetingProgressTimer` |
| `miniAudio` |
| `miniAudioPlayer` |

#### Modals and collaboration surfaces

| Key |
| --- |
| `loadingModal` |
| `alert` |
| `menuModal` |
| `customMenuButtonsRenderer` |
| `eventSettingsModal` |
| `requestsModal` |
| `waitingRoomModal` |
| `coHostModal` |
| `mediaSettingsModal` |
| `participantsModal` |
| `messagesModal` |
| `displaySettingsModal` |
| `confirmExitModal` |
| `confirmHereModal` |
| `shareEventModal` |
| `recordingModal` |
| `pollModal` |
| `breakoutRoomsModal` |
| `configureWhiteboardModal` |
| `screenboardModal` |
| `whiteboard` |
| `screenboard` |
| `backgroundModal` |
| `preJoinPage` |
| `welcomePage` |

#### Runtime function overrides

| Key |
| --- |
| `consumerResume` |
| `addVideosGrid` |
| `prepopulateUserMedia` |

Use overrides when you want to preserve MediaSFU behavior but re-skin, wrap, instrument, or partially replace the stock Flutter UI.

## Custom Builders And Full Workspace Replacement

If you only need to swap participant surfaces, use the builder hooks instead of full UI overrides.

```dart
MediasfuGeneric(
  options: MediasfuGenericOptions(
    credentials: Credentials(
      apiUserName: 'your-api-username',
      apiKey: 'your-64-character-api-key',
    ),
    customVideoCard: myVideoCard,
    customAudioCard: myAudioCard,
    customMiniCard: myMiniCard,
  ),
)
```

If your app owns the entire layout, use `customComponent` or `customWorkspaceBuilder`.

```dart
MediasfuGeneric(
  options: MediasfuGenericOptions(
    credentials: Credentials(
      apiUserName: 'your-api-username',
      apiKey: 'your-64-character-api-key',
    ),
    customWorkspaceBuilder: ({required parameters}) {
      return MyWorkspace(parameters: parameters);
    },
  ),
)
```

That path is ideal when MediaSFU should manage the media/session layer, but your product already has an established Flutter navigation shell and design system.

## Demo Mode And Seeded UI

Use local/demo mode when you want to design or QA the UI without connecting to a live backend.

```dart
MediasfuGeneric(
  options: MediasfuGenericOptions(
    useLocalUIMode: true,
    useSeed: true,
    seedData: SeedData(
      member: 'DemoUser',
      eventType: EventType.conference,
    ),
  ),
)
```

This is useful for:

- design reviews
- snapshot and visual testing
- app-store preview captures
- experimentation with custom builders and overrides

## Modern UI Path And Playbook Entry Points

The repository includes multiple entry files that are worth browsing while you integrate:

- `lib/main.dart` for a broad package playground
- `lib/main_generic.dart` for generic-room examples
- `lib/main_conference.dart` for conference-specific flows
- `lib/main_webinar.dart` for webinar-specific flows
- `lib/main_broadcast.dart` for broadcast-specific flows
- `lib/main_chat.dart` for chat-first examples
- `lib/main_modern.dart` for the modern room UI path
- `lib/main_unique.dart` for an interactive playbook
- `lib/main_playbook_core.dart` for a code-only variant of the playbook

Those files are especially useful when you want copy-pasteable examples for:

- `returnUI: false`
- source parameter capture
- custom builders
- `uiOverrides`
- seeded demo scenarios

## Feature Areas You Can Build With Today

The package surface already includes the major MediaSFU collaboration building blocks:

- conferencing, webinar, broadcast, and chat room modes
- screen sharing and screen annotation
- recording controls and recording-state modals
- polls and breakout room support
- participant moderation, permissions, and panelists flows
- live translation / transcription surfaces
- whiteboard and screenboard collaboration
- virtual backgrounds on supported platforms

Use the prebuilt widgets when you want the fastest route to these features, then adopt overrides or custom builders only for the surfaces that need product-specific behavior.

## Troubleshooting

### The room never connects

Check these first:

- your `apiUserName` and `apiKey` are valid for MediaSFU Cloud
- `localLink` points to the correct self-hosted server if you are not using Cloud
- your app has network permission and can reach the backend

### The UI is fine, but I do not want live connections while building

Use `useLocalUIMode: true` with optional `useSeed: true`.

### Headless mode renders nothing

That is expected when `returnUI: false`. Provide your own widgets and capture `MediasfuParameters` through `updateSourceParameters`.

### Web media does not behave correctly in local testing

For realistic web validation:

- test on HTTPS, not only localhost
- verify browser media permissions
- validate STUN/TURN and backend reachability from the deployed host

### Device labels are empty

`getMediaDevicesList` may need a user permission grant before browsers expose device labels. Trigger it from a user gesture and ensure camera or microphone permissions are allowed.

## Suggested Integration Path

1. Start with `MediasfuGeneric` or `ModernMediasfuGeneric`.
2. Validate backend connectivity and platform permissions.
3. Decide whether you want stock UI, headless mode, or selective overrides.
4. Add custom builders first; move to full `customComponent` only if necessary.
5. Keep real credentials on a backend proxy whenever possible.

## Links

- Package overview: [README.md](./README.md)
- Platform configuration: [PLATFORM_SETUP.md](./PLATFORM_SETUP.md)
- MediaSFU docs portal: <https://www.mediasfu.com/documentation>
- MediaSFU user guide: <https://www.mediasfu.com/user-guide>
- MediaSFU Open: <https://github.com/MediaSFU/MediaSFUOpen>
- GitHub issues: <https://github.com/MediaSFU/MediaSFU_SDK_Flutter/issues>

## License

MIT. See [LICENSE](./LICENSE).
