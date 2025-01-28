import 'package:equatable/equatable.dart';

enum AssetStatus { normal, warning, critical }

class Asset extends Equatable {
  final String id;
  final String name;
  final String? location;
  final double? temperature;
  final double? vibration;
  final int? oilLevel;
  final DateTime? lastUpdated;
  final AssetStatus status;

  const Asset({
    required this.id,
    required this.name,
    this.location,
    this.temperature,
    this.vibration,
    this.lastUpdated,
    this.oilLevel,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        temperature,
        vibration,
        oilLevel,
        lastUpdated,
        status,
      ];
}