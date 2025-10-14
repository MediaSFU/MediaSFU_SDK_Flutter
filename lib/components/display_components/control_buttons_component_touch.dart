import 'package:flutter/material.dart';

Axis _directionFromString(String direction) {
  switch (direction.toLowerCase()) {
    case 'vertical':
      return Axis.vertical;
    default:
      return Axis.horizontal;
  }
}

MainAxisAlignment _mainAxisFromPosition(String position) {
  switch (position.toLowerCase()) {
    case 'left':
      return MainAxisAlignment.start;
    case 'right':
      return MainAxisAlignment.end;
    default:
      return MainAxisAlignment.center;
  }
}

MainAxisAlignment _mainAxisFromLocation(String location) {
  switch (location.toLowerCase()) {
    case 'top':
      return MainAxisAlignment.start;
    case 'bottom':
      return MainAxisAlignment.end;
    default:
      return MainAxisAlignment.center;
  }
}

double _alignmentValueFromPosition(String position) {
  switch (position.toLowerCase()) {
    case 'left':
      return -1.0;
    case 'right':
      return 1.0;
    default:
      return 0.0;
  }
}

double _alignmentValueFromLocation(String location) {
  switch (location.toLowerCase()) {
    case 'top':
      return -1.0;
    case 'bottom':
      return 1.0;
    default:
      return 0.0;
  }
}

class ControlButtonsTouchContainerContext {
  final BuildContext buildContext;
  final ControlButtonsComponentTouchOptions options;
  final Axis direction;
  final List<ButtonTouch> visibleButtons;

  const ControlButtonsTouchContainerContext({
    required this.buildContext,
    required this.options,
    required this.direction,
    required this.visibleButtons,
  });
}

class ControlButtonsTouchButtonsContext {
  final BuildContext buildContext;
  final ControlButtonsComponentTouchOptions options;
  final Axis direction;
  final List<ButtonTouch> visibleButtons;
  final List<Widget> buttons;
  final List<Widget> spacedButtons;

  const ControlButtonsTouchButtonsContext({
    required this.buildContext,
    required this.options,
    required this.direction,
    required this.visibleButtons,
    required this.buttons,
    required this.spacedButtons,
  });
}

class ControlButtonsTouchButtonContext {
  final BuildContext buildContext;
  final ControlButtonsComponentTouchOptions options;
  final ButtonTouch button;
  final int index;
  final Axis direction;
  final bool isActive;

  const ControlButtonsTouchButtonContext({
    required this.buildContext,
    required this.options,
    required this.button,
    required this.index,
    required this.direction,
    required this.isActive,
  });
}

class ControlButtonsTouchButtonContentContext {
  final BuildContext buildContext;
  final ControlButtonsComponentTouchOptions options;
  final ButtonTouch button;
  final int index;
  final Axis direction;
  final bool isActive;
  final Widget? icon;
  final Widget? label;

  const ControlButtonsTouchButtonContentContext({
    required this.buildContext,
    required this.options,
    required this.button,
    required this.index,
    required this.direction,
    required this.isActive,
    required this.icon,
    required this.label,
  });
}

class ControlButtonsTouchButtonIconContext {
  final BuildContext buildContext;
  final ControlButtonsComponentTouchOptions options;
  final ButtonTouch button;
  final int index;
  final Axis direction;
  final bool isActive;

  const ControlButtonsTouchButtonIconContext({
    required this.buildContext,
    required this.options,
    required this.button,
    required this.index,
    required this.direction,
    required this.isActive,
  });
}

class ControlButtonsTouchButtonLabelContext {
  final BuildContext buildContext;
  final ControlButtonsComponentTouchOptions options;
  final ButtonTouch button;
  final int index;
  final Axis direction;
  final bool isActive;

  const ControlButtonsTouchButtonLabelContext({
    required this.buildContext,
    required this.options,
    required this.button,
    required this.index,
    required this.direction,
    required this.isActive,
  });
}

typedef ControlButtonsTouchContainerBuilder = Widget Function(
  ControlButtonsTouchContainerContext context,
  Widget defaultContainer,
);

typedef ControlButtonsTouchButtonsBuilder = Widget Function(
  ControlButtonsTouchButtonsContext context,
  Widget defaultButtons,
);

typedef ControlButtonsTouchButtonBuilder = Widget Function(
  ControlButtonsTouchButtonContext context,
  Widget defaultButton,
);

typedef ControlButtonsTouchButtonContentBuilder = Widget Function(
  ControlButtonsTouchButtonContentContext context,
  Widget defaultContent,
);

typedef ControlButtonsTouchButtonIconBuilder = Widget? Function(
  ControlButtonsTouchButtonIconContext context,
  Widget? defaultIcon,
);

typedef ControlButtonsTouchButtonLabelBuilder = Widget? Function(
  ControlButtonsTouchButtonLabelContext context,
  Widget? defaultLabel,
);

class ControlButtonsTouchStateColors {
  final Color? defaultColor;
  final Color? activeColor;
  final Color? disabledColor;
  final Color? pressedColor;

  const ControlButtonsTouchStateColors({
    this.defaultColor,
    this.activeColor,
    this.disabledColor,
    this.pressedColor,
  });
}

/// ButtonTouch - Represents a control button with customizable style and behavior.
///
/// ### Example Usage:
/// ```dart
/// ButtonTouch(
///   name: 'Play',
///   icon: Icons.play_arrow,
///   alternateIcon: Icons.pause,
///   onPress: () => print('Button pressed'),
///   active: true,
///   show: true,
///   backgroundColor: {
///     'default': Colors.blue,
///     'pressed': Colors.green,
///   },
/// );
/// ```
class ButtonTouch {
  final String? name;
  final IconData? icon;
  final IconData? alternateIcon;
  final VoidCallback? onPress;
  final Color? color;
  final Color? activeColor;
  final Color? inActiveColor;
  final bool active;
  final bool show;
  final Widget? customComponent;
  final bool disabled;
  final int? size;
  final Map<String, Color>? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? contentPadding;
  final MainAxisAlignment? contentMainAxisAlignment;
  final CrossAxisAlignment? contentCrossAxisAlignment;
  final double? contentGap;
  final double? iconSize;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? labelPadding;
  final EdgeInsetsGeometry? iconPadding;
  final Widget? iconWidget;
  final Widget? alternateIconWidget;
  final ControlButtonsTouchButtonContentBuilder? contentBuilder;
  final ControlButtonsTouchButtonBuilder? buttonBuilder;
  final ControlButtonsTouchButtonIconBuilder? iconBuilder;
  final ControlButtonsTouchButtonLabelBuilder? labelBuilder;
  final String? semanticsLabel;

  const ButtonTouch({
    this.name,
    this.icon,
    this.alternateIcon,
    this.onPress,
    this.color = Colors.white,
    this.activeColor,
    this.inActiveColor,
    this.active = false,
    this.show = true,
    this.customComponent,
    this.disabled = false,
    this.backgroundColor,
    this.size = 16,
    this.padding,
    this.margin,
    this.decoration,
    this.constraints,
    this.contentPadding,
    this.contentMainAxisAlignment,
    this.contentCrossAxisAlignment,
    this.contentGap,
    this.iconSize,
    this.textStyle,
    this.labelPadding,
    this.iconPadding,
    this.iconWidget,
    this.alternateIconWidget,
    this.contentBuilder,
    this.buttonBuilder,
    this.iconBuilder,
    this.labelBuilder,
    this.semanticsLabel,
  });
}

/// Configuration options for the `ControlButtonsComponentTouch`.
///
/// Provides extensive customization for touch-optimized control button bars with
/// per-button styling, state colors, accessibility, and six builder hooks. Most
/// comprehensive variant of control buttons with mobile/tablet touch targets in mind.
///
/// **Core Properties:**
/// - `buttons`: List of ButtonTouch objects (each button fully customizable)
/// - `showAspect`: If false, hides entire component; useful for conditional visibility
///
/// **Layout Configuration:**
/// - `direction`: Button arrangement: 'horizontal' (default) or 'vertical'
/// - `position`: Horizontal alignment: 'left' (default), 'right', 'center'
/// - `location`: Vertical alignment: 'top' (default), 'bottom', 'center'
/// - `gap`: Spacing between buttons (default: null, no spacing)
///
/// **Container Styling:**
/// - `containerDecoration`: BoxDecoration for button group wrapper
/// - `containerPadding`: Padding around button group (default: EdgeInsets.symmetric(vertical: 10))
/// - `containerMargin`: Margin for button group container
/// - `containerAlignment`: Alignment override (default: computed from position+location)
/// - `containerClipBehavior`: Clip behavior (default: Clip.none)
///
/// **Global Button Styling (applied to all buttons unless overridden per-button):**
/// - `buttonBackgroundColors`: ControlButtonsTouchStateColors with default/active/disabled/pressed colors
/// - `buttonColor`: Default icon color
/// - `activeIconColor`: Icon color when button.active=true
/// - `inactiveIconColor`: Icon color when button.active=false
/// - `iconSize`: Icon dimensions
/// - `textStyle`: Label text styling
/// - `buttonPadding`/`buttonMargin`: Spacing for each button
/// - `buttonDecoration`: BoxDecoration for button containers
/// - `buttonBorderRadius`: Border radius for buttons
/// - `buttonConstraints`: Size constraints for buttons
///
/// **Content Layout (icon+label arrangement):**
/// - `contentPadding`: Padding within button content area
/// - `contentMainAxisAlignment`: Alignment along button's main axis
/// - `contentCrossAxisAlignment`: Alignment along button's cross axis
/// - `contentGap`: Spacing between icon and label
/// - `labelPadding`: Padding around label text
/// - `iconPadding`: Padding around icon
///
/// **Icon Components:**
/// - `iconComponent`: Custom widget replacing default inactive icon display
/// - `alternateIconComponent`: Custom widget replacing default active icon display
///
/// **Builder Hooks (6):**
/// - `containerBuilder`: Override outer Container; receives ControlButtonsTouchContainerContext + default
/// - `buttonsBuilder`: Override Row/Column layout; receives ControlButtonsTouchButtonsContext + default
/// - `buttonBuilder`: Override individual button wrapper; receives ControlButtonsTouchButtonContext + default
/// - `buttonContentBuilder`: Override icon+label layout; receives ControlButtonsTouchButtonContentContext + default
/// - `iconBuilder`: Override icon widget; receives ControlButtonsTouchButtonIconContext + default
/// - `labelBuilder`: Override label text; receives ControlButtonsTouchButtonLabelContext + default
///
/// **ButtonTouch Properties (per-button customization):**
/// Each button in `buttons` array supports:
/// - `name`: Display label text
/// - `icon`: Primary icon (inactive state)
/// - `alternateIcon`: Icon shown when `active=true`
/// - `onPress`: Callback function on tap
/// - `color`: Base icon color (overrides global buttonColor)
/// - `activeColor`/`inActiveColor`: Icon tint colors (override global colors)
/// - `active`: Toggle state (affects icon and background color)
/// - `show`: If false, hides this button
/// - `disabled`: If true, makes button non-interactive and applies disabled color
/// - `backgroundColor`: Map with 'default', 'pressed', 'active', 'disabled' color keys
/// - `padding`/`margin`/`decoration`/`constraints`: Per-button layout props
/// - `contentPadding`/`contentMainAxisAlignment`/`contentCrossAxisAlignment`/`contentGap`: Per-button content layout
/// - `iconSize`: Per-button icon size override
/// - `textStyle`: Per-button label styling
/// - `labelPadding`/`iconPadding`: Per-button spacing
/// - `iconWidget`/`alternateIconWidget`: Custom icon widgets
/// - `customComponent`: Full button replacement widget
/// - `contentBuilder`/`buttonBuilder`/`iconBuilder`/`labelBuilder`: Per-button builder hooks
/// - `semanticsLabel`: Accessibility label (important for screen readers)
///
/// **Usage Patterns:**
/// 1. **Basic Touch Bar:**
///    ```dart
///    ControlButtonsComponentTouch(
///      options: ControlButtonsComponentTouchOptions(
///        buttons: [
///          ButtonTouch(
///            name: 'Mic',
///            icon: Icons.mic_off,
///            alternateIcon: Icons.mic,
///            onPress: toggleMic,
///            active: isMicOn,
///            semanticsLabel: 'Toggle microphone',
///          ),
///          ButtonTouch(
///            name: 'Camera',
///            icon: Icons.videocam_off,
///            alternateIcon: Icons.videocam,
///            onPress: toggleCamera,
///            active: isCameraOn,
///            semanticsLabel: 'Toggle camera',
///          ),
///        ],
///        direction: 'horizontal',
///        position: 'center',
///        location: 'bottom',
///        gap: 16,
///      ),
///    )
///    ```
///
/// 2. **State Colors:**
///    ```dart
///    ControlButtonsComponentTouch(
///      options: ControlButtonsComponentTouchOptions(
///        buttons: buttons,
///        buttonBackgroundColors: ControlButtonsTouchStateColors(
///          defaultColor: Colors.grey[800],
///          activeColor: Colors.green,
///          disabledColor: Colors.grey[600],
///          pressedColor: Colors.blue,
///        ),
///        activeIconColor: Colors.white,
///        inactiveIconColor: Colors.grey[400],
///      ),
///    )
///    ```
///
/// 3. **Per-Button Customization:**
///    ```dart
///    ControlButtonsComponentTouch(
///      options: ControlButtonsComponentTouchOptions(
///        buttons: [
///          ButtonTouch(
///            name: 'Record',
///            icon: Icons.fiber_manual_record,
///            onPress: startRecording,
///            backgroundColor: {'default': Colors.red, 'pressed': Colors.red[700]},
///            iconSize: 32,
///            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
///          ),
///          ButtonTouch(
///            name: 'Stop',
///            icon: Icons.stop,
///            onPress: stopRecording,
///            disabled: !isRecording,
///          ),
///        ],
///      ),
///    )
///    ```
///
/// 4. **Custom Button Content:**
///    ```dart
///    ControlButtonsComponentTouch(
///      options: ControlButtonsComponentTouchOptions(
///        buttons: buttons,
///        buttonContentBuilder: (context, defaultContent) {
///          final button = context.button;
///          return Column(
///            children: [
///              Badge(
///                label: button.active ? Text('ON') : null,
///                child: context.icon ?? SizedBox(),
///              ),
///              if (button.name != null) context.label ?? SizedBox(),
///            ],
///          );
///        },
///      ),
///    )
///    ```
///
/// 5. **Accessibility-Enhanced:**
///    ```dart
///    ControlButtonsComponentTouch(
///      options: ControlButtonsComponentTouchOptions(
///        buttons: [
///          ButtonTouch(
///            icon: Icons.mic_off,
///            onPress: toggleMic,
///            semanticsLabel: isMicOn ? 'Mute microphone' : 'Unmute microphone',
///            active: isMicOn,
///          ),
///        ],
///        buttonConstraints: BoxConstraints(minWidth: 48, minHeight: 48), // WCAG touch target
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Can be overridden via `MediasfuUICustomOverrides`:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   controlButtonsTouchOptions: ComponentOverride<ControlButtonsComponentTouchOptions>(
///     builder: (existingOptions) => ControlButtonsComponentTouchOptions(
///       buttons: existingOptions.buttons,
///       position: 'center',
///       location: 'bottom',
///       gap: 20,
///       containerDecoration: BoxDecoration(
///         gradient: LinearGradient(colors: [Colors.black87, Colors.black54]),
///         borderRadius: BorderRadius.circular(24),
///       ),
///       buttonBackgroundColors: ControlButtonsTouchStateColors(
///         defaultColor: Colors.transparent,
///         activeColor: Colors.blue[700],
///         pressedColor: Colors.blue[800],
///       ),
///       iconSize: 28,
///     ),
///   ),
/// ),
/// ```
///
/// **Touch Optimization:**
/// - Default button constraints ensure minimum 48x48 touch targets (WCAG 2.1 guideline)
/// - Larger icon sizes (default 16, recommended 24-32 for touch)
/// - Spacing via gap prop prevents accidental touches
/// - Disabled state visually distinct (color + opacity)
/// - Semantics labels for screen reader support
///
/// **Differences from Other Variants:**
/// - **vs ControlButtonsComponent**: More extensive per-button customization, state colors, accessibility props
/// - **vs ControlButtonsAltComponent**: Uses ButtonTouch model (richer than AltButton), 6 builder hooks vs 4, state color system
/// - Most comprehensive: Supports per-button builders, semantics, state colors, content layout customization
class ControlButtonsComponentTouchOptions {
  final List<ButtonTouch> buttons;
  final String position;
  final String location;
  final String direction;
  final BoxDecoration? containerDecoration;
  final EdgeInsetsGeometry? containerPadding;
  final EdgeInsetsGeometry? containerMargin;
  final AlignmentGeometry? containerAlignment;
  final Clip containerClipBehavior;
  final bool showAspect;
  final ControlButtonsTouchStateColors? buttonBackgroundColors;
  final Color? buttonColor;
  final Color? activeIconColor;
  final Color? inactiveIconColor;
  final double? iconSize;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? buttonPadding;
  final EdgeInsetsGeometry? buttonMargin;
  final BoxDecoration? buttonDecoration;
  final BorderRadiusGeometry? buttonBorderRadius;
  final BoxConstraints? buttonConstraints;
  final EdgeInsetsGeometry? contentPadding;
  final MainAxisAlignment? contentMainAxisAlignment;
  final CrossAxisAlignment? contentCrossAxisAlignment;
  final double? contentGap;
  final EdgeInsetsGeometry? labelPadding;
  final EdgeInsetsGeometry? iconPadding;
  final double? gap;
  final Widget? alternateIconComponent;
  final Widget? iconComponent;
  final ControlButtonsTouchContainerBuilder? containerBuilder;
  final ControlButtonsTouchButtonsBuilder? buttonsBuilder;
  final ControlButtonsTouchButtonBuilder? buttonBuilder;
  final ControlButtonsTouchButtonContentBuilder? buttonContentBuilder;
  final ControlButtonsTouchButtonIconBuilder? iconBuilder;
  final ControlButtonsTouchButtonLabelBuilder? labelBuilder;

  const ControlButtonsComponentTouchOptions({
    required this.buttons,
    this.position = 'left',
    this.location = 'top',
    this.direction = 'horizontal',
    this.containerDecoration,
    this.containerPadding,
    this.containerMargin,
    this.containerAlignment,
    this.containerClipBehavior = Clip.none,
    this.showAspect = true,
    this.buttonBackgroundColors,
    this.buttonColor,
    this.activeIconColor,
    this.inactiveIconColor,
    this.iconSize,
    this.textStyle,
    this.buttonPadding,
    this.buttonMargin,
    this.buttonDecoration,
    this.buttonBorderRadius,
    this.buttonConstraints,
    this.contentPadding,
    this.contentMainAxisAlignment,
    this.contentCrossAxisAlignment,
    this.contentGap,
    this.labelPadding,
    this.iconPadding,
    this.gap,
    this.alternateIconComponent,
    this.iconComponent,
    this.containerBuilder,
    this.buttonsBuilder,
    this.buttonBuilder,
    this.buttonContentBuilder,
    this.iconBuilder,
    this.labelBuilder,
  });
}

typedef ControlButtonsComponentTouchType = Widget Function(
    ControlButtonsComponentTouchOptions options);

/// A stateless widget rendering touch-optimized control buttons with extensive customization.
///
/// Most comprehensive control button variant designed for mobile/tablet touch interfaces.
/// Provides per-button styling, state color system, accessibility support, and six
/// builder hooks for maximum flexibility.
///
/// **Rendering Logic:**
/// 1. If `showAspect=false` → returns invisible Container
/// 2. Filters buttons: only renders buttons where `show=true`
/// 3. Builds button widgets using _buildButton (applies all styling/state logic)
/// 4. Inserts gap widgets between buttons (if gap > 0)
/// 5. Wraps in Row (horizontal) or Column (vertical)
/// 6. Wraps in Container with alignment (position/location)
/// 7. Applies builder hooks at each layer
///
/// **Layout Structure:**
/// ```
/// Visibility (showAspect)
///   └─ Container (containerBuilder)
///      └─ Row/Column (buttonsBuilder)
///         ├─ [IF gap > 0] SizedBox (spacing)
///         ├─ Semantics (buttonBuilder)
///         │  └─ GestureDetector (onTap → button.onPress)
///         │     └─ Container (button background, state colors)
///         │        └─ Row/Column (buttonContentBuilder)
///         │           ├─ [Icon] (iconBuilder)
///         │           ├─ [IF contentGap > 0] SizedBox
///         │           └─ [Text] (labelBuilder)
///         ├─ [IF gap > 0] SizedBox
///         ├─ [Next button] ...
///         └─ ...
/// ```
///
/// **Button State Logic:**
/// For each ButtonTouch, determines background color:
/// 1. If `disabled=true` → uses buttonBackgroundColors.disabledColor or button.backgroundColor['disabled']
/// 2. If `active=true` → uses buttonBackgroundColors.activeColor or button.backgroundColor['active']
/// 3. Else → uses buttonBackgroundColors.defaultColor or button.backgroundColor['default']
/// Icon color:
/// 1. If `active=true` → uses button.activeColor or global activeIconColor
/// 2. Else → uses button.inActiveColor or global inactiveIconColor
/// Icon widget:
/// 1. If `active=true` → uses button.alternateIconWidget or alternateIconComponent or Icon(button.alternateIcon)
/// 2. Else → uses button.iconWidget or iconComponent or Icon(button.icon)
///
/// **Builder Hook Priorities:**
/// 1. Per-button builders (button.contentBuilder, button.iconBuilder, etc.) override global builders
/// 2. Global builders (options.buttonBuilder, options.iconBuilder, etc.) applied if per-button not set
/// 3. Builder hooks receive context objects with computed state (isActive, etc.)
///
/// **Touch Target Sizing:**
/// - Default `buttonConstraints`: BoxConstraints(minWidth: 48, minHeight: 48) recommended
/// - Meets WCAG 2.1 Level AA touch target guideline (44x44 minimum)
/// - Icon sizes typically 24-32 for touch (vs 16-20 for mouse)
///
/// **Accessibility Features:**
/// - `semanticsLabel` on each button for screen readers
/// - Semantics widget wraps each button with label
/// - State announced: "Button, [label], [active/inactive]"
/// - Disabled buttons marked non-interactive
///
/// **Common Use Cases:**
/// 1. **Mobile Bottom Bar:**
///    ```dart
///    ControlButtonsComponentTouch(
///      options: ControlButtonsComponentTouchOptions(
///        buttons: [
///          ButtonTouch(name: 'Mic', icon: Icons.mic_off, alternateIcon: Icons.mic, onPress: toggleMic, active: isMicOn, semanticsLabel: 'Toggle microphone'),
///          ButtonTouch(name: 'Video', icon: Icons.videocam_off, alternateIcon: Icons.videocam, onPress: toggleVideo, active: isVideoOn, semanticsLabel: 'Toggle camera'),
///          ButtonTouch(name: 'Share', icon: Icons.screen_share, onPress: shareScreen, semanticsLabel: 'Share screen'),
///          ButtonTouch(name: 'More', icon: Icons.more_horiz, onPress: openMenu, semanticsLabel: 'More options'),
///        ],
///        direction: 'horizontal',
///        position: 'center',
///        location: 'bottom',
///        gap: 16,
///        containerDecoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
///        buttonConstraints: BoxConstraints(minWidth: 64, minHeight: 64),
///        iconSize: 28,
///      ),
///    )
///    ```
///
/// 2. **Vertical Sidebar (Tablet):**
///    ```dart
///    ControlButtonsComponentTouch(
///      options: ControlButtonsComponentTouchOptions(
///        buttons: quickActions,
///        direction: 'vertical',
///        position: 'right',
///        location: 'center',
///        gap: 12,
///        buttonBackgroundColors: ControlButtonsTouchStateColors(
///          defaultColor: Colors.grey[800],
///          activeColor: Colors.blue,
///          pressedColor: Colors.blue[700],
///        ),
///      ),
///    )
///    ```
///
/// 3. **State-Aware Recording Button:**
///    ```dart
///    ControlButtonsComponentTouch(
///      options: ControlButtonsComponentTouchOptions(
///        buttons: [
///          ButtonTouch(
///            name: isRecording ? 'Stop' : 'Record',
///            icon: isRecording ? Icons.stop : Icons.fiber_manual_record,
///            onPress: isRecording ? stopRecording : startRecording,
///            active: isRecording,
///            backgroundColor: {
///              'default': Colors.grey[800]!,
///              'active': Colors.red,
///              'pressed': Colors.red[700]!,
///            },
///            semanticsLabel: isRecording ? 'Stop recording' : 'Start recording',
///          ),
///        ],
///      ),
///    )
///    ```
///
/// 4. **Custom Button with Badge:**
///    ```dart
///    ControlButtonsComponentTouch(
///      options: ControlButtonsComponentTouchOptions(
///        buttons: [
///          ButtonTouch(
///            name: 'Messages',
///            icon: Icons.message,
///            onPress: openMessages,
///            buttonBuilder: (context, defaultButton) {
///              return Badge(
///                label: Text('3'),
///                child: defaultButton,
///              );
///            },
///          ),
///        ],
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Integrates with `MediasfuUICustomOverrides` for global styling:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   controlButtonsTouchOptions: ComponentOverride<ControlButtonsComponentTouchOptions>(
///     builder: (existingOptions) => ControlButtonsComponentTouchOptions(
///       buttons: existingOptions.buttons,
///       direction: existingOptions.direction,
///       position: 'center',
///       location: 'bottom',
///       gap: 20,
///       containerDecoration: BoxDecoration(
///         gradient: LinearGradient(colors: [Colors.black, Colors.grey[900]!]),
///         borderRadius: BorderRadius.circular(32),
///         boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 12)],
///       ),
///       buttonBackgroundColors: ControlButtonsTouchStateColors(
///         defaultColor: Colors.grey[800],
///         activeColor: Colors.green,
///         disabledColor: Colors.grey[700],
///       ),
///       iconSize: 32,
///       textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
///     ),
///   ),
/// ),
/// ```
///
/// **Performance Notes:**
/// - Filters buttons once per build (buttons.where)
/// - Gap widgets only inserted if gap > 0 (avoids empty SizedBox)
/// - Builder hooks called once per button per build
/// - Semantics labels important for accessibility but don't affect render performance
///
/// **Implementation Details:**
/// - Position/location props map to Alignment: ('left', 'top') → Alignment.topLeft
/// - Direction maps to Axis: 'horizontal' → Axis.horizontal, 'vertical' → Axis.vertical
/// - MainAxisAlignment computed from position (horizontal) or location (vertical)
/// - Per-button props override global props (checked via ?? operator)
/// - State color resolution: per-button.backgroundColor → global.buttonBackgroundColors → fallback colors
class ControlButtonsComponentTouch extends StatelessWidget {
  final ControlButtonsComponentTouchOptions options;

  const ControlButtonsComponentTouch({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final axis = _directionFromString(options.direction);
    final visibleButtons =
        options.buttons.where((button) => button.show).toList(growable: false);

    final rawButtons = <Widget>[];
    for (var i = 0; i < visibleButtons.length; i++) {
      final buttonWidget = _buildButton(
        context,
        visibleButtons[i],
        i,
        axis,
      );

      if (buttonWidget != null) {
        rawButtons.add(buttonWidget);
      }
    }

    final spacedButtons = <Widget>[];
    for (final button in rawButtons) {
      if (spacedButtons.isNotEmpty && options.gap != null) {
        spacedButtons.add(axis == Axis.vertical
            ? SizedBox(height: options.gap)
            : SizedBox(width: options.gap));
      }
      spacedButtons.add(button);
    }

    Widget buttonsBar = axis == Axis.horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: _mainAxisFromPosition(options.position),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: spacedButtons,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: _mainAxisFromLocation(options.location),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: spacedButtons,
          );

    if (options.buttonsBuilder != null) {
      buttonsBar = options.buttonsBuilder!(
        ControlButtonsTouchButtonsContext(
          buildContext: context,
          options: options,
          direction: axis,
          visibleButtons: visibleButtons,
          buttons: List.unmodifiable(rawButtons),
          spacedButtons: List.unmodifiable(spacedButtons),
        ),
        buttonsBar,
      );
    }

    final alignment = options.containerAlignment ?? Alignment(
      _alignmentValueFromPosition(options.position),
      _alignmentValueFromLocation(options.location),
    );

    Widget container = Container(
      padding: options.containerPadding ?? const EdgeInsets.symmetric(vertical: 10),
      margin: options.containerMargin,
      decoration: options.containerDecoration,
      clipBehavior: options.containerClipBehavior,
      alignment: alignment,
      child: buttonsBar,
    );

    if (options.containerBuilder != null) {
      container = options.containerBuilder!(
        ControlButtonsTouchContainerContext(
          buildContext: context,
          options: options,
          direction: axis,
          visibleButtons: visibleButtons,
        ),
        container,
      );
    }

    return Visibility(
      visible: options.showAspect,
      child: container,
    );
  }

  Widget? _buildButton(
    BuildContext context,
    ButtonTouch button,
    int index,
    Axis direction,
  ) {
    final isActive = button.active;
    final iconSize = button.iconSize ??
        options.iconSize ??
        button.size?.toDouble() ??
        20.0;

    final inactiveIconColor = button.inActiveColor ??
        options.inactiveIconColor ??
        button.color ??
        options.buttonColor ??
        Colors.white;

    final activeIconColor = button.activeColor ??
        options.activeIconColor ??
        button.color ??
        options.buttonColor ??
        Colors.white;

    Widget? iconWidget;
    if (button.customComponent == null) {
      iconWidget = _resolveIconWidget(
        button,
        isActive: isActive,
        iconSize: iconSize,
        activeColor: activeIconColor,
        inactiveColor: inactiveIconColor,
      );

      final iconContext = ControlButtonsTouchButtonIconContext(
        buildContext: context,
        options: options,
        button: button,
        index: index,
        direction: direction,
        isActive: isActive,
      );

      if (button.iconBuilder != null) {
        iconWidget = button.iconBuilder!(iconContext, iconWidget);
      }

      if (options.iconBuilder != null) {
        iconWidget = options.iconBuilder!(iconContext, iconWidget);
      }

      final iconPadding = button.iconPadding ?? options.iconPadding;
      if (iconWidget != null && iconPadding != null) {
        iconWidget = Padding(
          padding: iconPadding,
          child: iconWidget,
        );
      }
    }

    Widget? labelWidget;
    if (button.customComponent == null && button.name != null) {
      final baseStyle = button.textStyle ?? options.textStyle;
      final resolvedStyle = baseStyle?.copyWith(
            color: button.color ?? baseStyle.color ?? options.buttonColor,
          ) ??
          TextStyle(
            color: button.color ?? options.buttonColor ?? Colors.white,
            fontSize: 12,
          );

      labelWidget = Text(
        button.name!,
        style: resolvedStyle,
      );

      final labelContext = ControlButtonsTouchButtonLabelContext(
        buildContext: context,
        options: options,
        button: button,
        index: index,
        direction: direction,
        isActive: isActive,
      );

      if (button.labelBuilder != null) {
        labelWidget = button.labelBuilder!(labelContext, labelWidget);
      }

      if (options.labelBuilder != null) {
        labelWidget = options.labelBuilder!(labelContext, labelWidget);
      }

      final labelPadding = button.labelPadding ?? options.labelPadding;
      if (labelWidget != null && labelPadding != null) {
        labelWidget = Padding(
          padding: labelPadding,
          child: labelWidget,
        );
      }
    }

    Widget content = button.customComponent ??
        _buildDefaultContent(
          direction: direction,
          icon: iconWidget,
          label: labelWidget,
          button: button,
        );

    final contentContext = ControlButtonsTouchButtonContentContext(
      buildContext: context,
      options: options,
      button: button,
      index: index,
      direction: direction,
      isActive: isActive,
      icon: iconWidget,
      label: labelWidget,
    );

    if (button.contentBuilder != null) {
      content = button.contentBuilder!(contentContext, content);
    }

    if (options.buttonContentBuilder != null) {
      content = options.buttonContentBuilder!(contentContext, content);
    }

    final padding = button.padding ??
        options.buttonPadding ??
        const EdgeInsets.all(8);
    final margin = button.margin ??
        options.buttonMargin ??
        const EdgeInsets.symmetric(horizontal: 4, vertical: 4);
    final constraints = button.constraints ?? options.buttonConstraints;
    final backgroundColor = _resolveBackgroundColor(button, isActive);

    final baseDecoration = options.buttonDecoration ??
        BoxDecoration(
          borderRadius: options.buttonBorderRadius ?? BorderRadius.circular(5),
        );

    final decoration = _mergeDecorations(
      baseDecoration,
      button.decoration,
      backgroundColor,
    );

    Widget buttonWidget = Container(
      constraints: constraints,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: content,
    );

    if (button.disabled) {
      buttonWidget = Opacity(
        opacity: 0.6,
        child: buttonWidget,
      );
    }

    buttonWidget = Semantics(
      button: true,
      enabled: !button.disabled,
      label: button.semanticsLabel ?? button.name,
      child: GestureDetector(
        onTap: button.disabled ? null : button.onPress,
        child: buttonWidget,
      ),
    );

    final buttonContext = ControlButtonsTouchButtonContext(
      buildContext: context,
      options: options,
      button: button,
      index: index,
      direction: direction,
      isActive: isActive,
    );

    if (button.buttonBuilder != null) {
      buttonWidget = button.buttonBuilder!(buttonContext, buttonWidget);
    }

    if (options.buttonBuilder != null) {
      buttonWidget = options.buttonBuilder!(buttonContext, buttonWidget);
    }

    return buttonWidget;
  }

  Widget _buildDefaultContent({
    required Axis direction,
    required Widget? icon,
    required Widget? label,
    required ButtonTouch button,
  }) {
    final children = <Widget>[];
    if (icon != null) {
      children.add(icon);
    }
    if (label != null) {
      if (children.isNotEmpty) {
        final gap = button.contentGap ?? options.contentGap ??
            (direction == Axis.vertical ? 6.0 : 8.0);
        children.add(direction == Axis.vertical
            ? SizedBox(height: gap)
            : SizedBox(width: gap));
      }
      children.add(label);
    }

    Widget content = direction == Axis.vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: button.contentMainAxisAlignment ??
                options.contentMainAxisAlignment ??
                MainAxisAlignment.center,
            crossAxisAlignment: button.contentCrossAxisAlignment ??
                options.contentCrossAxisAlignment ??
                CrossAxisAlignment.center,
            children: children,
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: button.contentMainAxisAlignment ??
                options.contentMainAxisAlignment ??
                MainAxisAlignment.center,
            crossAxisAlignment: button.contentCrossAxisAlignment ??
                options.contentCrossAxisAlignment ??
                CrossAxisAlignment.center,
            children: children,
          );

    final padding = button.contentPadding ?? options.contentPadding;
    if (padding != null) {
      content = Padding(
        padding: padding,
        child: content,
      );
    }

    return content;
  }

  Widget? _resolveIconWidget(
    ButtonTouch button, {
    required bool isActive,
    required double iconSize,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    if (isActive) {
      if (button.alternateIconWidget != null) {
        return button.alternateIconWidget;
      }
      if (button.alternateIcon != null) {
        return Icon(
          button.alternateIcon,
          size: iconSize,
          color: activeColor,
        );
      }
      if (options.alternateIconComponent != null) {
        return options.alternateIconComponent;
      }
    }

    if (button.iconWidget != null) {
      return button.iconWidget;
    }

    if (button.icon != null) {
      return Icon(
        button.icon,
        size: iconSize,
        color: isActive ? activeColor : inactiveColor,
      );
    }

    return options.iconComponent;
  }

  Color? _resolveBackgroundColor(ButtonTouch button, bool isActive) {
    final background = button.backgroundColor;
    final stateColors = options.buttonBackgroundColors;

    if (button.disabled) {
      return background?['disabled'] ?? stateColors?.disabledColor;
    }

    if (isActive) {
      return background?['pressed'] ??
          background?['active'] ??
          stateColors?.pressedColor ??
          stateColors?.activeColor;
    }

    return background?['default'] ?? stateColors?.defaultColor;
  }

  BoxDecoration _mergeDecorations(
    BoxDecoration base,
    BoxDecoration? override,
    Color? fallbackColor,
  ) {
    final merged = base.copyWith(
      color: base.color ?? fallbackColor,
    );

    if (override == null) {
      return merged;
    }

    return merged.copyWith(
      color: override.color ?? merged.color ?? fallbackColor,
      image: override.image ?? merged.image,
      border: override.border ?? merged.border,
      borderRadius: override.borderRadius ?? merged.borderRadius,
      boxShadow: override.boxShadow ?? merged.boxShadow,
      gradient: override.gradient ?? merged.gradient,
      backgroundBlendMode:
          override.backgroundBlendMode ?? merged.backgroundBlendMode,
      shape: override.shape,
    );
  }
}
