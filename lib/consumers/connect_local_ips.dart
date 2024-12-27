import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import './socket_receive_methods/new_pipe_producer.dart' show newPipeProducer;
import './socket_receive_methods/producer_closed.dart' show producerClosed;
import '../types/types.dart'
    show
        NewPipeProducerOptions,
        NewPipeProducerParameters,
        NewPipeProducerType,
        ProducerClosedOptions,
        ProducerClosedParameters,
        ProducerClosedType,
        ReceiveAllPipedTransportsOptions,
        ReceiveAllPipedTransportsParameters,
        ReceiveAllPipedTransportsType,
        ReorderStreamsParameters,
        ReorderStreamsType;

/// Parameters interface for connecting local IPs and managing socket connections.
abstract class ConnectLocalIpsParameters
    implements
        ReorderStreamsParameters,
        ProducerClosedParameters,
        NewPipeProducerParameters,
        ReceiveAllPipedTransportsParameters {
  io.Socket? get socket;

  // Mediasfu functions
  ReorderStreamsType get reorderStreams;
  ReceiveAllPipedTransportsType get receiveAllPipedTransports;
  ConnectLocalIpsParameters Function() get getUpdatedAllParams;
}

/// Options for connecting local IPs and managing socket connections.
class ConnectLocalIpsOptions {
  final io.Socket? socket;
  final NewPipeProducerType? newProducerMethod;
  final ProducerClosedType? closedProducerMethod;
  final ConnectLocalIpsParameters parameters;

  ConnectLocalIpsOptions({
    required this.socket,
    this.newProducerMethod,
    this.closedProducerMethod,
    required this.parameters,
  });
}

/// Type definition for the [connectLocalIps] function.
typedef ConnectLocalIpsType = Future<void> Function(
    ConnectLocalIpsOptions options);

/// Connects to a local socket and manages socket events for media consumption.
///
/// This function sets up event listeners on the provided local socket for handling
/// new media producers and closed producers. It utilizes the provided methods to
/// manage these events accordingly.
///
/// ### Parameters:
/// - `options` (`ConnectLocalIpsOptions`): Configuration options for establishing connections and managing sockets:
///   - `socket` (`io.Socket`): The local socket connection.
///   - `newProducerMethod` (`NewPipeProducerType?`): Optional function to handle new pipe producer events.
///   - `closedProducerMethod` (`ProducerClosedType?`): Optional function to handle producer closed events.
///   - `parameters` (`ConnectLocalIpsParameters`): Parameters object to handle state updates and manage dependencies.
///
/// ### Returns:
/// - A `Future<void>` that completes when the connection setup is done.
///
/// ### Example Usage:
/// ```dart
/// final connectLocalIpsOptions = ConnectLocalIpsOptions(
///   socket: localSocket,
///   newProducerMethod: newPipeProducer,
///   closedProducerMethod: producerClosed,
///   parameters: connectLocalIpsParametersInstance,
/// );
///
/// connectLocalIps(connectLocalIpsOptions).then(() {
///   print('Connected to local IPs');
/// }).catchError((error) {
///   print('Error connecting to local IPs: $error');
/// });
/// ```
///
/// ### Error Handling:
/// Logs errors in debug mode if connection or socket events fail, without throwing exceptions.
Future<void> connectLocalIps(ConnectLocalIpsOptions options) async {
  final parameters = options.parameters.getUpdatedAllParams();

  final newProducerMethod = options.newProducerMethod ?? newPipeProducer;
  final closedProducerMethod = options.closedProducerMethod ?? producerClosed;

  try {
    final socket = options.socket;

    if (socket == null) {
      throw 'Socket connection is null';
    }

    //check if listener is already set
    if (socket.hasListeners('new-producer')) {
      return;
    }

    // Handle 'new-producer' event
    socket.on('new-producer', (data) async {
      final optionsNewPipeProducer = NewPipeProducerOptions(
        producerId: data['producerId'],
        islevel: data['islevel'],
        nsock: socket,
        parameters: parameters,
      );
      await newProducerMethod(
        optionsNewPipeProducer,
      );
    });

    // Handle 'producer-closed' event
    socket.on('producer-closed', (data) async {
      final optionsProducerClosed = ProducerClosedOptions(
        remoteProducerId: data['remoteProducerId'],
        parameters: parameters,
      );
      await closedProducerMethod(
        optionsProducerClosed,
      );
    });

    ReceiveAllPipedTransportsType receiveAllPipedTransports =
        parameters.receiveAllPipedTransports;

    // Initialize piped transports
    final optionsReceive = ReceiveAllPipedTransportsOptions(
      community: true,
      nsock: socket,
      parameters: parameters,
    );
    await receiveAllPipedTransports(optionsReceive);

    if (kDebugMode) {
      print('Successfully connected local IPs and set up event listeners.');
    }
  } catch (error) {
    if (kDebugMode) {
      print('ConnectLocalIps error: $error');
    }
  }
}
