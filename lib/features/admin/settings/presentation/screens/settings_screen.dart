import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:coffee_house_pos/core/theme/app_theme.dart';
import 'package:coffee_house_pos/features/auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'change_password_screen.dart';
import 'package:coffee_house_pos/features/admin/pos/presentation/providers/cart_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _storeNameController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _storePhoneController = TextEditingController();

  String _appVersion = '';
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadUserEmail();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  Future<void> _loadUserEmail() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.getCurrentUser();
      if (mounted) {
        setState(() {
          _userEmail = user?.email;
        });
      }
    } catch (e) {
      print('Error loading user email: $e');
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeAddressController.dispose();
    _storePhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final storeInfo = ref.watch(storeInfoProvider);

    // Update controllers when store info changes
    if (_storeNameController.text != storeInfo.name) {
      _storeNameController.text = storeInfo.name;
    }
    if (_storeAddressController.text != storeInfo.address) {
      _storeAddressController.text = storeInfo.address;
    }
    if (_storePhoneController.text != storeInfo.phone) {
      _storePhoneController.text = storeInfo.phone;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          Text(
            'Account',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: const Text('Email'),
                  subtitle: Text(_userEmail ?? 'Loading...'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Store Info Section
          Text(
            'Store Information',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Store Name', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _storeNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Enter store name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Address', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _storeAddressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Enter store address',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Text('Phone', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _storePhoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Enter store phone',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saveStoreInfo,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Store Info'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Appearance Section
          Text(
            'Appearance',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              secondary: Icon(
                themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              title: const Text('Theme'),
              subtitle: Text(
                themeMode == ThemeMode.dark
                    ? 'Catppuccin Mocha (Dark)'
                    : 'Catppuccin Latte (Light)',
              ),
              value: themeMode == ThemeMode.light,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          Text(
            'About',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App Version'),
              trailing: Text(
                _appVersion.isEmpty ? 'Loading...' : _appVersion,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _saveStoreInfo() async {
    // Validate inputs
    if (_storeNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Store name cannot be empty'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Show confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Changes?'),
        content: const Text('Update store information?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(storeInfoProvider.notifier).updateStoreInfo(
          name: _storeNameController.text.trim(),
          address: _storeAddressController.text.trim(),
          phone: _storePhoneController.text.trim(),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store information saved successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Show loading
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logging out...'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        // Sign out using auth notifier
        await ref.read(authNotifierProvider.notifier).signOut();

        // Navigate to login
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
