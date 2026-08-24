/// Headless helpers: everything an app-owned Flutter UI needs from a MediaSFU
/// room, without rendering any MediaSFU UI.
///
/// See HEADLESS_GUIDE.md for the full reference and for what is deliberately
/// **not** here — several React helpers depend on browser APIs (canvas capture,
/// MediaPipe, hls.js) that have no Flutter equivalent and are documented as
/// platform gaps rather than silently omitted.
library;

export 'get_media_streams.dart';
export 'get_room_readiness.dart';
export 'get_current_params.dart';
export 'participant_state.dart';
export 'headless_controller.dart';
export 'media_permissions.dart';
export 'media_production.dart';
export 'moderation.dart';
export 'room_actions.dart';
export 'session_features.dart';
export 'session_controls.dart';
export 'session_extras.dart';
export 'viewer_session.dart';
