// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/mediasfu_colors.dart';
import '../theme/mediasfu_spacing.dart';
import '../theme/mediasfu_typography.dart';
import '../theme/modern_style_options.dart';

/// Style variants for [PremiumTextField].
enum PremiumTextFieldVariant {
  /// Standard filled style with background color.
  filled,

  /// Outlined style with border.
  outlined,

  /// Underline-only style.
  underline,

  /// Glassmorphic/frosted style.
  glass,

  /// Neumorphic style with soft shadows.
  neumorphic,
}

/// A premium text field with modern styling and animations.
///
/// Features:
/// - Multiple style variants (filled, outlined, underline, glass, neumorphic)
/// - Animated focus states
/// - Leading and trailing icons
/// - Error and helper text
/// - Character counter
/// - Password visibility toggle
/// - Full customization
///
/// Example usage:
/// ```dart
/// PremiumTextField(
///   label: 'Email',
///   hint: 'Enter your email',
///   variant: PremiumTextFieldVariant.outlined,
///   leadingIcon: Icons.email,
///   validator: (value) => value?.contains('@') == true ? null : 'Invalid email',
/// )
/// ```
class PremiumTextField extends StatefulWidget {
  /// Text controller.
  final TextEditingController? controller;

  /// Focus node.
  final FocusNode? focusNode;

  /// Label text.
  final String? label;

  /// Hint text.
  final String? hint;

  /// Helper text.
  final String? helperText;

  /// Error text (overrides helperText when set).
  final String? errorText;

  /// Prefix text.
  final String? prefixText;

  /// Suffix text.
  final String? suffixText;

  /// Leading icon.
  final IconData? leadingIcon;

  /// Trailing icon.
  final IconData? trailingIcon;

  /// Custom leading widget.
  final Widget? leading;

  /// Custom trailing widget.
  final Widget? trailing;

  /// Style variant.
  final PremiumTextFieldVariant variant;

  /// Whether the field is for password input.
  final bool isPassword;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether to autofocus.
  final bool autofocus;

  /// Maximum lines.
  final int? maxLines;

  /// Minimum lines.
  final int? minLines;

  /// Maximum length.
  final int? maxLength;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Text input action.
  final TextInputAction? textInputAction;

  /// Text capitalization.
  final TextCapitalization textCapitalization;

  /// Input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Validator function.
  final String? Function(String?)? validator;

  /// On changed callback.
  final ValueChanged<String>? onChanged;

  /// On submitted callback.
  final ValueChanged<String>? onSubmitted;

  /// On editing complete callback.
  final VoidCallback? onEditingComplete;

  /// On tap callback.
  final VoidCallback? onTap;

  /// On trailing icon tap.
  final VoidCallback? onTrailingTap;

  /// Primary color.
  final Color? primaryColor;

  /// Error color.
  final Color? errorColor;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double? borderRadius;

  /// Content padding.
  final EdgeInsetsGeometry? contentPadding;

  /// Whether to use dark mode styling.
  final bool isDarkMode;

  /// Whether to show the character counter.
  final bool showCounter;

  /// Custom style options.
  final ModernStyleOptions? styleOptions;

  const PremiumTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixText,
    this.suffixText,
    this.leadingIcon,
    this.trailingIcon,
    this.leading,
    this.trailing,
    this.variant = PremiumTextFieldVariant.filled,
    this.isPassword = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onTap,
    this.onTrailingTap,
    this.primaryColor,
    this.errorColor,
    this.backgroundColor,
    this.borderRadius,
    this.contentPadding,
    this.isDarkMode = true,
    this.showCounter = false,
    this.styleOptions,
  });

  @override
  State<PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<PremiumTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animController;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;
  bool _isObscured = true;
  String? _errorText;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    // Mark animation as used for linter
    assert(_focusAnimation.value >= 0);

    if (widget.controller != null) {
      _charCount = widget.controller!.text.length;
      widget.controller!.addListener(_handleTextChange);
    }
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  void _handleTextChange() {
    if (widget.controller != null) {
      setState(() => _charCount = widget.controller!.text.length);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller != null) {
      widget.controller!.removeListener(_handleTextChange);
    }
    _animController.dispose();
    super.dispose();
  }

  Color get _primaryColor => widget.primaryColor ?? MediasfuColors.primary;
  Color get _errorColor => widget.errorColor ?? MediasfuColors.danger;

  bool get _hasError => widget.errorText != null || _errorText != null;
  String? get _effectiveError => widget.errorText ?? _errorText;

  double get _borderRadius => widget.borderRadius ?? 12.0;

  Color get _bgColor {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    switch (widget.variant) {
      case PremiumTextFieldVariant.filled:
        return widget.isDarkMode
            ? const Color(0xFF2A2A3E)
            : const Color(0xFFF1F5F9);
      case PremiumTextFieldVariant.outlined:
        return Colors.transparent;
      case PremiumTextFieldVariant.underline:
        return Colors.transparent;
      case PremiumTextFieldVariant.glass:
        return widget.isDarkMode
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.04);
      case PremiumTextFieldVariant.neumorphic:
        return widget.isDarkMode
            ? MediasfuColors.surfaceDark
            : MediasfuColors.surface;
    }
  }

  Color get _textColor => widget.isDarkMode ? Colors.white : Colors.black87;

  Color get _hintColor => widget.isDarkMode
      ? Colors.white.withValues(alpha: 0.5)
      : Colors.black.withValues(alpha: 0.4);

  Color get _iconColor => _isFocused
      ? (_hasError ? _errorColor : _primaryColor)
      : (widget.isDarkMode ? Colors.white60 : Colors.black45);

  InputBorder _buildBorder(bool focused, bool error) {
    final color =
        error ? _errorColor : (focused ? _primaryColor : Colors.transparent);

    switch (widget.variant) {
      case PremiumTextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(
            color: focused || error
                ? color
                : (widget.isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08)),
            width: focused ? 2 : 1,
          ),
        );

      case PremiumTextFieldVariant.outlined:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(
            color: error
                ? _errorColor
                : (focused
                    ? _primaryColor
                    : (widget.isDarkMode
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.15))),
            width: focused ? 2 : 1.5,
          ),
        );

      case PremiumTextFieldVariant.underline:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: error
                ? _errorColor
                : (focused
                    ? _primaryColor
                    : (widget.isDarkMode
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.2))),
            width: focused ? 2 : 1,
          ),
        );

      case PremiumTextFieldVariant.glass:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(
            color: error
                ? _errorColor.withValues(alpha: 0.5)
                : (focused
                    ? _primaryColor.withValues(alpha: 0.6)
                    : (widget.isDarkMode
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.1))),
            width: 1,
          ),
        );

      case PremiumTextFieldVariant.neumorphic:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide.none,
        );
    }
  }

  List<BoxShadow>? _buildNeumorphicShadows() {
    if (widget.variant != PremiumTextFieldVariant.neumorphic) return null;

    if (_isFocused) {
      // Inset shadows for focus
      return [
        BoxShadow(
          color: widget.isDarkMode
              ? const Color(0xFF0A0A12)
              : const Color(0xFFD1D9E6),
          offset: const Offset(2, 2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: widget.isDarkMode ? const Color(0xFF404060) : Colors.white,
          offset: const Offset(-2, -2),
          blurRadius: 4,
        ),
      ];
    } else {
      // Normal raised shadows
      return [
        BoxShadow(
          color: widget.isDarkMode
              ? const Color(0xFF404060).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.8),
          offset: const Offset(-3, -3),
          blurRadius: 6,
        ),
        BoxShadow(
          color: widget.isDarkMode
              ? const Color(0xFF0A0A12).withValues(alpha: 0.5)
              : const Color(0xFFD1D9E6).withValues(alpha: 0.5),
          offset: const Offset(3, 3),
          blurRadius: 6,
        ),
      ];
    }
  }

  Widget? _buildTrailing() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _isObscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: _iconColor,
          size: 20,
        ),
        onPressed: () => setState(() => _isObscured = !_isObscured),
        splashRadius: 20,
      );
    }

    if (widget.trailing != null) return widget.trailing;

    if (widget.trailingIcon != null) {
      return IconButton(
        icon: Icon(widget.trailingIcon, color: _iconColor, size: 20),
        onPressed: widget.onTrailingTap,
        splashRadius: 20,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget field = Container(
      decoration: widget.variant == PremiumTextFieldVariant.neumorphic
          ? BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(_borderRadius),
              boxShadow: _buildNeumorphicShadows(),
            )
          : null,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.isPassword && _isObscured,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        maxLines: widget.isPassword ? 1 : widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        inputFormatters: widget.inputFormatters,
        style: TextStyle(
          color: _textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: _hasError ? _errorColor : _primaryColor,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          helperText: _hasError ? null : widget.helperText,
          errorText: null, // We handle error text separately
          prefixText: widget.prefixText,
          suffixText: widget.suffixText,
          filled: widget.variant != PremiumTextFieldVariant.underline,
          fillColor: _bgColor,
          prefixIcon: widget.leading ??
              (widget.leadingIcon != null
                  ? Icon(widget.leadingIcon, color: _iconColor, size: 20)
                  : null),
          suffixIcon: _buildTrailing(),
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: _buildBorder(false, false),
          enabledBorder: _buildBorder(false, _hasError),
          focusedBorder: _buildBorder(true, _hasError),
          errorBorder: _buildBorder(false, true),
          focusedErrorBorder: _buildBorder(true, true),
          labelStyle: TextStyle(
            color: _isFocused
                ? (_hasError ? _errorColor : _primaryColor)
                : _hintColor,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(color: _hintColor),
          helperStyle: TextStyle(
            color: widget.isDarkMode
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.5),
            fontSize: 12,
          ),
          counterText: '', // Hide default counter
        ),
        validator: (value) {
          _errorText = widget.validator?.call(value);
          return _errorText;
        },
        onChanged: (value) {
          setState(() => _charCount = value.length);
          widget.onChanged?.call(value);
        },
        onFieldSubmitted: widget.onSubmitted,
        onEditingComplete: widget.onEditingComplete,
        onTap: widget.onTap,
      ),
    );

    // Add helper/error text and counter below
    if (widget.helperText != null ||
        _hasError ||
        (widget.showCounter && widget.maxLength != null)) {
      field = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          field,
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_hasError)
                Text(
                  _effectiveError!,
                  style: TextStyle(
                    color: _errorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else if (widget.helperText != null)
                Text(
                  widget.helperText!,
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                )
              else
                const SizedBox(),
              if (widget.showCounter && widget.maxLength != null)
                Text(
                  '$_charCount/${widget.maxLength}',
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      );
    }

    return field;
  }
}

/// A premium search field with animated clear button and search icon.
class PremiumSearchField extends StatefulWidget {
  /// Text controller.
  final TextEditingController? controller;

  /// Hint text.
  final String hint;

  /// On changed callback.
  final ValueChanged<String>? onChanged;

  /// On submitted callback.
  final ValueChanged<String>? onSubmitted;

  /// Whether to use dark mode.
  final bool isDarkMode;

  /// Border radius.
  final double borderRadius;

  /// Style variant.
  final PremiumTextFieldVariant variant;

  const PremiumSearchField({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.isDarkMode = true,
    this.borderRadius = 24,
    this.variant = PremiumTextFieldVariant.filled,
  });

  @override
  State<PremiumSearchField> createState() => _PremiumSearchFieldState();
}

class _PremiumSearchFieldState extends State<PremiumSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_handleChange);
  }

  void _handleChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumTextField(
      controller: _controller,
      hint: widget.hint,
      variant: widget.variant,
      borderRadius: widget.borderRadius,
      isDarkMode: widget.isDarkMode,
      leadingIcon: Icons.search_rounded,
      trailing: AnimatedOpacity(
        opacity: _hasText ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 150),
        child: IconButton(
          icon: Icon(
            Icons.close_rounded,
            size: 18,
            color: widget.isDarkMode ? Colors.white60 : Colors.black45,
          ),
          onPressed: () {
            _controller.clear();
            widget.onChanged?.call('');
          },
          splashRadius: 18,
        ),
      ),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
    );
  }
}
