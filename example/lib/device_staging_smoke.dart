import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

bool _stagingAutoCreateUsed = false;

Future<CreateJoinRoomResult> proxyRoom(
  String action,
  Map<String, dynamic> payload,
) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(
      Uri.parse('http://127.0.0.1:8765/$action'),
    );
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(payload));
    final response = await request.close();
    final data =
        jsonDecode(await utf8.decoder.bind(response).join())
            as Map<String, dynamic>;
    final success =
        response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['success'] == true;
    debugPrint(
      'STAGING_SMOKE action=$action status=${response.statusCode} success=$success',
    );
    return CreateJoinRoomResult(
      success: success,
      data: success
          ? CreateJoinRoomResponse.fromJson(data)
          : CreateJoinRoomError(
              error: 'Staging request failed (${response.statusCode})',
            ),
    );
  } finally {
    client.close(force: true);
  }
}

Future<CreateJoinRoomResult> createRoomOnMediaSFUProxy(
  CreateMediaSFUOptions options,
) => proxyRoom('create', options.payload.toMap());
Future<CreateJoinRoomResult> joinRoomOnMediaSFUProxy(
  JoinMediaSFUOptions options,
) => proxyRoom('join', options.payload.toMap());

void main() => runApp(const StagingSmokeApp());

class StagingSmokeApp extends StatelessWidget {
  const StagingSmokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const modern = bool.fromEnvironment('MODERN', defaultValue: true);
    Widget prejoin({PreJoinPageOptions? options}) {
      if (_stagingAutoCreateUsed) {
        return const Scaffold(
          body: Center(
            child: Text(
              'Staging room ended; no replacement room will be created.',
            ),
          ),
        );
      }
      _stagingAutoCreateUsed = true;
      return PreJoinPage(
        options: PreJoinPageOptions(
          parameters: options!.parameters,
          credentials: Credentials(apiUserName: '', apiKey: ''),
          returnUI: false,
          noUIPreJoinOptionsCreate: CreateMediaSFURoomOptions(
            action: 'create',
            capacity: 5,
            duration: 15,
            eventType: EventType.conference,
            userName: modern ? 'ModernTest' : 'ClassicTest',
          ),
          createMediaSFURoom: createRoomOnMediaSFUProxy,
          joinMediaSFURoom: joinRoomOnMediaSFUProxy,
        ),
      );
    }

    return MaterialApp(
      home: modern
          ? ModernMediasfuGeneric(
              options: ModernMediasfuGenericOptions(
                credentials: Credentials(
                  apiUserName: 'proxyUser',
                  apiKey: 'proxy-only',
                ),
                returnUI: true,
                connectMediaSFU: true,
                preJoinPageWidget: prejoin,
                createMediaSFURoom: createRoomOnMediaSFUProxy,
                joinMediaSFURoom: joinRoomOnMediaSFUProxy,
              ),
            )
          : MediasfuGeneric(
              options: MediasfuGenericOptions(
                credentials: Credentials(
                  apiUserName: 'proxyUser',
                  apiKey: 'proxy-only',
                ),
                returnUI: true,
                connectMediaSFU: true,
                preJoinPageWidget: prejoin,
                createMediaSFURoom: createRoomOnMediaSFUProxy,
                joinMediaSFURoom: joinRoomOnMediaSFUProxy,
              ),
            ),
    );
  }
}
