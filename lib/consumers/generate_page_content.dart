import 'dart:async';
import 'package:flutter/foundation.dart';
import '../types/types.dart'
    show DispStreamsType, DispStreamsParameters, DispStreamsOptions, Stream;

/// Parameters used for generating page content for a specific user interface page.
abstract class GeneratePageContentParameters implements DispStreamsParameters {
  // Properties as abstract getters
  List<List<Stream>> get paginatedStreams;
  int get currentUserPage;
  bool get updateMainWindow;

  // Update functions as abstract getters
  void Function(int) get updateCurrentUserPage;
  void Function(bool) get updateUpdateMainWindow;

  // Mediasfu function as an abstract getter
  DispStreamsType get dispStreams;

  // Method to retrieve updated parameters
  GeneratePageContentParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

/// Options for generating page content.
class GeneratePageContentOptions {
  int page;
  GeneratePageContentParameters parameters;
  int breakRoom;
  bool inBreakRoom;

  GeneratePageContentOptions({
    required this.page,
    required this.parameters,
    this.breakRoom = -1,
    this.inBreakRoom = false,
  });
}

typedef GeneratePageContentType = Future<void> Function(
    GeneratePageContentOptions options);

/// Generates the content for a specific page based on the provided options.
///
/// This function updates the page content for the given page in [options],
/// which includes updating the main window and setting the current page.
///
/// Example usage:
/// ```dart
/// final options = GeneratePageContentOptions(
///   page: 1,
///   parameters: GeneratePageContentParameters(
///     paginatedStreams: [[stream1, stream2], [stream3, stream4]],
///     currentUserPage: 0,
///     updateMainWindow: true,
///     updateCurrentUserPage: (page) => print('Current user page updated to: $page'),
///     updateUpdateMainWindow: (flag) => print('Main window update flag: $flag'),
///     dispStreams: (lStreams, ind, {parameters, breakRoom = -1, inBreakRoom = false}) async {
///       print('Displaying streams for page $ind');
///     },
///     getUpdatedAllParams: () => updatedParameters,
///   ),
/// );
/// await generatePageContent(options);
/// ```
///
/// Returns a [Future<void>] that completes when the page content is generated.
Future<void> generatePageContent(GeneratePageContentOptions options) async {
  try {
    List<List<Stream>> paginatedStreams = options.parameters.paginatedStreams;
    var currentUserPage = options.parameters.currentUserPage;
    var updateMainWindow = options.parameters.updateMainWindow;
    var updateCurrentUserPage = options.parameters.updateCurrentUserPage;
    var updateUpdateMainWindow = options.parameters.updateUpdateMainWindow;
    var dispStreams = options.parameters.dispStreams;

    // Convert page to an integer if passed as a string.
    var page = options.page;

    // Update current user page.
    currentUserPage = page;
    updateCurrentUserPage(currentUserPage);

    // Update main window flag.
    updateMainWindow = true;
    updateUpdateMainWindow(updateMainWindow);

    // Display streams for the specified page.
    final dispOptions = DispStreamsOptions(
      lStreams: paginatedStreams[page],
      ind: page,
      parameters: options.parameters,
      breakRoom: options.breakRoom,
      inBreakRoom: options.inBreakRoom,
    );
    await dispStreams(
      dispOptions,
    );
  } catch (error) {
    if (kDebugMode) {
      print('Error generating page content: ${error.toString()}');
    }
  }
}
