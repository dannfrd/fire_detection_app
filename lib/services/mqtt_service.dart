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
  
  // Topics
  final String _temperatureTopic = 'agrotech/sensor/temperature';
  final String _humidityTopic = 'agrotech/sensor/humidity';
  final String _gasTopic = 'agrotech/sensor/gas';
  final String _flameTopic = 'agrotech/sensor/flame';
  final String _locationTopic = 'agrotech/sensor/location';
  final String _allDataTopic = 'agrotech/sensor/all';

  // Streams
  final _sensorDataStreamController = StreamController<SensorData>.broadcast();
  Stream<SensorData> get sensorDataStream => _sensorDataStreamController.stream;

  // Connection status
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  // Reconnection fields
  Timer? _reconnectTimer;
  final int _reconnectInterval = 5; // Seconds

  // Connect to MQTT broker
  Future<bool> connect() async {
    _client = MqttServerClient(_host, _identifier);
    _client!.port = _port;
    _client!.keepAlivePeriod = 30;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic('willtopic')
        .withWillMessage('Connection lost')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce)
        .authenticateAs('kelompok_4', 'admin123#');

    _client!.connectionMessage = connMessage;

    try {
      await _client!.connect();
      return true;
    } catch (e) {
      print('Exception: $e');
      _client!.disconnect();
      return false;
    }
  }

  // Subscription to topics
  void subscribeToTopics() {
    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      _client!.subscribe(_allDataTopic, MqttQos.atLeastOnce);
      
      // Individual topics if needed
      _client!.subscribe(_temperatureTopic, MqttQos.atLeastOnce);
      _client!.subscribe(_humidityTopic, MqttQos.atLeastOnce);
      _client!.subscribe(_gasTopic, MqttQos.atLeastOnce);
      _client!.subscribe(_flameTopic, MqttQos.atLeastOnce);
      _client!.subscribe(_locationTopic, MqttQos.atLeastOnce);

      // Listen for changes
      _client!.updates!.listen(_onMessage);
    }
  }

  // Message handler
  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (var message in messages) {
      final MqttPublishMessage recMess = message.payload as MqttPublishMessage;
      final String messageString = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message);

      try {
        // Process the message based on topic
        if (message.topic == _allDataTopic) {
          final Map<String, dynamic> data = jsonDecode(messageString);
          
          // Create timestamp if not provided
          if (!data.containsKey('timestamp')) {
            data['timestamp'] = DateTime.now().toIso8601String();
          }
          
          // Create id if not provided
          if (!data.containsKey('id')) {
            data['id'] = DateTime.now().millisecondsSinceEpoch;
          }
          
          // Check for smoke_detected and flame_detected keys
          if (!data.containsKey('smoke_detected') && data.containsKey('smokeDetected')) {
            data['smoke_detected'] = data['smokeDetected'];
          }
          
          if (!data.containsKey('flame_detected') && data.containsKey('flameDetected')) {
            data['flame_detected'] = data['flameDetected'];
          }
          
          final sensorData = SensorData.fromJson(data);
          _sensorDataStreamController.add(sensorData);
        } 
        // Handle individual sensor topics if needed
        else if (message.topic == _temperatureTopic) {
          // Handle temperature data
        } else if (message.topic == _humidityTopic) {
          // Handle humidity data
        }
        // ... and so on for other topics
      } catch (e) {
        print('Error parsing MQTT message: $e');
        print('Message was: $messageString');
      }
    }
  }

  // Connection callbacks
  void _onConnected() {
    _isConnected = true;
    print('Connected to MQTT broker');
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
    });
  }

  void _onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  // Publish message to a topic
  void publishMessage(String topic, String message) {
    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    }
  }

  // Disconnect from MQTT broker
  void disconnect() {
    _reconnectTimer?.cancel();
    _client?.disconnect();
    _sensorDataStreamController.close();
  }
}