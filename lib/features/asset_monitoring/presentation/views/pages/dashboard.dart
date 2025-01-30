import 'package:asset_monitor/features/asset_monitoring/presentation/asset_bloc/asset_bloc.dart';
import 'package:asset_monitor/features/asset_monitoring/presentation/views/pages/daily_temperature_chart.dart';
import 'package:asset_monitor/features/asset_monitoring/presentation/views/pages/daily_vibration_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardPage extends StatelessWidget {
  static const routeName = '/dashboard';

  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<AssetBloc>()
        ..add(const GetAssetsEvent()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Monitor'),
       // actions: [
          // IconButton(
          //   icon: const Icon(Icons.refresh),
          //   onPressed: () {
          //     context.read<AssetBloc>().add(const GetAssetsEvent());
          //   },
          // ),
    //    ],
      ),
      body: BlocConsumer<AssetBloc, AssetState>(
        listener: (context, state) {
          if (state is AssetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {

          if (state is AssetLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MultipleAssetsLoaded) {
            if (state.assets.isEmpty) {
              return const Center(
                child: Text('No assets found'),
              );
            }
            return Column(
              children: [
                DailyTemperatureChart(assets: state.assets),
                DailyVibrationChart(assets: state.assets)
              ],
            );
          }

          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
    );
  }
}

// class _AssetGrid extends StatelessWidget {
//   final List<Asset> assets;

//   const _AssetGrid({
//     Key? key,
//     required this.assets,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: () async {
//         context.read<AssetBloc>().add(const GetAssetsEvent());
//       },
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
          
//           return GridView.builder(
//             padding: const EdgeInsets.all(16),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: crossAxisCount,
//               childAspectRatio: 1.5,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//             ),
//             itemCount: assets.length,
//             itemBuilder: (context, index) {
//               return AssetCard(asset: assets[index]);
//             },
//           );
//         },
//       ),
//     );
//   }

//   int _calculateCrossAxisCount(double width) {
//     if (width > 1200) return 4;
//     if (width > 800) return 3;
//     if (width > 600) return 2;
//     return 1;
//   }
// }