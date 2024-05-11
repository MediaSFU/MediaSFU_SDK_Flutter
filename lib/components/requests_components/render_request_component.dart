import 'package:flutter/material.dart';

/// RenderRequestComponent is a StatelessWidget that renders a single request item.
///
/// `request`: The details of the request item.
/// `onRequestItemPress`: Callback function to respond to the request item press.
/// `requestList`: The list of requests.
/// `updateRequestList`: Function to update the request list.
/// `roomName`: The name of the room.
/// `socket`: The socket for communication.

typedef RespondToRequests = void Function(
    {required Map<String, dynamic> parameters});

class RenderRequestComponent extends StatelessWidget {
  final Map<String, dynamic> request;
  final RespondToRequests onRequestItemPress;
  final List<dynamic> requestList;
  final Function(List<dynamic>) updateRequestList;
  final String roomName;
  final dynamic socket;

  const RenderRequestComponent({
    super.key,
    required this.request,
    required this.onRequestItemPress,
    required this.requestList,
    required this.updateRequestList,
    required this.roomName,
    required this.socket,
  });

  void handleRequestAction(String action) {
    onRequestItemPress(
      parameters: {
        'request': request,
        'updateRequestList': updateRequestList,
        'requestList': requestList,
        'action': action,
        'roomName': roomName,
        'socket': socket,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(request['name']),
        ),
        Expanded(
          flex: 2,
          child: Icon(
            _getIconData(request['icon']),
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
        return Icons.error; // or any other default icon
    }
  }
}
