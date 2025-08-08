import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m18_residences/models/reading.dart';

class ElectricConsumptionBarChart extends StatelessWidget {
  final List<Reading> completeReadings;
  final int yMax;
  final double barWidth;

  const ElectricConsumptionBarChart({super.key, required this.completeReadings, required this.yMax, required this.barWidth});

  @override
  Widget build(BuildContext context) {
    final reversedReadings = completeReadings.reversed.toList();

    return BarChart(
      BarChartData(
        maxY: yMax.toDouble(),
        minY: 0,
        barGroups:
            reversedReadings.asMap().entries.map((entry) {
              int index = entry.key;
              int value = entry.value.consumption;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: value.toDouble(),
                    color: Colors.blue,
                    width: barWidth,
                    borderRadius: BorderRadius.circular(4),
                    backDrawRodData: BackgroundBarChartRodData(show: true, toY: yMax.toDouble(), color: Colors.grey.withAlpha(50)),
                  ),
                ],
              );
            }).toList(),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: yMax / 4,
              getTitlesWidget: (value, meta) => Text("${value.toInt()} kWh"),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < reversedReadings.length) {
                  DateTime date = reversedReadings[index].createdAt;
                  return Text(DateFormat("MMM").format(date).toUpperCase());
                }
                return Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: false),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding: EdgeInsets.all(4),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem("${rod.toY.toStringAsFixed(1)} kWh", TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            if (event is FlTapUpEvent && barTouchResponse != null) {}
          },
        ),
      ),
    );
  }
}
