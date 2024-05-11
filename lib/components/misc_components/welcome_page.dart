// import 'dart:io'; // use the welcome_page.qrcode.dart file
import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart'; // handle permissions manually
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/foundation.dart' show kIsWeb; // use the welcome_page.qrcode.dart file
import 'dart:async';

/// This file contains the implementation of the WelcomePage widget.
/// Implement the qr_code_scanner package to scan QR codes using the 'welcome_page.qrcode.dart' file.
///
/// The WelcomePage widget is responsible for displaying a welcome screen
/// with input fields for event details, a QR code scanner, and additional options.
/// It also handles the logic for validating the event details and launching the event link.
/// The widget is used to gather the necessary information for joining an event.
/// It utilizes various dependencies such as permission_handler, qr_code_scanner,
/// url_launcher, shared_preferences, and flutter/foundation.
/// The widget is part of the mediasfu_flutter project.
///
/// The WelcomePage widget has the following parameters:
/// - `parameters`: A map containing various callback functions and variables
///   used for communication between the WelcomePage widget and its parent widget.
///
/// The WelcomePage widget has the following internal state:
/// - `_nameController`: A TextEditingController for the event display name input field.
/// - `_secretController`: A TextEditingController for the event token (secret) input field.
/// - `_eventIDController`: A TextEditingController for the event ID input field.
/// - `_linkController`: A TextEditingController for the event link input field.
/// - `showAlert`: A function callback for showing an alert message.
/// - `updateIsLoadingModalVisible`: A function callback for updating the visibility of a loading modal.
/// - `onWeb`: A boolean flag indicating whether the app is running on the web.
/// - `connectSocket`: A function callback for connecting to a socket.
/// - `socket`: A dynamic variable representing the socket connection.
/// - `updateSocket`: A function callback for updating the socket connection.
/// - `updateValidated`: A function callback for updating the validation status.
/// - `updateApiUserName`: A function callback for updating the API username.
/// - `updateApiToken`: A function callback for updating the API token.
/// - `updateLink`: A function callback for updating the event link.
/// - `updateRoomName`: A function callback for updating the room name.
/// - `updateMember`: A function callback for updating the member.
/// - `validated`: A boolean flag indicating whether the event details are validated.
/// - `_isScannerVisible`: A boolean flag indicating whether the QR code scanner is visible.
/// - `_scannedData`: A string representing the scanned QR code data.
/// - `_controller`: A QRViewController for controlling the QR code scanner.
/// - `hasCameraPermission`: A boolean flag indicating whether the app has camera permission.
/// - `_scanSubscription`: A StreamSubscription for handling the scanned QR code data.
///
/// The WelcomePage widget is a StatefulWidget, and its state is represented by the _WelcomePageState class.
/// The _WelcomePageState class overrides the `reassemble` and `initState` methods for handling camera reassembly
/// and initializing the state variables respectively.
/// The _WelcomePageState class also implements the build method for constructing the widget's UI.
/// The UI consists of a Scaffold with a blue background color and a Centered SingleChildScrollView.
/// The SingleChildScrollView contains a Column with various UI elements such as a brand logo, input fields,
/// a confirm button, a QR code scanner section, and additional options.
/// The widget also includes helper methods for handling camera reassembly, QR code view creation,
/// and launching URLs.
///
/// Note: This documentation comment only covers the selected code. There may be additional code
/// and functionality in the complete file.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef ConnectSocket = Future<dynamic> Function(
    String apiUserName, String apiKey, String apiToken, String link);

int maxAttempts =
    20; // Maximum number of unsuccessful attempts before rate limiting
int rateLimitDuration = 3 * 60 * 60 * 1000; // 3 hours in milliseconds

class WelcomePage extends StatefulWidget {
  final Map<String, dynamic> parameters;

  const WelcomePage({super.key, required this.parameters});

  @override
  // ignore: library_private_types_in_public_api
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();
  final TextEditingController _eventIDController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  late final ShowAlert showAlert;
  late final Function(bool) updateIsLoadingModalVisible;
  late bool onWeb;
  late final ConnectSocket connectSocket;
  late dynamic socket;
  late Function(dynamic) updateSocket;
  late Function(bool) updateValidated;
  late Function(String) updateApiUserName;
  late Function(String) updateApiToken;
  late Function(String) updateLink;
  late Function(String) updateRoomName;
  late Function(String) updateMember;
  late bool validated;

  // final bool _isScannerVisible = false;
  // final String _scannedData = '';
  // QRViewController? _controller; // use the welcome_page.qrcode.dart file
  bool hasCameraPermission = false;
  StreamSubscription? _scanSubscription;

  @override
  void reassemble() {
    super.reassemble();
    // use the welcome_page.qrcode.dart file
    // if (Platform.isAndroid) {
    //   _controller!.pauseCamera();
    // } else if (Platform.isIOS) {
    //   _controller!.resumeCamera();
    // }
  }

  @override
  void initState() {
    super.initState();
    // Extract showAlert and updateIsLoadingModalVisible from parameters

    showAlert = widget.parameters['showAlert'];
    updateIsLoadingModalVisible =
        widget.parameters['updateIsLoadingModalVisible'];
    onWeb = widget.parameters['onWeb'];
    connectSocket = widget.parameters['connectSocket'];
    socket = widget.parameters['socket'];
    updateSocket = widget.parameters['updateSocket'];
    updateValidated = widget.parameters['updateValidated'];
    updateApiUserName = widget.parameters['updateApiUserName'];
    updateApiToken = widget.parameters['updateApiToken'];
    updateLink = widget.parameters['updateLink'];
    updateRoomName = widget.parameters['updateRoomName'];
    updateMember = widget.parameters['updateMember'];
    validated = widget.parameters['validated'];
  }

  // final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF53C6E0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Brand Logo
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        NetworkImage('https://mediasfu.com/images/logo192.png'),
                  ),
                ),
                // Input Fields
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal:
                                10), // Adjust vertical padding as needed
                        hintText: 'Event Display Name',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(
                        height: 10), // Adjust vertical spacing as needed
                    TextFormField(
                      controller: _secretController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal:
                                10), // Adjust vertical padding as needed
                        hintText: 'Event Token (Secret)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(
                        height: 10), // Adjust vertical spacing as needed
                    TextFormField(
                      controller: _eventIDController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal:
                                10), // Adjust vertical padding as needed
                        hintText: 'Event ID',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(
                        height: 10), // Adjust vertical spacing as needed
                    TextFormField(
                      controller: _linkController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal:
                                10), // Adjust vertical padding as needed
                        hintText: 'Event Link',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                // Confirm Button
                ElevatedButton(
                  onPressed: () {
                    // Implement logic to check if the details are valid
                    _handleConfirm();
                  },
                  child: const Text('Confirm'),
                ),
                const SizedBox(height: 10),
                // use the welcome_page.qrcode.dart file
                // Horizontal Line with "OR"
                // const Row(
                //   children: [
                //     Expanded(child: Divider(color: Colors.black)),
                //     Padding(
                //       padding: EdgeInsets.symmetric(horizontal: 10),
                //       child: Text('OR', style: TextStyle(color: Colors.black)),
                //     ),
                //     Expanded(child: Divider(color: Colors.black)),
                //   ],
                // ),
                // const SizedBox(height: 10),
                // // QR Code Scanner Section
                // (_isScannerVisible && hasCameraPermission && !kIsWeb)
                //     ? Center(
                //         child: SizedBox(
                //         width: 300,
                //         height: 300,
                //         child: _buildQrView(),
                //       ))
                //     : ElevatedButton(
                //         onPressed: _handleScannerToggle,
                //         child: const Text('Scan QR Code'),
                //       ),
                // const SizedBox(height: 10),
                // Additional Options
                Column(
                  children: [
                    const Text(
                      'Provide the event details either by typing manually or scanning the QR-code to autofill.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    const Text('Don\'t have a secret?',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () {
                        // Implement logic to open the link
                        _launchURL(
                            'https://meeting.mediasfu.com/meeting/start/');
                      },
                      child: const Text('Get one from mediasfu.com'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // use the welcome_page.qrcode.dart file
  // Widget _buildQrView() {
  //   return QRView(
  //     key: _qrKey,
  //     onQRViewCreated: _onQRViewCreated,
  //   );
  // }

  // void _onQRViewCreated(QRViewController controller) {
  //   _controller = controller;

  //   // setState(() {
  //   //   _isScannerVisible = true;
  //   // });
  //   // Set up the stream subscription only once
  //   _scanSubscription ??= _controller!.scannedDataStream.listen((scanData) {
  //     setState(() {
  //       _scannedData = scanData.code ?? '';
  //     });
  //     // Handle the scanned QR code
  //     _handleBarCodeScanned();
  //   });
  // }

  // void _handleScannerToggle() {
  //   if (!_isScannerVisible) {
  //     if (!kIsWeb && !hasCameraPermission) {
  //       requestPermissionCamera().then((value) {
  //         if (value) {
  //           _controller?.resumeCamera();
  //           setState(() {
  //             hasCameraPermission = true;
  //             _isScannerVisible = true;
  //           });
  //         } else {
  //           showAlert(
  //             message: 'Camera permission denied.',
  //             type: 'danger',
  //             duration: 3000,
  //           );
  //         }
  //       });
  //     } else {
  //       _controller?.resumeCamera();
  //       setState(() {
  //         _isScannerVisible = true;
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       _controller?.pauseCamera();
  //       _isScannerVisible = false;
  //     });
  //   }
  // }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url); // Convert String to Uri
    if (await canLaunchUrl(uri)) {
      // Use the Uri
      await launchUrl(uri); // Use the Uri
    } else {
      throw 'Could not launch $url';
    }
  }

  void _handleConfirm() async {
    updateIsLoadingModalVisible(true);

    // Get input values from text controllers
    final String name = _nameController.text;
    final String secret = _secretController.text;
    final String eventID = _eventIDController.text;
    final String link = _linkController.text;

    // Validate input values
    if (name.isEmpty || secret.isEmpty || eventID.isEmpty || link.isEmpty) {
      showAlert(
        message: 'Please fill all the fields.',
        type: 'danger',
        duration: 3000,
      );
      updateIsLoadingModalVisible(false);
      return;
    }

    if (!_validateAlphanumeric(name) ||
        !_validateAlphanumeric(secret) ||
        !_validateAlphanumeric(eventID) ||
        !link.contains('mediasfu.com') ||
        eventID.toLowerCase().startsWith('d')) {
      showAlert(
        message: 'Please enter valid details.',
        type: 'danger',
        duration: 3000,
      );
      updateIsLoadingModalVisible(false);
      return;
    }

    if (secret.length != 64 ||
        name.length > 12 ||
        name.length < 2 ||
        eventID.length > 32 ||
        eventID.length < 8 ||
        link.length < 12) {
      showAlert(
        message: 'Please enter valid details.',
        type: 'danger',
        duration: 3000,
      );
      updateIsLoadingModalVisible(false);
      return;
    }

    // Make the request
    await _checkLimitsAndMakeRequest(
      apiUserName: eventID,
      apiToken: secret,
      link: link,
      userName: name,
    );
    updateIsLoadingModalVisible(false);
  }

  // use the welcome_page.qrcode.dart file
  // void _handleBarCodeScanned() {
  //   final String data = _scannedData.trim();
  //   final List<String> parts = data.split(';');

  //   if (parts.length == 5) {
  //     final String userName = parts[0];
  //     final String link = parts[1];
  //     final String userSecret = parts[2];
  //     final String passWord = parts[3];
  //     final String meetingID = parts[4];

  //     // Validate scanned data
  //     if (userName.isEmpty ||
  //         link.isEmpty ||
  //         userSecret.isEmpty ||
  //         passWord.isEmpty ||
  //         meetingID.isEmpty) {
  //       showAlert(
  //         message: 'Invalid scanned data.',
  //         type: 'danger',
  //         duration: 3000,
  //       );
  //       return;
  //     }

  //     if (!_validateAlphanumeric(userName) ||
  //         !_validateAlphanumeric(userSecret) ||
  //         !_validateAlphanumeric(passWord) ||
  //         !_validateAlphanumeric(meetingID)) {
  //       showAlert(
  //         message: 'Invalid scanned data.',
  //         type: 'danger',
  //         duration: 3000,
  //       );
  //       return;
  //     }

  //     if (userSecret.length != 64 ||
  //         userName.length > 12 ||
  //         userName.length < 2 ||
  //         meetingID.length > 32 ||
  //         meetingID.length < 8 ||
  //         !link.contains('mediasfu.com') ||
  //         meetingID.toLowerCase().startsWith('d')) {
  //       showAlert(
  //         message: 'Invalid scanned data.',
  //         type: 'danger',
  //         duration: 3000,
  //       );
  //       return;
  //     }

  //     // Further processing logic if needed

  //     // Set the scanned data to state
  //     setState(() {
  //       _scannedData = data;
  //     });

  //     // Update the text controllers
  //     _nameController.text = userName;
  //     _secretController.text = userSecret;
  //     _eventIDController.text = meetingID;
  //     _linkController.text = link;

  //     // Close the scanner
  //     _handleScannerToggle();

  //     // Make the request
  //     _handleConfirm();
  //   } else {
  //     // Handle the case where the scanned data doesn't have the expected format
  //     showAlert(
  //       message: 'Invalid scanned data.',
  //       type: 'danger',
  //       duration: 3000,
  //     );
  //     setState(() {});
  //   }
  // }

  bool _validateAlphanumeric(String value) {
    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumericRegex.hasMatch(value);
  }

  Future<bool> requestPermissionCamera() async {
    return true;
    // final status = await Permission.camera.request();
    // if (status == PermissionStatus.granted) {
    //   hasCameraPermission = true;
    //   return true;
    // } else {
    //   return false;
    // }
  }

  Future<void> _checkLimitsAndMakeRequest({
    required String apiUserName,
    String apiToken = "",
    String apiKey = "",
    required String link,
    required String userName,
  }) async {
    const int duration = 20000;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int unsuccessfulAttempts = prefs.getInt('unsuccessfulAttempts') ?? 0;
    int lastRequestTimestamp = prefs.getInt('lastRequestTimestamp') ?? 0;

    if (unsuccessfulAttempts >= maxAttempts) {
      if (DateTime.now().millisecondsSinceEpoch - lastRequestTimestamp <
          rateLimitDuration) {
        showAlert(
          message: 'Too many unsuccessful attempts. Please try again later.',
          type: 'danger',
          duration: 3000,
        );
        await prefs.setInt(
          'lastRequestTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
        return;
      } else {
        unsuccessfulAttempts = 0;
        await prefs.setInt('unsuccessfulAttempts', unsuccessfulAttempts);
        await prefs.setInt(
          'lastRequestTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    }

    try {
      updateIsLoadingModalVisible(true);

      final socketPromise = connectSocket(apiUserName, apiKey, apiToken, link);
      const timeoutDuration = Duration(milliseconds: duration);

      final socketWithTimeout = await socketPromise.timeout(
        timeoutDuration,
        onTimeout: () {
          throw TimeoutException('Socket connection timed out');
        },
      );

      if (socketWithTimeout != null && socketWithTimeout.id != null) {
        unsuccessfulAttempts = 0;
        await prefs.setInt('unsuccessfulAttempts', unsuccessfulAttempts);
        await prefs.setInt(
          'lastRequestTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
        // Update state or perform other actions on successful request
        await updateSocket(socketWithTimeout);
        await updateApiUserName(apiUserName);
        await updateApiToken(apiToken);
        await updateLink(link);
        await updateRoomName(apiUserName);
        await updateMember(userName);
        updateIsLoadingModalVisible(false);
        await updateValidated(true);
      } else {
        updateIsLoadingModalVisible(false);
        unsuccessfulAttempts++;
        await prefs.setInt('unsuccessfulAttempts', unsuccessfulAttempts);
        await prefs.setInt(
          'lastRequestTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
        if (unsuccessfulAttempts >= maxAttempts) {
          showAlert(
            message: 'Too many unsuccessful attempts. Please try again later.',
            type: 'danger',
            duration: 3000,
          );
        } else {
          showAlert(
            message: 'Invalid credentials. Please try again later.',
            type: 'danger',
            duration: 3000,
          );
        }
      }
    } catch (error) {
      updateIsLoadingModalVisible(false);

      await prefs.setInt('unsuccessfulAttempts', unsuccessfulAttempts);
      await prefs.setInt(
        'lastRequestTimestamp',
        DateTime.now().millisecondsSinceEpoch,
      );

      if (unsuccessfulAttempts >= maxAttempts) {
        showAlert(
          message: 'Too many unsuccessful attempts. Please try again later.',
          type: 'danger',
          duration: 3000,
        );
      } else {
        showAlert(
          message: 'Unable to connect. ${error.toString()}',
          type: 'danger',
          duration: 3000,
        );
      }
    }
  }

  @override
  void dispose() {
    // _controller?.dispose(); // use the welcome_page.qrcode.dart file
    _scanSubscription?.cancel();
    super.dispose();
  }
}
