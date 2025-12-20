import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coffee_house_pos/core/theme/app_theme.dart';
import 'package:coffee_house_pos/features/auth/presentation/providers/auth_provider.dart';
import 'package:coffee_house_pos/features/customer/profile/presentation/providers/profile_provider.dart';
import 'package:coffee_house_pos/features/customer/shared/widgets/customer_bottom_nav.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final statsAsync = ref.watch(profileStatsProvider);
    final userDataAsync = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(profileStatsProvider);
              ref.invalidate(userDataProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: authState.when(
        data: (state) {
          if (state is! AuthStateAuthenticated) {
            return const Center(
              child: Text('Please login to view profile'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(profileStatsProvider);
              ref.invalidate(userDataProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Info Card
                  userDataAsync.when(
                    data: (userData) => _buildUserInfoCard(
                        context, theme, state.user, userData),
                    loading: () =>
                        _buildUserInfoCard(context, theme, state.user, null),
                    error: (_, __) =>
                        _buildUserInfoCard(context, theme, state.user, null),
                  ),
                  const SizedBox(height: 16),

                  // Statistics Cards
                  statsAsync.when(
                    data: (stats) => _buildStatisticsSection(theme, stats),
                    loading: () => _buildLoadingStats(theme),
                    error: (_, __) => _buildErrorStats(theme),
                  ),
                  const SizedBox(height: 16),

                  // Settings Section
                  _buildSettingsSection(context, theme, ref),
                  const SizedBox(height: 16),

                  // About Section
                  _buildAboutSection(context, theme),
                  const SizedBox(height: 16),

                  // Logout Button
                  _buildLogoutButton(context, theme, ref),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 2),
    );
  }

  Widget _buildUserInfoCard(
      BuildContext context, ThemeData theme, dynamic user, UserData? userData) {
    final userName = user.name ?? 'User';
    final userEmail = user.email ?? '';
    final userPhone = userData?.phone ?? '';
    final userPhoto = userData?.photoUrl ?? '';

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          print('🔄 Navigating to /customer/profile/edit');
          try {
            context.push('/customer/profile/edit');
          } catch (e) {
            print('❌ Navigation error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Avatar with gradient border
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.peach,
                      AppTheme.mauve,
                      AppTheme.teal,
                    ],
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.surface,
                  backgroundImage: userPhoto.isNotEmpty
                      ? CachedNetworkImageProvider(userPhoto)
                      : null,
                  child: userPhoto.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: AppTheme.peach,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // User Name
              Text(
                userName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // User Email
              Text(
                userEmail,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),

              // User Phone (if available)
              if (userPhone.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      userPhone,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(ThemeData theme, ProfileStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Statistics',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.receipt_long,
                label: 'Total Orders',
                value: stats.totalOrders.toString(),
                color: AppTheme.peach,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.payments,
                label: 'Total Spent',
                value:
                    'Rp ${NumberFormat('#,##0', 'id_ID').format(stats.totalSpent)}',
                color: AppTheme.mauve,
                isSmallValue: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.hourglass_empty,
                label: 'Pending',
                value: stats.pendingOrders.toString(),
                color: AppTheme.yellow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.check_circle,
                label: 'Completed',
                value: stats.completedOrders.toString(),
                color: AppTheme.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isSmallValue = false,
  }) {
    return Card(
      elevation: 2,
      color: theme.brightness == Brightness.dark
          ? color.withOpacity(0.1)
          : theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: theme.brightness == Brightness.dark ? color : color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark
                    ? color
                    : theme.colorScheme.onSurface,
                fontSize: isSmallValue ? 16 : 24,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStats(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                child: Container(
                  height: 120,
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Container(
                  height: 120,
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorStats(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Failed to load statistics',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
      BuildContext context, ThemeData theme, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Settings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          elevation: 2,
          child: Column(
            children: [
              // Theme Toggle
              ListTile(
                leading: const Icon(
                  Icons.brightness_6,
                  color: AppTheme.yellow,
                ),
                title: const Text('Theme'),
                subtitle: Text(
                  themeMode == ThemeMode.dark
                      ? 'Dark (Mocha)'
                      : 'Light (Latte)',
                ),
                trailing: Switch(
                  value: themeMode == ThemeMode.light,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                  activeThumbColor: AppTheme.peach,
                ),
              ),
              Divider(
                height: 1,
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),

              // Notifications
              ListTile(
                leading: const Icon(
                  Icons.notifications,
                  color: AppTheme.blue,
                ),
                title: const Text('Notifications'),
                subtitle: const Text('View all notifications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push('/customer/notifications');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'About',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          elevation: 2,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.info,
                  color: AppTheme.sky,
                ),
                title: const Text('About App'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Coffee House POS',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(
                      Icons.coffee,
                      size: 48,
                      color: AppTheme.peach,
                    ),
                    children: [
                      const Text(
                        'A modern point-of-sale system for coffee houses, '
                        'built with Flutter and powered by AppWrite.',
                      ),
                    ],
                  );
                },
              ),
              Divider(
                height: 1,
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),
              ListTile(
                leading: const Icon(
                  Icons.description,
                  color: AppTheme.lavender,
                ),
                title: const Text('Terms & Conditions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push('/customer/terms');
                },
              ),
              Divider(
                height: 1,
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),
              ListTile(
                leading: const Icon(
                  Icons.privacy_tip,
                  color: AppTheme.pink,
                ),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push('/customer/privacy');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(
      BuildContext context, ThemeData theme, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.logout),
      label: const Text('Logout'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 0),
      ),
    );
  }
}
