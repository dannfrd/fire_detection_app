import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fire_detection_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/sensor_card.dart';
import '../widgets/status_indicator.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fire Detection Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<FireDetectionProvider>().refreshData();
            },
          ),
        ],
      ),
      body: Consumer<FireDetectionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentSensorData == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final sensorData = provider.currentSensorData;

          return RefreshIndicator(
            onRefresh: provider.refreshData,
            color: AppTheme.primaryGreen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.error != null)
                    _buildErrorMessage(provider.error!),
                  
                  // Headline
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16, top: 8),
                    child: Text(
                      'System Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  
                  // Status Indicator
                  StatusIndicator(
                    status: sensorData?.status ?? 'Unknown',
                    isFireDetected: sensorData?.isFireDetected ?? false,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Sensors Headline
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Sensor Readings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  
                  // Sensor Cards
                  Row(
                    children: [
                      Expanded(
                        child: SensorCard(
                          title: 'Smoke Sensor',
                          isActive: sensorData?.smokeDetected ?? false,
                          icon: Icons.cloud_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SensorCard(
                          title: 'Flame Sensor',
                          isActive: sensorData?.flameDetected ?? false,
                          icon: Icons.local_fire_department_outlined,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // System Info Headline
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'System Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  
                  // System Info Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowColor,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          Icons.update_rounded,
                          'Last Update',
                          sensorData?.timestamp.toString() ?? 'Never',
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.info_outline_rounded,
                          'Status',
                          sensorData?.status ?? 'Unknown',
                        ),
                        if (sensorData?.latitude != null &&
                            sensorData?.longitude != null) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            Icons.location_on_outlined,
                            'Location',
                            '${sensorData!.latitude!.toStringAsFixed(6)}, ${sensorData.longitude!.toStringAsFixed(6)}',
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Connection Status
                  _buildConnectionStatus(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorMessage(String errorMessage) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.errorColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryGreen,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
