import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';

class FireAlertWidget extends StatefulWidget {
  final bool isFireDetected;
  final String? detectionSource;
  final int? gasLevel;
  final double? temperature;
  final AlertLevel? alertLevel;

  const FireAlertWidget({
    super.key,
    required this.isFireDetected,
    this.detectionSource,
    this.gasLevel,
    this.temperature,
    this.alertLevel,
  });

  @override
  State<FireAlertWidget> createState() => _FireAlertWidgetState();
}

class _FireAlertWidgetState extends State<FireAlertWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine alert properties based on alert level and detection
    Color alertColor;
    String alertTitle;
    String alertMessage;
    IconData alertIcon;

    // Priority 1: Flame detected (always critical)
    if (widget.detectionSource?.contains('Sensor Api') == true) {
      alertColor = Colors.red;
      alertTitle = '🔥 BAHAYA KEBAKARAN!';
      alertMessage =
          'Sensor api mendeteksi nyala api! Segera evakuasi area dan hubungi pemadam kebakaran!';
      alertIcon = Icons.local_fire_department_rounded;
    }
    // Priority 2: Smoke detected
    else if (widget.detectionSource?.contains('Sensor Asap') == true) {
      alertColor = Colors.orange.shade800;
      alertTitle = '💨 PERINGATAN ASAP!';
      alertMessage =
          'Asap terdeteksi! Waspada kemungkinan kebakaran. Periksa area sekitar dan bersiap evakuasi!';
      alertIcon = Icons.smoke_free_rounded;
    }
    // Priority 3: Temperature alerts (high heat warning)
    else if (widget.alertLevel == AlertLevel.temperature) {
      alertColor = Colors.red.shade600;
      alertTitle = '🌡️ SUHU TINGGI!';
      alertMessage =
          'Suhu lingkungan tinggi. Waspada kemungkinan risiko kebakaran. Pantau sensor api dengan ketat.';
      alertIcon = Icons.thermostat_rounded;
    }
    // Default case
    else {
      alertColor = Colors.red;
      alertTitle = '⚠️ PERINGATAN!';
      alertMessage =
          'Kondisi tidak normal terdeteksi. Periksa area sekitar dengan hati-hati.';
      alertIcon = Icons.warning_rounded;
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(opacity: _opacityAnimation.value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: alertColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: alertColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: alertColor.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(alertIcon, size: 36, color: alertColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alertTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: alertColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              alertMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: alertColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),

            // Detection details
            if (widget.detectionSource != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Deteksi:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: alertColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terdeteksi oleh: ${widget.detectionSource}',
                      style: TextStyle(color: alertColor.withOpacity(0.8)),
                    ),
                    if (widget.gasLevel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Kadar Gas: ${widget.gasLevel} ppm',
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ],
                    if (widget.temperature != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Suhu: ${widget.temperature}°C',
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Emergency button
            ElevatedButton(
              onPressed: () {
                // Add emergency contact functionality here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone),
                  SizedBox(width: 8),
                  Text(
                    'HUBUNGI DARURAT',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
