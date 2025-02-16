import 'package:flutter/material.dart';

/// `LoadingModalOptions` - Configuration options for the `LoadingModal` widget.
///
/// ### Properties:
/// - `isVisible` (`bool`): Determines if the loading modal is visible.
/// - `backgroundColor` (`Color`): Background color of the modal overlay, defaulting to a semi-transparent black.
/// - `displayColor` (`Color`): Color for the loading indicator and loading text.
///
/// ### Example Usage:
/// ```dart
/// LoadingModalOptions(
///   isVisible: true,
///   backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
///   displayColor: Colors.white,
/// );
/// ```

class LoadingModalOptions {
  /// A boolean indicating whether the loading modal is visible.
  final bool isVisible;

  /// The background color of the loading modal overlay.
  final Color backgroundColor;

  /// The color of the loading indicator and loading text.
  final Color displayColor;

  /// Constructs a `LoadingModalOptions` object with the given configuration.
  const LoadingModalOptions({
    required this.isVisible,
    this.backgroundColor = const Color.fromRGBO(0, 0, 0, 0.5),
    this.displayColor = Colors.black,
  });
}

typedef LoadingModalType = Widget Function(
    {required LoadingModalOptions options});

/// `LoadingModal` - A loading modal overlay widget.
///
/// This modal displays a centered loading indicator with customizable background and indicator colors.
/// It blocks interactions outside the modal when visible.
///
/// ### Features:
/// - Fully covers the screen to create a loading overlay.
/// - Customizable background and indicator color.
/// - Prevents interaction outside the modal when visible.
///
/// ### Example Usage:
/// ```dart
/// LoadingModal(
///   options: LoadingModalOptions(
///     isVisible: true,
///     backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
///     displayColor: Colors.white,
///   ),
/// );
/// ```
class LoadingModal extends StatelessWidget {
  final LoadingModalOptions options;

  const LoadingModal({
    super.key,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: options.isVisible,
      child: Stack(
        children: [
          // Block interactions outside modal
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // Prevent interactions outside the modal
              child: Container(
                color: options.backgroundColor.withAlpha((0.5 * 255).toInt()),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 1.0,
                decoration: BoxDecoration(
                  color: options.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(options.displayColor),
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Loading...',
                      style: TextStyle(color: options.displayColor),
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
