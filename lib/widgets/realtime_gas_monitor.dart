import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class RealtimeGasMonitor extends StatelessWidget {
  final int? gasLevel;
  final bool isFireRisk;
  final bool showAnimations;
  final bool compactMode;

  const RealtimeGasMonitor({
    super.key,
    required this.gasLevel,
    this.isFireRisk = false,
    this.showAnimations = true,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final level = gasLevel ?? 0;
    
    // Define thresholds and colors
    const warningThreshold = 1000;
    const dangerThreshold = 2000;
    
    Color levelColor;
    String statusText;
    String warningText;
    
    if (level < warningThreshold) {
      levelColor = Colors.green;
      statusText = 'AMAN';
      warningText = 'Kadar gas dalam batas normal';
    } else if (level < dangerThreshold) {
      levelColor = Colors.orange;
      statusText = 'WASPADA';
      warningText = 'Kadar gas meningkat, perhatikan area sekitar';
    } else {
      levelColor = Colors.red;
      statusText = 'BAHAYA';
      warningText = 'Kadar gas berbahaya! Segera evakuasi area';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isFireRisk 
            ? BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isFireRisk
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red.shade50,
                    Colors.white,
                  ],
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  compactMode ? 'Gas' : 'Monitoring Gas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: compactMode ? 16 : 18,
                    color: AppTheme.textPrimary,
                  ),
                ),
                _buildStatusBadge(statusText, levelColor),
              ],
            ),
            SizedBox(height: compactMode ? 12 : 20),
            
            // Gas level display
            Center(
              child: _buildGasValueDisplay(level, levelColor, compactMode),
            ),
            
            SizedBox(height: compactMode ? 10 : 16),
            
            // Progress indicator
            LinearProgressIndicator(
              value: level / 3000,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(levelColor),
              minHeight: compactMode ? 8 : 10,
              borderRadius: BorderRadius.circular(compactMode ? 4 : 5),
            ),
            
            SizedBox(height: compactMode ? 4 : 8),
            
            // Range indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0 ppm',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: compactMode ? 10 : 12,
                  ),
                ),
                Text(
                  '3000 ppm',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: compactMode ? 10 : 12,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: compactMode ? 10 : 16),
            
            // Warning text - simplified in compact mode
            if (compactMode && level >= warningThreshold) 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: levelColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      level >= dangerThreshold ? Icons.warning : Icons.info_outline,
                      color: levelColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        level >= dangerThreshold ? 'Kadar gas berbahaya!' : 'Kadar gas meningkat',
                        style: TextStyle(
                          color: levelColor,
                          fontSize: 12,
                          fontWeight: level >= dangerThreshold ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (!compactMode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: levelColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      level >= dangerThreshold ? Icons.warning : Icons.info_outline,
                      color: levelColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warningText,
                        style: TextStyle(
                          color: levelColor,
                          fontWeight: level >= dangerThreshold ? FontWeight.bold : FontWeight.normal,
                        ),
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

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildGasValueDisplay(int level, Color color, bool compact) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$level',
          style: TextStyle(
            fontSize: compact ? 36 : 48,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: compact ? 6 : 8, 
            left: compact ? 3 : 4,
          ),
          child: Text(
            'ppm',
            style: TextStyle(
              fontSize: compact ? 14 : 16,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
