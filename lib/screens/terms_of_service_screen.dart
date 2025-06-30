import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
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
                  'Terms of Service',
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
                _buildSectionTitle('1. Acceptance of Terms'),
                _buildParagraph(
                  'By accessing or using the Agrotech Fire Detection application, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, you may not access the application.'
                ),
                
                const SizedBox(height: 16),
                _buildSectionTitle('2. Use License'),
                _buildParagraph(
                  'Permission is granted to temporarily use the application for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:'
                ),
                _buildBulletPoint('Modify or copy the materials'),
                _buildBulletPoint('Use the materials for any commercial purpose'),
                _buildBulletPoint('Attempt to decompile or reverse engineer any software contained in the application'),
                _buildBulletPoint('Remove any copyright or other proprietary notations from the materials'),
                _buildBulletPoint('Transfer the materials to another person or "mirror" the materials on any other server'),
                
                const SizedBox(height: 16),
                _buildSectionTitle('3. Disclaimer'),
                _buildParagraph(
                  'The materials on Agrotech Fire Detection\'s application are provided on an \'as is\' basis. Agrotech Fire Detection makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.'
                ),
                
                const SizedBox(height: 16),
                _buildSectionTitle('4. Limitations'),
                _buildParagraph(
                  'In no event shall Agrotech Fire Detection or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Agrotech Fire Detection\'s application, even if Agrotech Fire Detection or an authorized representative has been notified orally or in writing of the possibility of such damage.'
                ),
                
                const SizedBox(height: 16),
                _buildSectionTitle('5. Accuracy of Materials'),
                _buildParagraph(
                  'The materials appearing on Agrotech Fire Detection\'s application could include technical, typographical, or photographic errors. Agrotech Fire Detection does not warrant that any of the materials on its application are accurate, complete, or current. Agrotech Fire Detection may make changes to the materials contained on its application at any time without notice.'
                ),
                
                const SizedBox(height: 16),
                _buildSectionTitle('6. Links'),
                _buildParagraph(
                  'Agrotech Fire Detection has not reviewed all of the sites linked to its application and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by Agrotech Fire Detection of the site. Use of any such linked website is at the user\'s own risk.'
                ),
                
                const SizedBox(height: 16),
                _buildSectionTitle('7. Modifications'),
                _buildParagraph(
                  'Agrotech Fire Detection may revise these terms of service for its application at any time without notice. By using this application, you are agreeing to be bound by the then current version of these terms of service.'
                ),
                
                const SizedBox(height: 16),
                _buildSectionTitle('8. Governing Law'),
                _buildParagraph(
                  'These terms and conditions are governed by and construed in accordance with the laws of the United States and you irrevocably submit to the exclusive jurisdiction of the courts in that location.'
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
}
