
import 'dart:convert';
import 'dart:io';
import 'package:application_map_todolist/models/marker_model.dart';
import 'package:application_map_todolist/models/type_model.dart';
import 'package:application_map_todolist/services/data_storage.dart';
import 'package:application_map_todolist/services/event_notification_service.dart';
import 'package:application_map_todolist/units/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/event_model.dart';

Future<void> uploadEventsData(BuildContext context) async {
  bool onNotify = await EventStorage().loadSettingNotify();
  final eventsBox = Hive.box<Event>('eventsBox');
  final markersBox = Hive.box<MarkerEvent>('markersBox');
  final typesBox = await Hive.openBox<Type>('typesBox');

  // เปิด File Picker เพื่อเลือกไฟล์ JSON
  final params = OpenFileDialogParams(dialogType: OpenFileDialogType.document);
  final filePath = await FlutterFileDialog.pickFile(params: params);

  if (filePath == null) {
    print("No file selected");
    return;
  }

  // อ่านข้อมูลจากไฟล์
  final file = File(filePath);
  final fileContent = await file.readAsString();

  // แปลงข้อมูลจาก String เป็น JSON
  final Map<String, dynamic> jsonData = json.decode(fileContent);

  // เพิ่ม Events กลับเข้า Hive
  for (var eventData in jsonData['events']) {
    final event = Event(
      id: eventData['Id'],
      title: eventData['Title'],
      description: eventData['Description'],
      from: DateTime.parse(eventData['From']), // แปลง String เป็น DateTime
      to: DateTime.parse(eventData['To']),
      notiStart: eventData['NotiStart'],
      notiEnd: eventData['NotiEnd'],
      backgroundColor: eventData['BackgroundColor'],
      image: eventData['Image'],
      markerId: eventData['MarkerId'],
      typeId: eventData['TypeId'],
    );
    await eventsBox.put(event.id, event);
    if(onNotify){
      notificationService.scheduleNotification(
        event.to.hashCode, event.title, event.description,
        event.from, event.to, event.notiStart, event.notiEnd
      );
    }
  }

  // เพิ่ม Markers กลับเข้า Hive
  for (var markerData in jsonData['markers']) {
    final marker = MarkerEvent(
      markerId: markerData['MarkerId'],
      lat: markerData['Latitude'],
      lng: markerData['Longitude'],
      icon: markerData['Icon'],
    );
    await markersBox.put(marker.markerId, marker);
  }

  // เพิ่ม Types กลับเข้า Hive
    for (var typeData in jsonData['types']) {
    final type = Type(
      typeId: typeData['TypeId'],
      name: typeData['Name'],
      duration: typeData['Duration'],
    );
    await typesBox.put(type.typeId, type);
  }
  SnackBarUtil.showCustomSnackBar(context: context, text: 'อัปโหลดกิจกรรมเสร็จสิ้น!');
}


  Future<void> downloadEventsData(BuildContext context) async {
  final eventsBox = Hive.box<Event>('eventsBox');
  final markersBox = Hive.box<MarkerEvent>('markersBox');
    // ตรวจสอบและเปิด Box
    late Box<Type> typesBox;
    if (Hive.isBoxOpen('typesBox')) {
      typesBox = Hive.box<Type>('typesBox');
    } else {
      typesBox = await Hive.openBox<Type>('typesBox');
    }

  // ดึงข้อมูลจาก eventsBox
  final List<Map<String, dynamic>> eventsList = eventsBox.values.map((e) {
    return {
      "Id": e.id,
      "Title": e.title,
      "Description": e.description,
      "From": e.from.toIso8601String(), // ใช้ ISO 8601 Format
      "To": e.to.toIso8601String(),
      "NotiStart": e.notiStart,
      "NotiEnd": e.notiEnd,
      "BackgroundColor": e.backgroundColor,
      "Image": e.image,
      "MarkerId": e.markerId,
      "TypeId": e.typeId,
    };
  }).toList();

  // ดึงข้อมูลจาก markersBox
  final List<Map<String, dynamic>> markersList = markersBox.values.map((m) {
    return {
      "MarkerId": m.markerId,
      "Latitude": m.lat,
      "Longitude": m.lng,
      "Icon": m.icon,
    };
  }).toList();

  // ดึงข้อมูลจาก typesBox
  final List<Map<String, dynamic>> typesList = typesBox.values.map((t) {
    return {
      "TypeId": t.typeId,
      "Name": t.name,
      "Duration": t.duration,
    };
  }).toList();

  // รวมข้อมูลทั้งหมดเป็น JSON
  final Map<String, dynamic> fullData = {
    "events": eventsList,
    "markers": markersList,
    "types": typesList,
  };

  // แปลงเป็น JSON String
  final fullDataString = json.encode(fullData);

  // ใช้ path_provider เพื่อหาตำแหน่งบันทึกไฟล์
  final directory = await getExternalStorageDirectory();
  final filePath = '${directory?.path}/data.json'; // เปลี่ยนนามสกุลเป็น .json
  final file = File(filePath);

  // เขียนข้อมูลลงในไฟล์
  await file.writeAsString(fullDataString);

  // ให้ผู้ใช้เลือกตำแหน่งบันทึกไฟล์
  final params = SaveFileDialogParams(sourceFilePath: filePath, fileName: 'data.json');
  final savePath = await FlutterFileDialog.saveFile(params: params);

  if (savePath != null) {
    SnackBarUtil.showCustomSnackBar(context: context, text: 'ดาวน์โหลดกิจกรรมเสร็จสิ้น!');
  }
}