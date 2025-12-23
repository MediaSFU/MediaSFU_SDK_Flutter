import 'dart:ui';

import 'package:flutter/material.dart';

import '../../components/display_components/loading_modal.dart'
    show
        LoadingModalContainerContext,
        LoadingModalContentContext,
        LoadingModalOptions,
        LoadingModalSpinnerContext,
        LoadingModalTextContext;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/theme/mediasfu_typography.dart';
import '../core/theme/mediasfu_animations.dart';
import '../core/widgets/glassmorphic_container.dart';

/// Modern redesigned LoadingModal with glassmorphic styling, gradient spinner,
/// and premium animations.
class ModernLoadingModal extends StatefulWidget {
  final LoadingModalOptions options;

  const ModernLoadingModal({super.key, required this.options});

  @override
  State<ModernLoadingModal> createState() => _ModernLoadingModalState();
}

class _ModernLoadingModalState extends State<ModernLoadingModal>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: MediasfuAnimations.normal,
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: MediasfuAnimations.normal,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.options.isVisible) {
      _fadeController.forward();
      _scaleController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ModernLoadingModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.isVisible != oldWidget.options.isVisible) {
      if (widget.options.isVisible) {
        _fadeController.forward();
        _scaleController.forward();
      } else {
        _fadeController.reverse();
        _scaleController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.options.isVisible) {
      return const SizedBox.shrink();
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = MediasfuTypography.textTheme(darkMode: isDark);

    // Build premium gradient spinner
    Widget spinner = widget.options.showSpinner
        ? (widget.options.spinner ??
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: MediasfuColors.brandGradient(darkMode: isDark),
                      boxShadow: MediasfuColors.glowShadow(
                        MediasfuColors.primary,
                        intensity: 0.4,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                );
              },
            ))
        : const SizedBox.shrink();

    if (widget.options.spinnerBuilder != null) {
      spinner = widget.options.spinnerBuilder!(
        LoadingModalSpinnerContext(
            buildContext: context, options: widget.options),
        spinner,
      );
    }

    // Build text with gradient effect
    Widget text = widget.options.loadingText ??
        ShaderMask(
          shaderCallback: (bounds) =>
              MediasfuColors.brandGradient(darkMode: isDark)
                  .createShader(bounds),
          child: Text(
            'Loading...',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        );

    if (widget.options.textBuilder != null) {
      text = widget.options.textBuilder!(
        LoadingModalTextContext(buildContext: context, options: widget.options),
        text,
      );
    }

    // Assemble content children
    final List<Widget> contentChildren = [];
    if (widget.options.showSpinner) {
      contentChildren.add(spinner);
      if (widget.options.spinnerTextSpacing > 0) {
        contentChildren
            .add(SizedBox(height: widget.options.spinnerTextSpacing));
      }
    }
    contentChildren.add(text);

    // Content container with glow
    Widget content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: MediasfuColors.primary.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      child: GlassmorphicContainer(
        borderRadius: 24,
        blur: 25,
        padding: (widget.options.contentPadding as EdgeInsets?) ??
            MediasfuSpacing.insetAll(MediasfuSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: contentChildren,
        ),
      ),
    );

    if (widget.options.contentBuilder != null) {
      content = widget.options.contentBuilder!(
        LoadingModalContentContext(
          buildContext: context,
          options: widget.options,
          spinner: spinner,
          text: text,
        ),
        content,
      );
    }

    // Frosted overlay background with animations
    Widget modal = AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: child,
        );
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // block taps
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (isDark ? Colors.black : Colors.black)
                            .withValues(alpha: 0.5),
                        (isDark ? Colors.black : Colors.black)
                            .withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: widget.options.contentAlignment,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
                child: content,
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.options.containerBuilder != null) {
      modal = widget.options.containerBuilder!(
        LoadingModalContainerContext(
          buildContext: context,
          options: widget.options,
          content: content,
        ),
        modal,
      );
    }

    return modal;
  }
}

/// Convenience builder conforming to LoadingModalType signature.
Widget modernLoadingModalBuilder({required LoadingModalOptions options}) {
  return ModernLoadingModal(options: options);
}
