import 'package:hive/hive.dart';
import 'package:application_map_todolist/models/type_model.dart';

class TypeEventAdapter extends TypeAdapter<Type> {
  @override
  final int typeId = 2;

  @override
  Type read(BinaryReader reader) {
    return Type(
      typeId: reader.readString(),
      name: reader.readString(),
      duration: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Type obj) {
    writer.writeString(obj.typeId);
    writer.writeString(obj.name);
    writer.writeString(obj.duration);
  }
}