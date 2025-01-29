import 'package:asset_monitor/features/asset_monitoring/presentation/views/pages/asset_details_page.dart';
import 'package:asset_monitor/features/asset_monitoring/presentation/views/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asset_monitor/core/services/injection_container.dart';
import 'package:asset_monitor/features/asset_monitoring/presentation/asset_bloc/asset_bloc.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case DashboardPage.routeName:
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<AssetBloc>(),
          child: const DashboardPage(),
        ),
      );

    case AssetDetailPage.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final assetId = arguments['assetId'] as String;
      
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<AssetBloc>(),
          child: AssetDetailPage(assetId: assetId),
        ),
      );

    default:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<AssetBloc>(),
          child: const DashboardPage(),
        ),
      );
  }
}