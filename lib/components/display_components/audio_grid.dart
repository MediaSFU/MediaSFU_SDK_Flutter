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
/// Provides properties to customize a Stack-based layout for audio-only participant cards,
/// allowing multiple AudioCard widgets to be layered with configurable alignment and clipping.
///
/// **Core Properties:**
/// - `componentsToRender`: List of widgets to stack (typically AudioCard components)
/// - `alignment`: Stack alignment (default: AlignmentDirectional.topStart)
/// - `clipBehavior`: How to clip overflowing content (default: Clip.hardEdge)
///
/// **Builder Hooks (2):**
/// - `itemBuilder`: Override individual items before adding to Stack; receives AudioGridItemContext + default
/// - `containerBuilder`: Override entire Stack; receives AudioGridContainerContext + default
///
/// **Usage Patterns:**
/// 1. **Basic Audio Grid:**
///    ```dart
///    AudioGrid(
///      options: AudioGridOptions(
///        componentsToRender: audioParticipants.map((p) => AudioCard(
///          options: AudioCardOptions(
///            name: p.name,
///            participant: p,
///            parameters: parameters,
///            customStyle: BoxDecoration(color: Colors.grey[800]),
///          ),
///        )).toList(),
///      ),
///    )
///    ```
///
/// 2. **Centered Alignment:**
///    ```dart
///    AudioGrid(
///      options: AudioGridOptions(
///        componentsToRender: audioCards,
///        alignment: Alignment.center,
///      ),
///    )
///    ```
///
/// 3. **Custom Item Wrapper:**
///    ```dart
///    AudioGrid(
///      options: AudioGridOptions(
///        componentsToRender: audioCards,
///        itemBuilder: (context) {
///          return Padding(
///            padding: EdgeInsets.all(8),
///            child: context.defaultItem,
///          );
///        },
///      ),
///    )
///    ```
///
/// 4. **Custom Container:**
///    ```dart
///    AudioGrid(
///      options: AudioGridOptions(
///        componentsToRender: audioCards,
///        containerBuilder: (context) {
///          return Container(
///            decoration: BoxDecoration(color: Colors.black87),
///            child: context.defaultContainer,
///          );
///        },
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Can be overridden via `MediasfuUICustomOverrides`:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   audioGridOptions: ComponentOverride<AudioGridOptions>(
///     builder: (existingOptions) => AudioGridOptions(
///       componentsToRender: existingOptions.componentsToRender,
///       alignment: Alignment.topCenter,
///       clipBehavior: Clip.antiAlias,
///     ),
///   ),
/// ),
/// ```
///
/// **Stack Behavior:**
/// - All components rendered in single Stack (overlapping layout)
/// - Order: first component in list = bottom layer, last = top layer
/// - Alignment affects positioning of each child within Stack bounds
/// - Typically used when audio-only participants need visual representation
///
/// **Implementation Notes:**
/// - Uses Stack widget for layering (not Grid/GridView)
/// - No automatic sizing or spacing (Stack fills available space)
/// - clipBehavior prevents overflow outside Stack bounds
/// - Builder hooks called for each item during build
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

/// A stateless widget rendering audio-only participant cards in a Stack layout.
///
/// Displays multiple AudioCard components layered on top of each other using Stack,
/// allowing overlap and custom positioning. Typically used for audio-only meetings
/// or when video is disabled for multiple participants.
///
/// **Rendering Logic:**
/// 1. Iterates through `componentsToRender` list
/// 2. For each component, calls `itemBuilder` (if provided) to wrap it
/// 3. Collects all items into list
/// 4. Creates Stack with items, applying alignment and clipBehavior
/// 5. Calls `containerBuilder` (if provided) to wrap Stack
///
/// **Layout Structure:**
/// ```
/// Stack (containerBuilder)
///   ├─ alignment: AlignmentDirectional.topStart (default)
///   ├─ clipBehavior: Clip.hardEdge (default)
///   └─ children:
///      ├─ Component[0] (itemBuilder) [bottom layer]
///      ├─ Component[1] (itemBuilder)
///      └─ Component[N] (itemBuilder) [top layer]
/// ```
///
/// **Builder Hook Priorities:**
/// - `itemBuilder`: Called once per component; receives index, component, defaultItem
/// - `containerBuilder`: Called once for entire Stack; receives items list, defaultContainer
///
/// **Common Use Cases:**
/// 1. **Basic Audio Participant Stack:**
///    ```dart
///    AudioGrid(
///      options: AudioGridOptions(
///        componentsToRender: audioParticipants.map((participant) {
///          return AudioCard(
///            options: AudioCardOptions(
///              name: participant.name,
///              participant: participant,
///              parameters: parameters,
///              customStyle: BoxDecoration(
///                color: Colors.grey[800],
///                borderRadius: BorderRadius.circular(8),
///              ),
///            ),
///          );
///        }).toList(),
///      ),
///    )
///    ```
///
/// 2. **Audio Grid with Padding:**
///    ```dart
///    AudioGrid(
///      options: AudioGridOptions(
///        componentsToRender: audioCards,
///        itemBuilder: (context) {
///          return Padding(
///            padding: EdgeInsets.all(4),
///            child: context.defaultItem,
///          );
///        },
///      ),
///    )
///    ```
///
/// 3. **Centered Audio Display:**
///    ```dart
///    AudioGrid(
///      options: AudioGridOptions(
///        componentsToRender: audioCards,
///        alignment: Alignment.center,
///        containerBuilder: (context) {
///          return Container(
///            decoration: BoxDecoration(
///              gradient: LinearGradient(
///                colors: [Colors.black, Colors.grey[900]!],
///              ),
///            ),
///            child: context.defaultContainer,
///          );
///        },
///      ),
///    )
///    ```
///
/// 4. **Indexed Item Styling:**
///    ```dart
///    AudioGrid(
///      options: AudioGridOptions(
///        componentsToRender: audioCards,
///        itemBuilder: (context) {
///          // Style first item differently
///          if (context.index == 0) {
///            return Container(
///              decoration: BoxDecoration(
///                border: Border.all(color: Colors.blue, width: 2),
///              ),
///              child: context.defaultItem,
///            );
///          }
///          return context.defaultItem;
///        },
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Integrates with `MediasfuUICustomOverrides` for global styling:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   audioGridOptions: ComponentOverride<AudioGridOptions>(
///     builder: (existingOptions) => AudioGridOptions(
///       componentsToRender: existingOptions.componentsToRender,
///       alignment: Alignment.topCenter,
///       clipBehavior: Clip.antiAlias,
///       itemBuilder: (context) {
///         return Container(
///           margin: EdgeInsets.all(8),
///           decoration: BoxDecoration(
///             borderRadius: BorderRadius.circular(12),
///             boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
///           ),
///           child: context.defaultItem,
///         );
///       },
///     ),
///   ),
/// ),
/// ```
///
/// **Stack Layering:**
/// - Components rendered in order: first = bottom, last = top
/// - Each component fills Stack space based on its own constraints
/// - Alignment affects how each child positions within Stack
/// - Overlapping creates layered effect (useful for compact audio displays)
///
/// **Performance Notes:**
/// - Stateless widget (no internal state)
/// - List.generate creates items list once per build
/// - Builder hooks called during build (not cached)
/// - Stack renders all children (no lazy loading)
/// - Suitable for small-to-medium participant counts (2-20 typically)
///
/// **Implementation Details:**
/// - Uses List.generate to iterate componentsToRender
/// - itemBuilder receives AudioGridItemContext with index and component
/// - containerBuilder receives AudioGridContainerContext with all items
/// - Default Stack uses alignment and clipBehavior from options
/// - No positioning logic (Stack handles layout automatically)
///
/// **Typical Usage Context:**
/// - Audio-only meetings
/// - Participants with video disabled
/// - Compact display of multiple audio participants
/// - Fallback when video grid capacity exceeded
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
