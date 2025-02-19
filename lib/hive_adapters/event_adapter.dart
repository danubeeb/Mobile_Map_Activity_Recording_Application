import 'package:hive/hive.dart';
import 'package:application_map_todolist/models/event_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EventAdapter extends TypeAdapter<Event> {
  @override
  final typeId = 0; // เลขประจำตัวประเภท (unique)

  @override
  Event read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final description = reader.readString();

    final fromTimestamp = reader.readInt();
    final toTimestamp = reader.readInt();
    final from = DateTime.fromMillisecondsSinceEpoch(fromTimestamp);
    final to = DateTime.fromMillisecondsSinceEpoch(toTimestamp);

    final backgroundColor = reader.readInt();
    final image = reader.readString();
    final markerId = reader.readString();
    final typeId = reader.readString();

    return Event(
      id: id,
      title: title,
      description: description,
      from: from,
      to: to,
      backgroundColor: backgroundColor,
      image: image,
      markerId: markerId,
      typeId: typeId,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeInt(obj.from.millisecondsSinceEpoch);
    writer.writeInt(obj.to.millisecondsSinceEpoch);
    writer.writeInt(obj.backgroundColor); // ใช้ writeInt สำหรับ int
    writer.writeString(obj.image);
    writer.writeString(obj.markerId);
    writer.writeString(obj.typeId);
  }
}

void main() async {
  // เริ่มต้น Hive และลงทะเบียน Adapter
  await Hive.initFlutter(); // เริ่มต้น Hive สำหรับ Flutter
  Hive.registerAdapter(EventAdapter());

  // ใช้งาน Hive ในการเก็บข้อมูล
  var box = await Hive.openBox<Event>('eventsBox');

  // ดึงข้อมูล
  print(box.values);
}