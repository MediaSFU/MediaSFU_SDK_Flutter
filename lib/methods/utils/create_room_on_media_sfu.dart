import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../types/types.dart' show CreateMediaSFURoomOptions;
import 'create_join_room.dart';

class CreateMediaSFUOptions {
  CreateMediaSFURoomOptions payload;
  String apiUserName;
  String apiKey;
  String localLink;

  CreateMediaSFUOptions({
    required this.payload,
    required this.apiUserName,
    required this.apiKey,
    this.localLink = "",
  });
}

typedef CreateRoomOnMediaSFUType = Future<CreateJoinRoomResult> Function(
    CreateMediaSFUOptions options);

/// **createRoomOnMediaSFU**
///
/// Sends a request to create a new room on MediaSFU. This function validates
/// the provided credentials and dynamically determines the endpoint based on
/// the `localLink`. It performs an HTTP POST request with the given payload
/// and returns the response or an error.
///
/// **Parameters:**
/// - `payload` (`CreateMediaSFURoomOptions`): The payload containing room creation details.
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
/// final payload = CreateMediaSFURoomOptions(
///   roomName: "testRoom123",
///   description: "A test room for MediaSFU",
///   maxParticipants: 10,
/// );
///
/// final result = await createRoomOnMediaSFU(
///  CreateMediaSFUOptions(
///   payload: payload,
///   apiUserName: "apiUser123",
///   apiKey: "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
///   localLink: "https://custom.localserver.com",
/// );
/// );
///
/// if (result.success) {
///   print('Room created successfully: ${result.data}');
/// } else {
///   print('Failed to create room: ${result.data.error}');
/// }
/// ```

Future<CreateJoinRoomResult> createRoomOnMediaSFU(
  CreateMediaSFUOptions options,
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
    String endpoint = 'https://mediasfu.com/v1/rooms';

    if (localLink.isNotEmpty &&
        !localLink.contains('mediasfu.com') &&
        localLink.length > 1) {
      localLink = localLink.replaceAll(RegExp(r'/$'), '');
      endpoint = '$localLink/createRoom';
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
