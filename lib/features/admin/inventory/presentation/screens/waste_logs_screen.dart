import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:coffee_house_pos/core/constants/app_constants.dart';
import '../providers/waste_logs_provider.dart';
import '../../data/models/waste_log_model.dart';

class WasteLogsScreen extends ConsumerWidget {
  const WasteLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filteredLogsAsync = ref.watch(filteredWasteLogsProvider);
    final filter = ref.watch(wasteLogsFilterProvider);
    final totalAmount = ref.watch(totalWasteCostProvider);

    // Debug: Log the async state
    filteredLogsAsync.when(
      data: (logs) => print('🔍 WASTE LOGS: Found ${logs.length} logs'),
      loading: () => print('🔍 WASTE LOGS: Loading...'),
      error: (err, stack) => print('🔍 WASTE LOGS ERROR: $err'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context, ref, filter);
            },
            tooltip: 'Filter',
          ),
          if (filter.startDate != null ||
              filter.endDate != null ||
              (filter.reasonFilter != null && filter.reasonFilter != 'all'))
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                ref.read(wasteLogsFilterProvider.notifier).clearFilters();
              },
              tooltip: 'Clear filters',
            ),
        ],
      ),
      body: Column(
        children: [
          _SummaryCard(
            theme: theme,
            filteredLogsAsync: filteredLogsAsync,
            totalAmount: totalAmount,
          ),
          Expanded(
            child: _LogsList(
              theme: theme,
              filteredLogsAsync: filteredLogsAsync,
              onRefresh: () async {
                ref.invalidate(wasteLogsProvider);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ThemeData theme;
  final AsyncValue<List<WasteLog>> filteredLogsAsync;
  final double totalAmount;

  const _SummaryCard({
    required this.theme,
    required this.filteredLogsAsync,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Waste',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                filteredLogsAsync.when(
                  data: (logs) => Text(
                    '${logs.length} items',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const Text('-'),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total Amount',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalAmount.toStringAsFixed(1),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LogsList extends StatelessWidget {
  final ThemeData theme;
  final AsyncValue<List<WasteLog>> filteredLogsAsync;
  final Future<void> Function() onRefresh;

  const _LogsList({
    required this.theme,
    required this.filteredLogsAsync,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return filteredLogsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return _EmptyState(theme: theme);
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              return _LogCard(log: logs[index], theme: theme);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _ErrorState(
        error: error,
        onRetry: onRefresh,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeData theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No waste logs found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final WasteLog log;
  final ThemeData theme;

  const _LogCard({
    required this.log,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Compare with displayName (capitalized) since AppWrite stores "Expired", "Damaged", etc.
    final reasonEnum = WasteReason.values.firstWhere(
      (r) => r.displayName == log.reason,
      orElse: () => WasteReason.other,
    );

    final reasonInfo = _getReasonInfo(reasonEnum);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: reasonInfo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    reasonInfo.icon,
                    color: reasonInfo.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(log.timestamp),
                        style: TextStyle(
                          color: theme.colorScheme.outline,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${log.amount.toStringAsFixed(1)} ${log.stockUnit}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: reasonInfo.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                reasonEnum.displayName,
                style: TextStyle(
                  color: reasonInfo.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (log.notes != null && log.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log.notes!,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _ReasonInfo _getReasonInfo(WasteReason reason) {
    switch (reason) {
      case WasteReason.expired:
        return _ReasonInfo(Colors.orange, Icons.event_busy);
      case WasteReason.damaged:
        return _ReasonInfo(Colors.red, Icons.broken_image);
      case WasteReason.spilled:
        return _ReasonInfo(Colors.blue, Icons.water_drop);
      case WasteReason.other:
        return _ReasonInfo(Colors.grey, Icons.more_horiz);
    }
  }
}

class _ReasonInfo {
  final Color color;
  final IconData icon;

  _ReasonInfo(this.color, this.icon);
}

void _showFilterDialog(
    BuildContext context, WidgetRef ref, WasteLogsFilter currentFilter) {
  DateTime? tempStartDate = currentFilter.startDate;
  DateTime? tempEndDate = currentFilter.endDate;
  String? tempReason = currentFilter.reasonFilter;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Filter Waste Logs'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range
                  Text(
                    'Date Range',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            tempStartDate == null
                                ? 'Start Date'
                                : DateFormat('dd MMM yyyy')
                                    .format(tempStartDate!),
                          ),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: tempStartDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => tempStartDate = date);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            tempEndDate == null
                                ? 'End Date'
                                : DateFormat('dd MMM yyyy').format(tempEndDate!),
                          ),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: tempEndDate ?? DateTime.now(),
                              firstDate: tempStartDate ?? DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => tempEndDate = date);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Reason Filter
                  Text(
                    'Reason',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempReason,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    hint: const Text('All Reasons'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Reasons'),
                      ),
                      ...WasteReason.values.map((reason) {
                        return DropdownMenuItem(
                          value: reason.displayName,
                          child: Text(reason.displayName),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => tempReason = value);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    tempStartDate = null;
                    tempEndDate = null;
                    tempReason = null;
                  });
                },
                child: const Text('Clear'),
              ),
              FilledButton(
                onPressed: () {
                  ref.read(wasteLogsFilterProvider.notifier).setDateRange(
                        tempStartDate,
                        tempEndDate,
                      );
                  ref
                      .read(wasteLogsFilterProvider.notifier)
                      .setReasonFilter(tempReason);
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      );
    },
  );
}
