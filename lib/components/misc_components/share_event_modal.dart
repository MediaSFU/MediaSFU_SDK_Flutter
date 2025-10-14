import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../menu_components/share_buttons_component.dart'
    show ShareButtonsComponent, ShareButtonsComponentOptions;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../menu_components/meeting_passcode_component.dart'
    show MeetingPasscodeComponent, MeetingPasscodeComponentOptions;
import '../menu_components/meeting_id_component.dart'
    show MeetingIdComponent, MeetingIdComponentOptions;
import '../../types/modal_style_options.dart' show ShareEventModalStyleOptions;
import '../../types/types.dart' show EventType;

typedef ShareEventModalHeaderBuilder = Widget Function(
  ShareEventModalHeaderContext context);
typedef ShareEventModalPasscodeBuilder = Widget Function(
  ShareEventModalPasscodeContext context);
typedef ShareEventModalMeetingIdBuilder = Widget Function(
  ShareEventModalMeetingIdContext context);
typedef ShareEventModalShareButtonsBuilder = Widget Function(
  ShareEventModalShareButtonsContext context);
typedef ShareEventModalBodyBuilder = Widget Function(
  ShareEventModalBodyContext context);
typedef ShareEventModalContentBuilder = Widget Function(
  ShareEventModalContentContext context);
typedef ShareEventModalContainerBuilder = Widget Function(
  ShareEventModalContainerContext context);

/// Configuration object for [ShareEventModal].
///
/// Common properties include:
/// - `isShareEventModalVisible`: Controls modal visibility.
/// - `onShareEventClose`: Callback invoked when the modal is dismissed.
/// - `roomName` / `adminPasscode`: Meeting metadata displayed within the body.
/// - `shareButtons`: Toggles rendering of the share buttons section.
/// - `position`: Controls placement via [getModalPosition].
/// - `styles`: Optional [ShareEventModalStyleOptions] for fine-grained styling.
/// - Builder callbacks (`headerBuilder`, `bodyBuilder`, etc.) allow replacing
///   individual sections or wrapping the entire surface with custom widgets.

class ShareEventModalOptions {
  final Color backgroundColor;
  final bool isShareEventModalVisible;
  final VoidCallback onShareEventClose;
  final bool shareButtons;
  final String position;
  final String roomName;
  final String adminPasscode;
  final String islevel;
  final EventType eventType;
  final String? localLink;
  final ShareEventModalStyleOptions? styles;
  final Widget? title;
  final Widget? passcodeSection;
  final Widget? meetingIdSection;
  final Widget? shareButtonsSection;
  final ShareEventModalHeaderBuilder? headerBuilder;
  final ShareEventModalPasscodeBuilder? passcodeBuilder;
  final ShareEventModalMeetingIdBuilder? meetingIdBuilder;
  final ShareEventModalShareButtonsBuilder? shareButtonsBuilder;
  final ShareEventModalBodyBuilder? bodyBuilder;
  final ShareEventModalContentBuilder? contentBuilder;
  final ShareEventModalContainerBuilder? containerBuilder;

  ShareEventModalOptions({
    this.backgroundColor = const Color.fromRGBO(131, 192, 233, 0.25),
    required this.isShareEventModalVisible,
    required this.onShareEventClose,
    this.shareButtons = true,
    this.position = 'topRight',
    required this.roomName,
    required this.adminPasscode,
    required this.islevel,
    this.eventType = EventType.webinar,
    this.localLink,
    this.styles,
    this.title,
    this.passcodeSection,
    this.meetingIdSection,
    this.shareButtonsSection,
    this.headerBuilder,
    this.passcodeBuilder,
    this.meetingIdBuilder,
    this.shareButtonsBuilder,
    this.bodyBuilder,
    this.contentBuilder,
    this.containerBuilder,
  });
}

typedef ShareEventModalType = Widget Function(
    {required ShareEventModalOptions options});

class ShareEventModalHeaderContext {
  final Widget defaultHeader;
  final Widget title;
  final Widget closeButton;
  final VoidCallback onClose;

  const ShareEventModalHeaderContext({
    required this.defaultHeader,
    required this.title,
    required this.closeButton,
    required this.onClose,
  });
}

class ShareEventModalPasscodeContext {
  final Widget defaultPasscode;
  final String passcode;
  final bool isVisible;

  const ShareEventModalPasscodeContext({
    required this.defaultPasscode,
    required this.passcode,
    required this.isVisible,
  });
}

class ShareEventModalMeetingIdContext {
  final Widget defaultMeetingId;
  final String meetingId;

  const ShareEventModalMeetingIdContext({
    required this.defaultMeetingId,
    required this.meetingId,
  });
}

class ShareEventModalShareButtonsContext {
  final Widget defaultShareButtons;
  final bool isVisible;
  final String meetingId;
  final EventType eventType;
  final String? localLink;

  const ShareEventModalShareButtonsContext({
    required this.defaultShareButtons,
    required this.isVisible,
    required this.meetingId,
    required this.eventType,
    this.localLink,
  });
}

class ShareEventModalBodyContext {
  final Widget defaultBody;
  final Widget meetingIdSection;
  final Widget? passcodeSection;
  final Widget? shareButtonsSection;
  final bool showPasscode;
  final bool showShareButtons;
  final double sectionSpacing;

  const ShareEventModalBodyContext({
    required this.defaultBody,
    required this.meetingIdSection,
    required this.passcodeSection,
    required this.shareButtonsSection,
    required this.showPasscode,
    required this.showShareButtons,
    required this.sectionSpacing,
  });
}

class ShareEventModalContentContext {
  final Widget defaultContent;
  final Widget header;
  final Widget body;
  final double modalWidth;
  final double modalHeight;

  const ShareEventModalContentContext({
    required this.defaultContent,
    required this.header,
    required this.body,
    required this.modalWidth,
    required this.modalHeight,
  });
}

class ShareEventModalContainerContext {
  final Widget defaultContainer;
  final double modalWidth;
  final double modalHeight;
  final Map<String, double> position;
  final ShareEventModalOptions options;
  final ShareEventModalStyleOptions styles;
  final BuildContext context;

  const ShareEventModalContainerContext({
    required this.defaultContainer,
    required this.modalWidth,
    required this.modalHeight,
    required this.position,
    required this.options,
    required this.styles,
    required this.context,
  });
}

/// `ShareEventModal` is a modal widget that allows users to share event details,
/// copy meeting ID and passcode, and interact with sharing buttons.
///
/// Example usage:
/// ```dart
/// ShareEventModal(
///   options: ShareEventModalOptions(
///     isShareEventModalVisible: true,
///     onShareEventClose: () => print("Modal closed"),
///     roomName: "Room 1",
///     adminPasscode: "123456",
///     islevel: "2",
///     eventType: "webinar",
///     localLink: "https://example.com",
///   ),
/// );
/// ```

class ShareEventModal extends StatelessWidget {
  final ShareEventModalOptions options;

  const ShareEventModal({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final styles = options.styles ?? const ShareEventModalStyleOptions();

    final mediaSize = MediaQuery.of(context).size;
    final defaultWidth = math.min(mediaSize.width * 0.8, 400.0);
    double modalWidth = styles.width ?? defaultWidth;
    if (styles.maxWidth != null) {
      modalWidth = math.min(modalWidth, styles.maxWidth!);
    }

    final defaultHeight = mediaSize.height * 0.6;
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

    final sectionSpacing = styles.sectionSpacing ?? 20.0;

    final closeButton = IconButton(
      onPressed: options.onShareEventClose,
      icon: styles.closeIcon ?? const Icon(Icons.close),
      style: styles.closeButtonStyle,
    );

    final titleWidget = options.title ??
        (styles.titleTextStyle != null
            ? Text('Share Event', style: styles.titleTextStyle)
            : const SizedBox.shrink());

    Widget defaultHeader;
    if (titleWidget is SizedBox) {
      defaultHeader = Align(
        alignment: Alignment.centerRight,
        child: closeButton,
      );
    } else {
      defaultHeader = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(child: titleWidget),
          closeButton,
        ],
      );
    }

    final resolvedHeader = options.headerBuilder?.call(
          ShareEventModalHeaderContext(
            defaultHeader: defaultHeader,
            title: titleWidget,
            closeButton: closeButton,
            onClose: options.onShareEventClose,
          ),
        ) ??
        defaultHeader;

    final showPasscode = options.islevel == '2';

    Widget? passcodeSection;
    if (showPasscode) {
      final basePasscode = options.passcodeSection ??
          MeetingPasscodeComponent(
            options: MeetingPasscodeComponentOptions(
              meetingPasscode: options.adminPasscode,
              labelStyle: styles.passcodeLabelTextStyle,
              inputTextStyle: styles.passcodeInputTextStyle,
              inputBackgroundColor: styles.passcodeInputBackgroundColor,
            ),
          );

      final resolvedPasscode = options.passcodeBuilder?.call(
            ShareEventModalPasscodeContext(
              defaultPasscode: basePasscode,
              passcode: options.adminPasscode,
              isVisible: true,
            ),
          ) ??
          basePasscode;

      passcodeSection = styles.infoSectionPadding != null
          ? Padding(
              padding: styles.infoSectionPadding!,
              child: resolvedPasscode,
            )
          : resolvedPasscode;
    }

    final baseMeetingId = options.meetingIdSection ??
        MeetingIdComponent(
          options: MeetingIdComponentOptions(
            meetingID: options.roomName,
            labelStyle: styles.meetingIdLabelTextStyle,
            inputTextStyle: styles.meetingIdInputTextStyle,
            inputBackgroundColor: styles.meetingIdInputBackgroundColor,
          ),
        );

    final resolvedMeetingId = options.meetingIdBuilder?.call(
          ShareEventModalMeetingIdContext(
            defaultMeetingId: baseMeetingId,
            meetingId: options.roomName,
          ),
        ) ??
        baseMeetingId;

    final meetingIdSection = styles.infoSectionPadding != null
        ? Padding(
            padding: styles.infoSectionPadding!,
            child: resolvedMeetingId,
          )
        : resolvedMeetingId;

    Widget? shareButtonsSection;
    if (options.shareButtons) {
      final shareButtonsDefault = options.shareButtonsSection ??
          ShareButtonsComponent(
            options: ShareButtonsComponentOptions(
              meetingID: options.roomName,
              eventType: options.eventType,
              localLink: options.localLink,
            ),
          );

      Widget resolvedShareButtons = options.shareButtonsBuilder?.call(
            ShareEventModalShareButtonsContext(
              defaultShareButtons: shareButtonsDefault,
              isVisible: true,
              meetingId: options.roomName,
              eventType: options.eventType,
              localLink: options.localLink,
            ),
          ) ??
          shareButtonsDefault;

      if (styles.shareButtonsDecoration != null) {
        resolvedShareButtons = DecoratedBox(
          decoration: styles.shareButtonsDecoration!,
          child: Padding(
            padding: styles.shareButtonsPadding ?? EdgeInsets.zero,
            child: resolvedShareButtons,
          ),
        );
      } else if (styles.shareButtonsPadding != null) {
        resolvedShareButtons = Padding(
          padding: styles.shareButtonsPadding!,
          child: resolvedShareButtons,
        );
      }

      shareButtonsSection = resolvedShareButtons;
    }

    final sectionWidgets = <Widget>[
      if (passcodeSection != null) passcodeSection,
      meetingIdSection,
      if (shareButtonsSection != null) shareButtonsSection,
    ];

    final bodyChildren = <Widget>[];
    for (var i = 0; i < sectionWidgets.length; i++) {
      bodyChildren.add(sectionWidgets[i]);
      if (i < sectionWidgets.length - 1) {
        bodyChildren.add(SizedBox(height: sectionSpacing));
      }
    }

    final defaultBody = SingleChildScrollView(
      padding: styles.scrollPadding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: bodyChildren,
      ),
    );

    final resolvedBody = options.bodyBuilder?.call(
          ShareEventModalBodyContext(
            defaultBody: defaultBody,
            meetingIdSection: meetingIdSection,
            passcodeSection: passcodeSection,
            shareButtonsSection: shareButtonsSection,
            showPasscode: showPasscode,
            showShareButtons: options.shareButtons,
            sectionSpacing: sectionSpacing,
          ),
        ) ??
        defaultBody;

    final defaultContent = Column(
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
          ShareEventModalContentContext(
            defaultContent: defaultContent,
            header: resolvedHeader,
            body: resolvedBody,
            modalWidth: modalWidth,
            modalHeight: modalHeight,
          ),
        ) ??
        defaultContent;

    final contentDecoration = styles.contentDecoration ??
        BoxDecoration(
          color: options.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        );

    final contentPadding = styles.contentPadding ?? const EdgeInsets.all(10);

    final contentContainer = Container(
      padding: contentPadding,
      decoration: contentDecoration,
      child: resolvedContent,
    );

    Widget sizedContent = SizedBox(
      width: modalWidth,
      height: modalHeight,
      child: contentContainer,
    );

    if (styles.outerPadding != null || styles.outerContainerDecoration != null) {
      sizedContent = Container(
        padding: styles.outerPadding,
        decoration: styles.outerContainerDecoration,
        child: sizedContent,
      );
    }

    final resolvedContainer = options.containerBuilder?.call(
          ShareEventModalContainerContext(
            defaultContainer: sizedContent,
            modalWidth: modalWidth,
            modalHeight: modalHeight,
            position: positionData,
            options: options,
            styles: styles,
            context: context,
          ),
        ) ??
        sizedContent;

    return Visibility(
      visible: options.isShareEventModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: positionData['top'],
            right: positionData['right'],
            child: resolvedContainer,
          ),
        ],
      ),
    );
  }
}
