# MediaSFU Flutter — headless mode

Build a complete app-owned Flutter call interface while MediaSFU continues to
manage signaling, transports, room state, and media lifecycle. Headless mode
does not mean “no runtime”; it means your widgets own every visible surface.

Flutter has no DOM or browser media APIs, so the portable room, media,
moderation, and collaboration contracts are typed Dart helpers while genuinely
browser-only capabilities are reported explicitly in Section 4.

---

## 1. Keep parameter snapshots current

**The parameter bag is a snapshot of values the SDK reassigns.** Every field you
read — `allVideoStreams`, `participants`, `consumerTransports` — is captured at
publication time, and the SDK replaces its internals as producers come and go.

Follow these two guidelines to keep your interface in sync:

1. **Accept every publication.** Filtering updates by object identity or deep
   equality can miss changes and leave your UI displaying stale state.
2. **Read at use time, not at build time.** A bag captured in a widget's fields
   goes stale; read it inside `build` or from the callback that delivered it.

## 2. Media resolution

```dart
import 'package:mediasfu_sdk/methods.dart';

final remote = getRemoteVideoStreams(parameters);   // List<ResolvedMedia>
final local  = getLocalVideoStream(parameters);     // MediaStream?
final screen = getScreenShareStream(parameters);    // ScreenShareState
```

These helpers handle common media-selection cases:

| Trap | What you see |
| --- | --- |
| `youyou` self-marker in the remote list | you appear as your own remote participant |
| one producer arriving as two entries | the same person rendered twice |
| de-duplicating by object identity | still twice |
| no liveness check | a tile holding a track that already ended |
| screen routed through the camera path | mirrored and cropped |

### The `muted` trap — the expensive one

Never gate attachment on `muted`:

> A remote track stays `muted` until its first frame decodes.
> No frame decodes until the track is attached.

Waiting for it deadlocks, and the symptom is a permanently black tile with no
error anywhere. **`enabled` is the meaningful flag** — it is local and
app-controlled. `muted` is sender-driven and transient.

### Screens are not cameras

`getScreenShareStream` is separate on purpose. A screen must **never** be
mirrored, and it wants `BoxFit.contain` — `cover` crops exactly the content
someone is pointing at. Faces want `cover`.

The remote screen is deliberately *not* `enabled`-gated, for the muted reason
above; the local one is.

## 3. Roster state

```dart
final roster = listParticipantMediaStates(parameters);
final host   = getRoomHost(parameters);
final ready  = getRoomReadiness(parameters);   // .ready, .reason
```

**A participant's `id` is their membership id and is never a producer id.** Video
and audio are found through `videoID` / `audioID`, and the SDK writes `'none'`
(or leaves them empty) while that track is off. Matching on `id` is why
hand-rolled rosters report everyone as camera-off — and it is the bug that was
fixed in `getParticipantMedia` in this release.

`getRoomReadiness` returns a reason, not just a boolean. Rendering controls
before `ready` produces buttons that silently do nothing; showing "connecting"
after it is the same bug in the other direction.

## 4. What ported, what changed, what cannot

Stated plainly so nothing is assumed.

### Portable headless surface

- `MediasfuHeadlessController` accepts every parameter publication and exposes
  readiness, local/remote audio and video, screen share, and participant state.
- `ModernMediasfuGenericHead` restores the complete standard modern interface
  from that same mounted room engine. It does not open a second socket or keep
  a second copy of room, media, sidebar, or modal state.
- Media resolution: `getRemoteVideoStreams`, `getRemoteAudioStreams`,
  `getLocalVideoStream`, `getLocalAudioStream`, `getScreenShareStream`, and
  `getAudioGridComponents`.
- Roster and readiness: `listParticipantMediaStates`, `getRoomHost`,
  `getRoomReadiness`, `getCurrentParams`, and `getParticipantMedia`.
- Room actions and policy: chat, leave/end, media permissions, moderation,
  participant approval, host/co-host policy, and prepopulation helpers.
- Session UI state/actions: recording, whiteboard, polls, breakout rooms,
  translation, focus, background, presence, and related room controls.
- Viewer sessions and safe media-production capability reads. Unsupported
  native operations return an explicit capability/reason instead of silently
  pretending to work.

### Changed shape
- **No index-signature bag.** React helpers take `{ parameters }` with a loose
  object; Dart takes typed `abstract class` parameter interfaces, so each helper
  declares exactly what it reads. That is stricter and better, but it means the
  call signature differs from the React docs.
- **Audio.** Flutter exposes prepared audio widgets through
  `getAudioGridComponents(parameters)` — render **all of them**.
  Slicing the list silences whoever falls off the end while they remain visibly
  present, which users report as "the call is broken".

### Cannot exist on Flutter
These are absent by necessity, not oversight:

| React helper | Why not |
| --- | --- |
| Browser canvas virtual-background production | Flutter uses its native segmentation/component path rather than an offscreen DOM canvas. Readable state is exposed; the browser mutation helper is not. |
| `produceCanvas`, `produceElement` | DOM-only by definition. |
| `attachPlayback` (HLS) | needs a Flutter player (`video_player`), not `hls.js`. The *contract* ports; the implementation does not. |
| `publishWhip` / WHEP playback | **portable** — `flutter_webrtc` has `RTCPeerConnection` and HTTP. Not yet written; no blocker. |

## Reuse SDK dialogs in your own layout

Keep `ModernMediasfuGeneric` mounted with `returnUI: false` and accept its
parameter publications. Your widgets can host SDK dialogs without rendering
the entire built-in room interface.

Use the room's visibility value and matching updater instead of a second
local Boolean. For recording, bind `isRecordingModalVisible` in the dialog
options and route `onClose` to `updateIsRecordingModalVisible(false)`; opening
uses the same updater with `true`. Pass the current typed room parameters
and required confirmation/start callbacks.

Retain the background widget's lifecycle while the room is mounted. Apply
supported style and layout options without replacing its processing or room
callbacks. Use Flutter's component options; React DOM props and canvas
helpers do not apply to native Flutter.

Headless mode does not display the built-in sidebar. Supply your own visible
panel or dialog host, while allowing the room to control permissions, state
changes, and teardown. A settings dialog being visible does not prove that a
background has been published or that recording has started.

For self-view, render the controller's resolved local-video value rather than a
raw camera track. The resolver follows Flutter's native virtual-background
state, so the preview and the published stream do not disagree.

For breakout rooms, reuse `ModernBreakoutRoomsModal` with the latest typed room
parameters when you want the built-in planner. Save assignments before Start
and render validation feedback in your own surface. A breakout transition is a
room-membership operation; filtering participant widgets alone cannot pause and
resume the correct consumers.

### Restore the complete modern UI from a headless engine

Use `ModernMediasfuGenericHead` when you want the standard modern room tree but
need the engine and visible surface to remain separately placeable in your
Flutter layout. Keep one `ModernMediasfuGeneric` mounted with `returnUI: false`,
accept every publication, and pass the latest bag to the head:

```dart
final room = MediasfuHeadlessController();

Stack(
  children: [
    ModernMediasfuGeneric(
      options: ModernMediasfuGenericOptions(
        returnUI: false,
        noUIPreJoinOptionsJoin: joinOptions,
        updateSourceParameters: room.updateSourceParameters,
      ),
    ),
    AnimatedBuilder(
      animation: room,
      builder: (context, _) {
        final parameters = room.parameters;
        if (parameters == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ModernMediasfuGenericHead(parameters: parameters);
      },
    ),
  ],
)
```

The head delegates rendering back to the engine that published `parameters`.
That is why it can use the exact standard tree instead of approximating it, and
why an application-created or stale parameter bag is intentionally rejected.
Dispose the controller with the surrounding screen and let the generic engine
own room teardown as usual.

## 5. Efficient lifecycle and debugging

Create `MediasfuHeadlessController`, `ModernMediasfuGenericOptions`, and the
headless room widget once in `initState` (or as stable state fields). Keep that
engine mounted for the entire call and use `AnimatedBuilder` to rebuild only
your app-owned surface. Avoid replacing the engine or changing its key on every
parameter update. Normal Flutter widget rebuilds do not, by themselves, recreate
an existing engine's state.

Version `2.3.4` reduces unnecessary startup work in both headless and standard
UI sessions. With `returnUI: false`, the engine skips the standard room UI and
initializes UI builders only if a custom surface or `ModernMediasfuGenericHead`
requests them. Room signaling and media ownership follow the same lifecycle.

If you encounter excessive memory use or an out-of-memory error during development:

1. check that the engine and app-owned controllers are disposed when the call ends;
2. use compatible SDK and WebRTC versions and complete the native setup in
   [PLATFORM_SETUP.md](./PLATFORM_SETUP.md);
3. compare with `flutter run --profile` to help identify debug/JIT overhead;
   profile succeeding is useful evidence, but does not by itself rule out a
   lifecycle issue;
4. report a minimal reproduction, Flutter and dependency versions, device details,
   and whether the issue occurs before joining, when enabling media, or over time.
   Include relevant diagnostic logs only after removing credentials, room tokens,
   participant information, and other private data.

Increasing emulator RAM can confirm memory pressure, but should not be the
first or only fix. A steadily growing profile/release process indicates a
possible lifecycle issue and should be investigated separately.

## 6. Verification

```bash
flutter test test/headless
flutter test test/parameter_hierarchy_test.dart
```

The Dart tests pin producer-id matching, `'none'` handling, host/self
identification, roster ordering, permissions, viewer sessions, getter purity,
deferred publication, teardown guards, and embedded geometry.

For a credential-free physical-device startup and repeated-mount check, run
`flutter run --debug -t lib/device_memory_smoke.dart` from `example/`. It cycles
through classic and modern headless and local-room UI modes. Local UI mode does
not establish a real meeting or validate media delivery.

Before releasing your application, test create and join flows, local and remote
media with at least two participants, call controls, reconnects, leave/end behavior,
and teardown on each supported platform. Automated tests and local UI checks
complement, but do not replace, live media testing on your target devices.
