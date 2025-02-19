import 'package:flutter/material.dart';

class SnackBarUtil {
  static void showCustomSnackBar({
    required BuildContext context,
    required String text,
    Color backgroundColor = const Color.fromARGB(255, 94, 169, 143),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}