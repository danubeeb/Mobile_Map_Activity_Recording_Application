import 'package:application_map_todolist/screens/home_screen.dart';
import 'package:application_map_todolist/services/data_storage.dart';
import 'package:application_map_todolist/units/funtion.dart';
import 'package:application_map_todolist/units/snackbar_util.dart';
import 'package:flutter/material.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({this.openAppFirstTime = false});
  final bool openAppFirstTime;
  @override
  _PinLoginScreenState createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String? correctPin ;
  String enteredPin = "";

  @override
  void initState() {
    super.initState();
    loadPin();
  }

  void loadPin() async {
    correctPin = await EventStorage().loadPin();
  }

  void _onNumberPress(String number) {
    if (enteredPin.length < 4) {
      setState(() {
        enteredPin += number;
      });

      if (enteredPin.length == 4) {
        _validatePin();
      }
    }
  }

  void _onDeletePress() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      });
    }
  }

  void _validatePin() {
    if (enteredPin == correctPin) {
    // PIN ถูกต้อง
    if(widget.openAppFirstTime){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
    if(!widget.openAppFirstTime) {
    Navigator.pop(context);
    }
    } else {
      // PIN ไม่ถูกต้อง
      setState(() {
        enteredPin = "";
      });
      SnackBarUtil.showCustomSnackBar(context: context, text: 'รหัสผ่านไม่ถูกต้อง!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 80, left: 50, right: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ป้อนรหัส',
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < enteredPin.length
                        ? const Color.fromARGB(255, 83, 168, 127)
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            GridView.builder(
              shrinkWrap: true,
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                if (index == 9) {
                  return const SizedBox.shrink(); // ช่องว่างสำหรับตำแหน่งที่ 9
                } else if (index == 10) {
                  return PinFuntion.buildNumberButton("0", _onNumberPress);
                } else if (index == 11) {
                  return PinFuntion.buildDeleteButton(_onDeletePress);
                } else {
                  return PinFuntion.buildNumberButton((index + 1).toString(), _onNumberPress);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
