import 'package:asset_monitor/core/services/csv_import_service.dart';
import 'package:asset_monitor/core/services/injection_container.dart';
import 'package:asset_monitor/core/services/router.dart';
import 'package:asset_monitor/features/asset_monitoring/data/datasources/asset_local_datasource.dart';
import 'package:asset_monitor/features/asset_monitoring/presentation/asset_bloc/asset_bloc.dart';
import 'package:asset_monitor/features/asset_monitoring/presentation/views/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "/Users/jordannnabugwu/Documents/GitHub/asset_monitor/.env");
  await init();

 
  

  // Initialize local data source
  final localDataSource = sl<AssetLocalDataSource>();
   // Clear existing data
  await localDataSource.clearAssets();

  // Initialize CSV import service
  final csvImporter = CsvImportService(localDataSource: localDataSource);
  
  // Import data on first launch
  await csvImporter.importFromAssets('assets/asset_data.csv');


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AssetBloc>(
          create: (context) {
            final assetBloc = sl<AssetBloc>();
            return assetBloc;
          } 
        ),
      ],
      child: MaterialApp(
        title: 'Asset Monitor',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        onGenerateRoute: generateRoute,
        initialRoute: DashboardPage.routeName,
      ),
    );
  }
}
