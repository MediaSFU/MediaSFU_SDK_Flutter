import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../types/types.dart'
    show PreJoinPageParameters, ConnectSocketOptions;

/// **CheckLimitsAndMakeRequestOptions**
///
/// Encapsulates the parameters required for rate limiting and request handling.
class CheckLimitsAndMakeRequestOptions {
  final String apiUserName;
  final String apiToken;
  final String link;
  final String userName;
  final PreJoinPageParameters parameters;
  final bool validate;

  CheckLimitsAndMakeRequestOptions({
    required this.apiUserName,
    required this.apiToken,
    required this.link,
    required this.userName,
    required this.parameters,
    this.validate = true,
  });
}

/// **CheckLimitsAndMakeRequestType**
///
/// Function type for checking rate limits and making socket connections.
typedef CheckLimitsAndMakeRequestType = Future<void> Function({
  required String apiUserName,
  required String apiToken,
  required String link,
  required String userName,
  required PreJoinPageParameters parameters,
  bool validate,
});

/// **checkLimitsAndMakeRequest**
///
/// Checks for rate limits and establishes a socket connection if permissible.
///
/// ### Parameters:
/// - `apiUserName` (`String`): The API username.
/// - `apiToken` (`String`): The API token.
/// - `link` (`String`): The link to connect.
/// - `userName` (`String`): The user's display name.
/// - `parameters` (`PreJoinPageParameters`): The parameters for callbacks and socket handling.
/// - `validate` (`bool`): Whether to validate the primary socket connection.
///
/// ### Returns:
/// - `Future<void>`: Completes when the request and connection are handled.
Future<void> checkLimitsAndMakeRequest({
  required String apiUserName,
  required String apiToken,
  required String link,
  required String userName,
  required PreJoinPageParameters parameters,
  bool validate = true,
}) async {
  const int maxAttempts = 10;
  const int rateLimitDuration = 3 * 60 * 60 * 1000; // 3 hours in milliseconds
  const int timeoutDuration = 10000; // 10 seconds

  final prefs = await SharedPreferences.getInstance();
  int unsuccessfulAttempts = prefs.getInt('unsuccessfulAttempts') ?? 0;
  int lastRequestTimestamp = prefs.getInt('lastRequestTimestamp') ?? 0;

  if (unsuccessfulAttempts >= maxAttempts &&
      DateTime.now().millisecondsSinceEpoch - lastRequestTimestamp <
          rateLimitDuration) {
    parameters.showAlert!(
      message: "Too many unsuccessful attempts. Please try again later.",
      type: "danger",
      duration: 3000,
    );
    return;
  }

  try {
    parameters.updateIsLoadingModalVisible(true);

    // Attempt to connect the socket with a timeout
    final socketFuture = parameters.connectSocket(
      ConnectSocketOptions(
        apiUserName: apiUserName,
        apiKey: "", // Assuming API Key is not required if API Token is provided
        apiToken: apiToken,
        link: link,
      ),
    );

    final socket = await socketFuture.timeout(
      const Duration(milliseconds: timeoutDuration),
      onTimeout: () {
        throw TimeoutException("Socket connection timed out");
      },
    );

    if (socket.id!.isNotEmpty) {
      // Reset unsuccessful attempts on success
      prefs.setInt('unsuccessfulAttempts', 0);
      prefs.setInt(
          'lastRequestTimestamp', DateTime.now().millisecondsSinceEpoch);

      if (validate) {
        parameters.updateSocket(socket);
      } else {
        parameters.updateLocalSocket!(socket);
      }

      // Update other parameters
      parameters.updateApiUserName(apiUserName);
      parameters.updateApiToken(apiToken);
      parameters.updateLink(link);
      parameters.updateRoomName(apiUserName);
      parameters.updateMember(userName);

      if (validate) {
        parameters.updateValidated(true);
      }
    } else {
      // Increment unsuccessful attempts
      unsuccessfulAttempts += 1;
      prefs.setInt('unsuccessfulAttempts', unsuccessfulAttempts);
      parameters.updateIsLoadingModalVisible(false);
      parameters.showAlert!(
        message: "Invalid credentials.",
        type: "danger",
        duration: 3000,
      );
    }
  } on TimeoutException catch (_) {
    // Handle timeout
    unsuccessfulAttempts += 1;
    prefs.setInt('unsuccessfulAttempts', unsuccessfulAttempts);
    parameters.updateIsLoadingModalVisible(false);
    parameters.showAlert!(
      message: "Socket connection timed out. Please try again.",
      type: "danger",
      duration: 3000,
    );
  } catch (error) {
    // Handle other errors
    unsuccessfulAttempts += 1;
    prefs.setInt('unsuccessfulAttempts', unsuccessfulAttempts);
    parameters.updateIsLoadingModalVisible(false);
    parameters.showAlert!(
      message:
          "Unable to connect. Please check your credentials and try again.",
      type: "danger",
      duration: 3000,
    );
  } finally {
    parameters.updateIsLoadingModalVisible(false);
    prefs.setInt('lastRequestTimestamp', DateTime.now().millisecondsSinceEpoch);
  }
}
