import 'package:flutter/material.dart';
import 'package:coffee_house_pos/core/theme/app_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lavender.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.description,
                      color: AppTheme.lavender,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terms & Conditions',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.lavender,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last updated: December 19, 2025',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 1. Introduction
          _buildSection(
            theme,
            '1. Introduction',
            'Welcome to Coffee House POS. By accessing or using our mobile application, '
                'you agree to be bound by these Terms and Conditions. If you do not agree '
                'with any part of these terms, please do not use our application.',
          ),

          // 2. Service Description
          _buildSection(
            theme,
            '2. Service Description',
            'Coffee House POS is a point-of-sale application that allows customers to:\n'
                '• Browse menu items and products\n'
                '• Place orders with customizations\n'
                '• Track order status in real-time\n'
                '• View order history and receipts\n'
                '• Manage profile and preferences',
          ),

          // 3. User Accounts
          _buildSection(
            theme,
            '3. User Accounts',
            'To use our services, you must:\n'
                '• Be at least 13 years of age\n'
                '• Provide accurate registration information\n'
                '• Maintain the security of your account credentials\n'
                '• Notify us immediately of any unauthorized access\n'
                '• Accept responsibility for all activities under your account',
          ),

          // 4. Orders and Payments
          _buildSection(
            theme,
            '4. Orders and Payments',
            'When placing an order:\n'
                '• All prices are displayed in Indonesian Rupiah (IDR)\n'
                '• Orders are subject to product availability\n'
                '• We reserve the right to refuse or cancel any order\n'
                '• Payment is processed securely through our system\n'
                '• Tax (PPN 11%) is automatically calculated and added\n'
                '• Once confirmed, orders cannot be cancelled',
          ),

          // 5. Product Information
          _buildSection(
            theme,
            '5. Product Information',
            'We strive to provide accurate product information including:\n'
                '• Product names and descriptions\n'
                '• Prices and available sizes\n'
                '• Available add-ons and customizations\n'
                '• Product images (for illustration purposes)\n\n'
                'However, we do not guarantee that product descriptions, images, or '
                'other content are accurate, complete, or error-free.',
          ),

          // 6. User Conduct
          _buildSection(
            theme,
            '6. User Conduct',
            'You agree NOT to:\n'
                '• Use the app for any illegal purposes\n'
                '• Attempt to gain unauthorized access to our systems\n'
                '• Interfere with the proper functioning of the app\n'
                '• Upload viruses or malicious code\n'
                '• Impersonate another person or entity\n'
                '• Harass, abuse, or harm other users or staff',
          ),

          // 7. Intellectual Property
          _buildSection(
            theme,
            '7. Intellectual Property',
            'All content in this application, including but not limited to:\n'
                '• Text, graphics, logos, and images\n'
                '• Software and code\n'
                '• Design and layout\n'
                '• Trademarks and brand names\n\n'
                'are the property of Coffee House POS and are protected by copyright, '
                'trademark, and other intellectual property laws.',
          ),

          // 8. Privacy and Data
          _buildSection(
            theme,
            '8. Privacy and Data',
            'Your privacy is important to us. Our collection and use of personal '
                'information is governed by our Privacy Policy. By using the app, you '
                'consent to our collection, use, and disclosure of personal information '
                'as described in the Privacy Policy.',
          ),

          // 9. Limitation of Liability
          _buildSection(
            theme,
            '9. Limitation of Liability',
            'To the fullest extent permitted by law, Coffee House POS shall not be '
                'liable for any:\n'
                '• Indirect, incidental, or consequential damages\n'
                '• Loss of profits, data, or business opportunities\n'
                '• Service interruptions or technical issues\n'
                '• Errors or omissions in content\n'
                '• Actions of third parties',
          ),

          // 10. Modifications
          _buildSection(
            theme,
            '10. Modifications to Terms',
            'We reserve the right to modify these Terms and Conditions at any time. '
                'Changes will be effective immediately upon posting in the app. Your '
                'continued use of the app after changes constitutes acceptance of the '
                'modified terms.',
          ),

          // 11. Termination
          _buildSection(
            theme,
            '11. Account Termination',
            'We may terminate or suspend your account and access to the app at any '
                'time, without prior notice, for conduct that we believe:\n'
                '• Violates these Terms and Conditions\n'
                '• Is harmful to other users or our business\n'
                '• Exposes us to liability\n'
                '• Is otherwise inappropriate',
          ),

          // 12. Governing Law
          _buildSection(
            theme,
            '12. Governing Law',
            'These Terms and Conditions are governed by and construed in accordance '
                'with the laws of the Republic of Indonesia. Any disputes arising from '
                'these terms shall be subject to the exclusive jurisdiction of the courts '
                'of Indonesia.',
          ),

          // 13. Contact
          _buildSection(
            theme,
            '13. Contact Information',
            'If you have any questions about these Terms and Conditions, please contact us:\n\n'
                'Email: support@coffeehousepos.com\n'
                'Phone: +62 812-3456-7890\n'
                'Address: Jl. Coffee Street No. 123, Jakarta, Indonesia',
          ),

          const SizedBox(height: 32),

          // Acceptance Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'By using Coffee House POS, you acknowledge that you have read, '
                    'understood, and agree to be bound by these Terms and Conditions.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
