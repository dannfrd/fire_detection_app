import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../models/sensor_data.dart';

class MqttService {
  // MQTT Client
  MqttServerClient? _client;
  final String _identifier = 'agrotech_fire_app';
  final String _host = '103.139.192.54'; // Use your MQTT broker here
  final int _port = 1883;

  // Topics - Updated to match your Arduino code
  final String _kelompokTopic = 'kelompok4';
  final String _temperatureTopic = 'kelompok4/temperature';
  final String _humidityTopic = 'kelompok4/humidity';
  final String _gasTopic =
      'Tubes/kelompok4/gas'; // Updated to match Arduino code
  final String _flameTopic =
      'Tubes/kelompok4/flame'; // Updated to match Arduino code
  final String _smokeTopic = 'kelompok4/smoke';
  final String _sensorStatusTopic =
      'Tubes/kelompok4/sensor_status'; // New topic from Arduino
  final String _controlStatusTopic =
      'Tubes/Status'; // Control topic for remote activation
  final String _locationTopic = 'kelompok4/location';

  // Additional topics for wildcard subscription
  final String _tubesBaseTopic = 'Tubes/kelompok4';

  // Streams
  final _sensorDataStreamController = StreamController<SensorData>.broadcast();
  Stream<SensorData> get sensorDataStream => _sensorDataStreamController.stream;

  // Connection status
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Reconnection fields
  Timer? _reconnectTimer;
  final int _reconnectInterval = 5; // Seconds

  // Current sensor values - untuk menggabungkan data dari berbagai topic
  int? _currentGasLevel;
  bool _currentSmokeDetected = false;
  bool _currentFlameDetected = false;
  double _currentTemperature = 25.0;
  double _currentHumidity = 60.0;
  bool _systemActive = true; // System status from Arduino

  // Connect to MQTT broker
  Future<bool> connect() async {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      print('Already connected to MQTT broker');
      return true;
    }

    // Create a new client with a unique ID to avoid conflicts
    final uniqueId = '${_identifier}_${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient(_host, uniqueId);
    _client!.port = _port;
    _client!.keepAlivePeriod = 30;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.onSubscribed = _onSubscribed;

    // Important for release mode - explicitly set secure to false for plain MQTT
    _client!.secure = false;

    // Configure connection handling
    _client!.autoReconnect = true;
    _client!.resubscribeOnAutoReconnect = true;
    _client!.connectTimeoutPeriod = 3000; // 3 seconds timeout

    // Set logging
    _client!.logging(on: true);
    _client!.setProtocolV311();

    // Configure connection message with all required fields
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(uniqueId)
        .withWillTopic('willtopic')
        .withWillMessage('Connection lost')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce)
        .authenticateAs('kelompok_4', 'admin123#');

    _client!.connectionMessage = connMessage;

    try {
      print('Connecting to MQTT broker at $_host:$_port...');
      await _client!.connect();
      final state = _client!.connectionStatus!.state;

      if (state == MqttConnectionState.connected) {
        print('Connected to MQTT broker successfully');
        _isConnected = true;
        return true;
      } else {
        print('Failed to connect to MQTT broker. State: $state');
        _client!.disconnect();
        _isConnected = false;
        return false;
      }
    } catch (e) {
      print('Exception while connecting to MQTT: $e');
      _client!.disconnect();
      _isConnected = false;
      return false;
    }
  }

  // Subscription to topics
  void subscribeToTopics() {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      print('Subscribing to MQTT topics...');

      // Subscribe to main kelompok topic and all subtopics
      _client!.subscribe(_kelompokTopic, MqttQos.atLeastOnce);
      _client!.subscribe(
        _kelompokTopic + '/+',
        MqttQos.atLeastOnce,
      ); // Wildcard for all subtopics
      print('Subscribed to main topic: $_kelompokTopic');

      // Subscribe to Tubes topics (from Arduino code)
      _client!.subscribe(_tubesBaseTopic, MqttQos.atLeastOnce);
      _client!.subscribe(
        _tubesBaseTopic + '/+',
        MqttQos.atLeastOnce,
      ); // Wildcard for all Tubes subtopics
      print('Subscribed to Tubes topic: $_tubesBaseTopic');

      // Individual topics
      _client!.subscribe(_gasTopic, MqttQos.atLeastOnce);
      _client!.subscribe(_flameTopic, MqttQos.atLeastOnce);
      _client!.subscribe(_sensorStatusTopic, MqttQos.atLeastOnce);
      _client!.subscribe(_temperatureTopic, MqttQos.atLeastOnce);
      _client!.subscribe(_humidityTopic, MqttQos.atLeastOnce);
      _client!.subscribe(_smokeTopic, MqttQos.atLeastOnce);
      _client!.subscribe(_locationTopic, MqttQos.atLeastOnce);

      // Listen for changes
      _setupMessageListener();

      print('All MQTT topics subscribed successfully');
    } else {
      print('Cannot subscribe: MQTT client not connected');
    }
  }

  // Set up message listener
  void _setupMessageListener() {
    print('Setting up MQTT message listener');
    _client!.updates!.listen(
      _onMessage,
      onError: (error) {
        print('MQTT message stream error: $error');
      },
      onDone: () {
        print('MQTT message stream closed');
      },
      cancelOnError: false,
    );
  }

  // Method untuk membuat SensorData terbaru dari semua nilai sensor
  void _emitCombinedSensorData() {
    // Determine fire detection based on gas levels and system status
    // Updated thresholds to match Arduino's gas sensor values (3000 for danger)
    bool isHighGasLevel = _currentGasLevel != null && _currentGasLevel! > 2000;
    bool isCriticalGasLevel =
        _currentGasLevel != null && _currentGasLevel! > 3000;

    final sensorData = SensorData(
      id: DateTime.now().millisecondsSinceEpoch,
      timestamp: DateTime.now(),
      gasLevel: _currentGasLevel ?? 0, // Provide default to avoid null
      smokeDetected: _currentSmokeDetected || isHighGasLevel,
      flameDetected: _currentFlameDetected || isCriticalGasLevel,
      temperature: _currentTemperature,
      humidity: _currentHumidity,
      latitude:
          -7.12345, // You may want to update these with your actual location
      longitude: 110.12345,
      aiAnalysis: _currentFlameDetected ? "Api Terdeteksi" : null,
    );

    print('=== EMITTING SENSOR DATA ===');
    print('System Active: $_systemActive');
    print('Gas Level: ${_currentGasLevel ?? "N/A"} ppm');
    print('Smoke Detected: ${sensorData.smokeDetected}');
    print('Flame Detected: ${sensorData.flameDetected}');
    print('Temperature: ${_currentTemperature}°C');
    print('Humidity: ${_currentHumidity}%');
    print('============================');

    _sensorDataStreamController.add(sensorData);
  }

  // Message handler
  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    if (messages.isEmpty) {
      print('Received empty message list');
      return;
    }

    for (var message in messages) {
      try {
        if (message.payload is! MqttPublishMessage) {
          print(
            'Received message with unexpected payload type: ${message.payload.runtimeType}',
          );
          continue;
        }

        final MqttPublishMessage recMess =
            message.payload as MqttPublishMessage;
        // Proceed with extracting the message

        final String messageString = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        print('Received message on topic: ${message.topic}');
        print('Message: $messageString');

        // Process message by topic
        bool shouldEmitUpdate =
            true; // Always emit update on any message for real-time data

        // Handle gas sensor data from Tubes/kelompok4/gas
        if (message.topic == _gasTopic) {
          print('Processing gas topic message: $messageString');
          final gasLevel = int.tryParse(messageString.trim());
          if (gasLevel != null) {
            print(
              'Parsed gas level: $gasLevel ppm (current: $_currentGasLevel)',
            );
            if (gasLevel != _currentGasLevel) {
              print(
                'Gas level changed from $_currentGasLevel to $gasLevel ppm',
              );
              _currentGasLevel = gasLevel;
              shouldEmitUpdate = true;
            } else {
              print('Gas level unchanged: $gasLevel ppm');
            }
          } else {
            print('Failed to parse gas level from: $messageString');
          }
        }
        // Handle sensor status from Tubes/kelompok4/sensor_status
        else if (message.topic == _sensorStatusTopic) {
          print('Sensor status received: $messageString');

          final wasSystemActive = _systemActive;
          // Check system status from Arduino
          _systemActive = messageString.toLowerCase().contains('active');

          if (_systemActive != wasSystemActive) {
            print('System status changed: $_systemActive');
            shouldEmitUpdate = true;
          }
        }
        // Handle smoke sensor
        else if (message.topic == _smokeTopic) {
          final smokeDetected =
              messageString.toLowerCase() == 'true' ||
              messageString.trim() == '1' ||
              messageString.toLowerCase().contains('detected');
          if (smokeDetected != _currentSmokeDetected) {
            print('Smoke detection changed: $smokeDetected');
            _currentSmokeDetected = smokeDetected;
            shouldEmitUpdate = true;
          }
        }
        // Handle flame sensor - Updated to match Arduino code
        else if (message.topic == _flameTopic) {
          print('Flame sensor message: $messageString');
          // Arduino sends "FIRE DETECTED!" or "Safe"
          final flameDetected =
              messageString.toLowerCase().contains('fire detected') ||
              messageString.toLowerCase().contains('detected');
          if (flameDetected != _currentFlameDetected) {
            print('Flame detection changed: $flameDetected');
            _currentFlameDetected = flameDetected;
            shouldEmitUpdate = true;
          }
        }
        // Handle temperature
        else if (message.topic == _temperatureTopic) {
          final temperature = double.tryParse(messageString.trim());
          if (temperature != null && temperature != _currentTemperature) {
            print('Temperature updated: $temperature°C');
            _currentTemperature = temperature;
            shouldEmitUpdate = true;
          }
        }
        // Handle humidity
        else if (message.topic == _humidityTopic) {
          final humidity = double.tryParse(messageString.trim());
          if (humidity != null && humidity != _currentHumidity) {
            print('Humidity updated: $humidity%');
            _currentHumidity = humidity;
            shouldEmitUpdate = true;
          }
        }
        // Handle main kelompok topic untuk JSON data
        else if (message.topic == _kelompokTopic) {
          // Try to parse as JSON if it's in a combined format
          try {
            final Map<String, dynamic> jsonData = jsonDecode(messageString);

            // Update values if found in JSON
            if (jsonData.containsKey('gas')) {
              _currentGasLevel =
                  int.tryParse(jsonData['gas'].toString()) ?? _currentGasLevel;
              shouldEmitUpdate = true;
            }

            if (jsonData.containsKey('temperature')) {
              _currentTemperature =
                  double.tryParse(jsonData['temperature'].toString()) ??
                  _currentTemperature;
              shouldEmitUpdate = true;
            }

            if (jsonData.containsKey('humidity')) {
              _currentHumidity =
                  double.tryParse(jsonData['humidity'].toString()) ??
                  _currentHumidity;
              shouldEmitUpdate = true;
            }
          } catch (e) {
            print('Error parsing JSON from main topic: $e');
          }
        } else if ((message.topic.startsWith(_kelompokTopic) ||
                message.topic.startsWith(_tubesBaseTopic)) &&
            message.topic != _gasTopic &&
            message.topic != _sensorStatusTopic) {
          try {
            final Map<String, dynamic> data = jsonDecode(messageString);

            // Update individual values if present
            if (data.containsKey('gas') || data.containsKey('gas_level')) {
              final gasLevel = data['gas'] ?? data['gas_level'];
              if (gasLevel is int && gasLevel != _currentGasLevel) {
                _currentGasLevel = gasLevel;
                shouldEmitUpdate = true;
              }
            }

            if (data.containsKey('temperature')) {
              final temp = data['temperature'];
              if (temp is num && temp.toDouble() != _currentTemperature) {
                _currentTemperature = temp.toDouble();
                shouldEmitUpdate = true;
              }
            }

            if (data.containsKey('humidity')) {
              final hum = data['humidity'];
              if (hum is num && hum.toDouble() != _currentHumidity) {
                _currentHumidity = hum.toDouble();
                shouldEmitUpdate = true;
              }
            }

            // Create complete sensor data from JSON
            if (!shouldEmitUpdate) {
              if (!data.containsKey('timestamp')) {
                data['timestamp'] = DateTime.now().toIso8601String();
              }

              if (!data.containsKey('id')) {
                data['id'] = DateTime.now().millisecondsSinceEpoch;
              }

              final sensorData = SensorData.fromJson(data);
              _sensorDataStreamController.add(sensorData);
            }
          } catch (jsonError) {
            print('Not JSON data, treating as simple value: $messageString');
          }
        }

        // Emit combined update if any sensor value changed
        if (shouldEmitUpdate) {
          _emitCombinedSensorData();
        }
      } catch (e) {
        print('Error processing MQTT message on topic ${message.topic}: $e');
      }
    }
  }

  // Connection callbacks
  void _onConnected() {
    _isConnected = true;
    print('Connected to MQTT broker: $_host:$_port');
    subscribeToTopics();
  }

  void _onDisconnected() {
    _isConnected = false;
    print('Disconnected from MQTT broker');

    // Try to reconnect after interval
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _reconnectInterval), () async {
      print('Attempting to reconnect to MQTT broker...');
      await connect();

      // If connection successful, resubscribe
      if (_isConnected) {
        subscribeToTopics();
      }
    });
  }

  void _onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  // Publish message to a topic
  void publishMessage(String topic, String message) {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      try {
        final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
        builder.addString(message);
        _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
        print('Published message to $topic: $message');
      } catch (e) {
        print('Error publishing to $topic: $e');
      }
    } else {
      print('Cannot publish: MQTT client not connected');
    }
  }

  // Send control command to Arduino system
  void sendControlCommand(bool activate) {
    final command = activate ? "ACTIVE" : "INACTIVE";
    publishMessage(_controlStatusTopic, command);
    print('Sent control command: $command');
  }

  // Check connection status
  bool isClientConnected() {
    return _client?.connectionStatus?.state == MqttConnectionState.connected;
  }

  // Attempt to reconnect if disconnected
  Future<bool> ensureConnected() async {
    if (!isClientConnected()) {
      print('MQTT not connected, attempting to reconnect...');
      final connected = await connect();
      if (connected) {
        subscribeToTopics();
      }
      return connected;
    }
    return true;
  }

  // Disconnect from MQTT broker
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    if (_client != null) {
      try {
        _client!.disconnect();
        print('Disconnected from MQTT broker');
      } catch (e) {
        print('Error disconnecting from MQTT: $e');
      }
    }
    _isConnected = false;
  }

  // Clean up resources
  void dispose() {
    disconnect();
    try {
      _sensorDataStreamController.close();
    } catch (e) {
      print('Error closing stream controller: $e');
    }
  }
}
