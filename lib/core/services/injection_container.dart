
import 'package:asset_monitor/features/asset_monitoring/data/datasources/asset_openai_datasource.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:asset_monitor/core/network/network_info.dart';
import 'package:asset_monitor/features/asset_chatbot/data/datasources/openai_remote_datasource.dart';
import 'package:asset_monitor/features/asset_chatbot/data/repositories/chatbot_repository_impl.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/repositories/chatbot_repository.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/usecases/create_thread.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/usecases/get_messages.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/usecases/send_message.dart';
import 'package:asset_monitor/features/asset_chatbot/presentation/chatbot_bloc/chatbot_bloc.dart';
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

final sl = GetIt.instance;

Future<void> init() async {
  // Load environment variables first
  await dotenv.load(fileName: ".env");

  // External dependencies (shared across features)
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Initialize features
  await initAssetMonitoring();
  await initChatbot();
}

Future<void> initAssetMonitoring() async {
  //Features - Asset Monitoring

  final fileId = getEnvOrThrow('OPEN_AI_FILE_ID');
  final apiKey = getEnvOrThrow('OPEN_AI_API_KEY');
  
  sl.registerLazySingleton<AssetOpenAIRemoteDataSource>(
    () => AssetOpenAIRemoteDataSourceImpl(
      client: sl(),
      fileId: fileId,
      openAIKey: apiKey,
    ),
  );
  
  // Environment variables
  sl.registerLazySingleton(() => dotenv.env['MQTT_ENDPOINT'] ?? '');

  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AssetModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(AssetStatusModelAdapter());
  }

  final assetBox = await Hive.openBox<AssetModel>('assets');
  sl.registerLazySingleton(() => assetBox);

  final fileContentBox = await Hive.openBox<String>('file_content');
  sl.registerLazySingleton(() => fileContentBox);

  // Data sources
  sl.registerLazySingleton<AssetLocalDataSource>(
    () => AssetLocalDataSourceImpl(assetBox: sl(), fileContentBox: sl()),
  );
  sl.registerLazySingleton<AssetRemoteDataSource>(
    () => AssetRemoteDataSourceImpl(
      endpoint: sl(),
      clientId: 'asset_monitor_${DateTime.now().millisecondsSinceEpoch}',
    ),
  );

  // Repository
  sl.registerLazySingleton<AssetRepository>(
    () => AssetRepositoryImpl(
      openAIRemoteDataSource: sl(),
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAsset(repository: sl()));
  sl.registerLazySingleton(() => GetAssets(repository: sl()));
  sl.registerLazySingleton(() => WatchAsset(repository: sl()));  

  // Bloc
  sl.registerFactory(() => AssetBloc(
    getAsset: sl(),
    getAssets: sl(),
    watchAsset: sl(),
  ));
}

Future<void> initChatbot() async {
  // Environment variables
  final apiKey = getEnvOrThrow('OPEN_AI_API_KEY');
  final assistantId = getEnvOrThrow('OPEN_AI_ASSISTANT_ID');

  // Data sources
  sl.registerLazySingleton<OpenAIRemoteDataSource>(
    () => OpenAIRemoteDataSourceImpl(
      client: sl(),  // Using shared http.Client
      apiKey: apiKey,
      assistantId: assistantId,
    ),
  );

  // Repository
  sl.registerLazySingleton<ChatbotRepository>(
    () => ChatbotRepositoryImpl(
      openAIDatasource: sl()
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateThread(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => GetMessages(sl()));

  // Bloc
  sl.registerFactory(() => ChatbotBloc(
    createThread: sl(),
    sendMessage: sl(),
    getMessages: sl(),
  ));
}

String getEnvOrThrow(String key) {
  final value = dotenv.env[key];
  if (value == null) throw Exception('No $key found in .env');
  return value;
}