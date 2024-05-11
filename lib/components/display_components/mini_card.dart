import 'package:flutter/material.dart';

/// MiniCard - A Flutter widget for displaying a mini card with initials or an image.

/// The initials to display on the mini card.
///final String initials;

/// The font size of the initials text.
///final double? fontSize;

/// Custom decoration styles to apply to the mini card.
///final BoxDecoration? customStyle;

/// The source of the image to display on the mini card.
/// final String? imageSource;

/// A flag indicating whether to display the image with rounded corners.
///final bool roundedImage;

/// Custom decoration styles to apply to the image displayed on the mini card.
///final BoxDecoration? imageStyle;

/// MiniCard - A Flutter widget for displaying a mini card with initials or an image.
class MiniCard extends StatelessWidget {
  final String initials;
  final double? fontSize;
  final BoxDecoration? customStyle;
  final String? imageSource;
  final bool roundedImage;
  final BoxDecoration? imageStyle;

  /// Constructs a MiniCard widget.
  const MiniCard({
    super.key,
    required this.initials,
    this.fontSize,
    this.customStyle,
    this.imageSource,
    this.roundedImage = false,
    this.imageStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Define the style for the MiniCard
    final List<BoxDecoration> decorations = [
      BoxDecoration(
        borderRadius:
            BorderRadius.circular(4), // Adjust the border radius as needed
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
    ];

    // Add customStyle if not null
    if (customStyle != null) {
      decorations.add(customStyle!);
    }

    // Render the MiniCard with either an image or initials
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(4), // Adjust the border radius as needed
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: imageSource != null
          ? ClipRRect(
              borderRadius:
                  roundedImage ? BorderRadius.circular(20) : BorderRadius.zero,
              child: Image(
                image: NetworkImage(imageSource!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, exception, stackTrace) {
                  return _buildInitialsText(); // Display alternative content
                },
              ),
            )
          : _buildInitialsText(),
    );
  }

  // Builds the text widget for displaying initials
  Widget _buildInitialsText() {
    return Center(
      child: Text(
        initials,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: fontSize ?? 14), // Default font size is 14
      ),
    );
  }
}
