import 'package:application_map_todolist/wiggets/Tutorial.dart';
import 'package:flutter/material.dart';

class DialogHelper {
  static void showHowToUseAppDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            height: 550,
            child: Tutorial()
          ),
        );
      },
    );
  }
}
