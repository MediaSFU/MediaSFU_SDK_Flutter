import '../mediasfu_parameters.dart' show MediasfuParameters;

/// Purely reads the latest Flutter parameter snapshot.
///
/// The legacy Flutter getter is also pure, but this name carries the same
/// explicit contract as the React SDK and is safe in build/polling code.
MediasfuParameters getCurrentParams(MediasfuParameters parameters) =>
    parameters.getCurrentParams();
