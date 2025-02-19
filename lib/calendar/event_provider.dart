
import 'dart:convert';
import 'dart:io';
import 'package:application_map_todolist/models/event_model.dart';
import 'package:application_map_todolist/models/marker_model.dart';
import 'package:application_map_todolist/models/type_model.dart';
import 'package:application_map_todolist/units/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:application_map_todolist/calendar/event_notification_service.dart';
import 'package:application_map_todolist/storage/hive_storage.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _events = [];
  List<MarkerEvent> _markers = [];
  List<Type> _types = [];
  List<String> _images = [];
  List<Event> get events => _events;
  List<MarkerEvent> get markers => _markers;
  List<Type> get types => _types;
  List<String> get images => _images;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date){
    _selectedDate = date;
    notifyListeners();
  }

  EventProvider() {
    loadEvents();
    loadMarkers();
    loadTypes();
    loadImages();
  }

  // โหลด ข้อมูล

  Future<void> loadEvents() async {
    _events = await DataStorage().getEvents();
    notifyListeners();
  }

  Future<void> loadMarkers() async {
    _markers = await DataStorage().getMarkers();
    notifyListeners();
  }

  Future<void> loadTypes() async {
    _types = await DataStorage().getTypes();
    notifyListeners();
  }

  Future<void> loadImages() async {
    _images = await DataStorage.getImages();
    notifyListeners();
  }



  Event? getEventByMarkerId(String markerId) {
    try {
      return _events.firstWhere((event) => event.markerId == markerId);
    } catch (e) {
      return null;
    }
  }

  Type getTypeById(String id) {
    try {
      return _types.firstWhere((type) => type.typeId == id);
    } catch (e) {
      return Type(typeId: '0', name: 'ทั่วไป', duration: '');
    }
  }

  // เพิ่ม ข้อมูล

  void addEvent(Event event, bool From, bool To) async {
    _events.add(event);
    await DataStorage().saveEvent(event);
    notificationService.scheduleNotification( 
        event.to.hashCode, event.title, event.description, event.from, event.to, From, To
    );
    await loadEvents();
    notifyListeners();
  }

  void addMarker(Marker marker, String image) async {
    MarkerEvent markerModel = MarkerEvent(
      markerId: marker.markerId.value,
      lat: marker.position.latitude,
      lng: marker.position.longitude,
      icon: image,
    );
    _markers.add(markerModel);
    await DataStorage().saveMarker(markerModel);
    notifyListeners();
  }

  void addType(Type type) async {
    _types.add(type);
    await DataStorage().saveType(type);
    await loadTypes();
    notifyListeners();
  }

  void addImage(List<String> images) async {
    await DataStorage.saveImages(images);
    await loadImages();
    notifyListeners();
  }

  // ลบข้อมูล

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((event) => event.id == id);
    await DataStorage().deleteEventById(id);
    await DataStorage().deleteMarkerById(id);
    notifyListeners();
  }

  Future<void> deleteMarker(String id) async {
    _markers.removeWhere((marker) => marker.markerId == id);
    await DataStorage().deleteMarkerById(id);
    notifyListeners();
  }

  Future<void> deleteType(String id) async {
    _types.removeWhere((type) => type.typeId == id);
    await DataStorage().deleteByTypeId(id);
    notifyListeners();
  }

  void deleteAllEventAndMarker(BuildContext context) async {
    await DataStorage().clearEvent();
    await loadEvents();
    SnackBarUtil.showCustomSnackBar(context: context, text: 'กิจกรรมทั้งหมดถูลบแล้ว!');
    notifyListeners();
  }


  // เเก้ไข ข้อมูล

  Future<void> editEvent(Event newEvent) async {
    await DataStorage().saveEvent(newEvent);
    await loadEvents();
    notifyListeners();
  }

  List<Event> get eventsOfSelectedDate => _events.where((event) {
    return (_selectedDate.isAtSameMomentAs(event.from) ||
      (_selectedDate.isAfter(event.from) && _selectedDate.isBefore(event.to)) ||
      event.from.day == _selectedDate.day &&
      event.from.month == _selectedDate.month &&
      event.from.year == _selectedDate.year
    );
  }).toList();

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
    print('✅ File saved at $savePath');
  }
}

Future<void> uploadEventsData(BuildContext context) async {
  final eventsBox = Hive.box<Event>('eventsBox');
  final markersBox = Hive.box<MarkerEvent>('markersBox');
  final typesBox = await Hive.openBox<Type>('typesBox');

  // เปิด File Picker เพื่อเลือกไฟล์ JSON
  final params = OpenFileDialogParams(dialogType: OpenFileDialogType.document);
  final filePath = await FlutterFileDialog.pickFile(params: params);

  if (filePath == null) {
    print("❌ No file selected");
    return;
  }

  // อ่านข้อมูลจากไฟล์
  final file = File(filePath);
  final fileContent = await file.readAsString();

  // แปลงข้อมูลจาก String เป็น JSON
  final Map<String, dynamic> jsonData = json.decode(fileContent);

  // 🔹 เพิ่ม Events กลับเข้า Hive
  for (var eventData in jsonData['events']) {
    final event = Event(
      id: eventData['Id'],
      title: eventData['Title'],
      description: eventData['Description'],
      from: DateTime.parse(eventData['From']), // แปลง String เป็น DateTime
      to: DateTime.parse(eventData['To']),
      backgroundColor: eventData['BackgroundColor'],
      image: eventData['Image'],
      markerId: eventData['MarkerId'],
      typeId: eventData['TypeId'],
    );
    await eventsBox.put(event.id, event);
  }

  // 🔹 เพิ่ม Markers กลับเข้า Hive
  for (var markerData in jsonData['markers']) {
    final marker = MarkerEvent(
      markerId: markerData['MarkerId'],
      lat: markerData['Latitude'],
      lng: markerData['Longitude'],
      icon: markerData['Icon'],
    );
    await markersBox.put(marker.markerId, marker);
  }

  // 🔹 เพิ่ม Types กลับเข้า Hive
    for (var typeData in jsonData['types']) {
    final type = Type(
      typeId: typeData['TypeId'],
      name: typeData['Name'],
      duration: typeData['Duration'],
    );
    await typesBox.put(type.typeId, type);
  }
  await loadMarkers();
  await loadEvents();
  notifyListeners();
  SnackBarUtil.showCustomSnackBar(context: context, text: 'อัปโหลดกิจกรรมเสร็จสิ้น!');
  print("✅ Upload data completed successfully!");
}

  void clearEvents() {
    _events.clear();
    notifyListeners();
  }

}
