import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Mfuntion {

  // ตรวจประเภทรูปภาพเเละเเสดง
  static Widget resolveImageWidget({required String imagePath}) {
    final isAsset1 = imagePath.startsWith('data:image/png;base64,');
    return isAsset1
      ? Image.memory(
        Uint8List.fromList(base64Decode(imagePath.split(',').last)),
        fit: BoxFit.contain,
      )
      : Image.asset(
        imagePath,
        width: 45,
        height: 45,
        fit: BoxFit.contain,
    );
  }

  Widget buildToggleButtons({
    required int viewMode,
    required Function(int) onToggle,
    required String textleft,
    required String textright,
    double height = 36,
  }) {
  return Container(
    height: height,
    padding: EdgeInsets.symmetric(horizontal: 3),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 147, 101, 37),
      borderRadius: BorderRadius.circular(9),
    ),
    child: ToggleButtons(
      isSelected: [viewMode == 0, viewMode == 1],
      onPressed: (int index) {
        onToggle(index); // ใช้ callback function เพื่ออัปเดตค่า viewMode
      },
      borderColor: const Color.fromARGB(255, 147, 101, 37),
      selectedBorderColor: const Color.fromARGB(255, 73, 150, 123),
      borderWidth: 2,
      borderRadius: BorderRadius.circular(8.0),
      color: const Color.fromARGB(255, 109, 109, 109),
      fillColor: const Color.fromARGB(255, 98, 197, 162),
      constraints: BoxConstraints(
        minHeight: 30.0,
        minWidth: 40.0,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            textleft,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            textright,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    ),
  );
}



}