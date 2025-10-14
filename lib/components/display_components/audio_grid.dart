import 'package:flutter/material.dart';

class AudioGridItemContext {
  final BuildContext buildContext;
  final AudioGridOptions options;
  final int index;
  final Widget component;
  final Widget defaultItem;

  const AudioGridItemContext({
    required this.buildContext,
    required this.options,
    required this.index,
    required this.component,
    required this.defaultItem,
  });
}

class AudioGridContainerContext {
  final BuildContext buildContext;
  final AudioGridOptions options;
  final List<Widget> items;
  final Widget defaultContainer;

  const AudioGridContainerContext({
    required this.buildContext,
    required this.options,
    required this.items,
    required this.defaultContainer,
  });
}

typedef AudioGridItemBuilder = Widget Function(AudioGridItemContext context);

typedef AudioGridContainerBuilder = Widget Function(
  AudioGridContainerContext context,
);

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
  final AlignmentGeometry alignment;
  final Clip clipBehavior;
  final AudioGridItemBuilder? itemBuilder;
  final AudioGridContainerBuilder? containerBuilder;

  AudioGridOptions({
    required this.componentsToRender,
    this.alignment = AlignmentDirectional.topStart,
    this.clipBehavior = Clip.hardEdge,
    this.itemBuilder,
    this.containerBuilder,
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
    final List<Widget> items = List<Widget>.generate(
      options.componentsToRender.length,
      (index) {
        final component = options.componentsToRender[index];
        final defaultItem = component;

        return options.itemBuilder?.call(
              AudioGridItemContext(
                buildContext: context,
                options: options,
                index: index,
                component: component,
                defaultItem: defaultItem,
              ),
            ) ??
            defaultItem;
      },
    );

    final Widget defaultContainer = Stack(
      alignment: options.alignment,
      clipBehavior: options.clipBehavior,
      children: items,
    );

    return options.containerBuilder?.call(
          AudioGridContainerContext(
            buildContext: context,
            options: options,
            items: items,
            defaultContainer: defaultContainer,
          ),
        ) ??
        defaultContainer;
  }
}
