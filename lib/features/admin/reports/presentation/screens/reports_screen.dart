import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:coffee_house_pos/core/utils/currency_formatter.dart';
import '../providers/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filter = ref.watch(reportsFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ordersProvider);
          ref.invalidate(previousOrdersProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date range selector
              _buildDateRangeSelector(context, theme, ref, filter),

              const SizedBox(height: 24),

              // Metrics cards
              const _MetricsSection(),

              const SizedBox(height: 24),

              // Sales trend chart
              const _SalesTrendChart(),

              const SizedBox(height: 24),

              // Top products
              const _TopProductsSection(),

              const SizedBox(height: 24),

              // Category performance
              const _CategoryPerformanceSection(),

              const SizedBox(height: 24),

              // Hourly heatmap
              const _HourlyHeatmapSection(),

              const SizedBox(height: 24),

              // Payment methods
              const _PaymentMethodsSection(),

              const SizedBox(height: 24),

              // Stock insights
              const _StockInsightsSection(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    ReportsFilter filter,
  ) {
    return Card(
      elevation: 0,
      color: const Color(0xFFFEF7E0), // yellow bg
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
                    color: const Color(0xFFDF8E1D).withOpacity(0.15), // yellow
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.date_range,
                    size: 20,
                    color: Color(0xFFDF8E1D),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Period',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFDF8E1D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Today'),
                  selected: filter.rangeType == DateRangeFilter.today,
                  onSelected: (_) {
                    ref.read(reportsFilterProvider.notifier).setToday();
                  },
                ),
                FilterChip(
                  label: const Text('This Week'),
                  selected: filter.rangeType == DateRangeFilter.week,
                  onSelected: (_) {
                    ref.read(reportsFilterProvider.notifier).setWeek();
                  },
                ),
                FilterChip(
                  label: const Text('This Month'),
                  selected: filter.rangeType == DateRangeFilter.month,
                  onSelected: (_) {
                    ref.read(reportsFilterProvider.notifier).setMonth();
                  },
                ),
                FilterChip(
                  label: const Text('Custom'),
                  selected: filter.rangeType == DateRangeFilter.custom,
                  onSelected: (_) => _showCustomDatePicker(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat('MMM dd, yyyy').format(filter.startDate)} - ${DateFormat('MMM dd, yyyy').format(filter.endDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomDatePicker(
      BuildContext context, WidgetRef ref) async {
    final filter = ref.read(reportsFilterProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: filter.startDate,
        end: filter.endDate,
      ),
    );

    if (picked != null) {
      ref.read(reportsFilterProvider.notifier).setCustom(
            picked.start,
            picked.end,
          );
    }
  }
}

class _MetricsSection extends ConsumerWidget {
  const _MetricsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(reportsMetricsProvider);

    return metricsAsync.when(
      data: (metrics) => Column(
        children: [
          _MetricCard(
            title: 'Total Revenue',
            value: CurrencyFormatter.format(metrics.totalRevenue),
            change: metrics.revenueChange,
            icon: Icons.attach_money,
            color: const Color(0xFF40A02B), // green
            bgColor: const Color(0xFFE6F4E1),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Orders',
                  value: metrics.orderCount.toString(),
                  change: metrics.orderCountChange,
                  icon: Icons.receipt_long,
                  color: const Color(0xFFD20F39), // red
                  bgColor: const Color(0xFFFEE5EA),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Avg Order',
                  value: CurrencyFormatter.format(metrics.averageOrderValue),
                  change: metrics.avgOrderValueChange,
                  icon: Icons.trending_up,
                  color: const Color(0xFF8839EF), // mauve
                  bgColor: const Color(0xFFF2E9FC),
                ),
              ),
            ],
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorCard(error: error.toString()),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final double change;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = change >= 0;
    final changeColor =
        isPositive ? const Color(0xFF40A02B) : const Color(0xFFD20F39);

    return Card(
      elevation: 0,
      color: bgColor,
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
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: changeColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${change.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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

class _SalesTrendChart extends ConsumerWidget {
  const _SalesTrendChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dailySalesAsync = ref.watch(dailySalesProvider);

    return Card(
      elevation: 0,
      color: const Color(0xFFDCE7F8), // blue bg
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
                    color: const Color(0xFF1E66F5).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.show_chart,
                    size: 20,
                    color: Color(0xFF1E66F5),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Sales Trend',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E66F5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            dailySalesAsync.when(
              data: (dailySales) {
                if (dailySales.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text('No data available')),
                  );
                }

                final maxRevenue = dailySales
                    .map((e) => e.revenue)
                    .reduce((a, b) => a > b ? a : b);

                final horizontalInterval =
                    maxRevenue > 0 ? (maxRevenue / 5).toDouble() : 1.0;

                return SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: horizontalInterval,
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                CurrencyFormatter.formatCompact(value),
                                style: theme.textTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: dailySales.length > 1
                                ? (dailySales.length / 5).ceilToDouble()
                                : 1,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= dailySales.length) {
                                return const SizedBox();
                              }
                              final date = dailySales[value.toInt()].date;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  DateFormat('MMM dd').format(date),
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: dailySales
                              .asMap()
                              .entries
                              .map((entry) => FlSpot(
                                    entry.key.toDouble(),
                                    entry.value.revenue,
                                  ))
                              .toList(),
                          isCurved: true,
                          color: const Color(0xFF1E66F5),
                          barWidth: 3,
                          dotData: FlDotData(
                            show: dailySales.length <= 10,
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF1E66F5).withOpacity(0.2),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final date = dailySales[spot.x.toInt()].date;
                              return LineTooltipItem(
                                '${DateFormat('MMM dd').format(date)}\n${CurrencyFormatter.format(spot.y)}',
                                TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 250,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SizedBox(
                height: 250,
                child: Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopProductsSection extends ConsumerWidget {
  const _TopProductsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final topProductsAsync = ref.watch(topProductsProvider);

    return Card(
      elevation: 0,
      color: const Color(0xFFFEE5EA), // red/pink bg
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
                    color: const Color(0xFFD20F39).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.star,
                    size: 20,
                    color: Color(0xFFD20F39),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Top Products',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD20F39),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            topProductsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No products sold'),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFFD20F39).withOpacity(0.15),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Color(0xFFD20F39),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(product.productName),
                      subtitle: Text('${product.quantity} sold'),
                      trailing: Text(
                        CurrencyFormatter.format(product.revenue),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorCard(error: error.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPerformanceSection extends ConsumerWidget {
  const _CategoryPerformanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categorySalesAsync = ref.watch(categorySalesProvider);

    return Card(
      elevation: 0,
      color: const Color(0xFFF2E9FC), // mauve/purple bg
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
                    color: const Color(0xFF8839EF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pie_chart,
                    size: 20,
                    color: Color(0xFF8839EF),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Category Performance',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8839EF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            categorySalesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No data available'),
                    ),
                  );
                }

                final totalRevenue = categories.fold<double>(
                  0,
                  (sum, cat) => sum + cat.revenue,
                );

                final colors = [
                  const Color(0xFF1E66F5), // blue
                  const Color(0xFFD20F39), // red
                  const Color(0xFF40A02B), // green
                  const Color(0xFFDF8E1D), // yellow
                  const Color(0xFF8839EF), // mauve
                  const Color(0xFFEA76CB), // pink
                  const Color(0xFFE64553), // maroon
                  const Color(0xFFFE640B), // peach
                ];

                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: categories.asMap().entries.map((entry) {
                            final index = entry.key;
                            final category = entry.value;
                            final percentage =
                                (category.revenue / totalRevenue) * 100;

                            return PieChartSectionData(
                              value: category.revenue,
                              title: '${percentage.toStringAsFixed(1)}%',
                              color: colors[index % colors.length],
                              radius: 80,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...categories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      final percentage =
                          (category.revenue / totalRevenue) * 100;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(category.category),
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}% • ${CurrencyFormatter.format(category.revenue)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => _ErrorCard(error: error.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _HourlyHeatmapSection extends ConsumerWidget {
  const _HourlyHeatmapSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hourlySalesAsync = ref.watch(hourlySalesProvider);

    return Card(
      elevation: 0,
      color: const Color(0xFFE6F4E1), // green bg
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
                    color: const Color(0xFF40A02B).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    size: 20,
                    color: Color(0xFF40A02B),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Hourly Activity',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF40A02B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            hourlySalesAsync.when(
              data: (hourlySales) {
                final maxOrders = hourlySales
                    .map((e) => e.orderCount)
                    .reduce((a, b) => a > b ? a : b);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 24,
                  itemBuilder: (context, index) {
                    final hourData = hourlySales[index];
                    final intensity =
                        maxOrders > 0 ? hourData.orderCount / maxOrders : 0;

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF40A02B)
                            .withOpacity(intensity * 0.8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${index.toString().padLeft(2, '0')}:00',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                              color: intensity > 0.5
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${hourData.orderCount}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: intensity > 0.5
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorCard(error: error.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodsSection extends ConsumerWidget {
  const _PaymentMethodsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final paymentMethodsAsync = ref.watch(paymentMethodSalesProvider);

    return Card(
      elevation: 0,
      color: const Color(0xFFFEEBF2), // pink bg
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
                    color: const Color(0xFFEA76CB).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.payment,
                    size: 20,
                    color: Color(0xFFEA76CB),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Payment Methods',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEA76CB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            paymentMethodsAsync.when(
              data: (methods) {
                if (methods.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No data available'),
                    ),
                  );
                }

                final maxCount =
                    methods.map((e) => e.count).reduce((a, b) => a > b ? a : b);

                return SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxCount.toDouble() * 1.2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final method = methods[group.x.toInt()];
                            return BarTooltipItem(
                              '${method.method}\n${method.count} orders\n${CurrencyFormatter.format(method.revenue)}',
                              TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: theme.textTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= methods.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  methods[value.toInt()].method,
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),
                      barGroups: methods.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.count.toDouble(),
                              color: const Color(0xFFEA76CB),
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 250,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => _ErrorCard(error: error.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;

  const _ErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
          ],
        ),
      ),
    );
  }
}

class _StockInsightsSection extends ConsumerWidget {
  const _StockInsightsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: const Color(0xFFFEF0E4), // peach bg
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
                    color: const Color(0xFFE64553).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    size: 20,
                    color: Color(0xFFE64553),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Stock Insights',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE64553),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Low stock products
            const _LowStockProducts(),

            const SizedBox(height: 24),

            // Waste summary
            const _WasteSummary(),
          ],
        ),
      ),
    );
  }
}

class _LowStockProducts extends ConsumerWidget {
  const _LowStockProducts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(lowStockProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: theme.colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Low Stock Alert',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        productsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return Text(
                'All products are well stocked',
                style: TextStyle(color: theme.colorScheme.outline),
              );
            }

            return Column(
              children: products.map((product) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(product.name),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${product.currentStock.toStringAsFixed(1)} / ${product.minStock.toStringAsFixed(1)} ${product.stockUnit}',
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}

class _WasteSummary extends ConsumerWidget {
  const _WasteSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wasteSummaryAsync = ref.watch(wasteSummaryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.delete_outline,
              color: theme.colorScheme.tertiary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Waste Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        wasteSummaryAsync.when(
          data: (summary) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Waste Items:',
                      style: TextStyle(color: theme.colorScheme.outline),
                    ),
                    Text(
                      '${summary['count']} items',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Waste Amount:',
                      style: TextStyle(color: theme.colorScheme.outline),
                    ),
                    Text(
                      '${(summary['totalAmount'] as double).toStringAsFixed(1)} units',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
