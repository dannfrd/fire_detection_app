import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class SafetyRulesWidget extends StatelessWidget {
  final bool isFireDetected;
  final bool compactMode;

  const SafetyRulesWidget({
    super.key,
    required this.isFireDetected,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // Menentukan tipe petunjuk keselamatan yang ditampilkan
    Widget rulesContent;

    if (isFireDetected) {
      rulesContent = _buildFireSafetyRules(compactMode);
    } else {
      rulesContent = _buildPreventativeMeasures(compactMode);
    }

    return Card(
      elevation: compactMode ? 2 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(compactMode ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isFireDetected ? Icons.shield : Icons.security,
                  color: isFireDetected ? Colors.red : AppTheme.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Petunjuk Keselamatan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            rulesContent,
          ],
        ),
      ),
    );
  }

  Widget _buildFireSafetyRules(bool compactMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAlertBox(
          'SEGERA EVAKUASI!',
          'Jika api terdeteksi, keselamatan adalah prioritas utama.',
          Colors.red,
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          '1. Segera Evakuasi Area',
          'Tinggalkan area dengan tenang. Jangan panik dan jangan kembali untuk mengambil barang.',
          Icons.directions_run,
          isHighPriority: true,
        ),
        _buildRuleItem(
          '2. Panggil Pemadam Kebakaran',
          'Hubungi 113 atau nomor darurat pemadam kebakaran setempat setelah berada di tempat aman.',
          Icons.phone,
          isHighPriority: true,
        ),
        _buildRuleItem(
          '3. Gunakan Jalur Evakuasi',
          'Ikuti jalur evakuasi yang sudah ditentukan. Jangan gunakan lift.',
          Icons.exit_to_app,
          isHighPriority: true,
        ),
        _buildRuleItem(
          '4. Periksa Kondisi Pintu',
          'Sebelum membuka pintu, periksa suhu dengan punggung tangan. Jika panas, cari jalur alternatif.',
          Icons.door_front_door,
          isHighPriority: true,
        ),
        _buildRuleItem(
          '5. Jangan Mencoba Memadamkan Api Besar',
          'Hanya api kecil yang dapat dipadamkan dengan APAR. Api besar harus ditangani profesional.',
          Icons.local_fire_department,
          isHighPriority: true,
        ),
      ],
    );
  }

  Widget _buildPreventativeMeasures(bool compactMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAlertBox(
          'TINDAKAN PENCEGAHAN KEBAKARAN',
          'Perhatikan langkah-langkah pencegahan kebakaran untuk keamanan maksimal.',
          AppTheme.primaryGreen,
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          '1. Periksa Detektor Api dan Asap',
          'Lakukan pemeriksaan rutin pada sensor api dan asap, pastikan berfungsi dengan baik.',
          Icons.check_circle_outline,
        ),
        _buildRuleItem(
          '2. Pasang Detektor Kebakaran',
          'Gunakan detektor api dan asap di lokasi strategis dan periksa baterai secara berkala.',
          Icons.sensors,
        ),
        _buildRuleItem(
          '3. Miliki APAR (Alat Pemadam Api Ringan)',
          'Siapkan alat pemadam api dan pastikan semua orang tahu cara menggunakannya.',
          Icons.fire_extinguisher,
        ),
        _buildRuleItem(
          '4. Kenali Jalur Evakuasi',
          'Pastikan semua orang mengetahui jalur evakuasi dan titik kumpul.',
          Icons.map,
        ),
        _buildRuleItem(
          '5. Simpan Nomor Darurat',
          'Catat nomor pemadam kebakaran (113) dan layanan darurat lainnya di tempat yang mudah diakses.',
          Icons.contact_phone,
        ),
      ],
    );
  }

  Widget _buildAlertBox(String title, String description, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(
    String title,
    String description,
    IconData icon, {
    bool isHighPriority = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighPriority
                  ? Colors.red.withOpacity(0.1)
                  : AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isHighPriority ? Colors.red : AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isHighPriority
                        ? Colors.red.shade700
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
