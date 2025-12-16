import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_house_pos/core/config/appwrite_config.dart';
import 'package:coffee_house_pos/core/services/appwrite_service.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_model.dart';
import 'package:coffee_house_pos/features/admin/inventory/data/models/stock_movement_model.dart';
import 'package:coffee_house_pos/features/admin/inventory/data/models/waste_log_model.dart';
import 'package:appwrite/appwrite.dart';

class StockAdjustmentState {
  final bool isLoading;
  final String? error;
  final bool success;

  const StockAdjustmentState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  StockAdjustmentState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return StockAdjustmentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class StockAdjustmentNotifier extends StateNotifier<StockAdjustmentState> {
  final Ref ref;

  StockAdjustmentNotifier(this.ref) : super(const StockAdjustmentState());

  Future<bool> adjustStock({
    required Product product,
    required String adjustmentType, // 'restock', 'waste', 'adjustment'
    required double amount,
    String? reason,
    String? notes,
    required String performedBy,
    required String performedByName,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      final appwrite = ref.read(appwriteProvider);

      // Calculate new stock
      double newStock;
      if (adjustmentType == 'restock') {
        newStock = product.currentStock + amount;
      } else if (adjustmentType == 'waste') {
        newStock = product.currentStock - amount;
      } else {
        // manual adjustment - amount can be positive or negative
        newStock = amount;
      }

      if (newStock < 0) {
        throw Exception('Stock cannot be negative');
      }

      print('═══════════════════════════════════════════════════════');
      print('📦 STOCK ADJUSTMENT');
      print('═══════════════════════════════════════════════════════');
      print('Product: ${product.name}');
      print('Type: $adjustmentType');
      print('Amount: $amount ${product.stockUnit}');
      print('Current Stock: ${product.currentStock}');
      print('New Stock: $newStock');

      // Update product stock in AppWrite
      await appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollection,
        documentId: product.id!,
        data: {
          'currentStock': newStock,
        },
      );

      print('✅ Product stock updated in AppWrite');

      // Create stock movement log
      // Map 'waste' to 'adjustment' for AppWrite schema compatibility
      final movementType =
          adjustmentType == 'waste' ? 'adjustment' : adjustmentType;

      final movement = StockMovement(
        productId: product.id!,
        productName: product.name,
        orderId: '',
        orderNumber: '',
        amount: adjustmentType == 'waste' ? -amount : amount,
        stockUnit: product.stockUnit,
        type: movementType,
        reason: adjustmentType == 'waste' ? reason : null,
        notes: notes,
        performedBy: performedBy,
        timestamp: DateTime.now(),
      );

      await appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.stockMovementsCollection,
        documentId: ID.unique(),
        data: {
          'orderId': movement.orderId,
          'orderNumber': movement.orderNumber,
          'productId': movement.productId,
          'productName': movement.productName,
          'amount': movement.amount,
          'stockUnit': movement.stockUnit,
          'type': movement.type,
          if (movement.reason != null) 'reason': movement.reason,
          if (movement.notes != null) 'notes': movement.notes,
          'performedBy': movement.performedBy,
          'timestamp': movement.timestamp.toIso8601String(),
        },
      );

      print('✅ Stock movement logged');

      // If waste, also create waste log
      if (adjustmentType == 'waste') {
        final wasteLog = WasteLog(
          productId: product.id!,
          productName: product.name,
          amount: amount,
          stockUnit: product.stockUnit,
          reason: reason ??
              'Other', // Default to 'Other' (capitalized for AppWrite enum)
          notes: notes,
          loggedBy: performedBy,
          timestamp: DateTime.now(),
        );

        await appwrite.databases.createDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.wasteLogsCollection,
          documentId: ID.unique(),
          data: {
            'productId': wasteLog.productId,
            'productName': wasteLog.productName,
            'amount': wasteLog.amount,
            'stockUnit': wasteLog.stockUnit,
            'reason': wasteLog.reason,
            'notes': wasteLog.notes,
            'loggedBy': wasteLog.loggedBy,
            'timestamp': wasteLog.timestamp.toIso8601String(),
          },
        );

        print('✅ Waste log created');
      }

      print('═══════════════════════════════════════════════════════');

      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      print('❌ Error adjusting stock: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = const StockAdjustmentState();
  }
}

final stockAdjustmentProvider =
    StateNotifierProvider<StockAdjustmentNotifier, StockAdjustmentState>((ref) {
  return StockAdjustmentNotifier(ref);
});
