import 'dart:async'; // Import async for Future
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart'
    as io; // Import socket_io_client

/// Receives all piped transports.
///
/// This function receives all piped transports for a given room and member.
/// It emits a socket event to create receive all transports piped and calls the
/// [getPipedProducersAlt] callback function for each islevel option if producers exist.
/// It returns a Future that completes when the operation is finished.

typedef GetPipedProducersAlt = void Function(
    {required io.Socket nsock,
    required String islevel,
    required Map<String, dynamic> parameters});

Future<void> receiveAllPipedTransports({
  required io.Socket nsock,
  required Map<String, dynamic> parameters,
}) async {
  Completer<void> completer = Completer<void>(); // Create a Completer

  try {
    String roomName = parameters['roomName'];
    String member = parameters['member'];
    GetPipedProducersAlt getPipedProducersAlt =
        parameters['getPipedProducersAlt'];

    nsock.emitWithAck('createReceiveAllTransportsPiped', {
      'roomName': roomName,
      'member': member,
    }, ack: (dynamic response) {
      var options = ['0', '1', '2'];
      if (response['producersExist']) {
        for (String islevel in options) {
          getPipedProducersAlt(
              nsock: nsock, islevel: islevel, parameters: parameters);
        }
      }
      completer.complete(); // Complete the Future when finished
    });
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - receiveAllPipedTransports error: $error');
    }
    completer
        .completeError(error); // Complete with an error if an exception occurs
  }

  return completer.future; // Return the Future of the Completer
}
