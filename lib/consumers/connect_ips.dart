import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../sockets/socket_manager.dart' show connectSocket;
import './socket_receive_methods/new_pipe_producer.dart' show newPipeProducer;
import './socket_receive_methods/producer_closed.dart' show producerClosed;
import './socket_receive_methods/join_consume_room.dart' show joinConsumeRoom;
import '../types/types.dart'
    show
        ConnectSocketOptions,
        JoinConsumeRoomOptions,
        JoinConsumeRoomParameters,
        JoinConsumeRoomType,
        NewPipeProducerOptions,
        NewPipeProducerParameters,
        NewPipeProducerType,
        ProducerClosedOptions,
        ProducerClosedParameters,
        ProducerClosedType,
        ReorderStreamsParameters,
        ReorderStreamsType,
        ResponseJoinRoom;

/// Parameters interface for connecting IPs and managing socket connections.
abstract class ConnectIpsParameters
    implements
        ReorderStreamsParameters,
        JoinConsumeRoomParameters,
        ProducerClosedParameters,
        NewPipeProducerParameters {
  Device? get device;
  List<String> get roomRecvIPs;
  void Function(List<String> roomRecvIPs) get updateRoomRecvIPs;
  void Function(List<Map<String, io.Socket>> consumeSockets)
      get updateConsumeSockets;

  // mediasfu functions
  ReorderStreamsType get reorderStreams;
  ConnectIpsParameters Function() get getUpdatedAllParams;
}

/// Options for connecting IPs and managing socket connections.
class ConnectIpsOptions {
  final List<Map<String, io.Socket>> consumeSockets;
  final List<String> remIP;
  final String apiUserName;
  final String? apiKey;
  final String apiToken;
  final NewPipeProducerType? newProducerMethod;
  final ProducerClosedType? closedProducerMethod;
  final JoinConsumeRoomType? joinConsumeRoomMethod;
  final ConnectIpsParameters parameters;

  ConnectIpsOptions({
    required this.consumeSockets,
    required this.remIP,
    required this.apiUserName,
    this.apiKey,
    required this.apiToken,
    this.newProducerMethod,
    this.closedProducerMethod,
    this.joinConsumeRoomMethod,
    required this.parameters,
  });
}

/// Type definition for the [connectIps] function.
typedef ConnectIpsType = Future<List<dynamic>> Function(
    ConnectIpsOptions options);

/// Connects to multiple remote IPs to manage socket connections for media consumption.
///
/// This function iterates over a list of remote IPs, attempting to establish socket connections
/// and manage events for new media producers and closed producers in the connected rooms. If successful,
/// it updates the `consumeSockets` list with each connected socket and tracks connected IPs in `roomRecvIPs`.
///
/// ### Parameters:
/// - `options` (`ConnectIpsOptions`): Configuration options for establishing connections and managing sockets:
///   - `consumeSockets` (`List<Map<String, io.Socket>>`): A list of socket connections for each IP.
///   - `remIP` (`List<String>`): A list of remote IPs to connect to.
///   - `apiUserName` (`String`): API username for authentication.
///   - `apiKey` (`String?`): Optional API key for authentication.
///   - `apiToken` (`String`): API token for authentication.
///   - `newProducerMethod` (`NewPipeProducerType?`): Optional function to handle new producer events.
///   - `closedProducerMethod` (`ProducerClosedType?`): Optional function to handle closed producer events.
///   - `joinConsumeRoomMethod` (`JoinConsumeRoomType?`): Optional function to handle joining a room.
///   - `parameters` (`ConnectIpsParameters`): Parameters object to handle state updates and manage dependencies.
///
/// ### Returns:
/// - A `Future<List<dynamic>>` containing:
///   - Updated list of `consumeSockets` with newly connected sockets.
///   - Updated list of `roomRecvIPs` with connected IP addresses.
///
/// ### Example Usage:
/// ```dart
/// final options = ConnectIpsOptions(
///   consumeSockets: [],
///   remIP: ['100.122.1.1', '100.122.1.2'],
///   apiUserName: 'myUserName',
///   apiToken: 'myToken',
///   parameters: myConnectIpsParametersInstance,
/// );
///
/// connectIps(options).then(([consumeSockets, roomRecvIPs]) {
///   print('Successfully connected to IPs: $roomRecvIPs');
///   print('Active consume sockets: $consumeSockets');
/// });
/// ```
///
/// ### Error Handling:
/// Logs errors in debug mode if connection or socket events fail, without throwing exceptions.

Future<List<dynamic>> connectIps(ConnectIpsOptions options) async {
  var parameters = options.parameters.getUpdatedAllParams();

  // Extract parameters
  List<Map<String, io.Socket>> consumeSockets = options.consumeSockets;
  List<String> roomRecvIPs = parameters.roomRecvIPs;
  final updateRoomRecvIPs = parameters.updateRoomRecvIPs;
  final updateConsumeSockets = parameters.updateConsumeSockets;

  final newProducerMethod = options.newProducerMethod ?? newPipeProducer;
  final closedProducerMethod = options.closedProducerMethod ?? producerClosed;
  final joinConsumeRoomMethod =
      options.joinConsumeRoomMethod ?? joinConsumeRoom;

  try {
    // Check for required parameters
    if (options.apiKey == null && options.apiToken.isEmpty) {
      if (kDebugMode) {
        print('Missing required parameters for authentication');
      }
      return [consumeSockets, roomRecvIPs];
    }

    for (final ip in options.remIP) {
      try {
        // Check if the IP is already connected
        final existingSocket = consumeSockets.firstWhere(
          (socketObj) => socketObj.keys.first == ip,
          orElse: () => {},
        );

        if (existingSocket.isNotEmpty || ip.isEmpty) {
          continue;
        }

        // Connect to the remote socket using SocketManager
        final optionsConnect = ConnectSocketOptions(
          apiUserName: options.apiUserName,
          apiKey: options.apiKey ?? '',
          apiToken: options.apiToken,
          link: 'https://$ip.mediasfu.com',
        );
        io.Socket remoteSock = await connectSocket(
          optionsConnect,
        );

        if (remoteSock.id != null && remoteSock.id!.isNotEmpty) {
          if (!roomRecvIPs.contains(ip)) {
            roomRecvIPs.add(ip);
            updateRoomRecvIPs(roomRecvIPs);
          }

          // Event handler for 'new-pipe-producer'
          remoteSock.on('new-pipe-producer', (data) async {
            final optionsNewPipeProducer = NewPipeProducerOptions(
              producerId: data['producerId'],
              islevel: data['islevel'],
              nsock: remoteSock,
              parameters: parameters,
            );
            await newProducerMethod(
              optionsNewPipeProducer,
            );
          });

          // Event handler for 'producer-closed'
          remoteSock.on('producer-closed', (data) async {
            final optionsProducerClosed = ProducerClosedOptions(
              remoteProducerId: data['remoteProducerId'],
              parameters: parameters,
            );
            await closedProducerMethod(
              optionsProducerClosed,
            );
          });

          // Join the consumption room if required
          final optionsJoinConsume = JoinConsumeRoomOptions(
            remoteSock: remoteSock,
            apiToken: options.apiToken,
            apiUserName: options.apiUserName,
            parameters: parameters,
          );

          final dataJSON = await joinConsumeRoomMethod(
            optionsJoinConsume,
          );

          if (dataJSON is Map<String, dynamic>) {
            final data = ResponseJoinRoom.fromJson(dataJSON);

            if (data.rtpCapabilities == null) {
              return [consumeSockets, roomRecvIPs];
            }

            // Add the remote socket to the consumeSockets array
            consumeSockets.add({ip: remoteSock});
            updateConsumeSockets(consumeSockets);
          }
        }
      } catch (error) {
        if (kDebugMode) {
          print('connectIps error with IP $ip: $error');
        }
      }
    }

    return [consumeSockets, roomRecvIPs];
  } catch (error) {
    if (kDebugMode) {
      print('connectIps error: $error');
    }
    return [consumeSockets, parameters.roomRecvIPs];
  }
}
