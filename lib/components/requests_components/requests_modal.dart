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

abstract class RequestsModalParameters {
  /// Function to get updated parameters.
  RequestsModalParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Options for the RequestsModal widget.
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
  });

  // Default rendering function for individual request components.
  static Widget _defaultRenderRequestComponent(
      {required RenderRequestComponentOptions options}) {
    return RenderRequestComponent(options: options);
  }
}

typedef RequestsModalType = Widget Function({RequestsModalOptions options});

/// `RequestsModal` displays a modal window containing a list of requests and
/// provides search and filter functionality. The modal allows users to accept
/// or reject each request using real-time actions through a socket connection.
///
/// ### Parameters:
/// - [options] (`RequestsModalOptions`): A configuration object with properties:
///   - `isRequestsModalVisible` (bool): Controls modal visibility.
///   - `onRequestClose` (VoidCallback): Closes the modal.
///   - `requestCounter` (int): Count of active requests, displayed in the header.
///   - `onRequestFilterChange` (Function): Updates the filter query for the request list.
///   - `requestList` (List<Request>): List of current requests to display.
///   - `onRequestItemPress` (RespondToRequestsType): Callback for handling request item actions.
///   - `updateRequestList` (Function): Updates the list of requests.
///   - `roomName` (String): Name of the room associated with the requests.
///   - `socket` (io.Socket): Socket instance for emitting responses.
///   - `backgroundColor` (Color): Background color of the modal.
///   - `position` (String): Controls the modal position on the screen (e.g., 'topRight').
///   - `parameters` (RequestsModalParameters): Additional parameters.
///   - `renderRequestComponent` (RenderRequestComponentType): Function to render each request item.
///
/// ### Example:
/// ```dart
/// RequestsModal(
///   options: RequestsModalOptions(
///     isRequestsModalVisible: true,
///     onRequestClose: () => print('Modal closed'),
///     requestCounter: 5,
///     onRequestFilterChange: (query) => print('Filtering requests with: $query'),
///     requestList: [Request(id: '1', name: 'John', icon: 'fa-microphone')],
///     updateRequestList: (newList) => setState(() => requests = newList),
///     roomName: 'MainRoom',
///     socket: socket,
///     position: 'topRight',
///     parameters: {},
///   ),
/// );
/// ```
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
