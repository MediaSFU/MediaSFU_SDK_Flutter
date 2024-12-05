import 'dart:convert';
import 'package:http/http.dart' as http;
import 'create_join_room.dart';

/// **createRoomOnMediaSFU**
///
/// Sends a request to create a new room on MediaSFU.
///
/// **Parameters:**
/// - `payload`: The payload for the API request.
/// - `apiUserName`: The API username.
/// - `apiKey`: The API key.
///
/// **Returns:**
/// - A [CreateJoinRoomResult] containing the response or error.
Future<CreateJoinRoomResult> createRoomOnMediaSFU({
  required Map<String, dynamic> payload,
  required String apiUserName,
  required String apiKey,
}) async {
  try {
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
    const endpoint = 'https://mediasfu.com/v1/rooms/';

    // Prepare the request
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiUserName:$apiKey",
      },
      body: jsonEncode(payload),
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
