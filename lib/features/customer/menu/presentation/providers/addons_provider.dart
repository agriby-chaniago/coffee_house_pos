import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../../core/config/appwrite_config.dart';
import '../../../../admin/inventory/data/models/addon_model.dart';

// Fetch all active addons
final addonsProvider = FutureProvider<List<AddOn>>((ref) async {
  try {
    // Try to load from Hive first (cache) - use singleton box
    Box box;
    try {
      box = Hive.box('addons_cache');
    } catch (e) {
      // Box not opened yet, open it
      box = await Hive.openBox('addons_cache');
    }

    final cachedData = box.get('addons');

    if (cachedData != null && cachedData is List) {
      final List<AddOn> cached = cachedData
          .map((e) => AddOn.fromJson(Map<String, dynamic>.from(e as Map)))
          .cast<AddOn>()
          .toList();

      // Check if cached data has valid IDs
      final hasValidIds = cached.isNotEmpty && cached.first.id != null;

      // Return cached data only if it has valid IDs
      if (cached.isNotEmpty && hasValidIds) {
        print('✅ Using cached add-ons with valid IDs');
        // Fetch new data in background
        _fetchAndCacheAddons(box);
        return cached;
      } else if (cached.isNotEmpty) {
        print('⚠️ Cached add-ons have null IDs, re-fetching...');
      }
    }

    // No cache or invalid cache, fetch from AppWrite
    return await _fetchAndCacheAddons(box);
  } catch (e) {
    throw Exception('Failed to load addons: $e');
  }
});

Future<List<AddOn>> _fetchAndCacheAddons(Box box) async {
  try {
    final client = Client()
        .setEndpoint(AppwriteConfig.endpoint)
        .setProject(AppwriteConfig.projectId);
    final databases = Databases(client);

    print('📡 Fetching add-ons from AppWrite...');
    final response = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.addonsCollection,
      queries: [
        Query.equal('isActive', true),
        Query.orderAsc('sortOrder'),
        Query.limit(100),
      ],
    );

    print('✅ Fetched ${response.documents.length} add-ons from AppWrite');

    final addons = response.documents.map((doc) {
      final data = Map<String, dynamic>.from(doc.data);
      data['\$id'] = doc.$id;
      print('   📦 Processing addon: ${doc.$id} - ${data['name']}');
      return AddOn.fromJson(data);
    }).toList();

    // Save to cache
    await box.put('addons', addons.map((a) => a.toJson()).toList());
    print('💾 Cached ${addons.length} add-ons');

    return addons;
  } catch (e) {
    print('❌ Error fetching add-ons: $e');
    // Return empty list if fetch fails
    return [];
  }
}

// Get addons for specific IDs
final addonsByIdsProvider = Provider.family<List<AddOn>, List<String>>(
  (ref, addonIds) {
    final allAddons = ref.watch(addonsProvider);

    return allAddons.when(
      data: (addons) {
        return addons.where((addon) => addonIds.contains(addon.id)).toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );
  },
);

// Get addons grouped by category
final addonsByCategoryProvider = Provider<Map<String, List<AddOn>>>(
  (ref) {
    final allAddons = ref.watch(addonsProvider);

    return allAddons.when(
      data: (addons) {
        final grouped = <String, List<AddOn>>{};

        for (final addon in addons) {
          grouped.putIfAbsent(addon.category, () => []).add(addon);
        }

        return grouped;
      },
      loading: () => {},
      error: (_, __) => {},
    );
  },
);
