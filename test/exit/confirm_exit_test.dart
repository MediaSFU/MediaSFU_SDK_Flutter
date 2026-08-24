import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_sdk/methods/exit_methods/confirm_exit.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

void main() {
  test('host exit defaults to ending and can explicitly keep the room active',
      () async {
    final socket = io.io(
      'http://127.0.0.1',
      io.OptionBuilder().disableAutoConnect().build(),
    );

    await confirmExit(ConfirmExitOptions(
      socket: socket,
      member: 'host',
      roomName: 'room',
    ));
    await confirmExit(ConfirmExitOptions(
      socket: socket,
      member: 'host',
      roomName: 'room',
      endRoomOnHostExit: false,
    ));

    final firstPayload = socket.sendBuffer[0]['data'][1] as Map;
    final secondPayload = socket.sendBuffer[1]['data'][1] as Map;
    expect(firstPayload['endRoomOnHostExit'], isTrue);
    expect(secondPayload['endRoomOnHostExit'], isFalse);
    socket.dispose();
  });
}
