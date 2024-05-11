// ignore_for_file: unused_local_variable

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Updates consuming domains based on the provided parameters.
///
/// This function is responsible for updating the consuming domains based on the provided parameters.
/// It takes in a list of domains, a map of alternative domains, and a map of parameters.
/// The parameters should include a list of participants, an API username, an API key (optional),
/// an API token, and a list of consume sockets.
///
/// The function first checks if the participants array is not empty.
/// If it is not empty, it checks if the altDomains map has keys and removes any duplicates.
/// If altDomains is not empty, it calls the `getDomains` function with the provided domains, altDomains, and parameters.
/// If altDomains is empty, it calls the `connectIps` function with the provided consumeSockets, domains, apiUserName,
/// apiKey, apiToken, and parameters.
///
/// If an error occurs during the execution of this function, it will be caught and handled accordingly.

typedef NewProducerMethod = Future<void> Function({
  required String producerId,
  required String islevel,
  required dynamic nsock,
  required Map<String, dynamic> parameters,
});

typedef ClosedProducerMethod = Future<void> Function({
  required String remoteProducerId,
  required Map<String, dynamic> parameters,
});

typedef JoinConsumeRoomMethod = Future<Map<String, dynamic>> Function({
  required io.Socket remoteSock,
  required String apiToken,
  required String apiUserName,
  required Map<String, dynamic> parameters,
});

typedef ConnectIps = Future<List<dynamic>> Function({
  required List<Map<String, io.Socket>> consumeSockets,
  required List<dynamic> remIP,
  required String apiUserName,
  String? apiKey,
  String? apiToken,
  NewProducerMethod? newProducerMethod,
  ClosedProducerMethod? closedProducerMethod,
  JoinConsumeRoomMethod? joinConsumeRoomMethod,
  required Map<String, dynamic> parameters,
});

typedef GetDomains = Future<void> Function({
  required List<String> domains,
  required Map<String, String> altDomains,
  required Map<String, dynamic> parameters,
});

/// Updates consuming domains based on the provided parameters.
void updateConsumingDomains({
  required List<String> domains,
  required Map<String, String> altDomains,
  required Map<String, dynamic> parameters,
}) async {
  try {
    List<dynamic> participants = parameters['participants'];
    String apiUserName = parameters['apiUserName'];
    String apiKey = parameters['apiKey'] ?? '';
    String apiToken = parameters['apiToken'];
    List<Map<String, io.Socket>> consumeSockets = parameters['consumeSockets'];

    // mediasfu functions
    ConnectIps connectIps = parameters['connectIps'];
    GetDomains getDomains = parameters['getDomains'];

    // Check if participants array is not empty
    if (participants.isNotEmpty) {
      // Check if altDomains has keys and remove duplicates
      if (altDomains.isNotEmpty) {
        await getDomains(
            domains: domains, altDomains: altDomains, parameters: parameters);
      } else {
        final response = await connectIps(
          consumeSockets: consumeSockets,
          remIP: domains,
          apiUserName: apiUserName,
          apiKey: apiKey,
          apiToken: apiToken,
          parameters: parameters,
        );
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print("MediaSFU - Error in updateConsumingDomains: $error");
    }
    // Handle error accordingly
  }
}
