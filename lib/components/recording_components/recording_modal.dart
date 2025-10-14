import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'standard_panel_component.dart'
    show
        StandardPanelComponent,
        StandardPanelComponentOptions,
        StandardPanelComponentParameters;
import 'advanced_panel_component.dart'
    show
        AdvancedPanelComponent,
        AdvancedPanelComponentOptions,
        AdvancedPanelComponentParameters;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/types.dart'
    show
        ConfirmRecordingType,
        StartRecordingType,
        StartRecordingOptions,
        ConfirmRecordingOptions,
        ConfirmRecordingParameters,
        StartRecordingParameters,
        EventType;
import '../../types/modal_style_options.dart' show ModalStyleOptions;

/// Abstract class `RecordingModalParameters` defines recording configuration parameters
/// and provides abstract getters for settings like video type, display type, background color,
/// and additional properties for recording customization.
///
/// The class also provides update functions for each setting, enabling real-time updates
/// and customization of recording behavior within the modal.
abstract class RecordingModalParameters
    implements
        ConfirmRecordingParameters,
        StartRecordingParameters,
        StandardPanelComponentParameters,
        AdvancedPanelComponentParameters {
  bool get recordPaused;
  String get recordingVideoType;
  String get recordingDisplayType;
  String get recordingBackgroundColor;
  String get recordingNameTagsColor;
  String get recordingOrientationVideo;
  bool get recordingNameTags;
  bool get recordingAddText;
  String get recordingCustomText;
  String get recordingCustomTextPosition;
  String get recordingCustomTextColor;
  String get recordingMediaOptions;
  String get recordingAudioOptions;
  String get recordingVideoOptions;
  bool get recordingAddHLS;
  EventType get eventType;

  // Update functions as abstract getters returning functions
  void Function(String) get updateRecordingVideoType;
  void Function(String) get updateRecordingDisplayType;
  void Function(String) get updateRecordingBackgroundColor;
  void Function(String) get updateRecordingNameTagsColor;
  void Function(String) get updateRecordingOrientationVideo;
  void Function(bool) get updateRecordingNameTags;
  void Function(bool) get updateRecordingAddText;
  void Function(String) get updateRecordingCustomText;
  void Function(String) get updateRecordingCustomTextPosition;
  void Function(String) get updateRecordingCustomTextColor;
  void Function(String) get updateRecordingMediaOptions;
  void Function(String) get updateRecordingAudioOptions;
  void Function(String) get updateRecordingVideoOptions;
  void Function(bool) get updateRecordingAddHLS;

  // Method to retrieve updated parameters as an abstract getter
  RecordingModalParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Configuration for the recording modal enabling server-side capture with comprehensive layout/styling options.
///
/// * **confirmRecording** - Override for `confirmRecording`; receives {parameters}. Called when user taps "Confirm" to commit current settings before starting.
/// * **startRecording** - Override for `startRecording`; receives {parameters}. Called when user taps "Start Recording" after confirmation; emits socket event to initiate server-side capture.
/// * **parameters** - Must expose `recordingVideoType` (`'video'`/`'media'`/`'all'`), `recordingDisplayType` (`'video'`/`'media'`/`'all'`), `recordingBackgroundColor`, `recordingNameTagsColor`, `recordingOrientationVideo` (`'landscape'`/`'portrait'`/`'all'`), `recordingNameTags`, `recordingAddText`, `recordingCustomText`, `recordingCustomTextPosition`, `recordingCustomTextColor`, `recordingMediaOptions` (`'video'`/`'audio'`), `recordingAudioOptions` (`'all'`/`'onScreen'`/`'host'`), `recordingVideoOptions` (`'all'`/`'mainScreen'`), `recordingAddHLS`, `eventType`, and `recordPaused`.
/// * **position** - Modal placement via `getModalPosition` (e.g., 'bottomRight').
/// * **backgroundColor** - Background color for modal container.
/// * **styles** - Optional `ModalStyleOptions` for advanced theming (padding, border radius, etc.).
/// * **title** / **confirmButtonChild** / **startButtonChild** - Custom widgets for header and action buttons.
///
/// ### Usage
/// 1. Modal displays two tabs: "Basic" (`StandardPanelComponent`) and "Advanced" (`AdvancedPanelComponent`).
/// 2. Basic tab: `recordingVideoType`, `recordingDisplayType`, `recordingBackgroundColor`, `recordingNameTagsColor`, `recordingOrientationVideo` dropdowns; `recordingNameTags` switch.
/// 3. Advanced tab: `recordingAddText` switch, `recordingCustomText` input, `recordingCustomTextPosition`/`recordingCustomTextColor` dropdowns; `recordingMediaOptions`, `recordingAudioOptions`, `recordingVideoOptions`, `recordingAddHLS` toggles.
/// 4. "Confirm" button validates settings and calls `confirmRecording`, updating parameters; "Start Recording" button enabled after confirmation, invokes `startRecording` which emits socket event.
/// 5. Override via `MediasfuUICustomOverrides.recordingModal` to inject watermark preview, compliance warnings, or custom encoding presets.
class RecordingModalOptions {
  final bool isRecordingModalVisible;
  final VoidCallback onClose;
  final Color backgroundColor;
  final String position;
  final ConfirmRecordingType confirmRecording;
  final StartRecordingType startRecording;
  final RecordingModalParameters parameters;
  final ModalStyleOptions? styles;
  final Widget? title;
  final Widget? confirmButtonChild;
  final Widget? startButtonChild;

  RecordingModalOptions({
    required this.isRecordingModalVisible,
    required this.onClose,
    this.backgroundColor = const Color(0xFF83C0E9),
    this.position = 'bottomRight',
    required this.confirmRecording,
    required this.startRecording,
    required this.parameters,
    this.styles,
    this.title,
    this.confirmButtonChild,
    this.startButtonChild,
  });
}

typedef RecordingModalType = Widget Function(
    {required RecordingModalOptions options});

/// Server-side recording configuration modal with basic/advanced layout tabs.
///
/// * Displays `StandardPanelComponent` (basic tab) and `AdvancedPanelComponent`
///   (advanced tab) for comprehensive recording customization.
/// * Basic settings: `recordingVideoType` (`'video'`/`'media'`/`'all'`),
///   `recordingDisplayType`, `recordingBackgroundColor`, `recordingNameTagsColor`,
///   `recordingOrientationVideo` (`'landscape'`/`'portrait'`/`'all'`), `recordingNameTags` toggle.
/// * Advanced settings: `recordingAddText` toggle, `recordingCustomText` input,
///   `recordingCustomTextPosition`/`recordingCustomTextColor`, `recordingMediaOptions`
///   (`'video'`/`'audio'`), `recordingAudioOptions` (`'all'`/`'onScreen'`/`'host'`),
///   `recordingVideoOptions` (`'all'`/`'mainScreen'`), `recordingAddHLS` toggle.
/// * "Confirm" button validates settings and calls `confirmRecording`, persisting
///   choices to parameters; "Start Recording" button (enabled after confirm) invokes
///   `startRecording`, which emits `startRecordClient` socket event to initiate
///   server-side capture.
/// * Positions via `getModalPosition` using `options.position`.
///
/// Override via `MediasfuUICustomOverrides.recordingModal` to inject watermark
/// preview, compliance warnings, or custom encoding presets.
class RecordingModal extends StatelessWidget {
  final RecordingModalOptions options;

  const RecordingModal({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final style = options.styles ?? const ModalStyleOptions();
    final mediaSize = MediaQuery.of(context).size;

    final defaultModalWidth = math.min(mediaSize.width * 0.75, 400.0);
    double modalWidth = style.width ?? defaultModalWidth;
    if (style.maxWidth != null) {
      modalWidth = math.min(modalWidth, style.maxWidth!);
    }

    final defaultModalHeight = mediaSize.height * 0.75;
    double modalHeight = style.height ?? defaultModalHeight;
    if (style.maxHeight != null) {
      modalHeight = math.min(modalHeight, style.maxHeight!);
    }

    final positionData = getModalPosition(GetModalPositionOptions(
      position: options.position,
      modalWidth: modalWidth,
      modalHeight: modalHeight,
      context: context,
    ));

    final outerDecoration = style.outerContainerDecoration ??
        BoxDecoration(
          color: options.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            options.title ??
                Text(
                  'Recording Settings',
                  style: style.titleTextStyle ??
                      const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                ),
            IconButton(
              onPressed: options.onClose,
              icon: style.closeIcon ??
                  const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.black,
                  ),
              style: style.closeButtonStyle,
            ),
          ],
        ),
        const SizedBox(height: 15),
        Divider(
          height: style.dividerHeight ?? 1,
          color: style.dividerColor ?? Colors.black,
          thickness: style.dividerThickness ?? 1,
          indent: style.dividerIndent,
          endIndent: style.dividerEndIndent,
        ),
        const SizedBox(height: 15),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StandardPanelComponent(
                  options: StandardPanelComponentOptions(
                    parameters: options.parameters,
                  ),
                ),
                AdvancedPanelComponent(
                  options: AdvancedPanelComponentOptions(
                    parameters: options.parameters,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                options.confirmRecording(
                  ConfirmRecordingOptions(
                    parameters: options.parameters,
                  ),
                );
              },
              style: style.destructiveButtonStyle ??
                  ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: Colors.red,
                  ),
              child: options.confirmButtonChild ??
                  const Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
            ),
            if (!options.parameters.recordPaused)
              ElevatedButton(
                onPressed: () {
                  options.startRecording(
                    StartRecordingOptions(
                      parameters: options.parameters,
                    ),
                  );
                },
                style: style.primaryButtonStyle ??
                    ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Colors.green,
                    ),
                child: options.startButtonChild ??
                    const Row(
                      children: [
                        Text(
                          'Start ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
              ),
          ],
        ),
      ],
    );

    return Visibility(
      visible: options.isRecordingModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: positionData['top'],
            right: positionData['right'],
            child: Container(
              width: modalWidth,
              height: modalHeight,
              decoration: outerDecoration,
              padding: style.outerPadding ?? EdgeInsets.zero,
              child: DecoratedBox(
                decoration: style.contentDecoration ?? const BoxDecoration(),
                child: Padding(
                  padding: style.contentPadding ?? const EdgeInsets.all(20),
                  child: content,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
