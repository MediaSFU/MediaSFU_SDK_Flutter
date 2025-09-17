import 'package:flutter/material.dart';

/// MiniCardOptions - Configuration options for the `MiniCard`.
class MiniCardOptions {
  final String initials;
  final double fontSize;
  final BoxDecoration customStyle;
  final String? imageSource;
  final bool roundedImage;
  final BoxDecoration? imageStyle;
  final MiniCardType? customBuilder;

  MiniCardOptions({
    required this.initials,
    this.fontSize = 14,
    this.customStyle = const BoxDecoration(),
    this.imageSource,
    this.roundedImage = true,
    this.imageStyle,
    this.customBuilder,
  });
}

typedef MiniCardType = Widget Function({required MiniCardOptions options});

/// MiniCard - A Flutter widget for displaying a mini card with initials or an image.
///
/// This widget allows you to display a card with either an image or initials. It includes styling options for the card and image,
/// as well as customization for whether the image should have rounded corners.
///
/// ### Parameters:
/// - `options` (`MiniCardOptions`): Configuration options for the mini card.
///
/// ### Example Usage:
/// ```dart
/// // Using the default MiniCard
/// MiniCard(
///   options: MiniCardOptions(
///     initials: "AB",
///     fontSize: 18,
///     customStyle: BoxDecoration(
///       color: Colors.blue,
///       borderRadius: BorderRadius.circular(8),
///       border: Border.all(color: Colors.black, width: 2),
///     ),
///     imageSource: "https://example.com/image.jpg",
///     roundedImage: true,
///   ),
/// );
///
/// // Using a custom MiniCard builder
/// Widget myCustomMiniCard({required MiniCardOptions options}) {
///   return Container(
///     decoration: BoxDecoration(
///       color: Colors.green,
///       shape: BoxShape.circle,
///     ),
///     child: Center(
///       child: Text(
///         options.initials,
///         style: TextStyle(
///           fontSize: options.fontSize,
///           fontWeight: FontWeight.bold,
///           color: Colors.white,
///         ),
///       ),
///     ),
///   );
/// }
///
/// MiniCard(
///   options: MiniCardOptions(
///     initials: "AB",
///     fontSize: 18,
///     customBuilder: myCustomMiniCard, // Pass the custom builder
///   ),
/// );
/// ```
class MiniCard extends StatelessWidget {
  final MiniCardOptions options;

  const MiniCard({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    // If a custom builder is provided, use it
    if (options.customBuilder != null) {
      return options.customBuilder!(
        options: options,
      );
    }

    return Container(
      decoration: options.customStyle,
      child: options.imageSource != null ? _buildImage() : _buildInitialsText(),
    );
  }

  // Builds the widget for displaying the image with optional rounded corners
  Widget _buildImage() {
    return options.roundedImage
        ? CircleAvatar(
            backgroundImage: NetworkImage(
              options.imageSource!,
            ),
            radius: 50,
          )
        : ClipRRect(
            borderRadius: options.imageStyle?.borderRadius ??
                BorderRadius.circular(0), // Default to square corners
            child: Image.network(
              options.imageSource!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) {
                return _buildInitialsText(); // Fallback for image load failure
              },
            ),
          );
  }

  // Builds the text widget for displaying initials
  Widget _buildInitialsText() {
    return Center(
      child: Text(
        options.initials,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: options.fontSize,
          color: Colors.black,
        ),
      ),
    );
  }
}
