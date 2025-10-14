import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../methods/settings_methods/modify_settings.dart'
    show modifySettings, ModifySettingsType, ModifySettingsOptions;
import '../../types/types.dart' show ShowAlert;

class EventSettingsModalWrapperContext {
  final BuildContext buildContext;
  final EventSettingsModalOptions options;
  final double modalWidth;
  final double modalHeight;
  final List<Widget> stackChildren;
  final Widget defaultWrapper;
  final String audioState;
  final String videoState;
  final String screenshareState;
  final String chatState;

  const EventSettingsModalWrapperContext({
    required this.buildContext,
    required this.options,
    required this.modalWidth,
    required this.modalHeight,
    required this.stackChildren,
    required this.defaultWrapper,
    required this.audioState,
    required this.videoState,
    required this.screenshareState,
    required this.chatState,
  });
}

class EventSettingsModalContainerContext {
  final BuildContext buildContext;
  final EventSettingsModalOptions options;
  final double modalWidth;
  final double modalHeight;
  final Widget child;
  final Widget defaultContainer;
  final String audioState;
  final String videoState;
  final String screenshareState;
  final String chatState;

  const EventSettingsModalContainerContext({
    required this.buildContext,
    required this.options,
    required this.modalWidth,
    required this.modalHeight,
    required this.child,
    required this.defaultContainer,
    required this.audioState,
    required this.videoState,
    required this.screenshareState,
    required this.chatState,
  });
}

class EventSettingsModalHeaderContext {
  final BuildContext buildContext;
  final EventSettingsModalOptions options;
  final Widget title;
  final Widget closeButton;
  final Widget defaultHeader;

  const EventSettingsModalHeaderContext({
    required this.buildContext,
    required this.options,
    required this.title,
    required this.closeButton,
    required this.defaultHeader,
  });
}

class EventSettingsModalSectionContext {
  final BuildContext buildContext;
  final EventSettingsModalOptions options;
  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final Widget dropdown;
  final Widget defaultSection;

  const EventSettingsModalSectionContext({
    required this.buildContext,
    required this.options,
    required this.label,
    required this.value,
    required this.items,
    required this.dropdown,
    required this.defaultSection,
  });
}

class EventSettingsModalDropdownContext {
  final BuildContext buildContext;
  final EventSettingsModalOptions options;
  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final Widget defaultDropdown;

  const EventSettingsModalDropdownContext({
    required this.buildContext,
    required this.options,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.defaultDropdown,
  });
}

class EventSettingsModalButtonContext {
  final BuildContext buildContext;
  final EventSettingsModalOptions options;
  final VoidCallback onPressed;
  final Widget child;
  final Widget defaultButton;

  const EventSettingsModalButtonContext({
    required this.buildContext,
    required this.options,
    required this.onPressed,
    required this.child,
    required this.defaultButton,
  });
}

/// EventSettingsModalOptions - Defines configuration options for the `EventSettingsModal`.
class EventSettingsModalOptions {
  final bool isVisible;
  final VoidCallback onClose;
  final ModifySettingsType onModifySettings;
  final String position;
  final Color backgroundColor;
  final String audioSetting;
  final String videoSetting;
  final String screenshareSetting;
  final String chatSetting;
  final String roomName;
  final io.Socket? socket;
  final ShowAlert? showAlert;
  final void Function(String) updateAudioSetting;
  final void Function(String) updateVideoSetting;
  final void Function(String) updateScreenshareSetting;
  final void Function(String) updateChatSetting;
  final void Function(bool) updateIsSettingsModalVisible;
  final EventSettingsModalType? customBuilder;
  final EdgeInsetsGeometry? containerPadding;
  final EdgeInsetsGeometry? containerMargin;
  final AlignmentGeometry? containerAlignment;
  final BoxDecoration? containerDecoration;
  final EventSettingsModalWrapperBuilder? wrapperBuilder;
  final EventSettingsModalContainerBuilder? containerBuilder;
  final EventSettingsModalHeaderBuilder? headerBuilder;
  final EventSettingsModalSectionBuilder? sectionBuilder;
  final EventSettingsModalDropdownBuilder? dropdownBuilder;
  final EventSettingsModalButtonBuilder? buttonBuilder;
  final TextStyle? titleTextStyle;
  final TextStyle? labelTextStyle;
  final ButtonStyle? saveButtonStyle;
  final Widget? saveButtonChild;

  EventSettingsModalOptions({
    required this.isVisible,
    required this.onClose,
    this.onModifySettings = modifySettings,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFF83C0E9),
    required this.audioSetting,
    required this.videoSetting,
    required this.screenshareSetting,
    required this.chatSetting,
    required this.roomName,
    this.socket,
    required this.showAlert,
    required this.updateAudioSetting,
    required this.updateVideoSetting,
    required this.updateScreenshareSetting,
    required this.updateChatSetting,
    required this.updateIsSettingsModalVisible,
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
    this.saveButtonStyle,
    this.saveButtonChild,
  });
}

typedef EventSettingsModalType = Widget Function({
  required EventSettingsModalOptions options,
});

typedef EventSettingsModalWrapperBuilder = Widget Function(
  EventSettingsModalWrapperContext context,
);

typedef EventSettingsModalContainerBuilder = Widget Function(
  EventSettingsModalContainerContext context,
);

typedef EventSettingsModalHeaderBuilder = Widget Function(
  EventSettingsModalHeaderContext context,
);

typedef EventSettingsModalSectionBuilder = Widget Function(
  EventSettingsModalSectionContext context,
);

typedef EventSettingsModalDropdownBuilder = Widget Function(
  EventSettingsModalDropdownContext context,
);

typedef EventSettingsModalButtonBuilder = Widget Function(
  EventSettingsModalButtonContext context,
);

/// `EventSettingsModalOptions` - Configuration options for `EventSettingsModal`.
///
/// ### Properties:
/// - `isVisible`: Boolean indicating the modal's visibility.
/// - `onClose`: Callback to close the modal.
/// - `onModifySettings`: Callback for modifying the settings, with `modifySettings` as the default function.
/// - `position`: Position of the modal on the screen (default is 'topRight').
/// - `backgroundColor`: Background color of the modal (default is `Color(0xFF83C0E9)`).
/// - `audioSetting`, `videoSetting`, `screenshareSetting`, `chatSetting`: Initial settings for each media type.
/// - `roomName`: Name of the room or event.
/// - `socket`: Socket connection for sending settings updates.
/// - `showAlert`: Function to display alert messages.
/// - `updateAudioSetting`, `updateVideoSetting`, `updateScreenshareSetting`, `updateChatSetting`: Functions to update individual settings.
/// - `updateIsSettingsModalVisible`: Function to update the visibility of the modal.
///
/// ### Example Usage:
/// ```dart
/// EventSettingsModal(
///   options: EventSettingsModalOptions(
///     isVisible: true,
///     onClose: () => print("Modal closed"),
///     audioSetting: 'allow',
///     videoSetting: 'approval',
///     screenshareSetting: 'disallow',
///     chatSetting: 'allow',
///     roomName: 'eventRoom',
///     socket: socket,
///     showAlert: (msg, type, duration) => print(msg),
///     updateAudioSetting: (val) => print("Audio setting: $val"),
///     updateVideoSetting: (val) => print("Video setting: $val"),
///     updateScreenshareSetting: (val) => print("Screenshare setting: $val"),
///     updateChatSetting: (val) => print("Chat setting: $val"),
///     updateIsSettingsModalVisible: (val) => print("Settings modal visible: $val"),
///   ),
/// );
/// ```

/// `EventSettingsModal` - A modal widget for configuring event-specific media settings.
///
/// This widget provides options to control participant permissions for audio, video, screenshare, and chat.
/// The settings are saved and applied using the `onModifySettings` callback, which updates the settings on the server.
///
/// ### Parameters:
/// - `options` (`EventSettingsModalOptions`): Configuration options for the modal.
///
/// ### Structure:
/// - Header with title ("Event Settings") and close icon.
/// - Dropdown selectors for each setting (audio, video, screenshare, and chat).
/// - Save button to confirm and apply the settings.
///
/// ### Example Usage:
/// ```dart
/// EventSettingsModal(
///   options: EventSettingsModalOptions(
///     isVisible: true,
///     onClose: () => print("Modal closed"),
///     audioSetting: 'allow',
///     videoSetting: 'approval',
///     screenshareSetting: 'disallow',
///     chatSetting: 'allow',
///     roomName: 'eventRoom',
///     socket: socket,
///   ),
/// );
/// ```

class EventSettingsModal extends StatefulWidget {
  final EventSettingsModalOptions options;

  const EventSettingsModal({super.key, required this.options});

  @override
  _EventSettingsModalState createState() => _EventSettingsModalState();
}

class _EventSettingsModalState extends State<EventSettingsModal> {
  late String _audioState;
  late String _videoState;
  late String _screenshareState;
  late String _chatState;

  @override
  void initState() {
    super.initState();
    _audioState = widget.options.audioSetting;
    _videoState = widget.options.videoSetting;
    _screenshareState = widget.options.screenshareSetting;
    _chatState = widget.options.chatSetting;
  }

  @override
  Widget build(BuildContext context) {
    final customBuilder = widget.options.customBuilder;
    if (customBuilder != null) {
      return customBuilder(options: widget.options);
    }

    if (!widget.options.isVisible) {
      return const SizedBox.shrink();
    }

  final screenWidth = MediaQuery.of(context).size.width;
  final modalWidth = screenWidth * 0.8 > 400 ? 400.0 : screenWidth * 0.8;
    final modalHeight = MediaQuery.of(context).size.height * 0.6;

    final positionValues = getModalPosition(
      GetModalPositionOptions(
        position: widget.options.position,
        modalWidth: modalWidth,
        modalHeight: modalHeight,
        context: context,
      ),
    );

    final modal = _buildModalContainer(context, modalWidth, modalHeight);

    final positionedTop = (positionValues['top'] as num?)?.toDouble();
    final positionedRight = (positionValues['right'] as num?)?.toDouble();

    final stackChildren = <Widget>[
      Positioned(
        top: positionedTop,
        right: positionedRight,
        child: modal,
      ),
    ];

    final defaultWrapper = Stack(children: stackChildren);

    final wrapper = widget.options.wrapperBuilder?.call(
          EventSettingsModalWrapperContext(
            buildContext: context,
            options: widget.options,
            modalWidth: modalWidth,
            modalHeight: modalHeight,
            stackChildren: stackChildren,
            defaultWrapper: defaultWrapper,
            audioState: _audioState,
            videoState: _videoState,
            screenshareState: _screenshareState,
            chatState: _chatState,
          ),
        ) ??
        defaultWrapper;

    return Visibility(
      visible: widget.options.isVisible,
      child: wrapper,
    );
  }

  Widget _buildModalContainer(
    BuildContext context,
    double modalWidth,
    double modalHeight,
  ) {
    final content = _buildContent(context);

    final decoration = widget.options.containerDecoration ??
        BoxDecoration(color: widget.options.backgroundColor);

    final innerContainer = Container(
      width: modalWidth,
      height: modalHeight,
      padding: widget.options.containerPadding ?? const EdgeInsets.all(20.0),
      margin: widget.options.containerMargin,
      alignment: widget.options.containerAlignment,
      decoration: decoration,
      child: SingleChildScrollView(
        child: content,
      ),
    );

    final defaultContainer = AnimatedOpacity(
      opacity: widget.options.isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: innerContainer,
    );

    return widget.options.containerBuilder?.call(
          EventSettingsModalContainerContext(
            buildContext: context,
            options: widget.options,
            modalWidth: modalWidth,
            modalHeight: modalHeight,
            child: content,
            defaultContainer: defaultContainer,
            audioState: _audioState,
            videoState: _videoState,
            screenshareState: _screenshareState,
            chatState: _chatState,
          ),
        ) ??
        defaultContainer;
  }

  Widget _buildContent(BuildContext context) {
    final header = _buildHeader(context);
    final audioSection = _buildSettingSection(
      context: context,
      label: 'User audio:',
      value: _audioState,
      allowApproval: true,
      onChanged: (value) => setState(() => _audioState = value),
    );
    final videoSection = _buildSettingSection(
      context: context,
      label: 'User video:',
      value: _videoState,
      allowApproval: true,
      onChanged: (value) => setState(() => _videoState = value),
    );
    final screenshareSection = _buildSettingSection(
      context: context,
      label: 'User screenshare:',
      value: _screenshareState,
      allowApproval: true,
      onChanged: (value) => setState(() => _screenshareState = value),
    );
    final chatSection = _buildSettingSection(
      context: context,
      label: 'User chat:',
      value: _chatState,
      allowApproval: false,
      onChanged: (value) => setState(() => _chatState = value),
    );
    final saveButton = _buildSaveButton(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 10),
        const Divider(
          color: Colors.black,
          height: 1,
        ),
        const SizedBox(height: 10),
        audioSection,
        const SizedBox(height: 10),
        videoSection,
        const SizedBox(height: 10),
        screenshareSection,
        const SizedBox(height: 10),
        chatSection,
        const SizedBox(height: 10),
        saveButton,
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final title = Text(
      'Event Settings',
      style: widget.options.titleTextStyle ??
          const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
    );

    final closeButton = IconButton(
      icon: const Icon(Icons.close),
      onPressed: widget.options.onClose,
      color: Colors.black,
    );

    final defaultHeader = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        title,
        closeButton,
      ],
    );

    return widget.options.headerBuilder?.call(
          EventSettingsModalHeaderContext(
            buildContext: context,
            options: widget.options,
            title: title,
            closeButton: closeButton,
            defaultHeader: defaultHeader,
          ),
        ) ??
        defaultHeader;
  }

  Widget _buildSettingSection({
    required BuildContext context,
    required String label,
    required String value,
    required bool allowApproval,
    required void Function(String value) onChanged,
  }) {
    final items = _buildDropdownItems(allowApproval: allowApproval);
    final dropdownWidget = _buildDropdown(
      context: context,
      label: label,
      value: value,
      items: items,
      onChanged: onChanged,
    );

    final labelWidget = Expanded(
      flex: 4,
      child: Text(
        label,
        style: widget.options.labelTextStyle ??
            const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
      ),
    );

    final defaultSection = Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelWidget,
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: dropdownWidget,
          ),
        ],
      ),
    );

    return widget.options.sectionBuilder?.call(
          EventSettingsModalSectionContext(
            buildContext: context,
            options: widget.options,
            label: label,
            value: value,
            items: items,
            dropdown: dropdownWidget,
            defaultSection: defaultSection,
          ),
        ) ??
        defaultSection;
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String value) onChanged,
  }) {
    void handleChange(String? newValue) {
      if (newValue == null) return;
      onChanged(newValue);
    }

    final defaultDropdown = DropdownButton<String>(
      value: value,
      onChanged: handleChange,
      items: items,
    );

    return widget.options.dropdownBuilder?.call(
          EventSettingsModalDropdownContext(
            buildContext: context,
            options: widget.options,
            label: label,
            value: value,
            items: items,
            onChanged: handleChange,
            defaultDropdown: defaultDropdown,
          ),
        ) ??
        defaultDropdown;
  }

  List<DropdownMenuItem<String>> _buildDropdownItems({
    required bool allowApproval,
  }) {
    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem(
        value: 'disallow',
        child: Text('Disallow', style: TextStyle(fontSize: 14)),
      ),
    ];

    if (allowApproval) {
      items.add(
        const DropdownMenuItem(
          value: 'approval',
          child: Text('Approval', style: TextStyle(fontSize: 14)),
        ),
      );
    }

    items.add(
      const DropdownMenuItem(
        value: 'allow',
        child: Text('Allow', style: TextStyle(fontSize: 14)),
      ),
    );

    return items;
  }

  Widget _buildSaveButton(BuildContext context) {
    void onPressed() {
      final optionsModify = ModifySettingsOptions(
        audioSet: _audioState,
        videoSet: _videoState,
        screenshareSet: _screenshareState,
        chatSet: _chatState,
        updateAudioSetting: widget.options.updateAudioSetting,
        updateVideoSetting: widget.options.updateVideoSetting,
        updateScreenshareSetting: widget.options.updateScreenshareSetting,
        updateChatSetting: widget.options.updateChatSetting,
        updateIsSettingsModalVisible:
            widget.options.updateIsSettingsModalVisible,
        roomName: widget.options.roomName,
        socket: widget.options.socket,
        showAlert: widget.options.showAlert,
      );
      widget.options.onModifySettings(optionsModify);
    }

    final child = widget.options.saveButtonChild ?? const Text('Save');

    final defaultButton = ElevatedButton(
      onPressed: onPressed,
      style: widget.options.saveButtonStyle,
      child: child,
    );

    return widget.options.buttonBuilder?.call(
          EventSettingsModalButtonContext(
            buildContext: context,
            options: widget.options,
            onPressed: onPressed,
            child: child,
            defaultButton: defaultButton,
          ),
        ) ??
        defaultButton;
  }
}
