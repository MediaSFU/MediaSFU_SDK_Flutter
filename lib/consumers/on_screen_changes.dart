import 'dart:async';
import 'package:flutter/foundation.dart';

/// Handles on-screen changes based on the given parameters.
///
/// The [changed] parameter indicates whether the screen has changed or not.
/// The [parameters] parameter is a map containing various parameters related to the screen changes.
/// The map should include the following keys:
///   - 'eventType': The type of event that triggered the screen change.
///   - 'shareScreenStarted': A boolean indicating whether screen sharing has started.
///   - 'shared': A boolean indicating whether the screen has been shared.
///   - 'addForBasic': A boolean indicating whether to add for basic.
///   - 'updateMainHeightWidth': A function that updates the main height and width.
///   - 'updateAddForBasic': A function that updates the addForBasic flag.
///   - 'itemPageLimit': The limit for the item page.
///   - 'updateItemPageLimit': A function that updates the item page limit.
///   - 'reorderStreams': A function that reorders streams.
///
/// This function performs various operations based on the given parameters, such as updating flags, calling update functions,
/// and reordering streams. It also handles errors during the process and prints them in debug mode.

// Custom typedef for a function that updates main height and width
typedef UpdateMainHeightWidth = void Function(double value);

// Custom typedef for a function that updates the addForBasic flag
typedef UpdateAddForBasic = void Function(bool value);

// Custom typedef for a function that updates the item page limit
typedef UpdateItemPageLimit = void Function(int value);

// Custom typedef for a function that reorders streams
typedef ReorderStreams = Future<void> Function({
  bool add,
  bool screenChanged,
  required Map<String, dynamic> parameters,
});

Future<void> onScreenChanges({
  bool changed = false,
  required Map<String, dynamic> parameters,
}) async {
  try {
    // Destructure parameters
    String eventType = parameters['eventType'];
    bool shareScreenStarted = parameters['shareScreenStarted'];
    bool shared = parameters['shared'];
    bool addForBasic = parameters['addForBasic'];

    // Updated function typedefs
    UpdateMainHeightWidth updateMainHeightWidth =
        parameters['updateMainHeightWidth'] as UpdateMainHeightWidth;
    UpdateAddForBasic updateAddForBasic =
        parameters['updateAddForBasic'] as UpdateAddForBasic;
    int itemPageLimit = parameters['itemPageLimit'];
    UpdateItemPageLimit updateItemPageLimit =
        parameters['updateItemPageLimit'] as UpdateItemPageLimit;

    // mediasfu functions
    ReorderStreams reorderStreams =
        parameters['reorderStreams'] as ReorderStreams;

    // Remove element with id 'controlButtons'
    addForBasic = false;
    updateAddForBasic(addForBasic);

    if (eventType == 'broadcast' || eventType == 'chat') {
      addForBasic = true;
      updateAddForBasic(addForBasic);

      itemPageLimit = eventType == 'broadcast' ? 1 : 2;
      updateItemPageLimit(itemPageLimit);
      updateMainHeightWidth(eventType == 'broadcast' ? 100 : 0);
    } else {
      if (eventType == 'conference' && !(shareScreenStarted || shared)) {
        updateMainHeightWidth(0);
      }
    }

    // Update the mini cards grid
    await reorderStreams(
        add: false, screenChanged: changed, parameters: parameters);
  } catch (error) {
    // Handle errors during the process of handling screen changes
    if (kDebugMode) {
      print('Error handling screen changes: ${error.toString()}');
    }
    // throw error;
  }
}
