import 'dart:async';

import 'package:flutter/material.dart';

import '../models/sensor_data.dart';
import '../services/api_service.dart';

class FireDetectionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Timer? _timer;

  SensorData? _currentSensorData;
  List<SensorData> _sensorHistory = [];
  List<FireLocation> _fireLocations = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  SensorData? get currentSensorData => _currentSensorData;
  List<SensorData> get sensorHistory => _sensorHistory;
  List<FireLocation> get fireLocations => _fireLocations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FireDetectionProvider() {
    _startPeriodicFetch();
  }

  void _startPeriodicFetch() {
    _fetchAllData();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchCurrentSensorData();
    });
  }

  Future<void> _fetchAllData() async {
    _setLoading(true);
    await Future.wait([
      _fetchCurrentSensorData(),
      _fetchSensorHistory(),
      _fetchFireLocations(),
    ]);
    _setLoading(false);
  }

  Future<void> _fetchCurrentSensorData() async {
    try {
      final data = await _apiService.getCurrentSensorData();
      if (data != null) {
        _currentSensorData = data;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to fetch sensor data';
      notifyListeners();
    }
  }

  Future<void> _fetchSensorHistory() async {
    try {
      final history = await _apiService.getSensorHistory();
      _sensorHistory = history;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch sensor history';
      notifyListeners();
    }
  }

  Future<void> _fetchFireLocations() async {
    try {
      final locations = await _apiService.getFireLocations();
      _fireLocations = locations;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch fire locations';
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _fetchAllData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
