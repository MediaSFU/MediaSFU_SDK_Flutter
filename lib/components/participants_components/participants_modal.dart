// ignore_for_file: non_constant_identifier_names

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import './participant_list.dart'
    show ParticipantList, ParticipantListOptions, ParticipantListType;
import './participant_list_others.dart'
    show
        ParticipantListOthers,
        ParticipantListOthersOptions,
        ParticipantListOthersType;
import '../../methods/participants_methods/mute_participants.dart'
    show muteParticipants;
import '../../methods/participants_methods/message_participants.dart'
    show messageParticipants;
import '../../methods/participants_methods/remove_participants.dart'
    show removeParticipants;
import '../../types/types.dart'
    show
        ShowAlert,
        CoHostResponsibility,
        Participant,
        MuteParticipantsType,
        MessageParticipantsType,
        RemoveParticipantsType,
        EventType;
import '../../types/modal_style_options.dart'
    show ParticipantsModalStyleOptions;

typedef ParticipantsModalHeaderBuilder = Widget Function(
  ParticipantsModalHeaderContext context);
typedef ParticipantsModalSearchBuilder = Widget Function(
  ParticipantsModalSearchContext context);
typedef ParticipantsModalListsBuilder = Widget Function(
  ParticipantsModalListsContext context);
typedef ParticipantsModalBodyBuilder = Widget Function(
  ParticipantsModalBodyContext context);
typedef ParticipantsModalContentBuilder = Widget Function(
  ParticipantsModalContentContext context);

abstract class ParticipantsModalParameters {
  // Core properties as abstract getters
  List<CoHostResponsibility> get coHostResponsibility;
  String get coHost;
  String get member;
  String get islevel;
  List<Participant> get participants;
  List<Participant> get filteredParticipants;
  int get participantsCounter;
  EventType get eventType;
  io.Socket? get socket;
  ShowAlert? get showAlert;
  String get roomName;

  // Update functions as abstract getters returning functions
  void Function(bool) get updateIsMessagesModalVisible;
  void Function(Participant?) get updateDirectMessageDetails;
  void Function(bool) get updateStartDirectMessage;
  void Function(List<Participant>) get updateParticipants;

  // Method to retrieve updated parameters as an abstract getter
  ParticipantsModalParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Configuration payload for [ParticipantsModal].
///
/// Powers the participants list modal used throughout MediaSFU experiences,
/// exposing hooks for moderation actions and custom rendering layers:
///
/// * `isParticipantsModalVisible` / `onParticipantsClose`: control visibility
///   and handle dismissal.
/// * `onMuteParticipants`, `onMessageParticipants`, `onRemoveParticipants`:
///   optional function overrides for custom moderation workflows, analytics, or
///   permission checks before invoking the default handlers.
/// * `RenderParticipantList` / `RenderParticipantListOthers`: swap the default
///   participant list widgets to apply custom styling, sorting, or additional
///   columns.
/// * `position`: string (e.g., `'topRight'`, `'center'`) controlling modal
///   placement via `getModalPosition`.
/// * `styles`: optional [ParticipantsModalStyleOptions] for width, height,
///   decorations, and badge theming.
/// * Builder hooks (`headerBuilder`, `searchBuilder`, `listsBuilder`,
///   `bodyBuilder`, `contentBuilder`) let you wrap or replace individual
///   sections without reimplementing permission logic.
///
/// Use this options object via `MediasfuUICustomOverrides.participantsModal` to
/// deliver branded UX, integrate advanced filtering, or add participant notes.
class ParticipantsModalOptions {
  final bool isParticipantsModalVisible;
  final VoidCallback onParticipantsClose;
  final ValueChanged<String> onParticipantsFilterChange;
  final int participantsCounter;
  final MuteParticipantsType onMuteParticipants;
  final MessageParticipantsType onMessageParticipants;
  final RemoveParticipantsType onRemoveParticipants;
  final ParticipantListType RenderParticipantList;
  final ParticipantListOthersType RenderParticipantListOthers;
  final Color backgroundColor;
  final String position;
  final ParticipantsModalParameters parameters;
  final ParticipantsModalStyleOptions? styles;
  final Widget? title;
  final Widget? emptyState;
  final ParticipantsModalHeaderBuilder? headerBuilder;
  final ParticipantsModalSearchBuilder? searchBuilder;
  final ParticipantsModalListsBuilder? listsBuilder;
  final ParticipantsModalBodyBuilder? bodyBuilder;
  final ParticipantsModalContentBuilder? contentBuilder;

  ParticipantsModalOptions({
    required this.isParticipantsModalVisible,
    required this.onParticipantsClose,
    required this.onParticipantsFilterChange,
    required this.participantsCounter,
    this.onMuteParticipants = muteParticipants,
    this.onMessageParticipants = messageParticipants,
    this.onRemoveParticipants = removeParticipants,
    this.RenderParticipantList = defaultParticipantList,
    this.RenderParticipantListOthers = defaultParticipantListOthers,
    this.backgroundColor = const Color(0xFF83C0E9),
    this.position = 'topRight',
    required this.parameters,
    this.styles,
    this.title,
    this.emptyState,
    this.headerBuilder,
    this.searchBuilder,
    this.listsBuilder,
    this.bodyBuilder,
    this.contentBuilder,
  });

  // Default function for rendering participant list
  static Widget defaultParticipantList(
      {required ParticipantListOptions options}) {
    return ParticipantList(options: options);
  }

  // Default function for rendering participant list for others
  static Widget defaultParticipantListOthers(
      {required ParticipantListOthersOptions options}) {
    return ParticipantListOthers(options: options);
  }
}

typedef ParticipantsModalType = Widget Function(
    {required ParticipantsModalOptions options});

/// Modal dialog for viewing and managing session participants.
///
/// * Computes modal dimensions responsively (defaults to 80% width capped at
///   400px, 75% height) and positions via `getModalPosition`.
/// * Renders co-host/admin-level moderation actions (mute, message, remove)
///   when the current user has the appropriate permissions (`islevel == '2'` or
///   is a co-host with `participants` responsibility).
/// * Displays a search field for client-side filtering and a badge showing the
///   live participant count.
/// * Provides five builder hooks (`headerBuilder`, `searchBuilder`,
///   `listsBuilder`, `bodyBuilder`, `contentBuilder`) so you can inject custom
///   UI sections without re-implementing permission checks.
/// * Uses `RenderParticipantList` / `RenderParticipantListOthers` for the
///   actual row rendering, enabling custom styling or additional columns.
///
/// Override this component via `MediasfuUICustomOverrides.participantsModal` to
/// add advanced filters, participant notes, or integrate CRM data.
class ParticipantsModal extends StatelessWidget {
  final ParticipantsModalOptions options;

  const ParticipantsModal({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final styles = options.styles ?? const ParticipantsModalStyleOptions();
    final mediaSize = MediaQuery.of(context).size;

    final defaultModalWidth = math.min(mediaSize.width * 0.8, 400.0);
    double modalWidth = styles.width ?? defaultModalWidth;
    if (styles.maxWidth != null) {
      modalWidth = math.min(modalWidth, styles.maxWidth!);
    }

    final defaultModalHeight = mediaSize.height * 0.75;
    double modalHeight = styles.height ?? defaultModalHeight;
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
    final participantsList = params.filteredParticipants.isNotEmpty
        ? params.filteredParticipants
        : params.participants;
    final participantsCounter = participantsList.length;
    final islevel = params.islevel;
    final coHost = params.coHost;
    final member = params.member;
    final participantsValue = params.coHostResponsibility
        .any((item) => item.name == 'participants' && item.value);
    final canModerate = participantsList.isNotEmpty &&
        (islevel == '2' || (coHost == member && participantsValue));

    final counterBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: styles.counterDecoration ??
          BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
      child: Text(
        participantsCounter.toString(),
        style: styles.counterTextStyle ??
            const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
      ),
    );

    final headerTitle = options.title ??
        Text(
          'Participants',
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
          onPressed: options.onParticipantsClose,
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

    final defaultHeader = options.headerBuilder?.call(
          ParticipantsModalHeaderContext(
            defaultHeader: header,
            counter: participantsCounter,
            onClose: options.onParticipantsClose,
          ),
        ) ??
        header;

    final searchField = TextField(
      decoration: styles.searchInputDecoration ??
          const InputDecoration(
            hintText: 'Search ...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          ),
      style: styles.searchInputTextStyle,
      onChanged: options.onParticipantsFilterChange,
    );

    final resolvedSearch = options.searchBuilder?.call(
          ParticipantsModalSearchContext(
            defaultSearch: searchField,
            onFilter: options.onParticipantsFilterChange,
          ),
        ) ??
        searchField;

    Widget buildModeratorList() {
      return options.RenderParticipantList(
        options: ParticipantListOptions(
          participants: participantsList,
          isBroadcast: params.eventType == EventType.broadcast,
          onMuteParticipants: options.onMuteParticipants,
          onMessageParticipants: options.onMessageParticipants,
          onRemoveParticipants: options.onRemoveParticipants,
          socket: params.socket,
          coHostResponsibility: params.coHostResponsibility,
          member: params.member,
          islevel: params.islevel,
          showAlert: params.showAlert,
          coHost: params.coHost,
          roomName: params.roomName,
          updateIsMessagesModalVisible: params.updateIsMessagesModalVisible,
          updateDirectMessageDetails: params.updateDirectMessageDetails,
          updateStartDirectMessage: params.updateStartDirectMessage,
          updateParticipants: params.updateParticipants,
        ),
      );
    }

    Widget buildAttendeeList() {
      return options.RenderParticipantListOthers(
        options: ParticipantListOthersOptions(
          participants: participantsList,
          coHost: coHost,
          member: member,
        ),
      );
    }

    final lists = participantsList.isEmpty
        ? (options.emptyState ??
            Text(
              'No participants',
              style: styles.bodyTextStyle ??
                  const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
            ))
        : canModerate
            ? buildModeratorList()
            : buildAttendeeList();

    final listsContainer = Padding(
      padding: styles.listPadding ?? EdgeInsets.zero,
      child: lists,
    );

    final resolvedLists = options.listsBuilder?.call(
          ParticipantsModalListsContext(
            defaultLists: listsContainer,
            participants: participantsList,
            hasModeratorControls: canModerate,
          ),
        ) ??
        listsContainer;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        resolvedSearch,
        const SizedBox(height: 12),
        resolvedLists,
      ],
    );

    final resolvedBody = options.bodyBuilder?.call(
          ParticipantsModalBodyContext(
            defaultBody: body,
            counter: participantsCounter,
          ),
        ) ??
        body;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        defaultHeader,
        Divider(
          color: styles.dividerColor ?? Colors.black,
          height: styles.dividerHeight ?? 16,
          thickness: styles.dividerThickness ?? 1,
          indent: styles.dividerIndent,
          endIndent: styles.dividerEndIndent,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: resolvedBody,
          ),
        ),
      ],
    );

    final resolvedContent = options.contentBuilder?.call(
          ParticipantsModalContentContext(
            defaultContent: content,
            counter: participantsCounter,
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
      visible: options.isParticipantsModalVisible,
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

class ParticipantsModalHeaderContext {
  final Widget defaultHeader;
  final int counter;
  final VoidCallback onClose;

  const ParticipantsModalHeaderContext({
    required this.defaultHeader,
    required this.counter,
    required this.onClose,
  });
}

class ParticipantsModalSearchContext {
  final Widget defaultSearch;
  final ValueChanged<String> onFilter;

  const ParticipantsModalSearchContext({
    required this.defaultSearch,
    required this.onFilter,
  });
}

class ParticipantsModalListsContext {
  final Widget defaultLists;
  final List<Participant> participants;
  final bool hasModeratorControls;

  const ParticipantsModalListsContext({
    required this.defaultLists,
    required this.participants,
    required this.hasModeratorControls,
  });
}

class ParticipantsModalBodyContext {
  final Widget defaultBody;
  final int counter;

  const ParticipantsModalBodyContext({
    required this.defaultBody,
    required this.counter,
  });
}

class ParticipantsModalContentContext {
  final Widget defaultContent;
  final int counter;

  const ParticipantsModalContentContext({
    required this.defaultContent,
    required this.counter,
  });
}
