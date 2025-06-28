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
        title: const Text('Fire Detection Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FireDetectionProvider>().refreshData();
            },
          ),
        ],
      ),
      body: Consumer<FireDetectionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentSensorData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final sensorData = provider.currentSensorData;

          return RefreshIndicator(
            onRefresh: provider.refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.errorColor),
                      ),
                      child: Text(
                        provider.error!,
                        style: const TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                  StatusIndicator(
                    status: sensorData?.status ?? 'Unknown',
                    isFireDetected: sensorData?.isFireDetected ?? false,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SensorCard(
                          title: 'Smoke Sensor',
                          isActive: sensorData?.smokeDetected ?? false,
                          icon: Icons.cloud,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SensorCard(
                          title: 'Flame Sensor',
                          isActive: sensorData?.flameDetected ?? false,
                          icon: Icons.local_fire_department,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'System Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('Last Update',
                              sensorData?.timestamp.toString() ?? 'Never'),
                          _buildInfoRow(
                              'Status', sensorData?.status ?? 'Unknown'),
                          if (sensorData?.latitude != null &&
                              sensorData?.longitude != null)
                            _buildInfoRow('Location',
                                '${sensorData!.latitude!.toStringAsFixed(6)}, ${sensorData.longitude!.toStringAsFixed(6)}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
