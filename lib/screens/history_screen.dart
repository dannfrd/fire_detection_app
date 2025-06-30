import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/fire_detection_provider.dart';
import '../utils/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detection History',
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
          if (provider.isLoading && provider.sensorHistory.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            );
          }

          if (provider.sensorHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 72,
                    color: AppTheme.textSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No detection history available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.refreshData();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refreshData,
            color: AppTheme.primaryGreen,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.sensorHistory.length,
              itemBuilder: (context, index) {
                final data = provider.sensorHistory[index];
                return _buildHistoryItem(data, context, index == 0);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(dynamic sensorData, BuildContext context, bool isFirst) {
    final isAlert = sensorData.isFireDetected;
    final timeFormat = DateFormat('MMM dd, yyyy HH:mm');
    final statusColor = isAlert ? AppTheme.errorColor : AppTheme.primaryGreen;
    final statusIcon = isAlert ? Icons.warning_rounded : Icons.check_circle_rounded;
    final statusText = isAlert ? 'Fire Detection Alert' : 'Normal Status';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          Container(
            width: 50,
            height: double.infinity,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppTheme.dividerColor,
                      margin: const EdgeInsets.only(left: 19),
                    ),
                  ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.05),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeFormat.format(sensorData.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSensorInfo(
                          'Smoke Detector',
                          sensorData.smokeDetected ? "Detected" : "Clear",
                          Icons.cloud_outlined,
                          sensorData.smokeDetected,
                        ),
                        const SizedBox(height: 12),
                        _buildSensorInfo(
                          'Flame Detector',
                          sensorData.flameDetected ? "Detected" : "Clear",
                          Icons.local_fire_department_outlined,
                          sensorData.flameDetected,
                        ),
                        
                        if (sensorData.aiAnalysis != null) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.dividerColor,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 16,
                                      color: AppTheme.primaryGreen,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'AI Analysis',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  sensorData.aiAnalysis!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSensorInfo(String label, String status, IconData icon, bool isDetected) {
    final statusColor = isDetected ? AppTheme.errorColor : AppTheme.primaryGreen;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: statusColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
