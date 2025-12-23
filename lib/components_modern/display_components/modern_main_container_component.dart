import 'dart:ui';

import 'package:flutter/material.dart';

import '../../components/display_components/main_container_component.dart'
    show MainContainerComponentOptions;
import '../core/theme/mediasfu_colors.dart';

/// Modern redesigned MainContainerComponent with glassmorphic styling.
/// Retains all business logic from the original component.
class ModernMainContainerComponent extends StatelessWidget {
  final MainContainerComponentOptions options;

  const ModernMainContainerComponent({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double containerWidth = options.containerWidthFraction * screenWidth;
    final double containerHeight =
        options.containerHeightFraction * screenHeight;

    // Default decoration with subtle gradient and frosted effect
    final Decoration defaultDecoration = BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? const [Color(0xFF0F172A), Color(0xFF1E1B4B)]
            : const [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: MediasfuColors.elevation(level: 1, darkMode: isDark),
    );

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: containerWidth,
          height: containerHeight,
          margin: options.margin ??
              EdgeInsets.fromLTRB(
                options.marginLeft,
                options.marginTop,
                options.marginRight,
                options.marginBottom,
              ),
          padding: options.padding,
          decoration: options.decoration ?? defaultDecoration,
          alignment: options.alignment,
          clipBehavior: options.clipBehavior ?? Clip.antiAlias,
          child: Stack(
            children: options.children,
          ),
        ),
      ),
    );
  }
}

/// Convenience builder conforming to MainContainerComponentType signature.
Widget modernMainContainerComponentBuilder({
  required MainContainerComponentOptions options,
}) {
  return ModernMainContainerComponent(options: options);
}
