import 'package:flutter/material.dart';

/// A modal widget displaying a loading indicator.
///
/// Parameters:
/// - isVisible: A boolean indicating whether the loading modal is visible.
/// - backgroundColor: The background color of the loading modal.
/// - displayColor: The color of the loading indicator and text.
///
/// Example:
/// ```dart
/// LoadingModal(
///   isVisible: true,
///   backgroundColor: Colors.black.withOpacity(0.5),
///   displayColor: Colors.white,
/// )
/// ```

class LoadingModal extends StatelessWidget {
  final bool isVisible;
  final Color backgroundColor;
  final Color displayColor;

  const LoadingModal({
    super.key,
    required this.isVisible,
    required this.backgroundColor,
    required this.displayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // To prevent taps outside the modal
              child: Container(
                color: backgroundColor.withOpacity(0.99),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 1.0,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(displayColor),
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Loading...',
                      style: TextStyle(color: displayColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
