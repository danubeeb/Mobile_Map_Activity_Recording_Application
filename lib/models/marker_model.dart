import 'package:hive/hive.dart';

//part 'marker_model.g.dart'; // ใช้สำหรับสร้างไฟล์ adapter อัตโนมัติ

@HiveType(typeId: 1) // กำหนด typeId ให้ไม่ซ้ำกับ EventAdapter
class MarkerEvent extends HiveObject {
  @HiveField(0)
  final String markerId;

  @HiveField(1)
  final double lat;

  @HiveField(2)
  final double lng;

  @HiveField(3)
  final String icon;

  MarkerEvent({
    required this.markerId,
    required this.lat,
    required this.lng,
    required this.icon,
  });
}
