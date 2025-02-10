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

  Future<void> cacheFileContent(String content);
  Future<String?> getFileContent();
}

class AssetLocalDataSourceImpl implements AssetLocalDataSource {
  final Box<AssetModel> assetBox;
  final Box<String> fileContentBox;
  final String boxName = 'assets';
  final String fileContentKey = 'asset_file_content';

  AssetLocalDataSourceImpl({
    required this.assetBox,
    required this.fileContentBox
  });

  // static Future<AssetLocalDataSourceImpl> init() async {
  //   // Register adapter
  //   if (!Hive.isAdapterRegistered(0)) {
  //     Hive.registerAdapter(AssetModelAdapter());
  //   }
  //   //Register adapter for AssetStatus
  // if (!Hive.isAdapterRegistered(1)) {
  //   Hive.registerAdapter(AssetStatusAdapter());
  // }    
  //   // Open box
  //   final box = await Hive.openBox<AssetModel>('assets');
  //   return AssetLocalDataSourceImpl(assetBox: box);
  // }

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

   // Clear existing assets first
    await assetBox.clear();   

  for (var asset in assets) {
    await assetBox.put(asset.id, asset);
  }
  }

  @override
  Future<void> deleteAsset(String id) async {
    await assetBox.delete(id);
  }

  @override
  Future<void> clearAssets() async {
    await assetBox.clear();
  }

  @override
  Future<void> cacheFileContent(String content) async {
    await fileContentBox.put(fileContentKey, content);
  }  

  @override 
  Future<String?> getFileContent() async {
    return fileContentBox.get(fileContentKey);
  }
}
