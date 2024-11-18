import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/requests_methods/respond_to_requests.dart'
    show respondToRequests, RespondToRequestsType, RespondToRequestsOptions;
import '../../types/types.dart' show Request;

/// Options for configuring the `RenderRequestComponent`.
class RenderRequestComponentOptions {
  final Request request;
  final RespondToRequestsType onRequestItemPress;
  final List<Request> requestList;
  final void Function(List<Request>) updateRequestList;
  final String roomName;
  final io.Socket? socket;

  RenderRequestComponentOptions({
    required this.request,
    this.onRequestItemPress = respondToRequests,
    required this.requestList,
    required this.updateRequestList,
    required this.roomName,
    this.socket,
  });
}

typedef RenderRequestComponentType = Widget Function(
    {required RenderRequestComponentOptions options});

/// `RenderRequestComponent` is a stateless widget that renders a request item with options
/// to accept or reject the request. The component displays the request name, a relevant icon,
/// and two action buttons, allowing users to respond to requests in real time.
///
/// ### Parameters:
/// - [options] (`RenderRequestComponentOptions`): Contains the following:
///   - `request`: The request data, including `name` and `icon`.
///   - `onRequestItemPress`: A function to handle pressing accept or reject actions. Defaults to `respondToRequests`.
///   - `requestList`: The current list of requests to manage state.
///   - `updateRequestList`: A function to update the request list state in the parent.
///   - `roomName`: The room identifier.
///   - `socket`: The socket instance for emitting responses.
///
/// ### Example:
/// ```dart
/// RenderRequestComponent(
///   options: RenderRequestComponentOptions(
///     request: Request(id: '1', name: 'John Doe', icon: 'fa-microphone'),
///     requestList: requests,
///     updateRequestList: (newList) => setState(() => requests = newList),
///     roomName: 'MainRoom',
///     socket: socket,
///   ),
/// );
/// ```
///
/// ### Workflow:
/// 1. `handleRequestAction` processes either 'accepted' or 'rejected' actions using the provided `onRequestItemPress`.
/// 2. `_getIconData` matches icon strings like `fa-microphone` to relevant `Icons`.
/// 3. Displays request name, icon, and buttons for accepting or rejecting the request.

class RenderRequestComponent extends StatelessWidget {
  final RenderRequestComponentOptions options;

  const RenderRequestComponent({super.key, required this.options});

  void handleRequestAction(String action) {
    options.onRequestItemPress(
      RespondToRequestsOptions(
        request: options.request,
        updateRequestList: options.updateRequestList,
        requestList: options.requestList,
        action: action,
        roomName: options.roomName,
        socket: options.socket,
      ),
    );
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'fa-microphone':
        return Icons.mic;
      case 'fa-desktop':
        return Icons.desktop_windows;
      case 'fa-video':
        return Icons.videocam;
      case 'fa-comments':
        return Icons.comment;
      default:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(options.request.name!),
        ),
        Expanded(
          flex: 2,
          child: Icon(
            _getIconData(options.request.icon),
            size: 24,
            color: Colors.black,
          ),
        ),
        Expanded(
          flex: 2,
          child: IconButton(
            onPressed: () => handleRequestAction('accepted'),
            icon: const Icon(
              Icons.check,
              size: 24,
              color: Colors.green,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: IconButton(
            onPressed: () => handleRequestAction('rejected'),
            icon: const Icon(
              Icons.close,
              size: 24,
              color: Colors.red,
            ),
          ),
        ),
        const Expanded(flex: 1, child: SizedBox()), // Spacer
      ],
    );
  }
}
