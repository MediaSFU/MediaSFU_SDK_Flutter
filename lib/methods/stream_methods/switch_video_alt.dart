import '../../types/types.dart'
    show
        ShowAlert,
        SwitchUserVideoAltType,
        SwitchUserVideoAltOptions,
        SwitchUserVideoAltParameters;

abstract class SwitchVideoAltParameters
    implements SwitchUserVideoAltParameters {
  // Core properties as abstract getters
  bool get recordStarted;
  bool get recordResumed;
  bool get recordStopped;
  bool get recordPaused;
  String get recordingMediaOptions;
  bool get videoAlreadyOn;
  String get currentFacingMode;
  String get prevFacingMode;
  bool get allowed;
  bool get audioOnlyRoom;

  // Update functions as abstract getters
  void Function(String) get updateCurrentFacingMode;
  void Function(String) get updatePrevFacingMode;
  void Function(bool) get updateIsMediaSettingsModalVisible;

  // Optional alert as an abstract getter
  ShowAlert? get showAlert;

  // Mediasfu function as an abstract getter
  SwitchUserVideoAltType get switchUserVideoAlt;

  // Method to retrieve updated parameters as an abstract getter
  SwitchVideoAltParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Options for switching the user's video with alternate logic.
class SwitchVideoAltOptions {
  final SwitchVideoAltParameters parameters;

  SwitchVideoAltOptions({required this.parameters});
}

typedef SwitchVideoAltType = Future<void> Function(
    SwitchVideoAltOptions options);

/// Switches the user's video device with alternate logic, taking into account recording state and camera access permissions.
///
/// ### Parameters:
/// - [options] (`SwitchVideoAltOptions`): Contains the `parameters` required for switching video.
///
/// ### Example:
/// ```dart
/// final switchVideoAltOptions = SwitchVideoAltOptions(
///   parameters: SwitchVideoAltParameters(
///     recordStarted: true,
///     recordResumed: false,
///     recordStopped: false,
///     recordPaused: false,
///     recordingMediaOptions: 'video',
///     videoAlreadyOn: true,
///     currentFacingMode: 'user',
///     prevFacingMode: 'environment',
///     allowed: true,
///     audioOnlyRoom: false,
///     updateCurrentFacingMode: (mode) => setCurrentFacingMode(mode),
///     updatePrevFacingMode: (mode) => setPrevFacingMode(mode),
///     updateIsMediaSettingsModalVisible: (isVisible) => setMediaSettingsModal(isVisible),
///     showAlert: (alertOptions) => showAlert(alertOptions),
///     switchUserVideoAlt: switchUserVideoAltFunction,
///   ),
/// );
///
/// await switchVideoAlt(switchVideoAltOptions);
/// ```
Future<void> switchVideoAlt(SwitchVideoAltOptions options) async {
  final parameters = options.parameters.getUpdatedAllParams();

  final bool recordStarted = parameters.recordStarted;
  final bool recordResumed = parameters.recordResumed;
  final bool recordStopped = parameters.recordStopped;
  final bool recordPaused = parameters.recordPaused;
  final String recordingMediaOptions = parameters.recordingMediaOptions;
  bool videoAlreadyOn = parameters.videoAlreadyOn;
  String currentFacingMode = parameters.currentFacingMode;
  String prevFacingMode = parameters.prevFacingMode;
  final bool allowed = parameters.allowed;
  final bool audioOnlyRoom = parameters.audioOnlyRoom;
  final void Function(String) updateCurrentFacingMode =
      parameters.updateCurrentFacingMode;
  final void Function(String) updatePrevFacingMode =
      parameters.updatePrevFacingMode;
  final void Function(bool) updateIsMediaSettingsModalVisible =
      parameters.updateIsMediaSettingsModalVisible;
  final ShowAlert? showAlert = parameters.showAlert;

  // mediasfu functions
  final SwitchUserVideoAltType switchUserVideoAlt =
      parameters.switchUserVideoAlt;

  // Check if the room is audio-only
  if (audioOnlyRoom) {
    showAlert?.call(
      message: 'You cannot turn on your camera in an audio-only event.',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  // Check if recording is in progress and if video cannot be turned off
  bool checkoff = false;
  if ((recordStarted || recordResumed) &&
      !recordStopped &&
      !recordPaused &&
      recordingMediaOptions == 'video') {
    checkoff = true;
  }

  // Check camera access permission
  if (!allowed) {
    showAlert?.call(
      message: 'Allow access to your camera by starting it for the first time.',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  // Check video state and display appropriate alert messages
  if (checkoff) {
    if (videoAlreadyOn) {
      showAlert?.call(
        message: 'Please turn off your video before switching.',
        type: 'danger',
        duration: 3000,
      );
      return;
    }
  } else {
    if (!videoAlreadyOn) {
      showAlert?.call(
        message: 'Please turn on your video before switching.',
        type: 'danger',
        duration: 3000,
      );
      return;
    }
  }

  // Camera switching logic
  prevFacingMode = currentFacingMode;
  updatePrevFacingMode(prevFacingMode);

  // Toggle between 'environment' and 'user'
  currentFacingMode =
      currentFacingMode == 'environment' ? 'user' : 'environment';
  updateCurrentFacingMode(currentFacingMode);

  // Hide media settings modal if visible
  updateIsMediaSettingsModalVisible(false);

  // Perform the video switch using the mediasfu function
  final optionsSwitch = SwitchUserVideoAltOptions(
    parameters: parameters,
    videoPreference: currentFacingMode,
    checkoff: checkoff,
  );
  await switchUserVideoAlt(
    optionsSwitch,
  );
}
