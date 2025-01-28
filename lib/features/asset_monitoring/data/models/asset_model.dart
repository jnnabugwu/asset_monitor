
import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';

class AssetModel extends Asset {
  const AssetModel({
    required super.id,
    required super.name,
    super.location,
    super.temperature,
    super.vibration,
    super.oilLevel,
    super.lastUpdated,
    required super.status,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      temperature: json['temperature']?.toDouble(),
      vibration: json['vibration']?.toDouble(),
      oilLevel: json['oilLevel']?.toInt(),  
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'])
          : null,  
      status: AssetStatus.values.firstWhere(
        (e) => e.toString() == 'AssetStatus.${json['status'].toLowerCase()}',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'temperature': temperature,
      'vibration': vibration,
      'oilLevel': oilLevel,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'status': status.toString().split('.').last.toUpperCase(),
    };
  }
}