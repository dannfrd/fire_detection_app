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
    final Color primaryColor = isActive ? AppTheme.errorColor : AppTheme.primaryGreen;
    final String statusText = isActive ? 'DETECTED' : 'NORMAL';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background design element
            Positioned(
              right: -15,
              top: -15,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: primaryColor.withOpacity(0.1),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Icon row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 28,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Divider
                  Divider(
                    color: AppTheme.dividerColor,
                    thickness: 1,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
