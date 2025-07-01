import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fire_detection_provider.dart';
import '../utils/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 360;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: isSmallScreen ? 8 : null,
        leadingWidth: isSmallScreen ? 40 : null,
        title: Text(
          isSmallScreen
              ? 'Fire Detect'
              : isMobile
              ? 'Fire Detection'
              : 'Fire Detection System',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : null,
          ),
        ),
        actions: [
          // System Control Button
          Consumer<FireDetectionProvider>(
            builder: (context, provider, _) {
              if (!provider.isMqttConnected) return const SizedBox.shrink();

              return IconButton(
                icon: Icon(
                  Icons.power_settings_new,
                  color: AppTheme.primaryGreen,
                ),
                tooltip: 'Control System',
                onPressed: () => _showSystemControlDialog(context, provider),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () {
              final provider = Provider.of<FireDetectionProvider>(
                context,
                listen: false,
              );
              provider.refreshData();
            },
          ),
          SizedBox(width: isSmallScreen ? 4 : 8),
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

                        // Connection Status
                        _buildConnectionStatus(),
                        const SizedBox(height: 16),

                        // Main Fire Detection Status
                        _buildFireDetectionStatus(sensorData),
                        const SizedBox(height: 20),

                        // Sensor Monitoring Grid (hanya flame dan gas)
                        _buildSensorMonitoring(sensorData),
                        const SizedBox(height: 20),

                        // Fire Alert Widget jika terdeteksi
                        if (sensorData?.flameDetected == true ||
                            (sensorData?.gasLevel != null &&
                                sensorData!.gasLevel! >
                                    3000)) // Updated threshold
                          _buildFireAlert(sensorData),
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

  Widget _buildFireDetectionStatus(dynamic sensorData) {
    final flameDetected = sensorData?.flameDetected ?? false;
    final gasLevel = (sensorData?.gasLevel ?? 0).toDouble();
    final isDangerous =
        flameDetected || gasLevel > 3000; // Updated threshold to match Arduino

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDangerous ? Colors.red : AppTheme.primaryGreen,
          width: 2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDangerous
                  ? Colors.red.withOpacity(0.1)
                  : AppTheme.primaryGreen.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDangerous
                        ? Colors.red.withOpacity(0.2)
                        : AppTheme.primaryGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDangerous
                        ? Icons.local_fire_department_rounded
                        : Icons.shield_rounded,
                    color: isDangerous ? Colors.red : AppTheme.primaryGreen,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Sistem Kebakaran',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isDangerous ? 'BAHAYA TERDETEKSI!' : 'KONDISI AMAN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: isDangerous
                              ? Colors.red
                              : AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDangerous
                    ? Colors.red.withOpacity(0.1)
                    : AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getStatusDescription(flameDetected, gasLevel),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDangerous ? Colors.red : AppTheme.primaryGreen,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusDescription(bool flameDetected, double gasLevel) {
    if (flameDetected) {
      return 'Sensor flame mendeteksi api! Segera evakuasi area!';
    } else if (gasLevel > 3000) {
      // Updated threshold to match Arduino
      return 'Level gas berbahaya terdeteksi! Waspada kebocoran gas!';
    } else {
      return 'Semua sensor menunjukkan kondisi normal dan aman';
    }
  }

  Widget _buildSensorMonitoring(dynamic sensorData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monitoring Sensor',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            if (isMobile) {
              return Column(
                children: [
                  _buildFlameSensorCard(sensorData),
                  const SizedBox(height: 12),
                  _buildGasSensorCard(sensorData),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(child: _buildFlameSensorCard(sensorData)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildGasSensorCard(sensorData)),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildFlameSensorCard(dynamic sensorData) {
    final flameDetected = sensorData?.flameDetected ?? false;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: flameDetected ? Colors.red : Colors.grey.shade300,
          width: flameDetected ? 2 : 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: flameDetected ? Colors.red.withOpacity(0.05) : Colors.white,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: flameDetected
                        ? Colors.red.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: flameDetected ? Colors.red : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sensor Flame',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        flameDetected ? 'API TERDETEKSI' : 'Normal',
                        style: TextStyle(
                          color: flameDetected
                              ? Colors.red
                              : AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: flameDetected
                    ? Colors.red.withOpacity(0.1)
                    : AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                flameDetected ? 'BAHAYA' : 'AMAN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: flameDetected ? Colors.red : AppTheme.primaryGreen,
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

  Widget _buildGasSensorCard(dynamic sensorData) {
    final gasLevel = (sensorData?.gasLevel ?? 0).toDouble();
    final isDangerous = gasLevel > 3000; // Updated threshold to match Arduino
    final isWarning = gasLevel > 2000; // Warning level adjusted

    Color statusColor;
    String statusText;

    if (isDangerous) {
      statusColor = Colors.red;
      statusText = 'BAHAYA';
    } else if (isWarning) {
      statusColor = Colors.orange;
      statusText = 'WASPADA';
    } else {
      statusColor = AppTheme.primaryGreen;
      statusText = 'AMAN';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDangerous
              ? Colors.red
              : (isWarning ? Colors.orange : Colors.grey.shade300),
          width: isDangerous ? 2 : 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDangerous
              ? Colors.red.withOpacity(0.05)
              : isWarning
              ? Colors.orange.withOpacity(0.05)
              : Colors.white,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.gas_meter_rounded,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sensor Gas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${gasLevel.toStringAsFixed(0)} ppm',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
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

  Widget _buildFireAlert(dynamic sensorData) {
    final flameDetected = sensorData?.flameDetected ?? false;
    final gasLevel = (sensorData?.gasLevel ?? 0).toDouble();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.withOpacity(0.1),
              Colors.orange.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PERINGATAN BAHAYA!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        'Segera ambil tindakan keselamatan',
                        style: TextStyle(fontSize: 14, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  if (flameDetected)
                    const Text(
                      '🔥 Api terdeteksi! Segera evakuasi!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  if (gasLevel > 3000) // Updated threshold to match Arduino
                    Text(
                      '⚠️ Level gas berbahaya: ${gasLevel.toStringAsFixed(0)} ppm',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
              style: TextStyle(color: AppTheme.errorColor, fontSize: 14),
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
                provider.isMqttConnected ? Icons.wifi : Icons.wifi_off,
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

  void _showSystemControlDialog(
    BuildContext context,
    FireDetectionProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Control System'),
          content: const Text(
            'Do you want to activate or deactivate the fire detection system?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                provider.setSystemActive(false);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('System deactivated'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text(
                'Deactivate',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.setSystemActive(true);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('System activated'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
              child: Text(
                'Activate',
                style: TextStyle(color: AppTheme.primaryGreen),
              ),
            ),
          ],
        );
      },
    );
  }
}
