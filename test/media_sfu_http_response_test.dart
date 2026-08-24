import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mediasfu_sdk/methods/utils/media_sfu_http_response.dart';

void main() {
  test('turns an HTML 404 into a backend route error', () {
    final response = http.Response(
      '<!DOCTYPE html><html><body>app shell</body></html>',
      404,
      headers: {'content-type': 'text/html'},
    );

    final message = mediaSfuResponseError(
      response,
      action: 'join the room',
    );

    expect(message, contains('backend route was not found'));
    expect(message, isNot(contains('DOCTYPE')));
    expect(message, isNot(contains('Unexpected token')));
  });

  test('reports a successful HTML response as a wrong backend target', () {
    final response = http.Response(
      '<!DOCTYPE html><html></html>',
      200,
      headers: {'content-type': 'text/html; charset=utf-8'},
    );

    expect(
      mediaSfuResponseError(response, action: 'create the room'),
      contains('web page instead of the MediaSFU API'),
    );
  });

  test('preserves a structured backend error', () {
    final response = http.Response(
      '{"error":"Room capacity has been reached."}',
      409,
      headers: {'content-type': 'application/json'},
    );

    expect(
      mediaSfuResponseError(response, action: 'join the room'),
      'Room capacity has been reached.',
    );
  });

  test('turns browser fetch failures into connection guidance', () {
    final message = mediaSfuConnectionError(
      Exception('ClientException: XMLHttpRequest error.'),
      action: 'join the room',
    );

    expect(message, contains('Could not connect to the MediaSFU backend'));
    expect(message, isNot(contains('ClientException')));
  });
}
