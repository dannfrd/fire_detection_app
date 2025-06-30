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
    IconData statusIcon = Icons.check_circle_rounded;
    String statusMessage = 'All systems normal';

    if (status == 'Critical') {
      statusColor = AppTheme.errorColor;
      statusIcon = Icons.warning_rounded;
      statusMessage = 'Fire detected! Take immediate action';
    } else if (status == 'Warning') {
      statusColor = AppTheme.warningColor;
      statusIcon = Icons.warning_amber_rounded;
      statusMessage = 'Warning: Potential fire risk detected';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                statusIcon,
                size: 120,
                color: statusColor.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      size: 48,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          statusMessage,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
