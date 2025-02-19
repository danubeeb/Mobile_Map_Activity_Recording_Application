import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
