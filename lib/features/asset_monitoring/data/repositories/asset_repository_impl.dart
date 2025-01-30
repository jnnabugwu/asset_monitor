import 'package:asset_monitor/core/errors/exception.dart';
import 'package:asset_monitor/core/errors/failures.dart';
import 'package:asset_monitor/core/network/network_info.dart';
import 'package:asset_monitor/core/utils/typedef.dart';
import 'package:asset_monitor/features/asset_monitoring/data/datasources/asset_local_datasource.dart';
import 'package:asset_monitor/features/asset_monitoring/data/datasources/asset_remote_datasource.dart';
import 'package:asset_monitor/features/asset_monitoring/data/models/asset_model.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/repositories/asset_repository.dart';
import 'package:dartz/dartz.dart';

class AssetRepositoryImpl implements AssetRepository {
  final AssetLocalDataSource localDataSource;
  final AssetRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AssetRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });



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
   ResultFuture<List<Asset>> getAssets() async{
    try {
      final localAssets = await localDataSource.getAllAssets();
      print('Length of assets: ${localAssets.length}');
      return Right(localAssets);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message
      , statusCode: e.statusCode)
      );
      
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