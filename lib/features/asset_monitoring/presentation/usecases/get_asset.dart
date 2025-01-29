
import 'package:asset_monitor/core/usecases/usecase.dart';
import 'package:asset_monitor/core/utils/typedef.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/repositories/asset_repository.dart';

class GetAsset extends UsecaseWithParams<Asset, String> {
  final AssetRepository repository;
  
  const GetAsset(this.repository);

  @override
  ResultFuture<Asset> call(String params) async {
    return repository.getAsset(params);
  }
}