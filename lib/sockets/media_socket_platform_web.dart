import 'package:web/web.dart' as web;

/// The browser's `navigator.onLine`.
bool? platformOnlineState() => web.window.navigator.onLine;
