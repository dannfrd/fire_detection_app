class SensorData {
  final int id;
  final bool smokeDetected;
  final bool flameDetected;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  final String? aiAnalysis;
  final double? temperature;
  final double? humidity;
  final int? gasLevel;

  SensorData({
    required this.id,
    required this.smokeDetected,
    required this.flameDetected,
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.aiAnalysis,
    this.temperature,
    this.humidity,
    this.gasLevel,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'] ?? 0,
      smokeDetected: json['smoke_detected'] ?? false,
      flameDetected: json['flame_detected'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      aiAnalysis: json['ai_analysis'],
      temperature: json['temperature']?.toDouble(),
      humidity: json['humidity']?.toDouble(),
      gasLevel: json['gasLevel'] ?? json['gas_level'],
    );
  }

  bool get isFireDetected => smokeDetected || flameDetected;

  String get status {
    if (smokeDetected && flameDetected) return 'Critical';
    if (smokeDetected || flameDetected) return 'Warning';
    return 'Normal';
  }
}
