import 'package:flutter/foundation.dart';

import '../types/types.dart'
    show Participant, AutoAdjustType, ScreenState, EventType, AutoAdjustOptions;
import 'package:socket_io_client/socket_io_client.dart' show Socket;

/// Represents parameters required for the [trigger] function.
/// Interface for Trigger parameters, similar to the React Native TypeScript interface.
abstract class TriggerParameters {
  Socket? get socket;
  String get roomName;
  List<ScreenState> get screenStates;
  List<Participant> get participants;
  int? get updateDateState;
  int? get lastUpdate;
  int? get nForReadjust;
  EventType get eventType;
  bool get shared;
  bool get shareScreenStarted;
  bool get whiteboardStarted;
  bool get whiteboardEnded;

  void Function(int? timestamp) get updateUpdateDateState;
  void Function(int? lastUpdate) get updateLastUpdate;
  void Function(int nForReadjust) get updateNForReadjust;

  // Mediasfu functions
  AutoAdjustType get autoAdjust;

  /// Returns updated parameters with potential changes
  TriggerParameters Function() get getUpdatedAllParams;

  /// Dynamic access operator for additional properties
  // dynamic operator [](String key);
}

/// Options required to trigger a screen update.
class TriggerOptions {
  final List<String> refActiveNames;
  final TriggerParameters parameters;

  /// Constructor for [TriggerOptions].
  ///
  /// [refActiveNames] - Reference list of currently active participant names.
  /// [parameters] - Parameters containing functions and configurations needed for the trigger.
  TriggerOptions({
    required this.refActiveNames,
    required this.parameters,
  });
}

typedef TriggerType = Future<void> Function(TriggerOptions options);

/// Triggers a screen update based on various conditions and adjusts layouts as needed.
///
/// This function evaluates the current screen state and determines the primary participant
/// on the main screen. Depending on event type, screen sharing status, and active participants,
/// it adjusts the main screen person, calculates percentages for screen layout, and emits an
/// update to the client via the socket connection.
///
/// * [refActiveNames] - List of active participant names.
/// * [parameters] - Additional parameters for adjusting layouts and emitting updates.
///
/// Example usage:
/// ```dart
/// final params = TriggerParameters(
///   socket: mySocket,
///   roomName: "myRoom",
///   screenStates: [ScreenState(mainScreenPerson: "user1", mainScreenFilled: true)],
///   participants: [Participant(name: "admin", islevel: "2")],
///   updateDateState: (timestamp) => print("Updated date state: $timestamp"),
///   updateLastUpdate: (lastUpdate) => print("Updated last update: $lastUpdate"),
///   updateNForReadjust: (nForReadjust) => print("Updated nForReadjust: $nForReadjust"),
///   autoAdjust: (n, parameters) async => [n, 0],
///   getUpdatedAllParams: () => params,
///   eventType: EventType.conference,
///   shared: false,
///   shareScreenStarted: false,
///   whiteboardStarted: false,
///   whiteboardEnded: false,
/// );
///
/// await trigger(
///  TriggerOptions(
///   refActiveNames: ["user1", "user2"],
///   parameters: params,
/// ),
/// );
/// ```
Future<void> trigger(TriggerOptions options) async {
  try {
    final refActiveNames = options.refActiveNames;
    var parameters = options.parameters;

    parameters = parameters.getUpdatedAllParams();

    final socket = parameters.socket;
    final roomName = parameters.roomName;
    final screenStates = parameters.screenStates;
    final participants = parameters.participants;
    var updateDateState = parameters.updateDateState;
    var lastUpdate = parameters.lastUpdate;
    var nForReadjust = parameters.nForReadjust ?? 0;
    final eventType = parameters.eventType;
    final shared = parameters.shared;
    final shareScreenStarted = parameters.shareScreenStarted;
    final whiteboardStarted = parameters.whiteboardStarted;
    final whiteboardEnded = parameters.whiteboardEnded;

    final updateUpdateDateState = parameters.updateUpdateDateState;
    final updateLastUpdate = parameters.updateLastUpdate;
    final updateNForReadjust = parameters.updateNForReadjust;
    final autoAdjust = parameters.autoAdjust;

    // Determine admin and main screen participant
    String? personOnMainScreen =
        screenStates.isNotEmpty ? screenStates[0].mainScreenPerson : null;
    final admin = participants.firstWhere(
      (participant) => participant.islevel == '2',
    );
    final adminName = admin.name;

    if (personOnMainScreen == 'WhiteboardActive') {
      personOnMainScreen = adminName;
    }

    final bool mainScreenFilled =
        screenStates.isNotEmpty && screenStates[0].mainScreenFilled;
    final bool adminOnMainScreen =
        screenStates.isNotEmpty && screenStates[0].adminOnMainScreen;
    final int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    bool eventPass = false;

    // Specific conference conditions
    if (eventType == EventType.conference && !(shared || shareScreenStarted)) {
      eventPass = true;
      personOnMainScreen = adminName;
      if (!refActiveNames.contains(adminName) &&
          whiteboardStarted &&
          !whiteboardEnded) {
        refActiveNames.insert(0, adminName);
      }
    }

    if ((mainScreenFilled && personOnMainScreen != null && adminOnMainScreen) ||
        eventPass) {
      nForReadjust += 1;
      updateNForReadjust(nForReadjust);

      int adjustedParticipantCount = refActiveNames.length;

      List<int> adjustedValues = [0, 0];

      if (adjustedParticipantCount == 0 && eventType == EventType.webinar) {
        adjustedParticipantCount = 0;
      } else {
        final optionsAutoAdjust = AutoAdjustOptions(
          n: adjustedParticipantCount,
          eventType: eventType,
          shareScreenStarted: shareScreenStarted,
          shared: shared,
        );
        adjustedValues = await autoAdjust(
          optionsAutoAdjust,
        );
      }

      final mainScreenPercentage =
          100 - ((adjustedValues[0] / 12) * 100).floor();

      // Emit update if new timestamp or different last update
      if (lastUpdate == null || updateDateState != timestamp) {
        socket!.emitWithAck(
          'updateScreenClient',
          {
            'roomName': roomName,
            'names': refActiveNames,
            'mainPercent': mainScreenPercentage,
            'mainScreenPerson': personOnMainScreen,
            'viewType': eventType.name,
          },
          ack: (data) {
            updateDateState = timestamp;
            updateUpdateDateState(updateDateState);
            lastUpdate = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            updateLastUpdate(lastUpdate);
            if (data['success']) {
              // handle success
            } else {
              if (kDebugMode) {
                print('${data['reason']} updateScreenClient failed');
              }
            }
          },
        );
      }
    } else if (mainScreenFilled &&
        personOnMainScreen != null &&
        !adminOnMainScreen) {
      if (!refActiveNames.contains(adminName)) {
        refActiveNames.insert(0, adminName);
      }

      final optionsAutoAdjust = AutoAdjustOptions(
        n: refActiveNames.length,
        eventType: eventType,
        shareScreenStarted: shareScreenStarted,
        shared: shared,
      );
      final adjustedValues = await autoAdjust(
        optionsAutoAdjust,
      );
      final mainScreenPercentage =
          100 - ((adjustedValues[0] / 12) * 100).floor();

      if (lastUpdate == null || updateDateState != timestamp) {
        socket!.emitWithAck(
          'updateScreenClient',
          {
            'roomName': roomName,
            'names': refActiveNames,
            'mainPercent': mainScreenPercentage,
            'mainScreenPerson': personOnMainScreen,
            'viewType': eventType.name,
          },
          ack: (data) {
            updateDateState = timestamp;
            updateUpdateDateState(updateDateState);
            lastUpdate = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            updateLastUpdate(lastUpdate);
            if (data['success']) {
              // handle success
            } else {
              if (kDebugMode) {
                print('${data['reason']} updateScreenClient failed');
              }
            }
          },
        );
      }
    } else {
      if (kDebugMode) {
        // print('Trigger stopped recording');
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error in trigger: $error');
    }
  }
}
