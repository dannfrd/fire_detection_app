import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class GasLevelGauge extends StatelessWidget {
  final int? gasLevel;
  final int maxLevel;
  final String unit;

  const GasLevelGauge({
    super.key,
    required this.gasLevel,
    this.maxLevel = 1000,
    this.unit = 'ppm',
  });

  Color _getColorForLevel(int level) {
    if (level < maxLevel * 0.3) return Colors.green;
    if (level < maxLevel * 0.7) return Colors.orange;
    return Colors.red;
  }

  String _getLabelForLevel(int level) {
    if (level < maxLevel * 0.3) return 'Normal';
    if (level < maxLevel * 0.7) return 'Elevated';
    return 'Danger';
  }

  @override
  Widget build(BuildContext context) {
    if (gasLevel == null) {
      return const Center(
        child: Text(
          'No gas data available',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final level = gasLevel!;
    final progress = level / maxLevel;
    final safeProgress = progress.clamp(0.0, 1.0);
    final color = _getColorForLevel(level);
    final label = _getLabelForLevel(level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gas Level',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontSize: 15,
              ),
            ),
            Text(
              '$level $unit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: safeProgress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0 $unit',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              '$maxLevel $unit',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
