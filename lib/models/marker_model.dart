import 'package:hive/hive.dart';

@HiveType(typeId: 1)
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
