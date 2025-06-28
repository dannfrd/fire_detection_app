import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class StatusIndicator extends StatelessWidget {
  final String status;
  final bool isFireDetected;

  const StatusIndicator({
    super.key,
    required this.status,
    required this.isFireDetected,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = AppTheme.primaryGreen;
    IconData statusIcon = Icons.check_circle;
    String statusMessage = 'All systems normal';

    if (status == 'Critical') {
      statusColor = AppTheme.errorColor;
      statusIcon = Icons.warning;
      statusMessage = 'Fire detected! Take immediate action';
    } else if (status == 'Warning') {
      statusColor = AppTheme.warningColor;
      statusIcon = Icons.warning_amber;
      statusMessage = 'Warning: Potential fire risk detected';
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              statusIcon,
              size: 64,
              color: statusColor,
            ),
            const SizedBox(height: 16),
            Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusMessage,
              style: TextStyle(
                fontSize: 16,
                color: statusColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
