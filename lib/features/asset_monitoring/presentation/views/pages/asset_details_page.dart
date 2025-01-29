// lib/features/asset_monitoring/presentation/pages/asset_detail_page.dart
import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';
import 'package:asset_monitor/features/asset_monitoring/presentation/asset_bloc/asset_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssetDetailPage extends StatelessWidget {
  static const routeName = '/asset/details';
  
  final String assetId;

  const AssetDetailPage({
    Key? key,
    required this.assetId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<AssetBloc>()
        ..add(GetAssetEvent(id: assetId))
        ..add(StartWatchingAssetEvent(id: assetId)),
      child: const AssetDetailView(),
    );
  }
}

class AssetDetailView extends StatelessWidget {
  const AssetDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssetBloc, AssetState>(
      listener: (context, state) {
        if (state is AssetError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state is SingleAssetLoaded 
                ? state.asset.name 
                : 'Asset Details'
            ),
            actions: [
              if (state is SingleAssetLoaded)
                _buildStatusChip(state.asset.status),
            ],
          ),
          body: state is SingleAssetLoaded
              ? _buildDetailContent(context, state.asset)
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildStatusChip(AssetStatus status) {
    final color = switch (status) {
      AssetStatus.normal => Colors.green,
      AssetStatus.warning => Colors.orange,
      AssetStatus.critical => Colors.red,
    };

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Chip(
        label: Text(
          status.name.toUpperCase(),
          style: TextStyle(color: color.computeLuminance() > 0.5 
            ? Colors.black 
            : Colors.white),
        ),
        backgroundColor: color.withOpacity(0.2),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, Asset asset) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AssetBloc>().add(GetAssetEvent(id: asset.id));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(asset),
          const SizedBox(height: 16),
          _buildSensorDataCard(asset),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Asset asset) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'General Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow('ID', asset.id),
            _buildInfoRow('Location', asset.location ?? 'Not specified'),
            _buildInfoRow(
              'Last Updated', 
              asset.lastUpdated?.toLocal().toString() ?? 'Never',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorDataCard(Asset asset) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Text(
              'Sensor Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildSensorRow(
              'Temperature',
              asset.temperature?.toStringAsFixed(1) ?? 'N/A',
              '°C',
              Icons.thermostat,
              _getTemperatureColor(asset.temperature),
            ),
            _buildSensorRow(
              'Vibration',
              asset.vibration?.toStringAsFixed(1) ?? 'N/A',
              'Hz',
              Icons.vibration,
              _getVibrationColor(asset.vibration),
            ),
            _buildSensorRow(
              'Oil Level',
              asset.oilLevel?.toString() ?? 'N/A',
              '%',
              Icons.opacity,
              _getOilLevelColor(asset.oilLevel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildSensorRow(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      TextSpan(text: ' $unit'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTemperatureColor(double? temperature) {
    if (temperature == null) return Colors.grey;
    if (temperature > 85) return Colors.red;
    if (temperature > 70) return Colors.orange;
    return Colors.green;
  }

  Color _getVibrationColor(double? vibration) {
    if (vibration == null) return Colors.grey;
    if (vibration > 15) return Colors.red;
    if (vibration > 10) return Colors.orange;
    return Colors.green;
  }

  Color _getOilLevelColor(int? level) {
    if (level == null) return Colors.grey;
    if (level < 20) return Colors.red;
    if (level < 40) return Colors.orange;
    return Colors.green;
  }
}