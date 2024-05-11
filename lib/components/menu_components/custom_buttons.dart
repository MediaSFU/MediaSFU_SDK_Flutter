import 'package:flutter/material.dart';

/// CustomButtons - A widget for rendering custom buttons with various configurations.
///
/// This widget takes a list of button configurations and renders buttons accordingly.
///
/// The list of button configurations.
/// final List<Map<String, dynamic>> buttons;

class CustomButtons extends StatelessWidget {
  final List<Map<String, dynamic>> buttons;

  const CustomButtons({super.key, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: buttons.map<Widget>((button) {
        return Visibility(
          visible: button['show'] ?? true,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                button['action']();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color?>(
                  button['show'] ? button['backgroundColor'] : null,
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.all(10),
                ),
              ),
              child: Row(
                children: [
                  if (button['customComponent'] != null)
                    button['customComponent']!,
                  if (button['icon'] != null && button['icon'] is IconData)
                    Icon(
                      button['icon'],
                      size: 20,
                      color: Colors.black,
                    ),
                  if (button['text'] != null && button['icon'] != null)
                    const SizedBox(width: 4), // Spacer between icon and text
                  if (button['text'] != null)
                    Text(
                      button['text'],
                      style: const TextStyle(color: Colors.black),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
