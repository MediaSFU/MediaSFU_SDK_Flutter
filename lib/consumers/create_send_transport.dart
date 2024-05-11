import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';

/// Creates a WebRTC send transport and connects it to the server.
///
/// The [option] parameter specifies the transport option.
/// The [parameters] parameter is a map containing the necessary parameters for transport creation.
///
/// This function emits a 'createWebRtcTransport' event to the server and waits for the response.
/// If the response contains an error, it completes with an error.
/// Otherwise, it completes with the response parameters.
///
/// After creating the transport, it sets up event listeners for 'connect', 'produce', and 'connectionstatechange' events.
/// It also calls the provided callback functions to update the producer transport and other related objects.
///
/// Finally, it calls the [connectSendTransport] function to connect the transport to the server.
///
/// Throws an error if there is an error during transport creation or connection.

typedef UpdateTransportCreated = void Function(bool transportCreated);
typedef UpdateProducerTransport = void Function(dynamic producerTransport);
typedef UpdateVideoProducer = void Function(dynamic videoProducer);
typedef UpdateAudioProducer = void Function(dynamic audioProducer);
typedef UpdateScreenProducer = void Function(dynamic screenProducer);
typedef ConnectSendTransport = Future<void> Function({
  required String option,
  required Map<String, dynamic> parameters,
});
typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

Future<void> createSendTransport(
    {required String option, required Map<String, dynamic> parameters}) async {
  try {
    // Destructure parameters
    String islevel = parameters['islevel'] ?? '1';
    String member = parameters['member'] ?? '';
    final io.Socket socket = parameters['socket'];
    Device device = parameters['getUpdatedAllParams']()['device'];
    bool transportCreated = parameters['transportCreated'];
    dynamic producerTransport = parameters['producerTransport'];
    UpdateProducerTransport updateProducerTransport =
        parameters['updateProducerTransport'];
    UpdateTransportCreated updateTransportCreated =
        parameters['updateTransportCreated'];
    UpdateVideoProducer updateVideoProducer = parameters['updateVideoProducer'];
    UpdateAudioProducer updateAudioProducer = parameters['updateAudioProducer'];
    UpdateScreenProducer updateScreenProducer =
        parameters['updateScreenProducer'];

    //mediasfu functions
    ConnectSendTransport connectSendTransport =
        parameters['connectSendTransport'];

    // Emit createWebRtcTransport event to the server
    Completer completer = Completer();
    socket.emitWithAck(
        'createWebRtcTransport', {'consumer': false, 'islevel': islevel},
        ack: (dynamic params) async {
      // Check if there is an error in the response
      if (params['error'] != null) {
        completer.completeError(params['error']);
      } else {
        completer.complete(params);
      }

      var webrtcTransport = await completer.future;

      //producer callback function
      void producerCallbackFunction(Producer producer) {
        producer.kind == 'video' && producer.source == 'screen'
            ? updateScreenProducer(producer)
            : producer.kind == 'audio'
                ? updateAudioProducer(producer)
                : updateVideoProducer(producer);
      }

      // Create a WebRTC send transport
      try {
        producerTransport = device.createSendTransportFromMap(
          webrtcTransport['params'],
          producerCallback: producerCallbackFunction,
        );
      } catch (error) {
        if (kDebugMode) {
          print('MediaSFU - Error creating send transport: $error');
        }
      }

      updateProducerTransport(producerTransport);

      // Handle 'connect' event
      producerTransport.on('connect', (data) async {
        try {
          socket.emit('transport-connect', {
            'dtlsParameters': data['dtlsParameters'].toMap(),
          });
          data['callback']();
        } catch (error) {
          data['errback'](error);
        }
      });

      // Handle 'produce' event
      producerTransport.on('produce', (data) async {
        try {
          socket.emitWithAck('transport-produce', {
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
          if (kDebugMode) {
            // print('Error in producerTransport.on(produce): $error');
          }

          data['errback'](error);
        }
      });

      // Handle 'connectionstatechange' event
      producerTransport.on('connectionstatechange', (state) async {
        switch (state) {
          case 'connecting':
            break;
          case 'connected':
            break;
          case 'failed':
            await producerTransport.close();
            break;
          default:
            break;
        }
      });

      transportCreated = true;
      updateTransportCreated(transportCreated);
      try {
        await connectSendTransport(
          option: option,
          parameters: {
            ...parameters,
            'producerTransport': producerTransport,
          },
        );
      } catch (error) {
        if (kDebugMode) {
          // print('Error in connectSendTransport: $error');
        }
      }
    });
  } catch (error) {
    // Handle errors during transport creation
    if (kDebugMode) {
      print('MediaSFU - Error creating send transport: $error');
    }
  }
}
