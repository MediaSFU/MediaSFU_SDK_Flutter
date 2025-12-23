import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../consumers/generate_page_content.dart'
    show
        generatePageContent,
        GeneratePageContentParameters,
        GeneratePageContentOptions,
        GeneratePageContentType;
import '../../types/types.dart' show ShowAlert, BreakoutParticipant;

/// Provides context when building a custom container for [Pagination].
class PaginationContainerContext {
  final BuildContext context;
  final PaginationOptions options;
  final List<int> pages;
  final Widget listView;
  final Widget defaultContainer;

  PaginationContainerContext({
    required this.context,
    required this.options,
    required this.pages,
    required this.listView,
    required this.defaultContainer,
  });
}

/// Provides context when building the content portion of a page control.
class PaginationPageContentContext {
  final BuildContext context;
  final PaginationOptions options;
  final int page;
  final bool isActive;
  final bool isHomePage;
  final bool isLocked;
  final String label;
  final Widget defaultContent;

  PaginationPageContentContext({
    required this.context,
    required this.options,
    required this.page,
    required this.isActive,
    required this.isHomePage,
    required this.isLocked,
    required this.label,
    required this.defaultContent,
  });
}

/// Provides context when building the full button for a page control.
class PaginationPageButtonContext {
  final BuildContext context;
  final PaginationOptions options;
  final int page;
  final bool isActive;
  final bool isHomePage;
  final bool isLocked;
  final Widget content;
  final Widget defaultButton;
  final Future<void> Function() onSelect;

  PaginationPageButtonContext({
    required this.context,
    required this.options,
    required this.page,
    required this.isActive,
    required this.isHomePage,
    required this.isLocked,
    required this.content,
    required this.defaultButton,
    required this.onSelect,
  });
}

typedef PaginationContainerBuilder = Widget Function(
  PaginationContainerContext context,
);

typedef PaginationPageContentBuilder = Widget Function(
  PaginationPageContentContext context,
);

typedef PaginationPageButtonBuilder = Widget Function(
  PaginationPageButtonContext context,
);

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

/// Configuration options for the `Pagination` widget.
///
/// Defines pagination behavior for navigating between main room and breakout rooms in video
/// conferencing. Supports role-based access control (host vs. participant), locked room
/// indicators, and socket-based room switching with server synchronization.
///
/// **Properties:**
/// - `totalPages`: Total number of pages (0 = main room, 1+ = participant pages or breakout rooms)
/// - `currentUserPage`: Active page index (0-based)
/// - `handlePageChange`: Callback invoked when page changes (defaults to generatePageContent)
/// - `position`: Horizontal alignment of pagination within container ('left', 'middle', 'right'). Defaults to 'middle'
/// - `location`: Vertical position hint ('top', 'bottom'). Used for positioning context. Defaults to 'bottom'
/// - `direction`: Layout direction ('horizontal' for row, 'vertical' for column). Defaults to 'horizontal'
/// - `buttonsContainerStyle`: BoxConstraints for individual page buttons (e.g., BoxConstraints.tightFor(width: 60, height: 40))
/// - `alternateIconComponent`: Custom widget for alternate page indicator (currently unused in default implementation)
/// - `iconComponent`: Custom widget for page 0 home icon (overrides default star icon)
/// - `activePageColor`: Background color for selected page button (defaults to Color(0xFF2c678f) - blue)
/// - `inactivePageColor`: Background color for unselected page buttons (defaults to null = transparent)
/// - `backgroundColor`: Background color for entire pagination container (defaults to Color(0xFFFFFFFF) - white)
/// - `paginationHeight`: Maximum height (horizontal mode) or width (vertical mode) in pixels (defaults to 40.0)
/// - `showAspect`: Visibility flag (true = show pagination; false = hide). Defaults to true
/// - `parameters`: PaginationParameters providing room state, socket, user level, alerts (required)
/// - `containerBuilder`: Hook to wrap entire pagination container (receives listView, pages list)
/// - `pageButtonBuilder`: Hook to customize individual page button (receives page, isActive, isLocked, content, onSelect callback)
/// - `pageContentBuilder`: Hook to customize button content (receives page, isActive, isLocked, label, defaultContent)
///
/// **Page Number Interpretation:**
/// ```
/// Page 0: Main room (always accessible, displayed as star icon)
/// Page 1 to mainRoomsLength-1: Regular participant pages (if mainRoomsLength > 1)
/// Page mainRoomsLength+: Breakout rooms (labeled "Room N", locked if not member)
///
/// Breakout Room Number = page - (mainRoomsLength - 1)
/// ```
///
/// **Locked Room Display Logic:**
/// ```
/// if (breakOutRoomStarted && !breakOutRoomEnded && page >= mainRoomsLength) {
///   roomNumber = page - (mainRoomsLength - 1);
///   if (memberRoom + 1 != roomNumber && islevel != '2') {
///     label = "Room {roomNumber} 🔒"; // locked for non-host participants
///     isLocked = true;
///   } else {
///     label = "Room {roomNumber}"; // unlocked (member or host)
///   }
/// } else {
///   label = page.toString(); // numeric label outside breakout session
/// }
/// ```
///
/// **Builder Hook Flow:**
/// ```
/// 1. Determine page state (isActive, isHomePage, isLocked, displayLabel)
/// 2. Create baseContent (star icon for page 0, Text for others)
/// 3. pageContentBuilder?(baseContent) → resolvedContent
/// 4. Wrap resolvedContent in GestureDetector + Container → defaultButton
/// 5. pageButtonBuilder?(resolvedContent, defaultButton, onSelect) → final button
/// 6. Build ListView with all page buttons
/// 7. Wrap ListView in Container with styling
/// 8. containerBuilder?(listView, defaultContainer) → final container
/// 9. Wrap in Visibility(showAspect)
/// ```
///
/// **Common Configurations:**
/// ```dart
/// // 1. Basic horizontal pagination (5 pages)
/// PaginationOptions(
///   totalPages: 5,
///   currentUserPage: 0,
///   parameters: parameters,
///   activePageColor: Colors.blue,
///   inactivePageColor: Colors.grey[300],
///   backgroundColor: Colors.white,
/// )
///
/// // 2. Vertical sidebar pagination
/// PaginationOptions(
///   totalPages: 10,
///   currentUserPage: 2,
///   direction: 'vertical',
///   parameters: parameters,
///   paginationHeight: 80, // width in vertical mode
///   position: 'left',
/// )
///
/// // 3. Breakout room pagination (4 main rooms + 3 breakout rooms)
/// PaginationOptions(
///   totalPages: 7, // 0 (main) + 1-3 (participants) + 4-6 (breakout rooms 1-3)
///   currentUserPage: 0,
///   parameters: parameters, // with mainRoomsLength=4, memberRoom=0, breakOutRoomStarted=true
///   activePageColor: Colors.green,
///   inactivePageColor: Colors.grey[200],
/// )
/// // Result: Page 0 = star, Page 1-3 = "1", "2", "3", Page 4-6 = "Room 1", "Room 2", "Room 3" (locked if not member)
///
/// // 4. Custom page button styling
/// PaginationOptions(
///   totalPages: 5,
///   currentUserPage: 1,
///   parameters: parameters,
///   buttonsContainerStyle: BoxConstraints.tightFor(width: 50, height: 50),
///   pageButtonBuilder: (context) {
///     return Container(
///       margin: EdgeInsets.all(8),
///       decoration: BoxDecoration(
///         color: context.isActive ? Colors.blue : Colors.white,
///         shape: BoxShape.circle,
///         border: Border.all(color: Colors.blue, width: 2),
///         boxShadow: context.isActive
///             ? [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 8)]
///             : [],
///       ),
///       child: Center(child: context.content),
///     );
///   },
/// )
/// ```
///
/// **Typical Use Cases:**
/// - Video conference participant pagination
/// - Breakout room navigation with access control
/// - Multi-page gallery view
/// - Room-based content switching
/// - Host-controlled breakout session management
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
  final PaginationContainerBuilder? containerBuilder;
  final PaginationPageButtonBuilder? pageButtonBuilder;
  final PaginationPageContentBuilder? pageContentBuilder;
  final bool isDarkMode;

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
    this.containerBuilder,
    this.pageButtonBuilder,
    this.pageContentBuilder,
    this.isDarkMode = true,
  });
}

typedef PaginationType = Widget Function({required PaginationOptions options});

/// A stateless widget rendering pagination controls with breakout room access management.
///
/// Displays page navigation buttons for switching between main room and breakout rooms in
/// video conferencing. Implements role-based access control (host can visit any room,
/// participants restricted to assigned room), socket-based room switching, and server
/// synchronization via updateHostBreakout events.
///
/// **Lifecycle & State Management:**
/// - Stateless widget (no internal state)
/// - Reads current page from options.currentUserPage
/// - Page changes trigger handlePageChange callback (typically updates parent state + server)
/// - Access control checks performed in handleClick() before page change
///
/// **Access Control Logic (in handleClick):**
/// ```
/// if (breakOutRoomStarted && !breakOutRoomEnded && targetPage != 0) {
///   // Calculate which breakout room the page represents
///   breakRoomIndex = targetPage - (mainRoomsLength - 1);
///
///   // Find user's assigned breakout room
///   userBreakoutRoom = breakoutRooms.findIndex(room => room.contains(member));
///
///   if (userBreakoutRoom != breakRoomIndex && breakRoomIndex >= 0) {
///     // User trying to access non-assigned room
///     if (islevel != '2') {
///       // Non-host: deny access with alert
///       showAlert("You are not part of the breakout room N");
///       return;
///     } else {
///       // Host: allow access, emit updateHostBreakout to server
///       handlePageChange(page, breakRoom: breakRoomIndex, inBreakRoom: true);
///       socket.emit('updateHostBreakout', newRoom);
///     }
///   } else {
///     // User accessing assigned room or main room
///     handlePageChange(page, breakRoom: breakRoomIndex, inBreakRoom: true);
///     if (host leaving previous room) socket.emit('updateHostBreakout', -1);
///   }
/// } else {
///   // Not in breakout session: allow any page navigation
///   handlePageChange(page, breakRoom: 0, inBreakRoom: false);
/// }
/// ```
///
/// **Page Button Rendering Logic:**
/// ```
/// 1. Determine page state:
///    - isActive = page == currentUserPage
///    - isHomePage = page == 0
///    - isLocked = (breakout session active) && (page is breakout room) && (user not member) && (user not host)
///    - displayLabel = isHomePage ? star icon : page number or "Room N" or "Room N 🔒"
///
/// 2. Build baseContent:
///    - isHomePage: Icon(Icons.star, color: isActive ? yellow : grey)
///    - else: Text(displayLabel, fontSize: 16, fontWeight: bold)
///
/// 3. Apply pageContentBuilder hook (if provided)
///
/// 4. Wrap in GestureDetector + Container:
///    - onTap: handleClick(page) if !isActive
///    - decoration: activeDecoration (blue shadow) or inactiveDecoration (black border)
///    - margin: 5px horizontal/vertical
///    - constraints: buttonsContainerStyle (if provided)
///
/// 5. Apply pageButtonBuilder hook (if provided)
/// ```
///
/// **Socket Event Emission:**
/// ```
/// Event: 'updateHostBreakout'
/// Payload:
///   - newRoom: breakRoomIndex (host entering new room)
///   - prevRoom: hostNewRoom (host leaving previous room, optional)
///   - roomName: roomName (current meeting room name)
///
/// Emitted when:
///   - Host switches to breakout room (newRoom = breakRoomIndex)
///   - Host returns to main room (newRoom = -1, prevRoom = previous breakRoomIndex)
/// ```
///
/// **Common Use Cases:**
/// 1. **Basic Main Room Pagination:**
///    ```dart
///    Pagination(
///      options: PaginationOptions(
///        totalPages: 5, // 0 (main) + 1-5 (participant pages)
///        currentUserPage: 0,
///        parameters: parameters,
///        activePageColor: Colors.blue,
///        inactivePageColor: Colors.grey[300],
///        handlePageChange: (options) async {
///          // Switch displayed participants based on page
///          await updateMainGrid(options.page);
///        },
///      ),
///    )
///    ```
///
/// 2. **Breakout Room Navigation (Participant):**
///    ```dart
///    // Scenario: 4 main pages, 3 breakout rooms; user in room 2
///    Pagination(
///      options: PaginationOptions(
///        totalPages: 7, // 0-3 (main) + 4-6 (rooms 1-3)
///        currentUserPage: 0,
///        parameters: PaginationParameters(
///          mainRoomsLength: 4,
///          memberRoom: 1, // user in breakout room 2 (0-indexed)
///          breakOutRoomStarted: true,
///          breakOutRoomEnded: false,
///          member: 'john_doe',
///          breakoutRooms: [
///            [BreakoutParticipant(name: 'alice')],
///            [BreakoutParticipant(name: 'john_doe')], // user's room
///            [BreakoutParticipant(name: 'charlie')],
///          ],
///          islevel: '1', // participant level
///          showAlert: showAlertFunction,
///        ),
///      ),
///    )
///    // Result:
///    // - Page 0-3: numeric labels (1-3, main room)
///    // - Page 4: "Room 1 🔒" (locked)
///    // - Page 5: "Room 2" (unlocked, user's room)
///    // - Page 6: "Room 3 🔒" (locked)
///    // - Clicking locked room shows alert
///    ```
///
/// 3. **Breakout Room Navigation (Host):**
///    ```dart
///    // Scenario: Host can visit any breakout room
///    Pagination(
///      options: PaginationOptions(
///        totalPages: 7,
///        currentUserPage: 5, // currently in breakout room 2
///        parameters: PaginationParameters(
///          mainRoomsLength: 4,
///          memberRoom: -1, // host not assigned to any room
///          breakOutRoomStarted: true,
///          breakOutRoomEnded: false,
///          member: 'host_user',
///          breakoutRooms: [[...], [...], [...]],
///          hostNewRoom: 1, // host currently in room 2 (0-indexed)
///          islevel: '2', // host level
///          socket: socketInstance,
///          roomName: 'meeting_room_123',
///        ),
///      ),
///    )
///    // Result:
///    // - All pages unlocked (no 🔒 symbols)
///    // - Clicking room 1 (page 4):
///    //   1. Emit socket event
///    //   2. Update local state: hostNewRoom = 0
///    //   3. Switch to room 1 view
///    ```
///
/// **Override Integration:**
/// Integrates with `MediasfuUICustomOverrides` for global styling:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   paginationOptions: ComponentOverride<PaginationOptions>(
///     builder: (existingOptions) => PaginationOptions(
///       totalPages: existingOptions.totalPages,
///       currentUserPage: existingOptions.currentUserPage,
///       parameters: existingOptions.parameters,
///       handlePageChange: existingOptions.handlePageChange,
///       activePageColor: Colors.deepPurple,
///       inactivePageColor: Colors.grey[100],
///       backgroundColor: Colors.grey[50]!,
///       buttonsContainerStyle: BoxConstraints.tightFor(width: 55, height: 45),
///     ),
///   ),
/// ),
/// ```
///
/// **Responsive Behavior:**
/// - Horizontal mode: maxHeight = paginationHeight, width expands
/// - Vertical mode: maxWidth = paginationHeight (acts as width), height expands
/// - ListView.builder creates buttons on demand (efficient for many pages)
/// - Visibility widget hides entire component when showAspect=false
///
/// **Performance Notes:**
/// - Stateless widget (no internal state to manage)
/// - ListView.builder lazily builds page buttons (efficient for large page counts)
/// - Access control checks only when button clicked (not during render)
/// - Socket events emitted with ack for reliable delivery
/// - Builder hooks called during every build (not cached)
///
/// **Implementation Details:**
/// - Uses ListView.builder for efficient pagination rendering
/// - Pages list generated via List.generate (0 to totalPages inclusive)
/// - Active/inactive decorations use BoxShadow for depth effect
/// - Home page (0) always uses star icon, others use text labels
/// - Breakout room numbers calculated as: page - (mainRoomsLength - 1)
/// - Socket emitWithAck ensures server receives updateHostBreakout events
/// - getUpdatedAllParams() called before access checks to get latest state
///
/// **Typical Usage Context:**
/// - Video conference main room pagination
/// - Breakout room navigation with role-based access
/// - Multi-page participant gallery
/// - Host-controlled breakout session management
/// - Room-based content switching with server sync
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
    final List<int> pages =
        List<int>.generate(options.totalPages + 1, (index) => index);

    final BoxDecoration activeDecoration = BoxDecoration(
      color: options.activePageColor,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withAlpha((0.5 * 255).toInt()),
          spreadRadius: 1,
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    );

    final BoxDecoration inactiveDecoration = BoxDecoration(
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

    Widget buildPageButton(int page, BuildContext itemContext) {
      final bool isActive = page == options.currentUserPage;
      final bool isHomePage = page == 0;
      bool isLocked = false;

      String displayLabel = page.toString();
      final int mainRoomsLength = options.parameters.mainRoomsLength;
      final int targetPage = options.parameters.memberRoom;

      if (options.parameters.breakOutRoomStarted &&
          !options.parameters.breakOutRoomEnded &&
          page >= mainRoomsLength) {
        final int roomNumber = page - (mainRoomsLength - 1);

        if (targetPage + 1 != roomNumber) {
          final bool isHost = options.parameters.islevel == '2';
          if (!isHost) {
            displayLabel = 'Room $roomNumber 🔒';
            isLocked = true;
          } else {
            displayLabel = 'Room $roomNumber';
          }
        } else {
          displayLabel = 'Room $roomNumber';
        }
      } else {
        displayLabel = page.toString();
      }

      Widget baseContent;
      if (isHomePage) {
        baseContent = Icon(
          Icons.star,
          size: 18,
          color: isActive ? Colors.yellow : Colors.grey,
        );
      } else {
        baseContent = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Text(
            displayLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }

      final Widget resolvedContent = options.pageContentBuilder != null
          ? options.pageContentBuilder!(
              PaginationPageContentContext(
                context: itemContext,
                options: options,
                page: page,
                isActive: isActive,
                isHomePage: isHomePage,
                isLocked: isLocked,
                label: displayLabel,
                defaultContent: baseContent,
              ),
            )
          : baseContent;

      Future<void> onSelect() => handleClick(page, mainRoomsLength);

      final Widget defaultButton = GestureDetector(
        onTap: () async {
          if (!isActive) {
            await onSelect();
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          constraints: options.buttonsContainerStyle,
          decoration: isActive ? activeDecoration : inactiveDecoration,
          child: Center(child: resolvedContent),
        ),
      );

      if (options.pageButtonBuilder != null) {
        return options.pageButtonBuilder!(
          PaginationPageButtonContext(
            context: itemContext,
            options: options,
            page: page,
            isActive: isActive,
            isHomePage: isHomePage,
            isLocked: isLocked,
            content: resolvedContent,
            defaultButton: defaultButton,
            onSelect: onSelect,
          ),
        );
      }

      return defaultButton;
    }

    final Widget listView = ListView.builder(
      shrinkWrap: true,
      scrollDirection:
          options.direction == 'vertical' ? Axis.vertical : Axis.horizontal,
      itemCount: pages.length,
      itemBuilder: (itemContext, index) {
        final int page = pages[index];
        return buildPageButton(page, itemContext);
      },
    );

    final Widget defaultContainer = Container(
      color: options.backgroundColor,
      constraints: BoxConstraints(
        maxHeight: options.direction == 'vertical'
            ? double.infinity
            : options.paginationHeight,
        maxWidth: options.direction == 'horizontal'
            ? double.infinity
            : options.paginationHeight,
      ),
      child: Center(child: listView),
    );

    final Widget resolvedContainer = options.containerBuilder != null
        ? options.containerBuilder!(
            PaginationContainerContext(
              context: context,
              options: options,
              pages: pages,
              listView: listView,
              defaultContainer: defaultContainer,
            ),
          )
        : defaultContainer;

    return Visibility(
      visible: options.showAspect,
      child: resolvedContainer,
    );
  }
}
