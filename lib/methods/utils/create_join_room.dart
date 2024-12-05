/// **CreateJoinRoomResponse**
///
/// Represents the successful response from creating or joining a room.
class CreateJoinRoomResponse {
  final String message;
  final String roomName;
  final String? secureCode;
  final String publicURL;
  final String link;
  final String secret;
  final bool success;

  CreateJoinRoomResponse({
    required this.message,
    required this.roomName,
    this.secureCode,
    required this.publicURL,
    required this.link,
    required this.secret,
    required this.success,
  });

  factory CreateJoinRoomResponse.fromJson(Map<String, dynamic> json) {
    return CreateJoinRoomResponse(
      message: json['message'],
      roomName: json['roomName'],
      secureCode: json['secureCode'],
      publicURL: json['publicURL'],
      link: json['link'],
      secret: json['secret'],
      success: json['success'],
    );
  }
}

/// **CreateJoinRoomError**
///
/// Represents the error response from creating or joining a room.
class CreateJoinRoomError {
  final String error;
  final bool? success;

  CreateJoinRoomError({
    required this.error,
    this.success,
  });

  factory CreateJoinRoomError.fromJson(Map<String, dynamic> json) {
    return CreateJoinRoomError(
      error: json['error'],
      success: json['success'],
    );
  }
}

/// **CreateJoinRoomResult**
///
/// Represents the result of creating or joining a room.
/// Contains either a [CreateJoinRoomResponse], [CreateJoinRoomError], or `null`.
class CreateJoinRoomResult {
  final dynamic
      data; // Can be CreateJoinRoomResponse, CreateJoinRoomError, or null
  final bool success;

  CreateJoinRoomResult({
    this.data,
    required this.success,
  });
}

typedef CreateJoinRoomType = Future<CreateJoinRoomResult> Function({
  required Map<String, dynamic> payload,
  required String apiUserName,
  required String apiKey,
});
