import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/requests_methods/respond_to_requests.dart'
    show respondToRequests, RespondToRequestsType, RespondToRequestsOptions;
import '../../types/types.dart' show Request;

/// Configuration options for [RenderRequestComponent].
///
/// Encapsulates individual request data and response handling for a single
/// participant's permission request (microphone, video, screenshare, chat).
///
/// **Properties:**
/// - `request` ([Request]): Request object containing:
///   - `id`: Unique request identifier
///   - `name`: Participant name (e.g., "John Doe")
///   - `icon`: FontAwesome icon name (e.g., "fa-microphone", "fa-video", "fa-desktop", "fa-comments")
/// - `onRequestItemPress` ([RespondToRequestsType]): Response handler function (defaults to [respondToRequests])
/// - `requestList` (List<[Request]>): Current list of all pending requests for state management
/// - `updateRequestList` (Function(List<[Request]>)): Callback to update request list after accept/reject
/// - `roomName` (String): Room identifier for socket event targeting
/// - `socket` ([io.Socket]?): Socket.IO client instance for emitting "updateRequests" events
///
/// **Socket Events Emitted (via respondToRequests):**
/// - **"updateRequests"**: Sends accepted/rejected response to server
///   ```dart
///   socket.emit('updateRequests', {
///     'action': 'accepted', // or 'rejected'
///     'requestId': request.id,
///     'roomName': roomName,
///   });
///   ```
///
/// **Example:**
/// ```dart
/// RenderRequestComponentOptions(
///   request: Request(
///     id: 'req123',
///     name: 'Alice Johnson',
///     icon: 'fa-microphone',
///   ),
///   requestList: currentRequests,
///   updateRequestList: (newList) {
///     setState(() {
///       requestListState = newList;
///     });
///   },
///   roomName: parameters.roomName,
///   socket: parameters.socket,
///   onRequestItemPress: respondToRequests, // default handler
/// )
/// ```
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

/// A stateless widget rendering a single participant permission request item.
///
/// Displays participant name, request type icon, and accept/reject action buttons.
/// Handles real-time request responses via socket events and local state updates.
///
/// **Rendering Structure:**
/// ```
/// Row
///   ├─ Expanded (flex: 5) - Participant Name
///   │  └─ Text (request.name)
///   ├─ Expanded (flex: 2) - Request Type Icon
///   │  └─ Icon (24px, _getIconData(request.icon))
///   ├─ Expanded (flex: 2) - Accept Button
///   │  └─ IconButton
///   │     ├─ icon: Icons.check (green, 24px)
///   │     └─ onPressed: handleRequestAction('accepted')
///   ├─ Expanded (flex: 2) - Reject Button
///   │  └─ IconButton
///   │     ├─ icon: Icons.close (red, 24px)
///   │     └─ onPressed: handleRequestAction('rejected')
///   └─ Expanded (flex: 1) - Spacer
/// ```
///
/// **Icon Mapping (_getIconData):**
/// - `"fa-microphone"` → `Icons.mic` (audio request)
/// - `"fa-desktop"` → `Icons.desktop_windows` (screenshare request)
/// - `"fa-video"` → `Icons.videocam` (video request)
/// - `"fa-comments"` → `Icons.comment` (chat request)
/// - Default: `Icons.error` (unknown request type)
///
/// **Request Flow:**
/// 1. User clicks accept (✓) or reject (✕) button
/// 2. `handleRequestAction('accepted'|'rejected')` invoked
/// 3. Calls `onRequestItemPress(RespondToRequestsOptions(...))`
/// 4. Default handler `respondToRequests`:
///    - Emits socket event: `socket.emit('updateRequests', {action, requestId, roomName})`
///    - Removes request from local `requestList`
///    - Invokes `updateRequestList(filteredList)` to update parent state
/// 5. RequestsModal re-renders with updated list
///
/// **Common Use Cases:**
/// 1. **Microphone Request:**
///    ```dart
///    RenderRequestComponent(
///      options: RenderRequestComponentOptions(
///        request: Request(
///          id: 'mic_req_001',
///          name: 'Bob Smith',
///          icon: 'fa-microphone',
///        ),
///        requestList: allRequests,
///        updateRequestList: (newList) => setState(() => requests = newList),
///        roomName: parameters.roomName,
///        socket: parameters.socket,
///      ),
///    )
///    // Shows: "Bob Smith" | 🎤 | ✓ | ✕
///    ```
///
/// 2. **Screenshare Request:**
///    ```dart
///    RenderRequestComponent(
///      options: RenderRequestComponentOptions(
///        request: Request(
///          id: 'screen_req_002',
///          name: 'Carol Davis',
///          icon: 'fa-desktop',
///        ),
///        requestList: pendingRequests,
///        updateRequestList: (list) {
///          setState(() {
///            pendingRequests = list;
///            parameters.updateRequestList(list);
///          });
///        },
///        roomName: 'webinar-room-123',
///        socket: socketClient,
///      ),
///    )
///    // Shows: "Carol Davis" | 🖥️ | ✓ | ✕
///    ```
///
/// 3. **Video Request (Custom Handler):**
///    ```dart
///    RenderRequestComponent(
///      options: RenderRequestComponentOptions(
///        request: Request(
///          id: 'video_req_003',
///          name: 'David Lee',
///          icon: 'fa-video',
///        ),
///        requestList: requestQueue,
///        updateRequestList: (list) => updateQueue(list),
///        roomName: conferenceRoomName,
///        socket: conferenceSocket,
///        onRequestItemPress: (options) {
///          // Custom approval logic
///          if (options.action == 'accepted') {
///            logApproval(options.request);
///            showNotification('${options.request.name} video approved');
///          } else {
///            logRejection(options.request);
///          }
///          // Emit socket event
///          respondToRequests(options);
///        },
///      ),
///    )
///    // Shows: "David Lee" | 📹 | ✓ | ✕
///    // Adds custom logging and notifications before standard socket emit
///    ```
///
/// 4. **Chat Request:**
///    ```dart
///    RenderRequestComponent(
///      options: RenderRequestComponentOptions(
///        request: Request(
///          id: 'chat_req_004',
///          name: 'Eva Martinez',
///          icon: 'fa-comments',
///        ),
///        requestList: chatRequests,
///        updateRequestList: (list) => setState(() => chatRequests = list),
///        roomName: 'webinar-chat',
///        socket: chatSocket,
///      ),
///    )
///    // Shows: "Eva Martinez" | 💬 | ✓ | ✕
///    ```
///
/// **Action Handling:**
/// - **Accept (✓):** Calls `handleRequestAction('accepted')`
///   - Emits: `socket.emit('updateRequests', {action: 'accepted', ...})`
///   - Server grants permission (e.g., unmutes participant, allows video)
///   - Removes request from local list
///
/// - **Reject (✕):** Calls `handleRequestAction('rejected')`
///   - Emits: `socket.emit('updateRequests', {action: 'rejected', ...})`
///   - Server notifies participant of denial
///   - Removes request from local list
///
/// **State Management:**
/// - Request list filtering happens in `respondToRequests`:
///   ```dart
///   final filteredList = requestList.where((r) => r.id != request.id).toList();
///   updateRequestList(filteredList);
///   ```
/// - Parent component (RequestsModal) manages master `requestList` state
/// - `updateRequestList` callback synchronizes parent state after each action
///
/// **Socket Event Payload:**
/// ```dart
/// {
///   'action': 'accepted', // or 'rejected'
///   'requestId': 'req123',
///   'roomName': 'conference-room-456',
/// }
/// ```
///
/// **Flex Layout:**
/// - Name: 5 units (41.7% width)
/// - Icon: 2 units (16.7% width)
/// - Accept button: 2 units (16.7% width)
/// - Reject button: 2 units (16.7% width)
/// - Spacer: 1 unit (8.3% width)
/// - Total: 12 units
///
/// **Accessibility:**
/// - IconButton provides touch targets (min 48x48 logical pixels)
/// - Green check and red X provide color-coded visual feedback
/// - Participant name displayed as text label
///
/// **Typical Usage Context:**
/// - RequestsModal list rendering
/// - ListView.builder item renderer for `requestList`
/// - Host/co-host permission management interface
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
