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



}