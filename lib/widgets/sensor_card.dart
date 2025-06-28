import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class SensorCard extends StatelessWidget {
  final String title;
  final bool isActive;
  final IconData icon;

  const SensorCard({
    super.key,
    required this.title,
    required this.isActive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isActive ? AppTheme.errorColor : AppTheme.primaryGreen,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.errorColor.withOpacity(0.1)
                    : AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive ? AppTheme.errorColor : AppTheme.primaryGreen,
                ),
              ),
              child: Text(
                isActive ? 'DETECTED' : 'NORMAL',
                style: TextStyle(
                  color: isActive ? AppTheme.errorColor : AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
