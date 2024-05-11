import 'package:flutter/material.dart';
import './components/mediasfu_components/mediasfu_webinar.dart'
    show MediasfuWebinar;

void main() {
  runApp(const MyApp());
}

/// The main application widget for Mediasfu Webinar.
///
/// This application allows users to join or create webinars hosted on Mediasfu.
/// It provides a simple and streamlined experience for users to participate in webinars.
class MyApp extends StatelessWidget {
  /// Constructs a new instance of [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mediasfu Webinar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Home screen displays the MediasfuWebinar widget
      home: const MediasfuWebinar(),
    );
  }
}
