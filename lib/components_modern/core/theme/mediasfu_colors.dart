import 'package:flutter/material.dart';

/// Design tokens representing the modern MediaSFU colour palette.
///
/// This class provides a comprehensive color system with:
/// - Light and dark palettes with extended color spectrums
/// - Premium gradient systems (brand, metallic, iridescent, aurora)
/// - Glow and shadow utilities for depth effects
/// - Glass morphism decorations
/// - Neumorphic shadow pairs for 3D effects
/// - Interactive state utilities
class MediasfuColors {
  MediasfuColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMARY PALETTE - LIGHT MODE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary brand color - Indigo 500
  static const Color primary = Color(0xFF6366F1);

  /// Primary variant for emphasis - Indigo 600
  static const Color primaryVariant = Color(0xFF4F46E5);

  /// Primary light variant - Indigo 400
  static const Color primaryLight = Color(0xFF818CF8);

  /// Secondary brand color - Blue 500
  static const Color secondary = Color(0xFF3B82F6);

  /// Secondary light variant - Blue 400
  static const Color secondaryLight = Color(0xFF60A5FA);

  /// Secondary dark variant - Blue 600
  static const Color secondaryDark = Color(0xFF2563EB);

  /// Accent color - Cyan 500
  static const Color accent = Color(0xFF06B6D4);

  /// Accent light variant - Cyan 400
  static const Color accentLight = Color(0xFF22D3EE);

  /// Accent dark variant - Cyan 600
  static const Color accentDarkVariant = Color(0xFF0891B2);

  // Surface colors - Light mode
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF1F5F9);
  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardHover = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMARY PALETTE - DARK MODE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary brand color for dark mode - Indigo 400
  static const Color primaryDark = Color(0xFF818CF8);

  /// Primary dark variant - Indigo 500
  static const Color primaryDarkVariant = Color(0xFF6366F1);

  /// Primary light dark mode - Indigo 300
  static const Color primaryLightDark = Color(0xFFA5B4FC);

  /// Secondary for dark mode - Blue 400
  static const Color secondaryDarkMode = Color(0xFF60A5FA);

  /// Secondary light dark mode - Blue 300
  static const Color secondaryLightDark = Color(0xFF93C5FD);

  /// Accent for dark mode - Cyan 400
  static const Color accentDark = Color(0xFF22D3EE);

  /// Accent light dark mode - Cyan 300
  static const Color accentLightDark = Color(0xFF67E8F9);

  // Surface colors - Dark mode
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceElevatedDark = Color(0xFF334155);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color cardHoverDark = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF334155);

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  // Success spectrum - Emerald
  static const Color success = Color(0xFF34D399);
  static const Color successLight = Color(0xFF6EE7B7);
  static const Color successDark = Color(0xFF10B981);
  static const Color successBackground = Color(0xFFECFDF5);
  static const Color successBackgroundDark = Color(0xFF064E3B);

  // Warning spectrum - Amber
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningLight = Color(0xFFFDE68A);
  static const Color warningDark = Color(0xFFF59E0B);
  static const Color warningBackground = Color(0xFFFFFBEB);
  static const Color warningBackgroundDark = Color(0xFF78350F);

  // Danger/Error spectrum - Rose
  static const Color danger = Color(0xFFFB7185);
  static const Color dangerLight = Color(0xFFFDA4AF);
  static const Color dangerDark = Color(0xFFF43F5E);
  static const Color dangerBackground = Color(0xFFFFF1F2);
  static const Color dangerBackgroundDark = Color(0xFF881337);

  // Info spectrum - Sky
  static const Color info = Color(0xFF38BDF8);
  static const Color infoLight = Color(0xFF7DD3FC);
  static const Color infoDark = Color(0xFF0EA5E9);
  static const Color infoBackground = Color(0xFFF0F9FF);
  static const Color infoBackgroundDark = Color(0xFF0C4A6E);

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textMutedDark = Color(0xFF94A3B8);
  static const Color textDisabledDark = Color(0xFF64748B);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENT SYSTEMS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Brand gradient - Primary to secondary to accent blend.
  static LinearGradient brandGradient({bool darkMode = false}) {
    return LinearGradient(
      colors: darkMode
          ? const [Color(0xFF818CF8), Color(0xFF60A5FA), Color(0xFF22D3EE)]
          : const [Color(0xFF6366F1), Color(0xFF3B82F6), Color(0xFF06B6D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Simple brand gradient - Primary to secondary only.
  static LinearGradient simpleBrandGradient({bool darkMode = false}) {
    return LinearGradient(
      colors: darkMode
          ? const [Color(0xFF818CF8), Color(0xFF60A5FA)]
          : const [Color(0xFF6366F1), Color(0xFF3B82F6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Premium accent gradient - Cyan to indigo sweep.
  static LinearGradient accentGradient({bool darkMode = false}) {
    return LinearGradient(
      colors: darkMode
          ? const [Color(0xFF22D3EE), Color(0xFF818CF8)]
          : const [Color(0xFF06B6D4), Color(0xFF6366F1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Metallic gradient - Sophisticated silver/chrome effect.
  static LinearGradient metallicGradient({bool darkMode = false}) {
    return LinearGradient(
      colors: darkMode
          ? const [
              Color(0xFF64748B),
              Color(0xFF94A3B8),
              Color(0xFFCBD5E1),
              Color(0xFF94A3B8),
              Color(0xFF64748B),
            ]
          : const [
              Color(0xFFE2E8F0),
              Color(0xFFF1F5F9),
              Color(0xFFFFFFFF),
              Color(0xFFF1F5F9),
              Color(0xFFE2E8F0),
            ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Iridescent gradient - Multi-color holographic effect.
  static LinearGradient iridescentGradient({bool darkMode = false}) {
    return LinearGradient(
      colors: darkMode
          ? const [
              Color(0xFF818CF8),
              Color(0xFF60A5FA),
              Color(0xFF22D3EE),
              Color(0xFF2DD4BF),
              Color(0xFF34D399),
            ]
          : const [
              Color(0xFF6366F1),
              Color(0xFF3B82F6),
              Color(0xFF06B6D4),
              Color(0xFF14B8A6),
              Color(0xFF10B981),
            ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Aurora gradient - Northern lights effect.
  static LinearGradient auroraGradient({bool darkMode = false}) {
    return LinearGradient(
      colors: darkMode
          ? const [
              Color(0xFF10B981),
              Color(0xFF22D3EE),
              Color(0xFF60A5FA),
              Color(0xFF818CF8),
            ]
          : const [
              Color(0xFF059669),
              Color(0xFF06B6D4),
              Color(0xFF3B82F6),
              Color(0xFF6366F1),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Sunset gradient - Warm amber to orange to coral blend.
  static LinearGradient sunsetGradient({bool darkMode = false}) {
    return LinearGradient(
      colors: darkMode
          ? const [
              Color(0xFFFBBF24),
              Color(0xFFFB923C),
              Color(0xFFF87171),
            ]
          : const [
              Color(0xFFF59E0B),
              Color(0xFFF97316),
              Color(0xFFEF4444),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Ocean gradient - Deep blue to teal.
  static LinearGradient oceanGradient({bool darkMode = false}) {
    return LinearGradient(
      colors: darkMode
          ? const [
              Color(0xFF3B82F6),
              Color(0xFF22D3EE),
              Color(0xFF10B981),
            ]
          : const [
              Color(0xFF2563EB),
              Color(0xFF06B6D4),
              Color(0xFF059669),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Radial brand gradient - For circular elements.
  static RadialGradient radialBrandGradient({bool darkMode = false}) {
    return RadialGradient(
      colors: darkMode
          ? const [Color(0xFF818CF8), Color(0xFF60A5FA), Color(0xFF0F172A)]
          : const [Color(0xFF6366F1), Color(0xFF3B82F6), Color(0xFFF8FAFC)],
      stops: const [0.0, 0.5, 1.0],
      radius: 1.2,
    );
  }

  /// Sweep gradient - For spinner/loading elements.
  static SweepGradient sweepGradient({bool darkMode = false}) {
    return SweepGradient(
      colors: [
        darkMode ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
        darkMode ? const Color(0xFF22D3EE) : const Color(0xFF06B6D4),
        darkMode ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6),
        darkMode ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
      ],
      stops: const [0.0, 0.33, 0.66, 1.0],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ELEVATION SHADOW SYSTEM
  // ═══════════════════════════════════════════════════════════════════════════

  /// Utility for elevation shadow levels (1-5).
  static List<BoxShadow> elevation({int level = 2, bool darkMode = false}) {
    final baseColor = Colors.black.withValues(alpha: darkMode ? 0.35 : 0.15);
    switch (level) {
      case 1:
        return [
          BoxShadow(
            color: baseColor.withValues(alpha: darkMode ? 0.25 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: baseColor.withValues(alpha: darkMode ? 0.15 : 0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ];
      case 2:
        return [
          BoxShadow(
            color: baseColor.withValues(alpha: darkMode ? 0.3 : 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: baseColor.withValues(alpha: darkMode ? 0.15 : 0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ];
      case 3:
        return [
          BoxShadow(
            color: baseColor.withValues(alpha: darkMode ? 0.35 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: baseColor.withValues(alpha: darkMode ? 0.2 : 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
      case 4:
        return [
          BoxShadow(
            color: baseColor.withValues(alpha: darkMode ? 0.4 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: baseColor.withValues(alpha: darkMode ? 0.25 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];
      case 5:
        return [
          BoxShadow(
            color: baseColor.withValues(alpha: darkMode ? 0.45 : 0.15),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: baseColor.withValues(alpha: darkMode ? 0.3 : 0.1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ];
      default:
        return [
          BoxShadow(
            color: baseColor,
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ];
    }
  }

  /// Colored elevation shadows - Matches the element's color.
  static List<BoxShadow> coloredElevation(Color color, {int level = 2}) {
    switch (level) {
      case 1:
        return [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      case 2:
        return [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
      case 3:
      default:
        return [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GLOW EFFECTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Glow shadow - For buttons, icons, and interactive elements.
  /// [intensity] ranges from 0.0 to 1.0
  static List<BoxShadow> glowShadow(Color color, {double intensity = 0.5}) {
    final clampedIntensity = intensity.clamp(0.0, 1.0);
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.15 * clampedIntensity),
        blurRadius: 32,
        spreadRadius: 4,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.25 * clampedIntensity),
        blurRadius: 16,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.4 * clampedIntensity),
        blurRadius: 8,
      ),
    ];
  }

  /// Subtle glow - For hover states and subtle highlights.
  static List<BoxShadow> subtleGlow(Color color, {bool darkMode = false}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: darkMode ? 0.2 : 0.15),
        blurRadius: 20,
        spreadRadius: 1,
      ),
    ];
  }

  /// Pulsating glow base - Use with animation for pulsing effect.
  /// [phase] should be animated between 0.0 and 1.0
  static List<BoxShadow> pulseGlow(Color color, double phase) {
    final intensity = 0.3 + (0.3 * phase);
    return [
      BoxShadow(
        color: color.withValues(alpha: intensity * 0.5),
        blurRadius: 24 + (8 * phase),
        spreadRadius: 2 + (2 * phase),
      ),
      BoxShadow(
        color: color.withValues(alpha: intensity),
        blurRadius: 12 + (4 * phase),
      ),
    ];
  }

  /// Neon glow - High intensity colored glow.
  static List<BoxShadow> neonGlow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.1),
        blurRadius: 40,
        spreadRadius: 8,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: 20,
        spreadRadius: 4,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.5),
        blurRadius: 10,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.8),
        blurRadius: 4,
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NEUMORPHISM
  // ═══════════════════════════════════════════════════════════════════════════

  /// Neumorphic shadow pair - Creates the raised 3D effect.
  static List<BoxShadow> neumorphicShadow(
      {bool darkMode = false, bool isPressed = false}) {
    if (darkMode) {
      return isPressed
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(-2, -2),
              ),
              BoxShadow(
                color: const Color(0xFF2D3A4F).withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 8,
                offset: const Offset(4, 4),
              ),
              BoxShadow(
                color: const Color(0xFF2D3A4F).withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(-4, -4),
              ),
            ];
    } else {
      return isPressed
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(-2, -2),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.7),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(4, 4),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.9),
                blurRadius: 8,
                offset: const Offset(-4, -4),
              ),
            ];
    }
  }

  /// Inner shadow decoration for pressed/inset states.
  static BoxDecoration innerShadowDecoration({bool darkMode = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: darkMode
            ? [
                Colors.black.withValues(alpha: 0.2),
                Colors.transparent,
                const Color(0xFF2D3A4F).withValues(alpha: 0.1),
              ]
            : [
                Colors.black.withValues(alpha: 0.08),
                Colors.transparent,
                Colors.white.withValues(alpha: 0.5),
              ],
        stops: const [0.0, 0.5, 1.0],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GLASSMORPHISM
  // ═══════════════════════════════════════════════════════════════════════════

  /// Glass effect background.
  static Color glassBackground({bool darkMode = false}) {
    return (darkMode ? Colors.white : Colors.black).withValues(alpha: 0.06);
  }

  /// Glass effect border.
  static Color glassBorder({bool darkMode = false}) {
    return Colors.white.withValues(alpha: darkMode ? 0.08 : 0.35);
  }

  /// Premium frosted glass decoration.
  static BoxDecoration frostedGlass(
      {bool darkMode = false, double borderRadius = 20}) {
    return BoxDecoration(
      color: darkMode
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: darkMode
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.8),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: darkMode ? 0.3 : 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Gradient border for glass effect.
  static BoxDecoration glassGradientBorder(
      {bool darkMode = false, double borderRadius = 20}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: darkMode
            ? [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ]
            : [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.4),
              ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INTERACTIVE STATE UTILITIES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get hover color for any base color.
  static Color hoverColor(Color base, {bool darkMode = false}) {
    return darkMode
        ? Color.lerp(base, Colors.white, 0.1)!
        : Color.lerp(base, Colors.black, 0.08)!;
  }

  /// Get pressed/active color for any base color.
  static Color pressedColor(Color base, {bool darkMode = false}) {
    return darkMode
        ? Color.lerp(base, Colors.white, 0.2)!
        : Color.lerp(base, Colors.black, 0.15)!;
  }

  /// Get disabled color for any base color.
  static Color disabledColor(Color base) {
    return base.withValues(alpha: 0.4);
  }

  /// Get focus ring color.
  static Color focusRing({bool darkMode = false}) {
    return darkMode
        ? primaryDark.withValues(alpha: 0.5)
        : primary.withValues(alpha: 0.4);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OVERLAY & BACKDROP
  // ═══════════════════════════════════════════════════════════════════════════

  /// Modal backdrop overlay color.
  static Color modalBackdrop({bool darkMode = false}) {
    return darkMode
        ? Colors.black.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.4);
  }

  /// Scrim overlay for dimming content.
  static Color scrim({bool darkMode = false, double opacity = 0.5}) {
    return darkMode
        ? Colors.black.withValues(alpha: opacity)
        : Colors.black.withValues(alpha: opacity * 0.6);
  }

  /// Shimmer base color for loading states.
  static Color shimmerBase({bool darkMode = false}) {
    return darkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  }

  /// Shimmer highlight color for loading states.
  static Color shimmerHighlight({bool darkMode = false}) {
    return darkMode ? const Color(0xFF475569) : const Color(0xFFF8FAFC);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COLOR MANIPULATION UTILITIES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a Color from a hex string (supports #RRGGBB and #AARRGGBB).
  static Color fromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  /// Converts a Color to a hex string.
  static String toHex(Color color, {bool includeAlpha = false}) {
    final r = color.red.toRadixString(16).padLeft(2, '0');
    final g = color.green.toRadixString(16).padLeft(2, '0');
    final b = color.blue.toRadixString(16).padLeft(2, '0');
    if (includeAlpha) {
      final a = color.alpha.toRadixString(16).padLeft(2, '0');
      return '#$a$r$g$b';
    }
    return '#$r$g$b';
  }

  /// Adjusts brightness of a color.
  /// [factor] ranges from -1.0 (darker) to 1.0 (lighter)
  static Color adjustBrightness(Color color, double factor) {
    assert(factor >= -1 && factor <= 1);
    if (factor > 0) {
      return Color.lerp(color, Colors.white, factor)!;
    } else {
      return Color.lerp(color, Colors.black, -factor)!;
    }
  }

  /// Adjusts saturation of a color.
  /// [factor] ranges from -1.0 (desaturate) to 1.0 (saturate)
  static Color adjustSaturation(Color color, double factor) {
    assert(factor >= -1 && factor <= 1);
    final hsl = HSLColor.fromColor(color);
    final newSaturation = (hsl.saturation + factor).clamp(0.0, 1.0);
    return hsl.withSaturation(newSaturation).toColor();
  }

  /// Returns contrasting text color (white or black) for given background.
  static Color contrastingText(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? textPrimary : textPrimaryDark;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DROPDOWN / INPUT STYLING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Dropdown background color with proper contrast.
  static Color dropdownBackground({bool darkMode = false}) {
    return darkMode
        ? const Color(0xFF1E293B) // Dark slate - high contrast with text
        : Colors.white;
  }

  /// Dropdown item hover/selected background.
  static Color dropdownItemHover({bool darkMode = false}) {
    return darkMode
        ? primary.withValues(alpha: 0.15)
        : primary.withValues(alpha: 0.08);
  }

  /// Dropdown border color.
  static Color dropdownBorder({bool darkMode = false}) {
    return darkMode
        ? primary.withValues(alpha: 0.3)
        : primary.withValues(alpha: 0.2);
  }

  /// Input/dropdown container decoration with proper theming.
  static BoxDecoration dropdownDecoration(
      {bool darkMode = false, bool focused = false}) {
    return BoxDecoration(
      color: darkMode
          ? surfaceElevatedDark.withValues(alpha: 0.8)
          : Colors.white.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: focused
            ? (darkMode ? primaryDark : primary)
            : (darkMode
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.1)),
        width: focused ? 2 : 1,
      ),
      boxShadow: focused
          ? [
              BoxShadow(
                color:
                    (darkMode ? primaryDark : primary).withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ]
          : null,
    );
  }

  /// Dropdown text style with proper theming.
  static TextStyle dropdownTextStyle({bool darkMode = false}) {
    return TextStyle(
      color: darkMode ? Colors.white : Colors.black87,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TOOLTIP STYLING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Tooltip background color.
  static Color tooltipBackground({bool darkMode = false}) {
    return darkMode
        ? const Color(0xFF334155) // Slate 700
        : const Color(0xFF1E293B); // Slate 800
  }

  /// Tooltip text color - always light for visibility.
  static Color tooltipText({bool darkMode = false}) {
    return Colors.white;
  }

  /// Tooltip decoration with premium styling.
  static BoxDecoration tooltipDecoration({bool darkMode = false}) {
    return BoxDecoration(
      color: tooltipBackground(darkMode: darkMode),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: primary.withValues(alpha: 0.3),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: primary.withValues(alpha: 0.1),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ALERT/NOTIFICATION BACKDROP
  // ═══════════════════════════════════════════════════════════════════════════

  /// Light/transparent alert backdrop - allows seeing content underneath.
  static Color alertBackdrop({bool darkMode = false}) {
    return darkMode
        ? Colors.black.withValues(alpha: 0.25) // Very transparent
        : Colors.black.withValues(alpha: 0.15);
  }

  /// Get themed surface color based on elevation context.
  static Color themedSurface({bool darkMode = false, int elevation = 0}) {
    if (darkMode) {
      switch (elevation) {
        case 0:
          return backgroundDark;
        case 1:
          return surfaceDark;
        case 2:
          return surfaceElevatedDark;
        default:
          return cardHoverDark;
      }
    } else {
      switch (elevation) {
        case 0:
          return background;
        case 1:
          return surface;
        case 2:
          return surfaceElevated;
        default:
          return cardHover;
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // THEMED TEXT & ICON COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Theme-aware primary text color
  static Color themedText({bool darkMode = false}) {
    return darkMode ? textPrimaryDark : textPrimary;
  }

  /// Theme-aware secondary text color
  static Color themedSecondaryText({bool darkMode = false}) {
    return darkMode ? textSecondaryDark : textSecondary;
  }

  /// Theme-aware icon color (same as text for consistency)
  static Color themedIcon({bool darkMode = false}) {
    return darkMode ? textPrimaryDark : textPrimary;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTROL BUTTON COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Theme-aware control button inactive color
  static Color controlButtonInactive({bool darkMode = false}) {
    return darkMode ? Colors.white70 : Colors.black87;
  }

  /// Theme-aware control button active color
  static Color controlButtonActive({bool darkMode = false}) {
    return darkMode ? primaryDark : primary;
  }

  /// Theme-aware text color for control labels
  static Color controlTextColor({bool darkMode = false}) {
    return darkMode ? Colors.white : Colors.black87;
  }

  /// Recording status - active (recording)
  static Color get recordingActive => danger;

  /// Recording status - paused
  static Color get recordingPaused => warning;

  /// Recording status - stopped
  static Color get recordingStopped => success;
}
