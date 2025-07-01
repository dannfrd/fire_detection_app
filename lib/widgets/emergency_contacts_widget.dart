import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_theme.dart';

class EmergencyContactsWidget extends StatelessWidget {
  final bool isFireDetected;
  final bool compactMode;
  
  const EmergencyContactsWidget({
    super.key,
    required this.isFireDetected,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: compactMode ? 8 : 12, 
              horizontal: compactMode ? 16 : 20
            ),
            decoration: BoxDecoration(
              color: isFireDetected ? Colors.red : AppTheme.primaryGreen,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isFireDetected ? Icons.emergency : Icons.contacts,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  isFireDetected ? 'KONTAK DARURAT' : 'Kontak Penting',
                  style: TextStyle(
                    fontSize: compactMode ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compactMode ? 12 : 16),
            child: Column(
              children: [
                _buildContactItem(
                  'Pemadam Kebakaran',
                  '113',
                  Icons.fire_truck,
                  isPriority: isFireDetected,
                  onTap: () => _makePhoneCall('113'),
                ),
                _buildDivider(),
                _buildContactItem(
                  'Ambulans',
                  '118 / 119',
                  Icons.emergency,
                  isPriority: isFireDetected,
                  onTap: () => _makePhoneCall('118'),
                ),
                _buildDivider(),
                _buildContactItem(
                  'Polisi',
                  '110',
                  Icons.local_police,
                  onTap: () => _makePhoneCall('110'),
                ),
                _buildDivider(),
                _buildContactItem(
                  'Pusat Layanan Gas',
                  '1500-645',
                  Icons.gas_meter,
                  onTap: () => _makePhoneCall('1500645'),
                ),
                _buildDivider(),
                _buildContactItem(
                  'Call Center BPBD',
                  '112',
                  Icons.support_agent,
                  onTap: () => _makePhoneCall('112'),
                ),
              ],
            ),
          ),
          if (isFireDetected)
            Padding(
              padding: EdgeInsets.only(
                bottom: compactMode ? 12 : 16,
                left: compactMode ? 12 : 16,
                right: compactMode ? 12 : 16
              ),
              child: ElevatedButton.icon(
                onPressed: () => _makePhoneCall('113'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.emergency_share),
                label: const Text(
                  'HUBUNGI PEMADAM KEBAKARAN SEKARANG',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildContactItem(String name, String number, IconData icon, {bool isPriority = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPriority 
                    ? Colors.red.withOpacity(0.1) 
                    : AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isPriority ? Colors.red : AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isPriority ? FontWeight.bold : FontWeight.w500,
                      color: isPriority ? Colors.red : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    number,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.phone_enabled,
              color: isPriority ? Colors.red : AppTheme.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 60);
  }
  
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint('Could not launch $launchUri: $e');
    }
  }
}
