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
  
  // Topics - Update to match your actual MQTT topics
  final String _kelompokTopic = 'kelompok4';
  final String _temperatureTopic = 'kelompok4/temperature';
  final String _humidityTopic = 'kelompok4/humidity';
  final String _gasTopic = 'kelompok4/gas';
  final String _flameTopic = 'kelompok4/flame';
  final String _smokeTopic = 'kelompok4/smoke';
  final String _apiTopic = 'kelompok4/api';
  final String _locationTopic = 'kelompok4/location';
  final String _allDataTopic = 'kelompok4/all';

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
  bool _apiFireDetected = false;

  // Connect to MQTT broker
  Future<bool> connect() async {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      print('Already connected to MQTT broker');
      return true;
    }
    
    _client = MqttServerClient(_host, _identifier);
    _client!.port = _port;
    _client!.keepAlivePeriod = 30;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.onSubscribed = _onSubscribed;
    
    // Set a ping interval to detect connection issues
    _client!.autoReconnect = true;
    _client!.resubscribeOnAutoReconnect = true;
    
    // Set logging
    _client!.logging(on: true);
    _client!.setProtocolV311();

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(_identifier + '_${DateTime.now().millisecondsSinceEpoch}')
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
      _client!.subscribe(_kelompokTopic + '/+', MqttQos.atLeastOnce); // Wildcard for all subtopics
      print('Subscribed to main topic: $_kelompokTopic');
      
      // Individual topics
      _client!.subscribe(_gasTopic, MqttQos.atLeastOnce);
      _client!.subscribe(_apiTopic, MqttQos.atLeastOnce);
      _client!.subscribe(_temperatureTopic, MqttQos.atLeastOnce);
      _client!.subscribe(_humidityTopic, MqttQos.atLeastOnce);
      _client!.subscribe(_flameTopic, MqttQos.atLeastOnce);
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
    // Determine fire detection based on gas levels and API status
    bool isHighGasLevel = _currentGasLevel != null && _currentGasLevel! > 1000;
    bool isCriticalGasLevel = _currentGasLevel != null && _currentGasLevel! > 2000;
    
    final sensorData = SensorData(
      id: DateTime.now().millisecondsSinceEpoch,
      timestamp: DateTime.now(),
      gasLevel: _currentGasLevel,
      smokeDetected: _currentSmokeDetected || isHighGasLevel || _apiFireDetected,
      flameDetected: _currentFlameDetected || isCriticalGasLevel || _apiFireDetected,
      temperature: _currentTemperature,
      humidity: _currentHumidity,
      latitude: -7.12345,  // You may want to update these with your actual location
      longitude: 110.12345,
      aiAnalysis: _apiFireDetected ? "Api Terdeteksi" : null,
    );
    
    print('=== EMITTING SENSOR DATA ===');
    print('Gas Level: ${_currentGasLevel} ppm');
    print('Smoke Detected: ${sensorData.smokeDetected}');
    print('Flame Detected: ${sensorData.flameDetected}');
    print('Temperature: ${_currentTemperature}°C');
    print('Humidity: ${_currentHumidity}%');
    print('API Fire Detection: $_apiFireDetected');
    print('============================');
    
    _sensorDataStreamController.add(sensorData);
  }

  // Message handler
  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (var message in messages) {
      final MqttPublishMessage recMess = message.payload as MqttPublishMessage;
      final String messageString = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message);
      
      print('Received message on topic: ${message.topic}');
      print('Message: $messageString');

      try {
        bool shouldEmitUpdate = true; // Always emit update on any message for real-time data
        
        // Handle gas sensor data from kelompok4/gas
        if (message.topic == _gasTopic) {
          print('Processing gas topic message: $messageString');
          final gasLevel = int.tryParse(messageString.trim());
          if (gasLevel != null) {
            print('Parsed gas level: $gasLevel ppm (current: $_currentGasLevel)');
            if (gasLevel != _currentGasLevel) {
              print('Gas level changed from $_currentGasLevel to $gasLevel ppm');
              _currentGasLevel = gasLevel;
              shouldEmitUpdate = true;
            } else {
              print('Gas level unchanged: $gasLevel ppm');
            }
          } else {
            print('Failed to parse gas level from: $messageString');
          }
        }
        // Handle API status from kelompok4/api  
        else if (message.topic == _apiTopic) {
          print('API status received: $messageString');
          
          final wasFireDetected = _apiFireDetected;
          _apiFireDetected = messageString.toLowerCase().contains('api terdeteksi') || 
                           messageString.toLowerCase().contains('fire') ||
                           messageString.toLowerCase().contains('smoke');
          
          if (_apiFireDetected != wasFireDetected) {
            print('API fire detection changed: $_apiFireDetected');
            shouldEmitUpdate = true;
          }
        }
        // Handle smoke sensor
        else if (message.topic == _smokeTopic) {
          final smokeDetected = messageString.toLowerCase() == 'true' || 
                             messageString.trim() == '1' || 
                             messageString.toLowerCase().contains('detected');
          if (smokeDetected != _currentSmokeDetected) {
            print('Smoke detection changed: $smokeDetected');
            _currentSmokeDetected = smokeDetected;
            shouldEmitUpdate = true;
          }
        }
        // Handle flame sensor
        else if (message.topic == _flameTopic) {
          final flameDetected = messageString.toLowerCase() == 'true' || 
                             messageString.trim() == '1' || 
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
              _currentGasLevel = int.tryParse(jsonData['gas'].toString()) ?? _currentGasLevel;
              shouldEmitUpdate = true;
            }
            
            if (jsonData.containsKey('api')) {
              _apiFireDetected = jsonData['api'].toString().toLowerCase().contains('api terdeteksi');
              shouldEmitUpdate = true;
            }
            
            if (jsonData.containsKey('temperature')) {
              _currentTemperature = double.tryParse(jsonData['temperature'].toString()) ?? _currentTemperature;
              shouldEmitUpdate = true;
            }
            
            if (jsonData.containsKey('humidity')) {
              _currentHumidity = double.tryParse(jsonData['humidity'].toString()) ?? _currentHumidity;
              shouldEmitUpdate = true;
            }
          } catch (e) {
            print('Error parsing JSON from main topic: $e');
          }
        }
        else if (message.topic.startsWith(_kelompokTopic) && message.topic != _gasTopic && message.topic != _apiTopic) {
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
        print('Message content: $messageString');
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
  void disconnect() {
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