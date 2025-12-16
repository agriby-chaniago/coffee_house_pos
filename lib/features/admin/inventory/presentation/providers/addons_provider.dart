import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/config/appwrite_config.dart';
import '../../../../../core/services/appwrite_service.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../data/models/addon_model.dart';

// Add-on list provider
final addonsProvider = FutureProvider.autoDispose<List<AddOn>>((ref) async {
  final appwrite = ref.watch(appwriteProvider);

  try {
    print('🔄 Fetching add-ons from AppWrite...');
    final response = await appwrite.databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.addonsCollection,
      queries: [
        Query.orderAsc('sortOrder'),
        Query.limit(100),
      ],
    );

    print('✅ Fetched ${response.documents.length} add-ons');

    final addons = response.documents.map((doc) {
      return AddOn.fromJson({...doc.data, '\$id': doc.$id});
    }).toList();

    return addons;
  } catch (e) {
    print('❌ Error fetching add-ons: $e');
    final userMessage = ErrorHandler.getUserFriendlyMessage(e);
    throw Exception(userMessage);
  }
});

// Active add-ons only
final activeAddonsProvider =
    FutureProvider.autoDispose<List<AddOn>>((ref) async {
  final allAddons = await ref.watch(addonsProvider.future);
  return allAddons.where((addon) => addon.isActive).toList();
});

// Add-ons by category
final addonsByCategoryProvider = FutureProvider.autoDispose
    .family<List<AddOn>, String>((ref, category) async {
  final allAddons = await ref.watch(addonsProvider.future);
  return allAddons.where((addon) => addon.category == category).toList();
});

// Add-ons by IDs (for product's availableAddOnIds)
final addonsByIdsProvider = FutureProvider.autoDispose
    .family<List<AddOn>, List<String>>((ref, ids) async {
  if (ids.isEmpty) return [];

  final allAddons = await ref.watch(addonsProvider.future);
  return allAddons
      .where((addon) => ids.contains(addon.id) && addon.isActive)
      .toList();
});
