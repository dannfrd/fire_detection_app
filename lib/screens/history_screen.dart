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
                    Icon(Icons.check_circle_rounded, size: 20, color: Colors.green),
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
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            );
          }

          if (filteredHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _filterType == 'alerts' 
                        ? Icons.warning_outlined
                        : _filterType == 'normal'
                        ? Icons.check_circle_outline
                        : Icons.history_rounded,
                    size: 72,
                    color: AppTheme.textSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _filterType == 'alerts'
                        ? 'No fire alerts in history'
                        : _filterType == 'normal'
                        ? 'No normal readings in history'
                        : 'No detection history available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.refreshHistory();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshHistory(),
            color: AppTheme.primaryGreen,
            child: Column(
              children: [
                // Statistics header
                _buildHistoryStats(provider.sensorHistory),
                
                // Filter status bar
                if (_filterType != 'all')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: 8
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
                // Statistics header
                _buildHistoryStats(filteredHistory),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final data = filteredHistory[index];
                      return _buildHistoryItem(data, context, index == 0);
                    },
                  ),
                ),
              ],
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

  Widget _buildHistoryStats(List<dynamic> history) {
    final totalRecords = history.length;
    final alertCount = history.where((data) => data.isFireDetected).length;
    final normalCount = totalRecords - alertCount;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '$totalRecords',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Text(
                  'Total Records',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$alertCount',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const Text(
                  'Fire Alerts',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$normalCount',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const Text(
                  'Normal',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
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
    csv.writeln('Timestamp,Temperature(°C),Humidity(%),Gas Level(ppm),Flame Detected,Status,Alert Level');
    
    // CSV Data
    for (final data in history) {
      csv.writeln('${dateFormat.format(data.timestamp)},'
          '${data.temperature?.toStringAsFixed(1) ?? 'N/A'},'
          '${data.humidity?.toStringAsFixed(1) ?? 'N/A'},'
          '${data.gasLevel ?? 'N/A'},'
          '${data.flameDetected ? 'Yes' : 'No'},'
          '${data.status},'
          '${data.isFireDetected ? 'ALERT' : 'NORMAL'}');
    }
    
    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: csv.toString()));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('History exported to clipboard (${history.length} records)'),
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
                Provider.of<FireDetectionProvider>(context, listen: false)
                    .clearHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('History cleared successfully'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
