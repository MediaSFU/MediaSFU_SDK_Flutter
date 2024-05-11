import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../../producers/producer_emits/join_con_room.dart' show joinConRoom;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

/// Joins a consumption room and handles necessary setup.
///
/// This function is responsible for joining a consumption room and performing
/// any necessary setup tasks. It takes in various parameters including the
/// remote socket, API token, API username, and additional parameters needed
/// for the setup process.
///
/// The function returns a `Future` that resolves to a `Map<String, dynamic>`
/// containing the result of the join operation.

typedef ReceiveAllPipedTransports = Future<void> Function({
  required io.Socket nsock,
  required Map<String, dynamic> parameters,
});

typedef CreateDeviceClient = Future<Device> Function({
  required dynamic rtpCapabilities,
});

Future<Map<String, dynamic>> joinConsumeRoom({
  required io.Socket remoteSock,
  required String apiToken,
  required String apiUserName,
  required Map<String, dynamic> parameters,
}) async {
  // Joins a consumption room and handles necessary setup

  String roomName = parameters['roomName'];
  String islevel = parameters['islevel'];
  String member = parameters['member'];
  Device? device = parameters['device'];

  // mediasfu functions
  ReceiveAllPipedTransports receiveAllPipedTransports =
      parameters['receiveAllPipedTransports'];
  CreateDeviceClient createDeviceClient = parameters['createDeviceClient'];

  try {
    // Join the consumption room
    Map<String, dynamic> data = await joinConRoom(
      remoteSock,
      roomName,
      islevel,
      member,
      apiToken,
      apiUserName,
    );

    // ignore: unnecessary_null_comparison
    if (data != null && data['success'] == true) {
      // Setup media device if not already set
      if (device == null) {
        if (data['rtpCapabilities'] != null) {
          Device device_ = await createDeviceClient(
            rtpCapabilities: data['rtpCapabilities'],
          );

          // ignore: unnecessary_null_comparison
          if (device_ != null) {
            parameters['updateDevice'](device_);
          }
        }
      }

      // Receive all piped transports
      await receiveAllPipedTransports(
        nsock: remoteSock,
        parameters: parameters,
      );
    }

    return data;
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - Error in joinConsumeRoom: $error');
      // print('Error in joinConsumeRoom stackTrace: $stackTrace');
    }

    throw Exception(
        'Failed to join the consumption room or set up necessary components.');
  }
}
