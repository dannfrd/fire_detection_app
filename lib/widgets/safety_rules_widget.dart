import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class SafetyRulesWidget extends StatelessWidget {
  final bool isFireDetected;
  final bool isGasRisk;
  final int? gasLevel;
  final bool compactMode;

  const SafetyRulesWidget({
    super.key, 
    required this.isFireDetected,
    this.isGasRisk = false,
    this.gasLevel,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan jenis bahaya
    final bool isHighGasLevel = gasLevel != null && gasLevel! > 2000;
    final bool isMediumGasLevel = gasLevel != null && gasLevel! > 1000;
    
    // Menentukan tipe petunjuk keselamatan yang ditampilkan
    Widget rulesContent;
    
    if (isFireDetected) {
      rulesContent = _buildFireSafetyRules(compactMode);
    } else if (isHighGasLevel) {
      rulesContent = _buildHighGasSafetyRules(compactMode);
    } else if (isMediumGasLevel || isGasRisk) {
      rulesContent = _buildMediumGasSafetyRules(compactMode);
    } else {
      rulesContent = _buildPreventativeMeasures(compactMode);
    }
    
    return Card(
      elevation: compactMode ? 2 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(compactMode ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isFireDetected 
                      ? Icons.shield
                      : Icons.security,
                  color: isFireDetected 
                      ? Colors.red
                      : AppTheme.primaryGreen,
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
  
  Widget _buildHighGasSafetyRules(bool compactMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAlertBox(
          'PERINGATAN GAS BERBAHAYA',
          'Kadar gas tinggi terdeteksi! Segera ambil tindakan.',
          Colors.deepOrange,
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          '1. Matikan Sumber Gas',
          'Jika memungkinkan, matikan sumber gas utama dengan aman.',
          Icons.report_off,
          isHighPriority: true,
        ),
        _buildRuleItem(
          '2. Hindari Menyalakan Api atau Listrik',
          'Jangan nyalakan korek api, saklar listrik, atau perangkat yang dapat memicu percikan.',
          Icons.highlight_off,
          isHighPriority: true,
        ),
        _buildRuleItem(
          '3. Buka Jendela dan Pintu',
          'Tingkatkan ventilasi untuk mengurangi konsentrasi gas.',
          Icons.window,
          isHighPriority: true,
        ),
        _buildRuleItem(
          '4. Evakuasi Area',
          'Keluar dari area dengan segera. Jangan kembali sampai aman.',
          Icons.directions_run,
          isHighPriority: true,
        ),
        _buildRuleItem(
          '5. Hubungi Teknisi Gas',
          'Setelah berada di tempat aman, hubungi teknisi gas profesional.',
          Icons.phone,
          isHighPriority: true,
        ),
      ],
    );
  }
  
  Widget _buildMediumGasSafetyRules(bool compactMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAlertBox(
          'PERHATIAN - KADAR GAS MENINGKAT',
          'Tingkatkan kewaspadaan dan perhatikan tindakan pencegahan.',
          Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          '1. Periksa Sumber Gas',
          'Pastikan semua peralatan gas dimatikan dengan benar dan tidak bocor.',
          Icons.search,
        ),
        _buildRuleItem(
          '2. Tingkatkan Ventilasi',
          'Buka jendela dan pintu untuk meningkatkan sirkulasi udara.',
          Icons.air,
        ),
        _buildRuleItem(
          '3. Hindari Menyalakan Api',
          'Jangan menyalakan korek api atau merokok di area tersebut.',
          Icons.smoke_free,
        ),
        _buildRuleItem(
          '4. Monitor Tingkat Gas',
          'Perhatikan tingkat gas dan siap untuk evakuasi jika meningkat.',
          Icons.visibility,
        ),
        _buildRuleItem(
          '5. Persiapkan Evakuasi',
          'Jika tingkat gas terus naik, bersiaplah untuk meninggalkan area.',
          Icons.exit_to_app,
        ),
      ],
    );
  }
  
  Widget _buildPreventativeMeasures(bool compactMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAlertBox(
          'TINDAKAN PENCEGAHAN',
          'Perhatikan langkah-langkah pencegahan kebakaran dan kebocoran gas.',
          AppTheme.primaryGreen,
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          '1. Periksa Alat Gas Secara Berkala',
          'Lakukan pemeriksaan rutin pada semua peralatan gas untuk menghindari kebocoran.',
          Icons.check_circle_outline,
        ),
        _buildRuleItem(
          '2. Pasang Detektor Gas dan Asap',
          'Gunakan detektor gas dan asap di lokasi strategis dan periksa baterai secara berkala.',
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
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRuleItem(String title, String description, IconData icon, {bool isHighPriority = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighPriority ? Colors.red.withOpacity(0.1) : AppTheme.primaryGreen.withOpacity(0.1),
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
                    color: isHighPriority ? Colors.red.shade700 : AppTheme.textPrimary,
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
