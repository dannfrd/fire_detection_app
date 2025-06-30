import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fire_detection_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/gas_level_gauge.dart';
import '../widgets/sensor_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = MediaQuery.of(context).size.width < 600;
            return Text(
              isMobile ? 'Fire Detection' : 'Fire Detection Dashboard',
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      body: Consumer<FireDetectionProvider>(
        builder: (context, provider, child) {
          print('=== UI REBUILD ===');
          print('Gas Level in UI: ${provider.currentSensorData?.gasLevel} ppm');
          print('Last Update: ${provider.currentSensorData?.timestamp}');
          print('MQTT Connected: ${provider.isMqttConnected}');
          print('================');
          
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final padding = isMobile ? 16.0 : 24.0;
                  
                  return Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error message
                        if (provider.error != null)
                          _buildErrorMessage(provider.error!),
                        
                        // Connection Status at top
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 600;
                            
                            if (isMobile) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildConnectionStatus(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Last Update: ${_formatTimestamp(sensorData?.timestamp)}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Row(
                                children: [
                                  _buildConnectionStatus(),
                                  const Spacer(),
                                  Text(
                                    'Last Update: ${_formatTimestamp(sensorData?.timestamp)}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Main Status Card
                        _buildMainStatusCard(sensorData),
                        
                        const SizedBox(height: 20),
                        
                        // Sensor Cards Grid
                        _buildSensorGrid(sensorData),
                        
                        const SizedBox(height: 20),
                        
                        // Gas Level Monitoring Card
                        _buildGasMonitoringCard(sensorData),
                        
                        const SizedBox(height: 20),
                        
                        // Fire Detection Status
                        if (sensorData?.isFireDetected == true || 
                            sensorData?.smokeDetected == true || 
                            sensorData?.flameDetected == true)
                          _buildFireAlert(sensorData),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
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

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildMainStatusCard(dynamic sensorData) {
    final isFireDetected = sensorData?.isFireDetected ?? false;
    final status = sensorData?.status ?? 'Unknown';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isFireDetected ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isFireDetected ? Border.all(color: Colors.red, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isFireDetected ? Icons.warning_rounded : Icons.check_circle_rounded,
            size: 48,
            color: isFireDetected ? Colors.red : AppTheme.primaryGreen,
          ),
          const SizedBox(height: 12),
          Text(
            isFireDetected ? 'FIRE DETECTED!' : 'SYSTEM NORMAL',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isFireDetected ? Colors.red : AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorGrid(dynamic sensorData) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we should use mobile or tablet layout
        final isMobile = constraints.maxWidth < 600;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sensor Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (isMobile) 
              _buildMobileSensorGrid(sensorData)
            else 
              _buildTabletSensorGrid(sensorData),
          ],
        );
      },
    );
  }

  Widget _buildMobileSensorGrid(dynamic sensorData) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SensorCard(
                title: 'Smoke',
                isActive: sensorData?.smokeDetected ?? false,
                icon: Icons.cloud_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SensorCard(
                title: 'Flame',
                isActive: sensorData?.flameDetected ?? false,
                icon: Icons.local_fire_department_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SensorCard(
          title: 'Gas Sensor',
          isActive: sensorData?.gasLevel != null && (sensorData!.gasLevel! > 300),
          icon: Icons.gas_meter_outlined,
          subtitle: sensorData?.gasLevel != null ? '${sensorData!.gasLevel} ppm' : 'No data',
        ),
      ],
    );
  }

  Widget _buildTabletSensorGrid(dynamic sensorData) {
    return Row(
      children: [
        Expanded(
          child: SensorCard(
            title: 'Smoke',
            isActive: sensorData?.smokeDetected ?? false,
            icon: Icons.cloud_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SensorCard(
            title: 'Flame',
            isActive: sensorData?.flameDetected ?? false,
            icon: Icons.local_fire_department_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SensorCard(
            title: 'Gas',
            isActive: sensorData?.gasLevel != null && (sensorData!.gasLevel! > 1000),
            icon: Icons.gas_meter_outlined,
            subtitle: sensorData?.gasLevel != null ? '${sensorData!.gasLevel} ppm' : 'No data',
          ),
        ),
      ],
    );
  }

  Widget _buildGasMonitoringCard(dynamic sensorData) {
    final gasLevel = sensorData?.gasLevel ?? 0;
    Color statusColor;
    String statusText;
    String statusDescription;
    
    if (gasLevel <= 1000) {
      statusColor = Colors.green;
      statusText = 'SAFE';
      statusDescription = 'Gas levels are normal';
    } else if (gasLevel <= 2000) {
      statusColor = Colors.orange;
      statusText = 'CAUTION';
      statusDescription = 'Elevated gas levels detected';
    } else {
      statusColor = Colors.red;
      statusText = 'DANGER';
      statusDescription = 'High gas levels - evacuate area';
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.gas_meter_outlined,
                size: 24,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 12),
              const Text(
                'Gas Level Monitoring',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Gas Level Gauge
          Center(
            child: GasLevelGauge(
              gasLevel: sensorData?.gasLevel,
              maxLevel: 3000,
              unit: 'ppm',
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Status indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFireAlert(dynamic sensorData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Column(
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          const Text(
            'FIRE ALERT',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fire or smoke detected! Please evacuate immediately and contact emergency services.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          
          // Show which sensors are triggered
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (sensorData?.smokeDetected == true)
                _buildAlertChip('Smoke Detected', Icons.cloud_outlined),
              if (sensorData?.flameDetected == true)
                _buildAlertChip('Flame Detected', Icons.local_fire_department_outlined),
              if (sensorData?.gasLevel != null && sensorData!.gasLevel! > 700)
                _buildAlertChip('Gas Alert', Icons.gas_meter_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
