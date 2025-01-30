import 'package:hive/hive.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';

part 'asset_status_model.g.dart';

@HiveType(typeId: 1)
enum AssetStatusModel {
  @HiveField(0)
  normal,
  
  @HiveField(1)
  warning,
  
  @HiveField(2)
  critical;

  // Convert to domain enum
  AssetStatus toDomain() {
    switch (this) {
      case AssetStatusModel.normal:
        return AssetStatus.normal;
      case AssetStatusModel.warning:
        return AssetStatus.warning;
      case AssetStatusModel.critical:
        return AssetStatus.critical;
    }
  }

  // Convert from domain enum
  static AssetStatusModel fromDomain(AssetStatus status) {
    switch (status) {
      case AssetStatus.normal:
        return AssetStatusModel.normal;
      case AssetStatus.warning:
        return AssetStatusModel.warning;
      case AssetStatus.critical:
        return AssetStatusModel.critical;
    }
  }
}