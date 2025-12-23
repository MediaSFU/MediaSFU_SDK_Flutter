/// Handler for panelist-related socket events.
///
/// Listens for:
/// - panelistsUpdated: When the panelist list changes
/// - addedAsPanelist: When current user is added as a panelist
/// - removedFromPanelists: When current user is removed from panelists
/// - panelistFocusChanged: When focus mode is toggled
/// - controlMedia: When media is controlled (mute) due to focus mode
library;

import '../../types/types.dart' show Participant, ShowAlert;

/// Panelist data received from socket.
class PanelistData {
  final String id;
  final String name;

  PanelistData({
    required this.id,
    required this.name,
  });

  factory PanelistData.fromMap(Map<String, dynamic> map) {
    return PanelistData(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
    );
  }

  Participant toParticipant() {
    return Participant(
      id: id,
      name: name,
      audioID: '',
      videoID: '',
    );
  }
}

/// Data received when panelists list is updated.
class PanelistsUpdatedData {
  final List<PanelistData> panelists;

  PanelistsUpdatedData({
    required this.panelists,
  });

  factory PanelistsUpdatedData.fromMap(Map<String, dynamic> map) {
    final panelistsList = map['panelists'] as List<dynamic>? ?? [];
    return PanelistsUpdatedData(
      panelists: panelistsList
          .map((p) => PanelistData.fromMap(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Data received when panelist focus mode changes.
class PanelistFocusChangedData {
  final bool focusEnabled;
  final List<PanelistData> panelists;
  final bool muteOthersMic;
  final bool muteOthersCamera;

  PanelistFocusChangedData({
    required this.focusEnabled,
    required this.panelists,
    required this.muteOthersMic,
    required this.muteOthersCamera,
  });

  factory PanelistFocusChangedData.fromMap(Map<String, dynamic> map) {
    final panelistsList = map['panelists'] as List<dynamic>? ?? [];
    return PanelistFocusChangedData(
      focusEnabled: map['focusEnabled'] == true,
      panelists: panelistsList
          .map((p) => PanelistData.fromMap(p as Map<String, dynamic>))
          .toList(),
      muteOthersMic: map['muteOthersMic'] == true,
      muteOthersCamera: map['muteOthersCamera'] == true,
    );
  }
}

/// Data received when media control is requested.
class ControlMediaData {
  final String type; // 'audio' or 'video'
  final String action; // 'mute' or 'unmute'
  final String? reason;

  ControlMediaData({
    required this.type,
    required this.action,
    this.reason,
  });

  factory ControlMediaData.fromMap(Map<String, dynamic> map) {
    return ControlMediaData(
      type: map['type']?.toString() ?? 'audio',
      action: map['action']?.toString() ?? 'mute',
      reason: map['reason']?.toString(),
    );
  }
}

/// Data received when added as panelist.
class AddedAsPanelistData {
  final String message;

  AddedAsPanelistData({
    required this.message,
  });

  factory AddedAsPanelistData.fromMap(Map<String, dynamic> map) {
    return AddedAsPanelistData(
      message:
          map['message']?.toString() ?? 'You have been added as a panelist',
    );
  }
}

/// Data received when removed from panelists.
class RemovedFromPanelistsData {
  final String message;

  RemovedFromPanelistsData({
    required this.message,
  });

  factory RemovedFromPanelistsData.fromMap(Map<String, dynamic> map) {
    return RemovedFromPanelistsData(
      message:
          map['message']?.toString() ?? 'You have been removed from panelists',
    );
  }
}

/// Options for handling panelistsUpdated event.
class PanelistsUpdatedOptions {
  final PanelistsUpdatedData data;
  final void Function(List<Participant>)? updatePanelists;

  PanelistsUpdatedOptions({
    required this.data,
    this.updatePanelists,
  });
}

/// Options for handling panelistFocusChanged event.
class PanelistFocusChangedOptions {
  final PanelistFocusChangedData data;
  final void Function(bool)? updatePanelistsFocused;
  final void Function(bool)? updateMuteOthersMic;
  final void Function(bool)? updateMuteOthersCamera;
  final void Function(List<Participant>)? updatePanelists;
  // Optional: current values to compare for triggering onScreenChanges
  final bool? currentPanelistsFocused;
  final List<Participant>? currentPanelists;
  // Optional: callback to trigger screen rerender when focus/panelists change
  final Future<void> Function()? onScreenChanges;

  PanelistFocusChangedOptions({
    required this.data,
    this.updatePanelistsFocused,
    this.updateMuteOthersMic,
    this.updateMuteOthersCamera,
    this.updatePanelists,
    this.currentPanelistsFocused,
    this.currentPanelists,
    this.onScreenChanges,
  });
}

/// Options for handling controlMedia event.
class ControlMediaOptions {
  final ControlMediaData data;
  final ShowAlert? showAlert;
  final VoidCallback? clickAudio;
  final VoidCallback? clickVideo;
  final bool audioAlreadyOn;
  final bool videoAlreadyOn;

  ControlMediaOptions({
    required this.data,
    this.showAlert,
    this.clickAudio,
    this.clickVideo,
    this.audioAlreadyOn = false,
    this.videoAlreadyOn = false,
  });
}

/// Options for handling addedAsPanelist event.
class AddedAsPanelistOptions {
  final AddedAsPanelistData data;
  final ShowAlert? showAlert;

  AddedAsPanelistOptions({
    required this.data,
    this.showAlert,
  });
}

/// Options for handling removedFromPanelists event.
class RemovedFromPanelistsOptions {
  final RemovedFromPanelistsData data;
  final ShowAlert? showAlert;

  RemovedFromPanelistsOptions({
    required this.data,
    this.showAlert,
  });
}

typedef VoidCallback = void Function();
typedef PanelistsUpdatedType = Future<void> Function(
    PanelistsUpdatedOptions options);
typedef PanelistFocusChangedType = Future<void> Function(
    PanelistFocusChangedOptions options);
typedef ControlMediaType = Future<void> Function(ControlMediaOptions options);
typedef AddedAsPanelistType = Future<void> Function(
    AddedAsPanelistOptions options);
typedef RemovedFromPanelistsType = Future<void> Function(
    RemovedFromPanelistsOptions options);

/// Handles the panelistsUpdated socket event.
/// Called when the panelist list changes.
///
/// Example:
/// ```dart
/// socket.on("panelistsUpdated", (data) async {
///   await panelistsUpdated(PanelistsUpdatedOptions(
///     data: PanelistsUpdatedData.fromMap(data),
///     updatePanelists: (panelists) => setState(() => this.panelists = panelists),
///   ));
/// });
/// ```
Future<void> panelistsUpdated(PanelistsUpdatedOptions options) async {
  try {
    final data = options.data;

    if (options.updatePanelists != null) {
      final participantPanelists =
          data.panelists.map((p) => p.toParticipant()).toList();
      options.updatePanelists!(participantPanelists);
    }
  } catch (e) {
    print('Error handling panelistsUpdated: $e');
  }
}

/// Handles the panelistFocusChanged socket event.
/// Called when the host toggles focus mode on/off.
///
/// Example:
/// ```dart
/// socket.on("panelistFocusChanged", (data) async {
///   await panelistFocusChanged(PanelistFocusChangedOptions(
///     data: PanelistFocusChangedData.fromMap(data),
///     updatePanelistsFocused: (focused) => setState(() => panelistsFocused = focused),
///     updateMuteOthersMic: (mute) => setState(() => muteOthersMic = mute),
///     updateMuteOthersCamera: (mute) => setState(() => muteOthersCamera = mute),
///     updatePanelists: (panelists) => setState(() => this.panelists = panelists),
///     currentPanelistsFocused: panelistsFocused,
///     currentPanelists: panelists,
///     onScreenChanges: () async { ... },
///   ));
/// });
/// ```
Future<void> panelistFocusChanged(PanelistFocusChangedOptions options) async {
  try {
    final data = options.data;

    // Check if focus state or panelists changed (for triggering rerender)
    final focusChanged = options.currentPanelistsFocused != null &&
        options.currentPanelistsFocused != data.focusEnabled;

    // Compare panelist lists by their IDs
    final currentPanelistIds =
        (options.currentPanelists ?? []).map((p) => p.id).toList()..sort();
    final newPanelistIds = data.panelists.map((p) => p.id).toList()..sort();
    final panelistsChanged =
        currentPanelistIds.join(',') != newPanelistIds.join(',');

    options.updatePanelistsFocused?.call(data.focusEnabled);
    options.updateMuteOthersMic?.call(data.muteOthersMic);
    options.updateMuteOthersCamera?.call(data.muteOthersCamera);

    if (options.updatePanelists != null) {
      final participantPanelists =
          data.panelists.map((p) => p.toParticipant()).toList();
      options.updatePanelists!(participantPanelists);
    }

    // Trigger screen rerender if focus or panelists changed
    if ((focusChanged || panelistsChanged) && options.onScreenChanges != null) {
      await options.onScreenChanges!();
    }
  } catch (e) {
    print('Error handling panelistFocusChanged: $e');
  }
}

/// Handles the controlMedia socket event.
/// Called when media needs to be controlled due to focus mode.
///
/// Example:
/// ```dart
/// socket.on("controlMedia", (data) async {
///   await controlMedia(ControlMediaOptions(
///     data: ControlMediaData.fromMap(data),
///     showAlert: showAlert,
///     clickAudio: clickAudio,
///     clickVideo: clickVideo,
///     audioAlreadyOn: audioAlreadyOn,
///     videoAlreadyOn: videoAlreadyOn,
///   ));
/// });
/// ```
Future<void> controlMedia(ControlMediaOptions options) async {
  try {
    final data = options.data;

    if (data.action == 'mute') {
      if (data.type == 'audio' &&
          options.audioAlreadyOn &&
          options.clickAudio != null) {
        options.clickAudio!();
      } else if (data.type == 'video' &&
          options.videoAlreadyOn &&
          options.clickVideo != null) {
        options.clickVideo!();
      }

      if (options.showAlert != null && data.reason != null) {
        final mediaType = data.type == 'audio' ? 'microphone' : 'camera';
        options.showAlert!(
          message: 'Your $mediaType has been muted. ${data.reason}',
          type: 'info',
          duration: 3000,
        );
      }
    }
  } catch (e) {
    print('Error handling controlMedia: $e');
  }
}

/// Handles the addedAsPanelist socket event.
/// Called when current user is added as a panelist.
Future<void> addedAsPanelist(AddedAsPanelistOptions options) async {
  try {
    final data = options.data;

    options.showAlert?.call(
      message: data.message,
      type: 'success',
      duration: 3000,
    );
  } catch (e) {
    print('Error handling addedAsPanelist: $e');
  }
}

/// Handles the removedFromPanelists socket event.
/// Called when current user is removed from panelists.
Future<void> removedFromPanelists(RemovedFromPanelistsOptions options) async {
  try {
    final data = options.data;

    options.showAlert?.call(
      message: data.message,
      type: 'info',
      duration: 3000,
    );
  } catch (e) {
    print('Error handling removedFromPanelists: $e');
  }
}
