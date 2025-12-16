import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_house_pos/core/providers/sync_status_provider.dart';

/// Widget to show offline/sync status indicator
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);

    // Only show if offline or has pending items
    if (syncStatus.isOnline && syncStatus.pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: syncStatus.isOnline
            ? Colors.orange.withOpacity(0.9)
            : Colors.red.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            syncStatus.isOnline ? Icons.sync : Icons.cloud_off,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            syncStatus.isOnline
                ? 'Syncing ${syncStatus.pendingCount} items...'
                : 'Offline (${syncStatus.pendingCount} pending)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner widget for offline status (persistent at top)
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);

    if (syncStatus.isOnline) {
      return const SizedBox.shrink();
    }

    return MaterialBanner(
      backgroundColor: Colors.red.shade700,
      leading: const Icon(Icons.cloud_off, color: Colors.white),
      content: Text(
        'You are offline. ${syncStatus.pendingCount} changes will sync when reconnected.',
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Try to sync manually
            ref.read(syncStatusProvider.notifier).triggerSync();
          },
          child: const Text(
            'RETRY',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
