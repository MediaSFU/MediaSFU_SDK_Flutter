import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/misc_components/welcome_page.dart'
    show WelcomePageOptions;
import '../../types/types.dart' show ConnectSocketOptions;
import '../core/theme/mediasfu_borders.dart';
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/theme/mediasfu_typography.dart';
import '../core/widgets/glassmorphic_container.dart';
import '../core/widgets/gradient_card.dart';

/// Rate limit constants (copied from original)
const int _maxAttempts = 20;
const int _rateLimitDuration = 3 * 60 * 60 * 1000; // 3 hours in ms

/// Modern redesigned WelcomePage with glassmorphic styling.
/// Retains all business logic from the original component.
class ModernWelcomePage extends StatefulWidget {
  final WelcomePageOptions options;

  const ModernWelcomePage({super.key, required this.options});

  @override
  State<ModernWelcomePage> createState() => _ModernWelcomePageState();
}

class _ModernWelcomePageState extends State<ModernWelcomePage>
    with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // STATE (from original)
  // ─────────────────────────────────────────────────────────────────────────
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();
  final TextEditingController _eventIDController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  bool _pending = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _secretController.dispose();
    _eventIDController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUSINESS LOGIC (copied from original)
  // ─────────────────────────────────────────────────────────────────────────
  bool _validateAlphanumeric(String value) {
    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumericRegex.hasMatch(value);
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _handleConfirm() async {
    if (_pending) return;
    setState(() => _pending = true);
    widget.options.updateIsLoadingModalVisible(true);

    final String name = _nameController.text;
    final String secret = _secretController.text;
    final String eventID = _eventIDController.text;
    final String link = _linkController.text;

    if (name.isEmpty || secret.isEmpty || eventID.isEmpty || link.isEmpty) {
      widget.options.showAlert!(
        message: 'Please fill all the fields.',
        type: 'danger',
        duration: 3000,
      );
      widget.options.updateIsLoadingModalVisible(false);
      setState(() => _pending = false);
      return;
    }

    if (!_validateAlphanumeric(name) ||
        !_validateAlphanumeric(secret) ||
        !_validateAlphanumeric(eventID) ||
        !link.contains('mediasfu.com') ||
        eventID.toLowerCase().startsWith('d')) {
      widget.options.showAlert!(
        message: 'Please enter valid details.',
        type: 'danger',
        duration: 3000,
      );
      widget.options.updateIsLoadingModalVisible(false);
      setState(() => _pending = false);
      return;
    }

    if (secret.length != 64 ||
        name.length > 12 ||
        name.length < 2 ||
        eventID.length > 32 ||
        eventID.length < 8 ||
        link.length < 12) {
      widget.options.showAlert!(
        message: 'Please enter valid details.',
        type: 'danger',
        duration: 3000,
      );
      widget.options.updateIsLoadingModalVisible(false);
      setState(() => _pending = false);
      return;
    }

    await _checkLimitsAndMakeRequest(
      apiUserName: eventID,
      apiToken: secret,
      link: link,
      userName: name,
    );
    widget.options.updateIsLoadingModalVisible(false);
    if (mounted) setState(() => _pending = false);
  }

  Future<void> _checkLimitsAndMakeRequest({
    required String apiUserName,
    String apiToken = "",
    String apiKey = "",
    required String link,
    required String userName,
  }) async {
    const int duration = 20000;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int unsuccessfulAttempts = prefs.getInt('unsuccessfulAttempts') ?? 0;
    int lastRequestTimestamp = prefs.getInt('lastRequestTimestamp') ?? 0;

    if (unsuccessfulAttempts >= _maxAttempts) {
      if (DateTime.now().millisecondsSinceEpoch - lastRequestTimestamp <
          _rateLimitDuration) {
        widget.options.showAlert!(
          message: 'Too many unsuccessful attempts. Please try again later.',
          type: 'danger',
          duration: 3000,
        );
        prefs.setInt(
          'lastRequestTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
        return;
      } else {
        unsuccessfulAttempts = 0;
        prefs.setInt('unsuccessfulAttempts', unsuccessfulAttempts);
        prefs.setInt(
          'lastRequestTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    }

    try {
      widget.options.updateIsLoadingModalVisible(true);

      final socketPromise = widget.options.connectSocket(ConnectSocketOptions(
          apiUserName: apiUserName,
          apiToken: apiToken,
          apiKey: apiKey,
          link: link));
      const timeoutDuration = Duration(milliseconds: duration);

      final socketWithTimeout = await socketPromise.timeout(
        timeoutDuration,
        onTimeout: () {
          throw TimeoutException('Socket connection timed out');
        },
      );

      if (socketWithTimeout.id!.isNotEmpty) {
        unsuccessfulAttempts = 0;
        prefs.setInt('unsuccessfulAttempts', unsuccessfulAttempts);
        prefs.setInt(
          'lastRequestTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
        widget.options.updateSocket(socketWithTimeout);
        widget.options.updateApiUserName(apiUserName);
        widget.options.updateApiToken(apiToken);
        widget.options.updateLink(link);
        widget.options.updateRoomName(apiUserName);
        widget.options.updateMember(userName);
        widget.options.updateIsLoadingModalVisible(false);
        widget.options.updateValidated(true);
      } else {
        widget.options.updateIsLoadingModalVisible(false);
        unsuccessfulAttempts++;
        prefs.setInt('unsuccessfulAttempts', unsuccessfulAttempts);
        prefs.setInt(
          'lastRequestTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
        if (unsuccessfulAttempts >= _maxAttempts) {
          widget.options.showAlert!(
            message: 'Too many unsuccessful attempts. Please try again later.',
            type: 'danger',
            duration: 3000,
          );
        } else {
          widget.options.showAlert!(
            message: 'Invalid credentials. Please try again later.',
            type: 'danger',
            duration: 3000,
          );
        }
      }
    } catch (error) {
      widget.options.updateIsLoadingModalVisible(false);
      prefs.setInt('unsuccessfulAttempts', unsuccessfulAttempts);
      prefs.setInt(
        'lastRequestTimestamp',
        DateTime.now().millisecondsSinceEpoch,
      );

      if (unsuccessfulAttempts >= _maxAttempts) {
        widget.options.showAlert!(
          message: 'Too many unsuccessful attempts. Please try again later.',
          type: 'danger',
          duration: 3000,
        );
      } else {
        widget.options.showAlert!(
          message: 'Unable to connect. ${error.toString()}',
          type: 'danger',
          duration: 3000,
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MODERN UI BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = MediasfuTypography.textTheme(darkMode: isDark);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0xFF0F172A), Color(0xFF1E1B4B)]
                    : const [Color(0xFFE0E7FF), Color(0xFFF8FAFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Frosted blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
            child: Container(color: Colors.transparent),
          ),
          // Content
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding: MediasfuSpacing.insetAll(MediasfuSpacing.lg),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo with gradient ring and glow
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:
                                MediasfuColors.brandGradient(darkMode: isDark),
                            boxShadow: [
                              BoxShadow(
                                color: MediasfuColors.primary
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(3),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundImage:
                                NetworkImage(widget.options.imgSrc),
                          ),
                        ),
                        const SizedBox(height: MediasfuSpacing.lg),

                        // Hero card
                        GradientCard(
                          title: 'Welcome',
                          subtitle:
                              'Enter your event details to join the session.',
                        ),
                        const SizedBox(height: MediasfuSpacing.xl),

                        // Form container
                        GlassmorphicContainer(
                          padding: MediasfuSpacing.insetAll(MediasfuSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTextField(
                                controller: _nameController,
                                label: 'Display Name',
                                hint: '2-12 characters',
                              ),
                              const SizedBox(height: MediasfuSpacing.md),
                              _buildTextField(
                                controller: _secretController,
                                label: 'Event Token',
                                hint: '64-char secret',
                              ),
                              const SizedBox(height: MediasfuSpacing.md),
                              _buildTextField(
                                controller: _eventIDController,
                                label: 'Event ID',
                                hint: 'Your meeting ID',
                              ),
                              const SizedBox(height: MediasfuSpacing.md),
                              _buildTextField(
                                controller: _linkController,
                                label: 'Event Link',
                                hint: 'https://...',
                              ),
                              const SizedBox(height: MediasfuSpacing.lg),
                              _buildPrimaryButton(),
                              const SizedBox(height: MediasfuSpacing.md),
                              Center(
                                child: Text(
                                  'Need credentials?',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black45,
                                  ),
                                ),
                              ),
                              // Premium styled link button
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(MediasfuBorders.lg),
                                  border: Border.all(
                                    color: isDark
                                        ? MediasfuColors.primaryDark
                                            .withValues(alpha: 0.5)
                                        : MediasfuColors.primary
                                            .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _launchURL(
                                        'https://meeting.mediasfu.com/meeting/start/'),
                                    borderRadius: BorderRadius.circular(
                                        MediasfuBorders.lg),
                                    child: Padding(
                                      padding: MediasfuSpacing.insetSymmetric(
                                        horizontal: MediasfuSpacing.md,
                                        vertical: MediasfuSpacing.sm,
                                      ),
                                      child: ShaderMask(
                                        shaderCallback: (bounds) =>
                                            MediasfuColors.brandGradient(
                                                    darkMode: isDark)
                                                .createShader(bounds),
                                        child: Text(
                                          'Get them from mediasfu.com',
                                          style: textTheme.labelLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Focus(
      child: Builder(
        builder: (context) {
          final isFocused = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(MediasfuBorders.lg),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: MediasfuColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: TextField(
              controller: controller,
              style: MediasfuTypography.bodyLarge.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                labelStyle: TextStyle(
                  color: isFocused
                      ? MediasfuColors.primary
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MediasfuBorders.lg),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MediasfuBorders.lg),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MediasfuBorders.lg),
                  borderSide: BorderSide(
                    color: MediasfuColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: MediasfuSpacing.insetSymmetric(
                  horizontal: MediasfuSpacing.md,
                  vertical: MediasfuSpacing.md,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrimaryButton() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.3, end: 0.6),
      duration: const Duration(milliseconds: 1500),
      builder: (context, glowValue, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            gradient: MediasfuColors.brandGradient(darkMode: isDark),
            borderRadius: BorderRadius.circular(9999),
            boxShadow: [
              BoxShadow(
                color: MediasfuColors.primary.withValues(alpha: glowValue),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              ...MediasfuColors.elevation(level: 2, darkMode: isDark),
            ],
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _pending ? null : _handleConfirm,
          borderRadius: BorderRadius.circular(9999),
          child: Padding(
            padding: MediasfuSpacing.insetSymmetric(
              horizontal: MediasfuSpacing.xl,
              vertical: MediasfuSpacing.md,
            ),
            child: Center(
              child: _pending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Confirm',
                      style: MediasfuTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Convenience builder conforming to WelcomePageType signature.
Widget modernWelcomePageBuilder({required WelcomePageOptions options}) {
  return ModernWelcomePage(options: options);
}
