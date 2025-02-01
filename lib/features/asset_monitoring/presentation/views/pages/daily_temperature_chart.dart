import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyTemperatureChart extends StatelessWidget {
  final List<Asset> assets;

  const DailyTemperatureChart({
    Key? key,
    required this.assets,
  }) : super(key: key);

//figure out why not getting 7 days 
//add more graphs oil level and vibration 
//add groups (cnc, motor, pumps) 
//or filtering 

  Map<String, double> calculateDailyAverages() {
    final Map<String, List<double>> temperaturesByDay = {};
    
    for (var asset in assets) {
      if (asset.temperature != null && asset.lastUpdated != null) {
        final day = DateFormat('MM-dd').format(asset.lastUpdated!);
        temperaturesByDay.putIfAbsent(day, () => []);
        temperaturesByDay[day]!.add(asset.temperature!);
      } else {
        print('Skipped asset - ID: ${asset.id}, temp: ${asset.temperature}, date: ${asset.lastUpdated}');
      }
    }

    // Calculate averages
    final Map<String, double> averages = {};
    temperaturesByDay.forEach((day, temperatures) {
      averages[day] = temperatures.reduce((a, b) => a + b) / temperatures.length;
    });

    return Map.fromEntries(
      averages.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key))
    );
}

  @override
  Widget build(BuildContext context) {
    final averages = calculateDailyAverages();
    final days = averages.keys.toList();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Daily Average Temperatures',
            style: TextStyle(
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
                maxY: 100, // Maximum temperature
                minY: 0,   // Minimum temperature
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
                            '${value.toInt()}°F',
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