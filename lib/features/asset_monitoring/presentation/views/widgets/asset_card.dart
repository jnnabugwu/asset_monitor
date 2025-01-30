import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';
import 'package:asset_monitor/features/asset_monitoring/presentation/asset_bloc/asset_bloc.dart';
import 'package:asset_monitor/features/asset_monitoring/presentation/views/pages/asset_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssetCard extends StatefulWidget {
  final Asset asset;

  const AssetCard({
    super.key,
    required this.asset,
  });

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
 // Store the bloc reference
  late final AssetBloc _assetBloc;

  @override
  void initState() {
    super.initState();
    _assetBloc = context.read<AssetBloc>();
    // Use stored reference
    _assetBloc.add(StartWatchingAssetEvent(id: widget.asset.id));
  }

@override
  void dispose() {
    // Use stored reference instead of reading from context
    _assetBloc.add(const StopWatchingAssetEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AssetDetailPage(assetId: widget.asset.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.asset.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusIndicator(widget.asset.status),
                ],
              ),
              const SizedBox(height: 8),
              _buildMetricRow(
                'Temperature',
                '${widget.asset.temperature?.toStringAsFixed(1) ?? 'N/A'}°C',
                Icons.thermostat,
              ),
              _buildMetricRow(
                'Vibration',
                '${widget.asset.vibration?.toStringAsFixed(1) ?? 'N/A'} Hz',
                Icons.vibration,
              ),
              _buildMetricRow(
                'Oil Level',
                '${widget.asset.oilLevel?.toString() ?? 'N/A'}%',
                Icons.opacity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(AssetStatus status) {
    final color = switch (status) {
      AssetStatus.normal => Colors.green,
      AssetStatus.warning => Colors.orange,
      AssetStatus.critical => Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}