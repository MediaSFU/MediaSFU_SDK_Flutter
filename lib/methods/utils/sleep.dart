import 'dart:async';

/// Suspends the execution of the current isolate for the specified [milliseconds].
///
/// Returns a [Future] that completes after the specified [milliseconds] have elapsed.
Future<void> sleep(int milliseconds) {
  return Future.delayed(Duration(milliseconds: milliseconds));
}
