import 'package:flutter/material.dart';
import 'package:coffee_house_pos/core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
              color: AppTheme.pink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.privacy_tip,
                      color: AppTheme.pink,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Policy',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.pink,
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

          // Introduction
          _buildSection(
            theme,
            'Introduction',
            'Coffee House POS ("we", "our", or "us") is committed to protecting your '
                'privacy. This Privacy Policy explains how we collect, use, disclose, and '
                'safeguard your information when you use our mobile application.',
          ),

          // 1. Information We Collect
          _buildSection(
            theme,
            '1. Information We Collect',
            'We collect information that you provide directly to us, including:\n\n'
                'Personal Information:\n'
                '• Full name\n'
                '• Email address\n'
                '• Google account information (when signing in with Google)\n'
                '• Profile picture (optional)\n\n'
                'Order Information:\n'
                '• Order history and details\n'
                '• Product preferences and customizations\n'
                '• Order timestamps and status\n\n'
                'Device Information:\n'
                '• Device type and model\n'
                '• Operating system version\n'
                '• Unique device identifiers\n'
                '• Network connection type',
          ),

          // 2. How We Use Your Information
          _buildSection(
            theme,
            '2. How We Use Your Information',
            'We use the information we collect to:\n\n'
                '• Process and fulfill your orders\n'
                '• Provide customer support and respond to inquiries\n'
                '• Send order confirmations and status updates\n'
                '• Maintain and improve our services\n'
                '• Analyze usage patterns and app performance\n'
                '• Prevent fraud and enhance security\n'
                '• Comply with legal obligations\n'
                '• Personalize your experience',
          ),

          // 3. Information Sharing
          _buildSection(
            theme,
            '3. Information Sharing and Disclosure',
            'We do not sell your personal information. We may share your information with:\n\n'
                'Service Providers:\n'
                '• Cloud hosting services (AppWrite)\n'
                '• Authentication providers (Google Sign-In)\n'
                '• Analytics services\n\n'
                'Business Transfers:\n'
                '• In connection with any merger, sale, or acquisition\n\n'
                'Legal Requirements:\n'
                '• When required by law or legal process\n'
                '• To protect our rights and property\n'
                '• To prevent fraud or security threats',
          ),

          // 4. Data Storage and Security
          _buildSection(
            theme,
            '4. Data Storage and Security',
            'We implement appropriate security measures to protect your information:\n\n'
                '• Encrypted data transmission (HTTPS/TLS)\n'
                '• Secure cloud storage with AppWrite\n'
                '• Regular security audits and updates\n'
                '• Access controls and authentication\n'
                '• Data backup and disaster recovery\n\n'
                'However, no method of transmission over the internet is 100% secure. '
                'While we strive to protect your information, we cannot guarantee absolute security.',
          ),

          // 5. Data Retention
          _buildSection(
            theme,
            '5. Data Retention',
            'We retain your personal information for as long as necessary to:\n\n'
                '• Provide our services to you\n'
                '• Comply with legal obligations\n'
                '• Resolve disputes and enforce agreements\n'
                '• Maintain business records\n\n'
                'Order history is retained for accounting and tax purposes. '
                'You may request deletion of your account and personal data at any time.',
          ),

          // 6. Your Privacy Rights
          _buildSection(
            theme,
            '6. Your Privacy Rights',
            'You have the following rights regarding your personal information:\n\n'
                'Access: Request a copy of your personal data\n'
                'Correction: Update or correct inaccurate information\n'
                'Deletion: Request deletion of your account and data\n'
                'Objection: Object to certain data processing activities\n'
                'Portability: Receive your data in a portable format\n'
                'Withdraw Consent: Withdraw consent for data processing\n\n'
                'To exercise these rights, please contact us using the information below.',
          ),

          // 7. Cookies and Tracking
          _buildSection(
            theme,
            '7. Cookies and Tracking Technologies',
            'We use local storage and caching to:\n\n'
                '• Remember your preferences and settings\n'
                '• Cache menu items for faster loading\n'
                '• Store cart data locally\n'
                '• Enable offline functionality\n'
                '• Improve app performance\n\n'
                'You can clear this data through your device settings or by uninstalling the app.',
          ),

          // 8. Third-Party Services
          _buildSection(
            theme,
            '8. Third-Party Services',
            'Our app uses third-party services that may collect information:\n\n'
                'Google Sign-In:\n'
                '• Governed by Google\'s Privacy Policy\n'
                '• Used for authentication only\n'
                '• We only receive basic profile information\n\n'
                'AppWrite (Cloud Backend):\n'
                '• Hosts our database and storage\n'
                '• Complies with data protection regulations\n'
                '• Data stored in secure data centers',
          ),

          // 9. Children's Privacy
          _buildSection(
            theme,
            '9. Children\'s Privacy',
            'Our services are not intended for children under 13 years of age. '
                'We do not knowingly collect personal information from children under 13. '
                'If you believe we have collected information from a child under 13, '
                'please contact us immediately.',
          ),

          // 10. International Data Transfers
          _buildSection(
            theme,
            '10. International Data Transfers',
            'Your information may be transferred to and processed in countries other '
                'than your country of residence. These countries may have different data '
                'protection laws. By using our services, you consent to such transfers.',
          ),

          // 11. Changes to Privacy Policy
          _buildSection(
            theme,
            '11. Changes to This Privacy Policy',
            'We may update this Privacy Policy from time to time. We will notify you '
                'of any changes by:\n\n'
                '• Posting the new policy in the app\n'
                '• Updating the "Last updated" date\n'
                '• Sending an in-app notification (for material changes)\n\n'
                'Your continued use of the app after changes constitutes acceptance of '
                'the updated policy.',
          ),

          // 12. Contact Us
          _buildSection(
            theme,
            '12. Contact Us',
            'If you have questions, concerns, or requests regarding this Privacy Policy '
                'or your personal information, please contact us:\n\n'
                'Email: privacy@coffeehousepos.com\n'
                'Phone: +62 812-3456-7890\n'
                'Address: Jl. Coffee Street No. 123, Jakarta, Indonesia\n\n'
                'Data Protection Officer:\n'
                'Email: dpo@coffeehousepos.com',
          ),

          const SizedBox(height: 32),

          // Privacy Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.blue.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.security,
                  color: AppTheme.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your privacy and data security are our top priorities. We are committed '
                    'to handling your information responsibly and transparently.',
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
