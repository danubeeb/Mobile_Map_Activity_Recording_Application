import 'package:application_map_todolist/services/data_storage.dart';
import 'package:application_map_todolist/units/funtion.dart';
import 'package:application_map_todolist/units/snackbar_util.dart';
import 'package:application_map_todolist/wiggets/custom_buttons.dart';
import 'package:flutter/material.dart';

class CreatePinScreen extends StatefulWidget {
  @override
  _CreatePinScreenState createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String? newPin;
  String enteredPin = "";
  bool isConfirmingPin = false;

  void _onNumberPress(String number) {
    if (enteredPin.length < 4) {
      setState(() {
        enteredPin += number;
      });
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
    if (!isConfirmingPin) {
      // กำหนด New PIN
      setState(() {
        newPin = enteredPin;
        enteredPin = "";
        isConfirmingPin = true; // เริ่มการยืนยันรหัส
      });
    } else {
      // ตรวจสอบรหัสผ่านที่ยืนยัน
      if (enteredPin == newPin) {
        EventStorage().savePin(newPin!);
        SnackBarUtil.showCustomSnackBar(context: context, text: 'ตั้งรหัสผ่านเสร็จสิ้น!');
        Navigator.pop(context); // ปิดหน้าหลังตั้งรหัสผ่านสำเร็จ
      } else {
        setState(() {
          enteredPin = ""; // ล้าง PIN
        });
        SnackBarUtil.showCustomSnackBar(context: context, text: 'รหัสผ่านไม่ตรงกัน! กรุณาลองอีกครั้ง');
      }
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
            Text(
              isConfirmingPin ? 'ยืนยันรหัสผ่าน' : 'รหัสผ่าน',
              style: const TextStyle(fontSize: 22),
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
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CloseButton(color: Color.fromARGB(255, 98, 197, 162),),
                CustomButtons().DoneButton(onPressed: _validatePin),
              ],
            )
          ],
        ),
      ),
    );
  }
}
