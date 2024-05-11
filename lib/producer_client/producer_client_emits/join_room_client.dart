import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../producers/producer_emits/join_room.dart' show joinRoom;
import '../../producers/producer_emits/join_con_room.dart' show joinConRoom;

Future<Map<String, dynamic>> joinRoomClient({
  required io.Socket socket,
  required String roomName,
  required String islevel,
  required String member,
  required String sec,
  required String apiUserName,
  bool consume = false,
}) async {
  try {
    // Emit the joinRoom event to the server using the provided socket
    Map<String, dynamic> data = {};

    if (consume) {
      // Assuming `joinConRoom` and `joinRoom` functions are defined elsewhere

      data = await joinConRoom(
          socket, roomName, islevel, member, sec, apiUserName);
    } else {
      data =
          await joinRoom(socket, roomName, islevel, member, sec, apiUserName);
    }

    return data;
  } catch (error) {
    // Handle and log errors during the joinRoom process
    if (kDebugMode) {
      print('Error joining room: $error');
    }
    throw ('Failed to join the room. Please check your connection and try again.');
  }
}
