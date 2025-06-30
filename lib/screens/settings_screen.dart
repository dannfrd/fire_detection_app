import 'package:flutter/material.dart';

import '../screens/contact_support_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/terms_of_service_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
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
                      value ? 'Fire alerts enabled' : 'Fire alerts disabled'
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
                      value ? 'Warning alerts enabled' : 'Warning alerts disabled'
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
                      value ? 'System updates enabled' : 'System updates disabled'
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
                      value ? 'Location display enabled' : 'Location display disabled'
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
                      value ? 'Map auto-refresh enabled' : 'Map auto-refresh disabled'
                    );
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
                      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
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
                      MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
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
                      MaterialPageRoute(builder: (context) => const ContactSupportScreen()),
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
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
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
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
      ),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryGreen,
        ),
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
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryGreen,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Helper methods for implementing the functionality
  void _saveNotificationSettings() async {
    // Here you would typically use shared preferences or another storage mechanism
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('fireAlertsEnabled', _fireAlertsEnabled);
    // await prefs.setBool('warningAlertsEnabled', _warningAlertsEnabled);
    // await prefs.setBool('systemUpdatesEnabled', _systemUpdatesEnabled);
    
    // For demonstration, we're just printing the values
    debugPrint('Saving notification settings:');
    debugPrint('Fire Alerts: $_fireAlertsEnabled');
    debugPrint('Warning Alerts: $_warningAlertsEnabled');
    debugPrint('System Updates: $_systemUpdatesEnabled');
  }

  void _saveMapSettings() async {
    // Similar to notification settings, you would save these to persistent storage
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('showMyLocation', _showMyLocationEnabled);
    // await prefs.setBool('autoRefreshMap', _autoRefreshMapEnabled);
    
    debugPrint('Saving map settings:');
    debugPrint('Show My Location: $_showMyLocationEnabled');
    debugPrint('Auto-refresh Map: $_autoRefreshMapEnabled');
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

  Future<void> _loadSavedSettings() async {
    // Here you would typically load settings from shared preferences
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   _fireAlertsEnabled = prefs.getBool('fireAlertsEnabled') ?? true;
    //   _warningAlertsEnabled = prefs.getBool('warningAlertsEnabled') ?? true;
    //   _systemUpdatesEnabled = prefs.getBool('systemUpdatesEnabled') ?? false;
    //   _showMyLocationEnabled = prefs.getBool('showMyLocation') ?? true;
    //   _autoRefreshMapEnabled = prefs.getBool('autoRefreshMap') ?? true;
    // });
    
    // For now, we'll use the default values
    // This is already done in the class field initialization
    debugPrint('Settings loaded');
  }
}
