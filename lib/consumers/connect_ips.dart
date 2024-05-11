import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../sockets/socket_manager.dart' show connectSocket;
import './socket_receive_methods/new_pipe_producer.dart' show newPipeProducer;
import './socket_receive_methods/producer_closed.dart' show producerClosed;
import './socket_receive_methods/join_consume_room.dart' show joinConsumeRoom;

/// Connects to the specified IP addresses (subdomains) and performs various operations.
///
/// The [consumeSockets] parameter is a list of maps containing socket objects.
/// The [remIP] parameter is a list of dynamic values representing remote IP addresses.
/// The [apiUserName] parameter is a required string representing the API username.
/// The [apiKey] parameter is an optional string representing the API key.
/// The [apiToken] parameter is an optional string representing the API token.
/// The [newProducerMethod] parameter is a function that takes in producer details and returns a future.
/// The [closedProducerMethod] parameter is a function that takes in producer details and returns a future.
/// The [joinConsumeRoomMethod] parameter is a function that takes in socket details and returns a future.
/// The [parameters] parameter is a map containing additional parameters.
///
/// Returns a future that completes with a list containing the updated [consumeSockets] and [roomRecvIPs].
/// If an error occurs, the original [consumeSockets] and [roomRecvIPs] are returned.

typedef NewProducerMethod = Future<void> Function({
  required String producerId,
  required String islevel,
  required io.Socket nsock,
  required Map<String, dynamic> parameters,
});

typedef ClosedProducerMethod = Future<void> Function({
  required String remoteProducerId,
  required Map<String, dynamic> parameters,
});

typedef JoinConsumeRoomMethod = Future<Map<String, dynamic>> Function({
  required io.Socket remoteSock,
  required String apiToken,
  required String apiUserName,
  required Map<String, dynamic> parameters,
});

typedef UpdateConsumeSockets = void Function(List<Map<String, io.Socket>>);

Future<List<dynamic>> connectIps({
  required List<Map<String, io.Socket>> consumeSockets,
  required List<dynamic> remIP,
  required String apiUserName,
  String? apiKey,
  String? apiToken,
  NewProducerMethod? newProducerMethod,
  ClosedProducerMethod? closedProducerMethod,
  JoinConsumeRoomMethod? joinConsumeRoomMethod,
  required Map<String, dynamic> parameters,
}) async {
  newProducerMethod ??= newPipeProducer;
  closedProducerMethod ??= producerClosed;
  joinConsumeRoomMethod ??= joinConsumeRoom;

  apiKey ??= parameters['apiKey'];
  apiToken ??= parameters['apiToken'];

  try {
    final List<dynamic> roomRecvIPs = parameters['roomRecvIPs'];

    UpdateConsumeSockets updateConsumeSockets =
        parameters['updateConsumeSockets'];

    if ((apiKey == null && apiToken == null)) {
      return [consumeSockets, roomRecvIPs];
    }

    await Future.forEach(remIP, (ip) async {
      try {
        final matching = consumeSockets.firstWhere(
            (socketObj) => socketObj.keys.first == ip,
            orElse: () => <String, io.Socket>{});

        if (matching.isEmpty && ip != null && ip.isNotEmpty) {
          io.Socket remoteSock = await connectSocket(
              apiUserName, apiKey!, apiToken!, 'https://$ip.mediasfu.com');

          if (remoteSock.id != null && remoteSock.id != '') {
            if (!roomRecvIPs.contains(ip)) {
              roomRecvIPs.add(ip);
              parameters['updateRoomRecvIPs'](roomRecvIPs);
            }

            remoteSock.on('new-pipe-producer', (data) async {
              if (newProducerMethod != null) {
                await newProducerMethod(
                    producerId: data['producerId'],
                    islevel: data['islevel'],
                    nsock: remoteSock,
                    parameters: parameters);
              }
            });

            remoteSock.on('producer-closed', (data) async {
              if (closedProducerMethod != null) {
                await closedProducerMethod(
                    remoteProducerId: data['remoteProducerId'],
                    parameters: parameters);
              }
            });

            if (joinConsumeRoomMethod != null) {
              final data = await joinConsumeRoomMethod(
                  remoteSock: remoteSock,
                  apiToken: apiToken,
                  apiUserName: apiUserName,
                  parameters: parameters);
              if (data.isNotEmpty && data['rtpCapabilities'] == null) {
                return;
              }
            } else {
              try {
                final data = await joinConsumeRoomMethod!(
                    remoteSock: remoteSock,
                    apiToken: apiToken,
                    apiUserName: apiUserName,
                    parameters: parameters);
                if (data.isNotEmpty && data['rtpCapabilities'] == null) {
                  return;
                }
              } catch (error) {
                if (parameters['showAlert'] != null) {
                  parameters['showAlert']({
                    'message': error.toString(),
                    'type': 'danger',
                    'duration': 3000,
                  });
                }
              }
            }

            consumeSockets.add({ip: remoteSock});
            updateConsumeSockets(consumeSockets);
          }
        }
      } catch (error) {
        if (kDebugMode) {
          print('MediaSFU - connectIps error: $error');
        }
      }
    });

    return [consumeSockets, roomRecvIPs];
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - connectIps error: $error');
    }
    return [consumeSockets, parameters['roomRecvIPs']];
  }
}
