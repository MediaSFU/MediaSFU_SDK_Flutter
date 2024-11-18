import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../../consumers/signal_new_consumer_transport.dart'
    show signalNewConsumerTransport;
import '../../types/types.dart'
    show
        ShowAlert,
        SignalNewConsumerTransportOptions,
        ReorderStreamsParameters,
        SignalNewConsumerTransportParameters,
        ConnectRecvTransportParameters,
        ConnectRecvTransportType,
        ReorderStreamsType;

/// Interface for [NewPipeProducerParameters], extending other parameters.
abstract class NewPipeProducerParameters
    implements
        ReorderStreamsParameters,
        SignalNewConsumerTransportParameters,
        ConnectRecvTransportParameters {
  bool get firstRound;
  bool get shareScreenStarted;
  bool get shared;
  bool get landScaped;
  bool get isWideScreen;
  Device? get device;
  List<String> get consumingTransports;
  bool get lockScreen;

  ShowAlert? get showAlert;

  void Function(bool) get updateFirstRound;
  void Function(bool) get updateLandScaped;
  void Function(List<String>) get updateConsumingTransports;

  // Properties as getters
  ConnectRecvTransportType get connectRecvTransport;
  ReorderStreamsType get reorderStreams;

  NewPipeProducerParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Options for the [newPipeProducer] function.
class NewPipeProducerOptions {
  final String producerId;
  final String islevel;
  final io.Socket nsock;
  final NewPipeProducerParameters parameters;

  NewPipeProducerOptions({
    required this.producerId,
    required this.islevel,
    required this.nsock,
    required this.parameters,
  });
}

typedef NewPipeProducerType = Future<void> Function(
    NewPipeProducerOptions options);

/// Initiates a new pipe producer by signaling a new consumer transport and updating display settings as needed.
///
/// This function performs the following steps:
/// 1. Signals the creation of a new consumer transport for the specified `producerId`.
/// 2. Updates the `firstRound` and `landScaped` display parameters based on sharing mode and device orientation.
/// 3. Optionally, triggers an alert to prompt the user to rotate their device for optimal viewing if screen sharing is active and the device is not in landscape mode.
///
/// ### Parameters:
///
/// - `options` (`NewPipeProducerOptions`): Contains the required data for handling the new pipe producer:
///   - `producerId` (`String`): The ID of the producer to be consumed.
///   - `islevel` (`String`): The level status of the participant.
///   - `nsock` (`io.Socket`): The socket instance for managing real-time communication.
///   - `parameters` (`NewPipeProducerParameters`): Additional parameters to set up the producer:
///       - `firstRound` (`bool`): Flag indicating if this is the first operation round.
///       - `shareScreenStarted` (`bool`): Whether screen sharing has started.
///       - `shared` (`bool`): Whether sharing is currently active.
///       - `landScaped` (`bool`): Indicates if the device is in landscape orientation.
///       - `isWideScreen` (`bool`): Indicates if the device has a widescreen layout.
///       - `showAlert` (`ShowAlert?`): An optional callback to display alerts to the user.
///       - `updateFirstRound` (`Function`): Callback to update `firstRound` status.
///       - `updateLandScaped` (`Function`): Callback to update landscape orientation status.
///
/// ### Returns:
///
/// A `Future<void>` that completes once the consumer transport setup and parameter updates are finished.
///
/// ### Throws:
///
/// Throws an error if signaling the new consumer transport fails.
///
/// ### Example:
///
/// ```dart
/// import 'package:socket_io_client/socket_io_client.dart' as io;
/// import 'new_pipe_producer.dart';
/// import 'new_pipe_producer.options.dart';
///
/// final socket = io.io("http://localhost:3000", <String, dynamic>{
///   "transports": ["websocket"],
/// });
///
/// final parameters = NewPipeProducerParametersMock(
///   firstRound: true,
///   shareScreenStarted: true,
///   shared: false,
///   landScaped: false,
///   isWideScreen: false,
///   showAlert: (alert) => print(alert['message']),
///   updateFirstRound: (firstRound) => print("First Round Updated: $firstRound"),
///   updateLandScaped: (landScaped) => print("Landscape Updated: $landScaped"),
/// );
///
/// final options = NewPipeProducerOptions(
///   producerId: 'producer-123',
///   islevel: '2',
///   nsock: socket,
///   parameters: parameters,
/// );
///
/// try {
///   await newPipeProducer(options);
///   print("New pipe producer created successfully");
/// } catch (error) {
///   print("Error creating new pipe producer: $error");
/// }
/// ```

Future<void> newPipeProducer(NewPipeProducerOptions options) async {
  final producerId = options.producerId;
  final islevel = options.islevel;
  final nsock = options.nsock;
  final parameters = options.parameters;

  bool firstRound = parameters.firstRound;
  final bool shareScreenStarted = parameters.shareScreenStarted;
  final bool shared = parameters.shared;
  bool landScaped = parameters.landScaped;
  final bool isWideScreen = parameters.isWideScreen;
  final ShowAlert? showAlert = parameters.showAlert;

  // Call the signalNewConsumerTransport function
  final optionsSignal = SignalNewConsumerTransportOptions(
    remoteProducerId: producerId,
    islevel: islevel,
    nsock: nsock,
    parameters: parameters,
  );
  await signalNewConsumerTransport(
    optionsSignal,
  );

  // Modify firstRound and landscape status
  firstRound = false;
  if (shareScreenStarted || shared) {
    if (!isWideScreen && !landScaped) {
      showAlert!(
        message:
            'Please rotate your device to landscape mode for better experience',
        type: 'success',
        duration: 3000,
      );
      landScaped = true;
      parameters.updateLandScaped(landScaped);
    }
    firstRound = true;
    parameters.updateFirstRound(firstRound);
  }
}
