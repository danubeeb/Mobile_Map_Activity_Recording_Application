import 'package:flutter/material.dart';

class CustomButtons {
  Widget DoneButton({
    required VoidCallback onPressed,
    IconData icon = Icons.done,
    Color color = const Color.fromARGB(255, 98, 197, 162),
    double size = 30.0,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: size),
    );
  }
}