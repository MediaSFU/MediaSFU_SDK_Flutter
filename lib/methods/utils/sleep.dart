import 'dart:async';

/// Options for the sleep function, containing the sleep duration in milliseconds.
class SleepOptions {
  final int ms;

  SleepOptions({required this.ms});
}

typedef SleepType = Future<void> Function(SleepOptions options);

/// Suspends the execution of the current isolate for the specified [options.ms] milliseconds.
///
/// Returns a [Future] that completes after the specified duration.
///
/// Example usage:
/// ```dart
/// await sleep(SleepOptions(ms: 2000));
/// print("Waited for 2 seconds");
/// ```
Future<void> sleep(SleepOptions options) {
  return Future.delayed(Duration(milliseconds: options.ms));
}
