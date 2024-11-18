import 'package:flutter/material.dart';

/// Configuration options for the `AudioGrid` widget.
///
/// This class specifies the options available for configuring an `AudioGrid`.
///
/// ```dart
/// // Example usage:
/// AudioGridOptions(
///   componentsToRender: [
///     AudioComponent1(),
///     AudioComponent2(),
///     AudioComponent3(),
///   ],
/// );
/// ```
class AudioGridOptions {
  final List<Widget> componentsToRender;

  AudioGridOptions({
    required this.componentsToRender,
  });
}

typedef AudioGridType = Widget Function({
  required AudioGridOptions options,
});

/// A layout widget to stack multiple audio components on top of each other using [AudioGridOptions].
///
/// ```dart
/// // Example usage:
/// AudioGrid(
///   options: AudioGridOptions(
///     componentsToRender: [
///       AudioComponent1(),
///       AudioComponent2(),
///       AudioComponent3(),
///     ],
///   ),
/// );
/// ```
class AudioGrid extends StatelessWidget {
  final AudioGridOptions options;

  const AudioGrid({
    super.key,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: options.componentsToRender,
    );
  }
}
