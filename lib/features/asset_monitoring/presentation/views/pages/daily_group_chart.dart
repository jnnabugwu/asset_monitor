//So what this needs to have is 
//Group by machine 
//take in the machine name 
//and the the parameter by which to show 

import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyGroupChart extends StatelessWidget {
  final String machineGroup;
  final String parameter;
  final List<Asset> assets;
  const DailyGroupChart(
    {super.key, required this.machineGroup,
      required this.parameter, required this.assets}
      );

  
  List<Asset> groupMachine(List<Asset> assets, String machineGroup){
    var groupedMachines = assets.where(
      (element) => element.name.contains(machineGroup)
      ).toList();
    return groupedMachines;
  }

    Map<String, double> calculateDailyAverages(List<Asset> groupedAssets, String parameter){
      final Map<String, List<num>> parametersByDay = {};    
    switch (parameter) {
      case 'temperature':

          for (var asset in groupedAssets) {
            if (asset.temperature != null && asset.lastUpdated != null) {
              final day = DateFormat('MM-dd').format(asset.lastUpdated!);
              parametersByDay.putIfAbsent(day, () => []);
              parametersByDay[day]!.add(asset.temperature!);
            } else {
              print('Skipped asset - ID: ${asset.id}, date: ${asset.lastUpdated}');
            }
          }        
      case 'vibration':
          for (var asset in groupedAssets) {
            if (asset.vibration != null && asset.lastUpdated != null) {
              final day = DateFormat('MM-dd').format(asset.lastUpdated!);
              parametersByDay.putIfAbsent(day, () => []);
              parametersByDay[day]!.add(asset.vibration!);
            } else {
              print('Skipped asset - ID: ${asset.id}, date: ${asset.lastUpdated}');
            }
          } 
      case 'oilLevel':
          for (var asset in groupedAssets) {
            if (asset.oilLevel != null && asset.lastUpdated != null) {
              final day = DateFormat('MM-dd').format(asset.lastUpdated!);
              parametersByDay.putIfAbsent(day, () => []);
              parametersByDay[day]!.add(asset.oilLevel!);
            } else {
              print('Skipped asset - ID: ${asset.id}, date: ${asset.lastUpdated}');
            }
          } 
      default:
          for (var asset in groupedAssets) {
            if (asset.temperature != null && asset.lastUpdated != null) {
              final day = DateFormat('MM-dd').format(asset.lastUpdated!);
              parametersByDay.putIfAbsent(day, () => []);
              parametersByDay[day]!.add(asset.temperature!);
            } else {
              print('Skipped asset - ID: ${asset.id}, date: ${asset.lastUpdated}');
            }
          }        
    }


    
    // Calculate averages
    final Map<String, double> averages = {};
    parametersByDay.forEach((day, parameter) {
      averages[day] = parameter.reduce((a, b) => a + b) / parameter.length;
    });

    return Map.fromEntries(
      averages.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key))
    );
}


  @override
Widget build(BuildContext context) {
    final averages = calculateDailyAverages(assets,parameter);
    final days = averages.keys.toList();
    final String title = parameter;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Daily Average $title of ${machineGroup}s',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100, // Maximum vibration
                minY: 0,   // Minimum vibration
                barGroups: List.generate(
                  days.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: averages[days[index]]!,
                        color: _getTemperatureColor(averages[days[index]]!),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${value.toInt()}%',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                gridData: const FlGridData(show: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

    Color _getTemperatureColor(double temperature) {
    if (temperature > 85) {
      return Colors.red;
    } else if (temperature > 75) {
      return Colors.orange;
    }
    return Colors.green;
  }
}