### 2.4.2

* **Unmute in audio-only rooms.** The microphone could not be turned on in rooms created with `mediaType: "audio"` (it showed a camera message). Audio-only rooms now only block cameras.
* **Readable names.** Video and audio cards, participant lists and the join notice show a member's `displayName` when the room has one, falling back to the member name. New `Participant.displayName` and `Participant.label` getters.
* **Waiting rooms for API rooms.** When a room uses a waiting room, a guest joining through the SDK now waits until the host lets them in and then joins by itself; a declined guest or an ended room gets a clear message. No integrator work; progress is published for custom screens (`addWaitingRoomListener`, `cancelWaitingRoom()`).
* New room-create options: `region` (`asia`, `europe`, `us`, `general`), `regionStrict` (refuse instead of placing the room in another region) and `waitRoom`. Servers that do not support them ignore them.
* **Modern room with a side panel open.** On desktop the video area now fills the space beside an open panel (participants, chat and others); it was shrunk twice and left an empty gap. In the participants panel, narrow rows show mute, message and remove in one menu so names stay readable.

### 2.4.1

* **One send transport per connection.** Concurrent callers reuse the transport being created, and simultaneous produces of the same kind share one producer. Fixes devices that sent silence after a quick rejoin or device switch.
* **No connect loop after a permanent refusal.** A refusal for invalid credentials, an invalid request or no meeting minutes is remembered for the same link and credentials (10 minutes; 60 seconds for meeting minutes), so calling `connectSocket` again returns the same `MediaSocketConnectException` at once instead of opening another connection. A success forgets it; `clearRefusedMediaCredentials()` forgets everything.

### 2.4.0

* **Screen-share audio (web).** In Chromium desktop browsers a screen share can carry the tab or screen audio: a "Share audio too?" dialog offers **Screen + audio** or **Screen only**, the audio is published as its own track that pauses and stops with the share, and the sharer is never shown as speaking because of it. Every platform plays it, with a "*name* · Screen audio" card listeners can mute. Configure with `MediasfuScreenAudio.mode`, `MediasfuScreenAudio.enabled` and `MediasfuScreenAudio.prompt`; the sharer can mute it with `MediasfuScreenAudio.toggle`. Native apps and media servers without support keep video-only sharing.
* **Consumer backup preference.** When a busy consuming node has a connected backup, new streams are taken from the backup when it announces them within 1.5 seconds; otherwise from the busy node as before.
* **Clear connection errors.** `connectSocket` throws `MediaSocketConnectException` with the failure `phase`, `elapsedMs`, the web `online` state, the server's rejection `reason` and `stage`, `retryable` and a ready-to-show `userMessage`. Join pages show that message, refused credentials are not retried in a loop, and network failures no longer count toward the join attempt limit.
* **Rejoin after a reload, one connection per participant.** The SDK remembers the room credential for a room and name and proves it when registering again, and reuses it if the server still refuses the name. When another tab or device takes over, a dialog says "You joined from another tab or device." and offers **Use this one** (reconnects deliberately); the SDK never rejoins on its own. New exports: `sessionReplaced`, `wasSessionReplaced`, `rememberRejoinCredential`, `readRejoinCredential`, `forgetRejoinCredential`. Needs media servers with participant-rejoin support; older servers behave as before.
* **One send transport per connection.** Turning the microphone and camera on together (or a rejoin during a toggle) could create two producer transports on one socket, leaving that device's microphone silent. Transport creation now runs once per socket; later requests wait for it and produce on the same transport, and a second produce of the same source while one is in flight is skipped.
* **Refused connections are not retried.** A permanent refusal from the media server (invalid credentials, invalid request, no meeting minutes) is remembered for those credentials, so calling `connectSocket` again fails at once instead of opening another connection (10 minutes; 60 s for meeting minutes). A reconnect refused for good after joining closes the socket. `clearRefusedMediaCredentials()` resets it.

### 2.3.8

* Use one full-resolution camera encoding in chat rooms and rooms with configured capacity two; preserve simulcast in larger rooms by default.
* Add `simulcastOff` to classic and modern generic options for an explicit camera simulcast opt-out, plus a `roomCapacity` hint for older servers.
* Read optional configured capacity from room-join responses. Server capacity takes precedence over caller hints.
* Preserve single-encoding bitrate and frame-rate options in both local and remote camera send transports.
* Keep recording-enabled and non-recording camera bitrate budgets identical; add regression coverage for quality scaling, source-preset isolation, and successive room updates.

### 2.3.7

* Fix remote audio/video reception when a consume-room join returns the typed `ResponseJoinRoom` response. A successful join now retains its consume socket instead of disconnecting it during cleanup.
* Align the consume-room callback type with its actual response and clear failed endpoint registrations so retries remain possible.
* Build room video encodings from fresh presets so repeated resolution updates cannot compound bitrate multipliers across calls or rooms.

### 2.3.6

* Expose the optional `backendAudioDenoise` room-create policy and preserve it in `MeetingRoomParams` serialization. Omitting it retains the account preset; explicit `enabled: false` remains an opt-out.
* Keep the lone side-panel video tile fully visible during screen sharing, even when cover/full-display is selected.
* Preserve the existing consume-transport, audio-processing, and reconnect improvements included in this release candidate.

### 2.3.5

* Declare the validated Linux desktop platform explicitly so pub.dev displays it alongside the existing desktop and mobile targets.
* Fix consume-socket lifecycle cleanup across room changes and reconnects.
* Dispose failed consume-room joins instead of leaving untracked sockets alive.
* Remove disconnected endpoint registrations so the same endpoint can reconnect without a hard refresh.
* Remove admission listeners after socket success or failure and retain the 12-second admission timeout.

### 2.3.4

* Reduce unnecessary startup work for headless and standard room interfaces while preserving existing parameter interfaces.
* Initialize prebuilt UI builders only when needed. Engine-only sessions using `returnUI: false` skip the standard room UI; custom interfaces and `ModernMediasfuGenericHead` remain supported.
* Update `flutter_webrtc` to `^1.6.2+hotfix.3`.
* Improve example listener cleanup and remove a duplicate classic display-settings modal.
* Complete the Android example's media permission declarations and screen-wake-lock integration. See `PLATFORM_SETUP.md` for host-app requirements.
* Report unavailable Android screen-sharing integration without proceeding into native capture.
* Expand lifecycle, Android configuration, and startup regression coverage.

### 2.3.3
* **Recording controls and layout reporting**:
  - Report the room layout to the recorder as soon as a recording starts, rather than waiting for the next participant or screen change.
  - The live recording indicator in the control bar now responds only to its Pause/Resume and Stop controls. Taps elsewhere on the indicator no longer open recording settings during a recording.
  - Enlarged the Pause/Resume and Stop touch targets and added accessible labels to both.

### 2.3.2
* **Consume socket de-duplication**:
  - Serialize concurrent consume-endpoint setup so overlapping room updates cannot create duplicate sockets.
  - Keep failed connection attempts retryable without reintroducing the race.

### 2.3.1
* **Headless rendering and release refinements**:
  - Refined embedded/headless room sizing and media-rendering contracts for custom UIs.
  - Improved virtual-background and local-media selection guidance for camera-on and camera-off flows.
  - Hardened room/session teardown and late callback handling after leave or reconnect.
  - Clarified custom-component, backend-proxy, and platform setup documentation for production apps.

### 2.3.0
* **Headless and embedded-room release**:
  - Added public headless helpers for room readiness, participant/media state, production controls, playback, moderation, and session actions.
  - Added pure current-parameter reads for render and polling paths, while retaining explicit parameter publication for state updates.
  - Added embedded-container sizing across the main container, aspect, and screen boundaries without changing full-page defaults.
  - Guarded late send-transport callbacks after teardown.
  - Added the host option to leave without ending the room, while preserving end-on-exit as the default.
  - Expanded public guidance for prebuilt UI, overrides, headless rendering, backend proxies, MediaSFU Cloud, and self-hosted MediaSFU Open.

### 2.2.9
* **Compatibility and dependency updates**:
  - Fixed static analysis on Flutter 3.44+ after `CupertinoPageTransitionsBuilder` moved to the Cupertino library.
  - Updated `mediasfu_mediasoup_client` to 0.1.4 and `flutter_webrtc` to 1.5.2.
  - Updated direct dependency baselines to their latest compatible releases.
  - Aligned the declared Dart and Flutter minimums with the supported dependency graph.

### 2.2.8
* **Minor Improvements**:
  - Minor UI enhancements and bug fixes across all components.

### 2.2.7
* **Minor Improvements**:
  - Updated `font_awesome_flutter` to version 11.0.0 for access to the latest icons and features.
  - Improved error handling and logging in permission-related socket receive methods.
  - Updated `flutter_webrtc` to version 1.4.1 for enhanced compatibility and performance.

### 2.2.6
* **Minor Bug Fixes**:
  - Resolved minor UI glitches in custom builder implementations.
  - Improved error handling and logging for custom builder functions.
  - Updated documentation with clearer examples for custom builder usage.

### 2.2.5
* **Major Bug Fixes**:
  - UI stability improvements across all components, especially in no-UI mode.
  - Resolved edge cases in custom builder implementations to prevent crashes.

### 2.2.4

* **Documentation Overhaul**:
  - New lightweight, usage-focused `README.md` following modern SDK patterns.
  - Moved comprehensive API reference to `README_DETAILED.md`.
  - Added `PLATFORM_SETUP.md` with detailed platform-specific configuration guides.

* **Modern UI Components**:
  - Documented `ModernMediasfuGeneric` with theme-aware glassmorphism design.
  - Added `MediasfuColors` design system documentation.

* **New Features Documented**:
  - **Panelists Mode**: Dedicated panel for webinar/broadcast presenters.
  - **Permissions System**: Individual and group-level media/feature permissions.
  - **Real-time Translation**: 50+ language support with speech-to-text.

* **Dependencies**:
  - Added `image_picker`, `cached_network_image`, `path_provider` for background/image handling.
  - Added `path_drawing`, `share_plus` for whiteboard functionality.
  - Platform-specific deps (`google_mlkit_selfie_segmentation`, `web`, `dart_webrtc`) documented as optional.
  - Upgraded all dependencies to latest compatible versions.

### 2.2.3

* Updated to latest mediasfu_mediasoup_client version for Chrome 140 support.

### 2.2.2

* Added custom overrides for all UI components in the SDK.
* Updated README.md with more easy-to-follow examples for overrides and complete usage.

### 2.2.1

* Updated README.md with more easy-to-follow examples for custom builders and complete custom interface usage.
* Added `getMediaDevicesList` function to `MediasfuParameters` for retrieving available media devices.
* Added `getParticipantMedia` function to `MediasfuParameters` for accessing media (video/audio) of specific participants.

### 2.2.0

* Custom builders support for VideoCard, AudioCard, and MiniCard components.
* Complete custom interface support using `CustomComponentType`.
* Return `CustomComponent` instances from the builders as well as the full display widgets.
* PCMU and PCMA audio codec support.
* Chrome 140 video production fix in progress.

### 2.1.9

* Support for the latest version of WebRTC.

### 2.1.8

* Bug fix for screen sharing not displaying in the correct video for the sharer.
* Update in order of simulcast layers for video quality.

### 2.1.7

* Support for current version of WebRTC.

### 2.1.6

* Bug fix for no-UI mode setState called after dispose.

### 2.1.5

* Bug fix for using custom join/create functions for room.

### 2.1.4

* Bug fix for event types defaulting to 'chat' for no-UI mode.

### 2.1.3

* Bug fix for 'setState' called after dispose for no-UI mode.
* Bug fix for 'MediasfuConference not supporting no-UI mode.

### 2.1.2

* Bug fix for 'MediasfuGeneric' handling of updateSourceParameters.
* Allowed null source parameters for all default views.

### 2.1.1

* README.md update and types_alt.dart file removal.

### 2.1.0

* Added support for the latest version of the MediaSFU server.
* Added no-UI option for the SDK to enable developers to use the SDK without the default UI components.

### 2.0.1

* Minor fix for initial values.

### 2.0.0

* Major refactor of the SDK to support the latest version of the MediaSFU server.
* Support provided for MediaSFU Community Edition.

### 1.0.0

* Major refactor of the SDK to support the latest version of the MediaSFU server.
* Explicit options declaration/requirement for classes.
* Added support for FHD and QHD video resolutions.

### 0.0.7

* Bug fix for interval updates of loudness.

### 0.0.6

* Mini audio player bug fix.

### 0.0.5

1. **Updated flutter_webrtc support**:
   * Enhanced compatibility and performance with the latest version of `flutter_webrtc`.

2. **General bug fixes**:
   * Resolved various issues to improve overall stability and reliability.

3. **Added Polls support**:
   * Introduced functionality to conduct real-time polls during sessions, allowing for instant feedback and interaction.

4. **Added Breakout rooms support**:
   * Enabled the creation of multiple sub-meetings within a single session to facilitate focused group discussions and collaboration.

### 0.0.4

* Minor update in README.md.

### 0.0.3

* Cleanup of warnings for static analysis pass.

### 0.0.2

#### Changes

* Removed dependence on `permission_handler` to broaden platform support.
* Updated QR code scanning functionality to utilize `mobile_scanner`.
* Moved QR code scanner implementation to `welcome_page_qrcode.dart`.
* Removed the QR code scanner from the default 'welcome page'.

#### Notes

These updates enhance the MediaSFU Flutter SDK's versatility by eliminating dependency on specific permission handling libraries and integrating a more platform-agnostic QR code scanning solution. Developers can now leverage the SDK across a wider range of platforms while maintaining seamless QR code scanning functionality.
To use the QR code scanner pass the `welcome_page_qrcode.dart` as your `PrejoinPage` option for your event room.

Additionally, an example has been added to demonstrate the usage of the SDK's QR code scanning feature.

### 0.0.1

* Initial release of the MediaSFU Flutter SDK.
