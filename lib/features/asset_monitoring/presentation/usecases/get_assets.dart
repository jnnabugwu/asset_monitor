import 'package:asset_monitor/core/usecases/usecase.dart';
import 'package:asset_monitor/core/utils/typedef.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/repositories/asset_repository.dart';

class GetAssets extends UsecaseWithoutParams<List<Asset>> {
  final AssetRepository repository;
  
  const GetAssets(this.repository);

  @override
  ResultFuture<List<Asset>> call() async {
    return repository.getAssets();
  }
}