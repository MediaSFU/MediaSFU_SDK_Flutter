import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../consumers/generate_page_content.dart'
    show
        generatePageContent,
        GeneratePageContentParameters,
        GeneratePageContentOptions,
        GeneratePageContentType;
import '../../types/types.dart' show ShowAlert, BreakoutParticipant;

abstract class PaginationParameters implements GeneratePageContentParameters {
  int get mainRoomsLength;
  int get memberRoom;
  bool get breakOutRoomStarted;
  bool get breakOutRoomEnded;
  String get member;
  List<List<BreakoutParticipant>> get breakoutRooms;
  int get hostNewRoom;
  String get roomName;
  String get islevel;
  ShowAlert? get showAlert;
  io.Socket? get socket;

  // mediasfu functions
  PaginationParameters Function() get getUpdatedAllParams;
  // dynamic operator [](String key);
}

/// `PaginationOptions` - Configuration options for the `Pagination` widget.
///
/// ### Properties:
/// - `totalPages`: The total number of pages available for navigation.
/// - `currentUserPage`: The current page number for the user.
/// - `handlePageChange`: Callback function for handling page change events.
/// - `position`: Position of the pagination container ('middle' by default).
/// - `location`: Location of pagination (e.g., 'bottom').
/// - `direction`: Direction of pagination (e.g., 'horizontal' or 'vertical').
/// - `buttonsContainerStyle`: Optional styling constraints for the pagination buttons container.
/// - `alternateIconComponent`: Optional widget for an alternate icon display in pagination.
/// - `iconComponent`: Optional widget for the main icon display in pagination.
/// - `activePageColor`: Background color for the active page button.
/// - `inactivePageColor`: Background color for inactive page buttons.
/// - `backgroundColor`: Background color for the pagination container.
/// - `paginationHeight`: Maximum height of the pagination component.
/// - `showAspect`: Boolean to show pagination (defaults to true).
/// - `parameters`: Provides the parameters needed for handling page changes, including room settings, socket information, user access level, and any alert functionality.
///
/// ### Example Usage:
/// ```dart
/// Pagination(
///   options: PaginationOptions(
///     totalPages: 10,
///     currentUserPage: 1,
///     parameters: PaginationParametersImplementation(),
///   ),
/// );
/// ```
class PaginationOptions {
  final int totalPages;
  final int currentUserPage;
  final GeneratePageContentType handlePageChange;
  final String position;
  final String location;
  final String direction;
  final BoxConstraints? buttonsContainerStyle;
  final Widget? alternateIconComponent;
  final Widget? iconComponent;
  final Color activePageColor;
  final Color? inactivePageColor;
  final Color backgroundColor;
  final double paginationHeight;
  final bool showAspect;
  final PaginationParameters parameters;

  PaginationOptions({
    required this.totalPages,
    required this.currentUserPage,
    this.handlePageChange = generatePageContent,
    this.position = 'middle',
    this.location = 'bottom',
    this.direction = 'horizontal',
    this.buttonsContainerStyle,
    this.alternateIconComponent,
    this.iconComponent,
    this.activePageColor = const Color(0xFF2c678f),
    this.inactivePageColor,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.paginationHeight = 40.0,
    this.showAspect = true,
    required this.parameters,
  });
}

typedef PaginationType = Widget Function({required PaginationOptions options});

/// `Pagination` - A widget for handling pagination with breakout room considerations.
///
/// The `Pagination` widget displays pagination controls for navigating through pages.
/// It includes breakout room logic to allow or restrict access to specific rooms
/// based on the user's access level and breakout room states.
///
/// ### Parameters:
/// - `options` (`PaginationOptions`): Configuration options for the pagination.
///
/// ### Structure:
/// - Displays a paginated view with buttons styled based on the active or inactive state.
/// - Provides breakout room handling, alert notifications, and socket-based updates if the user is not authorized to access certain rooms.
///
/// ### Example Usage:
/// ```dart
/// Pagination(
///   options: PaginationOptions(
///     totalPages: 5,
///     currentUserPage: 2,
///     handlePageChange: customPageChangeHandler,
///     parameters: PaginationParametersImplementation(),
///     position: 'bottom',
///   ),
/// );
/// ```

class Pagination extends StatelessWidget {
  final PaginationOptions options;

  const Pagination({super.key, required this.options});

  Future<void> handleClick(int page, int offSet) async {
    if (page == options.currentUserPage) {
      return;
    }
    PaginationParameters parameters = options.parameters;
    final PaginationParameters updatedParameters =
        parameters.getUpdatedAllParams();
    parameters = updatedParameters;

    var breakOutRoomStarted = parameters.breakOutRoomStarted;
    var breakOutRoomEnded = parameters.breakOutRoomEnded;
    var member = parameters.member;
    var breakoutRooms = parameters.breakoutRooms;
    var hostNewRoom = parameters.hostNewRoom;
    var roomName = parameters.roomName;
    var islevel = parameters.islevel;
    var showAlert = parameters.showAlert;
    var socket = parameters.socket;

    if (breakOutRoomStarted && !breakOutRoomEnded && page != 0) {
      final roomMember = breakoutRooms.firstWhere(
        (r) => r.any((p) => p.name == member),
        orElse: () => [BreakoutParticipant(name: '')],
      );
      final pageInt = page - offSet;
      int memberBreakRoom = -1;

      if (roomMember.isNotEmpty && roomMember.first.name == member) {
        memberBreakRoom = breakoutRooms.indexOf(roomMember);
      }

      if ((memberBreakRoom == -1 || memberBreakRoom != pageInt) &&
          pageInt >= 0) {
        if (islevel != '2') {
          showAlert!(
            message: 'You are not part of the breakout room ${pageInt + 1}.',
            type: 'danger',
            duration: 3000,
          );
          return;
        }

        final optionsHandlePageChange = GeneratePageContentOptions(
          parameters: parameters,
          page: page,
          breakRoom: pageInt,
          inBreakRoom: true,
        );
        await options.handlePageChange(
          optionsHandlePageChange,
        );

        if (hostNewRoom != pageInt) {
          socket!.emitWithAck(
              'updateHostBreakout', {'newRoom': pageInt, 'roomName': roomName},
              ack: (response) async {});
        }
      } else {
        final optionsHandlePageChange = GeneratePageContentOptions(
          page: page,
          parameters: parameters,
          breakRoom: pageInt,
          inBreakRoom: pageInt >= 0,
        );
        await options.handlePageChange(
          optionsHandlePageChange,
        );

        if (islevel == '2' && hostNewRoom != -1) {
          socket!.emitWithAck('updateHostBreakout',
              {'prevRoom': hostNewRoom, 'newRoom': -1, 'roomName': roomName},
              ack: (response) async {});
        }
      }
    } else {
      final optionsHandlePageChange = GeneratePageContentOptions(
        page: page,
        parameters: parameters,
        breakRoom: 0,
        inBreakRoom: false,
      );
      await options.handlePageChange(
        optionsHandlePageChange,
      );

      if (islevel == '2' && hostNewRoom != -1) {
        socket!.emitWithAck('updateHostBreakout',
            {'prevRoom': hostNewRoom, 'newRoom': -1, 'roomName': roomName},
            ack: (response) async {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<int> data =
        List<int>.generate(options.totalPages + 1, (index) => index);

    return Visibility(
      visible: options.showAspect,
      child: Container(
        color: options.backgroundColor,
        constraints: BoxConstraints(
          maxHeight: options.direction == 'vertical'
              ? double.infinity
              : options.paginationHeight,
          maxWidth: options.direction == 'horizontal'
              ? double.infinity
              : options.paginationHeight,
        ),
        child: Center(
          child: ListView.builder(
            shrinkWrap:
                true, // Ensures the ListView only occupies the space needed
            scrollDirection: options.direction == 'vertical'
                ? Axis.vertical
                : Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final isActive = data[index] == options.currentUserPage;
              final pageStyle = isActive
                  ? BoxDecoration(
                      color: options.activePageColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    )
                  : BoxDecoration(
                      color: options.inactivePageColor,
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    );

              String displayItem = data[index].toString();
              final targetPage = options.parameters.memberRoom;

              if (options.parameters.breakOutRoomStarted &&
                  !(options.parameters.breakOutRoomEnded) &&
                  data[index] >= options.parameters.mainRoomsLength) {
                final roomNumber =
                    data[index] - (options.parameters.mainRoomsLength - 1);

                if (targetPage + 1 != roomNumber) {
                  if (options.parameters.islevel != '2') {
                    displayItem = 'Room $roomNumber 🔒';
                  } else {
                    displayItem = 'Room $roomNumber';
                  }
                } else {
                  displayItem = 'Room $roomNumber';
                }
              } else {
                displayItem = data[index].toString();
              }

              return GestureDetector(
                onTap: () {
                  if (!isActive) {
                    handleClick(
                        data[index], options.parameters.mainRoomsLength);
                  }
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: pageStyle,
                  child: Center(
                    child: data[index] == 0
                        ? Icon(Icons.star,
                            size: 18,
                            color: isActive ? Colors.yellow : Colors.grey)
                        : Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Text(
                              displayItem,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
