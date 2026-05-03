import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final String statusText;
  final Color accentColor;
  final bool isOnline;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.statusText,
    required this.accentColor,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isOnline ? accentColor : Colors.orange;
    final displayValue = isOnline ? value : "--";
    final displayStatus = isOnline ? statusText : "Sensor Tidak Terdeteksi";
    final displayIcon = isOnline ? icon : Icons.sensors_off_outlined;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOnline ? Colors.white10 : Colors.orange.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          // Left vertical bar
          Positioned(
            left: 0,
            top: 16,
            bottom: 16,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: effectiveColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: effectiveColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(displayIcon, color: effectiveColor, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      displayValue,
                      style: TextStyle(
                        color: isOnline ? AppTheme.textLight : AppTheme.textGrey,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (isOnline)
                      Text(
                        unit,
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      isOnline
                          ? (title.contains("SUHU") ? Icons.trending_up : Icons.check_circle_outline)
                          : Icons.warning_amber_rounded,
                      color: effectiveColor,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      displayStatus,
                      style: TextStyle(
                        color: effectiveColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
