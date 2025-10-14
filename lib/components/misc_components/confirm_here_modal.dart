import 'dart:async';
import 'dart:math' as math;

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/material.dart';
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/modal_style_options.dart'
  show ConfirmHereModalStyleOptions;
typedef ConfirmHereModalLoaderBuilder = Widget Function(
  ConfirmHereModalLoaderContext context);
typedef ConfirmHereModalMessageBuilder = Widget Function(
  ConfirmHereModalMessageContext context);
typedef ConfirmHereModalCountdownBuilder = Widget Function(
  ConfirmHereModalCountdownContext context);
typedef ConfirmHereModalButtonBuilder = Widget Function(
  ConfirmHereModalButtonContext context);
typedef ConfirmHereModalBodyBuilder = Widget Function(
  ConfirmHereModalBodyContext context);
typedef ConfirmHereModalContentBuilder = Widget Function(
  ConfirmHereModalContentContext context);
typedef ConfirmHereModalOverlayBuilder = Widget Function(
  ConfirmHereModalOverlayContext context);

/// `ConfirmHereModalOptions` defines the configuration for `ConfirmHereModal`,
/// including visibility, callbacks, countdown, and socket settings.
///
/// - `isConfirmHereModalVisible`: Controls visibility.
/// - `onConfirmHereClose`: Callback to handle closing.
/// - `backgroundColor`: Modal background color.
/// - `countdownDuration`: Duration for countdown in seconds.
/// - `socket`: WebSocket connection.
/// - `localSocket`: Local WebSocket connection.
/// - `roomName`: Room name for session.
/// - `member`: Member ID for user.

class ConfirmHereModalOptions {
  final bool isConfirmHereModalVisible;
  final VoidCallback onConfirmHereClose;
  final io.Socket? socket;
  final io.Socket? localSocket;
  final String roomName;
  final String member;
  final Color backgroundColor;
  final Color displayColor;
  final int countdownDuration;
  final String position;
  final ConfirmHereModalStyleOptions? styles;
  final Widget? heading;
  final Widget? description;
  final Widget? loader;
  final Widget? countdownLabel;
  final Widget? confirmButton;
  final ConfirmHereModalLoaderBuilder? loaderBuilder;
  final ConfirmHereModalMessageBuilder? messageBuilder;
  final ConfirmHereModalCountdownBuilder? countdownBuilder;
  final ConfirmHereModalButtonBuilder? buttonBuilder;
  final ConfirmHereModalBodyBuilder? bodyBuilder;
  final ConfirmHereModalContentBuilder? contentBuilder;
  final ConfirmHereModalOverlayBuilder? overlayBuilder;

  ConfirmHereModalOptions({
    required this.isConfirmHereModalVisible,
    required this.onConfirmHereClose,
    this.socket,
    this.localSocket,
    required this.roomName,
    required this.member,
    this.backgroundColor = const Color(0xFF83c0e9),
    this.displayColor = Colors.black,
    this.countdownDuration = 120,
    this.position = 'center',
    this.styles,
    this.heading,
    this.description,
    this.loader,
    this.countdownLabel,
    this.confirmButton,
    this.loaderBuilder,
    this.messageBuilder,
    this.countdownBuilder,
    this.buttonBuilder,
    this.bodyBuilder,
    this.contentBuilder,
    this.overlayBuilder,
  });
}

typedef ConfirmHereModalType = Widget Function(
    {required ConfirmHereModalOptions options});

/// `ConfirmHereModal` prompts the user to confirm presence with a countdown timer and action button.
///
/// Example Usage:
/// ```dart
/// ConfirmHereModal(
///   options: ConfirmHereModalOptions(
///     isConfirmHereModalVisible: true,
///     onConfirmHereClose: () => print("Modal closed"),
///     socket: io.Socket(),
///     localSocket: io.Socket(),
///     roomName: "room1",
///     member: "user1",
///   ),
/// );
/// ```

class ConfirmHereModal extends StatefulWidget {
  final ConfirmHereModalOptions options;

  const ConfirmHereModal({super.key, required this.options});

  @override
  _ConfirmHereModalState createState() => _ConfirmHereModalState();
}

class _ConfirmHereModalState extends State<ConfirmHereModal> {
  Timer? countdownTimer;
  late int counter;

  @override
  void initState() {
    super.initState();
    counter = widget.options.countdownDuration;
    if (widget.options.isConfirmHereModalVisible) {
      startCountdown();
    }
  }

  @override
  void didUpdateWidget(covariant ConfirmHereModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.isConfirmHereModalVisible !=
        oldWidget.options.isConfirmHereModalVisible) {
      if (widget.options.isConfirmHereModalVisible) {
        startCountdown();
      } else {
        stopCountdown();
      }
    }
    if (widget.options.countdownDuration !=
        oldWidget.options.countdownDuration) {
      counter = widget.options.countdownDuration;
      if (widget.options.isConfirmHereModalVisible) {
        startCountdown();
      }
    }
  }

  @override
  void dispose() {
    stopCountdown();
    super.dispose();
  }

  void startCountdown() {
    stopCountdown(resetCounter: false);
    counter = widget.options.countdownDuration;
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        counter--;
      });
      if (counter <= 0) {
        _handleTimeout();
      }
    });
  }

  void stopCountdown({bool resetCounter = true}) {
    countdownTimer?.cancel();
    countdownTimer = null;
    if (resetCounter) {
      counter = widget.options.countdownDuration;
    }
  }

  void _handleTimeout() {
    stopCountdown();
    widget.options.onConfirmHereClose();
    widget.options.socket?.emit('disconnectUser', {
      'member': widget.options.member,
      'roomName': widget.options.roomName,
      'ban': false,
    });

    try {
      final localSocket = widget.options.localSocket;
      if (localSocket != null && localSocket.id != null) {
        localSocket.emit('disconnectUser', {
          'member': widget.options.member,
          'roomName': widget.options.roomName,
          'ban': false,
        });
      }
    } catch (_) {
      // Silently ignore local socket errors.
    }
  }

  void _confirmAndClose() {
    stopCountdown();
    widget.options.onConfirmHereClose();
  }

  @override
  Widget build(BuildContext context) {
    final styles =
        widget.options.styles ?? const ConfirmHereModalStyleOptions();
    final mediaSize = MediaQuery.of(context).size;

    double modalWidth = styles.width ?? math.min(mediaSize.width * 0.8, 400.0);
    if (styles.maxWidth != null) {
      modalWidth = math.min(modalWidth, styles.maxWidth!);
    }
    if (styles.maxContentWidth != null) {
      modalWidth = math.min(modalWidth, styles.maxContentWidth!);
    }

    double modalHeight = styles.height ?? mediaSize.height * 0.65;
    if (styles.maxHeight != null) {
      modalHeight = math.min(modalHeight, styles.maxHeight!);
    }

    final positionData = getModalPosition(
      GetModalPositionOptions(
        position: widget.options.position,
        modalWidth: modalWidth,
        modalHeight: modalHeight,
        context: context,
      ),
    );

    final spinnerColor = styles.spinnerColor ?? widget.options.displayColor;
    final defaultLoader = widget.options.loader ??
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
        );

    final resolvedLoader = widget.options.loaderBuilder?.call(
          ConfirmHereModalLoaderContext(
            defaultLoader: defaultLoader,
            counter: counter,
            totalDuration: widget.options.countdownDuration,
          ),
        ) ??
        defaultLoader;

    final heading = widget.options.heading ??
        Text(
          'Are you still there?',
          style: styles.titleTextStyle ??
              TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.options.displayColor,
              ),
          textAlign: TextAlign.center,
        );

    final description = widget.options.description ??
        Text(
          'Please confirm if you are still present.',
          style: styles.messageTextStyle ??
              TextStyle(
                fontSize: 16,
                color: widget.options.displayColor,
              ),
          textAlign: TextAlign.center,
        );

    final defaultMessage = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        heading,
        const SizedBox(height: 15),
        description,
      ],
    );

    final resolvedMessage = widget.options.messageBuilder?.call(
          ConfirmHereModalMessageContext(
            defaultMessage: defaultMessage,
            heading: heading,
            description: description,
            counter: counter,
            totalDuration: widget.options.countdownDuration,
          ),
        ) ??
        defaultMessage;

    final labelStyle = styles.countdownTextStyle ??
        TextStyle(
          fontSize: 14,
          color: widget.options.displayColor,
        );
    final valueStyle = styles.countdownValueTextStyle ??
        labelStyle.copyWith(fontWeight: FontWeight.bold);

    final defaultCountdown = widget.options.countdownLabel ??
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Time remaining: ', style: labelStyle),
              TextSpan(text: '$counter', style: valueStyle),
            ],
          ),
          textAlign: TextAlign.center,
        );

    final resolvedCountdown = widget.options.countdownBuilder?.call(
          ConfirmHereModalCountdownContext(
            defaultCountdown: defaultCountdown,
            counter: counter,
            totalDuration: widget.options.countdownDuration,
          ),
        ) ??
        defaultCountdown;

    final defaultButton = widget.options.confirmButton ??
        FilledButton(
          onPressed: _confirmAndClose,
          style: styles.confirmButtonStyle ??
              FilledButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
          child: const Text(
            'Yes',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

    final resolvedButton = widget.options.buttonBuilder?.call(
          ConfirmHereModalButtonContext(
            defaultButton: defaultButton,
            onConfirm: _confirmAndClose,
          ),
        ) ??
        defaultButton;

    final bodyPadding = styles.bodySpacing ??
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16);

    final defaultBody = Padding(
      padding: bodyPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          resolvedLoader,
          const SizedBox(height: 20),
          resolvedMessage,
          const SizedBox(height: 10),
          resolvedCountdown,
          const SizedBox(height: 16),
          resolvedButton,
        ],
      ),
    );

    final resolvedBody = widget.options.bodyBuilder?.call(
          ConfirmHereModalBodyContext(
            defaultBody: defaultBody,
            counter: counter,
            totalDuration: widget.options.countdownDuration,
          ),
        ) ??
        defaultBody;

    final defaultContent = Center(child: resolvedBody);

    final resolvedContent = widget.options.contentBuilder?.call(
          ConfirmHereModalContentContext(
            defaultContent: defaultContent,
            counter: counter,
            totalDuration: widget.options.countdownDuration,
          ),
        ) ??
        defaultContent;

    Widget? overlayWidget;
    if (styles.overlayColor != null) {
      overlayWidget = ColoredBox(color: styles.overlayColor!);
    }
    if (widget.options.overlayBuilder != null) {
      overlayWidget = widget.options.overlayBuilder!(
        ConfirmHereModalOverlayContext(
          defaultOverlay: overlayWidget ?? const SizedBox.shrink(),
        ),
      );
    }

    final outerDecoration = styles.outerContainerDecoration ??
        BoxDecoration(
          color: widget.options.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        );

    final innerDecoration = styles.contentDecoration ??
        BoxDecoration(
          color: widget.options.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        );

    return Visibility(
      visible: widget.options.isConfirmHereModalVisible,
      child: Stack(
        children: [
          if (overlayWidget != null) Positioned.fill(child: overlayWidget),
          Positioned(
            top: positionData['top'],
            right: positionData['right'],
            child: Container(
              width: modalWidth,
              height: modalHeight,
              decoration: outerDecoration,
              padding: styles.outerPadding ?? const EdgeInsets.all(16),
              child: DecoratedBox(
                decoration: innerDecoration,
                child: Padding(
                  padding:
                      styles.contentPadding ?? const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: styles.maxContentWidth ?? double.infinity,
                    ),
                    child: resolvedContent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmHereModalLoaderContext {
  final Widget defaultLoader;
  final int counter;
  final int totalDuration;

  const ConfirmHereModalLoaderContext({
    required this.defaultLoader,
    required this.counter,
    required this.totalDuration,
  });
}

class ConfirmHereModalMessageContext {
  final Widget defaultMessage;
  final Widget heading;
  final Widget description;
  final int counter;
  final int totalDuration;

  const ConfirmHereModalMessageContext({
    required this.defaultMessage,
    required this.heading,
    required this.description,
    required this.counter,
    required this.totalDuration,
  });
}

class ConfirmHereModalCountdownContext {
  final Widget defaultCountdown;
  final int counter;
  final int totalDuration;

  const ConfirmHereModalCountdownContext({
    required this.defaultCountdown,
    required this.counter,
    required this.totalDuration,
  });
}

class ConfirmHereModalButtonContext {
  final Widget defaultButton;
  final VoidCallback onConfirm;

  const ConfirmHereModalButtonContext({
    required this.defaultButton,
    required this.onConfirm,
  });
}

class ConfirmHereModalBodyContext {
  final Widget defaultBody;
  final int counter;
  final int totalDuration;

  const ConfirmHereModalBodyContext({
    required this.defaultBody,
    required this.counter,
    required this.totalDuration,
  });
}

class ConfirmHereModalContentContext {
  final Widget defaultContent;
  final int counter;
  final int totalDuration;

  const ConfirmHereModalContentContext({
    required this.defaultContent,
    required this.counter,
    required this.totalDuration,
  });
}

class ConfirmHereModalOverlayContext {
  final Widget defaultOverlay;

  const ConfirmHereModalOverlayContext({required this.defaultOverlay});
}
