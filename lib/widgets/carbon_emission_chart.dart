import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hackaurora_vjti/utils/dummy_data.dart';

class CarbonEmissionChart extends StatelessWidget {
  const CarbonEmissionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  DummyData.carbonData[value.toInt()].stage,
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: DummyData.carbonData
                .asMap()
                .entries
                .map((e) => FlSpot(
                      e.key.toDouble(),
                      e.value.emission,
                    ))
                .toList(),
            isCurved: true,
            color: Colors.green,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}