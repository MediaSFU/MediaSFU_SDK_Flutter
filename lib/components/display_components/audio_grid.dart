import 'package:flutter/material.dart';

// AudioGrid is a layout widget used to stack multiple components on top of each other.
/// It takes a list of widgets as input and renders them as a stack.

class AudioGrid extends StatelessWidget {
  final List<Widget> componentsToRender;

  // ignore: prefer_const_constructors_in_immutables
  AudioGrid({super.key, required this.componentsToRender});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: componentsToRender,
    );
  }
}
