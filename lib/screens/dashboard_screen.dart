import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fire_detection_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/emergency_contacts_widget.dart';
import '../widgets/fire_alert_widget.dart';
import '../widgets/safety_rules_widget.dart';
import '../widgets/sensor_card.dart';

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
              : 'Fire Detection Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : null,
          ),
        ),
        actions: [
          // Show a refresh button in the app bar for easy access
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () {
              // Get the provider without listening
              final provider = Provider.of<FireDetectionProvider>(
                context,
                listen: false,
              );
              provider.refreshData();
            },
          ),
          if (!isMobile)
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'About',
              onPressed: () {
                // Show info about the app
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('About'),
                    content: const Text('Fire Detection System\nVersion 1.0.0'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          SizedBox(width: isSmallScreen ? 4 : 8),
        ],
      ),
      body: Consumer<FireDetectionProvider>(
        builder: (context, provider, child) {
          print('=== UI REBUILD ===');
          print(
            'Fire Detection Status in UI - Flame: ${provider.currentSensorData?.flameDetected}, Smoke: ${provider.currentSensorData?.smokeDetected}',
          );
          print('Last Update: ${provider.currentSensorData?.timestamp}');
          print('MQTT Connected: ${provider.isMqttConnected}');
          print('================');

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

                  // Calculate responsive spacing
                  final horizontalPadding = constraints.maxWidth < 360
                      ? 12.0
                      : constraints.maxWidth < 600
                      ? 16.0
                      : constraints.maxWidth < 900
                      ? 20.0
                      : 24.0;

                  final verticalSpacing = constraints.maxWidth < 360
                      ? 12.0
                      : constraints.maxWidth < 600
                      ? 16.0
                      : 20.0;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: padding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error message
                        if (provider.error != null)
                          _buildErrorMessage(provider.error!),

                        // Connection Status at top - responsive layout
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmallMobile = constraints.maxWidth < 360;
                            final isMobile = constraints.maxWidth < 600;
                            final isTablet =
                                constraints.maxWidth >= 600 &&
                                constraints.maxWidth < 900;
                            final isDesktop = constraints.maxWidth >= 900;

                            if (isSmallMobile || isMobile) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildConnectionStatus(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Last Update: ${_formatTimestamp(sensorData?.timestamp)}',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: isSmallMobile ? 11 : 12,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Row(
                                children: [
                                  _buildConnectionStatus(),
                                  const Spacer(),
                                  if (isDesktop)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Last Update: ${_formatTimestamp(sensorData?.timestamp)}',
                                          style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (isTablet)
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

                        SizedBox(height: verticalSpacing),

                        // Fire Detection Status Header
                        _buildStatusHeader(sensorData),

                        SizedBox(height: verticalSpacing),

                        // Sensor Cards Grid
                        _buildSensorGrid(sensorData),

                        SizedBox(height: verticalSpacing),

                        // Fire Detection Status Card
                        _buildFireDetectionCard(sensorData),

                        SizedBox(height: verticalSpacing),

                        // Fire Alert Widget with Animation - prioritize flame sensor
                        Consumer<FireDetectionProvider>(
                          builder: (context, provider, child) {
                            final alertLevel = provider.currentAlertLevel;
                            final sensorData = provider.currentSensorData;

                            // Show alert if flame detected, smoke detected, or high temperature
                            final shouldShowAlert =
                                alertLevel == AlertLevel.critical ||
                                alertLevel == AlertLevel.warning ||
                                alertLevel == AlertLevel.temperature;

                            if (!shouldShowAlert)
                              return const SizedBox.shrink();

                            return FireAlertWidget(
                              isFireDetected:
                                  sensorData?.flameDetected == true ||
                                  sensorData?.smokeDetected == true,
                              detectionSource: _getDetectionSource(sensorData),
                              gasLevel: sensorData?.gasLevel,
                              temperature: sensorData?.temperature,
                              alertLevel: alertLevel,
                            );
                          },
                        ),

                        // Add spacing only when alert is shown
                        Consumer<FireDetectionProvider>(
                          builder: (context, provider, child) {
                            final alertLevel = provider.currentAlertLevel;
                            final shouldShowAlert =
                                alertLevel == AlertLevel.critical ||
                                alertLevel == AlertLevel.warning ||
                                alertLevel == AlertLevel.temperature;
                            return shouldShowAlert
                                ? SizedBox(height: verticalSpacing)
                                : const SizedBox.shrink();
                          },
                        ),

                        // Safety Rules and Instructions Widget - adjust based on screen size
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmallScreen = constraints.maxWidth < 360;
                            return SafetyRulesWidget(
                              isFireDetected:
                                  sensorData?.isFireDetected == true ||
                                  sensorData?.smokeDetected == true ||
                                  sensorData?.flameDetected == true,
                              compactMode: isSmallScreen,
                            );
                          },
                        ),

                        SizedBox(height: verticalSpacing),

                        // Emergency Contacts Widget
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmallScreen = constraints.maxWidth < 360;
                            return EmergencyContactsWidget(
                              isFireDetected:
                                  sensorData?.isFireDetected == true ||
                                  sensorData?.smokeDetected == true ||
                                  sensorData?.flameDetected == true,
                              compactMode: isSmallScreen,
                            );
                          },
                        ),

                        SizedBox(height: verticalSpacing),
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

  Widget _buildSensorGrid(dynamic sensorData) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // More granular responsive breakpoints
        final isSmallMobile = constraints.maxWidth < 360;
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 900;
        final isDesktop = constraints.maxWidth >= 900;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sensor Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (isTablet || isDesktop)
                  Text(
                    'Last Updated: ${_formatTimestamp(sensorData?.timestamp)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (isSmallMobile)
              _buildSmallMobileSensorGrid(sensorData)
            else if (isMobile)
              _buildMobileSensorGrid(sensorData)
            else if (isTablet)
              _buildTabletSensorGrid(sensorData)
            else
              _buildDesktopSensorGrid(sensorData),
          ],
        );
      },
    );
  }

  Widget _buildSmallMobileSensorGrid(dynamic sensorData) {
    return Column(
      children: [
        // Flame sensor - most prominent
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: sensorData?.flameDetected == true
                ? Border.all(color: Colors.red, width: 2)
                : null,
            boxShadow: sensorData?.flameDetected == true
                ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: SensorCard(
            title: '🔥 Api',
            isActive: sensorData?.flameDetected ?? false,
            icon: Icons.local_fire_department_rounded,
            customColor: sensorData?.flameDetected == true ? Colors.red : null,
          ),
        ),
        const SizedBox(height: 8),

        // Smoke sensor
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: sensorData?.smokeDetected == true
                ? Border.all(color: Colors.orange, width: 2)
                : null,
          ),
          child: SensorCard(
            title: '💨 Asap',
            isActive: sensorData?.smokeDetected ?? false,
            icon: Icons.smoke_free_rounded,
            customColor: sensorData?.smokeDetected == true
                ? Colors.orange
                : null,
          ),
        ),
        const SizedBox(height: 8),

        SensorCard(
          title: '🌡️ Suhu',
          isActive:
              sensorData?.temperature != null &&
              (sensorData!.temperature! > 40),
          icon: Icons.thermostat_rounded,
          subtitle: sensorData?.temperature != null
              ? '${sensorData!.temperature!.toStringAsFixed(1)}°C'
              : 'No data',
          customColor:
              sensorData?.temperature != null && (sensorData!.temperature! > 40)
              ? Colors.orange
              : null,
        ),
      ],
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
          title: '🌡️ Suhu',
          isActive:
              sensorData?.temperature != null &&
              (sensorData!.temperature! > 40),
          icon: Icons.thermostat_rounded,
          subtitle: sensorData?.temperature != null
              ? '${sensorData!.temperature!.toStringAsFixed(1)}°C'
              : 'No data',
          customColor:
              sensorData?.temperature != null && (sensorData!.temperature! > 40)
              ? Colors.orange
              : null,
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
            title: 'Suhu',
            isActive:
                sensorData?.temperature != null &&
                (sensorData!.temperature! > 40),
            icon: Icons.thermostat_outlined,
            subtitle: sensorData?.temperature != null
                ? '${sensorData!.temperature!.toStringAsFixed(1)}°C'
                : 'No data',
            customColor:
                sensorData?.temperature != null &&
                    (sensorData!.temperature! > 40)
                ? Colors.orange
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopSensorGrid(dynamic sensorData) {
    return Row(
      children: [
        Expanded(
          child: SensorCard(
            title: 'Smoke',
            isActive: sensorData?.smokeDetected ?? false,
            icon: Icons.cloud_outlined,
            showDetails: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SensorCard(
            title: 'Flame',
            isActive: sensorData?.flameDetected ?? false,
            icon: Icons.local_fire_department_outlined,
            showDetails: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SensorCard(
            title: 'Suhu',
            isActive:
                sensorData?.temperature != null &&
                (sensorData!.temperature! > 40),
            icon: Icons.thermostat_outlined,
            subtitle: sensorData?.temperature != null
                ? '${sensorData!.temperature!.toStringAsFixed(1)}°C'
                : 'No data',
            showDetails: true,
            customColor:
                sensorData?.temperature != null &&
                    (sensorData!.temperature! > 40)
                ? Colors.orange
                : null,
          ),
        ),
        if (sensorData?.temperature != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: SensorCard(
              title: 'Temperature',
              isActive:
                  sensorData?.temperature != null &&
                  (sensorData!.temperature! > 35),
              icon: Icons.thermostat_outlined,
              subtitle: '${sensorData.temperature}°C',
              showDetails: true,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFireDetectionCard(dynamic sensorData) {
    final flameDetected = sensorData?.flameDetected ?? false;
    final smokeDetected = sensorData?.smokeDetected ?? false;
    final temperature = sensorData?.temperature ?? 0.0;

    Color statusColor;
    String statusText;
    String statusDescription;
    IconData statusIcon;

    if (flameDetected) {
      statusColor = Colors.red;
      statusText = 'KEBAKARAN TERDETEKSI';
      statusDescription = 'Sensor api mendeteksi nyala api!';
      statusIcon = Icons.local_fire_department_rounded;
    } else if (smokeDetected) {
      statusColor = Colors.orange;
      statusText = 'ASAP TERDETEKSI';
      statusDescription = 'Sensor asap mendeteksi adanya asap';
      statusIcon = Icons.smoke_free_rounded;
    } else if (temperature > 40) {
      statusColor = Colors.orange.shade700;
      statusText = 'SUHU TINGGI';
      statusDescription =
          'Suhu lingkungan tinggi: ${temperature.toStringAsFixed(1)}°C';
      statusIcon = Icons.thermostat_rounded;
    } else {
      statusColor = AppTheme.primaryGreen;
      statusText = 'AMAN';
      statusDescription = 'Semua sensor kebakaran normal';
      statusIcon = Icons.shield_rounded;
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [statusColor.withOpacity(0.1), Colors.white],
          ),
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
                  child: Icon(statusIcon, color: statusColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Deteksi Kebakaran',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: statusColor,
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
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                statusDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Sensor status indicators
            Row(
              children: [
                Expanded(
                  child: _buildSensorIndicator(
                    'Api',
                    flameDetected,
                    Icons.local_fire_department_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSensorIndicator(
                    'Asap',
                    smokeDetected,
                    Icons.smoke_free_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSensorIndicator(
                    'Suhu',
                    temperature > 40,
                    Icons.thermostat_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorIndicator(String label, bool isActive, IconData icon) {
    final color = isActive ? Colors.red : AppTheme.primaryGreen;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            isActive ? 'AKTIF' : 'NORMAL',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String? _getDetectionSource(dynamic sensorData) {
    if (sensorData == null) return null;

    List<String> sources = [];

    // Priority 1: Flame sensor (PRIMARY fire detection)
    if (sensorData.flameDetected == true) {
      sources.add('Sensor Api');
    }

    // Priority 2: Smoke sensor (Secondary fire indicator)
    if (sensorData.smokeDetected == true) {
      sources.add('Sensor Asap');
    }

    // Priority 3: AI Analysis (if available)
    if (sensorData.aiAnalysis != null &&
        sensorData.aiAnalysis.toString().toLowerCase().contains('api')) {
      sources.add('Analisis AI');
    }

    if (sources.isEmpty) return null;
    return sources.join(', ');
  }

  Widget _buildStatusHeader(dynamic sensorData) {
    final isFireDetected = sensorData?.isFireDetected ?? false;
    final temperature = sensorData?.temperature ?? 0.0;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isFireDetected) {
      statusColor = Colors.red;
      statusText = 'KEBAKARAN TERDETEKSI';
      statusIcon = Icons.warning_rounded;
    } else if (temperature > 45) {
      statusColor = Colors.orange;
      statusText = 'SUHU TINGGI';
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = AppTheme.primaryGreen;
      statusText = 'KONDISI NORMAL';
      statusIcon = Icons.check_circle_rounded;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive adjustments based on width
        final isSmallScreen = constraints.maxWidth < 360;
        final isMediumScreen = constraints.maxWidth < 600;

        // Adjust padding based on screen size
        final verticalPadding = isSmallScreen
            ? 12.0
            : (isMediumScreen ? 16.0 : 20.0);
        final horizontalPadding = isSmallScreen
            ? 16.0
            : (isMediumScreen ? 20.0 : 24.0);

        // Adjust icon size based on screen size
        final iconSize = isSmallScreen ? 28.0 : (isMediumScreen ? 36.0 : 40.0);
        final iconPadding = isSmallScreen ? 12.0 : 16.0;

        // Adjust text sizes
        final titleFontSize = isSmallScreen
            ? 16.0
            : (isMediumScreen ? 18.0 : 20.0);
        final subtitleFontSize = isSmallScreen
            ? 13.0
            : (isMediumScreen ? 14.0 : 16.0);
        final subtitleIconSize = isSmallScreen ? 14.0 : 16.0;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                statusColor.withOpacity(0.1),
                statusColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: statusColor.withOpacity(0.3),
              width: isSmallScreen ? 1 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Title row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(iconPadding),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, size: iconSize, color: statusColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),

              // Sensor values
              // Use responsive layout for the sensor data
              Container(
                margin: EdgeInsets.only(
                  top: isSmallScreen ? 8 : 12,
                  left: iconSize + iconPadding * 2 + 16,
                ),
                child: isMediumScreen
                    ?
                      // Stack vertically on small screens
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (sensorData?.temperature != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.thermostat_outlined,
                                  size: subtitleIconSize,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Suhu: ${sensorData!.temperature}°C',
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      )
                    // Layout horizontally on larger screens
                    : Row(
                        children: [
                          if (sensorData?.temperature != null) ...[
                            Icon(
                              Icons.thermostat_outlined,
                              size: subtitleIconSize,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Suhu: ${sensorData!.temperature}°C',
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
