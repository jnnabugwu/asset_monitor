import 'package:hive/hive.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';

class AssetStatusAdapter extends TypeAdapter<AssetStatus> {
  @override
  final int typeId = 1;

  @override
  AssetStatus read(BinaryReader reader) {
    final index = reader.readInt();
    return AssetStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, AssetStatus obj) {
    writer.writeInt(obj.index);
  }
}