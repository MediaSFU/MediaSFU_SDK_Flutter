import 'dart:convert';
import 'package:http/http.dart' as http;

import 'create_join_room.dart';
import 'media_sfu_http_response.dart';
import 'rejoin_credential_store.dart';
import 'wait_for_room_admission.dart';
import '../../types/types.dart' show JoinMediaSFURoomOptions;

class JoinMediaSFUOptions {
  JoinMediaSFURoomOptions payload;
  String apiUserName;
  String apiKey;
  String localLink;

  JoinMediaSFUOptions({
    required this.payload,
    required this.apiUserName,
    required this.apiKey,
    this.localLink = "",
  });
}

typedef JoinRoomOnMediaSFUType =
    Future<CreateJoinRoomResult> Function(JoinMediaSFUOptions options);

/// **joinRoomOnMediaSFU**
///
/// Sends a request to join an existing room on MediaSFU. This function validates
/// the provided credentials and dynamically determines the endpoint based on the
/// `localLink`. It performs an HTTP POST request with the provided payload and
/// returns the response or an error.
///
/// **Parameters:**
/// - `payload` (`JoinMediaSFURoomOptions`): The payload containing room join details.
/// - `apiUserName` (`String`): The API username used for authentication.
/// - `apiKey` (`String`): The API key for authentication (must be exactly 64 characters).
/// - `localLink` (`String`, optional): A local link for community edition servers. If provided,
///    it replaces the default MediaSFU endpoint.
///
/// **Returns:**
/// - A `Future<CreateJoinRoomResult>` containing:
///    - `success` (`bool`): Indicates whether the request was successful.
///    - `data` (`CreateJoinRoomResponse` | `CreateJoinRoomError`): The response data or error details.
///
/// **Example Usage:**
/// ```dart
/// final payload = JoinMediaSFURoomOptions(
///   action: "join",
///   meetingID: "testRoom123",
///   userName: "user123",
/// );
///
/// final result = await joinRoomOnMediaSFU(
///   JoinMediaSFUOptions(
///   payload: payload,
///   apiUserName: "apiUser123",
///   apiKey: "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
///   localLink: "https://custom.localserver.com",
///  ),
/// );
///
/// if (result.success) {
///   print('Successfully joined room: ${result.data}');
/// } else {
///   print('Failed to join room: ${result.data.error}');
/// }
/// ```

Future<CreateJoinRoomResult> joinRoomOnMediaSFU(
  JoinMediaSFUOptions options,
) async {
  try {
    // Extract options
    final payload = options.payload;
    String apiUserName = options.apiUserName;
    String apiKey = options.apiKey;
    String localLink = options.localLink;

    // Validate credentials
    if (apiUserName.isEmpty ||
        apiKey.isEmpty ||
        apiUserName == "yourAPIUSERNAME" ||
        apiKey == "yourAPIKEY" ||
        apiKey.length != 64 ||
        apiUserName.length < 6) {
      return CreateJoinRoomResult(
        data: CreateJoinRoomError(error: "Invalid credentials"),
        success: false,
      );
    }

    // Choose the appropriate endpoint
    String endpoint = 'https://mediasfu.com/v1/rooms/';

    if (localLink.isNotEmpty &&
        !localLink.contains('mediasfu.com') &&
        localLink.length > 1) {
      localLink = localLink.replaceAll(RegExp(r'/$'), '');
      endpoint = '$localLink/joinRoom';
    }

    Map<String, dynamic> payloadJson = payload.toMap();
    // participant-rejoin-v1: prove this app is the same participant with the credential it last received for this room and name.
    final stored = await readRejoinCredential(payload.meetingID, payload.userName);
    if (stored != null && payloadJson['rejoinSecret'] == null) {
      payloadJson['rejoinSecret'] = stored.secret;
    }

    // Prepare the request
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiUserName:$apiKey",
      },
      body: jsonEncode(payloadJson),
    );

    // Handle response
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = decodeMediaSfuJsonObject(response.body);
      if (data == null) {
        return CreateJoinRoomResult(
          data: CreateJoinRoomError(
            error: mediaSfuResponseError(response, action: 'join the room'),
          ),
          success: false,
        );
      }
      // wait-room-api-v1: the room has a waiting room; wait here until the host decides, then continue the normal join.
      if (data['waiting'] == true && data['secret'] is String) {
        final admission = await waitForRoomAdmission(
          roomName: (data['roomName'] ?? payload.meetingID).toString(),
          userName: (data['userName'] ?? payload.userName).toString(),
          secret: data['secret'] as String,
          apiUserName: apiUserName,
          apiKey: apiKey,
          endpoint: endpoint,
        );
        if (admission.status != WaitingRoomStatus.admitted || admission.link == null) {
          return CreateJoinRoomResult(
            data: CreateJoinRoomError(error: admission.error ?? waitingRoomDeclinedMessage),
            success: false,
          );
        }
        data['roomName'] = admission.roomName;
        data['secret'] = admission.secret;
        data['link'] = admission.link;
        data['publicURL'] = admission.publicURL ?? '';
        data['message'] = 'Room joined successfully';
        data['success'] = true;
      }
      final joined = CreateJoinRoomResponse.fromJson(data);
      await rememberRejoinCredential(
        roomName: joined.roomName,
        userName: payload.userName,
        secret: joined.secret,
        link: joined.link,
        publicURL: joined.publicURL,
      );
      return CreateJoinRoomResult(
        data: joined,
        success: true,
      );
    } else {
      final errorData = decodeMediaSfuJsonObject(response.body);
      // participant-rejoin-v1: the server still refuses the name (an older server, or the proof was not accepted). The stored
      // credential stays valid for the same participant, so reuse it; a revoked one is refused when connecting.
      if (stored != null &&
          RegExp('already taken', caseSensitive: false).hasMatch((errorData?['error'] ?? '').toString())) {
        return CreateJoinRoomResult(
          data: CreateJoinRoomResponse(
            message: 'Room joined successfully',
            roomName: stored.roomName,
            publicURL: stored.publicURL.isNotEmpty ? stored.publicURL : stored.link,
            link: stored.link,
            secret: stored.secret,
            success: true,
          ),
          success: true,
        );
      }
      return CreateJoinRoomResult(
        data: errorData != null
            ? CreateJoinRoomError.fromJson(errorData)
            : CreateJoinRoomError(
                error: mediaSfuResponseError(
                  response,
                  action: 'join the room',
                ),
              ),
        success: false,
      );
    }
  } catch (error) {
    return CreateJoinRoomResult(
      data: CreateJoinRoomError(
        error: mediaSfuConnectionError(error, action: 'join the room'),
      ),
      success: false,
    );
  }
}
