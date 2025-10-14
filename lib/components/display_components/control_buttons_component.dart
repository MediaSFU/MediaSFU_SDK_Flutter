import 'package:flutter/material.dart';

class ControlButtonsContainerContext {
  final BuildContext buildContext;
  final ControlButtonsComponentOptions options;
  final Axis direction;
  final List<ControlButton> visibleButtons;

  const ControlButtonsContainerContext({
    required this.buildContext,
    required this.options,
    required this.direction,
    required this.visibleButtons,
  });
}

class ControlButtonsButtonsContext {
  final BuildContext buildContext;
  final ControlButtonsComponentOptions options;
  final Axis direction;
  final List<ControlButton> visibleButtons;
  final List<Widget> buttons;
  final List<Widget> spacedButtons;

  const ControlButtonsButtonsContext({
    required this.buildContext,
    required this.options,
    required this.direction,
    required this.visibleButtons,
    required this.buttons,
    required this.spacedButtons,
  });
}

class ControlButtonsButtonContext {
  final BuildContext buildContext;
  final ControlButtonsComponentOptions options;
  final ControlButton button;
  final int index;
  final Axis direction;
  final bool isActive;

  const ControlButtonsButtonContext({
    required this.buildContext,
    required this.options,
    required this.button,
    required this.index,
    required this.direction,
    required this.isActive,
  });
}

class ControlButtonsButtonContentContext {
  final BuildContext buildContext;
  final ControlButtonsComponentOptions options;
  final ControlButton button;
  final int index;
  final Axis direction;
  final bool isActive;
  final Widget? icon;
  final Widget? label;

  const ControlButtonsButtonContentContext({
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

class ControlButtonsButtonIconContext {
  final BuildContext buildContext;
  final ControlButtonsComponentOptions options;
  final ControlButton button;
  final int index;
  final Axis direction;
  final bool isActive;

  const ControlButtonsButtonIconContext({
    required this.buildContext,
    required this.options,
    required this.button,
    required this.index,
    required this.direction,
    required this.isActive,
  });
}

class ControlButtonsButtonLabelContext {
  final BuildContext buildContext;
  final ControlButtonsComponentOptions options;
  final ControlButton button;
  final int index;
  final Axis direction;
  final bool isActive;

  const ControlButtonsButtonLabelContext({
    required this.buildContext,
    required this.options,
    required this.button,
    required this.index,
    required this.direction,
    required this.isActive,
  });
}

typedef ControlButtonsContainerBuilder = Widget Function(
  ControlButtonsContainerContext context,
  Widget defaultContainer,
);

typedef ControlButtonsButtonsBuilder = Widget Function(
  ControlButtonsButtonsContext context,
  Widget defaultButtons,
);

typedef ControlButtonsButtonBuilder = Widget Function(
  ControlButtonsButtonContext context,
  Widget defaultButton,
);

typedef ControlButtonsButtonContentBuilder = Widget Function(
  ControlButtonsButtonContentContext context,
  Widget defaultContent,
);

typedef ControlButtonsButtonIconBuilder = Widget? Function(
  ControlButtonsButtonIconContext context,
  Widget? defaultIcon,
);

typedef ControlButtonsButtonLabelBuilder = Widget? Function(
  ControlButtonsButtonLabelContext context,
  Widget? defaultLabel,
);

class ControlButtonStateColors {
  final Color? defaultColor;
  final Color? activeColor;
  final Color? disabledColor;
  final Color? pressedColor;

  const ControlButtonStateColors({
    this.defaultColor,
    this.activeColor,
    this.disabledColor,
    this.pressedColor,
  });
}

/// `ControlButton` - A model class to define properties of individual control buttons.
///
/// This model allows customization of button icons, colors, text, states, and actions,
/// enabling the creation of flexible and interactive control buttons.
///
/// ### Properties:
/// - `name` (`String?`): Optional text to display below the button's icon.
/// - `icon` (`IconData?`): Icon to display on the button when inactive.
/// - `alternateIcon` (`IconData?`): Alternate icon to display when the button is active.
/// - `onPress` (`VoidCallback?`): Function callback triggered on button press.
/// - `color` (`Color?`): Color of the button text. Defaults to `Colors.white`.
/// - `activeColor` (`Color?`): Color of the icon when the button is active. Defaults to `Colors.blue`.
/// - `inActiveColor` (`Color?`): Color of the icon when the button is inactive. Defaults to `Colors.grey`.
/// - `active` (`bool`): Indicates whether the button is active. Defaults to `false`.
/// - `show` (`bool`): Indicates whether the button is visible. Defaults to `true`.
/// - `customComponent` (`Widget?`): Custom widget to display instead of the default icon and text.
/// - `disabled` (`bool`): Indicates whether the button is disabled (non-clickable). Defaults to `false`.
///
/// ### Example Usage:
/// ```dart
/// ControlButton(
///   name: "Mute",
///   icon: Icons.mic,
///   alternateIcon: Icons.mic_off,
///   onPress: () => print("Mute button pressed"),
///   active: false,
///   color: Colors.black,
/// );
/// ```
///
class ControlButton {
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
  final ControlButtonsButtonContentBuilder? contentBuilder;
  final ControlButtonsButtonBuilder? buttonBuilder;
  final ControlButtonsButtonIconBuilder? iconBuilder;
  final ControlButtonsButtonLabelBuilder? labelBuilder;
  final String? semanticsLabel;

  ControlButton({
    this.name,
    this.icon,
    this.alternateIcon,
    this.onPress,
    this.color = Colors.white,
    this.activeColor = Colors.blue,
    this.inActiveColor = Colors.grey,
    this.active = false,
    this.show = true,
    this.customComponent,
    this.disabled = false,
  this.backgroundColor,
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

/// `ControlButtonsComponentOptions` - Configuration options for the `ControlButtonsComponent`.
///
/// This class defines the layout, alignment, and appearance of a collection of `ControlButton` widgets,
/// allowing flexible and customizable control button arrangements.
///
/// ### Properties:
/// - `buttons` (`List<ControlButton>`): List of `ControlButton` instances to display in the component.
/// - `alignment` (`MainAxisAlignment`): Alignment of buttons within the component. Defaults to `MainAxisAlignment.start`.
/// - `vertical` (`bool`): If `true`, arranges buttons vertically; otherwise, horizontally. Defaults to `false`.
/// - `buttonBackgroundColor` (`Color?`): Background color for active buttons.
/// - `buttonsContainerConstraints` (`BoxConstraints?`): Constraints on the container holding the buttons.
///
/// ### Example Usage:
/// ```dart
/// ControlButtonsComponentOptions(
///   buttons: [
///     ControlButton(
///       name: "Play",
///       icon: Icons.play_arrow,
///       onPress: () => print("Play button pressed"),
///     ),
///     ControlButton(
///       name: "Pause",
///       icon: Icons.pause,
///       onPress: () => print("Pause button pressed"),
///       active: true,
///     ),
///   ],
///   alignment: MainAxisAlignment.center,
///   vertical: false,
///   buttonBackgroundColor: Colors.blue,
/// );
/// ```
class ControlButtonsComponentOptions {
  final List<ControlButton> buttons;
  final MainAxisAlignment alignment;
  final bool vertical;
  final Color? buttonBackgroundColor;
  final BoxConstraints? buttonsContainerConstraints;
  final ControlButtonStateColors? buttonBackgroundColors;
  final Color? buttonColor;
  final Color? activeIconColor;
  final Color? inactiveIconColor;
  final double? iconSize;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? containerPadding;
  final EdgeInsetsGeometry? containerMargin;
  final Decoration? containerDecoration;
  final AlignmentGeometry? containerAlignment;
  final Clip containerClipBehavior;
  final EdgeInsetsGeometry? buttonPadding;
  final EdgeInsetsGeometry? buttonMargin;
  final BoxDecoration? buttonDecoration;
  final BorderRadiusGeometry? buttonBorderRadius;
  final BoxConstraints? buttonConstraints;
  final EdgeInsetsGeometry? contentPadding;
  final MainAxisAlignment? contentMainAxisAlignment;
  final CrossAxisAlignment? contentCrossAxisAlignment;
  final double? contentGap;
  final Widget? alternateIconComponent;
  final EdgeInsetsGeometry? labelPadding;
  final EdgeInsetsGeometry? iconPadding;
  final ControlButtonsContainerBuilder? containerBuilder;
  final ControlButtonsButtonsBuilder? buttonsBuilder;
  final ControlButtonsButtonBuilder? buttonBuilder;
  final ControlButtonsButtonContentBuilder? buttonContentBuilder;
  final ControlButtonsButtonIconBuilder? iconBuilder;
  final ControlButtonsButtonLabelBuilder? labelBuilder;
  final double? gap;

  const ControlButtonsComponentOptions({
    required this.buttons,
    this.alignment = MainAxisAlignment.start,
    this.vertical = false,
    this.buttonBackgroundColor,
    this.buttonsContainerConstraints,
    this.buttonBackgroundColors,
    this.buttonColor,
    this.activeIconColor,
    this.inactiveIconColor,
    this.iconSize,
    this.textStyle,
    this.containerPadding,
    this.containerMargin,
    this.containerDecoration,
    this.containerAlignment,
    this.containerClipBehavior = Clip.none,
    this.buttonPadding,
    this.buttonMargin,
    this.buttonDecoration,
    this.buttonBorderRadius,
    this.buttonConstraints,
    this.contentPadding,
    this.contentMainAxisAlignment,
    this.contentCrossAxisAlignment,
    this.contentGap,
    this.alternateIconComponent,
  this.labelPadding,
  this.iconPadding,
    this.containerBuilder,
    this.buttonsBuilder,
    this.buttonBuilder,
    this.buttonContentBuilder,
    this.iconBuilder,
    this.labelBuilder,
    this.gap,
  });
}

typedef ControlButtonsComponentType = Widget Function(
    ControlButtonsComponentOptions options);

/// `ControlButtonsComponent` - A widget that displays a set of control buttons based on specified options.
///
/// This widget arranges a collection of `ControlButton` instances either horizontally or vertically,
/// providing an interactive and visually flexible control panel.
///
/// ### Example Usage:
/// ```dart
/// ControlButtonsComponent(
///   options: ControlButtonsComponentOptions(
///     buttons: [
///       ControlButton(
///         name: "Play",
///         icon: Icons.play_arrow,
///         onPress: () => print("Play button pressed"),
///       ),
///       ControlButton(
///         name: "Stop",
///         icon: Icons.stop,
///         onPress: () => print("Stop button pressed"),
///         active: true,
///       ),
///     ],
///     alignment: MainAxisAlignment.center,
///     vertical: false,
///     buttonBackgroundColor: Colors.blue,
///   ),
/// );
/// ```
///
/// ### Notes:
/// - Each button can have an `active` state, displaying an `alternateIcon` and `activeColor` when active.
/// - The component can be laid out horizontally or vertically based on the `vertical` property.
class ControlButtonsComponent extends StatelessWidget {
  final ControlButtonsComponentOptions options;

  const ControlButtonsComponent({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final axis = options.vertical ? Axis.vertical : Axis.horizontal;
    final visibleButtons =
        options.buttons.where((button) => button.show).toList(growable: false);

    final buttons = <Widget>[];
    for (var i = 0; i < visibleButtons.length; i++) {
      final button = visibleButtons[i];
      final buttonWidget = _buildButton(
        context,
        button,
        i,
        axis,
      );

      if (buttonWidget == null) {
        continue;
      }

      buttons.add(buttonWidget);
    }

    final layoutChildren = <Widget>[];
    for (final buttonWidget in buttons) {
      if (layoutChildren.isNotEmpty && options.gap != null) {
        layoutChildren.add(axis == Axis.vertical
            ? SizedBox(height: options.gap)
            : SizedBox(width: options.gap));
      }
      layoutChildren.add(buttonWidget);
    }

    Widget buttonsContent = Flex(
      direction: axis,
      mainAxisAlignment: options.alignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: layoutChildren,
    );

    buttonsContent = options.buttonsBuilder?.call(
          ControlButtonsButtonsContext(
            buildContext: context,
            options: options,
            direction: axis,
            visibleButtons: visibleButtons,
            buttons: List.unmodifiable(buttons),
            spacedButtons: List.unmodifiable(layoutChildren),
          ),
          buttonsContent,
        ) ??
        buttonsContent;

    Widget container = Container(
      alignment: options.containerAlignment,
      padding: options.containerPadding,
      margin: options.containerMargin,
      decoration: options.containerDecoration,
      clipBehavior: options.containerClipBehavior,
      constraints: options.buttonsContainerConstraints,
      child: buttonsContent,
    );

    container = options.containerBuilder?.call(
          ControlButtonsContainerContext(
            buildContext: context,
            options: options,
            direction: axis,
            visibleButtons: visibleButtons,
          ),
          container,
        ) ??
        container;

    return container;
  }

  Widget? _buildButton(
    BuildContext context,
    ControlButton button,
    int index,
    Axis direction,
  ) {
    final isActive = button.active;
    final effectiveIconSize =
        button.iconSize ?? options.iconSize ?? 20.0;

    final defaultIconColor = button.inActiveColor ??
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
        iconSize: effectiveIconSize,
        activeColor: activeIconColor,
        inactiveColor: defaultIconColor,
      );

      final iconContext = ControlButtonsButtonIconContext(
        buildContext: context,
        options: options,
        button: button,
        index: index,
        direction: direction,
        isActive: isActive,
      );

      final buttonIcon = button.iconBuilder?.call(iconContext, iconWidget);
      if (button.iconBuilder != null) {
        iconWidget = buttonIcon;
      }

      final globalIcon = options.iconBuilder?.call(iconContext, iconWidget);
      if (options.iconBuilder != null) {
        iconWidget = globalIcon;
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

      final labelContext = ControlButtonsButtonLabelContext(
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

    final contentContext = ControlButtonsButtonContentContext(
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

    final backgroundColor = _resolveBackgroundColor(button, isActive);

    final padding = button.padding ?? options.buttonPadding ??
        const EdgeInsets.all(8);
    final margin = button.margin ?? options.buttonMargin ??
        const EdgeInsets.symmetric(horizontal: 4, vertical: 2);
    final constraints = button.constraints ?? options.buttonConstraints;

    final baseDecoration = options.buttonDecoration ??
        BoxDecoration(
          borderRadius: options.buttonBorderRadius ?? BorderRadius.circular(8),
        );

    final mergedDecoration = _mergeDecorations(
      baseDecoration,
      button.decoration,
      backgroundColor,
    );

    Widget buttonWidget = Container(
      constraints: constraints,
      padding: padding,
      margin: margin,
      decoration: mergedDecoration,
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

    final buttonContext = ControlButtonsButtonContext(
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
    required ControlButton button,
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
    ControlButton button, {
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

    if (isActive && options.alternateIconComponent != null) {
      return options.alternateIconComponent;
    }

    return null;
  }

  Color? _resolveBackgroundColor(ControlButton button, bool isActive) {
    final background = button.backgroundColor;
    final stateColors = options.buttonBackgroundColors;

    if (button.disabled) {
      return background?['disabled'] ?? stateColors?.disabledColor ??
          options.buttonBackgroundColor;
    }

    if (isActive) {
      return background?['pressed'] ??
          background?['active'] ??
          stateColors?.pressedColor ??
          stateColors?.activeColor ??
          options.buttonBackgroundColor;
    }

  return background?['default'] ??
    stateColors?.defaultColor ??
    options.buttonBackgroundColor;
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
