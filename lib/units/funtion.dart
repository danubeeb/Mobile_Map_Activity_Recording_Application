import 'package:flutter/material.dart';

class PinFuntion {
  
    static Widget buildNumberButton(String number,  void Function(String) onNumberPress) {
    return GestureDetector(
      onTap: () => onNumberPress(number),
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color.fromARGB(255, 98, 197, 162),
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: const TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  static Widget buildDeleteButton(VoidCallback onDeletePress) {
    return GestureDetector(
      onTap: onDeletePress,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.shade100,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.backspace, size: 24, color: Colors.red),
      ),
    );
  }

}