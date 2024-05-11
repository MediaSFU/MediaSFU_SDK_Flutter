import 'package:socket_io_client/socket_io_client.dart' as io;

/// Responds to requests by updating the request list and emitting an event to update the user's request status.
///
/// The [parameters] map should contain the following keys:
/// - 'socket': The socket object used for communication.
/// - 'request': The request object to respond to.
/// - 'updateRequestList': A function to update the request list.
/// - 'requestList': The current list of requests.
/// - 'action': The action to perform in response to the request.
/// - 'roomName': The name of the room associated with the request.

void respondToRequests({required Map<String, dynamic> parameters}) {
  final io.Socket socket = parameters['socket'] as io.Socket;
  final Map<String, dynamic> request = parameters['request'];
  final Function(List<dynamic>) updateRequestList =
      parameters['updateRequestList'] as Function(List<dynamic>);
  final List<dynamic> requestList = parameters['requestList'] as List<dynamic>;
  final String action = parameters['action'] as String;
  final String roomName = parameters['roomName'] as String;

  // Perform your logic here to determine which buttons to show/hide based on the state variables

  List<dynamic> newRequestList = requestList.where((request_) {
    return !(request_['id'] == request['id'] &&
        request_['icon'] == request['icon'] &&
        request_['name'] == request['name']);
  }).toList();

  updateRequestList(newRequestList);

  Map<String, dynamic> requestResponse = {
    'id': request['id'],
    'name': request['name'],
    'type': request['icon'],
    'action': action,
  };

  socket.emit('updateUserofRequestStatus', {
    'requestResponse': requestResponse,
    'roomName': roomName,
  });
}
