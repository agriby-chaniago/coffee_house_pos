# 🚀 IMPLEMENTATION GUIDE - Admin Side Completion

**Created:** December 16, 2025  
**Target:** Complete admin-side features for production-ready MVP  
**Estimated Time:** 2-3 days (1 developer)

---

## 📋 CHECKLIST OVERVIEW

### Priority 1: CRITICAL (Must Have) ⚠️

- [ ] **Admin Orders Management** - 0% (Day 1-2)
  - [ ] Orders screen with list view
  - [ ] Order detail screen
  - [ ] Order status update functionality
  - [ ] Filters & search
  - [ ] Providers & state management

### Priority 2: HIGH (Should Have) 🔥

- [ ] **Bottom Navigation Bar** - 0% (Day 2)
  - [ ] Shared bottom nav widget
  - [ ] Navigation logic
- [ ] **Order Model Enhancements** - 0% (Day 2)
  - [ ] Add notes field
  - [ ] Add cancelledAt field
  - [ ] Add cancellationReason field

### Priority 3: MEDIUM (Nice to Have) ✨

- [ ] **Receipt Enhancements** - 50% (Day 3)

  - [ ] Integrate store info from settings
  - [ ] Optional: QR code

- [ ] **Minor Improvements** - 0% (Day 3)
  - [ ] Image size validation (max 5MB)
  - [ ] Enhanced input validation
  - [ ] Stock alerts UI enhancements

### Priority 4: LOW (Future) 🔮

- [ ] Testing suite
- [ ] Batch operations
- [ ] Waste photo upload

---

## 🎯 DETAILED IMPLEMENTATION PLAN

---

## PRIORITY 1: ADMIN ORDERS MANAGEMENT ⚠️

### **Estimated Time:** 1.5-2 days

### **A. Folder Structure Setup** (15 minutes)

Create the following structure:

```
lib/features/admin/orders/
├── data/
│   └── (empty - reuse existing order_model from customer/orders)
└── presentation/
    ├── providers/
    │   ├── orders_provider.dart
    │   └── order_actions_provider.dart
    ├── screens/
    │   ├── orders_screen.dart
    │   └── order_detail_screen.dart
    └── widgets/
        ├── order_card.dart
        ├── order_status_badge.dart
        └── status_update_dialog.dart
```

**Action Items:**

- [ ] Create folder structure
- [ ] Verify order_model.dart already has required fields (orderNumber, status, items, etc.)

---

### **B. Orders Provider** (2-3 hours)

**File:** `lib/features/admin/orders/presentation/providers/orders_provider.dart`

**Implementation Checklist:**

1. **[ ] OrdersFilter Model**

   ```dart
   class OrdersFilter {
     final String? status;          // null = All
     final DateTime? startDate;
     final DateTime? endDate;
     final String? paymentMethod;
     final String searchQuery;
   }
   ```

2. **[ ] ordersFilterProvider**

   - StateNotifierProvider<OrdersFilterNotifier, OrdersFilter>
   - Methods: setStatus, setDateRange, setPaymentMethod, setSearchQuery, reset

3. **[ ] allOrdersProvider**

   - FutureProvider.autoDispose<List<Order>>
   - Fetch from AppWrite orders collection
   - Query: orderDesc by $createdAt
   - Limit: 100 (pagination later if needed)
   - Watch ordersFilterProvider for auto-refetch

4. **[ ] filteredOrdersProvider**

   - Provider.autoDispose<List<Order>>
   - Depends on: allOrdersProvider + ordersFilterProvider
   - Filter logic:
     - By status (if not null)
     - By date range (if provided)
     - By payment method (if provided)
     - By search query (orderNumber or customerName contains)

5. **[ ] ordersStatsProvider**
   - Provider.autoDispose<OrdersStats>
   - Calculate: totalOrders, pendingCount, preparingCount, readyCount, completedCount

**Sample Code Structure:**

```dart
// Filter state
class OrdersFilter {
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? paymentMethod;
  final String searchQuery;

  OrdersFilter({
    this.status,
    this.startDate,
    this.endDate,
    this.paymentMethod,
    this.searchQuery = '',
  });

  OrdersFilter copyWith({...}) => ...;
}

// Filter notifier
class OrdersFilterNotifier extends StateNotifier<OrdersFilter> {
  OrdersFilterNotifier() : super(OrdersFilter());

  void setStatus(String? status) => state = state.copyWith(status: status);
  void setDateRange(DateTime? start, DateTime? end) => ...;
  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);
  void reset() => state = OrdersFilter();
}

final ordersFilterProvider = StateNotifierProvider<OrdersFilterNotifier, OrdersFilter>(
  (ref) => OrdersFilterNotifier(),
);

// Fetch orders
final allOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final appwrite = ref.watch(appwriteProvider);

  final response = await appwrite.databases.listDocuments(
    databaseId: AppwriteConfig.databaseId,
    collectionId: AppwriteConfig.ordersCollection,
    queries: [
      Query.orderDesc('\$createdAt'),
      Query.limit(100),
    ],
  );

  return response.documents.map((doc) {
    return Order.fromJson({...doc.data, '\$id': doc.\$id});
  }).toList();
});

// Filter orders
final filteredOrdersProvider = Provider.autoDispose<AsyncValue<List<Order>>>((ref) {
  final ordersAsync = ref.watch(allOrdersProvider);
  final filter = ref.watch(ordersFilterProvider);

  return ordersAsync.whenData((orders) {
    var filtered = orders;

    // Filter by status
    if (filter.status != null && filter.status != 'all') {
      filtered = filtered.where((o) => o.status.toLowerCase() == filter.status!.toLowerCase()).toList();
    }

    // Filter by date range
    if (filter.startDate != null && filter.endDate != null) {
      filtered = filtered.where((o) {
        return o.createdAt.isAfter(filter.startDate!) &&
               o.createdAt.isBefore(filter.endDate!);
      }).toList();
    }

    // Filter by payment method
    if (filter.paymentMethod != null && filter.paymentMethod != 'all') {
      filtered = filtered.where((o) => o.paymentMethod == filter.paymentMethod).toList();
    }

    // Search
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      filtered = filtered.where((o) {
        return o.orderNumber.toLowerCase().contains(query) ||
               (o.customerName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  });
});
```

**Testing Checklist:**

- [ ] Test fetch orders from AppWrite
- [ ] Test status filter (All/Pending/Preparing/Ready/Completed/Cancelled)
- [ ] Test date range filter
- [ ] Test payment method filter
- [ ] Test search by order number
- [ ] Test search by customer name
- [ ] Test combined filters

---

### **C. Order Actions Provider** (1-2 hours)

**File:** `lib/features/admin/orders/presentation/providers/order_actions_provider.dart`

**Implementation Checklist:**

1. **[ ] OrderActionState Model**

   ```dart
   @freezed
   class OrderActionState with _$OrderActionState {
     const factory OrderActionState.idle() = _Idle;
     const factory OrderActionState.loading() = _Loading;
     const factory OrderActionState.success(String message) = _Success;
     const factory OrderActionState.error(String message) = _Error;
   }
   ```

2. **[ ] OrderActionsNotifier**

   - Methods:
     - updateOrderStatus(orderId, newStatus)
     - cancelOrder(orderId, reason)
   - Update order in AppWrite
   - Handle offline queue if offline
   - Show success/error states

3. **[ ] orderActionsProvider**
   - StateNotifierProvider

**Sample Code Structure:**

```dart
class OrderActionsNotifier extends StateNotifier<OrderActionState> {
  final AppwriteService _appwrite;

  OrderActionsNotifier(this._appwrite) : super(const OrderActionState.idle());

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    state = const OrderActionState.loading();

    try {
      // Update in AppWrite
      await _appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollection,
        documentId: orderId,
        data: {
          'status': newStatus,
          if (newStatus == 'completed') 'completedAt': DateTime.now().toIso8601String(),
        },
      );

      state = OrderActionState.success('Order updated to $newStatus');
    } on AppwriteException catch (e) {
      state = OrderActionState.error(e.message ?? 'Failed to update order');
    }
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    state = const OrderActionState.loading();

    try {
      await _appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollection,
        documentId: orderId,
        data: {
          'status': 'cancelled',
          'cancelledAt': DateTime.now().toIso8601String(),
          'cancellationReason': reason,
        },
      );

      state = const OrderActionState.success('Order cancelled');
    } on AppwriteException catch (e) {
      state = OrderActionState.error(e.message ?? 'Failed to cancel order');
    }
  }
}

final orderActionsProvider = StateNotifierProvider<OrderActionsNotifier, OrderActionState>((ref) {
  final appwrite = ref.watch(appwriteProvider);
  return OrderActionsNotifier(appwrite);
});
```

**Testing Checklist:**

- [ ] Test update status: Pending → Preparing
- [ ] Test update status: Preparing → Ready
- [ ] Test update status: Ready → Completed
- [ ] Test cancel order with reason
- [ ] Test error handling (invalid orderId, network error)
- [ ] Test state transitions (idle → loading → success/error)

---

### **D. Orders Screen** (3-4 hours)

**File:** `lib/features/admin/orders/presentation/screens/orders_screen.dart`

**UI Layout:**

```
AppBar
  ├─ Title: "Orders"
  └─ Actions: [Refresh IconButton]

Body
  ├─ Stats Cards Row (Scrollable)
  │   ├─ Total Orders
  │   ├─ Pending
  │   ├─ Preparing
  │   ├─ Ready
  │   └─ Completed
  │
  ├─ Search Bar
  │
  ├─ Filter Section
  │   ├─ Status Chips (All, Pending, Preparing, Ready, Completed, Cancelled)
  │   └─ Date Range Button
  │
  └─ Orders ListView
      └─ OrderCard (tap → navigate to detail)
```

**Implementation Checklist:**

1. **[ ] Stats Cards**

   - Watch ordersStatsProvider
   - Display count for each status
   - Catppuccin themed cards

2. **[ ] Search Bar**

   - TextField with search icon
   - onChanged: update ordersFilterProvider.searchQuery
   - Clear button (X) when text not empty

3. **[ ] Filter Chips**

   - FilterChip for each status
   - Selected state from ordersFilterProvider.status
   - onSelected: update filter

4. **[ ] Date Range Filter**

   - Button to show DateRangePicker
   - Display selected range
   - Clear button

5. **[ ] Orders ListView**
   - Watch filteredOrdersProvider
   - Show loading/error/empty states
   - RefreshIndicator
   - OrderCard for each order

**Sample Code Structure:**

```dart
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(filteredOrdersProvider);
    final filter = ref.watch(ordersFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allOrdersProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allOrdersProvider);
        },
        child: Column(
          children: [
            // Stats cards
            _buildStatsCards(theme),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by order number or customer...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(ordersFilterProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
                ),
                onChanged: (value) {
                  ref.read(ordersFilterProvider.notifier).setSearchQuery(value);
                },
              ),
            ),

            // Status filter chips
            _buildFilterChips(theme, filter),

            // Orders list
            Expanded(
              child: ordersAsync.when(
                data: (orders) {
                  if (orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: theme.colorScheme.outline),
                          const SizedBox(height: 16),
                          Text('No orders found', style: theme.textTheme.titleMedium),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return OrderCard(
                        order: orders[index],
                        onTap: () {
                          context.push('/admin/orders/${orders[index].id}');
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, OrdersFilter filter) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: const Text('All'),
            selected: filter.status == null,
            onSelected: (_) => ref.read(ordersFilterProvider.notifier).setStatus(null),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Pending'),
            selected: filter.status == 'pending',
            onSelected: (_) => ref.read(ordersFilterProvider.notifier).setStatus('pending'),
          ),
          // ... more chips
        ],
      ),
    );
  }
}
```

**Testing Checklist:**

- [ ] Test stats cards display
- [ ] Test search functionality
- [ ] Test filter chips (all statuses)
- [ ] Test date range picker
- [ ] Test empty state
- [ ] Test loading state
- [ ] Test error state
- [ ] Test refresh
- [ ] Test tap order card → navigate

---

### **E. Order Detail Screen** (3-4 hours)

**File:** `lib/features/admin/orders/presentation/screens/order_detail_screen.dart`

**UI Layout:**

```
AppBar
  ├─ Title: "Order Details"
  └─ Actions: [Print IconButton]

Body (ScrollView)
  ├─ Order Header Card
  │   ├─ Order Number (large)
  │   ├─ Status Badge
  │   ├─ Date & Time
  │   └─ Customer Name (if any)
  │
  ├─ Items Section
  │   └─ Each item with add-ons
  │
  ├─ Payment Summary Card
  │   ├─ Subtotal
  │   ├─ Tax (PPN 11%)
  │   ├─ Total
  │   └─ Payment Method
  │
  └─ Actions Section (if not completed/cancelled)
      ├─ Status-specific buttons
      └─ Cancel button (red)
```

**Implementation Checklist:**

1. **[ ] Order Header**

   - Display order number prominently
   - Status badge (color-coded)
   - Date formatted nicely
   - Customer name or "Walk-in Customer"
   - Cashier name

2. **[ ] Items List**

   - Each item in card/list tile
   - Product name + size
   - Quantity × price
   - Add-ons listed below (indented)
   - Item total

3. **[ ] Payment Summary**

   - Subtotal, tax, total (aligned right)
   - Payment method badge

4. **[ ] Action Buttons (Dynamic)**

   - **If Pending**: "Start Preparing" button (blue)
   - **If Preparing**: "Mark as Ready" button (orange)
   - **If Ready**: "Complete Order" button (green)
   - **If Pending/Preparing/Ready**: "Cancel Order" button (red) → show reason dialog
   - **If Completed/Cancelled**: No action buttons, show completion/cancellation info

5. **[ ] Status Update Logic**
   - Watch orderActionsProvider
   - Show loading during update
   - Show success SnackBar
   - Show error dialog
   - Navigate back on success

**Sample Code Structure:**

```dart
class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orderAsync = ref.watch(orderByIdProvider(orderId));
    final actionState = ref.watch(orderActionsProvider);

    // Listen to action state changes
    ref.listen<OrderActionState>(orderActionsProvider, (previous, next) {
      next.maybeWhen(
        success: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green),
          );
          // Refresh order
          ref.invalidate(orderByIdProvider(orderId));
          ref.invalidate(allOrdersProvider);
        },
        error: (message) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Error'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReceipt(context, orderAsync.value),
          ),
        ],
      ),
      body: orderAsync.when(
        data: (order) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              _buildOrderHeader(theme, order),
              const SizedBox(height: 24),

              // Items section
              _buildItemsSection(theme, order),
              const SizedBox(height: 24),

              // Payment summary
              _buildPaymentSummary(theme, order),
              const SizedBox(height: 24),

              // Action buttons
              _buildActionButtons(context, ref, order, actionState),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    Order order,
    OrderActionState actionState,
  ) {
    // Don't show buttons if completed or cancelled
    if (order.status == 'completed' || order.status == 'cancelled') {
      return _buildCompletionInfo(order);
    }

    final isLoading = actionState is _Loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status transition button
        if (order.status == 'pending')
          FilledButton.icon(
            onPressed: isLoading ? null : () => _updateStatus(ref, order.id!, 'preparing'),
            icon: const Icon(Icons.restaurant),
            label: const Text('Start Preparing'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1E66F5), // blue
              minimumSize: const Size.fromHeight(56),
            ),
          ),

        if (order.status == 'preparing')
          FilledButton.icon(
            onPressed: isLoading ? null : () => _updateStatus(ref, order.id!, 'ready'),
            icon: const Icon(Icons.check_circle),
            label: const Text('Mark as Ready'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDF8E1D), // yellow/orange
              minimumSize: const Size.fromHeight(56),
            ),
          ),

        if (order.status == 'ready')
          FilledButton.icon(
            onPressed: isLoading ? null : () => _updateStatus(ref, order.id!, 'completed'),
            icon: const Icon(Icons.done_all),
            label: const Text('Complete Order'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF40A02B), // green
              minimumSize: const Size.fromHeight(56),
            ),
          ),

        const SizedBox(height: 12),

        // Cancel button
        OutlinedButton.icon(
          onPressed: isLoading ? null : () => _showCancelDialog(context, ref, order.id!),
          icon: const Icon(Icons.cancel),
          label: const Text('Cancel Order'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFD20F39), // red
            side: const BorderSide(color: Color(0xFFD20F39)),
            minimumSize: const Size.fromHeight(56),
          ),
        ),
      ],
    );
  }

  Future<void> _updateStatus(WidgetRef ref, String orderId, String newStatus) async {
    await ref.read(orderActionsProvider.notifier).updateOrderStatus(orderId, newStatus);
  }

  Future<void> _showCancelDialog(BuildContext context, WidgetRef ref, String orderId) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for cancellation:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g., Customer request, Out of stock',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD20F39),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      await ref.read(orderActionsProvider.notifier).cancelOrder(
        orderId,
        reasonController.text,
      );
    }
  }
}

// Additional provider for single order
final orderByIdProvider = FutureProvider.autoDispose.family<Order, String>((ref, orderId) async {
  final appwrite = ref.watch(appwriteProvider);

  final doc = await appwrite.databases.getDocument(
    databaseId: AppwriteConfig.databaseId,
    collectionId: AppwriteConfig.ordersCollection,
    documentId: orderId,
  );

  return Order.fromJson({...doc.data, '\$id': doc.\$id});
});
```

**Testing Checklist:**

- [ ] Test display order details
- [ ] Test items list with add-ons
- [ ] Test payment summary
- [ ] Test "Start Preparing" button (Pending → Preparing)
- [ ] Test "Mark as Ready" button (Preparing → Ready)
- [ ] Test "Complete Order" button (Ready → Completed)
- [ ] Test "Cancel Order" with reason dialog
- [ ] Test button disabled during loading
- [ ] Test success SnackBar
- [ ] Test error dialog
- [ ] Test print button
- [ ] Test completion info display (completed orders)
- [ ] Test cancellation info display (cancelled orders)

---

### **F. Supporting Widgets** (2-3 hours)

#### **1. OrderCard Widget**

**File:** `lib/features/admin/orders/presentation/widgets/order_card.dart`

```dart
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 8),

              // Date & customer
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy · HH:mm').format(order.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),

              if (order.customerName != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: theme.colorScheme.outline),
                    const SizedBox(width: 4),
                    Text(
                      order.customerName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Total & payment
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    CurrencyFormatter.format(order.total),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (order.paymentMethod ?? 'cash').toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### **2. OrderStatusBadge Widget**

**File:** `lib/features/admin/orders/presentation/widgets/order_status_badge.dart`

```dart
class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _getStatusAttributes(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String) _getStatusAttributes(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return (
          const Color(0xFF7C7F93), // gray
          Icons.schedule,
          'Pending',
        );
      case 'preparing':
        return (
          const Color(0xFF1E66F5), // blue
          Icons.restaurant,
          'Preparing',
        );
      case 'ready':
        return (
          const Color(0xFFDF8E1D), // yellow
          Icons.done,
          'Ready',
        );
      case 'completed':
        return (
          const Color(0xFF40A02B), // green
          Icons.check_circle,
          'Completed',
        );
      case 'cancelled':
        return (
          const Color(0xFFD20F39), // red
          Icons.cancel,
          'Cancelled',
        );
      default:
        return (
          const Color(0xFF7C7F93),
          Icons.help,
          'Unknown',
        );
    }
  }
}
```

**Checklist:**

- [ ] Create OrderCard widget
- [ ] Create OrderStatusBadge widget
- [ ] Test all status badges (Pending, Preparing, Ready, Completed, Cancelled)
- [ ] Test OrderCard tap functionality

---

### **G. Router Integration** (30 minutes)

**File:** `lib/core/router/app_router.dart`

**Add routes:**

```dart
// Import
import '../../features/admin/orders/presentation/screens/orders_screen.dart';
import '../../features/admin/orders/presentation/screens/order_detail_screen.dart';

// Add routes under /admin/pos
GoRoute(
  path: 'orders',
  builder: (context, state) => const OrdersScreen(),
  routes: [
    GoRoute(
      path: ':orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return OrderDetailScreen(orderId: orderId);
      },
    ),
  ],
),
```

**Checklist:**

- [ ] Add imports
- [ ] Add orders routes
- [ ] Test navigation: /admin/pos/orders
- [ ] Test navigation: /admin/pos/orders/:orderId

---

## PRIORITY 2: BOTTOM NAVIGATION BAR 🔥

### **Estimated Time:** 2-3 hours

### **A. Bottom Navigation Widget** (1.5 hours)

**File:** `lib/core/widgets/admin_bottom_nav.dart`

**Implementation Checklist:**

1. **[ ] Create Widget**

   ```dart
   class AdminBottomNav extends StatelessWidget {
     final int currentIndex;

     const AdminBottomNav({super.key, required this.currentIndex});

     @override
     Widget build(BuildContext context) {
       return NavigationBar(
         selectedIndex: currentIndex,
         onDestinationSelected: (index) => _onTap(context, index),
         destinations: const [
           NavigationDestination(
             icon: Icon(Icons.point_of_sale),
             label: 'POS',
           ),
           NavigationDestination(
             icon: Icon(Icons.receipt_long),
             label: 'Orders',
           ),
           NavigationDestination(
             icon: Icon(Icons.inventory_2),
             label: 'Inventory',
           ),
           NavigationDestination(
             icon: Icon(Icons.bar_chart),
             label: 'Reports',
           ),
           NavigationDestination(
             icon: Icon(Icons.settings),
             label: 'Settings',
           ),
         ],
       );
     }

     void _onTap(BuildContext context, int index) {
       switch (index) {
         case 0:
           context.go('/admin/pos');
           break;
         case 1:
           context.go('/admin/pos/orders');
           break;
         case 2:
           context.go('/admin/pos/inventory');
           break;
         case 3:
           context.go('/admin/pos/reports');
           break;
         case 4:
           context.go('/admin/pos/settings');
           break;
       }
     }
   }
   ```

2. **[ ] Add to Screens**
   - Update PosScreen: add `bottomNavigationBar: AdminBottomNav(currentIndex: 0)`
   - Update OrdersScreen: add `bottomNavigationBar: AdminBottomNav(currentIndex: 1)`
   - Update InventoryScreen: add `bottomNavigationBar: AdminBottomNav(currentIndex: 2)`
   - Update ReportsScreen: add `bottomNavigationBar: AdminBottomNav(currentIndex: 3)`
   - Update SettingsScreen: add `bottomNavigationBar: AdminBottomNav(currentIndex: 4)`

**Testing Checklist:**

- [ ] Test navigation from POS → Orders
- [ ] Test navigation from Orders → Inventory
- [ ] Test navigation from Inventory → Reports
- [ ] Test navigation from Reports → Settings
- [ ] Test navigation from Settings → POS
- [ ] Test selected state highlights correct item
- [ ] Test on different screen sizes

---

## PRIORITY 3: ORDER MODEL ENHANCEMENTS ✨

### **Estimated Time:** 1-2 hours

### **A. Update Order Model** (1 hour)

**File:** `lib/features/customer/orders/data/models/order_model.dart`

**Changes:**

1. **[ ] Add new fields to Order class**

   ```dart
   const factory Order({
     // ... existing fields ...
     String? notes,                    // ADD THIS
     DateTime? cancelledAt,            // ADD THIS
     String? cancellationReason,       // ADD THIS
   }) = _Order;
   ```

2. **[ ] Update fromJson**

   ```dart
   factory Order.fromJson(Map<String, dynamic> json) {
     // ... existing code ...

     return Order(
       // ... existing fields ...
       notes: json['notes'],
       cancelledAt: json['cancelledAt'] != null
           ? DateTime.parse(json['cancelledAt'])
           : null,
       cancellationReason: json['cancellationReason'],
     );
   }
   ```

3. **[ ] Update toJson**

   ```dart
   Map<String, dynamic> toJson() {
     return {
       // ... existing fields ...
       if (notes != null) 'notes': notes,
       if (cancelledAt != null) 'cancelledAt': cancelledAt!.toIso8601String(),
       if (cancellationReason != null) 'cancellationReason': cancellationReason,
     };
   }
   ```

4. **[ ] Update toAppwriteJson**

   ```dart
   Map<String, dynamic> toAppwriteJson() {
     return {
       // ... existing fields ...
       if (notes != null) 'notes': notes,
       if (cancelledAt != null) 'cancelledAt': cancelledAt!.toIso8601String(),
       if (cancellationReason != null) 'cancellationReason': cancellationReason,
     };
   }
   ```

5. **[ ] Run build_runner**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

**Testing Checklist:**

- [ ] Run build_runner successfully
- [ ] Test order with notes
- [ ] Test order with cancelledAt
- [ ] Test order with cancellationReason
- [ ] Test serialization/deserialization

---

### **B. Update AppWrite Collection** (30 minutes)

**AppWrite Console Steps:**

1. **[ ] Add attributes to orders collection:**

   - Attribute: `notes`

     - Type: String
     - Size: 1000
     - Required: No
     - Array: No

   - Attribute: `cancelledAt`

     - Type: DateTime
     - Required: No

   - Attribute: `cancellationReason`
     - Type: String
     - Size: 500
     - Required: No

**Checklist:**

- [ ] Add `notes` attribute
- [ ] Add `cancelledAt` attribute
- [ ] Add `cancellationReason` attribute
- [ ] Test creating order with new fields

---

## PRIORITY 4: RECEIPT ENHANCEMENTS ✨

### **Estimated Time:** 1-2 hours

### **A. Integrate Store Info** (1 hour)

**File:** `lib/features/admin/pos/presentation/services/receipt_service.dart`

**Changes:**

1. **[ ] Update printReceipt to accept store info**

   ```dart
   static Future<void> printReceipt(Order order, StoreInfo storeInfo) async {
     // ... existing code ...

     // Update header section
     pw.Center(
       child: pw.Column(
         children: [
           pw.Text(
             storeInfo.name.toUpperCase(),  // Use store name
             style: pw.TextStyle(
               fontSize: 20,
               fontWeight: pw.FontWeight.bold,
             ),
           ),
           pw.SizedBox(height: 4),
           pw.Text(
             'Point of Sale',
             style: const pw.TextStyle(fontSize: 12),
           ),
           pw.SizedBox(height: 2),
           if (storeInfo.address.isNotEmpty)
             pw.Text(
               storeInfo.address,  // Use store address
               style: const pw.TextStyle(fontSize: 10),
               textAlign: pw.TextAlign.center,
             ),
           if (storeInfo.phone.isNotEmpty)
             pw.Text(
               storeInfo.phone,  // Use store phone
               style: const pw.TextStyle(fontSize: 10),
             ),
         ],
       ),
     ),
   }
   ```

2. **[ ] Update order_success_dialog.dart**

   ```dart
   // Add provider import
   final storeInfo = ref.watch(storeInfoProvider);

   // Update print button
   onPressed: () => ReceiptService.printReceipt(order, storeInfo),
   ```

3. **[ ] Update order_detail_screen.dart**

   ```dart
   // Add provider import
   final storeInfo = ref.watch(storeInfoProvider);

   // Update print button
   onPressed: () => ReceiptService.printReceipt(order, storeInfo),
   ```

**Testing Checklist:**

- [ ] Test receipt with custom store name
- [ ] Test receipt with store address
- [ ] Test receipt with store phone
- [ ] Test receipt with empty address/phone
- [ ] Test print from POS success dialog
- [ ] Test print from order detail screen

---

## OPTIONAL: QR CODE (Future Enhancement)

**Skip for MVP** - Can be added later

**File:** `lib/features/admin/pos/presentation/services/receipt_service.dart`

**Dependencies:**

```yaml
qr_flutter: ^4.1.0
```

**Implementation:**

- Generate QR code with order tracking URL
- Add to receipt footer
- Link to customer order tracking page

---

## 🧪 TESTING CHECKLIST

### **Manual Testing Flow**

#### **Orders Management**

- [ ] Admin dapat melihat daftar semua orders
- [ ] Filter by status: All, Pending, Preparing, Ready, Completed, Cancelled
- [ ] Filter by date range
- [ ] Search by order number
- [ ] Search by customer name
- [ ] Tap order card → navigate to detail
- [ ] Order detail menampilkan semua info lengkap
- [ ] Update status: Pending → Preparing
- [ ] Update status: Preparing → Ready
- [ ] Update status: Ready → Completed
- [ ] Cancel order dengan reason
- [ ] Print receipt dari order detail
- [ ] Refresh orders list
- [ ] Empty state ketika no orders
- [ ] Loading state
- [ ] Error handling

#### **Bottom Navigation**

- [ ] Navigation POS → Orders
- [ ] Navigation Orders → Inventory
- [ ] Navigation Inventory → Reports
- [ ] Navigation Reports → Settings
- [ ] Navigation Settings → POS
- [ ] Selected state correct di setiap screen

#### **Receipt**

- [ ] Receipt menampilkan store name dari settings
- [ ] Receipt menampilkan store address
- [ ] Receipt menampilkan store phone
- [ ] Receipt handle empty address/phone

#### **Order Model**

- [ ] Order dengan notes tersimpan
- [ ] Cancelled order memiliki cancelledAt
- [ ] Cancelled order memiliki cancellationReason

---

## 📦 DEPENDENCIES CHECK

Pastikan semua dependencies sudah ada di `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Routing
  go_router: ^14.2.0

  # Backend
  appwrite: ^12.0.3

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Network
  connectivity_plus: ^6.0.3

  # UI
  cached_network_image: ^3.3.1
  image_picker: ^1.1.2

  # PDF & Printing
  pdf: ^3.11.0
  printing: ^5.13.1

  # Utils
  intl: ^0.19.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  package_info_plus: ^8.0.0

  # Charts
  fl_chart: ^0.68.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

  # Code Generation
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
```

**Check:**

- [ ] All dependencies present
- [ ] Run `flutter pub get`
- [ ] No version conflicts

---

## 🚀 DEPLOYMENT CHECKLIST

### **Before Go-Live**

- [ ] **AppWrite Setup**

  - [ ] Orders collection memiliki semua attributes (termasuk notes, cancelledAt, cancellationReason)
  - [ ] Pre-seed admin account
  - [ ] Seed 15 products dari CSV
  - [ ] Seed 15 addons dari CSV
  - [ ] Setup indexes untuk performance
  - [ ] Setup storage bucket

- [ ] **Testing**

  - [ ] Complete manual testing checklist
  - [ ] Test offline mode
  - [ ] Test sync after reconnect
  - [ ] Test on real devices (Android/iOS)

- [ ] **Documentation**

  - [ ] Update README with setup instructions
  - [ ] Document admin flows
  - [ ] Document AppWrite configuration

- [ ] **Performance**
  - [ ] Test with 100+ orders
  - [ ] Optimize queries if needed
  - [ ] Image caching working
  - [ ] Pagination if needed

---

## 📝 NOTES & TIPS

### **Best Practices**

1. **State Management:**

   - Always use autoDispose for providers that aren't globally needed
   - Use family modifier for parameterized providers (e.g., orderByIdProvider)
   - Listen to action providers for side effects (SnackBar, Dialog)

2. **Error Handling:**

   - Always catch AppwriteException
   - Show user-friendly error messages
   - Log errors to console for debugging

3. **UI/UX:**

   - Show loading states during operations
   - Disable buttons during loading
   - Provide visual feedback (SnackBar, Dialog)
   - Use Catppuccin colors consistently

4. **Testing:**
   - Test happy path first
   - Test error cases (network error, invalid data)
   - Test edge cases (empty list, offline mode)

### **Common Pitfalls to Avoid**

1. ❌ Forgetting to invalidate providers after updates

   - ✅ Always `ref.invalidate(allOrdersProvider)` after status update

2. ❌ Not handling null values from AppWrite

   - ✅ Use null-aware operators and provide defaults

3. ❌ Hardcoding collection IDs

   - ✅ Use AppwriteConfig constants

4. ❌ Not disposing controllers

   - ✅ Always override dispose() and dispose controllers

5. ❌ Forgetting to run build_runner after model changes
   - ✅ Run `flutter pub run build_runner build --delete-conflicting-outputs`

---

## 🎯 SUCCESS CRITERIA

Admin side is complete when:

- ✅ Admin can view all orders in a list
- ✅ Admin can filter orders by status, date, payment method
- ✅ Admin can search orders by order number or customer name
- ✅ Admin can view full order details
- ✅ Admin can update order status (Pending → Preparing → Ready → Completed)
- ✅ Admin can cancel orders with reason
- ✅ Bottom navigation works on all admin screens
- ✅ Receipt shows store info from settings
- ✅ All features work offline with sync when online
- ✅ UI is consistent with Catppuccin theme
- ✅ No major bugs or crashes

---

## 📞 SUPPORT

If you encounter issues:

1. Check console logs for errors
2. Verify AppWrite connection and collection structure
3. Check internet connectivity for online features
4. Clear Hive boxes if state seems corrupted
5. Run `flutter clean && flutter pub get`

---

**Happy Coding! 🚀**

---

**Last Updated:** December 16, 2025  
**Version:** 1.0  
**Status:** Ready for Implementation
