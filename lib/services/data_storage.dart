
import 'dart:convert';

import 'package:application_map_todolist/hive_adapters/event_adapter.dart';
import 'package:application_map_todolist/hive_adapters/marker_adapter.dart';
import 'package:application_map_todolist/hive_adapters/type_adapter.dart';
import 'package:application_map_todolist/models/event_model.dart';
import 'package:application_map_todolist/models/marker_model.dart';
import 'package:application_map_todolist/models/type_model.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataStorage {
  static const String _boxEvent = 'eventsBox';
  static const String _boxMarker = 'markersBox';
  static const String _boxType = 'typesBox';
  static const String _boxImage = 'imagesBox';
  static const String _key = 'savedList';

  // event
  Future<Box<Event>> _openBoxEvent() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(EventAdapter());
    }
    return await Hive.openBox<Event>(_boxEvent);
  }

  Future<List<Event>> getEvents() async {
    final box = await _openBoxEvent();
    return box.values.toList();
  }

  Future<void> saveEvent(Event event) async {
    final box = await _openBoxEvent();
    await box.put(event.id, event);
  }

  Future<void> deleteEventById(String id) async {
    try {
      final box = await _openBoxEvent();
      final eventKey = box.keys.firstWhere(
        (key) {
          final storedEvent = box.get(key);
          return storedEvent != null && storedEvent.id == id;
        },
        orElse: () => null,
      );

      if (eventKey != null) {
        await box.delete(eventKey);
        print("ลบ Event สำเร็จ: $id");
      } else {
        print("ไม่พบ Event ที่ต้องการลบ: $id");
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดขณะลบ Event: $e");
    }
  }

  //marker
  Future<Box<MarkerEvent>> _openBoxMarker() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MarkerEventAdapter());
    }
    return await Hive.openBox<MarkerEvent>(_boxMarker);
  }

  Future<List<MarkerEvent>> getMarkers() async {
    final box = await _openBoxMarker();
    return box.values.toList();
  }

  Future<void> saveMarker(MarkerEvent marker) async {
    final box = await _openBoxMarker();
    await box.put(marker.markerId, marker);
  }

  Future<void> deleteMarkerById(String markerId) async {
    final box = await _openBoxMarker();
    if (box.containsKey(markerId)) {
      await box.delete(markerId);
    }
  }

  //type
  Future<Box<Type>> _openBoxType() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TypeEventAdapter());
    }
    return await Hive.openBox<Type>(_boxType);
  }

  Future<List<Type>> getTypes() async {
    try {
      final box = await _openBoxType();
      box.values.forEach((type) {
      });
      return box.values.toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveType(Type type) async {
    final box = await _openBoxType(); // เปิด Box ของ Type
    await box.put(type.typeId, type);
  }

  Future<void> deleteByTypeId(String typeId) async {
    final eventBox = await _openBoxEvent();
    final markerBox = await _openBoxMarker();
    final typeBox = await _openBoxType();

  // ลบข้อมูลใน _boxEvent ที่ตรงกับ typeId
    final eventsToDelete = eventBox.values.where((event) => event.typeId == typeId).toList();
    for (var event in eventsToDelete) {
      await eventBox.delete(event.id);
      await markerBox.delete(event.markerId);
    }

    // ลบข้อมูลใน _boxType ที่ตรงกับ typeId
    final typeToDelete = typeBox.values.where((type) => type.typeId == typeId).toList();
    for (var type in typeToDelete) {
      await typeBox.delete(type.typeId);
    }
  }

  //image
  /// ดึงข้อมูลจาก Hive ออกมาเป็น List<String>
  static Future<List<String>> getImages() async {
    var box = await Hive.openBox(_boxImage);
    return (box.get(_key, defaultValue: <String>[]) as List).cast<String>();
  }

  /// บันทึกข้อมูลลง Hive โดยแทนที่ค่าทั้งหมดด้วย List<String> ใหม่
  static Future<void> saveImages(List<String> newList) async {
    var box = await Hive.openBox(_boxImage);
    await box.put(_key, newList);
  }



  //ลบข้อมูลกิจกกรมทั้งหมด
  Future<void> clearEvent() async {
    final eventBox = await _openBoxEvent();
    final markerBox = await _openBoxMarker();
    await eventBox.clear();
    await markerBox.clear();
  }
}

class EventStorage {
  static const String _keyPin = 'pin';
  static const String _keySettingPin = 'settingPin';
  static const String _keySettingNotify = 'settingNotify';

  // บันทึกข้อมูล
  Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPin);
    await prefs.setString(_keyPin, pin);
  }

  Future<void> saveSettingPin(bool onSecurity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettingPin, onSecurity ? 'true' : 'false');
  }

  Future<void> saveSettingNotify(bool onNotify) async {
    final prefs = await SharedPreferences.getInstance();  
    await prefs.setString(_keySettingNotify, onNotify ? 'true' : 'false');
  }


  // โหลดข้อมูล


  Future<List<Map<String, dynamic>>> getMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> markerDataList = prefs.getStringList('marker') ?? [];
    List<Map<String, dynamic>> markers = [];
    for (String markerData in markerDataList) {
      markers.add(jsonDecode(markerData));
    }
    return markers;
  }

  Future<String?> loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPin);
  }

  Future<bool> loadSettingPin() async {
    final prefs = await SharedPreferences.getInstance();
    final onSecurity = prefs.getString(_keySettingPin);
    return onSecurity == 'true';
  }

  Future<bool> loadSettingNotify() async {
    final prefs = await SharedPreferences.getInstance();
    final onNotify = prefs.getString(_keySettingNotify);
    return onNotify == 'true' || onNotify == null;
  }


  // ลบข้อมูล

  Future<void> deletePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPin);
  }

}