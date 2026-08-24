import '../mediasfu_parameters.dart' show MediasfuParameters;

enum ProducerKind { video, audio, screen }

class CaptureLimits {
  final int width;
  final int height;
  final int frameRate;

  const CaptureLimits({
    required this.width,
    required this.height,
    required this.frameRate,
  });
}

int _dimensionCap(dynamic dimension) =>
    (dimension.max as int?) ?? (dimension.ideal as int?) ?? 0;

/// Returns the camera capture ceiling published by the room.
///
/// Flutter's parameter bag does not retain the transient screen-share
/// `targetWidth`/`targetHeight` values used by `startShareScreen`, so screen
/// ceilings are reported as unknown rather than guessed.
CaptureLimits getCaptureLimits(
  MediasfuParameters parameters, {
  ProducerKind kind = ProducerKind.video,
}) {
  if (kind == ProducerKind.screen) {
    return CaptureLimits(width: 0, height: 0, frameRate: parameters.frameRate);
  }
  if (kind == ProducerKind.audio) {
    return const CaptureLimits(width: 0, height: 0, frameRate: 0);
  }
  return CaptureLimits(
    width: _dimensionCap(parameters.vidCons.width),
    height: _dimensionCap(parameters.vidCons.height),
    frameRate: parameters.frameRate,
  );
}
