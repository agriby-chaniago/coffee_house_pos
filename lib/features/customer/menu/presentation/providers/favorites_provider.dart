import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Favorites Provider with Hive persistence (per-user)
class FavoritesNotifier extends StateNotifier<Set<String>> {
  late final Box _box;
  bool _isInitialized = false;
  final String? userId;

  FavoritesNotifier(this.userId) : super({}) {
    _initBox();
  }

  Future<void> _initBox() async {
    try {
      _box = await Hive.openBox('favorites');
      _isInitialized = true;
      print('✅ Favorites box initialized');
      await _loadFavorites();
    } catch (e) {
      print('❌ Error initializing favorites box: $e');
      _isInitialized = false;
    }
  }

  Future<void> _loadFavorites() async {
    if (!_isInitialized) {
      print('⚠️ Box not initialized yet, cannot load favorites');
      return;
    }
    if (userId == null) {
      print('⚠️ No userId, cannot load favorites');
      return;
    }
    try {
      final key = 'user_${userId}_favorites';
      final favoritesList = _box.get(key, defaultValue: <String>[]);
      print('📦 Loading favorites for user $userId from Hive: $favoritesList');
      if (favoritesList is List) {
        state = Set<String>.from(favoritesList.map((e) => e.toString()));
        print('✅ Loaded ${state.length} favorites: $state');
      }
    } catch (e) {
      print('❌ Error loading favorites: $e');
      state = {};
    }
  }

  Future<void> _saveFavorites() async {
    if (!_isInitialized) {
      print('⚠️ Box not initialized yet, cannot save favorites');
      return;
    }
    if (userId == null) {
      print('⚠️ No userId, cannot save favorites');
      return;
    }
    try {
      final key = 'user_${userId}_favorites';
      await _box.put(key, state.toList());
      print('💾 Saved favorites for user $userId to Hive: ${state.toList()}');
    } catch (e) {
      print('❌ Error saving favorites: $e');
    }
  }

  /// Toggle favorite status
  void toggleFavorite(String productId) {
    print('═══════════════════════════════════════');
    print('🔄 Toggling favorite for: $productId');
    print('📊 Current state before toggle: $state');
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
      print('❌ Removed from favorites');
    } else {
      state = {...state, productId};
      print('✅ Added to favorites');
    }
    print('📊 Current state after toggle: $state');
    print('📊 Total favorites: ${state.length}');
    print('═══════════════════════════════════════');
    _saveFavorites();
  }

  /// Check if product is favorite
  bool isFavorite(String productId) {
    final result = state.contains(productId);
    print('🔍 Checking if $productId is favorite: $result (state: $state)');
    return result;
  }

  /// Clear all favorites
  void clearAll() {
    state = {};
    _saveFavorites();
  }
}

final favoritesProvider =
    StateNotifierProvider.family<FavoritesNotifier, Set<String>, String?>(
        (ref, userId) {
  return FavoritesNotifier(userId);
});

/// Provider to get count of favorites
final favoritesCountProvider = Provider.family<int, String?>((ref, userId) {
  final favorites = ref.watch(favoritesProvider(userId));
  return favorites.length;
});
