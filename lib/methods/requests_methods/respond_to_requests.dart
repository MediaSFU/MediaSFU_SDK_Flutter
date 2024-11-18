import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart' show Request;

/// Defines the options for responding to requests.
class RespondToRequestsOptions {
  final io.Socket? socket;
  final Request request;
  final Function(List<Request>) updateRequestList;
  final List<Request> requestList;
  final String action;
  final String roomName;

  RespondToRequestsOptions({
    this.socket,
    required this.request,
    required this.updateRequestList,
    required this.requestList,
    required this.action,
    required this.roomName,
  });
}

/// Type definition for the respondToRequests function.
typedef RespondToRequestsType = Future<void> Function(
    RespondToRequestsOptions options);

/// Responds to incoming requests by updating the request list locally and notifying the server of the request status.
/// This function is typically used to manage permissions or participation requests in real-time collaboration tools.
///
/// ### Parameters:
/// - [options] (`RespondToRequestsOptions`): Contains the following:
///   - `socket`: An instance of the socket connection used to communicate with the server.
///   - `request`: The request to respond to, containing fields like `id`, `name`, and `icon`.
///   - `updateRequestList`: A callback function to update the list of pending requests.
///   - `requestList`: The current list of requests.
///   - `action`: The action to perform in response to the request (e.g., "accept" or "reject").
///   - `roomName`: The name of the room in which the response should be processed.
///
/// ### Example:
/// ```dart
/// respondToRequests(
///   RespondToRequestsOptions(
///     socket: socket,
///     request: Request(id: '123', name: 'John Doe', icon: 'fa-microphone'),
///     updateRequestList: (newList) => setState(() => requests = newList),
///     requestList: requests,
///     action: 'accept',
///     roomName: 'conferenceRoom',
///   ),
/// );
/// ```
///
/// ### Workflow:
/// 1. Filters out the specified `request` from `requestList`.
/// 2. Updates the list of requests locally using `updateRequestList`.
/// 3. Sends the response to the server by emitting `updateUserofRequestStatus`.
///
/// This ensures both the local UI and the server stay in sync regarding the request’s status.

Future<void> respondToRequests(RespondToRequestsOptions options) async {
  // Filter out the request from the request list
  List<Request> newRequestList = options.requestList.where((request_) {
    return !(request_['id'] == options.request['id'] &&
        request_['icon'] == options.request['icon'] &&
        request_['name'] == options.request['name']);
  }).toList();

  // Update the request list with the filtered list
  options.updateRequestList(newRequestList);

  // Prepare the request response
  Map<String, dynamic> requestResponse = {
    'id': options.request['id'],
    'name': options.request['name'],
    'type': options.request['icon'],
    'action': options.action,
  };

  // Emit the request response to the server
  options.socket!.emit('updateUserofRequestStatus', {
    'requestResponse': requestResponse,
    'roomName': options.roomName,
  });
}
