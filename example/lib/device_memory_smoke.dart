import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

void main() {
  runApp(const DeviceMemorySmokeApp());
}

/// Cycles through the SDK's two renderers in full-UI and engine-only modes.
///
/// This entry point intentionally uses no credentials or room actions. It is a
/// deterministic debug/JIT and lifecycle smoke test for a physical device:
///
/// ```bash
/// flutter run --debug -t lib/device_memory_smoke.dart
/// ```
class DeviceMemorySmokeApp extends StatefulWidget {
  const DeviceMemorySmokeApp({super.key});

  @override
  State<DeviceMemorySmokeApp> createState() => _DeviceMemorySmokeAppState();
}

class _DeviceMemorySmokeAppState extends State<DeviceMemorySmokeApp> {
  static const _modes = <String>[
    'classic-headless',
    'modern-headless',
    'classic-ui',
    'modern-ui',
  ];
  static const _transitionCount = 16;
  static const _transitionInterval = Duration(seconds: 5);

  Timer? _timer;
  int _modeIndex = 0;
  int _transitions = 0;

  @override
  void initState() {
    super.initState();
    _reportMode();
    _timer = Timer.periodic(_transitionInterval, (_) {
      if (_transitions >= _transitionCount) {
        _timer?.cancel();
        debugPrint('MEDIASFU_MEMORY_SMOKE complete');
        return;
      }

      setState(() {
        _modeIndex = (_modeIndex + 1) % _modes.length;
        _transitions++;
      });
      _reportMode();
    });
  }

  void _reportMode() {
    debugPrint(
      'MEDIASFU_MEMORY_SMOKE mode=${_modes[_modeIndex]} '
      'transition=$_transitions/$_transitionCount',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = _modes[_modeIndex];
    final isModern = mode.startsWith('modern');
    final isHeadless = mode.endsWith('headless');
    final engine = isModern
        ? ModernMediasfuGeneric(
            key: ValueKey(mode),
            options: ModernMediasfuGenericOptions(
              returnUI: !isHeadless,
              useLocalUIMode: true,
            ),
          )
        : MediasfuGeneric(
            key: ValueKey(mode),
            options: MediasfuGenericOptions(
              returnUI: !isHeadless,
              useLocalUIMode: true,
            ),
          );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          Positioned.fill(child: engine),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SafeArea(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '$mode • $_transitions/$_transitionCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
