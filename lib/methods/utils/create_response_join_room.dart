import '../../types/types.dart' show ResponseJoinLocalRoom, ResponseJoinRoom;

/// Represents the options for creating a ResponseJoinRoom.
class CreateResponseJoinRoomOptions {
  final ResponseJoinLocalRoom localRoom;

  CreateResponseJoinRoomOptions({required this.localRoom});
}

/// Type definition for the function that creates a ResponseJoinRoom.
typedef CreateResponseJoinRoomType = Future<ResponseJoinRoom> Function(
    CreateResponseJoinRoomOptions options);

/// Creates a ResponseJoinRoom object from a ResponseJoinLocalRoom object.
///
/// This function takes a [CreateResponseJoinRoomOptions] containing the
/// [ResponseJoinLocalRoom] object and returns a [Future<ResponseJoinRoom>].
///
/// Example:
/// ```dart
/// final localRoom = ResponseJoinLocalRoom(
///   rtpCapabilities: null,
///   isHost: true,
///   eventStarted: false,
///   isBanned: false,
///   hostNotJoined: false,
///   eventRoomParams: MeetingRoomParams(...),
///   recordingParams: RecordingParams(...),
///   secureCode: "12345",
///   mediasfuURL: "https://example.com",
///   apiKey: "api-key",
///   apiUserName: "user-name",
///   allowRecord: true,
/// );
///
/// final joinRoom = await createResponseJoinRoom(
///   CreateResponseJoinRoomOptions(localRoom: localRoom),
/// );
/// print(joinRoom);
/// ```
Future<ResponseJoinRoom> createResponseJoinRoom(
    CreateResponseJoinRoomOptions options) async {
  final localRoom = options.localRoom;

  return ResponseJoinRoom(
    rtpCapabilities: localRoom.rtpCapabilities,
    success: localRoom.rtpCapabilities != null,
    roomRecvIPs: [], // Placeholder; populate with necessary values
    meetingRoomParams: localRoom.eventRoomParams,
    recordingParams: localRoom.recordingParams,
    secureCode: localRoom.secureCode,
    recordOnly: false, // Default assumption unless additional logic applies
    isHost: localRoom.isHost,
    safeRoom: false, // Default assumption unless additional logic applies
    autoStartSafeRoom:
        false, // Default assumption unless additional logic applies
    safeRoomStarted:
        false, // Default assumption unless additional logic applies
    safeRoomEnded: false, // Default assumption unless additional logic applies
    reason: localRoom.isBanned! ? "User is banned from the room." : null,
    banned: localRoom.isBanned,
    suspended: false, // Default assumption unless additional logic applies
    noAdmin: localRoom.hostNotJoined,
  );
}
