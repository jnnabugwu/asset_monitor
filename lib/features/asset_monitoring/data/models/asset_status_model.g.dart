// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_status_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssetStatusModelAdapter extends TypeAdapter<AssetStatusModel> {
  @override
  final int typeId = 1;

  @override
  AssetStatusModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AssetStatusModel.normal;
      case 1:
        return AssetStatusModel.warning;
      case 2:
        return AssetStatusModel.critical;
      default:
        return AssetStatusModel.normal;
    }
  }

  @override
  void write(BinaryWriter writer, AssetStatusModel obj) {
    switch (obj) {
      case AssetStatusModel.normal:
        writer.writeByte(0);
        break;
      case AssetStatusModel.warning:
        writer.writeByte(1);
        break;
      case AssetStatusModel.critical:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetStatusModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
