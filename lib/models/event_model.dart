import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Event {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime from;

  @HiveField(4)
  final DateTime to;

  @HiveField(5)
  final bool notiStart;

  @HiveField(6)
  final bool notiEnd;

  @HiveField(7)
  final int backgroundColor;

  @HiveField(8)
  final String image;

  @HiveField(9)
  final String markerId;

  @HiveField(10)
  final String typeId;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.from,
    required this.to,
    required this.notiStart,
    required this.notiEnd,
    required this.backgroundColor,
    required this.image,
    required this.markerId,
    required this.typeId,
  });
}