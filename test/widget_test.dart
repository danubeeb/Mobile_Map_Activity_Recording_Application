import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class MultiSelectImageApp extends StatefulWidget {
  @override
  _MultiSelectImageAppState createState() => _MultiSelectImageAppState();
}

class _MultiSelectImageAppState extends State<MultiSelectImageApp> {
  List<String> imageList = [
    // ตัวอย่าง path รูปภาพ
    'assets/image1.png',
    'assets/image2.png',
    'assets/image3.png',
    'assets/image4.png',
  ];
  Set<int> selectedIndices = {}; // เก็บดัชนีรูปภาพที่ถูกเลือก

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รูปภาพทั้งหมด')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: imageList.length,
              itemBuilder: (BuildContext context, int index) {
                final imagePath = imageList[index];
                final isAsset = imagePath.startsWith('data:image');
                final isSelected = selectedIndices.contains(index);

                return GestureDetector(
                  onLongPress: () {
                    setState(() {
                      if (isSelected) {
                        selectedIndices.remove(index);
                      } else {
                        selectedIndices.add(index);
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: isAsset
                            ? Image.memory(
                                Uint8List.fromList(
                                    base64Decode(imagePath.split(',').last)),
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                              ),
                      ),
                      if (isSelected)
                        const Positioned(
                          top: 5,
                          right: 5,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 16), // เพิ่มระยะห่างระหว่างปุ่ม
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: selectedIndices.isEmpty
                      ? null
                      : () {
                          setState(() {
                            selectedIndices.toList()
                              ..sort((a, b) => b.compareTo(a)) // ลบจากหลังสุด
                              ..forEach((index) {
                                imageList.removeAt(index);
                              });
                            selectedIndices.clear();
                          });
                          // บันทึกรายการที่เหลือ
                          EventStorage().saveImageListnew(imageList);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedIndices.isEmpty ? Colors.grey : Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.delete),
                      SizedBox(width: 20),
                      Text(
                        'ลบ',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EventStorage {
  void saveImageListnew(List<String> imageList) {
    // บันทึกรายการรูปภาพ (สามารถเพิ่ม SharedPreferences หรือระบบบันทึกอื่นได้)
    print('Saved image list: $imageList');
  }
}
