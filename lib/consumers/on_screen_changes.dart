import 'dart:async';
import 'package:flutter/foundation.dart';
import '../types/types.dart'
    show
        ReorderStreamsType,
        ReorderStreamsParameters,
        EventType,
        ReorderStreamsOptions;

/// Parameters for handling screen changes.
abstract class OnScreenChangesParameters implements ReorderStreamsParameters {
  // Properties as abstract getters
  EventType get eventType;
  bool get shareScreenStarted;
  bool get shared;
  bool get addForBasic;
  UpdateMainHeightWidth get updateMainHeightWidth;
  UpdateAddForBasic get updateAddForBasic;
  int get itemPageLimit;
  UpdateItemPageLimit get updateItemPageLimit;
  ReorderStreamsType get reorderStreams;

  OnScreenChangesParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

/// Options for handling screen changes.
class OnScreenChangesOptions {
  final bool changed;
  final OnScreenChangesParameters parameters;

  OnScreenChangesOptions({
    this.changed = false,
    required this.parameters,
  });
}

typedef OnScreenChangesType = Future<void> Function(
    OnScreenChangesOptions options);

// Custom typedef for a function that updates main height and width.
typedef UpdateMainHeightWidth = void Function(double value);

// Custom typedef for a function that updates the addForBasic flag.
typedef UpdateAddForBasic = void Function(bool value);

// Custom typedef for a function that updates the item page limit.
typedef UpdateItemPageLimit = void Function(int value);

/// Handles screen changes and adjusts the display settings based on event type and screen sharing status.
///
/// This function updates the layout parameters, such as the main height/width and item page limit, based on the
/// current event type (e.g., broadcast, chat, conference) and the screen sharing status. It also invokes the
/// reordering of streams if a screen change is detected.
///
/// Parameters:
/// - [options] (`OnScreenChangesOptions`): Options for managing screen changes:
///   - [changed] (`bool`): Indicates if a screen change occurred.
///   - [parameters] (`OnScreenChangesParameters`): Parameters that define display behaviors and update functions.
///
/// Example:
/// ```dart
/// final parameters = OnScreenChangesParameters(
///   eventType: EventType.conference,
///   shareScreenStarted: false,
///   shared: false,
///   addForBasic: false,
///   updateMainHeightWidth: (value) => print('Main height width updated: $value'),
///   updateAddForBasic: (value) => print('Add for basic updated: $value'),
///   itemPageLimit: 4,
///   updateItemPageLimit: (value) => print('Item page limit updated: $value'),
///   reorderStreams: (ReorderStreamsOptions options) async {
///     print('Reordering streams with options: ${options.screenChanged}');
///   },
/// );
///
/// final options = OnScreenChangesOptions(
///   changed: true,
///   parameters: parameters,
/// );
///
/// await onScreenChanges(options);
/// ```

Future<void> onScreenChanges(OnScreenChangesOptions options) async {
  try {
    final parameters = options.parameters;

    // Destructure parameters
    bool addForBasic = parameters.addForBasic;
    final updateMainHeightWidth = parameters.updateMainHeightWidth;
    final updateAddForBasic = parameters.updateAddForBasic;
    int itemPageLimit = parameters.itemPageLimit;
    final updateItemPageLimit = parameters.updateItemPageLimit;
    final reorderStreams = parameters.reorderStreams;

    // Remove element with id 'controlButtons'
    addForBasic = false;
    updateAddForBasic(addForBasic);

    if (parameters.eventType == EventType.broadcast ||
        parameters.eventType == EventType.chat) {
      addForBasic = true;
      updateAddForBasic(addForBasic);

      itemPageLimit = parameters.eventType == EventType.broadcast ? 1 : 2;
      updateItemPageLimit(itemPageLimit);
      updateMainHeightWidth(
          parameters.eventType == EventType.broadcast ? 100 : 0);
    } else if (parameters.eventType == EventType.conference &&
        !(parameters.shareScreenStarted || parameters.shared)) {
      updateMainHeightWidth(0);
    }

    // Update the mini cards grid
    final optionsReorderStreams = ReorderStreamsOptions(
      add: false,
      screenChanged: options.changed,
      parameters: parameters,
    );
    await reorderStreams(
      optionsReorderStreams,
    );
  } catch (error) {
    if (kDebugMode) {
      print('Error handling screen changes: ${error.toString()}');
    }
  }
}
