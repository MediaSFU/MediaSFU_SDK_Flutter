import 'dart:async';
import 'package:flutter/material.dart';

/// AlertComponentOptions - Configuration options for the `AlertComponent` widget.
///
/// Example:
/// ```dart
/// AlertComponent(
///   options: AlertComponentOptions(
///     visible: true,
///     message: "Operation successful!",
///     type: "success",
///     duration: 3000,
///     onHide: () => print("Alert hidden"),
///     textColor: Colors.white,
///   ),
/// );
/// ```
class AlertComponentOptions {
  final bool visible;
  final String message;
  final String type;
  final int duration;
  final Function onHide;
  final Color textColor;

  AlertComponentOptions({
    required this.visible,
    required this.message,
    this.type = 'success',
    this.duration = 3000,
    required this.onHide,
    this.textColor = Colors.black,
  });
}

typedef AlertComponentType = Widget Function(
    {required AlertComponentOptions options});

/// AlertComponent - A widget for displaying alerts with customizable options.
///
/// Example:
/// ```dart
/// AlertComponent(
///   options: AlertComponentOptions(
///     visible: true,
///     message: "An error occurred",
///     type: "error",
///     duration: 3000,
///     onHide: () => print("Alert hidden"),
///     textColor: Colors.white,
///   ),
/// );
/// ```
class AlertComponent extends StatefulWidget {
  final AlertComponentOptions options;

  const AlertComponent({
    super.key,
    required this.options,
  });

  @override
  _AlertComponentState createState() => _AlertComponentState();
}

class _AlertComponentState extends State<AlertComponent> {
  String _alertType = '';

  @override
  void initState() {
    super.initState();
    _updateAlertType();
  }

  @override
  void didUpdateWidget(covariant AlertComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.type != oldWidget.options.type) {
      _updateAlertType();
    }
  }

  void _updateAlertType() {
    if (!mounted) return;
    setState(() {
      _alertType = widget.options.type;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options.visible) {
      // Start a timer to hide the alert after duration
      Timer(Duration(milliseconds: widget.options.duration), () {
        widget.options.onHide();
      });
    }

    return Visibility(
      visible: widget.options.visible,
      child: GestureDetector(
        onTap: () => widget.options.onHide(),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: _alertType == 'success' ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
            ),
            padding: const EdgeInsets.all(20),
            child: Text(
              widget.options.message,
              style: TextStyle(color: widget.options.textColor, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
