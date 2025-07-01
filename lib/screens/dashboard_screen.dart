import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fire_detection_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/emergency_contacts_widget.dart';
import '../widgets/fire_alert_widget.dart';
import '../widgets/gas_level_gauge.dart';
import '../widgets/realtime_gas_monitor.dart';
import '../widgets/safety_rules_widget.dart';
import '../widgets/sensor_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 360;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    
    return Scaffold(
      appBar: AppBar(
        titleSpacing: isSmallScreen ? 8 : null,
        leadingWidth: isSmallScreen ? 40 : null,
        title: Text(
          isSmallScreen ? 'Fire Detect' : 
          isMobile ? 'Fire Detection' : 
          'Fire Detection Dashboard',
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
              final provider = Provider.of<FireDetectionProvider>(context, listen: false);
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
                  
                  // Calculate responsive spacing
                  final horizontalPadding = constraints.maxWidth < 360 ? 12.0 : 
                                          constraints.maxWidth < 600 ? 16.0 : 
                                          constraints.maxWidth < 900 ? 20.0 : 24.0;
                                          
                  final verticalSpacing = constraints.maxWidth < 360 ? 12.0 : 
                                          constraints.maxWidth < 600 ? 16.0 : 20.0;
                  
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
                            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
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
                        
                        // Gas Level and Fire Status Header
                        _buildStatusHeader(sensorData),
                        
                        SizedBox(height: verticalSpacing),
                        
                        // Sensor Cards Grid
                        _buildSensorGrid(sensorData),
                        
                        SizedBox(height: verticalSpacing),
                        
                        // Real-time Gas Level Monitoring Card
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return RealtimeGasMonitor(
                              gasLevel: sensorData?.gasLevel,
                              isFireRisk: sensorData?.gasLevel != null && sensorData!.gasLevel! > 1000,
                              compactMode: constraints.maxWidth < 400, // Compact mode for very small screens
                            );
                          },
                        ),
                        
                        SizedBox(height: verticalSpacing),
                        
                        // Fire Alert Widget with Animation - only show when needed
                        if (sensorData?.isFireDetected == true || 
                            sensorData?.smokeDetected == true || 
                            sensorData?.flameDetected == true ||
                            (sensorData?.gasLevel != null && sensorData!.gasLevel! > 1000))
                          FireAlertWidget(
                            isFireDetected: sensorData?.isFireDetected == true || 
                                          sensorData?.smokeDetected == true || 
                                          sensorData?.flameDetected == true,
                            detectionSource: _getDetectionSource(sensorData),
                            gasLevel: sensorData?.gasLevel,
                            temperature: sensorData?.temperature,
                          ),
                        
                        if (sensorData?.isFireDetected == true || 
                            sensorData?.smokeDetected == true || 
                            sensorData?.flameDetected == true ||
                            (sensorData?.gasLevel != null && sensorData!.gasLevel! > 1000))
                          SizedBox(height: verticalSpacing),
                        
                        // Safety Rules and Instructions Widget - adjust based on screen size
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmallScreen = constraints.maxWidth < 360;
                            return SafetyRulesWidget(
                              isFireDetected: sensorData?.isFireDetected == true || 
                                           sensorData?.smokeDetected == true || 
                                           sensorData?.flameDetected == true,
                              isGasRisk: sensorData?.gasLevel != null && sensorData!.gasLevel! > 1000,
                              gasLevel: sensorData?.gasLevel,
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
                              isFireDetected: sensorData?.isFireDetected == true || 
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
        // More granular responsive breakpoints
        final isSmallMobile = constraints.maxWidth < 360;
        final isMobile = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
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
        SensorCard(
          title: 'Smoke',
          isActive: sensorData?.smokeDetected ?? false,
          icon: Icons.cloud_outlined,
        ),
        const SizedBox(height: 8),
        SensorCard(
          title: 'Flame',
          isActive: sensorData?.flameDetected ?? false,
          icon: Icons.local_fire_department_outlined,
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
            title: 'Gas',
            isActive: sensorData?.gasLevel != null && (sensorData!.gasLevel! > 1000),
            icon: Icons.gas_meter_outlined,
            subtitle: sensorData?.gasLevel != null ? '${sensorData!.gasLevel} ppm' : 'No data',
            showDetails: true,
          ),
        ),
        if (sensorData?.temperature != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: SensorCard(
              title: 'Temperature',
              isActive: sensorData?.temperature != null && (sensorData!.temperature! > 35),
              icon: Icons.thermostat_outlined,
              subtitle: '${sensorData.temperature}°C',
              showDetails: true,
            ),
          ),
        ],
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

  String? _getDetectionSource(dynamic sensorData) {
    if (sensorData == null) return null;
    
    List<String> sources = [];
    
    if (sensorData.smokeDetected == true) {
      sources.add('Sensor Asap');
    }
    
    if (sensorData.flameDetected == true) {
      sources.add('Sensor Api');
    }
    
    if (sensorData.gasLevel != null && sensorData.gasLevel > 2000) {
      sources.add('Sensor Gas');
    }
    
    if (sensorData.aiAnalysis != null && 
        sensorData.aiAnalysis.toString().toLowerCase().contains('api')) {
      sources.add('Analisis AI');
    }
    
    if (sources.isEmpty) return null;
    return sources.join(', ');
  }

  Widget _buildStatusHeader(dynamic sensorData) {
    final isFireDetected = sensorData?.isFireDetected ?? false;
    final gasLevel = sensorData?.gasLevel ?? 0;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (isFireDetected) {
      statusColor = Colors.red;
      statusText = 'KEBAKARAN TERDETEKSI';
      statusIcon = Icons.warning_rounded;
    } else if (gasLevel > 1000) {
      statusColor = Colors.orange;
      statusText = 'KADAR GAS TINGGI';
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
        final verticalPadding = isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);
        final horizontalPadding = isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0);
        
        // Adjust icon size based on screen size
        final iconSize = isSmallScreen ? 28.0 : (isMediumScreen ? 36.0 : 40.0);
        final iconPadding = isSmallScreen ? 12.0 : 16.0;
        
        // Adjust text sizes
        final titleFontSize = isSmallScreen ? 16.0 : (isMediumScreen ? 18.0 : 20.0);
        final subtitleFontSize = isSmallScreen ? 13.0 : (isMediumScreen ? 14.0 : 16.0);
        final subtitleIconSize = isSmallScreen ? 14.0 : 16.0;
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding, 
            horizontal: horizontalPadding
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
                    child: Icon(
                      statusIcon,
                      size: iconSize,
                      color: statusColor,
                    ),
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
                  left: iconSize + iconPadding * 2 + 16
                ),
                child: isMediumScreen ?
                  // Stack vertically on small screens
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.gas_meter_outlined,
                            size: subtitleIconSize,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Gas: ${gasLevel.toString()} ppm',
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
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
                        Icon(
                          Icons.gas_meter_outlined,
                          size: subtitleIconSize,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Gas: ${gasLevel.toString()} ppm',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (sensorData?.temperature != null) ...[
                          const SizedBox(width: 16),
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
