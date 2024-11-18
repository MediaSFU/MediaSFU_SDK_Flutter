import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../types/types.dart'
    show
        ConnectIpsType,
        ConnectIpsParameters,
        AltDomains,
        ConsumeSocket,
        ConnectIpsOptions;

/// Parameters required for the getDomains function.
abstract class GetDomainsParameters implements ConnectIpsParameters {
  // Core properties as abstract getters
  List<String> get roomRecvIPs;
  dynamic get rtpCapabilities; // Placeholder for RtpCapabilities type
  List<ConsumeSocket> get consumeSockets;

  // Mediasfu function as an abstract getter
  ConnectIpsType get connectIps;

  // Method to retrieve updated parameters as an abstract getter
  GetDomainsParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

/// Options for retrieving domains and processing connections.
class GetDomainsOptions {
  final List<String> domains;
  final AltDomains altDomains;
  final String apiUserName;
  final String apiKey;
  final String apiToken;
  final GetDomainsParameters parameters;

  GetDomainsOptions({
    required this.domains,
    required this.altDomains,
    required this.apiUserName,
    required this.apiKey,
    required this.apiToken,
    required this.parameters,
  });
}

typedef GetDomainsType = Future<void> Function(GetDomainsOptions options);

/// Connects to specified domains, processes IPs, and handles domain-related connections.
///
/// The function iterates over a list of domains to verify IP connections, connects to
/// any new IPs, and uses the provided `connectIps` function to handle connection processes.
///
/// - [options] contains the configuration and parameters needed for processing connections:
///   - `domains`: List of domains to be processed for IP connections.
///   - `altDomains`: Alternative IP mappings for specific domains.
///   - `apiUserName`: Username for API authentication.
///   - `apiKey`: API key for authentication.
///   - `apiToken`: API token for secure access.
///   - `parameters`: An instance of `GetDomainsParameters` that contains IPs to be processed
///     and necessary configurations.
///
/// The function performs the following actions:
/// - Checks each domain in `options.domains` to determine if it has an alternative IP in `altDomains`.
/// - For each domain, if the IP is not already in `roomRecvIPs`, it is added to a list of IPs to connect.
/// - Uses `connectIps` to initiate the connection to each new IP address in `ipsToConnect`.
///
/// ### Example Usage:
/// ```dart
/// final options = GetDomainsOptions(
///   domains: ['domain1.com', 'domain2.com'],
///   altDomains: AltDomains(domains: {
///     'domain1.com': 'alt1.domain.com',
///     'domain2.com': 'alt2.domain.com',
///   }),
///   apiUserName: 'myUsername',
///   apiKey: 'myApiKey',
///   apiToken: 'myApiToken',
///   parameters: GetDomainsParameters(
///     roomRecvIPs: ['100.122.1.1'],
///     consumeSockets: [ConsumeSocket(id: 'socket1')],
///     rtpCapabilities: null,
///     connectIps: (connectOptions) async {
///       print('Connecting to IPs: ${connectOptions.remIP}');
///     },
///   ),
/// );
///
/// await getDomains(options);
/// ```
///
/// In this example:
/// - The function checks each domain in the `domains` list and replaces it with an alternative IP from `altDomains` if available.
/// - It verifies if each IP is already connected by checking against `roomRecvIPs`.
/// - Finally, it calls `connectIps` for each new IP not already connected.

Future<void> getDomains(GetDomainsOptions options) async {
  final updatedParams = options.parameters.getUpdatedAllParams();
  List<String> ipsToConnect = [];

  try {
    // Process each domain and check if IP is already connected
    for (String domain in options.domains) {
      String ipToCheck = options.altDomains.altDomains[domain] ?? domain;

      // Add IP if not already connected
      if (!updatedParams.roomRecvIPs.contains(ipToCheck)) {
        ipsToConnect.add(ipToCheck);
      }
    }

    // Connect to IPs
    final optionsConnect = ConnectIpsOptions(
      consumeSockets: updatedParams.consumeSockets,
      remIP: ipsToConnect,
      apiUserName: options.apiUserName,
      apiKey: options.apiKey,
      apiToken: options.apiToken,
      parameters: updatedParams,
    );
    await updatedParams.connectIps(
      optionsConnect,
    );
  } catch (error) {
    if (kDebugMode) {
      print("MediaSFU - Error in getDomains: $error");
    }
  }
}
