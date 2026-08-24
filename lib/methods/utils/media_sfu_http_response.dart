import 'dart:convert';

import 'package:http/http.dart' as http;

Map<String, dynamic>? decodeMediaSfuJsonObject(String body) {
  try {
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

String mediaSfuResponseError(
  http.Response response, {
  required String action,
}) {
  final decoded = decodeMediaSfuJsonObject(response.body);
  final serverMessage = decoded == null
      ? ''
      : [decoded['error'], decoded['reason'], decoded['message']]
            .whereType<String>()
            .map((value) => value.trim())
            .firstWhere((value) => value.isNotEmpty, orElse: () => '');
  if (serverMessage.isNotEmpty) return serverMessage;

  final status = response.statusCode;
  if (status == 401 || status == 403) {
    return 'The MediaSFU backend rejected the credentials (HTTP $status).';
  }
  if (status == 404) {
    return 'The MediaSFU backend route was not found (HTTP 404). Check the configured backend URL.';
  }
  if (status == 408 || status == 504) {
    return 'The MediaSFU backend timed out while trying to $action (HTTP $status). Please try again.';
  }
  if (status >= 500) {
    return 'The MediaSFU backend is unavailable (HTTP $status). Please try again shortly.';
  }

  final contentType = response.headers['content-type']?.toLowerCase() ?? '';
  final looksLikeHtml =
      contentType.contains('text/html') ||
      response.body.trimLeft().toLowerCase().startsWith('<!doctype') ||
      response.body.trimLeft().toLowerCase().startsWith('<html');
  if (looksLikeHtml) {
    return 'The configured backend returned a web page instead of the MediaSFU API. Check the backend URL.';
  }
  if (status >= 200 && status < 300) {
    return 'The MediaSFU backend returned an invalid response while trying to $action.';
  }
  return 'The MediaSFU backend could not $action (HTTP $status).';
}

String mediaSfuConnectionError(Object error, {required String action}) {
  final message = error.toString().toLowerCase();
  if (message.contains('timeout')) {
    return 'The MediaSFU backend timed out while trying to $action. Please try again.';
  }
  if (message.contains('clientexception') ||
      message.contains('failed host lookup') ||
      message.contains('connection refused') ||
      message.contains('connection reset') ||
      message.contains('networkerror') ||
      message.contains('xmlhttprequest error') ||
      message.contains('failed to fetch') ||
      message.contains('socketexception')) {
    return 'Could not connect to the MediaSFU backend. Check your connection and configured backend URL.';
  }
  return 'The MediaSFU backend request failed while trying to $action. Please try again.';
}
