import 'dart:async';
import 'package:flutter/material.dart';

/// AlertComponent - A component for displaying alerts with customizable styles.
///
/// This widget displays an alert message with customizable styles such as
/// background color, text color, and duration of visibility. It can be used
/// to show success or error messages to the user.
///
/// Required parameters:
/// - [visible]: A boolean indicating whether the alert should be visible or hidden.
/// - [message]: The message to be displayed in the alert.
/// - [onHide]: A function to handle hiding the alert.
///
/// Optional parameters:
/// - [type]: The type of alert, either 'success' or 'error'. Defaults to 'success'.
/// - [duration]: The duration in milliseconds for which the alert will be visible. Defaults to 3000 milliseconds.
/// - [textColor]: The color of the text in the alert message. Defaults to black.
///
/// Example:
/// ```dart
/// AlertComponent(
///   visible: true,
///   message: 'Alert message',
///   onHide: () {
///     // Logic to hide the alert
///   },
/// );
/// ```

class AlertComponent extends StatefulWidget {
  final bool visible;
  final String message;
  final String type;
  final int duration;
  final Function onHide;
  final Color textColor;

  const AlertComponent({
    super.key,
    required this.visible,
    required this.message,
    this.type = 'success',
    this.duration = 3000,
    required this.onHide,
    this.textColor = Colors.black,
  });

  @override
  // ignore: library_private_types_in_public_api
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
    if (widget.type != oldWidget.type) {
      _updateAlertType();
    }
  }

  void _updateAlertType() {
    setState(() {
      _alertType = widget.type;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.visible) {
      // Start a timer to hide the alert after duration
      Timer(Duration(milliseconds: widget.duration), () {
        widget.onHide();
      });
    }

    return Visibility(
      visible: widget.visible,
      child: GestureDetector(
        onTap: () => widget.onHide(),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: _alertType == 'success' ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
            ),
            padding: const EdgeInsets.all(20),
            child: Text(
              widget.message,
              style: TextStyle(color: widget.textColor, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
