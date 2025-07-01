import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agrotech Fire Detection Privacy Policy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last Updated: July 1, 2025',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('1. Introduction'),
                _buildParagraph(
                  'Welcome to Agrotech Fire Detection. This application was developed by our team as part of an Internet of Things (IoT) project. We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.'
                ),
                
                const SizedBox(height: 16),
                _buildSectionTitle('2. Information We Collect'),
                _buildParagraph(
                  'We collect several types of information for various purposes to provide and improve our service to you:'
                ),
                _buildBulletPoint('Location data to provide mapping services'),
                _buildBulletPoint('Device information for optimization and troubleshooting'),
                _buildBulletPoint('Usage data to improve our application'),
                _buildBulletPoint('Sensor data from connected devices'),
                
                const SizedBox(height: 16),
                _buildSectionTitle('3. How We Use Your Information'),
                _buildParagraph(
                  'We use the collected data for various purposes:'
                ),
                _buildBulletPoint('To provide and maintain our service'),
                _buildBulletPoint('To notify you about changes to our service'),
                _buildBulletPoint('To provide customer support'),
                _buildBulletPoint('To monitor the usage of our service'),
                _buildBulletPoint('To detect, prevent and address technical issues'),
                
                const SizedBox(height: 16),
                _buildSectionTitle('4. Data Security'),
                _buildParagraph(
                  'The security of your data is important to us. We strive to use commercially acceptable means to protect your personal information, but we cannot guarantee its absolute security. We implement various security measures to maintain the safety of your personal information.'
                ),
                
                const SizedBox(height: 16),
                _buildSectionTitle('5. Your Data Rights'),
                _buildParagraph(
                  'You have the right to:'
                ),
                _buildBulletPoint('Access the personal information we hold about you'),
                _buildBulletPoint('Request correction of your personal information'),
                _buildBulletPoint('Request deletion of your personal information'),
                _buildBulletPoint('Object to processing of your personal information'),
                _buildBulletPoint('Request restriction of processing your personal information'),
                
                const SizedBox(height: 16),
                _buildSectionTitle('6. Changes to This Privacy Policy'),
                _buildParagraph(
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date. You are advised to review this Privacy Policy periodically for any changes.'
                ),
                
                const SizedBox(height: 16),
                _buildSectionTitle('7. Contact Us'),
                _buildParagraph(
                  'If you have any questions about this Privacy Policy, please contact our development team:'
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.group_rounded,
                            color: AppTheme.primaryGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Development Team:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildEmailContactItem('codewithwan@gmail.com'),
                      _buildEmailContactItem('muhammadzaky034@gmail.com'),
                      _buildEmailContactItem('ardanferdiansah03@gmail.com'),
                      _buildEmailContactItem('rafiiqbal2407@gmail.com'),
                      _buildEmailContactItem('tsabitahhilyatul@gmail.com'),
                      _buildEmailContactItem('ayeshacha177@gmail.com'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailContactItem(String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(
            Icons.email_outlined,
            size: 16,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              email,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
