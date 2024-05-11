// ignore_for_file: unused_local_variable

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Retrieves domains based on the provided parameters.
///
/// This function connects to the specified domains and retrieves the IP addresses
/// associated with them. It checks if the IP addresses are already present in the
/// `roomRecvIPs` list and adds the ones that are not. Then, it calls the `connectIps`
/// function to establish connections to the new IP addresses.
///
/// The function takes the following parameters:
/// - `domains`: A list of domain names to retrieve IP addresses for.
/// - `altDomains`: A map of alternative domain names and their corresponding IP addresses.
/// - `parameters`: A map of additional parameters required for the function.
///
/// The `parameters` map should contain the following keys:
/// - `roomRecvIPs`: A list of IP addresses already present in the room.
/// - `apiUserName`: The API username for authentication.
/// - `apiKey`: (Optional) The API key for authentication.
/// - `apiToken`: The API token for authentication.
/// - `consumeSockets`: A list of consume sockets.
/// - `connectIps`: A function to connect to IP addresses.
///
/// This function does not return any value. If an error occurs during the process,
/// it will be printed to the console in debug mode.

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

/// Retrieves domains based on the provided parameters.
Future<void> getDomains({
  required List<String> domains,
  required Map<String, String> altDomains,
  required Map<String, dynamic> parameters,
}) async {
  // Function to retrieve domains

  List<dynamic> roomRecvIPs = parameters['roomRecvIPs'];
  String apiUserName = parameters['apiUserName'];
  String apiKey = parameters['apiKey'] ?? '';
  String apiToken = parameters['apiToken'];
  List<Map<String, io.Socket>> consumeSockets = parameters['consumeSockets'];

  //mediasfu functions
  ConnectIps connectIps = parameters['connectIps'];

  List<String> ipsToConnect = [];

  try {
    for (String domain in domains) {
      String ipToCheck = altDomains[domain] ?? domain;
      // Check if the IP is already in roomRecvIPs
      if (!roomRecvIPs.contains(ipToCheck)) {
        ipsToConnect.add(ipToCheck);
      }
    }
    final List<dynamic> result = await connectIps(
      consumeSockets: consumeSockets,
      remIP: ipsToConnect,
      parameters: parameters,
      apiUserName: apiUserName,
      apiKey: apiKey,
      apiToken: apiToken,
    );
  } catch (error) {
    if (kDebugMode) {
      print("MediaSFU - Error in getDomains: $error");
    }
    // throw new Error("Failed to retrieve domains.");
  }
}
