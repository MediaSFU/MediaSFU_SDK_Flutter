import 'dart:async';
import 'package:flutter/foundation.dart';

/// Generates the content for a specific page.
///
/// This function takes in the [page] number and [parameters] map as required
/// parameters. It generates the content for the specified page by updating
/// various variables and calling the [dispStreams] function to display the
/// streams for the page.
///
/// The [parameters] map should contain the following keys:
/// - 'paginatedStreams': A list of dynamic objects representing the paginated streams.
/// - 'currentUserPage': An integer representing the current user page.
/// - 'updateMainWindow': A boolean flag indicating whether to update the main window.
/// - 'updateCurrentUserPage': A function that updates the current user page.
/// - 'updateUpdateMainWindow': A function that updates the main window flag.
/// - 'dispStreams': A function that displays the streams.
///
/// This function returns a [Future] that completes when the content generation is
/// finished.

typedef DispStreamsFunction = void Function({
  required List<dynamic> lStreams,
  required int ind,
  bool auto,
  bool chatSkip,
  dynamic forChatCard,
  dynamic forChatID,
  required Map<String, dynamic> parameters,
});
typedef UpdateFunction<T> = void Function(T value);

Future<void> generatePageContent(
    {required int page, required Map<String, dynamic> parameters}) async {
  try {
    // Destructure parameters
    var paginatedStreams = parameters['paginatedStreams'] as List<dynamic>;
    var currentUserPage = parameters['currentUserPage'] as int;
    var updateMainWindow = parameters['updateMainWindow'] as bool;
    var updateCurrentUserPage =
        parameters['updateCurrentUserPage'] as UpdateFunction<int>;
    var updateUpdateMainWindow =
        parameters['updateUpdateMainWindow'] as UpdateFunction<bool>;

    // mediasfu functions
    DispStreamsFunction dispStreams = parameters['dispStreams'];

    // Convert page to an integer
    page = int.parse(page.toString());

    // Update current user page
    currentUserPage = page;
    updateCurrentUserPage(currentUserPage);

    // Update main window flag
    updateMainWindow = true;
    updateUpdateMainWindow(updateMainWindow);

    // Display streams for the specified page
    dispStreams(
        lStreams: paginatedStreams[page], ind: page, parameters: parameters);
  } catch (error) {
    // Handle errors during content generation
    if (kDebugMode) {
      // print('Error generating page content: ${error.toString()}');
    }
  }
}
