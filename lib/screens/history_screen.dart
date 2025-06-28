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
        title: const Text('Detection History'),
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
          if (provider.isLoading && provider.sensorHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.sensorHistory.isEmpty) {
            return const Center(
              child: Text(
                'No detection history available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refreshData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.sensorHistory.length,
              itemBuilder: (context, index) {
                final data = provider.sensorHistory[index];
                return _buildChatBubble(data);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatBubble(dynamic sensorData) {
    final isAlert = sensorData.isFireDetected;
    final timeFormat = DateFormat('MMM dd, HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor:
                isAlert ? AppTheme.errorColor : AppTheme.primaryGreen,
            child: Icon(
              isAlert ? Icons.warning : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAlert
                        ? AppTheme.errorColor.withOpacity(0.1)
                        : AppTheme.lightGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isAlert ? AppTheme.errorColor : AppTheme.lightGreen,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAlert ? 'Fire Detection Alert' : 'Normal Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isAlert
                              ? AppTheme.errorColor
                              : AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Smoke: ${sensorData.smokeDetected ? "Detected" : "Clear"}\n'
                        'Flame: ${sensorData.flameDetected ? "Detected" : "Clear"}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (sensorData.aiAnalysis != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AI Analysis:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sensorData.aiAnalysis!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeFormat.format(sensorData.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
