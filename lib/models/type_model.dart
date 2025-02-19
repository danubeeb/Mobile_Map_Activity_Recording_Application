import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class Type extends HiveObject {
  @HiveField(0)
  final String typeId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String duration;

  Type({
    required this.typeId,
    required this.name,
    required this.duration,
  });
}
