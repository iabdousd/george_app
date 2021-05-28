// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_image.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedImageAdapter extends TypeAdapter<CachedImage> {
  @override
  final int typeId = 0;

  @override
  CachedImage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedImage(
      url: fields[0] as String,
      filePath: fields[1] as String,
      creationDate: fields[2] as DateTime,
      lastUseDate: fields[3] as DateTime,
      usesCount: fields[4] as int,
      quality: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CachedImage obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.creationDate)
      ..writeByte(3)
      ..write(obj.lastUseDate)
      ..writeByte(4)
      ..write(obj.usesCount)
      ..writeByte(5)
      ..write(obj.quality);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedImageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
