import 'package:flutter/material.dart';

import 'mediasfu_borders.dart';
import 'mediasfu_colors.dart';
import 'mediasfu_spacing.dart';
import 'mediasfu_typography.dart';

/// Factory for the modern MediaSFU ThemeData variants.
///
/// Provides:
/// - Light and dark theme configurations
/// - Material 3 design tokens
/// - Premium shadow and elevation styles
/// - Consistent typography and spacing
class MediasfuTheme {
  MediasfuTheme._();

  /// Light theme configuration.
  static ThemeData light() => _themeData(darkMode: false);

  /// Dark theme configuration.
  static ThemeData dark() => _themeData(darkMode: true);

  /// Creates theme data based on mode.
  static ThemeData _themeData({required bool darkMode}) {
    final colorScheme = darkMode
        ? ColorScheme.dark(
            primary: MediasfuColors.primaryDark,
            secondary: MediasfuColors.secondaryDarkMode,
            tertiary: MediasfuColors.accentDark,
            surface: MediasfuColors.surfaceDark,
            surfaceContainerHighest: MediasfuColors.surfaceElevatedDark,
            error: MediasfuColors.dangerDark,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: MediasfuColors.textPrimaryDark,
            onError: Colors.white,
            outline: MediasfuColors.dividerDark,
          )
        : ColorScheme.light(
            primary: MediasfuColors.primary,
            secondary: MediasfuColors.secondary,
            tertiary: MediasfuColors.accent,
            surface: MediasfuColors.surface,
            surfaceContainerHighest: MediasfuColors.surfaceElevated,
            error: MediasfuColors.danger,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: MediasfuColors.textPrimary,
            onError: Colors.white,
            outline: MediasfuColors.divider,
          );

    final textTheme = MediasfuTypography.textTheme(darkMode: darkMode);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: darkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor:
          darkMode ? MediasfuColors.backgroundDark : MediasfuColors.background,
      canvasColor:
          darkMode ? MediasfuColors.surfaceDark : MediasfuColors.surface,
      cardColor: darkMode ? MediasfuColors.cardDark : MediasfuColors.card,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor:
            darkMode ? MediasfuColors.backgroundDark : MediasfuColors.surface,
        foregroundColor: darkMode
            ? MediasfuColors.textPrimaryDark
            : MediasfuColors.textPrimary,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: darkMode
              ? MediasfuColors.textPrimaryDark
              : MediasfuColors.textPrimary,
        ),
        iconTheme: IconThemeData(
          color: darkMode
              ? MediasfuColors.textPrimaryDark
              : MediasfuColors.textPrimary,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      iconTheme: IconThemeData(
        color: darkMode
            ? MediasfuColors.textSecondaryDark
            : MediasfuColors.textSecondary,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.4),
        thickness: 1,
        space: 1,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Button themes with premium styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MediasfuBorders.lg),
          ),
          padding: MediasfuSpacing.insetSymmetric(
            horizontal: MediasfuSpacing.lg,
            vertical: MediasfuSpacing.md,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.05);
            }
            return null;
          }),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MediasfuBorders.lg),
          ),
          padding: MediasfuSpacing.insetSymmetric(
            horizontal: MediasfuSpacing.lg,
            vertical: MediasfuSpacing.md,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MediasfuBorders.lg),
          ),
          padding: MediasfuSpacing.insetSymmetric(
            horizontal: MediasfuSpacing.lg,
            vertical: MediasfuSpacing.md,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.primary.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.hovered)) {
              return colorScheme.primary.withValues(alpha: 0.05);
            }
            return null;
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MediasfuBorders.md),
          ),
          padding: MediasfuSpacing.insetSymmetric(
            horizontal: MediasfuSpacing.md,
            vertical: MediasfuSpacing.sm,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: darkMode
              ? MediasfuColors.textSecondaryDark
              : MediasfuColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MediasfuBorders.md),
          ),
        ),
      ),

      // Input decoration with refined styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkMode
            ? MediasfuColors.surfaceElevatedDark.withValues(alpha: 0.5)
            : MediasfuColors.surfaceElevated,
        contentPadding: MediasfuSpacing.insetSymmetric(
          horizontal: MediasfuSpacing.md,
          vertical: MediasfuSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MediasfuBorders.lg),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MediasfuBorders.lg),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MediasfuBorders.lg),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MediasfuBorders.lg),
          borderSide: BorderSide(
            color: MediasfuColors.danger,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MediasfuBorders.lg),
          borderSide: BorderSide(
            color: MediasfuColors.danger,
            width: 2,
          ),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: darkMode
              ? MediasfuColors.textMutedDark
              : MediasfuColors.textMuted,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: darkMode
              ? MediasfuColors.textMutedDark
              : MediasfuColors.textMuted,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: MediasfuColors.danger,
        ),
        prefixIconColor:
            darkMode ? MediasfuColors.textMutedDark : MediasfuColors.textMuted,
        suffixIconColor:
            darkMode ? MediasfuColors.textMutedDark : MediasfuColors.textMuted,
      ),

      // Card theme with subtle shadow
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkMode ? MediasfuColors.cardDark : MediasfuColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MediasfuBorders.lg),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor:
            darkMode ? MediasfuColors.surfaceDark : MediasfuColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MediasfuBorders.xxl),
        ),
        titleTextStyle: textTheme.headlineLarge?.copyWith(
          color: darkMode
              ? MediasfuColors.textPrimaryDark
              : MediasfuColors.textPrimary,
        ),
        contentTextStyle: textTheme.bodyLarge?.copyWith(
          color: darkMode
              ? MediasfuColors.textSecondaryDark
              : MediasfuColors.textSecondary,
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:
            darkMode ? MediasfuColors.surfaceDark : MediasfuColors.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        dragHandleColor:
            darkMode ? MediasfuColors.dividerDark : MediasfuColors.divider,
        dragHandleSize: const Size(40, 4),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkMode
            ? MediasfuColors.surfaceElevatedDark
            : MediasfuColors.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: darkMode ? MediasfuColors.textPrimaryDark : Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MediasfuBorders.md),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: darkMode
            ? MediasfuColors.surfaceElevatedDark
            : MediasfuColors.surfaceElevated,
        selectedColor: colorScheme.primary.withValues(alpha: 0.2),
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MediasfuBorders.full),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        padding: MediasfuSpacing.insetSymmetric(
          horizontal: MediasfuSpacing.md,
          vertical: MediasfuSpacing.xs,
        ),
      ),

      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor:
            darkMode ? MediasfuColors.textMutedDark : MediasfuColors.textMuted,
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelLarge,
        dividerColor: Colors.transparent,
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.2),
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.1),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return darkMode
              ? MediasfuColors.textMutedDark
              : MediasfuColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.3);
          }
          return colorScheme.outline.withValues(alpha: 0.3);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(
          color: colorScheme.outline,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primary.withValues(alpha: 0.2),
        circularTrackColor: colorScheme.primary.withValues(alpha: 0.2),
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: darkMode
              ? MediasfuColors.surfaceElevatedDark
              : MediasfuColors.textPrimary,
          borderRadius: BorderRadius.circular(MediasfuBorders.sm),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: darkMode ? MediasfuColors.textPrimaryDark : Colors.white,
        ),
        padding: MediasfuSpacing.insetSymmetric(
          horizontal: MediasfuSpacing.sm,
          vertical: MediasfuSpacing.xs,
        ),
      ),

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

/// Simple notifier used to switch between light/dark/system themes.
class MediasfuThemeModeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

/// Extension methods for easy theme access.
extension MediasfuThemeExtension on BuildContext {
  /// Quick access to current theme data.
  ThemeData get theme => Theme.of(this);

  /// Quick access to color scheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Quick access to text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Check if current theme is dark mode.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
