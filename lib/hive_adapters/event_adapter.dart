import 'package:hive/hive.dart';
import 'package:application_map_todolist/models/event_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EventAdapter extends TypeAdapter<Event> {
  @override
  final typeId = 0;

  @override
  Event read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final description = reader.readString();

    final fromTimestamp = reader.readInt();
    final toTimestamp = reader.readInt();
    final from = DateTime.fromMillisecondsSinceEpoch(fromTimestamp);
    final to = DateTime.fromMillisecondsSinceEpoch(toTimestamp);

    final notiStart = reader.readBool();
    final notiEnd = reader.readBool();

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
      notiStart: notiStart,
      notiEnd: notiEnd,
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
    writer.writeBool(obj.notiStart);
    writer.writeBool(obj.notiEnd);
    writer.writeInt(obj.backgroundColor);
    writer.writeString(obj.image);
    writer.writeString(obj.markerId);
    writer.writeString(obj.typeId);
  }
}