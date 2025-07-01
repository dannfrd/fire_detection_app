import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/sensor_data.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';
import '../services/mqtt_service.dart';

class FireDetectionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final MqttService _mqttService = MqttService();

  StreamSubscription? _mqttSubscription;
  Timer? _periodicFetchTimer;

  SensorData? _currentSensorData;
  List<SensorData> _sensorHistory = [];
  bool _isLoading = false;
  String? _error;
  bool _isMqttConnected = false;

  // Alert status
  AlertLevel _currentAlertLevel = AlertLevel.normal;
  FireDetectionSettings? _settings;

  // Getters
  SensorData? get currentSensorData => _currentSensorData;
  List<SensorData> get sensorHistory => _sensorHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isMqttConnected => _isMqttConnected;
  AlertLevel get currentAlertLevel => _currentAlertLevel;

  // Method to control Arduino system
  void setSystemActive(bool active) {
    if (_isMqttConnected) {
      _mqttService.sendControlCommand(active);
    }
  }

  FireDetectionProvider() {
    _initializeServices();
  }

  // Set the settings provider reference
  void setSettingsProvider(FireDetectionSettings settings) {
    _settings = settings;
    // Re-evaluate alert levels if we have sensor data
    if (_currentSensorData != null) {
      _evaluateAlertLevels(_currentSensorData!);
    }
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

      // First try - with a timeout to prevent blocking too long
      Future<bool> connectionFuture = _mqttService.connect();
      _isMqttConnected = await connectionFuture.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('MQTT connection timed out after 10 seconds');
          return false;
        },
      );

      if (_isMqttConnected) {
        print('Successfully connected to MQTT broker');

        // Set up the MQTT data stream subscription
        _setupMqttSubscription();

        // Periodically check MQTT connection
        _startMqttConnectionChecker();
      } else {
        print('Failed to connect to MQTT broker');
        _error = 'Could not connect to MQTT server. Using API fallback.';

        // Try one more time after a short delay
        Future.delayed(const Duration(seconds: 2), () async {
          print('Retrying MQTT connection...');
          _isMqttConnected = await _mqttService.connect();
          if (_isMqttConnected) {
            print('Successfully connected to MQTT on retry');
            _error = null;
            _setupMqttSubscription();
            _startMqttConnectionChecker();
            notifyListeners();
          }
        });

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
        print(
          'Fire Detection Status - Flame: ${sensorData.flameDetected}, Smoke: ${sensorData.smokeDetected}',
        );
        print('Smoke: ${sensorData.smokeDetected}');
        print('Flame: ${sensorData.flameDetected}');
        print('Temperature: ${sensorData.temperature}°C');
        print('Timestamp: ${sensorData.timestamp}');
        print('============================');

        _currentSensorData = sensorData;

        // Evaluate against thresholds
        _evaluateAlertLevels(sensorData);

        // Add to history if it's a new reading
        if (_sensorHistory.isEmpty ||
            _sensorHistory.first.timestamp != sensorData.timestamp) {
          _sensorHistory.insert(0, sensorData);

          // Keep history to a reasonable size
          if (_sensorHistory.length > 50) {
            _sensorHistory = _sensorHistory.sublist(0, 50);
          }
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
    _mqttConnectionCheckTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) async {
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
        // Evaluate against thresholds
        _evaluateAlertLevels(data);
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
        _mqttService.publishMessage(
          'kelompok4/commands/refresh',
          'request_data',
        );
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
        _error =
            'MQTT disconnected and API server unavailable. Using simulation mode.';
      }
    }

    _setLoading(false);
  }

  // For testing: simulate receiving MQTT data focused on fire detection scenarios
  void simulateMqttData() {
    final random = Random();

    // Generate realistic temperature values
    final baseTemp = _currentSensorData?.temperature ?? 28.0;
    final newTemp = (baseTemp + (random.nextDouble() * 6 - 3)).clamp(
      15.0,
      60.0, // Allow higher temperatures for fire scenarios
    );

    final baseHumidity = _currentSensorData?.humidity ?? 65.0;
    final newHumidity = (baseHumidity + (random.nextDouble() * 10 - 5)).clamp(
      30.0,
      90.0,
    );

    // Keep gas level for compatibility but don't use it for fire detection logic
    final baseGasLevel = _currentSensorData?.gasLevel ?? 800;
    final newGasLevel = (baseGasLevel + (random.nextInt(800) - 400)).clamp(
      100,
      4000,
    );

    // Fire detection scenarios focused on flame and smoke sensors
    bool smokeDetected = false;
    bool flameDetected = false;

    // Scenario 1: Fire detected by flame sensor (primary trigger)
    if (random.nextDouble() < 0.15) {
      // 15% chance of flame detection
      flameDetected = true;
      smokeDetected =
          random.nextDouble() < 0.8; // 80% chance smoke also detected
    }
    // Scenario 2: Smoke detected without flame (early warning)
    else if (random.nextDouble() < 0.25) {
      // 25% chance of smoke only
      smokeDetected = true;
      flameDetected = false;
    }
    // Scenario 3: High temperature scenarios
    else if (newTemp > 40) {
      smokeDetected = random.nextDouble() < 0.4; // 40% chance
      flameDetected =
          newTemp > 50 && random.nextDouble() < 0.6; // 60% chance if very hot
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

    // Evaluate against thresholds
    _evaluateAlertLevels(mockData);

    if (_sensorHistory.isEmpty ||
        _sensorHistory.first.timestamp != mockData.timestamp) {
      _sensorHistory.insert(0, mockData);

      if (_sensorHistory.length > 50) {
        _sensorHistory = _sensorHistory.sublist(0, 50);
      }
    }

    _error = null;
    notifyListeners();

    print(
      'Simulated MQTT data generated - Flame: $flameDetected, Smoke: $smokeDetected, Temp: ${newTemp.toStringAsFixed(1)}°C',
    );
  }

  // Evaluate sensor data for fire detection (flame sensor priority)
  void _evaluateAlertLevels(SensorData sensorData) {
    // Default to normal if no settings available
    if (_settings == null) {
      _currentAlertLevel = AlertLevel.normal;
      return;
    }

    // Fire detection priority: Focus on flame sensor ONLY
    if (sensorData.flameDetected) {
      _currentAlertLevel = AlertLevel.critical;
      print('🔥 FLAME DETECTED - CRITICAL FIRE ALERT!');
    }
    // Secondary: Smoke detection as backup indicator
    else if (sensorData.smokeDetected) {
      _currentAlertLevel = AlertLevel.warning;
      print('💨 SMOKE DETECTED - Fire risk warning');
    }
    // Temperature monitoring as additional context only
    else if (sensorData.temperature != null &&
        sensorData.temperature! >= _settings!.temperatureThreshold) {
      _currentAlertLevel = AlertLevel.temperature;
      print(
        '🌡️ HIGH TEMPERATURE - ${sensorData.temperature}°C (elevated risk)',
      );
    }
    // All clear - no fire indicators
    else {
      _currentAlertLevel = AlertLevel.normal;
      print('✅ Fire sensors normal - No fire detected');
    }

    // Update UI
    notifyListeners();
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
