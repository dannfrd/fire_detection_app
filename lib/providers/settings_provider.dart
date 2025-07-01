import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FireDetectionSettings with ChangeNotifier {
  // Notification settings
  bool _fireAlertsEnabled = true;
  bool _warningAlertsEnabled = true;
  bool _systemUpdatesEnabled = false;

  // Gas level thresholds with default values
  double _warningThreshold = 1000.0;
  double _criticalThreshold = 2000.0;
  double _temperatureThreshold = 40.0;

  // Threshold range settings for UI components
  final double _minWarningThreshold = 500.0;
  final double _maxWarningThreshold = 1500.0;
  final double _minCriticalThreshold = 1500.0;
  final double _maxCriticalThreshold = 3000.0;
  final double _minTemperatureThreshold = 30.0;
  final double _maxTemperatureThreshold = 60.0;

  // Getters
  bool get fireAlertsEnabled => _fireAlertsEnabled;
  bool get warningAlertsEnabled => _warningAlertsEnabled;
  bool get systemUpdatesEnabled => _systemUpdatesEnabled;
  double get warningThreshold => _warningThreshold;
  double get criticalThreshold => _criticalThreshold;
  double get temperatureThreshold => _temperatureThreshold;

  // Getters for threshold range settings
  double get minWarningThreshold => _minWarningThreshold;
  double get maxWarningThreshold => _maxWarningThreshold;
  double get minCriticalThreshold => _minCriticalThreshold;
  double get maxCriticalThreshold => _maxCriticalThreshold;
  double get minTemperatureThreshold => _minTemperatureThreshold;
  double get maxTemperatureThreshold => _maxTemperatureThreshold;

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

      // Load threshold settings
      _warningThreshold =
          prefs.getDouble('warningThreshold') ??
          _minWarningThreshold +
              (_maxWarningThreshold - _minWarningThreshold) / 2;
      _criticalThreshold =
          prefs.getDouble('criticalThreshold') ??
          _minCriticalThreshold +
              (_maxCriticalThreshold - _minCriticalThreshold) / 2;
      _temperatureThreshold =
          prefs.getDouble('temperatureThreshold') ??
          _minTemperatureThreshold +
              (_maxTemperatureThreshold - _minTemperatureThreshold) / 4;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  // Reset to default threshold values
  Future<void> resetThresholds() async {
    _warningThreshold =
        _minWarningThreshold +
        (_maxWarningThreshold - _minWarningThreshold) / 2;
    _criticalThreshold =
        _minCriticalThreshold +
        (_maxCriticalThreshold - _minCriticalThreshold) / 2;
    _temperatureThreshold =
        _minTemperatureThreshold +
        (_maxTemperatureThreshold - _minTemperatureThreshold) / 4;

    await _saveThresholdSettings();
    notifyListeners();
  }

  // Check if sensor data exceeds thresholds
  AlertLevel checkAlertLevel(double gasLevel, double temperature) {
    if (gasLevel >= _criticalThreshold) {
      return AlertLevel.critical;
    } else if (gasLevel >= _warningThreshold) {
      return AlertLevel.warning;
    } else if (temperature >= _temperatureThreshold) {
      return AlertLevel.temperature;
    } else {
      return AlertLevel.normal;
    }
  }

  // Check if notification should be shown based on alert level and settings
  bool shouldShowNotification(AlertLevel level) {
    switch (level) {
      case AlertLevel.critical:
        return _fireAlertsEnabled;
      case AlertLevel.warning:
        return _warningAlertsEnabled;
      case AlertLevel.temperature:
        return _warningAlertsEnabled;
      case AlertLevel.normal:
        return false;
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

  Future<void> setThresholds({
    double? warningThreshold,
    double? criticalThreshold,
    double? temperatureThreshold,
  }) async {
    bool changed = false;

    if (warningThreshold != null && warningThreshold != _warningThreshold) {
      _warningThreshold = warningThreshold;
      changed = true;
    }

    if (criticalThreshold != null && criticalThreshold != _criticalThreshold) {
      _criticalThreshold = criticalThreshold;
      changed = true;
    }

    if (temperatureThreshold != null &&
        temperatureThreshold != _temperatureThreshold) {
      _temperatureThreshold = temperatureThreshold;
      changed = true;
    }

    if (changed) {
      await _saveThresholdSettings();
      notifyListeners();
    }
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

// Enum for alert levels
enum AlertLevel { normal, warning, temperature, critical }
