# Translation voice catalogue

The socket helper accepts an optional joined-room context:

```dart
final result = await fetchVoicesViaSocket(socket, 'configured', 'zh', roomName: joinedRoom);
```

The server chooses the actual credential/provider. The provider argument is a compatibility hint, not an override. Consume result.provider/model/status/schemaVersion/truncated and male/female/neutral voice groups. Neutral means unspecified gender; do not infer gender from names. Unknown providers, timeouts, malformed replies and provider errors do not create Deepgram fallback IDs. Explicit stock IDs must come from this room/output catalogue. Existing consented clone handling remains separate.

Modern pickers (and the private limited picker) refetch for room/output/provider-model changes, discard stale replies and clear stale selections. Lists scroll without the former six-voice cap. Automatic mode may retain provider defaults when the list is unavailable, so identity consistency cannot be promised then.

Source and offline tests are updated; package publication and physical-device/real translated audio acceptance are separate release states. This does not implement the deferred microphone-track recovery or ICE/DTLS telemetry work.
