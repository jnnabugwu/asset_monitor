// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssetModelAdapter extends TypeAdapter<AssetModel> {
  @override
  final int typeId = 0;

  @override
  AssetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssetModel(
      id: fields[0] as String,
      name: fields[1] as String,
      location: fields[2] as String?,
      temperature: fields[3] as double?,
      vibration: fields[4] as double?,
      oilLevel: fields[5] as int?,
      lastUpdated: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AssetModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.temperature)
      ..writeByte(4)
      ..write(obj.vibration)
      ..writeByte(5)
      ..write(obj.oilLevel)
      ..writeByte(6)
      ..write(obj.lastUpdated)
      ..writeByte(7)
      ..write(obj.statusModel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
