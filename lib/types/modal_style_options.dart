import 'package:flutter/material.dart';

/// Render mode for modal components.
/// - `modal`: Traditional overlay modal with positioning, header, and close button
/// - `sidebar`: Inline content for desktop sidebar (no overlay, no header, full width)
/// - `inline`: Embedded content without modal wrapper (no positioning)
enum ModalRenderMode {
  /// Traditional overlay modal with positioning, header, and close button
  modal,

  /// Inline content for desktop sidebar (no overlay, no header, fills container)
  sidebar,

  /// Embedded content without modal wrapper (no positioning)
  inline,
}

/// Base styling options that can be shared across MediaSFU modal widgets.
class ModalStyleOptions {
  final BoxDecoration? outerContainerDecoration;
  final EdgeInsetsGeometry? outerPadding;
  final BoxDecoration? contentDecoration;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? titleTextStyle;
  final Widget? closeIcon;
  final ButtonStyle? closeButtonStyle;
  final Color? dividerColor;
  final double? dividerThickness;
  final double? dividerHeight;
  final double? dividerIndent;
  final double? dividerEndIndent;
  final double? width;
  final double? maxWidth;
  final double? height;
  final double? maxHeight;
  final TextStyle? sectionTitleTextStyle;
  final TextStyle? bodyTextStyle;
  final TextStyle? emptyStateTextStyle;
  final ButtonStyle? primaryButtonStyle;
  final ButtonStyle? secondaryButtonStyle;
  final ButtonStyle? destructiveButtonStyle;

  const ModalStyleOptions({
    this.outerContainerDecoration,
    this.outerPadding,
    this.contentDecoration,
    this.contentPadding,
    this.titleTextStyle,
    this.closeIcon,
    this.closeButtonStyle,
    this.dividerColor,
    this.dividerThickness,
    this.dividerHeight,
    this.dividerIndent,
    this.dividerEndIndent,
    this.width,
    this.maxWidth,
    this.height,
    this.maxHeight,
    this.sectionTitleTextStyle,
    this.bodyTextStyle,
    this.emptyStateTextStyle,
    this.primaryButtonStyle,
    this.secondaryButtonStyle,
    this.destructiveButtonStyle,
  });
}

/// Styling extensions specific to the poll modal surface.
class PollModalStyleOptions extends ModalStyleOptions {
  final InputDecoration? questionInputDecoration;
  final TextStyle? questionInputTextStyle;
  final InputDecoration? optionInputDecoration;
  final TextStyle? optionInputTextStyle;
  final TextStyle? pollItemQuestionTextStyle;
  final TextStyle? pollResultTextStyle;
  final TextStyle? pollOptionPreviewTextStyle;
  final TextStyle? currentPollOptionTextStyle;
  final ButtonStyle? createButtonStyle;
  final ButtonStyle? endButtonStyle;
  final ButtonStyle? voteButtonStyle;
  final TextStyle? dropdownTextStyle;
  final String? questionLabelText;
  final String Function(int index)? optionLabelBuilder;

  const PollModalStyleOptions({
    super.outerContainerDecoration,
    super.outerPadding,
    super.contentDecoration,
    super.contentPadding,
    super.titleTextStyle,
    super.closeIcon,
    super.closeButtonStyle,
    super.dividerColor,
    super.dividerThickness,
    super.dividerHeight,
    super.dividerIndent,
    super.dividerEndIndent,
    super.width,
    super.maxWidth,
    super.height,
    super.maxHeight,
    super.sectionTitleTextStyle,
    super.bodyTextStyle,
    super.emptyStateTextStyle,
    super.primaryButtonStyle,
    super.secondaryButtonStyle,
    super.destructiveButtonStyle,
    this.questionInputDecoration,
    this.questionInputTextStyle,
    this.optionInputDecoration,
    this.optionInputTextStyle,
    this.pollItemQuestionTextStyle,
    this.pollResultTextStyle,
    this.pollOptionPreviewTextStyle,
    this.currentPollOptionTextStyle,
    this.createButtonStyle,
    this.endButtonStyle,
    this.voteButtonStyle,
    this.dropdownTextStyle,
    this.questionLabelText,
    this.optionLabelBuilder,
  });
}

/// Styling options specific to the participants modal surface.
class ParticipantsModalStyleOptions extends ModalStyleOptions {
  final BoxDecoration? counterDecoration;
  final TextStyle? counterTextStyle;
  final InputDecoration? searchInputDecoration;
  final TextStyle? searchInputTextStyle;
  final EdgeInsetsGeometry? listPadding;
  final TextStyle? listItemTextStyle;
  final TextStyle? listSectionHeaderTextStyle;

  const ParticipantsModalStyleOptions({
    super.outerContainerDecoration,
    super.outerPadding,
    super.contentDecoration,
    super.contentPadding,
    super.titleTextStyle,
    super.closeIcon,
    super.closeButtonStyle,
    super.dividerColor,
    super.dividerThickness,
    super.dividerHeight,
    super.dividerIndent,
    super.dividerEndIndent,
    super.width,
    super.maxWidth,
    super.height,
    super.maxHeight,
    super.sectionTitleTextStyle,
    super.bodyTextStyle,
    super.primaryButtonStyle,
    super.secondaryButtonStyle,
    super.destructiveButtonStyle,
    this.counterDecoration,
    this.counterTextStyle,
    this.searchInputDecoration,
    this.searchInputTextStyle,
    this.listPadding,
    this.listItemTextStyle,
    this.listSectionHeaderTextStyle,
  });
}

/// Styling options specific to the waiting room modal surface.
class WaitingRoomModalStyleOptions extends ModalStyleOptions {
  final BoxDecoration? counterDecoration;
  final TextStyle? counterTextStyle;
  final InputDecoration? searchInputDecoration;
  final TextStyle? searchInputTextStyle;
  final EdgeInsetsGeometry? listPadding;
  final TextStyle? participantNameTextStyle;
  final ButtonStyle? acceptButtonStyle;
  final ButtonStyle? rejectButtonStyle;
  final Widget? acceptIcon;
  final Widget? rejectIcon;

  const WaitingRoomModalStyleOptions({
    super.outerContainerDecoration,
    super.outerPadding,
    super.contentDecoration,
    super.contentPadding,
    super.titleTextStyle,
    super.closeIcon,
    super.closeButtonStyle,
    super.dividerColor,
    super.dividerThickness,
    super.dividerHeight,
    super.dividerIndent,
    super.dividerEndIndent,
    super.width,
    super.maxWidth,
    super.height,
    super.maxHeight,
    super.sectionTitleTextStyle,
    super.bodyTextStyle,
    super.primaryButtonStyle,
    super.secondaryButtonStyle,
    super.destructiveButtonStyle,
    this.counterDecoration,
    this.counterTextStyle,
    this.searchInputDecoration,
    this.searchInputTextStyle,
    this.listPadding,
    this.participantNameTextStyle,
    this.acceptButtonStyle,
    this.rejectButtonStyle,
    this.acceptIcon,
    this.rejectIcon,
  });
}

/// Styling options specific to the confirm-here modal surface.
class ConfirmHereModalStyleOptions extends ModalStyleOptions {
  final Color? overlayColor;
  final double? maxContentWidth;
  final TextStyle? messageTextStyle;
  final TextStyle? countdownTextStyle;
  final TextStyle? countdownValueTextStyle;
  final ButtonStyle? confirmButtonStyle;
  final Color? spinnerColor;
  final EdgeInsetsGeometry? bodySpacing;

  const ConfirmHereModalStyleOptions({
    super.outerContainerDecoration,
    super.outerPadding,
    super.contentDecoration,
    super.contentPadding,
    super.titleTextStyle,
    super.closeIcon,
    super.closeButtonStyle,
    super.dividerColor,
    super.dividerThickness,
    super.dividerHeight,
    super.dividerIndent,
    super.dividerEndIndent,
    super.width,
    super.maxWidth,
    super.height,
    super.maxHeight,
    super.sectionTitleTextStyle,
    super.bodyTextStyle,
    super.emptyStateTextStyle,
    super.primaryButtonStyle,
    super.secondaryButtonStyle,
    super.destructiveButtonStyle,
    this.overlayColor,
    this.maxContentWidth,
    this.messageTextStyle,
    this.countdownTextStyle,
    this.countdownValueTextStyle,
    this.confirmButtonStyle,
    this.spinnerColor,
    this.bodySpacing,
  });
}

/// Styling options specific to the share event modal surface.
class ShareEventModalStyleOptions extends ModalStyleOptions {
  final TextStyle? passcodeLabelTextStyle;
  final TextStyle? passcodeInputTextStyle;
  final Color? passcodeInputBackgroundColor;
  final TextStyle? meetingIdLabelTextStyle;
  final TextStyle? meetingIdInputTextStyle;
  final Color? meetingIdInputBackgroundColor;
  final EdgeInsetsGeometry? infoSectionPadding;
  final EdgeInsetsGeometry? shareButtonsPadding;
  final BoxDecoration? shareButtonsDecoration;
  final EdgeInsetsGeometry? scrollPadding;
  final double? sectionSpacing;

  const ShareEventModalStyleOptions({
    super.outerContainerDecoration,
    super.outerPadding,
    super.contentDecoration,
    super.contentPadding,
    super.titleTextStyle,
    super.closeIcon,
    super.closeButtonStyle,
    super.dividerColor,
    super.dividerThickness,
    super.dividerHeight,
    super.dividerIndent,
    super.dividerEndIndent,
    super.width,
    super.maxWidth,
    super.height,
    super.maxHeight,
    super.sectionTitleTextStyle,
    super.bodyTextStyle,
    super.emptyStateTextStyle,
    super.primaryButtonStyle,
    super.secondaryButtonStyle,
    super.destructiveButtonStyle,
    this.passcodeLabelTextStyle,
    this.passcodeInputTextStyle,
    this.passcodeInputBackgroundColor,
    this.meetingIdLabelTextStyle,
    this.meetingIdInputTextStyle,
    this.meetingIdInputBackgroundColor,
    this.infoSectionPadding,
    this.shareButtonsPadding,
    this.shareButtonsDecoration,
    this.scrollPadding,
    this.sectionSpacing,
  });
}
