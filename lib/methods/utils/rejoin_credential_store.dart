import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Memory of the room credential this app last received for a room and name, so a reload or app restart can rejoin
/// as the same participant.
///
/// MediaSFU keeps a participant's 3 most recent room credentials valid (servers with participant-rejoin-v1). When the
/// SDK registers again it sends the stored credential as `rejoinSecret`, which lets the server re-admit the same
/// participant even while the old connection is still registered. If the server still refuses the name, the stored
/// credential itself is reused. Entries expire after 24 hours. Storage failures are ignored (a fresh registration
/// still works).
class StoredRejoinCredential {
  final String roomName;
  final String userName;
  final String secret;
  final String link;
  final String publicURL;
  final int storedAt;

  StoredRejoinCredential({
    required this.roomName,
    required this.userName,
    required this.secret,
    this.link = '',
    this.publicURL = '',
    required this.storedAt,
  });

  Map<String, dynamic> toJson() => {
        'roomName': roomName,
        'userName': userName,
        'secret': secret,
        'link': link,
        'publicURL': publicURL,
        'storedAt': storedAt,
      };

  static StoredRejoinCredential? fromJson(Map<String, dynamic> json) {
    final secret = json['secret'];
    if (secret is! String || secret.isEmpty) return null;
    return StoredRejoinCredential(
      roomName: (json['roomName'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      secret: secret,
      link: (json['link'] ?? '').toString(),
      publicURL: (json['publicURL'] ?? '').toString(),
      storedAt: json['storedAt'] is int ? json['storedAt'] as int : 0,
    );
  }
}

const String _prefix = 'mediasfu:rejoin:';
const int _maxAgeMs = 24 * 60 * 60 * 1000;
final RegExp _secretPattern = RegExp(r'^[a-fA-F0-9]{64}$');

String _keyFor(String roomName, String userName) =>
    '$_prefix${roomName.trim().toLowerCase()}:${userName.trim().toLowerCase()}';

/// Remembers the credential returned by a successful create or join.
Future<void> rememberRejoinCredential({
  required String roomName,
  required String userName,
  required String secret,
  String link = '',
  String publicURL = '',
}) async {
  if (roomName.isEmpty || userName.isEmpty || !_secretPattern.hasMatch(secret)) return;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyFor(roomName, userName),
      jsonEncode(StoredRejoinCredential(
        roomName: roomName,
        userName: userName,
        secret: secret,
        link: link,
        publicURL: publicURL,
        storedAt: DateTime.now().millisecondsSinceEpoch,
      ).toJson()),
    );
  } catch (_) {}
}

/// The stored credential for this room and name, or null (none, expired or unreadable).
Future<StoredRejoinCredential?> readRejoinCredential(String roomName, String userName) async {
  if (roomName.isEmpty || userName.isEmpty) return null;
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(roomName, userName));
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    final value = decoded is Map<String, dynamic> ? StoredRejoinCredential.fromJson(decoded) : null;
    if (value == null || DateTime.now().millisecondsSinceEpoch - value.storedAt > _maxAgeMs) {
      await prefs.remove(_keyFor(roomName, userName));
      return null;
    }
    return value;
  } catch (_) {
    return null;
  }
}

/// Forgets the stored credential (for example after leaving on purpose).
Future<void> forgetRejoinCredential(String roomName, String userName) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(roomName, userName));
  } catch (_) {}
}
