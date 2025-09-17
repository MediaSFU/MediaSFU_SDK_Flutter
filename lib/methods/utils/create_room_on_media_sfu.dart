import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
/// and returns the response or an error. Includes rate limiting to prevent
/// duplicate requests within a 30-second window.
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
///   action: 'create',
///   duration: 60,
///   capacity: 10,
///   userName: 'hostUser',
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

    // Build a unique identifier for this create request
    final String roomIdentifier =
        'create_${payload.userName}_${payload.duration}_${payload.capacity}';
    final String pendingKey = 'mediasfu_pending_$roomIdentifier';
    const int pendingTimeout = 30 * 1000; // 30 seconds in milliseconds

    // Check pending status to prevent duplicate requests
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? pendingRequest = prefs.getString(pendingKey);

      if (pendingRequest != null) {
        final Map<String, dynamic> pendingData = jsonDecode(pendingRequest);
        final int timeSincePending = DateTime.now().millisecondsSinceEpoch -
            ((pendingData['timestamp'] as num?)?.toInt() ?? 0);

        if (timeSincePending < pendingTimeout) {
          return CreateJoinRoomResult(
            data:
                CreateJoinRoomError(error: 'Room creation already in progress'),
            success: false,
          );
        } else {
          // Stale lock, clear it
          await prefs.remove(pendingKey);
        }
      }
    } catch (e) {
      // Ignore SharedPreferences read/JSON errors
    }

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

    // Mark request as pending
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> pendingData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'payload': {
          'action': 'create',
          'userName': payload.userName,
          'duration': payload.duration,
          'capacity': payload.capacity,
        },
      };

      await prefs.setString(pendingKey, jsonEncode(pendingData));

      // Auto-clear the pending flag after timeout to avoid stale locks
      Future.delayed(Duration(milliseconds: pendingTimeout), () async {
        try {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove(pendingKey);
        } catch (e) {
          // Ignore errors
        }
      });
    } catch (e) {
      // Ignore SharedPreferences write errors
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

      // Clear pending status on success
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove(pendingKey);
      } catch (e) {
        // Ignore errors
      }

      return CreateJoinRoomResult(
        data: CreateJoinRoomResponse.fromJson(data),
        success: true,
      );
    } else {
      final errorData = jsonDecode(response.body);

      // Clear pending status on error
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove(pendingKey);
      } catch (e) {
        // Ignore errors
      }

      return CreateJoinRoomResult(
        data: CreateJoinRoomError.fromJson(errorData),
        success: false,
      );
    }
  } catch (error) {
    // Clear pending status on error
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String roomIdentifier =
          'create_${options.payload.userName}_${options.payload.duration}_${options.payload.capacity}';
      await prefs.remove('mediasfu_pending_$roomIdentifier');
    } catch (e) {
      // Ignore errors
    }

    // Handle unexpected errors
    return CreateJoinRoomResult(
      data: CreateJoinRoomError(
          error: 'Unable to create room, ${error.toString()}'),
      success: false,
    );
  }
}
