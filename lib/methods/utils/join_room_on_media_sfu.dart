import 'create_join_room.dart';
import 'create_room_on_media_sfu.dart';

/// **joinRoomOnMediaSFU**
///
/// Sends a request to join an existing room on MediaSFU.
///
/// **Parameters:**
/// - `payload`: The payload for the API request.
/// - `apiUserName`: The API username.
/// - `apiKey`: The API key.
///
/// **Returns:**
/// - A [CreateJoinRoomResult] containing the response or error.
Future<CreateJoinRoomResult> joinRoomOnMediaSFU({
  required Map<String, dynamic> payload,
  required String apiUserName,
  required String apiKey,
}) async {
  // Reuse the createRoomOnMediaSFU function for joining
  return await createRoomOnMediaSFU(
    payload: payload,
    apiUserName: apiUserName,
    apiKey: apiKey,
  );
}
