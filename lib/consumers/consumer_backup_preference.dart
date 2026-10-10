import 'package:socket_io_client/socket_io_client.dart' as io;

/// Consumer backup preference (server feature consumer-backup-v1).
///
/// When a consuming node gets busy, the server attaches a backup node and sends every listener
/// `alt_domains: { <busy node>: <backup node> }`. Streams already received stay on the busy node, but a stream
/// announced after that is taken from the backup: when the busy node announces it and the backup is connected, the
/// client waits briefly for the backup's own announcement (the backup gets each new stream a moment later) and falls
/// back to the busy node if it does not come. Consumption is de-duplicated by producer id, so the first one wins.
///
/// The request is never sent to the backup for a stream the backup has not announced: a consume the backup cannot
/// serve fails without an error and the de-duplication would then skip the busy node's copy (staging test, Oct 9 2026).
class MediasfuConsumerBackups {
  MediasfuConsumerBackups._();

  /// How long a busy node's announcement waits for the backup's.
  static Duration preferDelay = const Duration(milliseconds: 1500);

  static final Map<String, String> _backupByParent = <String, String>{};

  /// Records the server's `{ busy node: backup node }` map.
  static void remember(Map<String, String>? altDomains) {
    altDomains?.forEach((parent, backup) {
      if (parent.isNotEmpty && backup.isNotEmpty && parent != backup) _backupByParent[parent] = backup;
    });
  }

  static void forgetAll() => _backupByParent.clear();

  /// The connected backup to prefer over [ip], or null.
  static String? preferredBackup(String ip, List<Map<String, io.Socket>>? consumeSockets) {
    final backup = _backupByParent[ip];
    if (backup == null) return null;
    final connected = (consumeSockets ?? const []).any((entry) => entry[backup]?.connected == true);
    return connected ? backup : null;
  }

  /// Delay before consuming a stream announced by [ip]: non-zero only when a connected backup should win.
  static Duration delayFor(String ip, List<Map<String, io.Socket>>? consumeSockets) =>
      preferredBackup(ip, consumeSockets) != null ? preferDelay : Duration.zero;
}
