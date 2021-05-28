part of 'contact_user.dart';

class ContactUserAdapter extends TypeAdapter<ContactUser> {
  @override
  final int typeId = 1;

  @override
  ContactUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactUser(
      userId: fields[0] as String,
      userName: fields[1] as String,
      contactName: fields[2] as String,
      userEmail: fields[3] as String,
      userPhone: fields[4] as String,
      contactPhones: (fields[5] as List)?.cast<String>(),
      userPhotoURL: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ContactUser obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.contactName)
      ..writeByte(3)
      ..write(obj.userEmail)
      ..writeByte(4)
      ..write(obj.userPhone)
      ..writeByte(5)
      ..write(obj.contactPhones)
      ..writeByte(6)
      ..write(obj.userPhotoURL);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
