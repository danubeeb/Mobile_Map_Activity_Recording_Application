import 'package:application_map_todolist/models/marker_model.dart';
import 'package:hive/hive.dart';

class MarkerEventAdapter extends TypeAdapter<MarkerEvent> {
  @override
  final int typeId = 1;

  @override
  MarkerEvent read(BinaryReader reader) {
    return MarkerEvent(
      markerId: reader.readString(),
      lat: reader.readDouble(),
      lng: reader.readDouble(),
      icon: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, MarkerEvent obj) {
    writer.writeString(obj.markerId);
    writer.writeDouble(obj.lat);
    writer.writeDouble(obj.lng);
    writer.writeString(obj.icon);
  }
}