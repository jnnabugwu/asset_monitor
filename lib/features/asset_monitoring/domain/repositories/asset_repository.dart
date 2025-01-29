

import 'package:asset_monitor/core/errors/failures.dart';
import 'package:asset_monitor/core/utils/typedef.dart';
import 'package:asset_monitor/features/asset_monitoring/data/models/asset_model.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';
import 'package:dartz/dartz.dart';

abstract class AssetRepository {
  ResultFuture<Asset> getAsset(String id);
  Stream<Either<Failure,Asset>> watchAssetUpdates(String id);
  ResultFuture<List<Asset>> getAssets();
  ResultFuture<void> updateAsset(AssetModel asset);
}