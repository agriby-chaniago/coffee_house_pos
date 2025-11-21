import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coffee_house_pos/core/services/offline_sync_manager.dart';

// Connectivity status stream
final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

// Sync state
enum SyncState {
  idle,
  syncing,
  error,
}

class SyncStatus {
  final SyncState state;
  final bool isOnline;
  final int pendingCount;
  final String? errorMessage;

  const SyncStatus({
    required this.state,
    required this.isOnline,
    required this.pendingCount,
    this.errorMessage,
  });

  SyncStatus copyWith({
    SyncState? state,
    bool? isOnline,
    int? pendingCount,
    String? errorMessage,
  }) {
    return SyncStatus(
      state: state ?? this.state,
      isOnline: isOnline ?? this.isOnline,
      pendingCount: pendingCount ?? this.pendingCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  final OfflineSyncManager _syncManager;

  SyncStatusNotifier(this._syncManager)
      : super(const SyncStatus(
          state: SyncState.idle,
          isOnline: false,
          pendingCount: 0,
        ));

  void updateConnectivity(bool isOnline) {
    state = state.copyWith(isOnline: isOnline);
  }

  void updatePendingCount(int count) {
    state = state.copyWith(pendingCount: count);
  }

  void setSyncing() {
    state = state.copyWith(
      state: SyncState.syncing,
      errorMessage: null,
    );
  }

  void setSyncComplete() {
    state = state.copyWith(
      state: SyncState.idle,
      pendingCount: _syncManager.getPendingCount(),
      errorMessage: null,
    );
  }

  void setSyncError(String error) {
    state = state.copyWith(
      state: SyncState.error,
      errorMessage: error,
    );
  }

  Future<void> manualSync() async {
    if (state.state == SyncState.syncing) return;

    try {
      setSyncing();
      await _syncManager.syncAll();
      setSyncComplete();
    } catch (e) {
      setSyncError(e.toString());
    }
  }

  void refreshStatus() {
    state = state.copyWith(
      isOnline: _syncManager.isOnline,
      pendingCount: _syncManager.getPendingCount(),
      state: _syncManager.isSyncing ? SyncState.syncing : SyncState.idle,
    );
  }
}

// Singleton sync manager provider
final syncManagerProvider = Provider<OfflineSyncManager>((ref) {
  return OfflineSyncManager();
});

// Sync status provider
final syncStatusProvider =
    StateNotifierProvider<SyncStatusNotifier, SyncStatus>((ref) {
  final syncManager = ref.watch(syncManagerProvider);
  return SyncStatusNotifier(syncManager);
});
