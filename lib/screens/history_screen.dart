import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/fire_detection_provider.dart';
import '../utils/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filterType = 'all'; // all, alerts, normal

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
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export history',
            onPressed: () {
              final provider = Provider.of<FireDetectionProvider>(
                context,
                listen: false,
              );

              List<dynamic> dataToExport = provider.sensorHistory;
              switch (_filterType) {
                case 'alerts':
                  dataToExport = provider.sensorHistory
                      .where((data) => data.isFireDetected)
                      .toList();
                  break;
                case 'normal':
                  dataToExport = provider.sensorHistory
                      .where((data) => !data.isFireDetected)
                      .toList();
                  break;
              }

              _exportHistory(dataToExport);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter history',
            onSelected: (value) {
              if (value == 'clear') {
                _showClearHistoryDialog();
              } else {
                setState(() {
                  _filterType = value;
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.list_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('All Records'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'alerts',
                child: Row(
                  children: [
                    Icon(Icons.warning_rounded, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Alerts Only'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'normal',
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text('Normal Only'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all_rounded, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear History'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<FireDetectionProvider>().refreshHistory();
            },
          ),
        ],
      ),
      body: Consumer<FireDetectionProvider>(
        builder: (context, provider, child) {
          // Filter the history based on selected filter
          List<dynamic> filteredHistory = provider.sensorHistory;

          switch (_filterType) {
            case 'alerts':
              filteredHistory = provider.sensorHistory
                  .where((data) => data.isFireDetected)
                  .toList();
              break;
            case 'normal':
              filteredHistory = provider.sensorHistory
                  .where((data) => !data.isFireDetected)
                  .toList();
              break;
            default:
              filteredHistory = provider.sensorHistory;
          }

          if (provider.isLoading && provider.sensorHistory.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            );
          }

          if (filteredHistory.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (_filterType == 'alerts'
                                    ? AppTheme.errorColor
                                    : _filterType == 'normal'
                                    ? AppTheme.primaryGreen
                                    : AppTheme.textSecondary)
                                .withOpacity(0.1),
                            (_filterType == 'alerts'
                                    ? AppTheme.errorColor
                                    : _filterType == 'normal'
                                    ? AppTheme.primaryGreen
                                    : AppTheme.textSecondary)
                                .withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _filterType == 'alerts'
                            ? Icons.warning_outlined
                            : _filterType == 'normal'
                            ? Icons.check_circle_outline
                            : Icons.history_rounded,
                        size: 72,
                        color:
                            (_filterType == 'alerts'
                                    ? AppTheme.errorColor
                                    : _filterType == 'normal'
                                    ? AppTheme.primaryGreen
                                    : AppTheme.textSecondary)
                                .withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _filterType == 'alerts'
                          ? 'No Fire Alerts Found'
                          : _filterType == 'normal'
                          ? 'No Normal Readings Found'
                          : 'No Detection History',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _filterType == 'alerts'
                          ? 'Great news! No fire incidents have been detected in your history.'
                          : _filterType == 'normal'
                          ? 'No normal readings found with current filter settings.'
                          : 'Start monitoring to see detection history here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            provider.refreshHistory();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                        if (_filterType != 'all') ...[
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _filterType = 'all';
                              });
                            },
                            icon: const Icon(Icons.clear_all_rounded, size: 18),
                            label: const Text('Show All'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshHistory(),
            color: AppTheme.primaryGreen,
            child: Column(
              children: [
                // Statistics header (based on filtered data)
                _buildHistoryStats(filteredHistory),

                // Filter status bar
                if (_filterType != 'all')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _filterType == 'alerts'
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _filterType == 'alerts'
                              ? Icons.warning_rounded
                              : Icons.check_circle_rounded,
                          size: 16,
                          color: _filterType == 'alerts'
                              ? Colors.red
                              : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Showing ${_filterType == 'alerts' ? 'fire alerts' : 'normal readings'} only (${filteredHistory.length} items)',
                          style: TextStyle(
                            fontSize: 12,
                            color: _filterType == 'alerts'
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _filterType = 'all';
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: _buildGroupedHistoryList(filteredHistory)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(
    dynamic sensorData,
    BuildContext context,
    bool isFirst,
  ) {
    final isAlert = sensorData.isFireDetected;
    final timeFormat = DateFormat('MMM dd, yyyy');
    final timeDetailFormat = DateFormat('HH:mm');
    final statusColor = isAlert ? AppTheme.errorColor : AppTheme.primaryGreen;
    final statusIcon = isAlert
        ? Icons.warning_rounded
        : Icons.check_circle_rounded;
    final statusText = isAlert ? 'Fire Detection Alert' : 'Normal Status';

    // Get relative time
    final now = DateTime.now();
    final difference = now.difference(sensorData.timestamp);
    String relativeTime;

    if (difference.inMinutes < 1) {
      relativeTime = 'Just now';
    } else if (difference.inMinutes < 60) {
      relativeTime = '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      relativeTime = '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      relativeTime = '${difference.inDays}d ago';
    } else {
      relativeTime = timeFormat.format(sensorData.timestamp);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Container(
            width: 60,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                // Status indicator with enhanced design
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor.withOpacity(0.8), statusColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(statusIcon, color: Colors.white, size: 24),
                ),
                // Timeline line
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 20,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.dividerColor,
                          AppTheme.dividerColor.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content card with enhanced design
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isAlert
                      ? AppTheme.errorColor.withOpacity(0.2)
                      : AppTheme.dividerColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isAlert
                        ? AppTheme.errorColor.withOpacity(0.08)
                        : AppTheme.shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with enhanced styling
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withOpacity(0.03),
                          statusColor.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: statusColor.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    sensorData.status.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Time information
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  relativeTime,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  timeDetailFormat.format(sensorData.timestamp),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Detection results with better layout
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Detection status grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildEnhancedSensorCard(
                                'Smoke',
                                sensorData.smokeDetected,
                                Icons.cloud_outlined,
                                isCompact: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildEnhancedSensorCard(
                                'Flame',
                                sensorData.flameDetected,
                                Icons.local_fire_department_outlined,
                                isCompact: true,
                              ),
                            ),
                          ],
                        ),

                        // Environmental data if available
                        if (sensorData.temperature != null ||
                            sensorData.humidity != null ||
                            sensorData.gasLevel != null) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Environmental Data',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildEnvironmentalDataGrid(sensorData),
                        ],

                        // Location if available
                        if (sensorData.latitude != null &&
                            sensorData.longitude != null) ...[
                          const SizedBox(height: 16),
                          _buildLocationInfo(
                            sensorData.latitude!,
                            sensorData.longitude!,
                          ),
                        ],

                        // AI Analysis with improved styling
                        if (sensorData.aiAnalysis != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryGreen.withOpacity(0.05),
                                  AppTheme.primaryGreen.withOpacity(0.02),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.primaryGreen.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGreen,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'AI Analysis',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  sensorData.aiAnalysis!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textPrimary,
                                    height: 1.5,
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

  Widget _buildEnhancedSensorCard(
    String label,
    bool isDetected,
    IconData icon, {
    bool isCompact = false,
  }) {
    final statusColor = isDetected
        ? AppTheme.errorColor
        : AppTheme.primaryGreen;
    final statusText = isDetected ? 'Detected' : 'Clear';

    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: isCompact ? 16 : 20,
                  color: Colors.white,
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (isCompact) ...[
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            statusText,
            style: TextStyle(
              fontSize: isCompact ? 14 : 16,
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalDataGrid(dynamic sensorData) {
    final List<Map<String, dynamic>> environmentalData = [];

    if (sensorData.temperature != null) {
      environmentalData.add({
        'label': 'Temperature',
        'value': '${sensorData.temperature!.toStringAsFixed(1)}°C',
        'icon': Icons.thermostat_outlined,
        'color': _getTemperatureColor(sensorData.temperature!),
      });
    }

    if (sensorData.humidity != null) {
      environmentalData.add({
        'label': 'Humidity',
        'value': '${sensorData.humidity!.toStringAsFixed(1)}%',
        'icon': Icons.water_drop_outlined,
        'color': _getHumidityColor(sensorData.humidity!),
      });
    }

    if (sensorData.gasLevel != null) {
      environmentalData.add({
        'label': 'Gas Level',
        'value': '${sensorData.gasLevel} ppm',
        'icon': Icons.air_outlined,
        'color': _getGasLevelColor(sensorData.gasLevel!),
      });
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: environmentalData
          .map(
            (data) => Container(
              constraints: const BoxConstraints(minWidth: 100),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: data['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: data['color'].withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(data['icon'], size: 18, color: data['color']),
                  const SizedBox(height: 6),
                  Text(
                    data['label'],
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data['value'],
                    style: TextStyle(
                      fontSize: 14,
                      color: data['color'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildLocationInfo(double latitude, double longitude) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 18,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature > 35) return AppTheme.errorColor;
    if (temperature > 30) return AppTheme.warningColor;
    if (temperature < 10) return Colors.blue;
    return AppTheme.primaryGreen;
  }

  Color _getHumidityColor(double humidity) {
    if (humidity > 80 || humidity < 20) return AppTheme.warningColor;
    return AppTheme.primaryGreen;
  }

  Color _getGasLevelColor(int gasLevel) {
    if (gasLevel > 400) return AppTheme.errorColor;
    if (gasLevel > 200) return AppTheme.warningColor;
    return AppTheme.primaryGreen;
  }

  Widget _buildHistoryStats(List<dynamic> history) {
    final totalRecords = history.length;
    final alertCount = history.where((data) => data.isFireDetected).length;
    final normalCount = totalRecords - alertCount;

    // Calculate percentage
    final alertPercentage = totalRecords > 0
        ? (alertCount / totalRecords * 100)
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, AppTheme.backgroundColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Detection Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Records',
                  value: '$totalRecords',
                  icon: Icons.list_alt_rounded,
                  color: AppTheme.textPrimary,
                  showTrend: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Fire Alerts',
                  value: '$alertCount',
                  icon: Icons.warning_rounded,
                  color: AppTheme.errorColor,
                  percentage: alertPercentage,
                  showTrend: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Normal',
                  value: '$normalCount',
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.primaryGreen,
                  percentage: totalRecords > 0
                      ? (normalCount / totalRecords * 100)
                      : 0.0,
                  showTrend: true,
                ),
              ),
            ],
          ),

          // Risk level indicator
          if (totalRecords > 0) ...[
            const SizedBox(height: 16),
            _buildRiskIndicator(alertPercentage),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    double? percentage,
    bool showTrend = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Spacer(),
              if (showTrend && percentage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator(double alertPercentage) {
    String riskLevel;
    Color riskColor;
    IconData riskIcon;

    if (alertPercentage >= 30) {
      riskLevel = 'High Risk';
      riskColor = AppTheme.errorColor;
      riskIcon = Icons.dangerous_rounded;
    } else if (alertPercentage >= 10) {
      riskLevel = 'Medium Risk';
      riskColor = AppTheme.warningColor;
      riskIcon = Icons.warning_rounded;
    } else {
      riskLevel = 'Low Risk';
      riskColor = AppTheme.primaryGreen;
      riskIcon = Icons.security_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(riskIcon, color: riskColor, size: 18),
          const SizedBox(width: 8),
          Text(
            'Risk Level: ',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            riskLevel,
            style: TextStyle(
              fontSize: 14,
              color: riskColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _exportHistory(List<dynamic> history) {
    if (history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    StringBuffer csv = StringBuffer();

    // CSV Header
    csv.writeln(
      'Timestamp,Temperature(°C),Humidity(%),Gas Level(ppm),Flame Detected,Status,Alert Level',
    );

    // CSV Data
    for (final data in history) {
      csv.writeln(
        '${dateFormat.format(data.timestamp)},'
        '${data.temperature?.toStringAsFixed(1) ?? 'N/A'},'
        '${data.humidity?.toStringAsFixed(1) ?? 'N/A'},'
        '${data.gasLevel ?? 'N/A'},'
        '${data.flameDetected ? 'Yes' : 'No'},'
        '${data.status},'
        '${data.isFireDetected ? 'ALERT' : 'NORMAL'}',
      );
    }

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: csv.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'History exported to clipboard (${history.length} records)',
        ),
        backgroundColor: AppTheme.primaryGreen,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Clear History'),
            ],
          ),
          content: const Text(
            'Are you sure you want to clear all detection history? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<FireDetectionProvider>(
                  context,
                  listen: false,
                ).clearHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('History cleared successfully'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGroupedHistoryList(List<dynamic> filteredHistory) {
    // Group history by date
    Map<String, List<dynamic>> groupedHistory = {};
    final dateFormat = DateFormat('MMM dd, yyyy');

    for (var item in filteredHistory) {
      final dateKey = dateFormat.format(item.timestamp);
      if (!groupedHistory.containsKey(dateKey)) {
        groupedHistory[dateKey] = [];
      }
      groupedHistory[dateKey]!.add(item);
    }

    // Sort dates in descending order
    final sortedDates = groupedHistory.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMM dd, yyyy').parse(a);
        final dateB = DateFormat('MMM dd, yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dayHistory = groupedHistory[date]!;

        // Sort items within each day by time (newest first)
        dayHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            _buildDateHeader(date, dayHistory),

            // History items for this date
            ...dayHistory.asMap().entries.map((entry) {
              final itemIndex = entry.key;
              final data = entry.value;
              return _buildHistoryItem(data, context, itemIndex == 0);
            }).toList(),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(String date, List<dynamic> dayHistory) {
    final alertCount = dayHistory.where((data) => data.isFireDetected).length;

    // Determine if this is today, yesterday, etc.
    final now = DateTime.now();
    final headerDate = DateFormat('MMM dd, yyyy').parse(date);
    final difference = now.difference(headerDate).inDays;

    String displayDate;
    if (difference == 0) {
      displayDate = 'Today';
    } else if (difference == 1) {
      displayDate = 'Yesterday';
    } else if (difference < 7) {
      displayDate = '${difference} days ago';
    } else {
      displayDate = date;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.dividerColor, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    displayDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  // Summary for the day
                  if (alertCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.errorColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$alertCount alert${alertCount > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${dayHistory.length} total',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
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
}
