import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/mqtt_config_provider.dart';
import '../screens/contact_support_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/terms_of_service_screen.dart';
import '../screens/mqtt_config_screen.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State variables for switches
  bool _fireAlertsEnabled = true;
  bool _warningAlertsEnabled = true;
  bool _systemUpdatesEnabled = false;
  bool _showMyLocationEnabled = true;
  bool _autoRefreshMapEnabled = true;

  // Gas level thresholds
  double _warningThreshold = 1000;
  double _criticalThreshold = 2000;
  double _temperatureThreshold = 40;

  // Reference to the settings provider
  late FireDetectionSettings _settingsProvider;

  @override
  void initState() {
    super.initState();
    // Settings will be loaded from the provider
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get settings provider
    _settingsProvider = Provider.of<FireDetectionSettings>(context);
    // Update local state from provider
    _updateLocalStateFromProvider();
  }

  void _updateLocalStateFromProvider() {
    setState(() {
      _fireAlertsEnabled = _settingsProvider.fireAlertsEnabled;
      _warningAlertsEnabled = _settingsProvider.warningAlertsEnabled;
      _systemUpdatesEnabled = _settingsProvider.systemUpdatesEnabled;
      _showMyLocationEnabled = _settingsProvider.showMyLocationEnabled;
      _autoRefreshMapEnabled = _settingsProvider.autoRefreshMapEnabled;
      _warningThreshold = _settingsProvider.warningThreshold;
      _criticalThreshold = _settingsProvider.criticalThreshold;
      _temperatureThreshold = _settingsProvider.temperatureThreshold;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Information Card
          // Alert Thresholds Section
          _buildSectionHeader('Alert Thresholds'),
          _buildThresholdsCard(),

          const SizedBox(height: 20),

          _buildSectionHeader('App Information'),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppTheme.primaryGreen,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Agrotech Fire Detection',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.blue,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This app helps detect and monitor potential fire risks in agricultural environments.',
                          style: TextStyle(color: Colors.blue, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Notification Settings
          _buildSectionHeader('Notification Settings'),
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
            child: Column(
              children: [
                _buildSwitchTile(
                  'Fire Alerts',
                  'Receive notifications for fire detections',
                  Icons.notifications_active_rounded,
                  _fireAlertsEnabled,
                  (value) {
                    setState(() {
                      _fireAlertsEnabled = value;
                    });
                    _saveNotificationSettings();
                    _showSettingUpdatedSnackbar(
                      value ? 'Fire alerts enabled' : 'Fire alerts disabled',
                    );
                  },
                ),
                const Divider(height: 1, indent: 70),
                _buildSwitchTile(
                  'Warning Alerts',
                  'Receive notifications for potential risks',
                  Icons.warning_amber_rounded,
                  _warningAlertsEnabled,
                  (value) {
                    setState(() {
                      _warningAlertsEnabled = value;
                    });
                    _saveNotificationSettings();
                    _showSettingUpdatedSnackbar(
                      value
                          ? 'Warning alerts enabled'
                          : 'Warning alerts disabled',
                    );
                  },
                ),
                const Divider(height: 1, indent: 70),
                _buildSwitchTile(
                  'System Updates',
                  'Receive notifications about system status',
                  Icons.system_update_rounded,
                  _systemUpdatesEnabled,
                  (value) {
                    setState(() {
                      _systemUpdatesEnabled = value;
                    });
                    _saveNotificationSettings();
                    _showSettingUpdatedSnackbar(
                      value
                          ? 'System updates enabled'
                          : 'System updates disabled',
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Map Settings
          _buildSectionHeader('Map Settings'),
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
            child: Column(
              children: [
                _buildSwitchTile(
                  'Show My Location',
                  'Display your current location on the map',
                  Icons.my_location_rounded,
                  _showMyLocationEnabled,
                  (value) {
                    setState(() {
                      _showMyLocationEnabled = value;
                    });
                    _saveMapSettings();
                    _showSettingUpdatedSnackbar(
                      value
                          ? 'Location display enabled'
                          : 'Location display disabled',
                    );
                  },
                ),
                const Divider(height: 1, indent: 70),
                _buildSwitchTile(
                  'Auto-refresh Map',
                  'Automatically update map data',
                  Icons.refresh_rounded,
                  _autoRefreshMapEnabled,
                  (value) {
                    setState(() {
                      _autoRefreshMapEnabled = value;
                    });
                    _saveMapSettings();
                    _showSettingUpdatedSnackbar(
                      value
                          ? 'Map auto-refresh enabled'
                          : 'Map auto-refresh disabled',
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // MQTT Configuration Section
          _buildSectionHeader('Connection'),
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
            child: Column(
              children: [
                Consumer<MqttConfigProvider>(
                  builder: (context, mqttConfig, child) {
                    return _buildListTileWithCustomTrailing(
                      'MQTT Configuration',
                      mqttConfig.isConfigured
                          ? 'Host: ${mqttConfig.host}:${mqttConfig.port}'
                          : 'Configure MQTT connection',
                      Icons.settings_ethernet_rounded,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MqttConfigScreen(),
                          ),
                        );
                      },
                      mqttConfig.isConfigured
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            )
                          : Icon(Icons.warning, color: Colors.orange, size: 20),
                    );
                  },
                ),
                const Divider(height: 1, indent: 70),
                _buildListTile(
                  'Reset MQTT Settings',
                  'Clear all MQTT configuration',
                  Icons.refresh_rounded,
                  () {
                    _showResetMqttConfirmation();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About'),
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
            child: Column(
              children: [
                _buildListTile(
                  'Privacy Policy',
                  'View our privacy policy',
                  Icons.privacy_tip_rounded,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 70),
                _buildListTile(
                  'Terms of Service',
                  'View our terms of service',
                  Icons.description_rounded,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsOfServiceScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 70),
                _buildListTile(
                  'Contact Support',
                  'Get help with the app',
                  Icons.support_agent_rounded,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactSupportScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // App version footer
          const Center(
            child: Text(
              '© 2025 Agrotech Fire Detection',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool initialValue,
    Function(bool) onChanged,
  ) {
    return SwitchListTile.adaptive(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
      ),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryGreen),
      ),
      value: initialValue,
      onChanged: onChanged,
      activeColor: AppTheme.primaryGreen,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryGreen),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildThresholdsCard() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gas Level Thresholds',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // Reset button
                IconButton(
                  onPressed: _resetThresholdSettings,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  tooltip: 'Reset to default values',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Adjust when alerts should be triggered based on gas level readings.',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),

            // Warning level slider
            _buildLabeledSlider(
              label: 'Warning Level',
              value: _warningThreshold,
              min: 500,
              max: 1500,
              divisions: 10,
              activeColor: Colors.orange,
              valueLabel: '${_warningThreshold.toInt()} ppm',
              onChanged: (value) {
                setState(() {
                  _warningThreshold = value;
                  // Ensure critical is always higher than warning
                  if (_criticalThreshold < _warningThreshold + 300) {
                    _criticalThreshold = _warningThreshold + 300;
                  }
                });
              },
            ),

            const SizedBox(height: 16),

            // Critical level slider
            _buildLabeledSlider(
              label: 'Critical Level',
              value: _criticalThreshold,
              min: 1500,
              max: 3000,
              divisions: 15,
              activeColor: Colors.red,
              valueLabel: '${_criticalThreshold.toInt()} ppm',
              onChanged: (value) {
                setState(() {
                  _criticalThreshold = value;
                });
              },
            ),

            const Divider(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Temperature Threshold',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // Info icon with tooltip
                Tooltip(
                  message:
                      'Temperature above this level may indicate fire risk',
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: const Duration(seconds: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(color: Colors.white),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Temperature above this level may indicate fire risk.',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),

            // Temperature threshold slider
            _buildLabeledSlider(
              label: 'High Temperature',
              value: _temperatureThreshold,
              min: 30,
              max: 60,
              divisions: 30,
              activeColor: Colors.deepOrange,
              valueLabel: '${_temperatureThreshold.toInt()}°C',
              onChanged: (value) {
                setState(() {
                  _temperatureThreshold = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Save button
            ElevatedButton(
              onPressed: _saveThresholdSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save Threshold Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Color activeColor,
    required String valueLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: activeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: activeColor.withOpacity(0.3)),
              ),
              child: Text(
                valueLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            inactiveTrackColor: activeColor.withOpacity(0.2),
            thumbColor: activeColor,
            overlayColor: activeColor.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: valueLabel,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _saveNotificationSettings() async {
    try {
      await _settingsProvider.setFireAlertsEnabled(_fireAlertsEnabled);
      await _settingsProvider.setWarningAlertsEnabled(_warningAlertsEnabled);
      await _settingsProvider.setSystemUpdatesEnabled(_systemUpdatesEnabled);

      debugPrint('Notification settings saved successfully via provider');
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  void _saveMapSettings() async {
    try {
      await _settingsProvider.setShowMyLocationEnabled(_showMyLocationEnabled);
      await _settingsProvider.setAutoRefreshMapEnabled(_autoRefreshMapEnabled);

      debugPrint('Map settings saved successfully via provider');
    } catch (e) {
      debugPrint('Error saving map settings: $e');
    }
  }

  void _showSettingUpdatedSnackbar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _saveThresholdSettings() async {
    try {
      await _settingsProvider.setThresholds(
        warningThreshold: _warningThreshold,
        criticalThreshold: _criticalThreshold,
        temperatureThreshold: _temperatureThreshold,
      );

      debugPrint('Threshold settings saved successfully via provider');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Threshold settings saved'),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error saving threshold settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _resetThresholdSettings() {
    setState(() {
      _warningThreshold = 1000.0;
      _criticalThreshold = 2000.0;
      _temperatureThreshold = 40.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Threshold settings reset to default values'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildListTileWithCustomTrailing(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    Widget trailing,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryGreen),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _showResetMqttConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset MQTT Configuration'),
          content: const Text(
            'Are you sure you want to reset all MQTT settings? This will clear your broker configuration and you will need to set it up again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final mqttConfig = Provider.of<MqttConfigProvider>(
                  context,
                  listen: false,
                );
                await mqttConfig.resetConfig();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('MQTT configuration has been reset'),
                      backgroundColor: AppTheme.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}
