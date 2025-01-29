import 'package:asset_monitor/core/errors/failures.dart';
import 'package:asset_monitor/core/usecases/usecase.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/repositories/asset_repository.dart';
import 'package:dartz/dartz.dart';

class WatchAsset extends StreamUsecaseWithParams<Asset, String> {
  final AssetRepository repository;
  
  const WatchAsset({required this.repository});

  @override
  Stream<Either<Failure, Asset>> call(String params) {
    return repository.watchAssetUpdates(params);
  }
}