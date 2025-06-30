import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fire_detection_provider.dart';
import '../utils/app_theme.dart';

class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FireDetectionProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: provider.isMqttConnected 
                ? AppTheme.primaryGreen.withOpacity(0.1) 
                : AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                provider.isMqttConnected 
                    ? Icons.wifi 
                    : Icons.wifi_off,
                size: 16,
                color: provider.isMqttConnected 
                    ? AppTheme.primaryGreen 
                    : AppTheme.errorColor,
              ),
              const SizedBox(width: 6),
              Text(
                provider.isMqttConnected 
                    ? 'MQTT Connected' 
                    : 'Using API (MQTT Disconnected)',
                style: TextStyle(
                  fontSize: 12,
                  color: provider.isMqttConnected 
                      ? AppTheme.primaryGreen 
                      : AppTheme.errorColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
