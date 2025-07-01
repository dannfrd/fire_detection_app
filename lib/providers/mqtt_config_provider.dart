import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttConfigProvider with ChangeNotifier {
  // Default MQTT configuration
  String _host = '103.139.192.54';
  int _port = 1883;
  String _username = '';
  String _password = '';
  String _clientId = 'agrotech_fire_app';
  bool _isConfigured = false;

  // Getters
  String get host => _host;
  int get port => _port;
  String get username => _username;
  String get password => _password;
  String get clientId => _clientId;
  bool get isConfigured => _isConfigured;

  // Constructor
  MqttConfigProvider() {
    loadConfig();
  }

  // Load configuration from SharedPreferences
  Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _host = prefs.getString('mqtt_host') ?? '103.139.192.54';
      _port = prefs.getInt('mqtt_port') ?? 1883;
      _username = prefs.getString('mqtt_username') ?? '';
      _password = prefs.getString('mqtt_password') ?? '';
      _clientId = prefs.getString('mqtt_client_id') ?? 'agrotech_fire_app';
      _isConfigured = prefs.getBool('mqtt_configured') ?? false;

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading MQTT config: $e');
      }
    }
  }

  // Save configuration to SharedPreferences
  Future<void> saveConfig({
    required String host,
    required int port,
    required String username,
    required String password,
    required String clientId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('mqtt_host', host);
      await prefs.setInt('mqtt_port', port);
      await prefs.setString('mqtt_username', username);
      await prefs.setString('mqtt_password', password);
      await prefs.setString('mqtt_client_id', clientId);
      await prefs.setBool('mqtt_configured', true);

      _host = host;
      _port = port;
      _username = username;
      _password = password;
      _clientId = clientId;
      _isConfigured = true;

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving MQTT config: $e');
      }
    }
  }

  // Test MQTT connection
  Future<bool> testConnection({
    required String host,
    required int port,
    required String username,
    required String password,
    required String clientId,
  }) async {
    try {
      final client = MqttServerClient(host, clientId);
      client.port = port;
      client.logging(on: false);
      client.keepAlivePeriod = 20;
      client.connectTimeoutPeriod = 10000; // 10 seconds

      // Attempt to connect
      MqttConnectMessage connMessage;
      if (username.isNotEmpty) {
        connMessage = MqttConnectMessage()
            .withClientIdentifier(clientId)
            .authenticateAs(username, password)
            .startClean()
            .withWillQos(MqttQos.atLeastOnce);
      } else {
        connMessage = MqttConnectMessage()
            .withClientIdentifier(clientId)
            .startClean()
            .withWillQos(MqttQos.atLeastOnce);
      }
      client.connectionMessage = connMessage;

      try {
        await client.connect();
        if (client.connectionStatus!.state == MqttConnectionState.connected) {
          client.disconnect();
          return true;
        }
      } catch (e) {
        if (kDebugMode) {
          print('MQTT connection test failed: $e');
        }
      }

      client.disconnect();
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error testing MQTT connection: $e');
      }
      return false;
    }
  }

  // Reset configuration
  Future<void> resetConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('mqtt_host');
      await prefs.remove('mqtt_port');
      await prefs.remove('mqtt_username');
      await prefs.remove('mqtt_password');
      await prefs.remove('mqtt_client_id');
      await prefs.setBool('mqtt_configured', false);

      _host = '103.139.192.54';
      _port = 1883;
      _username = '';
      _password = '';
      _clientId = 'agrotech_fire_app';
      _isConfigured = false;

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting MQTT config: $e');
      }
    }
  }

  // Mark as configured (for skipping configuration)
  Future<void> markAsConfigured() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mqtt_configured', true);
      _isConfigured = true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error marking MQTT as configured: $e');
      }
    }
  }
}
