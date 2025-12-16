import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/appwrite_service.dart';
import '../../../../../core/services/hive_service.dart';
import '../../../../../core/config/appwrite_config.dart';
import '../../../../customer/menu/data/models/addon_model.dart';

final addonsProvider = FutureProvider<List<AddOn>>((ref) async {
  final appwrite = ref.watch(appwriteProvider);

  try {
    // Try to fetch from AppWrite first
    print('Fetching addons from AppWrite...');
    final response = await appwrite.databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.addonsCollection,
    );

    print(
        'Successfully fetched ${response.documents.length} addons from AppWrite');

    final addons = <AddOn>[];
    for (var i = 0; i < response.documents.length; i++) {
      try {
        final doc = response.documents[i];
        print('Parsing addon ${i + 1}: ${doc.data['name']}');
        final addon = AddOn.fromJson(doc.data);
        addons.add(addon);
      } catch (e, stackTrace) {
        print('Error parsing addon ${i + 1}: $e');
        print('Addon data: ${response.documents[i].data}');
        print('Stack trace: $stackTrace');
        // Continue parsing other addons
      }
    }

    print('Successfully parsed ${addons.length} addons');

    // Cache to Hive for offline use
    final box = HiveService.getAddonsBox();
    for (final addon in addons) {
      await box.put(addon.id, addon.toJson());
    }

    return addons;
  } catch (e) {
    // Fallback to Hive if offline
    print('Failed to fetch addons from AppWrite: $e');
    final box = HiveService.getAddonsBox();
    if (box.isNotEmpty) {
      final cachedAddons = box.values
          .map((json) => AddOn.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return cachedAddons;
    }
    return [];
  }
});

final addonsByCategoryProvider =
    FutureProvider.family<List<AddOn>, String>((ref, category) async {
  final allAddons = await ref.watch(addonsProvider.future);
  if (category.isEmpty) return allAddons;
  return allAddons.where((a) => a.category == category).toList();
});

final addonsForProductProvider =
    FutureProvider.family<List<AddOn>, List<String>>((ref, addonIds) async {
  final allAddons = await ref.watch(addonsProvider.future);
  return allAddons.where((a) => addonIds.contains(a.id) && a.isActive).toList();
});
