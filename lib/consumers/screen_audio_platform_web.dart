import 'package:web/web.dart' as web;

/// Chromium desktop browsers (Chrome, Edge, Opera, Brave) can capture tab/screen audio; Firefox, Safari and mobile
/// browsers return video only.
bool browserCanCaptureDisplayAudio() {
  final ua = web.window.navigator.userAgent;
  if (RegExp(r'Mobi|Android|iPhone|iPad|iPod', caseSensitive: false).hasMatch(ua)) return false;
  return RegExp(r'(Chrome|Chromium|Edg)/').hasMatch(ua) && !RegExp(r'Firefox|FxiOS|OPiOS').hasMatch(ua);
}
