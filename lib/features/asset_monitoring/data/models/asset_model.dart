
import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';
import 'package:hive/hive.dart';

part 'asset_model.g.dart';

//Created an adapter for the AssetStatus type from the domain AssetStatus
@HiveType(typeId: 1)
class AssetStatusAdapter {
    @HiveField(0)
    final AssetStatus status;

    const AssetStatusAdapter(this.status);
}


@HiveType(typeId: 0)
class AssetModel extends Asset {

    @HiveField(0)
    @override
    final String id;
    
    
    @HiveField(1)
    @override
    final String name;
    
    
    @HiveField(2)
    @override
    final String? location;
    
    @HiveField(3)
    @override
    final double? temperature;
    
    @HiveField(4)
    @override
    final double? vibration;
    
    @HiveField(5)
    @override
    final int? oilLevel;
    
    @HiveField(6)
    @override
    final DateTime? lastUpdated;
    
    @HiveField(7)
    @override
    final AssetStatus status;

    const AssetModel({
            required this.id,        
            required this.name,      
            this.location,           
            this.temperature,        
            this.vibration,
            this.oilLevel,
            this.lastUpdated,
            required this.status,
        }) : super(                  
            id: id,
            name: name,
            location: location,
            temperature: temperature,
            vibration: vibration,
            oilLevel: oilLevel,
            lastUpdated: lastUpdated,
            status: status,
        );

  factory AssetModel.fromEntity(Asset asset) {
        return AssetModel(
            id: asset.id,
            name: asset.name,
            location: asset.location,
            temperature: asset.temperature,
            vibration: asset.vibration,
            oilLevel: asset.oilLevel,
            lastUpdated: asset.lastUpdated,
            status: asset.status,
        );
    }  

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