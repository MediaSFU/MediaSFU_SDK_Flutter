import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../types/types.dart'
    show
        GetPipedProducersAltType,
        GetPipedProducersAltParameters,
        GetPipedProducersAltOptions;

/// Parameters for receiving all piped transports
abstract class ReceiveAllPipedTransportsParameters
    implements GetPipedProducersAltParameters {
  final String roomName;
  final String member;
  final GetPipedProducersAltType getPipedProducersAlt;

  ReceiveAllPipedTransportsParameters({
    required this.roomName,
    required this.member,
    required this.getPipedProducersAlt,
  });

  // dynamic operator [](String key);
}

class ReceiveAllPipedTransportsOptions {
  final io.Socket nsock;
  final ReceiveAllPipedTransportsParameters parameters;

  ReceiveAllPipedTransportsOptions({
    required this.nsock,
    required this.parameters,
  });
}

typedef ReceiveAllPipedTransportsType = Future<void> Function(
    ReceiveAllPipedTransportsOptions options);

/// Receives all piped transports for a specific room and member by requesting piped producers at different levels.
///
/// This function sends a `createReceiveAllTransportsPiped` event to the server, which checks if piped producers exist for the given room and member.
/// If producers are found, it calls the [getPipedProducersAlt] function to retrieve piped transports for levels 0, 1, and 2.
///
/// Parameters:
/// - [nsock] (`io.Socket`): The socket instance used for communication.
/// - [parameters] (`ReceiveAllPipedTransportsParameters`): The parameters required to receive piped transports.
///  - [roomName] (`String`): The name of the room to receive piped transports.
/// - [member] (`String`): The name of the member to receive piped transports.
/// - [getPipedProducersAlt] (`GetPipedProducersAltType`): The function to retrieve piped producers at different levels.
///
/// Example usage:
/// ```dart
/// receiveAllPipedTransports(
///  ReceiveAllPipedTransportsOptions(
///   nsock: socket,
///  parameters: ReceiveAllPipedTransportsParameters(
///   roomName: 'roomA',
///  member: 'userB',
///  getPipedProducersAlt: getPipedProducersAlt,
/// ),
/// ),
/// );
///
/// ```

Future<void> receiveAllPipedTransports(
    ReceiveAllPipedTransportsOptions options) async {
  final nsock = options.nsock;
  final parameters = options.parameters;
  final completer = Completer<void>();

  try {
    final options = ['0', '1', '2'];

    nsock.emitWithAck(
      'createReceiveAllTransportsPiped',
      {'roomName': parameters.roomName, 'member': parameters.member},
      ack: (response) async {
        if (response['producersExist'] == true) {
          // Retrieve piped producers for each level if producers exist
          for (final islevel in options) {
            final optionsGetPipedProducersAlt = GetPipedProducersAltOptions(
              nsock: nsock,
              islevel: islevel,
              parameters: parameters,
            );
            await parameters.getPipedProducersAlt(
              optionsGetPipedProducersAlt,
            );
          }
        }
        completer.complete();
      },
    );
  } catch (error) {
    if (kDebugMode) {
      print('Error in receiveAllPipedTransports: $error');
    }
    completer.completeError(error);
  }

  return completer.future;
}
