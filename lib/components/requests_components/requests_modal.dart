import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/requests_methods/respond_to_requests.dart'
    show respondToRequests;
import './render_request_component.dart'
    show
        RenderRequestComponent,
        RenderRequestComponentOptions,
        RenderRequestComponentType;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/types.dart' show Request, RespondToRequestsType;
import '../../types/modal_style_options.dart' show ModalRenderMode;

abstract class RequestsModalParameters {
  /// Function to get updated parameters.
  RequestsModalParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Configuration for the requests modal displaying participant requests (screenshare/video/audio).
///
/// * **requestList** - Array of `Request` objects; each has `id`, `name`, `icon` (FontAwesome icon name like 'fa-microphone', 'fa-video', 'fa-desktop').
/// * **requestCounter** - Count of pending requests; shown in modal header badge.
/// * **onRequestItemPress** - Override for `respondToRequests`; receives {request, updateRequestList, requestList, action, roomName, socket}. `action` is `'accepted'` (grant) or `'rejected'` (deny); emits `updateRequestAction` socket event.
/// * **onRequestFilterChange** - Callback when search input changes; filters `requestList` by participant name.
/// * **updateRequestList** - Updates `requestList` in parent state after grant/deny.
/// * **roomName** - Session identifier for socket event.
/// * **socket** - Socket.IO client for emitting `updateRequestAction` event.
/// * **position** - Modal placement via `getModalPosition` (e.g., 'topRight').
/// * **backgroundColor** - Background color for modal container.
/// * **renderRequestComponent** - Custom renderer for individual request items; receives `RenderRequestComponentOptions` with `request`, `onRequestItemPress`, `requestList`, `updateRequestList`, `roomName`, `socket`. Defaults to `RenderRequestComponent` widget.
/// * **parameters** - Must expose `getUpdatedAllParams`.
///
/// Compatible with [ModernRequestsModalOptions] from the modern component.
///
/// ### Usage
/// 1. Modal displays header with "Requests" title and counter badge.
/// 2. Search input filters `requestList` by participant name.
/// 3. Each request row shows name, icon (microphone/video/screenshare), and "Accept" (green) / "Reject" (red) buttons.
/// 4. "Accept" button calls `onRequestItemPress` with `action: 'accepted'`, emitting `updateRequestAction` socket event with `{requestId, action: 'accepted', roomName}`.
/// 5. "Reject" button calls `onRequestItemPress` with `action: 'rejected'`, emitting `updateRequestAction` event with `action: 'rejected'`.
/// 6. After grant/deny, `updateRequestList` removes request from queue.
/// 7. Override via `MediasfuUICustomOverrides.requestsModal` to inject custom approval workflows, analytics tracking, or automated policies.
class RequestsModalOptions {
  final bool isRequestsModalVisible;
  final VoidCallback onRequestClose;
  final int requestCounter;
  final Function(String) onRequestFilterChange;
  final List<Request> requestList;
  RespondToRequestsType onRequestItemPress;
  final Function(List<Request>) updateRequestList;
  final String roomName;
  final io.Socket? socket;
  final Color backgroundColor;
  final String position;
  RenderRequestComponentType renderRequestComponent;
  final RequestsModalParameters parameters;

  /// Dark mode toggle for modern styling.
  /// Note: Pending modern implementation - placeholder for future glassmorphic UI.
  final bool isDarkMode;

  /// Enable glassmorphism effects for modern styling.
  /// Note: Pending modern implementation - placeholder for future glassmorphic UI.
  final bool enableGlassmorphism;

  /// Render mode for embedding in different contexts.
  /// - `modal`: Full modal with overlay, positioning, visibility wrapper (default)
  /// - `sidebar`: Content only, for embedding in sidebar panel
  /// - `inline`: Content only, no visibility check
  final ModalRenderMode renderMode;

  RequestsModalOptions({
    required this.isRequestsModalVisible,
    required this.onRequestClose,
    required this.requestCounter,
    required this.onRequestFilterChange,
    required this.requestList,
    this.onRequestItemPress = respondToRequests,
    required this.updateRequestList,
    required this.roomName,
    this.socket,
    this.backgroundColor = const Color(0xFF83C0E9),
    this.position = 'topRight',
    required this.parameters,
    this.renderRequestComponent =
        _defaultRenderRequestComponent, // Default rendering function
    this.isDarkMode = false,
    this.enableGlassmorphism = false,
    this.renderMode = ModalRenderMode.modal,
  });

  // Default rendering function for individual request components.
  static Widget _defaultRenderRequestComponent(
      {required RenderRequestComponentOptions options}) {
    return RenderRequestComponent(options: options);
  }
}

typedef RequestsModalType = Widget Function({RequestsModalOptions options});

/// Requests modal displaying participant permission requests (screenshare/video/audio) with grant/deny actions (host-only).
///
/// * Displays scrollable list of `Request` objects from `requestList`.
/// * Header shows "Requests" title with counter badge (`requestCounter`).
/// * Search input filters list by participant name via `onRequestFilterChange`.
/// * Each request row shows participant name, icon (FontAwesome icon from
///   `request.icon` like 'fa-microphone', 'fa-video', 'fa-desktop'), and "Accept"
///   (green checkmark) / "Reject" (red X) icon buttons.
/// * "Accept" calls `onRequestItemPress` with `action: 'accepted'`, which emits
///   `updateRequestAction` socket event with `{requestId, action: 'accepted', roomName}`,
///   then removes request from `requestList` via `updateRequestList`.
/// * "Reject" calls `onRequestItemPress` with `action: 'rejected'`, emitting
///   `updateRequestAction` event with `action: 'rejected'`, then removes from queue.
/// * Empty state shows "No requests" when list is empty.
/// * Positions via `getModalPosition` using `options.position`.
/// * Request items rendered via `renderRequestComponent` (defaults to
///   `RenderRequestComponent` widget); can be overridden for custom rendering.
///
/// Override via `MediasfuUICustomOverrides.requestsModal` to inject custom
/// approval workflows, analytics tracking, or automated policies.
///
/// ### Workflow:
/// 1. **Visibility**: The `isRequestsModalVisible` controls whether the modal is shown.
/// 2. **Filtering**: Text input filters requests via `onRequestFilterChange`.
/// 3. **Request List**: Each request is rendered using `renderRequestComponent`, which supports custom UI.

class RequestsModal extends StatelessWidget {
  final RequestsModalOptions options;

  const RequestsModal({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    // Note: renderMode is available for API compatibility but sidebar/inline
    // rendering is handled by modern components. This classic modal always
    // renders in modal mode.

    final screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = 0.8 * screenWidth;
    if (modalWidth > 400) modalWidth = 400;

    final modalHeight = MediaQuery.of(context).size.height * 0.65;

    return Visibility(
      visible: options.isRequestsModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(GetModalPositionOptions(
                position: options.position,
                modalWidth: modalWidth,
                modalHeight: modalHeight,
                context: context))['top'],
            right: getModalPosition(GetModalPositionOptions(
                position: options.position,
                modalWidth: modalWidth,
                modalHeight: modalHeight,
                context: context))['right'],
            child: Container(
              width: modalWidth,
              height: modalHeight,
              decoration: BoxDecoration(
                color: options.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Requests ${options.requestCounter}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: options.onRequestClose,
                        icon: const Icon(Icons.close),
                        color: Colors.black,
                      ),
                    ],
                  ),
                  const Divider(
                    height: 1,
                    color: Colors.black,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search ...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: options.onRequestFilterChange,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: options.requestList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final request = options.requestList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: options.renderRequestComponent(
                            options: RenderRequestComponentOptions(
                              request: request,
                              requestList: options.requestList,
                              updateRequestList: options.updateRequestList,
                              roomName: options.roomName,
                              socket: options.socket,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
