import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sensor_data.dart';

class ApiService {
  static const String baseUrl =
      'http://your-server-url.com/api'; // Replace with actual server URL
  static const Duration timeout = Duration(seconds: 10);

  Future<SensorData?> getCurrentSensorData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sensor/current'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return SensorData.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('Error fetching sensor data: $e');
      return null;
    }
  }

  Future<List<SensorData>> getSensorHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sensor/history'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => SensorData.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching sensor history: $e');
      return [];
    }
  }

  Future<List<FireLocation>> getFireLocations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fires/locations'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        // Check if response is actually JSON
        final contentType = response.headers['content-type'] ?? '';
        if (!contentType.contains('application/json')) {
          print('Warning: Response is not JSON, got content-type: $contentType');
          print('Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
          return [];
        }
        
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          return jsonData.map((item) => FireLocation.fromJson(item)).toList();
        } catch (parseError) {
          print('Error parsing JSON response: $parseError');
          print('Response body: ${response.body}');
          return [];
        }
      } else {
        print('API returned status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching fire locations: $e');
      return [];
    }
  }
}
