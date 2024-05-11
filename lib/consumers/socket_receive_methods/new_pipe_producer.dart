import 'dart:async';
import '../../consumers/signal_new_consumer_transport.dart'
    show signalNewConsumerTransport;
import 'package:socket_io_client/socket_io_client.dart' as io;

/// This function is responsible for handling the new pipe producer.
/// It takes in the following parameters:
/// - [producerId]: The ID of the producer.
/// - [islevel]: The level of the producer.
/// - [nsock]: The socket for communication.
/// - [parameters]: Additional parameters for the function.
///
/// It returns a [Future] that completes when the function finishes its execution.
///
/// The function performs the following steps:
/// 1. Extracts the values of various parameters from the [parameters] map.
/// 2. Calls the [signalNewConsumerTransport] function with the extracted parameters.
/// 3. Updates the values of [firstRound], [landScaped], and [isWideScreen] based on the extracted parameters.
/// 4. Shows an alert message if necessary.
/// 5. Updates the values of [firstRound] and [landScaped] based on the extracted parameters.
///
typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

Future<void> newPipeProducer({
  required String producerId,
  required String islevel,
  required io.Socket nsock,
  required Map<String, dynamic> parameters,
}) async {
  bool firstRound = parameters['first_round'] ?? false;
  bool shareScreenStarted = parameters['shareScreenStarted'] ?? false;
  bool shared = parameters['shared'] ?? false;
  bool landScaped = parameters['landScaped'] ?? false;
  bool isWideScreen = parameters['isWideScreen'] ?? false;
  ShowAlert? showAlert = parameters['showAlert'];
  Function updateFirstRound = parameters['updateFirstRound'];
  Function updateLandScaped = parameters['updateLandScaped'];

  // Call the signalNewConsumerTransport function
  await signalNewConsumerTransport(
    remoteProducerId: producerId,
    islevel: islevel,
    nsock: nsock,
    parameters: parameters,
  );

  firstRound = false;
  if (shareScreenStarted || shared) {
    if (!isWideScreen) {
      if (!landScaped) {
        if (showAlert != null) {
          showAlert(
            message: 'Please rotate your device to landscape mode.',
            duration: 3000,
            type: 'success',
          );
        }
        landScaped = true;
        updateLandScaped(landScaped);
      }
    }
    firstRound = true;
    updateFirstRound(firstRound);
  }
}
