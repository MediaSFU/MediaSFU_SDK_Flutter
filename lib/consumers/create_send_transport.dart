import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../types/types.dart'
    show
        ConnectSendTransportOptions,
        ConnectSendTransportParameters,
        ConnectSendTransportType;

// Define type aliases for callback functions
typedef UpdateProducerTransport = void Function(Transport? producerTransport);
typedef UpdateTransportCreated = void Function(bool transportCreated);
typedef UpdateScreenProducer = void Function(Producer? producer);
typedef UpdateAudioProducer = void Function(Producer? producer);
typedef UpdateVideoProducer = void Function(Producer? producer);

// Dart equivalent of CreateSendTransportParameters interface
abstract class CreateSendTransportParameters
    implements ConnectSendTransportParameters {
  String get islevel;
  String get member;
  io.Socket? get socket;
  Device? get device;
  bool get transportCreated;
  Transport? get producerTransport;

  UpdateProducerTransport get updateProducerTransport;
  UpdateTransportCreated get updateTransportCreated;
  UpdateScreenProducer get updateScreenProducer;
  UpdateAudioProducer get updateAudioProducer;
  UpdateVideoProducer get updateVideoProducer;

  // mediasfu functions
  ConnectSendTransportType get connectSendTransport;

  // Method to retrieve updated parameters
  CreateSendTransportParameters Function() get getUpdatedAllParams;

  // Dynamic access to other properties if needed
  // dynamic operator [](String key);
  // void operator []=(String key, dynamic value);
}

// Dart equivalent of CreateSendTransportOptions interface
class CreateSendTransportOptions {
  final String option; // 'audio', 'video', 'screen', or 'all'
  final CreateSendTransportParameters parameters;
  Map<String, dynamic>? audioConstraints;
  Map<String, dynamic>? videoConstraints;

  CreateSendTransportOptions({
    required this.option,
    required this.parameters,
    this.audioConstraints,
    this.videoConstraints,
  });
}

// Type definition for CreateSendTransportType function
typedef CreateSendTransportType = Future<void> Function(
    CreateSendTransportOptions options);

/// Creates a WebRTC send transport for media transmission (audio, video, or screen).
///
/// This function initiates a WebRTC send transport with a server for sending media streams (audio, video, screen).
/// It performs the following actions:
/// 1. Emits a `createWebRtcTransport` event to the server to request the creation of a WebRTC transport.
/// 2. Sets up a transport to handle events for connecting, producing, and monitoring connection state changes.
/// 3. Calls `connectSendTransport` for further media setup and transmission.
///
/// ### Parameters:
/// - `options` (`CreateSendTransportOptions`): Contains the option specifying the media type ('audio', 'video', 'screen', or 'all')
///    and the parameters required for transport creation.
///
/// ### Logic Flow:
/// 1. **Emit `createWebRtcTransport` Event**:
///    - Requests a WebRTC transport from the server.
///    - Waits for an acknowledgment from the server containing transport parameters or an error response.
/// 2. **Transport Setup**:
///    - Creates the send transport with callbacks for producer updates.
///    - Sets up `connect`, `produce`, and `connectionstatechange` events on the transport.
///      - **`connect`**: Completes the DTLS connection by sending DTLS parameters to the server.
///      - **`produce`**: Initiates media transmission by sending RTP parameters and additional data to the server.
///      - **`connectionstatechange`**: Monitors the transport’s state, handling any failures.
/// 3. **Invoke `connectSendTransport`**:
///    - Calls `connectSendTransport` to finalize and manage ongoing media transmission based on the selected option.
///
/// ### Callbacks:
/// - **Producer Callback**: Selects the appropriate producer (audio, video, or screen) for the current transport session.
/// - **Connection Events**: Sets up handlers for connection, media production, and connection state changes.
///
/// ### Throws:
/// - Logs an error if transport creation fails at any stage.
///
/// ### Example Usage:
/// ```dart
/// final options = CreateSendTransportOptions(
///   option: 'video',
///   parameters: MyCreateSendTransportParameters(
///     islevel: '2',
///     member: 'user123',
///     socket: mySocket,
///     device: myDevice,
///     transportCreated: false,
///     updateProducerTransport: (transport) => print('Producer Transport updated'),
///     updateTransportCreated: (created) => print('Transport created: $created'),
///     updateScreenProducer: (producer) => print('Screen Producer updated'),
///     updateAudioProducer: (producer) => print('Audio Producer updated'),
///     updateVideoProducer: (producer) => print('Video Producer updated'),
///     connectSendTransport: connectSendTransport,
///   ),
/// );
///
/// createSendTransport(options).then((_) {
///   print('Send transport created successfully.');
/// }).catchError((error) {
///   print('Error creating send transport: $error');
/// });
/// ```
///
/// ### Notes:
/// - This function relies on socket-based communication with the server to manage transport creation and media production.
/// - Specific callback functions for updating producers (audio, video, screen) allow flexible media handling.

Future<void> createSendTransport(
  CreateSendTransportOptions options,
) async {
  try {
    // Destructure parameters from the options
    final parameters = options.parameters;
    String islevel = parameters.islevel;
    String member = parameters.member;
    io.Socket? socket = parameters.socket;
    Device? device = parameters.device;
    bool transportCreated = parameters.transportCreated;
    Transport? producerTransport = parameters.producerTransport;

    // Callback functions from parameters
    final updateProducerTransport = parameters.updateProducerTransport;
    final updateTransportCreated = parameters.updateTransportCreated;
    final updateScreenProducer = parameters.updateScreenProducer;
    final updateAudioProducer = parameters.updateAudioProducer;
    final updateVideoProducer = parameters.updateVideoProducer;
    final connectSendTransport = parameters.connectSendTransport;

    // Get updated device and socket parameters if necessary
    final updatedParams = parameters.getUpdatedAllParams();
    device = updatedParams.device;
    socket = updatedParams.socket;

    // Emit 'createWebRtcTransport' event to the server
    Completer<Map<String, dynamic>> producerCompleter = Completer();
    socket!.emitWithAck(
      'createWebRtcTransport',
      {'consumer': false, 'islevel': islevel},
      ack: (response) async {
        if (response['error'] != null) {
          producerCompleter.completeError(response['error']);
        } else {
          producerCompleter.complete(response['params']);
        }

        Map<String, dynamic> webrtcTransportMap =
            await producerCompleter.future;

        //producer callback function
        void producerCallbackFunction(Producer producer) {
          producer.kind == 'video' && producer.source == 'screen'
              ? updateScreenProducer(producer)
              : producer.kind == 'audio'
                  ? updateAudioProducer(producer)
                  : updateVideoProducer(producer);
        }

        try {
          // Create a WebRTC send transport
          producerTransport = device?.createSendTransportFromMap(
            webrtcTransportMap,
            producerCallback: producerCallbackFunction,
          );
        } catch (error) {
          if (kDebugMode) {
            print('MediaSFU - Error creating send transport: $error');
          }
        }
        updateProducerTransport(producerTransport);

        // Handle 'connect' event for DTLS connection
        producerTransport?.on('connect', (data) async {
          try {
            socket!.emit('transport-connect',
                {'dtlsParameters': data['dtlsParameters'].toMap()});
            data['callback']();
          } catch (error) {
            data['errback'](error);
          }
        });

        // Handle 'produce' event to initiate media transmission
        producerTransport?.on('produce', (data) async {
          try {
            socket!.emitWithAck('transport-produce', {
              'kind': data['kind'],
              'rtpParameters': data['rtpParameters'].toMap(),
              if (data['appData'] != null)
                'appData': Map<String, dynamic>.from(data['appData']),
              'islevel': islevel,
              'name': member,
            }, ack: (response) async {
              data['callback'](response['id']);
            });
          } catch (error) {
            data['errback'](error);
          }
        });

        // Monitor the connection state and handle any failures
        producerTransport?.on('connectionstatechange', (state) async {
          switch (state) {
            case 'connecting':
              break;
            case 'connected':
              break;
            case 'failed':
              if (kDebugMode) print("Transport connection failed.");
              await producerTransport?.close();
              break;
            default:
              break;
          }
        });

        // Set transport as created and invoke connectSendTransport
        transportCreated = true;
        updateTransportCreated(transportCreated);
        try {
          parameters.updateProducerTransport(producerTransport);
          final optionsConnect = ConnectSendTransportOptions(
            option: options.option,
            parameters: parameters,
            audioConstraints: options.audioConstraints,
            videoConstraints: options.videoConstraints,
          );
          await connectSendTransport(
            optionsConnect,
          );
        } catch (error) {
          if (kDebugMode) {
            print("Error in transport creation: $error");
          }
        }
      },
    );
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - Error creating send transport: $error');
    }
  }
}
