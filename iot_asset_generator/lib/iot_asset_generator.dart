import 'dart:math';
import 'dart:io';
import 'dart:convert'; // For JSON encoding
import 'package:uuid/uuid.dart';

// Constants remain the same
const temperatureRange = (50.0, 95.0); // Fahrenheit
const vibrationRange = (0.0, 100.0);   // Hz
const oilLevelRange = (40, 100);       // Percentage

// Sample data remains the same
const locations = [
  'Factory Floor A',
  'Assembly Line B',
  'Maintenance Bay C',
  'Production Unit D',
  'Workshop E'
];

const assetTypes = [
  'Industrial Motor',
  'CNC Machine',
  'Pump System'
];

// Modified AssetData class to include toJson method
class AssetData {
  final String id;
  final String name;
  final String location;
  final double temperature;
  final double vibration;
  final int oilLevel;
  final DateTime lastUpdated;
  final String status;

  AssetData({
    required this.id,
    required this.name,
    required this.location,
    required this.temperature,
    required this.vibration,
    required this.oilLevel,
    required this.lastUpdated,
    required this.status,
  });

  // New method to convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'temperature': temperature,
    'vibration': vibration,
    'oilLevel': oilLevel,
    'lastUpdated': lastUpdated.toIso8601String(),
    'status': status,
  };
}

// generateStatus remains the same
String generateStatus(double temperature, double vibration, int oilLevel) {
  if (temperature > 85 || vibration > 80 || oilLevel < 50) {
    return 'critical';
  } else if (temperature > 75 || vibration > 60 || oilLevel < 70) {
    return 'warning';
  }
  return 'normal';
}

class AssetDataGenerator {
  final random = Random();
  final uuid = Uuid();

  double getRandomDouble(double min, double max) {
    return min + random.nextDouble() * (max - min);
  }

  int getRandomInt(int min, int max) {
    return min + random.nextInt(max - min + 1);
  }

  List<AssetData> generateAssetData({
    int numAssets = 8,
    int daysOfData = 7,
    int readingsPerDay = 1,
  }) {
    // Generation logic remains the same
    final assets = <AssetData>[];
    final now = DateTime.now();

    for (var i = 0; i < numAssets; i++) {
      final assetId = uuid.v4();
      final assetName = '${assetTypes[random.nextInt(assetTypes.length)]} #${getRandomInt(1000, 9999)}';
      final location = locations[random.nextInt(locations.length)];

      for (var day = 0; day < daysOfData; day++) {
        for (var reading = 0; reading < readingsPerDay; reading++) {
          final timestamp = now.subtract(Duration(
            days: day,
            hours: random.nextInt(24),
            minutes: random.nextInt(60),
          ));

          final temperature = double.parse(
              getRandomDouble(temperatureRange.$1, temperatureRange.$2)
                  .toStringAsFixed(1));
          final vibration = double.parse(
              getRandomDouble(vibrationRange.$1, vibrationRange.$2)
                  .toStringAsFixed(1));
          final oilLevel = getRandomInt(oilLevelRange.$1, oilLevelRange.$2);

          assets.add(AssetData(
            id: assetId,
            name: assetName,
            location: location,
            temperature: temperature,
            vibration: vibration,
            oilLevel: oilLevel,
            lastUpdated: timestamp,
            status: generateStatus(temperature, vibration, oilLevel),
          ));
        }
      }
    }
    return assets;
  }

Future<void> saveToJson(List<AssetData> assets, String filename) async {
  final jsonData = {
    'timestamp': DateTime.now().toIso8601String(),
    'assetCount': assets.map((a) => a.id).toSet().length,  // Unique asset count
    'assets': assets.map((asset) => asset.toJson()).toList(),  // All readings
  };

  final jsonString = JsonEncoder.withIndent('  ').convert(jsonData);
  await File(filename).writeAsString(jsonString);
}
}