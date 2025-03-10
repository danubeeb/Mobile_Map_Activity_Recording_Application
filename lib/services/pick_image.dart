import 'dart:convert';
import 'dart:io';
import 'package:application_map_todolist/providers/event_provider.dart';
import 'package:application_map_todolist/units/snackbar_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

  Future<void> pickImage(BuildContext context, List<String> imageList) async {
    final ImagePicker _picker = ImagePicker();
    String base64Strings = '';
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {

      base64Strings = base64Encode(File(image.path).readAsBytesSync());
      imageList.add('data:image/png;base64,$base64Strings') ;
      final provider = Provider.of<EventProvider>(context, listen: false);
      provider.addImage(imageList);
      SnackBarUtil.showCustomSnackBar(context: context, text: 'อัปโหลดรูปภาพเสร็จสิ้น!');
    }
  }