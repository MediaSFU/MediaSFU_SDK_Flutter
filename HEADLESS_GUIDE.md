# MediaSFU Flutter — headless mode

Build a complete app-owned Flutter call interface while MediaSFU continues to
manage signaling, transports, room state, and media lifecycle. Headless mode
does not mean “no runtime”; it means your widgets own every visible surface.

Flutter has no DOM or browser media APIs, so the portable room, media,
moderation, and collaboration contracts are typed Dart helpers while genuinely
browser-only capabilities are reported explicitly in Section 4.

---

## 1. The one rule to internalise

**The parameter bag is a snapshot of values the SDK reassigns.** Every field you
read — `allVideoStreams`, `participants`, `consumerTransports` — is captured at
publication time, and the SDK replaces its internals as producers come and go.

Two consequences, and nearly every "my video is black" report breaks one of them:

1. **Take every publication.** De-duplicating or deep-comparing them freezes your
   UI on whatever it rendered first. It looks like an optimisation; it is a freeze.
2. **Read at use time, not at build time.** A bag captured in a widget's fields
   goes stale; read it inside `build` or from the callback that delivered it.

## 2. Media resolution

```dart
import 'package:mediasfu_sdk/methods.dart';

final remote = getRemoteVideoStreams(parameters);   // List<ResolvedMedia>
final local  = getLocalVideoStream(parameters);     // MediaStream?
final screen = getScreenShareStream(parameters);    // ScreenShareState
```

Each exists because the obvious hand-rolled version gets something wrong:

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

## 5. Verification

```bash
flutter test test/headless
```

The Dart tests pin producer-id matching, `'none'` handling, host/self
identification, roster ordering, permissions, viewer sessions, getter purity,
deferred publication, teardown guards, and embedded geometry.

**Verification status:** These headless APIs are integrated in the Familiar Calls
Flutter application and are covered by static analysis, automated Dart tests,
and Android build, install, and launch checks. A live two-participant Flutter
media session is not yet part of the published acceptance evidence. Before a
production rollout, validate create and join flows, local and remote media, call
controls, leave and end behavior, and teardown on every target platform you
support.
