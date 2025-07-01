import 'dart:async';
import 'dart:math';

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
    } else {
      // Skip API calls if MQTT is connected to avoid HTML error
      print('MQTT connected, skipping API calls');
    }
    
    _setLoading(false);
  }

  Future<void> _connectToMqtt() async {
    try {
      print('Attempting to connect to MQTT...');
      _isMqttConnected = await _mqttService.connect();
      
      if (_isMqttConnected) {
        print('Successfully connected to MQTT broker');
        
        // Set up the MQTT data stream subscription
        _setupMqttSubscription();
        
        // Periodically check MQTT connection
        _startMqttConnectionChecker();
      } else {
        print('Failed to connect to MQTT broker');
        _error = 'Could not connect to MQTT server. Using API fallback.';
        notifyListeners();
      }
    } catch (e) {
      print('MQTT connection error: $e');
      _error = 'MQTT connection error: $e';
      _isMqttConnected = false;
      notifyListeners();
    }
  }

  void _setupMqttSubscription() {
    // Cancel any existing subscription first
    _mqttSubscription?.cancel();
    
    // Listen to sensor data stream
    _mqttSubscription = _mqttService.sensorDataStream.listen(
      (sensorData) {
        print('=== PROVIDER RECEIVED DATA ===');
        print('Gas Level: ${sensorData.gasLevel} ppm');
        print('Smoke: ${sensorData.smokeDetected}');
        print('Flame: ${sensorData.flameDetected}');
        print('Temperature: ${sensorData.temperature}°C');
        print('Timestamp: ${sensorData.timestamp}');
        print('============================');
        
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
        print('MQTT stream error: $error');
        _error = 'Error receiving MQTT data: $error';
        notifyListeners();
      },
      onDone: () {
        print('MQTT stream closed');
        // Try to reconnect
        _reconnectToMqtt();
      },
    );
  }
  
  // Add a connection checker that periodically verifies MQTT connection
  Timer? _mqttConnectionCheckTimer;
  
  void _startMqttConnectionChecker() {
    _mqttConnectionCheckTimer?.cancel();
    _mqttConnectionCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      final isConnected = _mqttService.isConnected;
      
      if (!isConnected && _isMqttConnected) {
        print('MQTT connection lost, attempting to reconnect...');
        _reconnectToMqtt();
      } else if (isConnected && !_isMqttConnected) {
        // Update state if we're connected but the state doesn't reflect it
        _isMqttConnected = true;
        notifyListeners();
      }
    });
  }
  
  Future<void> _reconnectToMqtt() async {
    try {
      print('Attempting to reconnect to MQTT...');
      final wasConnected = _isMqttConnected;
      _isMqttConnected = await _mqttService.ensureConnected();
      
      if (_isMqttConnected) {
        print('Successfully reconnected to MQTT');
        if (!wasConnected) {
          // Only set up subscription if we weren't connected before
          _setupMqttSubscription();
          notifyListeners();
        }
      } else if (wasConnected) {
        // Only update state and start API fallback if state changed
        print('Failed to reconnect to MQTT, switching to API');
        _isMqttConnected = false;
        _startPeriodicFetch();
        notifyListeners();
      }
    } catch (e) {
      print('Error reconnecting to MQTT: $e');
      if (_isMqttConnected) {
        _isMqttConnected = false;
        _startPeriodicFetch();
        notifyListeners();
      }
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
      print('API fetch error: $e');
      // Don't set error for API issues when MQTT is working
      if (!_isMqttConnected) {
        _error = 'Failed to fetch sensor data from API';
        notifyListeners();
      }
    }
  }
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> refreshData() async {
    _setLoading(true);
    _error = null;
    
    // First, try to ensure MQTT connection is active
    if (!_isMqttConnected) {
      await _reconnectToMqtt();
    }
    
    if (_isMqttConnected) {
      print('Using MQTT for real-time data');
      // For MQTT, we can publish a request for fresh data
      try {
        _mqttService.publishMessage('kelompok4/commands', 'request_data');
        _mqttService.publishMessage('kelompok4', 'refresh');
        _mqttService.publishMessage('kelompok4/commands/refresh', 'request_data');
        print('Published refresh requests to MQTT');
      } catch (e) {
        print('Error publishing refresh command: $e');
      }
      
      // Skip API calls when MQTT is connected to avoid HTML errors
      print('Skipping API calls since MQTT is connected');
    } else {
      print('Using API for data (MQTT not connected)');
      // For API, fetch sensor data only, skip history to avoid HTML errors
      try {
        await _fetchCurrentSensorData();
      } catch (e) {
        print('API error (expected if server is offline): $e');
        _error = 'MQTT disconnected and API server unavailable. Using simulation mode.';
      }
    }
    
    _setLoading(false);
  }

  // For testing: simulate receiving MQTT data with more realistic scenarios
  void simulateMqttData() {
    final random = Random();
    
    // Generate more realistic sensor values matching ESP32 ADC range (0-4095)
    // MQ-135 typically shows values around 100-300 in clean air, 1000+ for gas detection
    final baseGasLevel = _currentSensorData?.gasLevel ?? 800;
    // Generate values between -400 and +400 from base, with ESP32 ADC range in mind
    final newGasLevel = (baseGasLevel + (random.nextInt(800) - 400)).clamp(100, 4000);
    
    final baseTemp = _currentSensorData?.temperature ?? 28.0;
    final newTemp = (baseTemp + (random.nextDouble() * 6 - 3)).clamp(15.0, 45.0);
    
    final baseHumidity = _currentSensorData?.humidity ?? 65.0;
    final newHumidity = (baseHumidity + (random.nextDouble() * 10 - 5)).clamp(30.0, 90.0);
    
    // Simulate different scenarios based on gas level - adjusted for ESP32 ADC values
    bool smokeDetected = false;
    bool flameDetected = false;
    
    if (newGasLevel > 2000) {
      // High gas level scenario - ESP32 ADC values are higher
      smokeDetected = random.nextBool();
      flameDetected = newGasLevel > 3000 ? random.nextBool() : false;
    } else if (newGasLevel > 1500) {
      // Medium gas level scenario
      smokeDetected = random.nextDouble() < 0.3; // 30% chance
    }
    
    // High temperature can also trigger alerts
    if (newTemp > 35) {
      smokeDetected = smokeDetected || (random.nextDouble() < 0.4);
      flameDetected = flameDetected || (newTemp > 40 && random.nextDouble() < 0.3);
    }
    
    final mockData = SensorData(
      id: DateTime.now().millisecondsSinceEpoch,
      smokeDetected: smokeDetected,
      flameDetected: flameDetected,
      latitude: _currentSensorData?.latitude ?? -7.12345,
      longitude: _currentSensorData?.longitude ?? 110.12345,
      timestamp: DateTime.now(),
      temperature: newTemp,
      humidity: newHumidity,
      gasLevel: newGasLevel,
    );
    
    // Process this mock data as if it came from MQTT
    _currentSensorData = mockData;
    
    if (_sensorHistory.isEmpty || 
        _sensorHistory.first.timestamp != mockData.timestamp) {
      _sensorHistory.insert(0, mockData);
      
      if (_sensorHistory.length > 50) {
        _sensorHistory = _sensorHistory.sublist(0, 50);
      }
    }
    
    // Update fire locations if fire is detected
    if (mockData.isFireDetected && mockData.latitude != null && 
        mockData.longitude != null) {
      _updateFireLocations(mockData);
    }
    
    _error = null;
    notifyListeners();
    
    print('Simulated MQTT data generated - Gas: ${newGasLevel}ppm, Temp: ${newTemp.toStringAsFixed(1)}°C, Smoke: $smokeDetected, Flame: $flameDetected');
  }

  @override
  void dispose() {
    try {
      _mqttSubscription?.cancel();
      _periodicFetchTimer?.cancel();
      _mqttConnectionCheckTimer?.cancel();
      // Note: MqttService doesn't have dispose method, connection will be handled by the service itself
    } catch (e) {
      print('Error during disposal: $e');
    }
    super.dispose();
  }
}
