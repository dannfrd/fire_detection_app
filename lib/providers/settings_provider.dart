import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FireDetectionSettings with ChangeNotifier {
  // Notification settings
  bool _fireAlertsEnabled = true;
  bool _warningAlertsEnabled = true;
  bool _systemUpdatesEnabled = false;
  
  // Map settings
  bool _showMyLocationEnabled = true;
  bool _autoRefreshMapEnabled = true;
  
  // Gas level thresholds
  double _warningThreshold = 1000.0;
  double _criticalThreshold = 2000.0;
  double _temperatureThreshold = 40.0;
  
  // Getters
  bool get fireAlertsEnabled => _fireAlertsEnabled;
  bool get warningAlertsEnabled => _warningAlertsEnabled;
  bool get systemUpdatesEnabled => _systemUpdatesEnabled;
  bool get showMyLocationEnabled => _showMyLocationEnabled;
  bool get autoRefreshMapEnabled => _autoRefreshMapEnabled;
  double get warningThreshold => _warningThreshold;
  double get criticalThreshold => _criticalThreshold;
  double get temperatureThreshold => _temperatureThreshold;
  
  // Constructor
  FireDetectionSettings() {
    loadSettings();
  }
  
  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load notification settings
      _fireAlertsEnabled = prefs.getBool('fireAlertsEnabled') ?? true;
      _warningAlertsEnabled = prefs.getBool('warningAlertsEnabled') ?? true;
      _systemUpdatesEnabled = prefs.getBool('systemUpdatesEnabled') ?? false;
      
      // Load map settings
      _showMyLocationEnabled = prefs.getBool('showMyLocation') ?? true;
      _autoRefreshMapEnabled = prefs.getBool('autoRefreshMap') ?? true;
      
      // Load threshold settings
      _warningThreshold = prefs.getDouble('warningThreshold') ?? 1000.0;
      _criticalThreshold = prefs.getDouble('criticalThreshold') ?? 2000.0;
      _temperatureThreshold = prefs.getDouble('temperatureThreshold') ?? 40.0;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }
  
  // Setters with save functionality
  Future<void> setFireAlertsEnabled(bool value) async {
    _fireAlertsEnabled = value;
    await _saveNotificationSettings();
    notifyListeners();
  }
  
  Future<void> setWarningAlertsEnabled(bool value) async {
    _warningAlertsEnabled = value;
    await _saveNotificationSettings();
    notifyListeners();
  }
  
  Future<void> setSystemUpdatesEnabled(bool value) async {
    _systemUpdatesEnabled = value;
    await _saveNotificationSettings();
    notifyListeners();
  }
  
  Future<void> setShowMyLocationEnabled(bool value) async {
    _showMyLocationEnabled = value;
    await _saveMapSettings();
    notifyListeners();
  }
  
  Future<void> setAutoRefreshMapEnabled(bool value) async {
    _autoRefreshMapEnabled = value;
    await _saveMapSettings();
    notifyListeners();
  }
  
  Future<void> setThresholds({
    double? warningThreshold,
    double? criticalThreshold,
    double? temperatureThreshold,
  }) async {
    if (warningThreshold != null) _warningThreshold = warningThreshold;
    if (criticalThreshold != null) _criticalThreshold = criticalThreshold;
    if (temperatureThreshold != null) _temperatureThreshold = temperatureThreshold;
    
    await _saveThresholdSettings();
    notifyListeners();
  }
  
  // Private save methods
  Future<void> _saveNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('fireAlertsEnabled', _fireAlertsEnabled);
      await prefs.setBool('warningAlertsEnabled', _warningAlertsEnabled);
      await prefs.setBool('systemUpdatesEnabled', _systemUpdatesEnabled);
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }
  
  Future<void> _saveMapSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('showMyLocation', _showMyLocationEnabled);
      await prefs.setBool('autoRefreshMap', _autoRefreshMapEnabled);
    } catch (e) {
      debugPrint('Error saving map settings: $e');
    }
  }
  
  Future<void> _saveThresholdSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('warningThreshold', _warningThreshold);
      await prefs.setDouble('criticalThreshold', _criticalThreshold);
      await prefs.setDouble('temperatureThreshold', _temperatureThreshold);
    } catch (e) {
      debugPrint('Error saving threshold settings: $e');
    }
  }
}
