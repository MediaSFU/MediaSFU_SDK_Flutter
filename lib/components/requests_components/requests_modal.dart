import 'package:flutter/material.dart';

// Import the respondToRequests function
import '../../methods/requests_methods/respond_to_requests.dart'
    show respondToRequests;
import './render_request_component.dart' show RenderRequestComponent;
import '../../methods/utils/get_modal_position.dart' show getModalPosition;

/// RequestsModal is a StatelessWidget that displays a modal for managing requests.
///
/// `isRequestsModalVisible`: Flag to control the visibility of the modal.
/// `onRequestClose`: Callback function to close the modal.
/// `requestCounter`: Counter for the number of requests.
/// `onRequestFilterChange`: Callback function for filtering requests.
/// `requestList`: List of requests to display.
/// `onRequestItemPress`: Callback function to respond to a request item press.
/// `updateRequestList`: Function to update the list of requests.
/// `roomName`: The name of the room.
/// `socket`: Socket for communication.
/// `backgroundColor`: Background color of the modal.
/// `position`: Position of the modal.
/// `parameters`: Additional parameters.
/// `renderRequestComponent`: Function to render each request item.

typedef RespondToRequests = void Function(
    {required Map<String, dynamic> parameters});

// Define the RequestsModal widget
class RequestsModal extends StatelessWidget {
  // Define the properties of the widget
  final bool isRequestsModalVisible;
  final Function() onRequestClose;
  final int requestCounter;
  final Function(String) onRequestFilterChange;
  final List<dynamic> requestList;
  final RespondToRequests onRequestItemPress;
  final Function(List<dynamic>) updateRequestList;
  final String roomName;
  final dynamic socket;
  final Color backgroundColor;
  final String position;
  final Map<String, dynamic> parameters;
  final Widget Function(
    Map<String, dynamic>, // request
    RespondToRequests, // onRequestItemPress
    List<dynamic>, // requestList
    Function(List<dynamic>), // updateRequestList
    String, // roomName
    dynamic, // socket
  ) renderRequestComponent;

  // Constructor for the widget
  const RequestsModal({
    super.key,
    required this.isRequestsModalVisible,
    required this.onRequestClose,
    required this.requestCounter,
    required this.onRequestFilterChange,
    required this.requestList,
    this.onRequestItemPress = respondToRequests,
    required this.updateRequestList,
    required this.roomName,
    required this.socket,
    this.backgroundColor = const Color(0xFF83C0E9),
    this.position = 'topRight',
    required this.parameters,
    this.renderRequestComponent = _defaultRenderRequestComponent,
  });

  // Default renderRequestComponent function
  static Widget _defaultRenderRequestComponent(
    Map<String, dynamic> request,
    RespondToRequests onRequestItemPress,
    List<dynamic> requestList,
    Function(List<dynamic>) updateRequestList,
    String roomName,
    dynamic socket,
  ) {
    return RenderRequestComponent(
      request: request,
      onRequestItemPress: onRequestItemPress,
      requestList: requestList,
      updateRequestList: updateRequestList,
      roomName: roomName,
      socket: socket,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = 0.8 * screenWidth;
    if (modalWidth > 400) {
      modalWidth = 400;
    }

    double modalHeight = MediaQuery.of(context).size.height * 0.65;

    return Visibility(
      visible: isRequestsModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(
                position, context, modalWidth, modalHeight)['top'],
            right: getModalPosition(
                position, context, modalWidth, modalHeight)['right'],
            child: Container(
              width: modalWidth,
              height: MediaQuery.of(context).size.height * 0.65,
              color: backgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Requests $requestCounter',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onRequestClose,
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
                      onChanged: onRequestFilterChange,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: requestList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: renderRequestComponent(
                            requestList[
                                index], // Pass the request object directly
                            onRequestItemPress, // Pass onRequestItemPress here
                            requestList,
                            updateRequestList,
                            roomName,
                            socket,
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
