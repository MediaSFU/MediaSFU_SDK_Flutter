import 'package:flutter/widgets.dart';

/// Default MediaSFU logo — network URL.
const String kDefaultMediaSFULogo = 'https://mediasfu.com/images/logo192.png';

/// Fallback local asset path for the MediaSFU logo (works offline / release builds).
const String kDefaultMediaSFULogoAsset =
    'packages/mediasfu_sdk/assets/logo192.png';

/// Returns an [ImageProvider] that handles both network URLs and local assets.
///
/// If [source] starts with `http`, returns a [NetworkImage].
/// Otherwise, treats it as a local asset path.
ImageProvider resolveImageSource(String source) {
  if (source.startsWith('http')) {
    return NetworkImage(source);
  }
  return AssetImage(source);
}

/// Builds a circular logo widget that tries the network image first,
/// then falls back to the bundled asset if it fails.
Widget buildLogoCircle(String source, {double radius = 50}) {
  return ClipOval(
    child: SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: source.startsWith('http')
          ? Image.network(
              source,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  kDefaultMediaSFULogoAsset,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                );
              },
            )
          : Image.asset(
              source,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  kDefaultMediaSFULogo,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                );
              },
            ),
    ),
  );
}

/// Returns an [Image] widget that handles both network URLs and local assets.
/// Falls back to the bundled asset if the network image fails.
Widget buildMediasfuImage(
  String source, {
  double? width,
  double? height,
  BoxFit? fit,
}) {
  if (source.startsWith('http')) {
    return Image.network(
      source,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          kDefaultMediaSFULogoAsset,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }
  return Image.asset(
    source,
    width: width,
    height: height,
    fit: fit,
  );
}
