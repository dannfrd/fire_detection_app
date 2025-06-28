class SensorData {
  final int id;
  final bool smokeDetected;
  final bool flameDetected;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  final String? aiAnalysis;

  SensorData({
    required this.id,
    required this.smokeDetected,
    required this.flameDetected,
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.aiAnalysis,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'] ?? 0,
      smokeDetected: json['smoke_detected'] ?? false,
      flameDetected: json['flame_detected'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      aiAnalysis: json['ai_analysis'],
    );
  }

  bool get isFireDetected => smokeDetected || flameDetected;

  String get status {
    if (smokeDetected && flameDetected) return 'Critical';
    if (smokeDetected || flameDetected) return 'Warning';
    return 'Normal';
  }
}

class FireLocation {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String severity;

  FireLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.severity,
  });

  factory FireLocation.fromJson(Map<String, dynamic> json) {
    return FireLocation(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      severity: json['severity'] ?? 'Normal',
    );
  }
}
