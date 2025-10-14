import 'package:flutter/material.dart';

class ControlButtonsAltWrapperContext {
  final BuildContext buildContext;
  final ControlButtonsAltComponentOptions options;
  final Widget child;
  final Widget defaultWrapper;

  const ControlButtonsAltWrapperContext({
    required this.buildContext,
    required this.options,
    required this.child,
    required this.defaultWrapper,
  });
}

class ControlButtonsAltContainerContext {
  final BuildContext buildContext;
  final ControlButtonsAltComponentOptions options;
  final Widget child;
  final Widget defaultContainer;

  const ControlButtonsAltContainerContext({
    required this.buildContext,
    required this.options,
    required this.child,
    required this.defaultContainer,
  });
}

class ControlButtonsAltLayoutContext {
  final BuildContext buildContext;
  final ControlButtonsAltComponentOptions options;
  final List<Widget> buttons;
  final Widget defaultLayout;

  const ControlButtonsAltLayoutContext({
    required this.buildContext,
    required this.options,
    required this.buttons,
    required this.defaultLayout,
  });
}

class ControlButtonsAltButtonContext {
  final BuildContext buildContext;
  final ControlButtonsAltComponentOptions options;
  final AltButton button;
  final Widget defaultButton;

  const ControlButtonsAltButtonContext({
    required this.buildContext,
    required this.options,
    required this.button,
    required this.defaultButton,
  });
}

/// AltButton - Represents a configurable button within the control button component.
///
/// ### Example Usage:
/// ```dart
/// ControlButton(
///   name: 'Mute',
///   icon: Icons.mic_off,
///   alternateIcon: Icons.mic,
///   onPress: () => print('Muted'),
///   defaultBackgroundColor: Colors.grey,
///   pressedBackgroundColor: Colors.blue,
///   active: true,
///   activeColor: Colors.green,
///   inActiveColor: Colors.red,
///   show: true,
///   disabled: false,
/// );
/// ```

class AltButton {
  /// The display name of the button.
  final String? name;

  /// The primary icon of the button.
  final IconData? icon;

  /// The alternate icon displayed when the button is active.
  final IconData? alternateIcon;

  /// The callback function triggered when the button is pressed.
  final VoidCallback? onPress;

  /// The default background color of the button.
  final Color? defaultBackgroundColor;

  /// The background color of the button when pressed or active.
  final Color? pressedBackgroundColor;

  /// Indicates whether the button is in an active state.
  final bool active;

  /// The color of the icon when the button is active.
  final Color? activeColor;

  /// The color of the icon when the button is inactive.
  final Color? inActiveColor;

  /// The color of the text label.
  final Color? textColor;

  /// Indicates whether the button should be displayed.
  final bool show;

  /// If true, the button is disabled and non-interactive.
  final bool disabled;

  /// A custom widget to replace the default icon and text layout.
  final Widget? customComponent;

  AltButton({
    this.name,
    this.icon,
    this.alternateIcon,
    this.onPress,
    this.defaultBackgroundColor,
    this.pressedBackgroundColor,
    this.active = false,
    this.activeColor,
    this.inActiveColor,
    this.textColor,
    this.show = true,
    this.disabled = false,
    this.customComponent,
  });
}

typedef ControlButtonsAltComponentType = Widget Function(
    {required ControlButtonsAltComponentOptions options});

typedef ControlButtonsAltWrapperBuilder = Widget Function(
  ControlButtonsAltWrapperContext context,
);

typedef ControlButtonsAltContainerBuilder = Widget Function(
  ControlButtonsAltContainerContext context,
);

typedef ControlButtonsAltLayoutBuilder = Widget Function(
  ControlButtonsAltLayoutContext context,
);

typedef ControlButtonsAltButtonBuilder = Widget Function(
  ControlButtonsAltButtonContext context,
);

/// Configuration options for the `ControlButtonsAltComponent`.
///
/// Provides properties to customize an alternative control button bar with flexible
/// positioning, alignment, and layout direction. Similar to `ControlButtonsComponent`
/// but with different default styling and layout options.
///
/// **Core Properties:**
/// - `buttons`: List of AltButton objects defining each button (icon, callback, colors, active state)
/// - `showAspect`: If false, hides entire component; useful for conditional visibility
///
/// **Layout Configuration:**
/// - `direction`: Button arrangement: 'horizontal' (default) or 'vertical'
/// - `position`: Horizontal alignment: 'left', 'right', 'center' (default: 'left')
/// - `location`: Vertical alignment: 'top' (default), 'bottom', 'center'
///
/// **Styling:**
/// - `buttonsContainerStyle`: BoxDecoration for button group container
/// - `containerPadding`/`containerMargin`/`containerAlignment`: Outer container layout
///
/// **Icon Components:**
/// - `iconComponent`: Custom widget replacing default inactive icon display
/// - `alternateIconComponent`: Custom widget replacing default active icon display
///
/// **Builder Hooks (4):**
/// - `customBuilder`: Full widget replacement; receives ControlButtonsAltComponentOptions
/// - `wrapperBuilder`: Override outer wrapper; receives child + default
/// - `containerBuilder`: Override container; receives child + default
/// - `layoutBuilder`: Override button layout (Row/Column); receives buttons + default
/// - `buttonBuilder`: Override individual buttons; receives AltButton + default
///
/// **AltButton Properties:**
/// Each button in `buttons` array supports:
/// - `name`: Display label text
/// - `icon`: Primary icon (inactive state)
/// - `alternateIcon`: Icon shown when `active=true`
/// - `onPress`: Callback function on tap
/// - `defaultBackgroundColor`: Background when inactive
/// - `pressedBackgroundColor`: Background when active
/// - `active`: Toggle state (affects icon and color)
/// - `activeColor`/`inActiveColor`: Icon tint colors
/// - `textColor`: Label text color
/// - `show`: If false, hides this button
/// - `disabled`: If true, makes button non-interactive
/// - `customComponent`: Custom widget replacing icon+label
///
/// **Usage Patterns:**
/// 1. **Basic Horizontal Bar:**
///    ```dart
///    ControlButtonsAltComponent(
///      options: ControlButtonsAltComponentOptions(
///        buttons: [
///          AltButton(
///            name: 'Mic',
///            icon: Icons.mic_off,
///            alternateIcon: Icons.mic,
///            onPress: toggleMic,
///            active: isMicOn,
///            activeColor: Colors.green,
///            inActiveColor: Colors.red,
///          ),
///          AltButton(
///            name: 'Camera',
///            icon: Icons.videocam_off,
///            alternateIcon: Icons.videocam,
///            onPress: toggleCamera,
///            active: isCameraOn,
///          ),
///        ],
///        direction: 'horizontal',
///        position: 'center',
///        location: 'bottom',
///      ),
///    )
///    ```
///
/// 2. **Vertical Sidebar:**
///    ```dart
///    ControlButtonsAltComponent(
///      options: ControlButtonsAltComponentOptions(
///        buttons: controlButtons,
///        direction: 'vertical',
///        position: 'right',
///        location: 'center',
///        buttonsContainerStyle: BoxDecoration(
///          color: Colors.black54,
///          borderRadius: BorderRadius.circular(8),
///        ),
///      ),
///    )
///    ```
///
/// 3. **Custom Button Renderer:**
///    ```dart
///    ControlButtonsAltComponent(
///      options: ControlButtonsAltComponentOptions(
///        buttons: buttons,
///        buttonBuilder: (context) {
///          final button = context.button;
///          return Tooltip(
///            message: button.name ?? '',
///            child: context.defaultButton,
///          );
///        },
///      ),
///    )
///    ```
///
/// 4. **Conditional Visibility:**
///    ```dart
///    ControlButtonsAltComponent(
///      options: ControlButtonsAltComponentOptions(
///        buttons: [
///          AltButton(name: 'Share', icon: Icons.screen_share, onPress: shareScreen, show: canShare),
///          AltButton(name: 'Record', icon: Icons.fiber_manual_record, onPress: startRecord, show: isHost),
///        ],
///        showAspect: isMediaControlsVisible,
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Can be overridden via `MediasfuUICustomOverrides`:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   controlButtonsAltOptions: ComponentOverride<ControlButtonsAltComponentOptions>(
///     builder: (existingOptions) => ControlButtonsAltComponentOptions(
///       buttons: existingOptions.buttons,
///       position: 'center',
///       location: 'bottom',
///       buttonsContainerStyle: BoxDecoration(
///         gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
///         borderRadius: BorderRadius.circular(24),
///       ),
///     ),
///   ),
/// ),
/// ```
///
/// **Differences from ControlButtonsComponent:**
/// - Uses AltButton model (different properties than ControlButton)
/// - position/location props for flexible alignment (vs fixed positioning)
/// - Simpler layout (no row/column gap props)
/// - Different default styling approach
/// - No icon+content separate builders (unified buttonBuilder)
class ControlButtonsAltComponentOptions {
  /// An array of button configurations to render within the component.
  final List<AltButton> buttons;

  /// Specifies the horizontal alignment of the buttons within the container.
  /// Options: 'left', 'right', 'center'.
  final String position;

  /// Specifies the vertical alignment of the buttons within the container.
  /// Options: 'top', 'bottom', 'center'.
  final String location;

  /// Determines the layout direction of the buttons.
  /// Options: 'horizontal', 'vertical'.
  final String direction;

  /// Additional styling for the container holding the buttons.
  final BoxDecoration? buttonsContainerStyle;

  /// Custom builder to replace the entire component.
  final ControlButtonsAltComponentType? customBuilder;

  /// Padding applied to the container wrapping the buttons.
  final EdgeInsetsGeometry? containerPadding;

  /// Margin applied to the container wrapping the buttons.
  final EdgeInsetsGeometry? containerMargin;

  /// Alignment of the container's child.
  final AlignmentGeometry? containerAlignment;

  /// Builder to override the wrapper surrounding the layout.
  final ControlButtonsAltWrapperBuilder? wrapperBuilder;

  /// Builder to override the top-level container.
  final ControlButtonsAltContainerBuilder? containerBuilder;

  /// Builder to override the layout that arranges the buttons.
  final ControlButtonsAltLayoutBuilder? layoutBuilder;

  /// Builder to override individual buttons.
  final ControlButtonsAltButtonBuilder? buttonBuilder;

  /// A custom widget to display in place of the default icon component when the button is active.
  final Widget? alternateIconComponent;

  /// A custom widget to display in place of the default icon component when the button is inactive.
  final Widget? iconComponent;

  /// Controls the visibility of the widget.
  final bool showAspect;

  ControlButtonsAltComponentOptions({
    required this.buttons,
    this.position = 'left',
    this.location = 'top',
    this.direction = 'horizontal',
    this.buttonsContainerStyle,
    this.alternateIconComponent,
    this.iconComponent,
    this.showAspect = true,
    this.customBuilder,
    this.containerPadding,
    this.containerMargin,
    this.containerAlignment,
    this.wrapperBuilder,
    this.containerBuilder,
    this.layoutBuilder,
    this.buttonBuilder,
  });
}

/// A stateless widget rendering an alternative control button bar with flexible positioning.
///
/// Displays a row or column of interactive buttons (AltButton) with customizable alignment,
/// layout direction, and styling. Alternative to `ControlButtonsComponent` with different
/// layout options (position/location props vs fixed positioning).
///
/// **Rendering Logic:**
/// 1. If `showAspect=false` → returns empty Container
/// 2. If `customBuilder` provided → delegates full rendering
/// 3. Filters buttons: only renders buttons where `show=true`
/// 4. Builds layout: Row (horizontal) or Column (vertical) containing buttons
/// 5. Wraps layout in Container with alignment (position/location)
/// 6. Applies builder hooks at each layer
///
/// **Layout Structure:**
/// ```
/// Container (wrapperBuilder)
///   └─ Container (containerBuilder)
///      └─ Align (position/location → Alignment)
///         └─ Row/Column (layoutBuilder)
///            ├─ GestureDetector (buttonBuilder)
///            │  └─ Container (button background)
///            │     └─ Column
///            │        ├─ Icon (or alternateIcon if active)
///            │        └─ Text (button.name)
///            ├─ GestureDetector ...
///            └─ ...
/// ```
///
/// **Button Rendering:**
/// Each AltButton becomes:
/// - GestureDetector (onTap → button.onPress)
/// - Container (background color: defaultBackgroundColor or pressedBackgroundColor if active)
/// - Column with:
///   - Icon (uses icon or alternateIcon based on active state)
///   - Text (button.name)
/// - Icon color: activeColor if active, else inActiveColor
/// - Opacity: 0.5 if disabled, else 1.0
///
/// **Position/Location Mapping:**
/// - `position='left'` + `location='top'` → Alignment.topLeft
/// - `position='center'` + `location='bottom'` → Alignment.bottomCenter
/// - `position='right'` + `location='center'` → Alignment.centerRight
/// - All 9 combinations of (left/center/right) × (top/center/bottom) supported
///
/// **Builder Hook Priorities:**
/// - `customBuilder` → full widget replacement (ignores all other props)
/// - `wrapperBuilder` → wraps outer container; receives child + default
/// - `containerBuilder` → wraps inner container; receives child + default
/// - `layoutBuilder` → wraps Row/Column; receives buttons list + default
/// - `buttonBuilder` → wraps individual button; receives AltButton + default
///
/// **Common Use Cases:**
/// 1. **Bottom Control Bar:**
///    ```dart
///    ControlButtonsAltComponent(
///      options: ControlButtonsAltComponentOptions(
///        buttons: [
///          AltButton(name: 'Mic', icon: Icons.mic_off, onPress: toggleMic),
///          AltButton(name: 'Video', icon: Icons.videocam_off, onPress: toggleVideo),
///          AltButton(name: 'Share', icon: Icons.screen_share, onPress: shareScreen),
///        ],
///        direction: 'horizontal',
///        position: 'center',
///        location: 'bottom',
///      ),
///    )
///    ```
///
/// 2. **Right Sidebar (Vertical):**
///    ```dart
///    ControlButtonsAltComponent(
///      options: ControlButtonsAltComponentOptions(
///        buttons: quickActions,
///        direction: 'vertical',
///        position: 'right',
///        location: 'center',
///        buttonsContainerStyle: BoxDecoration(color: Colors.black54),
///      ),
///    )
///    ```
///
/// 3. **Conditional Button Visibility:**
///    ```dart
///    ControlButtonsAltComponent(
///      options: ControlButtonsAltComponentOptions(
///        buttons: [
///          AltButton(name: 'Host Controls', icon: Icons.settings, onPress: openHostMenu, show: isHost),
///          AltButton(name: 'Leave', icon: Icons.exit_to_app, onPress: leaveRoom),
///        ],
///        position: 'left',
///        location: 'top',
///      ),
///    )
///    ```
///
/// 4. **Custom Button Wrapper:**
///    ```dart
///    ControlButtonsAltComponent(
///      options: ControlButtonsAltComponentOptions(
///        buttons: buttons,
///        buttonBuilder: (context) {
///          final button = context.button;
///          return Badge(
///            label: button.active ? Text('ON') : null,
///            child: context.defaultButton,
///          );
///        },
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Integrates with `MediasfuUICustomOverrides` for global styling:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   controlButtonsAltOptions: ComponentOverride<ControlButtonsAltComponentOptions>(
///     builder: (existingOptions) => ControlButtonsAltComponentOptions(
///       buttons: existingOptions.buttons,
///       direction: existingOptions.direction,
///       position: 'center',
///       location: 'bottom',
///       buttonsContainerStyle: BoxDecoration(
///         color: Colors.black87,
///         borderRadius: BorderRadius.circular(32),
///         boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
///       ),
///     ),
///   ),
/// ),
/// ```
///
/// **Active State Behavior:**
/// - When `active=true`: uses `alternateIcon` (if provided) and `activeColor`
/// - When `active=false`: uses `icon` and `inActiveColor`
/// - Background color switches between `defaultBackgroundColor` and `pressedBackgroundColor`
///
/// **Disabled State:**
/// - Reduces opacity to 0.5
/// - onPress callback still fires (caller should handle disabled logic)
///
/// **Implementation Notes:**
/// - Filters buttons before rendering (only `show=true` buttons)
/// - Direction prop directly maps to Row (horizontal) or Column (vertical)
/// - Position+location props combined into single Alignment value
/// - Builder hooks receive both context and default widget for wrapping patterns
class ControlButtonsAltComponent extends StatelessWidget {
  final ControlButtonsAltComponentOptions options;

  const ControlButtonsAltComponent({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    if (options.customBuilder != null) {
      return options.customBuilder!(options: options);
    }

    if (!options.showAspect) {
      return const SizedBox.shrink();
    }

    final buttons = _buildButtons(context);
    final layout = _buildLayout(context, buttons);

    final defaultWrapper = layout;
    final wrapper = options.wrapperBuilder?.call(
          ControlButtonsAltWrapperContext(
            buildContext: context,
            options: options,
            child: layout,
            defaultWrapper: defaultWrapper,
          ),
        ) ??
        defaultWrapper;

    final defaultContainer = Container(
      margin:
          options.containerMargin ?? const EdgeInsets.symmetric(vertical: 5),
      decoration: options.buttonsContainerStyle,
      padding: options.containerPadding ?? const EdgeInsets.all(5),
      alignment: options.containerAlignment,
      child: wrapper,
    );

    final container = options.containerBuilder?.call(
          ControlButtonsAltContainerContext(
            buildContext: context,
            options: options,
            child: wrapper,
            defaultContainer: defaultContainer,
          ),
        ) ??
        defaultContainer;

    return Visibility(
      visible: options.showAspect,
      child: container,
    );
  }

  /// Builds the button layout based on the [direction] property.
  Widget _buildLayout(BuildContext context, List<Widget> buttons) {
    Widget defaultLayout;
    if (options.direction == 'horizontal') {
      defaultLayout = Column(
        mainAxisAlignment: _getVerticalMainAxisAlignment(),
        children: [
          Row(
            mainAxisAlignment: _getHorizontalMainAxisAlignment(),
            children: buttons,
          ),
        ],
      );
    } else {
      defaultLayout = Row(
        mainAxisAlignment: _getHorizontalMainAxisAlignment(),
        children: [
          Column(
            mainAxisAlignment: _getVerticalMainAxisAlignment(),
            children: buttons,
          ),
        ],
      );
    }

    return options.layoutBuilder?.call(
          ControlButtonsAltLayoutContext(
            buildContext: context,
            options: options,
            buttons: buttons,
            defaultLayout: defaultLayout,
          ),
        ) ??
        defaultLayout;
  }

  /// Determines the horizontal alignment based on [position].
  MainAxisAlignment _getHorizontalMainAxisAlignment() {
    switch (options.position) {
      case 'right':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'left':
      default:
        return MainAxisAlignment.start;
    }
  }

  /// Determines the vertical alignment based on [location].
  MainAxisAlignment _getVerticalMainAxisAlignment() {
    switch (options.location) {
      case 'bottom':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'top':
      default:
        return MainAxisAlignment.start;
    }
  }

  /// Builds the list of button widgets based on the [buttons] configuration.
  List<Widget> _buildButtons(BuildContext context) {
    return options.buttons.map((button) {
      if (!button.show) return const SizedBox.shrink();

      final Widget defaultButton = GestureDetector(
        onTap: button.disabled ? null : button.onPress,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          decoration: BoxDecoration(
            color: button.active
                ? (button.pressedBackgroundColor ?? Colors.grey)
                : (button.defaultBackgroundColor ?? Colors.transparent),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (button.customComponent != null)
                button.customComponent!
              else ...[
                if (button.icon != null)
                  _buildButtonIcon(button),
                if (button.name != null)
                  Text(
                    button.name!,
                    style: TextStyle(
                      color: button.textColor ?? Colors.white,
                      fontSize: 12,
                    ),
                  ),
              ],
            ],
          ),
        ),
      );

      return options.buttonBuilder?.call(
            ControlButtonsAltButtonContext(
              buildContext: context,
              options: options,
              button: button,
              defaultButton: defaultButton,
            ),
          ) ??
          defaultButton;
    }).toList();
  }

  Widget _buildButtonIcon(AltButton button) {
    if (button.active && options.alternateIconComponent != null) {
      return options.alternateIconComponent!;
    }

    if (!button.active && options.iconComponent != null) {
      return options.iconComponent!;
    }

    return Icon(
      button.active ? (button.alternateIcon ?? button.icon) : button.icon,
      size: 16,
      color: button.active
          ? (button.activeColor ?? Colors.white)
          : (button.inActiveColor ?? Colors.white),
    );
  }
}
