
import 'package:asset_monitor/core/network/network_info.dart';
import 'package:asset_monitor/features/asset_monitoring/data/datasources/asset_local_datasource.dart';
import 'package:asset_monitor/features/asset_monitoring/data/datasources/asset_remote_datasource.dart';
import 'package:asset_monitor/features/asset_monitoring/data/models/asset_model.dart';
import 'package:asset_monitor/features/asset_monitoring/data/models/asset_status_model.dart';
import 'package:asset_monitor/features/asset_monitoring/data/repositories/asset_repository_impl.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/repositories/asset_repository.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/usecases/get_asset.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/usecases/get_assets.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/usecases/watch_asset.dart';
import 'package:asset_monitor/features/asset_monitoring/presentation/asset_bloc/asset_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //Features - Asset Monitoring
  
  //Environment variables
  sl.registerLazySingleton(() => dotenv.env['MQTT_ENDPOINT'] ?? '');

  // Bloc
  sl.registerFactory(() => AssetBloc(
    getAsset: sl(),
    getAssets: sl(),
    watchAsset: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => GetAsset(repository: sl()));
  sl.registerLazySingleton(() => GetAssets(repository: sl()));
  sl.registerLazySingleton(() => WatchAsset(repository: sl()));  

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

  if (!Hive.isAdapterRegistered(1)) {
  Hive.registerAdapter(AssetStatusModelAdapter());
  }

  final assetBox = await Hive.openBox<AssetModel>('assets');
  sl.registerLazySingleton(() => assetBox);

  // Network Checker
  sl.registerLazySingleton(() => InternetConnectionChecker());
}