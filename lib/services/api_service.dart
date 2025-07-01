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
      final response = await http
          .get(
            Uri.parse('$baseUrl/sensor/current'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

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
      final response = await http
          .get(
            Uri.parse('$baseUrl/sensor/history'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

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
}
