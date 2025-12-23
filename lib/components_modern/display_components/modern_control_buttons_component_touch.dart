import 'package:flutter/material.dart';
import '../../components/display_components/control_buttons_component_touch.dart';

/// Modern version of ControlButtonsComponentTouch with improved alignment and styling.
class ModernControlButtonsComponentTouch extends StatelessWidget {
  final ControlButtonsComponentTouchOptions options;

  const ModernControlButtonsComponentTouch({super.key, required this.options});

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
        return MainAxisAlignment.end;
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

  CrossAxisAlignment _crossAxisFromPosition(String position) {
    switch (position.toLowerCase()) {
      case 'left':
        return CrossAxisAlignment.start;
      case 'right':
        return CrossAxisAlignment.end;
      default:
        return CrossAxisAlignment.end;
    }
  }

  CrossAxisAlignment _crossAxisFromLocation(String location) {
    switch (location.toLowerCase()) {
      case 'top':
        return CrossAxisAlignment.start;
      case 'bottom':
        return CrossAxisAlignment.end;
      default:
        return CrossAxisAlignment.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If showAspect is false, return empty widget
    if (!options.showAspect) {
      return const SizedBox.shrink();
    }

    // Check if this is a horizontal middle-positioned bar (record buttons)
    final isHorizontalMiddle =
        options.direction.toLowerCase() == 'horizontal' &&
            options.position.toLowerCase() == 'middle';

    // Normalize inputs so we always anchor bottom-right/vertical by default.
    // If caller left defaults (left/top/horizontal), force our modern defaults.
    // Exception: horizontal middle position should stay horizontal for record buttons.
    final normalizedPosition = isHorizontalMiddle
        ? 'middle'
        : (options.position.isEmpty || options.position == 'left')
            ? 'right'
            : options.position.toLowerCase();
    final normalizedLocation =
        (options.location.isEmpty || options.location == 'top')
            ? 'bottom'
            : options.location.toLowerCase();
    final normalizedDirection = isHorizontalMiddle
        ? 'horizontal'
        : (options.direction.isEmpty || options.direction == 'horizontal')
            ? 'vertical'
            : options.direction.toLowerCase();

    final axis = _directionFromString(normalizedDirection);
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
      if (spacedButtons.isNotEmpty) {
        // Default gap of 10.0 if not specified
        final gap = options.gap ?? 10.0;
        spacedButtons.add(axis == Axis.vertical
            ? SizedBox(height: gap)
            : SizedBox(width: gap));
      }
      spacedButtons.add(button);
    }

    // Correct alignment logic:
    // For Row (Horizontal):
    // - MainAxis (Horizontal) -> Position (Left/Right/Center)
    // - CrossAxis (Vertical) -> Location (Top/Bottom/Center)
    // For Column (Vertical):
    // - MainAxis (Vertical) -> Location (Top/Bottom/Center)
    // - CrossAxis (Horizontal) -> Position (Left/Right/Center)

    Widget buttonsBar = axis == Axis.horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: _mainAxisFromPosition(normalizedPosition),
            crossAxisAlignment: _crossAxisFromLocation(normalizedLocation),
            children: spacedButtons,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: _mainAxisFromLocation(normalizedLocation),
            crossAxisAlignment: _crossAxisFromPosition(normalizedPosition),
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

    // Get theme info for styling
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? Colors.black.withOpacity(0.35)
        : Colors.white.withOpacity(0.85);

    // Wrap the buttons bar in a styled container
    Widget styledButtons = Container(
      padding: options.containerPadding ??
          const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      margin: options.containerMargin ?? const EdgeInsets.all(12),
      decoration: options.containerDecoration ??
          BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
      clipBehavior: options.containerClipBehavior,
      child: buttonsBar,
    );

    // Use Align instead of Positioned to avoid ParentDataWidget errors
    // Positioned can only be used as a direct child of Stack
    Alignment alignment;
    if (normalizedPosition == 'middle') {
      // Horizontal center at bottom
      alignment = Alignment.bottomCenter;
    } else if (normalizedPosition == 'left') {
      alignment = normalizedLocation == 'top'
          ? Alignment.topLeft
          : Alignment.bottomLeft;
    } else {
      // Default: right
      alignment = normalizedLocation == 'top'
          ? Alignment.topRight
          : Alignment.bottomRight;
    }

    return Visibility(
      visible: options.showAspect,
      child: Align(
        alignment: alignment,
        child: styledButtons,
      ),
    );
  }

  Widget? _buildButton(
    BuildContext context,
    ButtonTouch button,
    int index,
    Axis direction,
  ) {
    final isActive = button.active;
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final isWide = mediaQuery.size.width >= 1200;
    final shouldUseSidebar =
        (isLandscape && isWide) || direction == Axis.vertical;
    final isLargeScreen = mediaQuery.size.width > 768;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Base icon sizes - significantly larger for modern UI
    // Small screens: 30, Large screens: 36, Sidebar mode: 48
    final double baseIconSize = isLargeScreen ? 36.0 : 30.0;
    // For shouldUseSidebar, add 40% extra size
    final double defaultIconSize = shouldUseSidebar
        ? (isLargeScreen ? 48.0 : 42.0) // Ensure at least 42 on small screens
        : baseIconSize;
    final iconSize = button.iconSize ??
        options.iconSize ??
        button.size?.toDouble() ??
        defaultIconSize;

    // Theme-aware colors
    final defaultInactiveColor = isDarkMode ? Colors.white70 : Colors.black87;
    final defaultActiveColor = isDarkMode ? Colors.white : Colors.black;

    final inactiveIconColor = button.inActiveColor ??
        options.inactiveIconColor ??
        button.color ??
        options.buttonColor ??
        defaultInactiveColor;

    final activeIconColor = button.activeColor ??
        options.activeIconColor ??
        button.color ??
        options.buttonColor ??
        defaultActiveColor;

    Widget? iconWidget;
    if (button.customComponent == null) {
      // Logic to resolve icon widget (simplified from original)
      if (isActive) {
        if (button.alternateIconWidget != null) {
          iconWidget = button.alternateIconWidget;
        } else if (options.alternateIconComponent != null) {
          iconWidget = options.alternateIconComponent;
        } else if (button.alternateIcon != null) {
          iconWidget = Icon(
            button.alternateIcon,
            color: activeIconColor,
            size: iconSize,
          );
        } else {
          iconWidget = Icon(
            button.icon,
            color: activeIconColor,
            size: iconSize,
          );
        }
      } else {
        if (button.iconWidget != null) {
          iconWidget = button.iconWidget;
        } else if (options.iconComponent != null) {
          iconWidget = options.iconComponent;
        } else {
          iconWidget = Icon(
            button.icon,
            color: inactiveIconColor,
            size: iconSize,
          );
        }
      }

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
      // Theme-aware text color
      final defaultTextColor = isDarkMode ? Colors.white : Colors.black87;
      // Base font sizes - larger for modern UI
      // Small screens: 14, Large screens: 16, Sidebar mode: 20
      final double baseFontSize = isLargeScreen ? 16.0 : 14.0;
      final double resolvedFontSize = shouldUseSidebar
          ? (baseFontSize * 1.25) // 20.0 for sidebar mode
          : baseFontSize;

      final baseStyle = button.textStyle ?? options.textStyle;
      final resolvedStyle = baseStyle?.copyWith(
            color: button.color ??
                baseStyle.color ??
                options.buttonColor ??
                defaultTextColor,
          ) ??
          TextStyle(
            color: button.color ?? options.buttonColor ?? defaultTextColor,
            fontSize: resolvedFontSize,
            fontWeight: FontWeight.w600,
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

    // Button container styling
    final backgroundColor = button.disabled
        ? (button.backgroundColor?['disabled'] ??
            options.buttonBackgroundColors?.disabledColor)
        : isActive
            ? (button.backgroundColor?['active'] ??
                options.buttonBackgroundColors?.activeColor)
            : (button.backgroundColor?['default'] ??
                options.buttonBackgroundColors?.defaultColor);

    final buttonDecoration = button.decoration ??
        options.buttonDecoration ??
        BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: button.padding != null
              ? null
              : (options.buttonBorderRadius ?? BorderRadius.circular(8)),
        );

    Widget buttonContainer = Container(
      padding: button.padding ?? options.buttonPadding,
      margin: button.margin ?? options.buttonMargin,
      decoration: buttonDecoration,
      constraints: button.constraints ?? options.buttonConstraints,
      child: content,
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
      buttonContainer = button.buttonBuilder!(buttonContext, buttonContainer);
    }

    if (options.buttonBuilder != null) {
      buttonContainer = options.buttonBuilder!(buttonContext, buttonContainer);
    }

    final tooltipMessage = button.semanticsLabel ?? button.name ?? '';
    final hasTooltip = tooltipMessage.isNotEmpty;

    Widget result = Semantics(
      label: tooltipMessage,
      button: true,
      enabled: !button.disabled,
      child: GestureDetector(
        onTap: button.disabled ? null : button.onPress,
        child: buttonContainer,
      ),
    );

    if (hasTooltip) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      result = Tooltip(
        message: tooltipMessage,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white : Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: isDarkMode ? Colors.black : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        verticalOffset: 12,
        child: result,
      );
    }

    return result;
  }

  Widget _buildDefaultContent({
    required Axis direction,
    required Widget? icon,
    required Widget? label,
    required ButtonTouch button,
  }) {
    final children = <Widget>[];
    if (icon != null) children.add(icon);

    // Better spacing between icon and label
    if (icon != null && label != null) {
      final gap = button.contentGap ?? options.contentGap ?? 6.0;
      children.add(SizedBox(
        width: direction == Axis.horizontal ? gap : 0,
        height: direction == Axis.vertical ? gap : 0,
      ));
    }

    if (label != null) children.add(label);

    return Container(
      padding: button.contentPadding ??
          options.contentPadding ??
          const EdgeInsets.all(4),
      child: Flex(
        direction: direction,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: button.contentMainAxisAlignment ??
            options.contentMainAxisAlignment ??
            MainAxisAlignment.center,
        crossAxisAlignment: button.contentCrossAxisAlignment ??
            options.contentCrossAxisAlignment ??
            CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}
