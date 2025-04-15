import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ElectricConsumptionBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> completeReadings;
  final double yMax;

  const ElectricConsumptionBarChart({
    super.key,
    required this.completeReadings,
    required this.yMax,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: yMax,
        minY: 0,
        barGroups:
            completeReadings.asMap().entries.map((entry) {
              int index = entry.key;
              double value = entry.value["curr_reading"].toDouble();

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: value,
                    color: Colors.blue,
                    width: 15,
                    borderRadius: BorderRadius.circular(4),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: yMax,
                      color: Colors.grey.withOpacity(0.2),
                    ),
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
                if (index >= 0 && index < completeReadings.length) {
                  DateTime date = completeReadings[index]["created_at"];
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
              return BarTooltipItem(
                "${rod.toY.toStringAsFixed(1)} kWh",
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
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
