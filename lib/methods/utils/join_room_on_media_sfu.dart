import 'dart:convert';
import 'package:http/http.dart' as http;

import 'create_join_room.dart';
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

typedef JoinRoomOnMediaSFUType = Future<CreateJoinRoomResult> Function(
    JoinMediaSFUOptions options);

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
    JoinMediaSFUOptions options) async {
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
      final data = jsonDecode(response.body);
      return CreateJoinRoomResult(
        data: CreateJoinRoomResponse.fromJson(data),
        success: true,
      );
    } else {
      final errorData = jsonDecode(response.body);
      return CreateJoinRoomResult(
        data: CreateJoinRoomError.fromJson(errorData),
        success: false,
      );
    }
  } catch (error) {
    // Handle unexpected errors
    return CreateJoinRoomResult(
      data: CreateJoinRoomError(error: 'Unknown error'),
      success: false,
    );
  }
}
