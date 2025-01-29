import 'package:asset_monitor/core/errors/exception.dart';
import 'package:asset_monitor/features/asset_monitoring/data/models/asset_model.dart';
import 'package:hive/hive.dart';

abstract class AssetLocalDataSource {
  Future<AssetModel> getAsset(String id);
  Future<List<AssetModel>> getAllAssets();
  Future<void> cacheAsset(AssetModel asset);
  Future<void> cacheAssets(List<AssetModel> assets);
  Future<void> deleteAsset(String id);
  Future<void> clearAssets();
}

class AssetLocalDataSourceImpl implements AssetLocalDataSource {
  final Box<AssetModel> assetBox;
  final String boxName = 'assets';

  AssetLocalDataSourceImpl({required this.assetBox});

  static Future<AssetLocalDataSourceImpl> init() async {
    // Register adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AssetModelAdapter());
    }
    
    // Open box
    final box = await Hive.openBox<AssetModel>('assets');
    return AssetLocalDataSourceImpl(assetBox: box);
  }

  @override
  Future<AssetModel> getAsset(String id) async {
    final asset = assetBox.get(id);
    if (asset != null) {
      return asset;
    } else {
      throw const CacheException(message: 'Asset not found');
    }
  }

  @override
  Future<List<AssetModel>> getAllAssets() async {
    return assetBox.values.toList();
  }

  @override
  Future<void> cacheAsset(AssetModel asset) async {
    await assetBox.put(asset.id, asset);
  }

  @override
  Future<void> cacheAssets(List<AssetModel> assets) async {
    final Map<String, AssetModel> assetMap = {
      for (var asset in assets) asset.id: asset
    };
    await assetBox.putAll(assetMap);
  }

  @override
  Future<void> deleteAsset(String id) async {
    await assetBox.delete(id);
  }

  @override
  Future<void> clearAssets() async {
    await assetBox.clear();
  }
}
