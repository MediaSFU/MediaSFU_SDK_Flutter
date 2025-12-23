import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../../methods/stream_methods/switch_video.dart'
    show
        switchVideo,
        SwitchVideoOptions,
        SwitchVideoParameters,
        SwitchVideoType;
import '../../methods/stream_methods/switch_audio.dart'
    show
        switchAudio,
        SwitchAudioOptions,
        SwitchAudioParameters,
        SwitchAudioType;
import '../../methods/stream_methods/switch_video_alt.dart'
    show
        switchVideoAlt,
        SwitchVideoAltOptions,
        SwitchVideoAltParameters,
        SwitchVideoAltType;
import '../../methods/stream_methods/switch_audio_output.dart'
    show switchAudioOutput, SwitchAudioOutputOptions;

class MediaSettingsModalWrapperContext {
  final BuildContext buildContext;
  final MediaSettingsModalOptions options;
  final MediaSettingsModalParameters parameters;
  final double modalWidth;
  final double modalHeight;
  final List<Widget> stackChildren;
  final Widget defaultWrapper;

  const MediaSettingsModalWrapperContext({
    required this.buildContext,
    required this.options,
    required this.parameters,
    required this.modalWidth,
    required this.modalHeight,
    required this.stackChildren,
    required this.defaultWrapper,
  });
}

class MediaSettingsModalContainerContext {
  final BuildContext buildContext;
  final MediaSettingsModalOptions options;
  final MediaSettingsModalParameters parameters;
  final double modalWidth;
  final double modalHeight;
  final Widget child;
  final Widget defaultContainer;

  const MediaSettingsModalContainerContext({
    required this.buildContext,
    required this.options,
    required this.parameters,
    required this.modalWidth,
    required this.modalHeight,
    required this.child,
    required this.defaultContainer,
  });
}

class MediaSettingsModalHeaderContext {
  final BuildContext buildContext;
  final MediaSettingsModalOptions options;
  final MediaSettingsModalParameters parameters;
  final Widget title;
  final Widget closeButton;
  final Widget defaultHeader;

  const MediaSettingsModalHeaderContext({
    required this.buildContext,
    required this.options,
    required this.parameters,
    required this.title,
    required this.closeButton,
    required this.defaultHeader,
  });
}

class MediaSettingsModalSectionContext {
  final BuildContext buildContext;
  final MediaSettingsModalOptions options;
  final MediaSettingsModalParameters parameters;
  final String label;
  final String type;
  final Widget dropdown;
  final Widget defaultSection;

  const MediaSettingsModalSectionContext({
    required this.buildContext,
    required this.options,
    required this.parameters,
    required this.label,
    required this.type,
    required this.dropdown,
    required this.defaultSection,
  });
}

class MediaSettingsModalDropdownContext {
  final BuildContext buildContext;
  final MediaSettingsModalOptions options;
  final MediaSettingsModalParameters parameters;
  final String type;
  final String? selectedValue;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final Widget defaultDropdown;

  const MediaSettingsModalDropdownContext({
    required this.buildContext,
    required this.options,
    required this.parameters,
    required this.type,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.defaultDropdown,
  });
}

class MediaSettingsModalButtonContext {
  final BuildContext buildContext;
  final MediaSettingsModalOptions options;
  final MediaSettingsModalParameters parameters;
  final VoidCallback onPressed;
  final Widget child;
  final Widget defaultButton;

  const MediaSettingsModalButtonContext({
    required this.buildContext,
    required this.options,
    required this.parameters,
    required this.onPressed,
    required this.child,
    required this.defaultButton,
  });
}

typedef MediaSettingsModalWrapperBuilder = Widget Function(
  MediaSettingsModalWrapperContext context,
);

typedef MediaSettingsModalContainerBuilder = Widget Function(
  MediaSettingsModalContainerContext context,
);

typedef MediaSettingsModalHeaderBuilder = Widget Function(
  MediaSettingsModalHeaderContext context,
);

typedef MediaSettingsModalSectionBuilder = Widget Function(
  MediaSettingsModalSectionContext context,
);

typedef MediaSettingsModalDropdownBuilder = Widget Function(
  MediaSettingsModalDropdownContext context,
);

typedef MediaSettingsModalButtonBuilder = Widget Function(
  MediaSettingsModalButtonContext context,
);

/// `MediaSettingsModalParameters` - Abstract class defining required parameters
/// for configuring media settings.
///
/// ### Abstract Getters:
/// - `userDefaultVideoInputDevice`: Default video input device ID.
/// - `userDefaultAudioInputDevice`: Default audio input device ID.
/// - `videoInputs`: List of available video input devices.
/// - `audioInputs`: List of available audio input devices.
/// - `isMediaSettingsModalVisible`: Boolean for media settings modal visibility.
/// - `updateIsMediaSettingsModalVisible`: Function to update visibility.
///
/// ### Example Usage:
/// ```dart
/// class CustomMediaSettingsModalParameters implements MediaSettingsModalParameters {
///   @override
///   String get userDefaultVideoInputDevice => 'default_video';
///   @override
///   String get userDefaultAudioInputDevice => 'default_audio';
///   // ... other implementations
/// }
/// ```
abstract class MediaSettingsModalParameters
    implements
        SwitchVideoParameters,
        SwitchAudioParameters,
        SwitchVideoAltParameters {
  String get userDefaultVideoInputDevice;
  String get userDefaultAudioInputDevice;
  List<MediaDeviceInfo> get videoInputs;
  List<MediaDeviceInfo> get audioInputs;
  bool get isMediaSettingsModalVisible;
  void Function(bool) get updateIsMediaSettingsModalVisible;

  /// Whether speakerphone is currently enabled (mobile only).
  bool get isSpeakerphoneOn;

  /// Callback to toggle speakerphone on/off.
  void Function(bool) get updateIsSpeakerphoneOn;

  /// Background modal visibility state for virtual backgrounds.
  bool get isBackgroundModalVisible;

  /// Callback to toggle the background modal visibility.
  void Function(bool) get updateIsBackgroundModalVisible;

  MediaSettingsModalParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Configuration for the media-device picker modal enabling camera/mic selection.
///
/// * **switchCameraOnPress** - Override for `switchVideoAlt`; receives {videoPreference, parameters}. Called when user taps "Switch Camera" (mobile).
/// * **switchVideoOnPress** - Override for `switchVideo`; receives {videoPreference, checkoff, parameters}. Called when dropdown selection changes for video device.
/// * **switchAudioOnPress** - Override for `switchAudio`; receives {audioPreference, parameters}. Called when dropdown selection changes for audio device.
/// * **parameters** - Must expose `userDefaultVideoInputDevice`, `userDefaultAudioInputDevice`, `videoInputs`, `audioInputs`, `isMediaSettingsModalVisible`, `updateIsMediaSettingsModalVisible`, and `getUpdatedAllParams`.
/// * **position** - Modal placement via `getModalPosition` (e.g., 'topRight').
/// * **backgroundColor** - Background color for modal container.
/// * **customBuilder** - Replace entire modal widget tree; receives `MediaSettingsModalOptions`.
/// * **wrapperBuilder** - Override top-level Stack; receives {stackChildren, defaultWrapper}.
/// * **containerBuilder** - Override modal container (positioned box); receives {child, defaultContainer}.
/// * **headerBuilder** - Override header bar; receives {title, closeButton, defaultHeader}.
/// * **sectionBuilder** - Override each device-picker section; receives {label, type, dropdown, defaultSection}.
/// * **dropdownBuilder** - Override DropdownButton widget; receives {type, selectedValue, items, onChanged, defaultDropdown}.
/// * **buttonBuilder** - Override "Switch Camera" button; receives {onPressed, child, defaultButton}.
/// * **containerPadding** / **containerMargin** / **containerAlignment** / **containerDecoration** - Fine-tune modal container styling.
/// * **titleTextStyle** / **labelTextStyle** - Typography overrides for title and section labels.
/// * **switchButtonStyle** / **switchButtonChild** - Customize "Switch Camera" button appearance.
///
/// Compatible with [ModernMediaSettingsModalOptions] from the modern component.
///
/// ### Usage
/// 1. Modal populates dropdowns from `parameters.videoInputs` and `parameters.audioInputs` (list of `MediaDeviceInfo`).
/// 2. Current selection defaults to `userDefaultVideoInputDevice` and `userDefaultAudioInputDevice`.
/// 3. Changing dropdown invokes `switchVideoOnPress` or `switchAudioOnPress`, which update state and switch tracks.
/// 4. "Switch Camera" button (mobile-only) cycles through front/back cameras via `switchCameraOnPress`.
/// 5. Override via `MediasfuUICustomOverrides.mediaSettingsModal` to inject permission checks, device aliases, or preview surfaces.
class MediaSettingsModalOptions {
  final bool isVisible;
  final VoidCallback onClose;
  final SwitchVideoAltType switchCameraOnPress;
  final SwitchVideoType switchVideoOnPress;
  final SwitchAudioType switchAudioOnPress;
  final MediaSettingsModalParameters parameters;
  final String position;
  final Color backgroundColor;
  final MediaSettingsModalType? customBuilder;
  final EdgeInsetsGeometry? containerPadding;
  final EdgeInsetsGeometry? containerMargin;
  final AlignmentGeometry? containerAlignment;
  final BoxDecoration? containerDecoration;
  final MediaSettingsModalWrapperBuilder? wrapperBuilder;
  final MediaSettingsModalContainerBuilder? containerBuilder;
  final MediaSettingsModalHeaderBuilder? headerBuilder;
  final MediaSettingsModalSectionBuilder? sectionBuilder;
  final MediaSettingsModalDropdownBuilder? dropdownBuilder;
  final MediaSettingsModalButtonBuilder? buttonBuilder;
  final TextStyle? titleTextStyle;
  final TextStyle? labelTextStyle;
  final ButtonStyle? switchButtonStyle;
  final Widget? switchButtonChild;

  /// Dark mode toggle for modern styling.
  /// Note: Pending modern implementation - placeholder for future glassmorphic UI.
  final bool isDarkMode;

  /// Enable glassmorphism effects for modern styling.
  /// Note: Pending modern implementation - placeholder for future glassmorphic UI.
  final bool enableGlassmorphism;

  /// Render mode for the modal (modal, sidebar, or inline).
  /// When set to `sidebar` or `inline`, returns content without modal wrapper.
  final ModalRenderMode renderMode;

  MediaSettingsModalOptions({
    required this.isVisible,
    required this.onClose,
    this.switchCameraOnPress = switchVideoAlt,
    this.switchVideoOnPress = switchVideo,
    this.switchAudioOnPress = switchAudio,
    required this.parameters,
    this.position = 'topRight',
    this.backgroundColor = Colors.blue,
    this.customBuilder,
    this.containerPadding,
    this.containerMargin,
    this.containerAlignment,
    this.containerDecoration,
    this.wrapperBuilder,
    this.containerBuilder,
    this.headerBuilder,
    this.sectionBuilder,
    this.dropdownBuilder,
    this.buttonBuilder,
    this.titleTextStyle,
    this.labelTextStyle,
    this.switchButtonStyle,
    this.switchButtonChild,
    this.isDarkMode = false,
    this.enableGlassmorphism = false,
    this.renderMode = ModalRenderMode.modal,
  });
}

typedef MediaSettingsModalType = MediaSettingsModal Function({
  required MediaSettingsModalOptions options,
});

/// `MediaSettingsModalOptions` - Configuration options for the `MediaSettingsModal`.
/// - `isVisible`: Boolean to control modal visibility.
/// - `onClose`: Callback function to handle modal close.
/// - `switchCameraOnPress`: Function to handle camera switch action.
/// - `switchVideoOnPress`: Function to handle video switch action.
/// - `switchAudioOnPress`: Function to handle audio switch action.
/// - `parameters`: Instance of `MediaSettingsModalParameters`.
/// - `position`: Modal position on the screen (e.g., 'topRight').
/// - `backgroundColor`: Background color of the modal.
///
/// ### Example Usage:
/// ```dart
/// MediaSettingsModal(
///   options: MediaSettingsModalOptions(
///     isVisible: true,
///     onClose: () => print("Modal closed"),
///     parameters: CustomMediaSettingsModalParameters(),
///     backgroundColor: Colors.blue,
///   ),
/// );
/// ```

/// Device-picker modal for camera/mic selection and mobile camera flipping.
///
/// * Builds dropdowns from `parameters.videoInputs` and `parameters.audioInputs`
///   (list of `MediaDeviceInfo` from `flutter_webrtc`).
/// * Current selection defaults to `userDefaultVideoInputDevice` and
///   `userDefaultAudioInputDevice`.
/// * Dropdown changes invoke `switchVideoOnPress` or `switchAudioOnPress`, which
///   call `switchVideo`/`switchAudio` to update tracks, then persist new deviceId
///   to `userDefaultVideoInputDevice`/`userDefaultAudioInputDevice`.
/// * "Switch Camera" button (mobile-only) calls `switchCameraOnPress` (defaults to
///   `switchVideoAlt`), toggling front/back cameras.
/// * Positions via `getModalPosition` using `options.position`.
/// * Offers seven builder hooks (`wrapperBuilder`, `containerBuilder`, `headerBuilder`,
///   `sectionBuilder`, `dropdownBuilder`, `buttonBuilder`) plus `customBuilder` for
///   full replacement, enabling custom device previews, permission prompts, or QR-based device linking.
///
/// Override via `MediasfuUICustomOverrides.mediaSettingsModal` to inject live
/// preview tiles, device aliases, or permission checks.
class MediaSettingsModal extends StatelessWidget {
  final MediaSettingsModalOptions options;

  const MediaSettingsModal({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    if (options.customBuilder != null) {
      return options.customBuilder!(options: options);
    }

    if (!options.isVisible) {
      return const SizedBox.shrink();
    }

    final parameters = options.parameters.getUpdatedAllParams();
    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = screenWidth * 0.8 > 400 ? 400.0 : screenWidth * 0.8;
    final modalHeight = MediaQuery.of(context).size.height * 0.65;

    final videoInputs = parameters.videoInputs;
    final audioInputs = parameters.audioInputs;

    String selectedVideoPreference = parameters.userDefaultVideoInputDevice;
    if (videoInputs.isEmpty) {
      selectedVideoPreference = '';
    } else if (selectedVideoPreference.isEmpty ||
        !videoInputs
            .any((input) => input.deviceId == selectedVideoPreference)) {
      selectedVideoPreference = videoInputs[0].deviceId;
    }
    final String? selectedVideoInput =
        videoInputs.isEmpty ? null : selectedVideoPreference;

    String selectedAudioPreference = parameters.userDefaultAudioInputDevice;
    if (audioInputs.isEmpty) {
      selectedAudioPreference = '';
    } else if (selectedAudioPreference.isEmpty ||
        !audioInputs
            .any((input) => input.deviceId == selectedAudioPreference)) {
      selectedAudioPreference = audioInputs[0].deviceId;
    }
    final String? selectedAudioInput =
        audioInputs.isEmpty ? null : selectedAudioPreference;

    final positionValues = getModalPosition(
      GetModalPositionOptions(
        position: options.position,
        modalWidth: modalWidth,
        modalHeight: modalHeight,
        context: context,
      ),
    );

    final modal = _buildModalContainer(
      context: context,
      parameters: parameters,
      modalWidth: modalWidth,
      modalHeight: modalHeight,
      videoInputs: videoInputs,
      audioInputs: audioInputs,
      selectedVideoInput: selectedVideoInput,
      selectedAudioInput: selectedAudioInput,
    );

    final stackChildren = <Widget>[
      Positioned(
        top: (positionValues['top'] as num?)?.toDouble(),
        right: (positionValues['right'] as num?)?.toDouble(),
        child: modal,
      ),
    ];

    final defaultWrapper = Stack(children: stackChildren);

    final wrapper = options.wrapperBuilder?.call(
          MediaSettingsModalWrapperContext(
            buildContext: context,
            options: options,
            parameters: parameters,
            modalWidth: modalWidth,
            modalHeight: modalHeight,
            stackChildren: stackChildren,
            defaultWrapper: defaultWrapper,
          ),
        ) ??
        defaultWrapper;

    return Visibility(
      visible: options.isVisible,
      child: wrapper,
    );
  }

  Widget _buildModalContainer({
    required BuildContext context,
    required MediaSettingsModalParameters parameters,
    required double modalWidth,
    required double modalHeight,
    required List<MediaDeviceInfo> videoInputs,
    required List<MediaDeviceInfo> audioInputs,
    required String? selectedVideoInput,
    required String? selectedAudioInput,
  }) {
    final content = _buildContent(
      context: context,
      parameters: parameters,
      modalWidth: modalWidth,
      modalHeight: modalHeight,
      videoInputs: videoInputs,
      audioInputs: audioInputs,
      selectedVideoInput: selectedVideoInput,
      selectedAudioInput: selectedAudioInput,
    );

    final decoration = options.containerDecoration ??
        BoxDecoration(color: options.backgroundColor);

    final defaultContainer = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: options.containerMargin,
        padding: options.containerPadding ?? const EdgeInsets.all(10),
        alignment: options.containerAlignment,
        decoration: decoration,
        width: modalWidth,
        height: modalHeight,
        child: content,
      ),
    );

    return options.containerBuilder?.call(
          MediaSettingsModalContainerContext(
            buildContext: context,
            options: options,
            parameters: parameters,
            modalWidth: modalWidth,
            modalHeight: modalHeight,
            child: content,
            defaultContainer: defaultContainer,
          ),
        ) ??
        defaultContainer;
  }

  Widget _buildContent({
    required BuildContext context,
    required MediaSettingsModalParameters parameters,
    required double modalWidth,
    required double modalHeight,
    required List<MediaDeviceInfo> videoInputs,
    required List<MediaDeviceInfo> audioInputs,
    required String? selectedVideoInput,
    required String? selectedAudioInput,
    bool showCloseButton = true,
  }) {
    final header =
        _buildHeader(context, parameters, showCloseButton: showCloseButton);
    final cameraSection = _buildDeviceSection(
      context: context,
      parameters: parameters,
      label: 'Select Camera:',
      type: 'camera',
      selectedValue: selectedVideoInput,
      items: videoInputs
          .map(
            (input) => DropdownMenuItem<String>(
              value: input.deviceId,
              child: Text(input.label),
            ),
          )
          .toList(),
      onChanged: (value) async {
        final optionsSwitch = SwitchVideoOptions(
          videoPreference: value,
          parameters: parameters,
        );
        await options.switchVideoOnPress(optionsSwitch);
      },
    );

    final microphoneSection = _buildDeviceSection(
      context: context,
      parameters: parameters,
      label: 'Select Microphone:',
      type: 'microphone',
      selectedValue: selectedAudioInput,
      items: audioInputs
          .map(
            (input) => DropdownMenuItem<String>(
              value: input.deviceId,
              child: Text(input.label),
            ),
          )
          .toList(),
      onChanged: (value) async {
        final optionsSwitch = SwitchAudioOptions(
          audioPreference: value,
          parameters: parameters,
        );
        await options.switchAudioOnPress(optionsSwitch);
      },
    );

    final switchButton = _buildSwitchButton(
      context,
      parameters,
    );

    final speakerToggle = _buildSpeakerToggle(
      context,
      parameters,
    );

    final virtualBackgroundButton = _buildVirtualBackgroundButton(
      context,
      parameters,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const Divider(height: 10, thickness: 1, color: Colors.black),
        const SizedBox(height: 10),
        cameraSection,
        const SizedBox(height: 20),
        microphoneSection,
        const SizedBox(height: 20),
        speakerToggle,
        const SizedBox(height: 20),
        switchButton,
        const Divider(height: 20, thickness: 1, color: Colors.black),
        virtualBackgroundButton,
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    MediaSettingsModalParameters parameters, {
    bool showCloseButton = true,
  }) {
    final title = Text(
      'Media Settings',
      style: options.titleTextStyle ??
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
    );

    final closeButton = showCloseButton
        ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: options.onClose,
          )
        : const SizedBox.shrink();

    final defaultHeader = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        title,
        if (showCloseButton) closeButton,
      ],
    );

    return options.headerBuilder?.call(
          MediaSettingsModalHeaderContext(
            buildContext: context,
            options: options,
            parameters: parameters,
            title: title,
            closeButton: closeButton,
            defaultHeader: defaultHeader,
          ),
        ) ??
        defaultHeader;
  }

  Widget _buildDeviceSection({
    required BuildContext context,
    required MediaSettingsModalParameters parameters,
    required String label,
    required String type,
    required String? selectedValue,
    required List<DropdownMenuItem<String>> items,
    required Future<void> Function(String value) onChanged,
  }) {
    final dropdown = _buildDropdown(
      context: context,
      parameters: parameters,
      type: type,
      selectedValue: selectedValue,
      items: items,
      onChanged: onChanged,
    );

    final labelWidget = Text(
      label,
      style: options.labelTextStyle ??
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
    );

    final defaultSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelWidget,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: dropdown,
        ),
      ],
    );

    return options.sectionBuilder?.call(
          MediaSettingsModalSectionContext(
            buildContext: context,
            options: options,
            parameters: parameters,
            label: label,
            type: type,
            dropdown: dropdown,
            defaultSection: defaultSection,
          ),
        ) ??
        defaultSection;
  }

  Widget _buildDropdown({
    required BuildContext context,
    required MediaSettingsModalParameters parameters,
    required String type,
    required String? selectedValue,
    required List<DropdownMenuItem<String>> items,
    required Future<void> Function(String value) onChanged,
  }) {
    Future<void> handleChange(String? newValue) async {
      if (newValue == null) return;
      await onChanged(newValue);
    }

    final defaultDropdown = DropdownButton<String>(
      value: selectedValue,
      onChanged: (value) {
        handleChange(value);
      },
      items: items,
    );

    return options.dropdownBuilder?.call(
          MediaSettingsModalDropdownContext(
            buildContext: context,
            options: options,
            parameters: parameters,
            type: type,
            selectedValue: selectedValue,
            items: items,
            onChanged: (value) {
              handleChange(value);
            },
            defaultDropdown: defaultDropdown,
          ),
        ) ??
        defaultDropdown;
  }

  Widget _buildSwitchButton(
    BuildContext context,
    MediaSettingsModalParameters parameters,
  ) {
    final onPressed = _createSwitchCameraHandler(parameters);
    final child = options.switchButtonChild ?? const Text('Switch Camera');

    final defaultButton = ElevatedButton(
      onPressed: onPressed,
      style: options.switchButtonStyle,
      child: child,
    );

    return options.buttonBuilder?.call(
          MediaSettingsModalButtonContext(
            buildContext: context,
            options: options,
            parameters: parameters,
            onPressed: onPressed,
            child: child,
            defaultButton: defaultButton,
          ),
        ) ??
        defaultButton;
  }

  /// Check if speaker toggle is supported on current platform
  bool get _isSpeakerToggleSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Builds the speaker toggle for switching between earpiece and speaker (mobile only).
  Widget _buildSpeakerToggle(
    BuildContext context,
    MediaSettingsModalParameters parameters,
  ) {
    final isSupported = _isSpeakerToggleSupported;

    if (!isSupported) {
      // Don't show on unsupported platforms
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Speaker Output:',
          style: options.labelTextStyle ??
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              parameters.isSpeakerphoneOn ? 'Speaker' : 'Earpiece',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Switch(
              value: parameters.isSpeakerphoneOn,
              activeTrackColor: options.backgroundColor.withValues(alpha: 0.5),
              activeThumbColor: options.backgroundColor,
              onChanged: (bool value) async {
                final success = await switchAudioOutput(
                  SwitchAudioOutputOptions(
                    speakerOn: value,
                    preferBluetooth: true,
                  ),
                );
                if (success) {
                  parameters.updateIsSpeakerphoneOn(value);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Check if virtual background is supported on current platform
  bool get _isVirtualBackgroundSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Builds the Virtual Background button that toggles the background modal.
  Widget _buildVirtualBackgroundButton(
    BuildContext context,
    MediaSettingsModalParameters parameters,
  ) {
    final isSupported = _isVirtualBackgroundSupported;

    void handleVirtualBackgroundPress() {
      if (isSupported) {
        final isVisible = parameters.isBackgroundModalVisible;
        parameters.updateIsBackgroundModalVisible(!isVisible);
      } else {
        // Show alert for unsupported platforms
        parameters.showAlert?.call(
          message:
              'Virtual backgrounds are only supported on mobile devices (Android/iOS). '
              'This feature is not available on ${kIsWeb ? 'web' : defaultTargetPlatform.name}.',
          type: 'warning',
          duration: 4000,
        );
      }
    }

    return Opacity(
      opacity: isSupported ? 1.0 : 0.6,
      child: ElevatedButton.icon(
        onPressed: handleVirtualBackgroundPress,
        icon: const Icon(Icons.photo_library, size: 18),
        label: Text(isSupported
            ? 'Virtual Background'
            : 'Virtual Background (Mobile Only)'),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSupported ? options.backgroundColor : Colors.grey.shade300,
          foregroundColor: isSupported ? Colors.black : Colors.grey.shade600,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  VoidCallback _createSwitchCameraHandler(
    MediaSettingsModalParameters parameters,
  ) {
    return () {
      final optionsSwitch = SwitchVideoAltOptions(
        parameters: parameters,
      );
      options.switchCameraOnPress(optionsSwitch);
    };
  }
}
