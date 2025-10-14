import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/utils/get_modal_position.dart'
  show getModalPosition, GetModalPositionOptions;
import '../../methods/waiting_methods/respond_to_waiting.dart'
  show respondToWaiting, RespondToWaitingOptions;
import '../../types/modal_style_options.dart'
  show WaitingRoomModalStyleOptions;
import '../../types/types.dart'
  show WaitingRoomParticipant, RespondToWaitingType;

typedef WaitingRoomModalHeaderBuilder = Widget Function(
  WaitingRoomModalHeaderContext context);
typedef WaitingRoomModalSearchBuilder = Widget Function(
  WaitingRoomModalSearchContext context);
typedef WaitingRoomModalListBuilder = Widget Function(
  WaitingRoomModalListContext context);
typedef WaitingRoomModalItemBuilder = Widget Function(
  WaitingRoomModalItemContext context);
typedef WaitingRoomModalBodyBuilder = Widget Function(
  WaitingRoomModalBodyContext context);
typedef WaitingRoomModalContentBuilder = Widget Function(
  WaitingRoomModalContentContext context);

/// Additional parameters for the WaitingRoomModal.
abstract class WaitingRoomModalParameters {
  List<WaitingRoomParticipant> get waitingRoomList;
  List<WaitingRoomParticipant> get filteredWaitingRoomList;
  int get waitingRoomCounter;
  String get roomName;
  io.Socket? get socket;
  void Function(List<WaitingRoomParticipant>) get updateWaitingRoomList;

  /// Function to get updated parameters.
  WaitingRoomModalParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Configuration for the waiting-room modal enabling host to accept/reject participants queued for entry.
///
/// * **waitingRoomList** - Array of `WaitingRoomParticipant` objects; displayed in scrollable list.
/// * **waitingRoomCounter** - Count of participants in queue; shown in modal header.
/// * **onWaitingRoomItemPress** - Override for `respondToWaiting`; receives {participantId, participantName, updateWaitingList, waitingList, type, roomName, socket}. `type` is `'accepted'` (admit) or `'rejected'` (deny); emits `updateWaiting` socket event with action.
/// * **onWaitingRoomFilterChange** - Callback when search input changes; filters `waitingRoomList` by name.
/// * **updateWaitingList** - Updates `waitingRoomList` in parent state after admit/reject.
/// * **roomName** - Session identifier for socket event.
/// * **socket** - Socket.IO client for emitting `updateWaiting` event.
/// * **position** - Modal placement via `getModalPosition` (e.g., 'topRight').
/// * **backgroundColor** - Background color for modal container.
/// * **parameters** - Must expose `waitingRoomList`, `filteredWaitingRoomList`, `waitingRoomCounter`, `roomName`, `socket`, `updateWaitingRoomList`, `getUpdatedAllParams`.
/// * **styles** - Optional `WaitingRoomModalStyleOptions` for advanced theming.
/// * **title** / **emptyState** - Custom widgets for header and empty list placeholder.
/// * **headerBuilder** / **searchBuilder** / **listBuilder** / **itemBuilder** / **bodyBuilder** / **contentBuilder** - Builder hooks for granular customization.
///
/// ### Usage
/// 1. Modal displays header with "Waiting Room" title and counter badge.
/// 2. Search input filters `waitingRoomList` by participant name.
/// 3. Each participant row shows name with "Accept" (green) and "Reject" (red) buttons.
/// 4. "Accept" button calls `onWaitingRoomItemPress` with `type: 'accepted'`, emitting `updateWaiting` socket event with `{participantId, participantName, action: 'accepted', roomName}`.
/// 5. "Reject" button calls `onWaitingRoomItemPress` with `type: 'rejected'`, emitting `updateWaiting` socket event with `{participantId, participantName, action: 'rejected', roomName}`.
/// 6. After admit/reject, `updateWaitingList` removes participant from queue.
/// 7. Override via `MediasfuUICustomOverrides.waitingRoomModal` to inject custom admission logic, pre-admission surveys, or analytics tracking.
class WaitingRoomModalOptions {
  final bool isWaitingModalVisible;
  final VoidCallback onWaitingRoomClose;
  final int waitingRoomCounter;
  final Function(String) onWaitingRoomFilterChange;
  final List<WaitingRoomParticipant> waitingRoomList;
  final Function(List<WaitingRoomParticipant>) updateWaitingList;
  final String roomName;
  final io.Socket? socket;
  RespondToWaitingType onWaitingRoomItemPress;
  final String position; // e.g., "topRight"
  final Color backgroundColor;
  final WaitingRoomModalParameters parameters;
  final WaitingRoomModalStyleOptions? styles;
  final Widget? title;
  final Widget? emptyState;
  final WaitingRoomModalHeaderBuilder? headerBuilder;
  final WaitingRoomModalSearchBuilder? searchBuilder;
  final WaitingRoomModalListBuilder? listBuilder;
  final WaitingRoomModalItemBuilder? itemBuilder;
  final WaitingRoomModalBodyBuilder? bodyBuilder;
  final WaitingRoomModalContentBuilder? contentBuilder;

  WaitingRoomModalOptions({
    required this.isWaitingModalVisible,
    required this.onWaitingRoomClose,
    required this.waitingRoomCounter,
    required this.onWaitingRoomFilterChange,
    required this.waitingRoomList,
    required this.updateWaitingList,
    required this.roomName,
    this.socket,
    this.onWaitingRoomItemPress = respondToWaiting,
    this.position = "topRight",
    this.backgroundColor = const Color(0xFF83C0E9),
    required this.parameters,
    this.styles,
    this.title,
    this.emptyState,
    this.headerBuilder,
    this.searchBuilder,
    this.listBuilder,
    this.itemBuilder,
    this.bodyBuilder,
    this.contentBuilder,
  });
}

typedef WaitingRoomModalType = WaitingRoomModal Function({
  Key? key,
  required WaitingRoomModalOptions options,
});

/// Waiting-room modal displaying queued participants with accept/reject actions (host-only).
///
/// * Displays scrollable list of `WaitingRoomParticipant` objects from `waitingRoomList`.
/// * Header shows "Waiting Room" title with counter badge (`waitingRoomCounter`).
/// * Search input filters list by participant name via `onWaitingRoomFilterChange`.
/// * Each participant row shows name with "Accept" (green checkmark) and "Reject"
///   (red X) icon buttons.
/// * "Accept" calls `onWaitingRoomItemPress` with `type: 'accepted'`, which emits
///   `updateWaiting` socket event with `{participantId, participantName, action: 'accepted', roomName}`,
///   then removes participant from `waitingRoomList` via `updateWaitingList`.
/// * "Reject" calls `onWaitingRoomItemPress` with `type: 'rejected'`, emitting
///   `updateWaiting` event with `action: 'rejected'`, then removes from queue.
/// * Empty state shows "No participants in waiting room" when list is empty.
/// * Positions via `getModalPosition` using `options.position`.
/// * Offers six builder hooks (`headerBuilder`, `searchBuilder`, `listBuilder`,
///   `itemBuilder`, `bodyBuilder`, `contentBuilder`) for granular customization.
///
/// Override via `MediasfuUICustomOverrides.waitingRoomModal` to inject custom
/// admission logic, pre-admission surveys, or analytics tracking.
/// ```
///
/// ### Functional Details:
/// - The `filterWaitingRoomList` method filters participants by a search query.
/// - `getModalTopPosition` and `getModalRightPosition` calculate positioning based on the `position` parameter in [options].
/// - Handles list updates dynamically and reflects changes in the counter displayed on the modal header.

class WaitingRoomModal extends StatelessWidget {
  final WaitingRoomModalOptions options;

  const WaitingRoomModal({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final styles = options.styles ?? const WaitingRoomModalStyleOptions();
    final mediaSize = MediaQuery.of(context).size;

    final defaultWidth = math.min(mediaSize.width * 0.8, 350.0);
    double modalWidth = styles.width ?? defaultWidth;
    if (styles.maxWidth != null) {
      modalWidth = math.min(modalWidth, styles.maxWidth!);
    }

    final defaultHeight = mediaSize.height * 0.65;
    double modalHeight = styles.height ?? defaultHeight;
    if (styles.maxHeight != null) {
      modalHeight = math.min(modalHeight, styles.maxHeight!);
    }

    final positionData = getModalPosition(
      GetModalPositionOptions(
        position: options.position,
        modalWidth: modalWidth,
        modalHeight: modalHeight,
        context: context,
      ),
    );

    final params = options.parameters.getUpdatedAllParams();
  final baseList = params.filteredWaitingRoomList.isNotEmpty
        ? params.filteredWaitingRoomList
        : (params.waitingRoomList.isNotEmpty
            ? params.waitingRoomList
            : options.waitingRoomList);
    final waitingList = List<WaitingRoomParticipant>.from(baseList);
  final fallbackCounter = params.waitingRoomCounter >
      options.waitingRoomCounter
    ? params.waitingRoomCounter
    : options.waitingRoomCounter;
  final waitingCounter =
    waitingList.isNotEmpty ? waitingList.length : fallbackCounter;

    Future<void> handleResponse(
        WaitingRoomParticipant participant, bool accepted) async {
      await options.onWaitingRoomItemPress(
        options: RespondToWaitingOptions(
          participantId: participant.id,
          participantName: participant.name,
          updateWaitingList: params.updateWaitingRoomList,
          waitingList: params.waitingRoomList,
          roomName: params.roomName,
          socket: params.socket,
          type: accepted,
        ),
      );
    }

    final counterBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: styles.counterDecoration ??
          BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
      child: Text(
        waitingCounter.toString(),
        style: styles.counterTextStyle ??
            const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
      ),
    );

    final headerTitle = options.title ??
        Text(
          'Waiting',
          style: styles.titleTextStyle ??
              const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        );

    final header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            headerTitle,
            const SizedBox(width: 8),
            counterBadge,
          ],
        ),
        IconButton(
          onPressed: options.onWaitingRoomClose,
          icon: styles.closeIcon ??
              const Icon(
                Icons.close,
                size: 20,
                color: Colors.black,
              ),
          style: styles.closeButtonStyle,
        ),
      ],
    );

    final resolvedHeader = options.headerBuilder?.call(
          WaitingRoomModalHeaderContext(
            defaultHeader: header,
            counter: waitingCounter,
            onClose: options.onWaitingRoomClose,
          ),
        ) ??
        header;

    final searchField = TextField(
      decoration: styles.searchInputDecoration ??
          const InputDecoration(
            hintText: 'Search ...',
            border: OutlineInputBorder(),
          ),
      style: styles.searchInputTextStyle,
      onChanged: options.onWaitingRoomFilterChange,
    );

    final resolvedSearch = options.searchBuilder?.call(
          WaitingRoomModalSearchContext(
            defaultSearch: searchField,
            onFilter: options.onWaitingRoomFilterChange,
          ),
        ) ??
        searchField;

    Widget buildParticipantItem(WaitingRoomParticipant participant) {
      void onAccept() {
        handleResponse(participant, true);
      }

      void onReject() {
        handleResponse(participant, false);
      }

      final row = Row(
        children: [
          Expanded(
            child: Text(
              participant.name,
              style: styles.participantNameTextStyle ??
                  const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onAccept,
            style: styles.acceptButtonStyle,
            icon: styles.acceptIcon ??
                const Icon(
                  Icons.check,
                  color: Colors.green,
                ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onReject,
            style: styles.rejectButtonStyle,
            icon: styles.rejectIcon ??
                const Icon(
                  Icons.close,
                  color: Colors.red,
                ),
          ),
        ],
      );

      final defaultItem = Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: row,
      );

      return options.itemBuilder?.call(
            WaitingRoomModalItemContext(
              defaultItem: defaultItem,
              participant: participant,
              onAccept: onAccept,
              onReject: onReject,
            ),
          ) ??
          defaultItem;
    }

    final listWidget = waitingList.isEmpty
        ? Center(
            child: options.emptyState ??
                Text(
                  'No participants in waiting room',
                  style: styles.bodyTextStyle ??
                      const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                  textAlign: TextAlign.center,
                ),
          )
        : ListView.separated(
            padding: styles.listPadding ??
                const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            itemCount: waitingList.length,
            itemBuilder: (context, index) =>
                buildParticipantItem(waitingList[index]),
            separatorBuilder: (context, index) => const SizedBox(height: 8),
          );

    final resolvedList = options.listBuilder?.call(
          WaitingRoomModalListContext(
            defaultList: listWidget,
            participants: waitingList,
            counter: waitingCounter,
          ),
        ) ??
        listWidget;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        resolvedSearch,
        const SizedBox(height: 12),
        Expanded(child: resolvedList),
      ],
    );

    final resolvedBody = options.bodyBuilder?.call(
          WaitingRoomModalBodyContext(
            defaultBody: body,
            counter: waitingCounter,
          ),
        ) ??
        body;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        resolvedHeader,
        Divider(
          color: styles.dividerColor ?? Colors.black,
          height: styles.dividerHeight ?? 16,
          thickness: styles.dividerThickness ?? 1,
          indent: styles.dividerIndent,
          endIndent: styles.dividerEndIndent,
        ),
        const SizedBox(height: 8),
        Expanded(child: resolvedBody),
      ],
    );

    final resolvedContent = options.contentBuilder?.call(
          WaitingRoomModalContentContext(
            defaultContent: content,
            counter: waitingCounter,
          ),
        ) ??
        content;

    final outerDecoration = styles.outerContainerDecoration ??
        BoxDecoration(
          color: options.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        );

    final innerDecoration = styles.contentDecoration ??
        BoxDecoration(
          color: options.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        );

    return Visibility(
      visible: options.isWaitingModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: positionData['top'],
            right: positionData['right'],
            child: Container(
              width: modalWidth,
              height: modalHeight,
              decoration: outerDecoration,
              padding: styles.outerPadding ?? const EdgeInsets.all(10),
              child: DecoratedBox(
                decoration: innerDecoration,
                child: Padding(
                  padding:
                      styles.contentPadding ?? const EdgeInsets.all(16),
                  child: resolvedContent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaitingRoomModalHeaderContext {
  final Widget defaultHeader;
  final int counter;
  final VoidCallback onClose;

  const WaitingRoomModalHeaderContext({
    required this.defaultHeader,
    required this.counter,
    required this.onClose,
  });
}

class WaitingRoomModalSearchContext {
  final Widget defaultSearch;
  final ValueChanged<String> onFilter;

  const WaitingRoomModalSearchContext({
    required this.defaultSearch,
    required this.onFilter,
  });
}

class WaitingRoomModalListContext {
  final Widget defaultList;
  final List<WaitingRoomParticipant> participants;
  final int counter;

  const WaitingRoomModalListContext({
    required this.defaultList,
    required this.participants,
    required this.counter,
  });
}

class WaitingRoomModalItemContext {
  final Widget defaultItem;
  final WaitingRoomParticipant participant;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const WaitingRoomModalItemContext({
    required this.defaultItem,
    required this.participant,
    required this.onAccept,
    required this.onReject,
  });
}

class WaitingRoomModalBodyContext {
  final Widget defaultBody;
  final int counter;

  const WaitingRoomModalBodyContext({
    required this.defaultBody,
    required this.counter,
  });
}

class WaitingRoomModalContentContext {
  final Widget defaultContent;
  final int counter;

  const WaitingRoomModalContentContext({
    required this.defaultContent,
    required this.counter,
  });
}
