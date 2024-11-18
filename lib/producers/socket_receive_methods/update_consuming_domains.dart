import 'package:flutter/foundation.dart';
import '../../types/types.dart'
    show
        ConnectIpsType,
        GetDomainsType,
        ConnectIpsParameters,
        GetDomainsParameters,
        AltDomains,
        Participant,
        ConsumeSocket,
        GetDomainsOptions,
        ConnectIpsOptions;

/// Represents the parameters required for updating consuming domains.
abstract class UpdateConsumingDomainsParameters
    implements ConnectIpsParameters, GetDomainsParameters {
  List<Participant> get participants;
  List<ConsumeSocket> get consumeSockets;

  // mediasfu functions
  ConnectIpsType get connectIps;
  GetDomainsType get getDomains;

  UpdateConsumingDomainsParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Represents the options for updating consuming domains.
class UpdateConsumingDomainsOptions {
  final List<String> domains;
  final AltDomains altDomains;
  final String apiUserName;
  final String apiKey;
  final String apiToken;
  final UpdateConsumingDomainsParameters parameters;

  UpdateConsumingDomainsOptions({
    required this.domains,
    required this.altDomains,
    required this.apiUserName,
    required this.apiKey,
    required this.apiToken,
    required this.parameters,
  });
}

typedef UpdateConsumingDomainsType = Future<void> Function(
    UpdateConsumingDomainsOptions options);

/// Updates consuming domains based on the provided options.
///
/// This function updates consuming domains by invoking `getDomains` and `connectIps`
/// functions based on the provided parameters.
///
/// @param [UpdateConsumingDomainsOptions] options - The options for updating consuming domains.
/// - `domains`: List of primary domains.
/// - `altDomains`: Alternative domains map.
/// - `apiUserName`: API username for authorization.
/// - `apiKey`: API key for secure access.
/// - `apiToken`: API token for secure access.
/// - `parameters`: UpdateConsumingDomainsParameters instance with required parameters and functions.
///
/// Example usage:
/// ```dart
/// final options = UpdateConsumingDomainsOptions(
///   domains: ["domain1.com", "domain2.com"],
///   altDomains: AltDomains(altDomains: {"domain1.com": ["alt1.com"]}),
///   apiUserName: "myApiUser",
///   apiKey: "myApiKey",
///   apiToken: "myApiToken",
///   parameters: UpdateConsumingDomainsParameters(
///     participants: [Participant(id: "user1", name: "User 1")],
///     consumeSockets: [ConsumeSocket(id: "socket1", isConnected: true)],
///     connectIps: (options) async => print("Connecting IPs"),
///     getDomains: (options) async => print("Getting Domains"),
///   ),
/// );
/// await updateConsumingDomains(options);
/// ```
void updateConsumingDomains(UpdateConsumingDomainsOptions options) async {
  try {
    // Access latest parameters
    final updatedParams = options.parameters.getUpdatedAllParams();

    // Check if participants list is non-empty
    if (updatedParams.participants.isNotEmpty) {
      // Check if altDomains has entries
      if (options.altDomains.altDomains.isNotEmpty) {
        final optionsGet = GetDomainsOptions(
          domains: options.domains,
          altDomains: options.altDomains,
          apiUserName: options.apiUserName,
          apiKey: options.apiKey,
          apiToken: options.apiToken,
          parameters: updatedParams,
        );
        await updatedParams.getDomains(
          optionsGet,
        );
      } else {
        final optionsConnect = ConnectIpsOptions(
          consumeSockets: updatedParams.consumeSockets,
          remIP: options.domains,
          apiUserName: options.apiUserName,
          apiKey: options.apiKey,
          apiToken: options.apiToken,
          parameters: updatedParams,
        );
        await updatedParams.connectIps(
          optionsConnect,
        );
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print("Error in updateConsumingDomains: $error");
    }
  }
}
