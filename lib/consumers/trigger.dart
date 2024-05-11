import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Triggers the screen update based on the given parameters.
///
/// The [refActiveNames] is a list of active names.
/// The [parameters] is a map of parameters including:
///   - [getUpdatedAllParams]: A function that returns updated parameters.
///   - [socket]: The socket for communication.
///   - [roomName]: The name of the room.
///   - [screenStates]: The list of screen states.
///   - [participants]: The list of participants.
///   - [updateDateState]: The update date state.
///   - [lastUpdate]: The last update.
///   - [nForReadjust]: The number for readjustment.
///   - [eventType]: The type of event.
///   - [shared]: A flag indicating if the screen is shared.
///   - [shareScreenStarted]: A flag indicating if the screen sharing has started.
///
/// The [autoAdjust] is a function that adjusts the screen based on the number of active names.
///
/// The function updates the screen based on the given parameters and emits the update to the client.
/// It handles different scenarios such as conferences, webinars, and screen filling.

typedef AutoAdjust = Future<List<int>> Function({
  required int n,
  required Map<String, dynamic> parameters,
});

typedef GetUpdatedAllParams = Map<String, dynamic> Function();

typedef GetEstimate = List<dynamic> Function(
    {required int n, required Map<String, dynamic> parameters});
typedef CheckGrid = Future<List<dynamic>> Function(
    int rows, int cols, int refLength);

typedef UpdateDateState = void Function(int timestamp);
typedef UpdateUpdateDateState = void Function(int timestamp);
typedef UpdateLastUpdate = void Function(int now);
typedef UpdateNForReadjust = void Function(int nForReadjust);
typedef UpdateScreenStates = void Function(
    List<Map<String, dynamic>> screenStates);

Future<void> trigger(
    {required List<String> refActiveNames,
    required Map<String, dynamic> parameters}) async {
  GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];

  parameters = getUpdatedAllParams();

  io.Socket socket = parameters['socket'];
  String roomName = parameters['roomName'];
  List<Map<String, dynamic>> screenStates = parameters['screenStates'] ?? [];
  List<dynamic> participants = parameters['participants'] ?? [];
  int updateDateState = parameters['updateDateState'] ?? 0;
  dynamic lastUpdate = parameters['lastUpdate'];
  int nForReadjust = parameters['nForReadjust'];
  String eventType = parameters['eventType'];
  bool shared = parameters['shared'] ?? false;
  bool shareScreenStarted = parameters['shareScreenStarted'] ?? false;

  UpdateUpdateDateState updateUpdateDateState =
      parameters['updateUpdateDateState'];
  UpdateLastUpdate updateLastUpdate = parameters['updateLastUpdate'];
  UpdateNForReadjust updateNForReadjust = parameters['updateNForReadjust'];

  // mediasfu functions
  AutoAdjust autoAdjust = parameters['autoAdjust'];

  String? personOnMainScreen = screenStates[0]['mainScreenPerson'];
  bool? mainfilled = screenStates[0]['mainScreenFilled'];
  bool? adminOnMain = screenStates[0]['adminOnMainScreen'];
  int nForReadjust_;
  int val1;

  int noww = DateTime.now().millisecondsSinceEpoch;
  int timestamp = noww ~/ 1000;

  bool eventPass = false;

  if (eventType == 'conference' && !(shared || shareScreenStarted)) {
    eventPass = true;

    List<dynamic> admin = participants
        .where((participant) =>
            participant['isAdmin'] == true && participant['islevel'] == '2')
        .toList();
    String adminName = "";

    if (admin.isNotEmpty) {
      adminName = admin[0]['name'];
    }

    personOnMainScreen = adminName;

    if (!refActiveNames.contains(adminName)) {
      refActiveNames.insert(0, adminName);
    }
  }

  if ((mainfilled! && personOnMainScreen != null && adminOnMain!) ||
      eventPass) {
    dynamic admin = participants
        .where((participant) =>
            participant['isAdmin'] == true && participant['islevel'] == '2')
        .toList();

    if (admin.isNotEmpty) {}

    nForReadjust = nForReadjust + 1;
    updateNForReadjust(nForReadjust);

    nForReadjust_ = refActiveNames.length;

    if (nForReadjust_ == 0 && eventType == 'webinar') {
      val1 = 0;
    } else {
      List<int> adjustedValues =
          await autoAdjust(n: nForReadjust_, parameters: parameters);
      val1 = adjustedValues[0];
    }

    int calc1 = ((val1 / 12) * 100).floor();
    int calc2 = 100 - calc1;

    if (lastUpdate == null || (updateDateState != timestamp)) {
      socket.emitWithAck('updateScreenClient', {
        'roomName': roomName,
        'names': refActiveNames,
        'mainPercent': calc2,
        'mainScreenPerson': personOnMainScreen,
        'viewType': eventType
      }, ack: (data) {
        updateDateState = timestamp;
        updateUpdateDateState(timestamp);
        updateLastUpdate(timestamp);

        if (data['success']) {
          // handle success
        } else {
          if (kDebugMode) {
            print('${data['reason']} updateScreenClient failed');
          }
        }
      });
    }
  } else if (mainfilled && personOnMainScreen != null && !adminOnMain!) {
    dynamic admin = participants
        .where((participant) =>
            participant['isAdmin'] == true && participant['islevel'] == '2')
        .toList();
    String adminName = "";

    if (admin.length > 0) {
      adminName = admin[0]['name'];
    }

    nForReadjust_ = refActiveNames.length;

    if (!refActiveNames.contains(adminName)) {
      refActiveNames.insert(0, adminName);
      nForReadjust_ = refActiveNames.length;
    }

    List<int> adjustedValues =
        await autoAdjust(n: nForReadjust_, parameters: parameters);
    val1 = adjustedValues[0];

    int calc1 = ((val1 / 12) * 100).floor();
    int calc2 = 100 - calc1;

    if (lastUpdate == null || (updateDateState != timestamp)) {
      socket.emitWithAck('updateScreenClient', {
        'roomName': roomName,
        'names': refActiveNames,
        'mainPercent': calc2,
        'mainScreenPerson': personOnMainScreen,
        'viewType': eventType
      }, ack: (data) {
        updateDateState = timestamp;
        updateUpdateDateState(timestamp);
        updateLastUpdate(timestamp);

        if (data['success']) {
          // handle success
        } else {
          if (kDebugMode) {
            print('${data['reason']} updateScreenClient failed');
          }
        }
      });
    }
  } else {
    //stop recording
    if (kDebugMode) {
      print('trigger stopRecording');
    }
  }
}
