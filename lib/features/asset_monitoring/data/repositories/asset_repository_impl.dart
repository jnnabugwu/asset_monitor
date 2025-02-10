import 'package:asset_monitor/core/errors/exception.dart';
import 'package:asset_monitor/core/errors/failures.dart';
import 'package:asset_monitor/core/network/network_info.dart';
import 'package:asset_monitor/core/utils/typedef.dart';
import 'package:asset_monitor/features/asset_monitoring/data/datasources/asset_local_datasource.dart';
import 'package:asset_monitor/features/asset_monitoring/data/datasources/asset_openai_datasource.dart';
import 'package:asset_monitor/features/asset_monitoring/data/datasources/asset_remote_datasource.dart';
import 'package:asset_monitor/features/asset_monitoring/data/models/asset_model.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/repositories/asset_repository.dart';
import 'package:dartz/dartz.dart';

class AssetRepositoryImpl implements AssetRepository {
  final AssetOpenAIRemoteDataSource openAIRemoteDataSource;
  final AssetLocalDataSource localDataSource;
  final AssetRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AssetRepositoryImpl({
    required this.openAIRemoteDataSource,
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  Future<String> _formatAssetsForAI(List<AssetModel> assets) async {
    final buffer = StringBuffer();
    for (var asset in assets) {
      buffer.writeln("""
Machine ID: ${asset.id}
Name: ${asset.name}
Location: ${asset.location ?? 'Not specified'}
Status: ${asset.status.name}
Temperature: ${asset.temperature ?? 'N/A'}°F
Vibration: ${asset.vibration ?? 'N/A'} Hz
Oil Level: ${asset.oilLevel ?? 'N/A'}%
Last Updated: ${asset.lastUpdated?.toIso8601String() ?? 'N/A'}
-------------------""");
    }
    print('----------------');
    print(buffer.toString());
    return buffer.toString();
    
  }

// New method to cache formatted asset data
  ResultFuture<void> cacheFormattedAssetData() async {
    try {
      final assets = await localDataSource.getAllAssets();
      final formattedContent = await _formatAssetsForAI(assets);
      await localDataSource.cacheFileContent(formattedContent);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode
      ));
    }
  }

  // New method to get formatted asset data
  ResultFuture<String> getFormattedAssetData() async {
    try {
      final content = await localDataSource.getFileContent();
      if (content != null) {
        return Right(content);
      } else {
        // If no cached content exists, create it
        final result = await cacheFormattedAssetData();
        return result.fold(
          (failure) => Left(failure),
          (_) async {
            final newContent = await localDataSource.getFileContent();
            return Right(newContent ?? '');
          },
        );
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    }
  }

  @override
  ResultFuture<Asset> getAsset(String id) async{
    try {
         final localAsset = await localDataSource.getAsset(id);
         return Right(localAsset);      
      } on CacheException {
       return Left(CacheFailure(message: 'Asset not found', statusCode: 404));
     }
  }
  // ResultFuture<Asset> getAsset(String id) async {
  //   try {
  //     if (await networkInfo.isConnected) {
  //       final remoteAsset = await remoteDataSource.getAsset(id);
  //       await localDataSource.cacheAsset(remoteAsset);
  //       return Right(remoteAsset);
  //     } else {
  //       final localAsset = await localDataSource.getAsset(id);
  //       return Right(localAsset);
  //     }
  //   } on CacheException {
  //     return Left(CacheFailure(message: 'Asset not found', statusCode: 404));
  //   } on ServerException {
  //     // Try to get from cache if server fails
  //     try {
  //       final localAsset = await localDataSource.getAsset(id);
  //       return Right(localAsset);
  //     } on CacheException {
  //       return Left(CacheFailure(message: 'Asset not found', statusCode: 404));
  //     }
  //   }
  // }
  
 @override
  ResultFuture<List<Asset>> getAssets() async {
    final areWeConnected = await networkInfo.isConnected;
    try {
      if (areWeConnected) {
        print('getting assets in repo');
        final openAIAssets = await openAIRemoteDataSource.getAssets();
        print('got assets from data source');
        await localDataSource.cacheAssets(openAIAssets);
        final localAssets = await localDataSource.getAllAssets();
        print('localAssets: ${localAssets.length}');
        print(openAIAssets);
        return Right(openAIAssets);
      } else {
        print('getting assets from getallassets');
        final localAssets = await localDataSource.getAllAssets();
        return Right(localAssets);
      }
    } on ServerException catch (e){
      try {
         print('getting assets from get all assets 2');
         print(areWeConnected);
         print(ServerException(message: e.message, statusCode: e.statusCode));
        final localAssets = await localDataSource.getAllAssets();
        return Right(localAssets);
      } on CacheException catch (e) {
        return Left(CacheFailure(
          message: e.message,
          statusCode: e.statusCode,
        ));
      }
    }
  }

  // ResultFuture<List<Asset>> getAssets() async {
  //   try {
  //     if (await networkInfo.isConnected) {
  //       final remoteAssets = await remoteDataSource.getAssets();
  //       await localDataSource.cacheAssets(remoteAssets);
  //       return Right(remoteAssets);
  //     } else {
  //       final localAssets = await localDataSource.getAllAssets();
  //       return Right(localAssets);
  //     }
  //   } on CacheException catch (e) {
  //     return Left(CacheFailure(
  //       message: e.message,
  //       statusCode: e.statusCode,
  //     ));
  //   } on ServerException {
  //     // Try to get from cache if server fails
  //     try {
  //       final localAssets = await localDataSource.getAllAssets();
  //       return Right(localAssets);
  //     } on CacheException catch (e) {
  //       return Left(CacheFailure(
  //         message: e.message,
  //         statusCode: e.statusCode,
  //       ));
  //     }
  //   }
  // }
  
  @override
  ResultFuture<void> updateAsset(AssetModel asset) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateAsset(asset);
        return const Right(null);
      } else {
        return Left(NetworkFailure(
          message: 'No internet connection',
          statusCode: 503,
        ));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    }
  }
  
  @override
  Stream<Either<Failure, Asset>> watchAssetUpdates(String id) async* {
    if (await networkInfo.isConnected) {
      try {
        await for (final asset in remoteDataSource.watchAssetUpdates(id)) {
          await localDataSource.cacheAsset(asset);
          yield Right(asset);
        }
      } on ServerException catch (e) {
        yield Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      }
    } else {
      yield Left(NetworkFailure(
        message: 'No internet connection',
        statusCode: 503,
      ));
    }
  }
}