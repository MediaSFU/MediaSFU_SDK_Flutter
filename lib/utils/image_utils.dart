import 'package:flutter/widgets.dart';

/// Default MediaSFU logo — uses a local bundled asset instead of a network URL
/// so the logo loads instantly and works offline / on Windows desktop.
const String kDefaultMediaSFULogo = 'packages/mediasfu_sdk/assets/logo192.png';
const String _kMediaSFUPackageName = 'mediasfu_sdk';
const String _kMediaSFUPackagePrefix = 'packages/$_kMediaSFUPackageName/';

bool _isNetworkImageSource(String source) =>
    source.startsWith('http://') || source.startsWith('https://');

bool _isMediaSFUPackageAsset(String source) =>
    source.startsWith(_kMediaSFUPackagePrefix);

String _normalizeMediaSFUPackageAsset(String source) {
  if (_isMediaSFUPackageAsset(source)) {
    return source.substring(_kMediaSFUPackagePrefix.length);
  }
  return source;
}

/// Returns an [ImageProvider] that handles both network URLs and local assets.
///
/// If [source] starts with `http`, returns a [NetworkImage].
/// Otherwise, treats it as a local asset path.
ImageProvider resolveImageSource(String source) {
  if (_isNetworkImageSource(source)) {
    return NetworkImage(source);
  }

  if (_isMediaSFUPackageAsset(source)) {
    return AssetImage(
      _normalizeMediaSFUPackageAsset(source),
      package: _kMediaSFUPackageName,
    );
  }

  return AssetImage(source);
}

/// Returns an [Image] widget that handles both network URLs and local assets.
Widget buildMediasfuImage(
  String source, {
  double? width,
  double? height,
  BoxFit? fit,
}) {
  if (_isNetworkImageSource(source)) {
    return Image.network(source, width: width, height: height, fit: fit);
  }

  if (_isMediaSFUPackageAsset(source)) {
    return Image.asset(
      _normalizeMediaSFUPackageAsset(source),
      package: _kMediaSFUPackageName,
      width: width,
      height: height,
      fit: fit,
    );
  }

  return Image.asset(
    source,
    width: width,
    height: height,
    fit: fit,
  );
}
