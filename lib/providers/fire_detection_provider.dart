import 'dart:async';

import 'package:flutter/material.dart';

import '../models/sensor_data.dart';
import '../services/api_service.dart';
import '../services/mqtt_service.dart';

class FireDetectionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final MqttService _mqttService = MqttService();
  
  StreamSubscription? _mqttSubscription;
  Timer? _periodicFetchTimer;

  SensorData? _currentSensorData;
  List<SensorData> _sensorHistory = [];
  List<FireLocation> _fireLocations = [];
  bool _isLoading = false;
  String? _error;
  bool _isMqttConnected = false;

  // Getters
  SensorData? get currentSensorData => _currentSensorData;
  List<SensorData> get sensorHistory => _sensorHistory;
  List<FireLocation> get fireLocations => _fireLocations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isMqttConnected => _isMqttConnected;

  FireDetectionProvider() {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _setLoading(true);
    
    // Connect to MQTT
    await _connectToMqtt();
    
    // If no MQTT or as a fallback, use API
    if (!_isMqttConnected) {
      _startPeriodicFetch();
    }
    
    // Get initial history and locations data
    await Future.wait([
      _fetchSensorHistory(),
      _fetchFireLocations(),
    ]);
    
    _setLoading(false);
  }

  Future<void> _connectToMqtt() async {
    try {
      _isMqttConnected = await _mqttService.connect();
      
      if (_isMqttConnected) {
        print('Successfully connected to MQTT');
        // Listen to sensor data stream
        _mqttSubscription = _mqttService.sensorDataStream.listen(
          (sensorData) {
            _currentSensorData = sensorData;
            
            // Add to history if it's a new reading
            if (_sensorHistory.isEmpty || 
                _sensorHistory.first.timestamp != sensorData.timestamp) {
              _sensorHistory.insert(0, sensorData);
              
              // Keep history to a reasonable size
              if (_sensorHistory.length > 50) {
                _sensorHistory = _sensorHistory.sublist(0, 50);
              }
            }
            
            // Check if fire is detected and update fire locations
            if (sensorData.isFireDetected && sensorData.latitude != null && 
                sensorData.longitude != null) {
              _updateFireLocations(sensorData);
            }
            
            // Clear any previous errors
            _error = null;
            notifyListeners();
          },
          onError: (error) {
            _error = 'Error receiving MQTT data: $error';
            notifyListeners();
          },
        );
      } else {
        _error = 'Failed to connect to MQTT broker';
        notifyListeners();
      }
    } catch (e) {
      print('MQTT connection error: $e');
      _error = 'Failed to connect to MQTT: $e';
      _isMqttConnected = false;
      notifyListeners();
    }
  }

  void _updateFireLocations(SensorData sensorData) {
    // Create a new fire location from sensor data
    final newLocation = FireLocation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      latitude: sensorData.latitude!,
      longitude: sensorData.longitude!,
      timestamp: sensorData.timestamp,
      severity: sensorData.status,
      temperature: sensorData.temperature,
      humidity: sensorData.humidity,
      gasLevel: sensorData.gasLevel,
    );
    
    // Add to locations if not already present
    if (!_fireLocations.any((loc) => 
        loc.latitude == newLocation.latitude && 
        loc.longitude == newLocation.longitude)) {
      _fireLocations.add(newLocation);
      notifyListeners();
    }
  }

  void _startPeriodicFetch() {
    _fetchCurrentSensorData();
    _periodicFetchTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchCurrentSensorData();
    });
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
    _setLoading(true);
    
    if (_isMqttConnected) {
      // For MQTT, we can just wait for new data to arrive
      // But we can refresh history and locations data from API
      await Future.wait([
        _fetchSensorHistory(),
        _fetchFireLocations(),
      ]);
    } else {
      // For API, fetch all data
      await Future.wait([
        _fetchCurrentSensorData(),
        _fetchSensorHistory(),
        _fetchFireLocations(),
      ]);
    }
    
    _setLoading(false);
  }

  @override
  void dispose() {
    try {
      _mqttSubscription?.cancel();
      _periodicFetchTimer?.cancel();
      _mqttService.disconnect();
    } catch (e) {
      print('Error during disposal: $e');
    }
    super.dispose();
  }
}
