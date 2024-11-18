import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../../producers/producer_emits/join_con_room.dart' show joinConRoom;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import '../../types/types.dart'
    show
        ReceiveAllPipedTransportsParameters,
        ReceiveAllPipedTransportsType,
        CreateDeviceClientType,
        JoinConRoomOptions,
        ResponseJoinRoom,
        CreateDeviceClientOptions,
        ReceiveAllPipedTransportsOptions;

/// Interface for parameters required by the [joinConsumeRoom] function.
///
/// Contains properties such as room information, participant level, and device setup.
abstract class JoinConsumeRoomParameters
    implements ReceiveAllPipedTransportsParameters {
  String get roomName;
  String get islevel;
  String get member;
  Device? get device;

  void Function(Device? device) get updateDevice;

  // Mediasfu functions
  ReceiveAllPipedTransportsType get receiveAllPipedTransports;
  CreateDeviceClientType get createDeviceClient;

  JoinConsumeRoomParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Options for the [joinConsumeRoom] function.
///
/// Encapsulates required parameters such as the remote socket, API token, username,
/// and additional parameters for joining a consumption room.
class JoinConsumeRoomOptions {
  final io.Socket remoteSock;
  final String apiToken;
  final String apiUserName;
  final JoinConsumeRoomParameters parameters;

  JoinConsumeRoomOptions({
    required this.remoteSock,
    required this.apiToken,
    required this.apiUserName,
    required this.parameters,
  });
}

typedef JoinConsumeRoomType = Future<Map<String, dynamic>> Function(
    JoinConsumeRoomOptions options);

/// Joins a consumption room, initiates a media `Device` if necessary, and sets up piped transports for streaming.
///
/// This function:
/// 1. Sends a request to join a specified consumption room using provided authentication details.
/// 2. Checks if a media `Device` needs to be initialized, and creates it using RTP capabilities if required.
/// 3. Calls `receiveAllPipedTransports` to establish the necessary piped transports for media sharing.
///
/// ### Parameters:
///
/// - `options` (`JoinConsumeRoomOptions`): An options object containing:
///   - `remoteSock` (`io.Socket`): The remote socket for communication.
///   - `apiToken` (`String`): The API token for authentication.
///   - `apiUserName` (`String`): The username for API access.
///   - `parameters` (`JoinConsumeRoomParameters`): Room-specific settings, including:
///       - `roomName`: The name of the room to join.
///       - `islevel`: Participant level in the room.
///       - `member`: Unique member identifier.
///       - `device`: Media `Device` instance, if already initialized.
///       - `receiveAllPipedTransports`: A function to handle piped transport setup.
///       - `createDeviceClient`: A function to initialize a new media `Device`.
///       - `updateDevice`: A function to update the `Device` if initialized within the function.
///
/// ### Returns:
///
/// A `Future<ResponseJoinRoom>` containing the result of the join operation, including details about room
/// participants and RTP capabilities if the join operation is successful.
///
/// ### Throws:
///
/// Throws an `Exception` if there is an error joining the room, creating the `Device`, or setting up piped transports.
///
/// ### Example:
///
/// ```dart
/// import 'package:socket_io_client/socket_io_client.dart' as io;
/// import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
/// import 'join_consume_room.dart';
///
/// final socket = io.io("http://localhost:3000", <String, dynamic>{
///   "transports": ["websocket"],
/// });
///
/// final parameters = JoinConsumeRoomParametersMock(
///   roomName: 'test-room',
///   islevel: '2',
///   member: 'user123',
///   device: null,
///   updateDevice: (device) => print('Device initialized: $device'),
///   receiveAllPipedTransports: (options) async => print('Setting up piped transports'),
///   createDeviceClient: (options) async => Device(),
/// );
///
/// final options = JoinConsumeRoomOptions(
///   remoteSock: socket,
///   apiToken: 'your-api-token',
///   apiUserName: 'test-user',
///   parameters: parameters,
/// );
///
/// try {
///   final response = await joinConsumeRoom(options);
///   print('Successfully joined room with response: $response');
/// } catch (error) {
///   print('Failed to join room: $error');
/// }
/// ```

Future<ResponseJoinRoom> joinConsumeRoom(JoinConsumeRoomOptions options) async {
  // Extract parameters
  final remoteSock = options.remoteSock;
  final apiToken = options.apiToken;
  final apiUserName = options.apiUserName;
  final parameters = options.parameters;

  final String roomName = parameters.roomName;
  final String islevel = parameters.islevel;
  final String member = parameters.member;
  Device? device = parameters.getUpdatedAllParams().device;

  ReceiveAllPipedTransportsType receiveAllPipedTransports =
      parameters.receiveAllPipedTransports;
  CreateDeviceClientType createDeviceClient = parameters.createDeviceClient;

  try {
    // Join the consumption room
    final optionsJoinConRoom = JoinConRoomOptions(
      socket: remoteSock,
      roomName: roomName,
      islevel: islevel,
      member: member,
      sec: apiToken,
      apiUserName: apiUserName,
    );
    final data = await joinConRoom(optionsJoinConRoom);

    if (data.success == true) {
      // Setup media device if it's not already initialized
      if (device == null && data.rtpCapabilities != null) {
        final optionsDevice = CreateDeviceClientOptions(
          rtpCapabilities: data.rtpCapabilities,
        );
        final Device? newDevice =
            await createDeviceClient(options: optionsDevice);

        // Update the device in the parameters
        parameters.updateDevice(newDevice!);
      }

      // Initialize piped transports
      final optionsReceive = ReceiveAllPipedTransportsOptions(
        nsock: remoteSock,
        parameters: parameters,
      );
      await receiveAllPipedTransports(optionsReceive);
    }

    return data;
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - Error in joinConsumeRoom: $error');
    }
    throw Exception(
      'Failed to join the consumption room or set up necessary components.',
    );
  }
}
