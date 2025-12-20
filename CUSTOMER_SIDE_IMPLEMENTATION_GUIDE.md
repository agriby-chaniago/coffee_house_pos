# 🚀 CUSTOMER SIDE IMPLEMENTATION GUIDE

**Project:** Coffee House POS - Customer App  
**Theme:** Catppuccin (Colorful & Minimalist)  
**Timeline:** 4-5 weeks  
**Status:** Ready for Implementation

---

## 📋 TABLE OF CONTENTS

1. [Overview](#overview)
2. [Design Philosophy](#design-philosophy)
3. [Implementation Checklist](#implementation-checklist)
4. [Recommended Implementation Order](#recommended-implementation-order)
5. [Technical Specifications](#technical-specifications)
6. [File Structure](#file-structure)
7. [Code Guidelines](#code-guidelines)
8. [Testing Checklist](#testing-checklist)

---

## 🎯 OVERVIEW

Customer app adalah aplikasi mobile untuk customer coffee house yang memungkinkan mereka:

- Browse menu produk dengan kategori
- Add products ke cart dengan add-ons
- Checkout dan create order
- Track order real-time
- View order history
- Manage profile

**Key Features:**

- ✨ Colorful UI dengan Catppuccin theme
- 🎨 Minimalist & clean design
- ⚡ Real-time order tracking
- 💾 Offline cart persistence
- 📱 Mobile-first responsive
- 🔄 Pull-to-refresh
- 🎭 Smooth animations

---

## 🎨 DESIGN PHILOSOPHY

### **Color Palette (Catppuccin Accents)**

```dart
// Category Colors
const categoryColors = {
  'Coffee': Color(0xFFDF8E1D),      // Peach
  'Non-Coffee': Color(0xFFCBA6F7),  // Mauve
  'Food': Color(0xFF94E2D5),        // Teal
  'Dessert': Color(0xFFF5C2E7),     // Pink
};

// Status Colors
const statusColors = {
  'pending': Colors.grey,
  'preparing': Colors.blue,
  'ready': Colors.green,
  'completed': Color(0xFFDF8E1D),   // Peach
  'cancelled': Colors.red,
};
```

### **UI Principles**

1. **Colorful but Cohesive**

   - Use accent colors untuk categories & badges
   - Maintain Catppuccin base colors
   - Gradients untuk hero sections

2. **Minimalist Layout**

   - White space generous (16-24px padding)
   - Clean typography hierarchy
   - Subtle shadows (elevation 1-2)
   - Rounded corners (12-20px)

3. **Smooth UX**
   - Hero animations untuk product images
   - Haptic feedback pada buttons
   - Loading states (shimmer/skeleton)
   - Error states dengan retry
   - Empty states dengan illustrations

---

## ✅ IMPLEMENTATION CHECKLIST

### **🔴 PHASE 1: MENU & PRODUCTS (Week 1-2)**

#### **1.1 Menu Provider**

- [x] File: `lib/features/customer/menu/presentation/providers/menu_provider.dart`
- [x] Implement `FutureProvider.autoDispose<List<Product>>`
- [x] Fetch products dari AppWrite
- [x] Cache di Hive untuk offline access
- [x] Error handling dengan ErrorHandler
- [x] Refresh functionality

**Technical Details:**

```dart
final menuProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  // 1. Try load from Hive cache first
  // 2. Fetch from AppWrite
  // 3. Update Hive cache
  // 4. Return products
});

final filteredMenuProvider = Provider.autoDispose<AsyncValue<List<Product>>>((ref) {
  // Filter by category & search query
});

final menuSearchProvider = StateProvider<String>((ref) => '');
final menuCategoryProvider = StateProvider<String>((ref) => 'All');
```

---

#### **1.2 Menu Screen**

- [x] File: `lib/features/customer/menu/presentation/screens/menu_screen.dart`
- [x] Implement AppBar dengan:
  - [x] Profile icon (leading)
  - [x] Cart icon (actions)
  - [x] Title "Coffee House"
- [x] Category tabs (All/Coffee/Non-Coffee/Food/Dessert)
  - [x] Colorful FilterChips
  - [x] Horizontal scrollable
- [x] Search bar dengan icon
  - [x] Debounce 300ms
  - [x] Clear button
- [x] Product grid (2 columns)
  - [x] Product cards dengan:
    - [x] Cached image (placeholder: coffee icon)
    - [x] Category badge (colorful)
    - [x] Product name (bold)
    - [x] Prices (M/L) dalam row
    - [x] Quick add button (+)
- [x] Pull-to-refresh
- [x] Loading state: Shimmer grid (6 items)
- [x] Error state: Retry button
- [x] Empty state: "No products found"
- [x] Bottom navigation bar (Menu/Orders/Profile)

**Widget Structure:**

```
Scaffold
├─ AppBar
│  ├─ Leading: CircleAvatar (profile)
│  ├─ Title: "Coffee House"
│  └─ Actions: Badge(cart icon)
├─ Body: Column
│  ├─ Search Bar (TextField)
│  ├─ Category Tabs (Wrap of FilterChips)
│  └─ Product Grid (GridView.builder)
│     └─ Product Card
│        ├─ Image (CachedNetworkImage)
│        ├─ Category Badge (Container)
│        ├─ Name (Text)
│        ├─ Prices Row (M/L)
│        └─ Add Button (IconButton)
└─ BottomNavigationBar
```

---

#### **1.3 Product Detail Modal**

- [x] File: `lib/features/customer/menu/presentation/widgets/product_detail_modal.dart`
- [x] Bottom sheet fullscreen
- [x] Sections:
  - [x] Hero Image dengan gradient overlay
    - [x] Gradient sesuai category color
    - [x] Close button (top-right)
  - [x] Product Info
    - [x] Name (titleLarge, bold)
    - [x] Description (bodyMedium)
    - [x] Category badge
  - [x] Size Selector
    - [x] RadioListTile untuk M/L
    - [x] Show price untuk each size
    - [x] Selected state colorful
  - [x] Add-ons Section
    - [x] Group by category (ExpansionTile)
    - [x] Categories: Milk Type, Sugar Level, Extras, Ice Level
    - [x] CheckboxListTile untuk each addon
    - [x] Show additional price (+Rp X)
    - [x] Icons per category (colorful)
  - [x] Quantity Stepper
    - [x] +/- buttons (min: 1)
    - [x] Number display (center)
  - [x] Price Calculator
    - [x] Live update
    - [x] Format: "Total: Rp XXX"
    - [x] Highlighted dengan card/container
  - [x] Add to Cart Button
    - [x] Full width
    - [x] Gradient background (category color)
    - [x] Icon + text "Add to Cart"
    - [x] Loading state

**State Management:**

```dart
class _ProductDetailModalState extends State<ProductDetailModal> {
  late ProductVariant _selectedVariant;
  final Set<String> _selectedAddonIds = {};
  int _quantity = 1;

  double get _itemPrice {
    final variantPrice = _selectedVariant.price;
    final addonsPrice = widget.availableAddons
        .where((a) => _selectedAddonIds.contains(a.id))
        .fold<double>(0, (sum, a) => sum + a.additionalPrice);
    return variantPrice + addonsPrice;
  }

  double get _totalPrice => _itemPrice * _quantity;
}
```

---

### **🟠 PHASE 2: CART SYSTEM (Week 2)**

#### **2.1 Customer Cart Provider**

- [x] File: `lib/features/customer/cart/presentation/providers/customer_cart_provider.dart`
- [x] Implement `StateNotifier<CartState>`
- [x] Functions:
  - [x] `addItem(CartItem item)` - Add product dengan add-ons
  - [x] `removeItem(String cartItemId)` - Remove dari cart
  - [x] `updateQuantity(String cartItemId, int quantity)` - Update qty
  - [x] `updateItem(String cartItemId, CartItem newItem)` - Edit item
  - [x] `clearCart()` - Clear semua items
  - [x] `getSubtotal()` - Calculate subtotal
  - [x] `getTaxAmount()` - Calculate PPN 11%
  - [x] `getTotal()` - Calculate total
- [x] Save to Hive on every change (persist cart)
- [x] Load from Hive on init

**Cart State Model:**

```dart
class CartState {
  final List<CartItem> items;
  final double subtotal;
  final double taxAmount;
  final double total;

  CartState({
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
  });
}

class CartItem {
  final String id; // UUID
  final String productId;
  final String productName;
  final String productImageUrl;
  final String category;
  final ProductVariant selectedVariant;
  final List<SelectedAddOn> selectedAddons;
  final int quantity;
  final double itemPrice; // Variant price + addons
  final double totalPrice; // itemPrice * quantity

  CartItem({...});
}
```

---

#### **2.2 Cart Screen**

- [x] File: `lib/features/customer/cart/presentation/screens/cart_screen.dart`
- [x] AppBar dengan title "My Cart"
- [x] Cart items list:
  - [x] CartItemCard untuk each item
    - [x] Product image (small, leading)
    - [x] Product name & category badge
    - [x] Size display (M/L)
    - [x] Add-ons list (chips)
    - [x] Quantity display
    - [x] Price (item total)
    - [x] Actions row:
      - [x] Edit button → reopen ProductDetailModal
      - [x] Delete button → confirmation dialog
  - [x] Swipe to delete (Dismissible)
- [x] Price breakdown card:
  - [x] Subtotal row
  - [x] PPN 11% row (calculated)
  - [x] Divider
  - [x] Total row (bold, large)
- [x] Checkout button:
  - [x] Fixed bottom
  - [x] Full width
  - [x] Gradient background (primary color)
  - [x] Disabled if cart empty
  - [x] Navigate to checkout screen
- [x] Empty cart state:
  - [x] Illustration
  - [x] "Your cart is empty"
  - [x] "Browse Menu" button

**Widget Structure:**

```
Scaffold
├─ AppBar: "My Cart"
├─ Body: Column
│  ├─ Cart Items List (ListView)
│  │  └─ Dismissible(CartItemCard)
│  │     ├─ Image
│  │     ├─ Info Column
│  │     │  ├─ Name + Badge
│  │     │  ├─ Size
│  │     │  ├─ Add-ons Wrap
│  │     │  └─ Quantity
│  │     ├─ Price
│  │     └─ Actions (Edit/Delete)
│  └─ Price Breakdown Card
│     ├─ Subtotal
│     ├─ PPN 11%
│     └─ Total (bold)
└─ Bottom: Checkout Button
```

---

### **🟡 PHASE 3: CHECKOUT & ORDER (Week 3)**

#### **3.1 Customer Checkout Provider**

- [x] File: `lib/features/customer/orders/presentation/providers/customer_checkout_provider.dart`
- [x] Implement `StateNotifier<CheckoutState>`
- [x] Function: `createOrder({String? customerName})`
  - [x] Get cart items dari customer_cart_provider
  - [x] Generate order number (format: YYYYMMDD-###)
  - [x] Create Order object:
    - [x] customerId (dari auth provider)
    - [x] customerName (optional)
    - [x] items (dari cart)
    - [x] subtotal/tax/total
    - [x] status: 'pending'
    - [x] paymentMethod: 'cash' (default)
    - [x] createdAt: DateTime.now()
  - [x] Save to AppWrite orders collection
  - [x] Save to Hive for offline access
  - [x] Clear cart
  - [x] Return order ID
- [x] Error handling & loading states

**Checkout State:**

```dart
class CheckoutState {
  final bool isLoading;
  final String? orderId;
  final String? error;

  CheckoutState({
    this.isLoading = false,
    this.orderId,
    this.error,
  });
}
```

---

#### **3.2 Checkout Screen**

- [x] File: `lib/features/customer/orders/presentation/screens/checkout_screen.dart`
- [x] AppBar: "Checkout"
- [x] Sections:
  - [x] Order Review Card
    - [x] Items count summary
    - [x] Expandable items list
  - [x] Customer Info Card
    - [x] TextField untuk customer name
    - [x] Label: "Your Name (Optional)"
    - [x] Helper text: "For order call-out"
  - [x] Payment Method Card
    - [x] Display only: "Cash at Store"
    - [x] Icon: money icon
    - [x] Info text: "Pay when you pick up"
  - [x] Order Summary Card
    - [x] Subtotal
    - [x] PPN 11%
    - [x] Divider
    - [x] Total (bold, large)
- [x] Confirm Order Button
  - [x] Fixed bottom
  - [x] Full width
  - [x] Gradient background
  - [x] Loading state (CircularProgressIndicator)
  - [x] On success: Navigate to OrderTrackingScreen
  - [x] On error: Show SnackBar
- [x] Back button: Show confirmation dialog

---

#### **3.3 Order Realtime Provider**

- [x] File: `lib/features/customer/orders/presentation/providers/order_realtime_provider.dart`
- [x] Implement `StreamProvider.family<Order, String>`
- [x] Subscribe to AppWrite Realtime untuk specific order
- [x] Listen to order status changes
- [x] Update UI automatically
- [x] Handle connection/disconnection
- [x] Helper functions for status colors & icons

**Implementation:**

```dart
final orderRealtimeProvider = StreamProvider.family<Order, String>((ref, orderId) {
  final appwrite = ref.watch(appwriteProvider);

  return appwrite.databases.subscribe(
    databaseId: AppwriteConfig.databaseId,
    collectionId: AppwriteConfig.ordersCollection,
    documentId: orderId,
  ).map((event) {
    // Parse event.payload to Order
    return Order.fromJson(event.payload);
  });
});
```

---

#### **3.4 Order Tracking Screen**

- [x] File: `lib/features/customer/orders/presentation/screens/order_tracking_screen.dart`
- [x] Receives: orderId as parameter
- [x] AppBar: "Order Tracking"
- [x] Real-time subscription via orderRealtimeProvider
- [x] Sections:
  - [x] Order Number Card
    - [x] Large display "#YYYYMMDD-###"
    - [x] Copy button
  - [x] Status Stepper (Vertical)
    - [x] Step 1: Pending (⏰ grey)
    - [x] Step 2: Preparing (🍳 blue)
    - [x] Step 3: Ready (✅ green)
    - [x] Step 4: Completed (✨ peach)
    - [x] Estimated times display
  - [x] Order Details Card (Collapsible)
    - [x] Items list
    - [x] Total amount
  - [x] Help Card
    - [x] "Need help?" text
    - [x] Contact info
- [x] Auto-refresh with pull-to-refresh
- [x] Loading & error states

**Status Indicator:**

```dart
Widget _buildStatusStep(String status, String title, IconData icon, Color color, {bool isActive = false, bool isCompleted = false}) {
  return Row(
    children: [
      Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted ? color : Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
      SizedBox(width: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          if (isActive) Text("Estimated 5-10 mins", style: TextStyle(color: color)),
        ],
      ),
    ],
  );
}
```

---

### **🟢 PHASE 4: ORDER HISTORY (Week 3-4)**

#### **4.1 Order History Provider**

- [x] File: `lib/features/customer/orders/presentation/providers/order_history_provider.dart`
- [x] Implement `FutureProvider.autoDispose<List<Order>>`
- [x] Fetch user orders dari AppWrite
- [x] Filter: `Query.equal('customerId', currentUserId)`
- [x] Sort: `Query.orderDesc('$createdAt')`
- [x] Cache di Hive
- [x] Refresh support
- [x] Filter & search providers

**Additional Providers:**

```dart
final orderHistoryFilterProvider = StateProvider<String>((ref) => 'all'); // all/pending/completed
final orderHistorySearchProvider = StateProvider<String>((ref) => '');

final filteredOrderHistoryProvider = Provider.autoDispose<AsyncValue<List<Order>>>((ref) {
  final ordersAsync = ref.watch(orderHistoryProvider);
  final filter = ref.watch(orderHistoryFilterProvider);
  final search = ref.watch(orderHistorySearchProvider);

  // Filter & search logic
});
```

---

#### **4.2 Order History Screen**

- [x] File: `lib/features/customer/orders/presentation/screens/order_history_screen.dart`
- [x] AppBar: "My Orders"
- [x] Filter chips (horizontal scroll)
  - [x] All (default)
  - [x] Pending
  - [x] Preparing
  - [x] Ready
  - [x] Completed
  - [x] Colorful selected state
- [x] Search bar dengan order number
- [x] Orders list:
  - [x] OrderHistoryCard untuk each order
    - [x] Order number (bold)
    - [x] Status badge (colorful)
    - [x] Date & time
    - [x] Items count
    - [x] Total amount
    - [x] Tap → Navigate to OrderDetailScreen
- [x] Pull-to-refresh
- [x] Loading states
- [x] Empty state: "No orders yet"
- [x] Bottom navigation bar

**Order History Card:**

```dart
class OrderHistoryCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status),
          child: Icon(Icons.receipt_long),
        ),
        title: Text(order.orderNumber, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM dd, HH:mm').format(order.createdAt)),
            Text('${order.items.length} items • Rp ${order.total}'),
          ],
        ),
        trailing: StatusBadge(status: order.status),
      ),
    );
  }
}
```

---

#### **4.3 Order Detail Screen**

- [x] File: `lib/features/customer/orders/presentation/screens/order_detail_screen.dart`
- [x] Receives: orderId as parameter
- [x] AppBar: "Order Details" + Refresh button
- [x] Digital Receipt View:
  - [x] Header Card
    - [x] Store name
    - [x] Order number (large)
    - [x] Date & time
    - [x] Status badge
  - [x] Customer Info (if provided)
    - [x] Name
  - [x] Items Table
    - [x] Each item row:
      - [x] Product name
      - [x] Size (M/L)
      - [x] Add-ons list (chips)
      - [x] Quantity
      - [x] Item total
  - [x] Price Breakdown
    - [x] Subtotal
    - [x] PPN 11%
    - [x] Total (bold, highlighted)
  - [x] Payment Method
    - [x] "Cash at Store" with icon
  - [x] Footer
    - [x] "Thank you for your order!"
- [x] Action buttons:
  - [x] Track order (if not completed)
  - [x] View All Orders button

**Share Receipt:**

```dart
Future<void> _shareReceipt() async {
  // Generate receipt image or PDF
  // Use screenshot package or pdf package
  // Share via share_plus package
}
```

---

### **🔵 PHASE 5: PROFILE & SETTINGS (Week 4)**

#### **5.1 Profile Provider**

- [x] File: `lib/features/customer/profile/presentation/providers/profile_provider.dart`
- [x] Implement `FutureProvider.autoDispose<ProfileStats>`
- [x] Fetch user orders
- [x] Calculate stats:
  - [x] Total orders count
  - [x] Total spent (sum of all order totals)
  - [x] Pending orders count
  - [x] Completed orders count
- [x] Refresh support

**Profile Stats Model:**

```dart
class ProfileStats {
  final int totalOrders;
  final double totalSpent;
  final List<Product> favoriteProducts; // optional

  ProfileStats({
    required this.totalOrders,
    required this.totalSpent,
    this.favoriteProducts = const [],
  });
}
```

---

#### **5.2 Profile Screen**

- [x] File: `lib/features/customer/profile/presentation/screens/profile_screen.dart` (enhance existing)
- [x] AppBar: "Profile"
- [x] Sections:
  - [x] User Info Card
    - [x] CircleAvatar dengan gradient border
    - [x] User name (dari auth)
    - [x] User email
  - [x] Statistics Cards (2 columns + 2 rows)
    - [x] Card 1: Total Orders (Peach)
    - [x] Card 2: Total Spent (Mauve)
    - [x] Card 3: Pending Orders (Yellow)
    - [x] Card 4: Completed Orders (Green)
  - [x] Settings Section
    - [x] ListTile: Theme
      - [x] Leading: Icon (brightness_6)
      - [x] Title: "Theme"
      - [x] Trailing: Switch (Mocha ↔ Latte)
    - [x] ListTile: Notifications (placeholder)
      - [x] Leading: Icon (notifications)
      - [x] Title: "Notifications"
      - [x] Trailing: Switch (disabled)
  - [x] About Section
    - [x] ListTile: About App
    - [x] ListTile: Terms & Conditions
    - [x] ListTile: Privacy Policy
  - [x] Logout Button
    - [x] Red color
    - [x] Icon + text
    - [x] Confirmation dialog
    - [x] On confirm: authProvider.signOut()
- [x] Bottom navigation bar

---

### **⚪ PHASE 6: ADDITIONAL FEATURES (Week 4-5)**

#### **6.1 Bottom Navigation Bar**

- [x] File: `lib/features/customer/shared/widgets/customer_bottom_nav.dart`
- [x] 3 tabs:
  - [x] Menu (home icon)
  - [x] Orders (receipt icon)
  - [x] Profile (person icon)
- [x] Colorful selected state (Peach)
- [x] Smooth transition with NavigationBar
- [x] Add to all customer screens (Menu, Orders, Profile)

---

#### **6.2 Notifications (Placeholder)**

- [ ] File: `lib/features/customer/notifications/presentation/providers/notification_provider.dart`
- [ ] Setup FCM (Firebase Cloud Messaging) - optional
- [ ] Listen to order status changes
- [ ] Show local notification
- [ ] Notification screen (list of notifications) - optional

---

#### **6.3 Search Enhancement**

- [ ] Recent searches (save to Hive)
- [ ] Popular products query
- [ ] Search suggestions (autocomplete)
- [ ] Category shortcuts in search

---

#### **6.4 Favorites System (Optional)**

- [ ] File: `lib/features/customer/favorites/presentation/providers/favorites_provider.dart`
- [ ] StateNotifier untuk manage favorites
- [ ] Add/remove favorite products
- [ ] Save to Hive (persist)
- [ ] Display favorites in menu screen
- [ ] Heart icon on product cards

---

### **🎨 PHASE 7: POLISH & UX (Week 5)**

#### **7.1 Animations**

- [x] Hero animations:
  - [x] Product image (MenuScreen → ProductDetailModal)
- [x] Page transitions:
  - [x] Slide from bottom untuk modals
  - [x] Fade for navigation
- [x] Micro-interactions:
  - [x] Bounce on add to cart
  - [x] Ripple effects
  - [x] Scale on button press
  - [x] Animated buttons widget

**Implementation:**

```dart
// Hero Animation
Hero(
  tag: 'product-${product.id}',
  child: CachedNetworkImage(imageUrl: product.imageUrl),
)

// Page Transition
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  },
)
```

---

#### **7.2 Haptic Feedback**

- [ ] Install package: `flutter_vibrate` (OPTIONAL)
- [ ] Add feedback on:
  - [ ] Button taps (OPTIONAL)
  - [ ] Add to cart (OPTIONAL)
  - [ ] Remove from cart (OPTIONAL)
  - [ ] Order confirmation (OPTIONAL)
  - [ ] Success actions (OPTIONAL)

```dart
import 'package:flutter_vibrate/flutter_vibrate.dart';

void _hapticLight() {
  Vibrate.feedback(FeedbackType.light);
}

void _hapticMedium() {
  Vibrate.feedback(FeedbackType.medium);
}
```

---

#### **7.3 Loading States**

- [x] Shimmer loading untuk:
  - [x] Product grid
  - [x] Order list
  - [x] Profile stats
- [x] Skeleton screens (ShimmerProductCard, ShimmerOrderCard)
- [x] Colorful progress indicators
- [x] Animated placeholders

**Shimmer Package:**

```dart
import 'package:shimmer/shimmer.dart';

Widget _buildShimmerCard() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Card(
      child: Container(height: 200),
    ),
  );
}
```

---

#### **7.4 Error Handling**

- [x] No internet dialog:
  - [x] Icon: wifi_off
  - [x] Message: "No internet connection"
  - [x] Retry button
- [x] Error states:
  - [x] ErrorStateWidget (full page)
  - [x] NetworkErrorState
  - [x] LoadFailedState
  - [x] InlineErrorWidget (small errors)
- [x] User-friendly messages
- [x] Colorful error cards
- [x] SnackBar helpers (Error & Success)

---

#### **7.5 Empty States**

- [x] Empty cart:
  - [x] Icon with animation (shopping_cart_outlined)
  - [x] Text: "Cart is Empty"
  - [x] Button: "Browse Menu"
- [x] No orders:
  - [x] Icon with animation (receipt_long_outlined)
  - [x] Text: "No orders yet"
  - [x] Button: "Order Now"
- [x] No search results:
  - [x] Icon (search_off)
  - [x] Text: "No products found"
  - [x] Dynamic message with query
- [x] Filtered orders empty:
  - [x] Icon (filter_list_off)
  - [x] Text: "No {status} Orders"
- [x] All with colorful icons & animations

**Use package:** `flutter_svg` or `lottie` for illustrations

---

#### **7.6 Image Optimization**

- [x] Use `cached_network_image` package
- [x] Placeholder images:
  - [x] Coffee icon for products
  - [x] User icon for profile
- [x] Error images:
  - [x] Broken image icon
- [x] Lazy loading in lists (ListView.builder, GridView.builder)
- [x] Fade-in animation on load
- [x] Category-colored placeholders

```dart
CachedNetworkImage(
  imageUrl: product.imageUrl,
  placeholder: (context, url) => Center(
    child: Icon(Icons.coffee, size: 64, color: Colors.grey),
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
  fit: BoxFit.cover,
  fadeInDuration: Duration(milliseconds: 300),
)
```

---

## 📦 RECOMMENDED IMPLEMENTATION ORDER

### **Week 1: Foundation**

1. ✅ Menu Provider (1 day)
2. ✅ Menu Screen dengan product grid (2 days)
3. ✅ Product Detail Modal (2 days)

### **Week 2: Cart & Checkout**

4. ✅ Customer Cart Provider (1 day)
5. ✅ Cart Screen (2 days)
6. ✅ Checkout Provider (1 day)
7. ✅ Checkout Screen (1 day)

### **Week 3: Orders**

8. ✅ Order Realtime Provider (1 day) - **DONE**
9. ✅ Order Tracking Screen (2 days) - **DONE**
10. ✅ Order History Provider (1 day) - **DONE**
11. ✅ Order History Screen (1 day) - **DONE**
12. ✅ Order Detail Screen (1 day) - **DONE**

### **Week 4: Profile & Additional**

13. ✅ Profile Provider (0.5 day) - **DONE**
14. ✅ Profile Screen (1 day) - **DONE**
15. ✅ Bottom Navigation Bar (0.5 day) - **DONE**
16. ⏳ Search Enhancement (1 day) - OPTIONAL
17. ⏳ Favorites System (optional) (1 day) - OPTIONAL

### **Week 5: Polish**

18. ✅ Animations (1 day) - **DONE**
19. ⏩ Haptic Feedback (0.5 day) - **SKIPPED (Optional)**
20. ✅ Loading States (1 day) - **DONE**
21. ✅ Error Handling (1 day) - **DONE**
22. ✅ Empty States (0.5 day) - **DONE**
23. ✅ Image Optimization (0.5 day) - **DONE**
24. ⏳ Testing & Bug Fixes (1 day) - **NEXT**

---

## 📂 FILE STRUCTURE

```
lib/features/customer/
├── menu/
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── menu_provider.dart
│   │   ├── screens/
│   │   │   └── menu_screen.dart
│   │   └── widgets/
│   │       ├── product_card.dart
│   │       ├── product_detail_modal.dart
│   │       ├── category_chip.dart
│   │       └── search_bar.dart
│   └── (reuse data/models from admin side)
│
├── cart/
│   ├── data/
│   │   └── models/
│   │       └── cart_item_model.dart
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── customer_cart_provider.dart
│   │   ├── screens/
│   │   │   └── cart_screen.dart
│   │   └── widgets/
│   │       ├── cart_item_card.dart
│   │       └── price_breakdown_card.dart
│
├── orders/
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── customer_checkout_provider.dart
│   │   │   ├── order_realtime_provider.dart
│   │   │   └── order_history_provider.dart
│   │   ├── screens/
│   │   │   ├── checkout_screen.dart
│   │   │   ├── order_tracking_screen.dart
│   │   │   ├── order_history_screen.dart
│   │   │   └── order_detail_screen.dart
│   │   └── widgets/
│   │       ├── order_history_card.dart
│   │       ├── status_stepper.dart
│   │       └── digital_receipt.dart
│   └── (reuse data/models from admin side)
│
├── profile/
│   ├── data/
│   │   └── models/
│   │       └── profile_stats_model.dart
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── profile_provider.dart
│   │   ├── screens/
│   │   │   └── profile_screen.dart
│   │   └── widgets/
│   │       └── stats_card.dart
│
├── favorites/ (optional)
│   └── presentation/
│       └── providers/
│           └── favorites_provider.dart
│
├── notifications/ (optional)
│   └── presentation/
│       └── providers/
│           └── notification_provider.dart
│
└── shared/
    └── widgets/
        ├── customer_bottom_nav.dart
        ├── empty_state.dart
        ├── error_state.dart
        └── shimmer_loading.dart
```

---

## 💻 CODE GUIDELINES

### **1. Naming Conventions**

```dart
// Providers
final menuProvider = FutureProvider...
final customerCartProvider = StateNotifierProvider...

// Screens
class MenuScreen extends ConsumerStatefulWidget
class CartScreen extends ConsumerWidget

// Widgets
class ProductCard extends StatelessWidget
class CartItemCard extends StatelessWidget

// Models
class CartItem
class ProfileStats

// Constants
const double kDefaultPadding = 16.0;
const Duration kAnimationDuration = Duration(milliseconds: 300);
```

### **2. Widget Structure**

```dart
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  // State variables

  @override
  void initState() {
    super.initState();
    // Initialize
  }

  @override
  void dispose() {
    // Cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menuAsync = ref.watch(menuProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(menuAsync),
      bottomNavigationBar: CustomerBottomNav(currentIndex: 0),
    );
  }

  // Private build methods
  Widget _buildAppBar() { ... }
  Widget _buildBody(AsyncValue<List<Product>> menuAsync) { ... }
}
```

### **3. Provider Patterns**

```dart
// FutureProvider for async data fetching
final menuProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  // Fetch logic
});

// StateNotifier for state management
class CustomerCartNotifier extends StateNotifier<CartState> {
  CustomerCartNotifier() : super(CartState.empty());

  void addItem(CartItem item) {
    // Update state
    state = state.copyWith(items: [...state.items, item]);
    _saveToHive();
  }
}

final customerCartProvider = StateNotifierProvider<CustomerCartNotifier, CartState>((ref) {
  return CustomerCartNotifier();
});

// StreamProvider for realtime
final orderRealtimeProvider = StreamProvider.family<Order, String>((ref, orderId) {
  // Realtime subscription
});
```

### **4. Error Handling**

```dart
// In providers
try {
  // Operation
} catch (e) {
  final message = ErrorHandler.getUserFriendlyMessage(e);
  throw Exception(message);
}

// In UI
menuAsync.when(
  data: (products) => _buildProductGrid(products),
  loading: () => _buildShimmerLoading(),
  error: (error, stack) => ErrorState(
    message: error.toString(),
    onRetry: () => ref.invalidate(menuProvider),
  ),
)
```

### **5. Theming**

```dart
// Use theme colors
final theme = Theme.of(context);

Container(
  color: theme.colorScheme.surface,
  child: Text(
    'Hello',
    style: theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.bold,
    ),
  ),
)

// Category colors
final categoryColor = _getCategoryColor(product.category);

Color _getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'coffee': return const Color(0xFFDF8E1D);
    case 'non-coffee': return const Color(0xFFCBA6F7);
    case 'food': return const Color(0xFF94E2D5);
    case 'dessert': return const Color(0xFFF5C2E7);
    default: return Colors.grey;
  }
}
```

### **6. Navigation**

```dart
// Using go_router
context.go('/customer/cart');
context.push('/customer/orders/track/$orderId');
context.pop();

// With result
final result = await context.push('/customer/product/$productId');
if (result == true) {
  // Product added to cart
}
```

### **7. Performance**

```dart
// Use const constructors
const SizedBox(height: 16)
const Icon(Icons.coffee)

// Use Keys for lists
ListView.builder(
  key: ValueKey('menu-list'),
  itemBuilder: (context, index) => ProductCard(
    key: ValueKey(products[index].id),
    product: products[index],
  ),
)

// Lazy loading
ListView.builder() // Instead of ListView(children: [...])

// Image caching
CachedNetworkImage(...) // Instead of Image.network()
```

---

## ✅ TESTING CHECKLIST

### **Functional Testing**

**Menu & Products:**

- [ ] Products load correctly
- [ ] Category filter works
- [ ] Search filters products
- [ ] Product detail modal opens
- [ ] Size selection works
- [ ] Add-ons selection works
- [ ] Quantity stepper works (min: 1)
- [ ] Price calculates correctly
- [ ] Add to cart succeeds

**Cart:**

- [ ] Cart persists (survives app restart)
- [ ] Items display correctly with add-ons
- [ ] Edit item reopens modal with selections
- [ ] Remove item works with confirmation
- [ ] Swipe to delete works
- [ ] Price breakdown calculates correctly (PPN 11%)
- [ ] Checkout button disabled when empty

**Checkout:**

- [ ] Customer name optional
- [ ] Order summary accurate
- [ ] Create order succeeds
- [ ] Order number generated correctly
- [ ] Cart clears after order
- [ ] Navigation to tracking works

**Order Tracking:**

- [ ] Real-time updates work
- [ ] Status changes reflect immediately
- [ ] Stepper shows correct progress
- [ ] Estimated times display
- [ ] Offline mode handles gracefully

**Order History:**

- [ ] Orders load correctly
- [ ] Filter by status works
- [ ] Search by order number works
- [ ] Tap navigates to detail
- [ ] Pull-to-refresh works

**Order Detail:**

- [ ] Receipt displays correctly
- [ ] All items with add-ons show
- [ ] Price breakdown accurate
- [ ] Share receipt works (optional)
- [ ] Reorder works (optional)

**Profile:**

- [ ] User info displays
- [ ] Stats calculate correctly
- [ ] Theme toggle works
- [ ] Logout works with confirmation

---

### **UI/UX Testing**

**Visual:**

- [ ] Colors match Catppuccin theme
- [ ] Category colors distinct
- [ ] Text readable (contrast)
- [ ] Images load with placeholders
- [ ] Icons colorful & meaningful
- [ ] Cards have subtle shadows
- [ ] Spacing consistent (16-24px)

**Animations:**

- [ ] Hero animations smooth
- [ ] Page transitions natural
- [ ] Micro-interactions responsive
- [ ] Loading states animated

**Responsiveness:**

- [ ] Works on various screen sizes
- [ ] Portrait & landscape modes
- [ ] Text doesn't overflow
- [ ] Images scale properly
- [ ] Bottom nav doesn't overlap content

**Accessibility:**

- [ ] Tap targets ≥ 48x48 dp
- [ ] Text size adjustable
- [ ] Color contrast sufficient
- [ ] Error messages clear

---

### **Performance Testing**

- [ ] App starts < 3 seconds
- [ ] Product grid scrolls smoothly (60fps)
- [ ] Images load progressively
- [ ] No memory leaks
- [ ] Offline mode works
- [ ] Cache effective (reduces network calls)

---

### **Edge Cases**

- [ ] Empty cart checkout blocked
- [ ] Zero quantity blocked
- [ ] Offline order creation handled
- [ ] Network errors handled gracefully
- [ ] Invalid order ID handled
- [ ] No products scenario
- [ ] No add-ons available
- [ ] Very long product names
- [ ] Many add-ons selected
- [ ] Large order (50+ items)

---

## 🎓 ADDITIONAL RESOURCES

### **Packages to Use**

```yaml
dependencies:
  # Core
  flutter_riverpod: ^2.5.1
  go_router: ^13.2.0

  # State & Data
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Network & Backend
  appwrite: ^12.0.3
  http: ^1.2.0

  # UI Components
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  flutter_svg: ^2.0.10+1
  lottie: ^3.1.0

  # Utilities
  intl: ^0.19.0
  uuid: ^4.3.3
  share_plus: ^7.2.2
  url_launcher: ^6.2.5

  # Haptics (optional)
  flutter_vibrate: ^1.3.0

  # Notifications (optional)
  firebase_messaging: ^14.7.20
  flutter_local_notifications: ^17.0.1
```

### **Design References**

- **Catppuccin Theme**: https://github.com/catppuccin/catppuccin
- **Material Design 3**: https://m3.material.io/
- **Flutter Gallery**: https://gallery.flutter.dev/

### **Learning Resources**

- **Riverpod Docs**: https://riverpod.dev/
- **AppWrite Docs**: https://appwrite.io/docs
- **Go Router Guide**: https://pub.dev/packages/go_router

---

## 🚀 GETTING STARTED

### **Pre-Implementation Checklist**

Before starting implementation, ensure:

- [ ] Admin side completed & tested
- [ ] AppWrite collections configured
- [ ] Product & Add-on data seeded
- [ ] Auth flow working (Google Sign-in)
- [ ] Hive initialized
- [ ] All dependencies installed
- [ ] Theme configured (Catppuccin)
- [ ] Assets prepared (icons, illustrations)

### **First Steps**

1. **Create folder structure**

   ```bash
   mkdir -p lib/features/customer/{menu,cart,orders,profile,shared}/{data,presentation}/{models,providers,screens,widgets}
   ```

2. **Install additional packages**

   ```bash
   flutter pub add cached_network_image shimmer flutter_svg uuid share_plus
   ```

3. **Create base files**

   - Start with menu_provider.dart
   - Then menu_screen.dart
   - Follow implementation order

4. **Test frequently**
   - Test each feature before moving to next
   - Use hot reload for quick iterations
   - Check on real device for performance

---

## 📝 NOTES

### **Important Reminders**

1. **Reuse Admin Models**

   - Product, ProductVariant, AddOn models already exist
   - Don't duplicate - import from admin side

2. **Order Model Sharing**

   - Customer creates orders
   - Admin manages orders
   - Same Order model, different screens

3. **Cart vs POS Cart**

   - Customer has persistent cart (Hive)
   - Admin POS has session cart (memory)
   - Separate providers, different use cases

4. **Real-time Sync**

   - Only order tracking uses real-time
   - Menu/products use standard fetch + cache
   - Balance real-time vs polling

5. **Offline Support**

   - Cart persists offline
   - Orders queue when offline
   - Show clear offline indicators

6. **Performance**
   - Use autoDispose for providers
   - Implement pagination if needed
   - Lazy load images
   - Cache aggressively

---

## ✨ SUCCESS CRITERIA

Customer app is complete when:

✅ **Core Features Working:**

- Browse menu dengan categories & search
- Add products to cart dengan add-ons
- Checkout dan create order
- Track order real-time
- View order history
- Manage profile

✅ **UX Polished:**

- Colorful & attractive UI
- Smooth animations
- Helpful loading states
- Clear error messages
- Intuitive navigation

✅ **Performance Good:**

- App responsive (< 3s startup)
- Smooth scrolling (60fps)
- Images load quickly
- Works offline

✅ **Tested:**

- All features tested
- Edge cases handled
- No crashes
- User-friendly

---

## 🎉 FINAL CHECKLIST

Before marking customer side as complete:

- [ ] All screens implemented
- [ ] All providers working
- [ ] Navigation smooth
- [ ] Theme consistent
- [ ] Images optimized
- [ ] Animations added
- [ ] Error handling complete
- [ ] Loading states everywhere
- [ ] Empty states designed
- [ ] Bottom nav functional
- [ ] Real-time working
- [ ] Cart persists
- [ ] Orders sync
- [ ] Profile displays
- [ ] Logout works
- [ ] Testing passed
- [ ] Performance acceptable
- [ ] Code documented
- [ ] Git committed
- [ ] Ready for production

---

**Last Updated:** December 19, 2025  
**Version:** 1.0  
**Author:** AI Assistant  
**Project:** Coffee House POS - Customer Side

---

**Good luck with the implementation! 🚀☕**
