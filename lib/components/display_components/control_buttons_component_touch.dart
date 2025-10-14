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

/// ControlButtonsComponentTouchOptions - Configuration options for `ControlButtonsComponentTouch`.
///
/// ### Example Usage:
/// ```dart
/// ControlButtonsComponentTouchOptions(
///   buttons: [
///     ButtonTouch(name: 'Play', icon: Icons.play_arrow, onPress: () {} ),
///     ButtonTouch(name: 'Stop', icon: Icons.stop, onPress: () {}, disabled: true ),
///   ],
///   position: 'right',
///   location: 'bottom',
///   direction: 'horizontal',
///   containerDecoration: BoxDecoration(
///     color: Colors.grey,
///     borderRadius: BorderRadius.circular(8),
///   ),
/// );
/// ```
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

/// ControlButtonsComponentTouch - Renders a customizable set of control buttons.
///
/// ### Example Usage:
/// ```dart
/// ControlButtonsComponentTouch(
///   options: ControlButtonsComponentTouchOptions(
///     buttons: [
///       ButtonTouch(name: 'Play', icon: Icons.play_arrow, onPress: () {} ),
///       ButtonTouch(name: 'Pause', icon: Icons.pause, onPress: () {} ),
///     ],
///   ),
/// );
/// ```
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
