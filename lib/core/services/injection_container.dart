
import 'package:asset_monitor/core/network/network_info.dart';
import 'package:asset_monitor/features/asset_monitoring/data/datasources/asset_local_datasource.dart';
import 'package:asset_monitor/features/asset_monitoring/data/datasources/asset_remote_datasource.dart';
import 'package:asset_monitor/features/asset_monitoring/data/models/asset_model.dart';
import 'package:asset_monitor/features/asset_monitoring/data/repositories/asset_repository_impl.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/repositories/asset_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //Features - Asset Monitoring

  // Repository
  sl.registerLazySingleton<AssetRepository>(
    () => AssetRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AssetLocalDataSource>(
    () => AssetLocalDataSourceImpl(
      assetBox: sl(),
    ),
  );

  sl.registerLazySingleton<AssetRemoteDataSource>(
    () => AssetRemoteDataSourceImpl(
      endpoint: sl(), // From your .env via EnvConfig
      clientId: 'asset_monitor_${DateTime.now().millisecondsSinceEpoch}',
    ),
  );

  //Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  //External
  // Hive
  await Hive.initFlutter();
  
  // Register Adapters

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AssetModelAdapter());
  }

  final assetBox = await Hive.openBox<AssetModel>('assets');
  sl.registerLazySingleton(() => assetBox);

  // Network Checker
  sl.registerLazySingleton(() => InternetConnectionChecker());
}