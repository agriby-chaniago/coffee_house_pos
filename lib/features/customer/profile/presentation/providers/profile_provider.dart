import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_house_pos/features/customer/orders/data/models/order_model.dart';
import 'package:coffee_house_pos/core/services/appwrite_service.dart';
import 'package:coffee_house_pos/core/config/appwrite_config.dart';
import 'package:coffee_house_pos/features/auth/presentation/providers/auth_provider.dart';
import 'package:appwrite/appwrite.dart';

/// Profile statistics model
class ProfileStats {
  final int totalOrders;
  final double totalSpent;
  final int pendingOrders;
  final int completedOrders;

  ProfileStats({
    required this.totalOrders,
    required this.totalSpent,
    required this.pendingOrders,
    required this.completedOrders,
  });

  ProfileStats.empty()
      : totalOrders = 0,
        totalSpent = 0.0,
        pendingOrders = 0,
        completedOrders = 0;
}

/// Provider to fetch profile statistics
final profileStatsProvider =
    FutureProvider.autoDispose<ProfileStats>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (state) async {
      if (state is! AuthStateAuthenticated) {
        return ProfileStats.empty();
      }

      try {
        final appwrite = ref.watch(appwriteProvider);
        final databases = appwrite.databases;

        // Fetch all orders for this user
        final response = await databases.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.ordersCollection,
          queries: [
            Query.equal('customerId', state.user.$id),
            Query.orderDesc('\$createdAt'),
            Query.limit(100), // Fetch last 100 orders for stats
          ],
        );

        // Parse orders
        final orders = response.documents.map((doc) {
          return Order.fromJson(doc.data);
        }).toList();

        // Calculate statistics
        final totalOrders = orders.length;
        final totalSpent = orders.fold<double>(
          0.0,
          (sum, order) => sum + order.total,
        );
        final pendingOrders = orders
            .where((order) =>
                order.status == 'pending' || order.status == 'preparing')
            .length;
        final completedOrders =
            orders.where((order) => order.status == 'completed').length;

        return ProfileStats(
          totalOrders: totalOrders,
          totalSpent: totalSpent,
          pendingOrders: pendingOrders,
          completedOrders: completedOrders,
        );
      } catch (e) {
        // Return empty stats on error
        return ProfileStats.empty();
      }
    },
    loading: () => ProfileStats.empty(),
    error: (_, __) => ProfileStats.empty(),
  );
});
