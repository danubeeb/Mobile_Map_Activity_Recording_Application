import 'package:application_map_todolist/models/event_model.dart';
import 'package:application_map_todolist/models/marker_model.dart';
import 'package:application_map_todolist/models/type_model.dart';
import 'package:application_map_todolist/services/event_data_service.dart';
import 'package:application_map_todolist/units/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:application_map_todolist/services/event_notification_service.dart';
import 'package:application_map_todolist/services/data_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  void addEvent(Event event) async {
    await DataStorage().saveEvent(event);
    notificationService.scheduleNotification(
        event.id.hashCode, event.title, event.description, event.from, event.to, event.notiStart, event.notiEnd
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
    await DataStorage().saveMarker(markerModel);
    await loadMarkers();
    notifyListeners();
  }

  void addType(Type type) async {
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
    notificationService.deleteNotifications(id);
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
    await loadEvents();
    await loadMarkers();
    notifyListeners();
  }

  void deleteAllEventAndMarker(BuildContext context) async {
    await DataStorage().clearEvent();
    await loadEvents();
    await loadMarkers();
    SnackBarUtil.showCustomSnackBar(context: context, text: 'กิจกรรมทั้งหมดถูลบแล้ว!');
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

  Future<void> importFile(BuildContext context) async {
    await uploadEventsData(context);
    await loadTypes();
    await loadMarkers();
    await loadEvents();
    notifyListeners();
  }

  void clearEvents() {
    _events.clear();
    notificationService.cancelAllNotifications();
    notifyListeners();
  }

}
