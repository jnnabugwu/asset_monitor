import 'dart:io';
import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:asset_monitor/features/asset_monitoring/data/models/asset_model.dart';
import 'package:asset_monitor/features/asset_monitoring/data/datasources/asset_local_datasource.dart';

class CsvImportService {
  final AssetLocalDataSource localDataSource;

  CsvImportService({required this.localDataSource});

  Future<void> importFromAssets(String assetPath) async {
    try {
      // Read CSV file from assets
      final String csvString = await rootBundle.loadString(assetPath);
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);
      
      // Skip header row and convert to AssetModels
      final assets = csvData.skip(1).map((row) => AssetModel(
        id: row[0].toString(),
        name: row[1].toString(),
        location: row[2].toString(),
        temperature: double.tryParse(row[3].toString()),
        vibration: double.tryParse(row[4].toString()),
        oilLevel: int.tryParse(row[5].toString()),
        lastUpdated: DateTime.tryParse(row[6].toString()),
        status: _parseStatus(row[7].toString()),
      )).toList();
      print('Number of assets taken from CSV file: ${assets.length}');
      // Batch save to local storage

      final uniqueIds = assets.map((a) => a.id).toSet();
      print('Number of unique asset IDs: ${uniqueIds.length}');      

      // Check date range
      final dates = assets.map((a) => a.lastUpdated).where((d) => d != null).toList()
        ..sort();
      if (dates.isNotEmpty) {
        print('Date range: ${dates.first} to ${dates.last}');
      }


      await localDataSource.cacheAssets(assets);
    } catch (e) {
      throw Exception('Failed to import CSV: $e');
    }
  }

  Future<void> importFromFile(File file) async {
    try {
      // Read CSV file
      final String csvString = await file.readAsString();
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);
      
      // Process in batches of 100 for better memory management
      const int batchSize = 100;
      for (var i = 1; i < csvData.length; i += batchSize) {
        final end = (i + batchSize < csvData.length) ? i + batchSize : csvData.length;
        final batchAssets = csvData.sublist(i, end).map((row) => AssetModel(
          id: row[0].toString(),
          name: row[1].toString(),
          location: row[2].toString(),
          temperature: double.tryParse(row[3].toString()),
          vibration: double.tryParse(row[4].toString()),
          oilLevel: int.tryParse(row[5].toString()),
          lastUpdated: DateTime.tryParse(row[6].toString()),
          status: _parseStatus(row[7].toString()),
        )).toList();

        await localDataSource.cacheAssets(batchAssets);
      }
    } catch (e) {
      throw Exception('Failed to import CSV: $e');
    }
  }

  AssetStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'critical':
        return AssetStatus.critical;
      case 'warning':
        return AssetStatus.warning;
      default:
        return AssetStatus.normal;
    }
  }
}