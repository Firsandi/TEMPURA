import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/dashboard_model.dart';

class MonitoringChart extends StatelessWidget {
  final List<SensorDataModel> history;

  const MonitoringChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.cardGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(child: Text("Belum ada data riwayat", style: TextStyle(color: Colors.white38))),
      );
    }

    // Reversed because history is usually latest first from API
    final sortedHistory = history.reversed.toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(10, 24, 20, 10),
      decoration: BoxDecoration(
        color: AppTheme.cardGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withOpacity(0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(color: Colors.white38, fontSize: 10);
                  switch (value.toInt()) {
                    case 0: return const Text('09.00', style: style);
                    case 5: return const Text('10.00', style: style);
                    case 10: return const Text('11.00', style: style);
                    case 15: return const Text('12.00', style: style);
                    case 19: return const Text('Sekarang', style: style);
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}°', style: const TextStyle(color: Colors.white38, fontSize: 10));
                },
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // Temperature Line (Gold)
            LineChartBarData(
              spots: sortedHistory.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.temp);
              }).toList(),
              isCurved: true,
              color: AppTheme.primaryGold,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryGold.withOpacity(0.15),
              ),
            ),
            // Humidity Line (Dashed Green)
            LineChartBarData(
              spots: sortedHistory.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.hum);
              }).toList(),
              isCurved: true,
              color: AppTheme.accentGreen,
              barWidth: 2,
              dashArray: [5, 5],
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
