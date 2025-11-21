import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_house_pos/core/config/appwrite_config.dart';
import 'package:coffee_house_pos/core/services/appwrite_service.dart';
import 'package:coffee_house_pos/features/admin/inventory/data/models/waste_log_model.dart';
import 'package:appwrite/appwrite.dart';

// Fetch waste logs from AppWrite
final wasteLogsProvider = FutureProvider<List<WasteLog>>((ref) async {
  final appwrite = ref.watch(appwriteProvider);

  try {
    final response = await appwrite.databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.wasteLogsCollection,
      queries: [
        Query.orderDesc('\$createdAt'),
        Query.limit(100),
      ],
    );

    return response.documents.map((doc) {
      final data = doc.data;
      data['\$id'] = doc.$id;
      data['\$createdAt'] = doc.$createdAt;
      data['\$updatedAt'] = doc.$updatedAt;

      return WasteLog(
        id: doc.$id,
        productId: data['productId'],
        productName: data['productName'],
        amount: (data['amount'] as num).toDouble(),
        stockUnit: data['stockUnit'],
        reason: data['reason'],
        notes: data['notes'],
        loggedBy: data['loggedBy'],
        timestamp: DateTime.parse(data['timestamp']),
      );
    }).toList();
  } catch (e) {
    print('Error fetching waste logs: $e');
    rethrow;
  }
});

// Filter state
class WasteLogsFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? reasonFilter;

  WasteLogsFilter({
    this.startDate,
    this.endDate,
    this.reasonFilter,
  });

  WasteLogsFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? reasonFilter,
  }) {
    return WasteLogsFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reasonFilter: reasonFilter ?? this.reasonFilter,
    );
  }
}

class WasteLogsFilterNotifier extends StateNotifier<WasteLogsFilter> {
  WasteLogsFilterNotifier() : super(WasteLogsFilter());

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void setReasonFilter(String? reason) {
    state = state.copyWith(reasonFilter: reason);
  }

  void clearFilters() {
    state = WasteLogsFilter();
  }
}

final wasteLogsFilterProvider =
    StateNotifierProvider<WasteLogsFilterNotifier, WasteLogsFilter>((ref) {
  return WasteLogsFilterNotifier();
});

// Filtered waste logs
final filteredWasteLogsProvider = Provider<AsyncValue<List<WasteLog>>>((ref) {
  final logsAsync = ref.watch(wasteLogsProvider);
  final filter = ref.watch(wasteLogsFilterProvider);

  return logsAsync.whenData((logs) {
    var filtered = logs;

    // Filter by date range
    if (filter.startDate != null) {
      filtered = filtered.where((log) {
        return log.timestamp.isAfter(filter.startDate!) ||
            log.timestamp.isAtSameMomentAs(filter.startDate!);
      }).toList();
    }

    if (filter.endDate != null) {
      final endOfDay = DateTime(
        filter.endDate!.year,
        filter.endDate!.month,
        filter.endDate!.day,
        23,
        59,
        59,
      );
      filtered = filtered.where((log) {
        return log.timestamp.isBefore(endOfDay) ||
            log.timestamp.isAtSameMomentAs(endOfDay);
      }).toList();
    }

    // Filter by reason
    if (filter.reasonFilter != null && filter.reasonFilter != 'all') {
      filtered =
          filtered.where((log) => log.reason == filter.reasonFilter).toList();
    }

    return filtered;
  });
});

// Calculate total waste cost
final totalWasteCostProvider = Provider<double>((ref) {
  final filteredLogsAsync = ref.watch(filteredWasteLogsProvider);

  return filteredLogsAsync.maybeWhen(
    data: (logs) {
      // Note: We would need product prices to calculate actual cost
      // For now, return the total amount
      return logs.fold<double>(0.0, (sum, log) => sum + log.amount);
    },
    orElse: () => 0.0,
  );
});
