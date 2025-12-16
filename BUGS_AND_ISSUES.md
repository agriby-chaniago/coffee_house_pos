# 🐛 BUGS & ISSUES TRACKER

**Created:** December 16, 2025  
**Status:** Pre-Manual Testing  
**Total Issues:** 10

---

## 🔴 CRITICAL PRIORITY (Must Fix)

### 1. Memory Leak - Stream Not Disposed

**File:** `lib/core/providers/sync_status_provider.dart`  
**Line:** 6-9  
**Severity:** 🔴 Critical

**Issue:**

```dart
final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
  // ❌ Stream never closed, causes memory leak
});
```

**Impact:**

- Memory leak on app lifecycle
- Stream listeners accumulate
- Battery drain over time

**Fix:**

```dart
final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  final connectivity = Connectivity();
  final stream = connectivity.onConnectivityChanged;

  ref.onDispose(() {
    // Properly dispose stream subscription
  });

  return stream;
});
```

**Status:** 🟡 Pending

---

### 2. Memory Leak - Image File Not Cleaned

**Files:**

- `lib/features/admin/inventory/presentation/providers/product_form_provider.dart`
- `lib/features/admin/inventory/presentation/providers/edit_product_provider.dart`

**Line:** ~60-80  
**Severity:** 🔴 Critical

**Issue:**

```dart
Future<bool> pickImage() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    final file = File(pickedFile.path);
    // Upload file to AppWrite
    // ❌ Temp file stays in memory/disk after upload
    return true;
  }
}
```

**Impact:**

- Disk space consumed by temp files
- Memory not freed after upload
- Multiple uploads can fill device storage

**Fix:**

```dart
File? tempFile;
try {
  tempFile = File(pickedFile.path);
  // Upload logic
  await uploadImage(tempFile);
} finally {
  // Clean up temp file
  if (tempFile != null && await tempFile.exists()) {
    await tempFile.delete();
  }
}
```

**Status:** 🟡 Pending

---

## 🟡 HIGH PRIORITY (Should Fix)

### 3. Performance - No Pagination for Orders

**File:** `lib/features/admin/orders/presentation/providers/orders_provider.dart`  
**Line:** 90  
**Severity:** 🟡 High

**Issue:**

```dart
queries: [
  Query.orderDesc('\$createdAt'),
  Query.limit(100), // ❌ Hardcoded limit, no pagination
],
```

**Impact:**

- App slows down with >100 orders
- Unnecessary network bandwidth
- Poor UX with large datasets

**Fix:**

- Implement infinite scroll / load more
- Add pagination parameters
- Cache previous pages

**Status:** 🟡 Pending

---

### 4. Performance - Client-Side Search

**File:** `lib/features/admin/orders/presentation/providers/orders_provider.dart`  
**Line:** 148-153  
**Severity:** 🟡 High

**Issue:**

```dart
if (filter.searchQuery.isNotEmpty) {
  final query = filter.searchQuery.toLowerCase();
  filtered = filtered.where((o) {
    return o.orderNumber.toLowerCase().contains(query) ||
           (o.customerName?.toLowerCase().contains(query) ?? false);
  }).toList(); // ❌ Filtering after fetching all data
}
```

**Impact:**

- All orders fetched before filtering
- Slow search with large datasets
- Network waste

**Fix:**

```dart
// Use AppWrite server-side search
queries: [
  if (searchQuery.isNotEmpty)
    Query.search('orderNumber', searchQuery),
],
```

**Status:** 🟡 Pending

---

### 5. Missing Input Validation

**File:** `lib/features/admin/pos/presentation/providers/checkout_provider.dart`  
**Line:** 45-50  
**Severity:** 🟡 High

**Issue:**

```dart
Future<bool> processCheckout({
  required PaymentMethod paymentMethod,
  String? customerName,
  double? cashReceived, // ❌ No validation (can be negative, zero, or less than total)
}) async {
  // No validation before processing
}
```

**Impact:**

- Can create invalid transactions
- Cash payment with insufficient amount
- Data integrity issues

**Fix:**

```dart
// Add validation
if (paymentMethod == PaymentMethod.cash && cashReceived != null) {
  if (cashReceived < cart.total) {
    throw ValidationException('Insufficient cash: received $cashReceived, required ${cart.total}');
  }
  if (cashReceived < 0) {
    throw ValidationException('Cash received cannot be negative');
  }
}
```

**Status:** 🟡 Pending

---

### 6. Missing Numeric Validation in Forms

**Files:**

- `lib/features/admin/inventory/presentation/screens/product_form_screen.dart`
- `lib/features/admin/inventory/presentation/screens/edit_product_screen.dart`

**Severity:** 🟡 High

**Issue:**

- Price fields accept negative numbers
- Stock fields accept negative numbers
- No min/max validation

**Impact:**

- Invalid product data in database
- Negative prices/stock cause calculation errors
- Poor data quality

**Fix:**

```dart
TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty) return 'Required';
    final number = double.tryParse(value);
    if (number == null) return 'Invalid number';
    if (number < 0) return 'Cannot be negative';
    if (number > 1000000) return 'Value too large';
    return null;
  },
)
```

**Status:** 🟡 Pending

---

## 🟠 MEDIUM PRIORITY (Nice to Fix)

### 7. Code Duplication - Receipt Service

**File:** `lib/features/admin/pos/presentation/services/receipt_service.dart`  
**Lines:** 15-240 and 289-504  
**Severity:** 🟠 Medium

**Issue:**

- `printReceipt()` and `shareReceipt()` have 99% duplicate code
- Same receipt building logic repeated
- Hard to maintain consistency

**Impact:**

- Code maintainability
- Bug fixes need double updates
- Violates DRY principle

**Fix:**

```dart
// Extract common logic
static pw.Document _buildReceiptDocument(
  Order order, {
  String? storeName,
  String? storeAddress,
  String? storePhone,
}) {
  final pdf = pw.Document();
  // ... common building logic
  return pdf;
}

static Future<void> printReceipt(...) async {
  final pdf = _buildReceiptDocument(order, ...);
  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}

static Future<void> shareReceipt(...) async {
  final pdf = _buildReceiptDocument(order, ...);
  await Printing.sharePdf(bytes: await pdf.save(), filename: '...');
}
```

**Status:** 🟡 Pending

---

### 8. Error Messages Not User-Friendly

**Multiple Files:** All providers  
**Severity:** 🟠 Medium

**Issue:**

```dart
catch (e) {
  state = state.copyWith(error: e.toString());
  // ❌ Exposes technical stack trace to user
}
```

**Impact:**

- Confusing error messages for users
- Technical details exposed
- Poor UX

**Fix:**

```dart
String _getUserFriendlyMessage(Object error) {
  if (error is AppwriteException) {
    switch (error.code) {
      case 401: return 'Session expired. Please login again.';
      case 404: return 'Item not found.';
      case 500: return 'Server error. Please try again.';
      default: return 'Something went wrong. Please try again.';
    }
  }
  return 'An unexpected error occurred.';
}

catch (e) {
  state = state.copyWith(error: _getUserFriendlyMessage(e));
}
```

**Status:** 🟡 Pending

---

### 9. Inconsistent Offline Handling

**Multiple Files**  
**Severity:** 🟠 Medium

**Issue:**

- `OfflineSyncManager` exists but not used consistently
- Some operations don't queue when offline
- Inconsistent behavior across features

**Impact:**

- App crashes or fails silently when offline
- Data loss potential
- Inconsistent UX

**Fix:**

- Audit all AppWrite calls
- Ensure all write operations use OfflineSyncManager
- Add offline state indicators in UI

**Status:** 🟡 Pending

---

## 🟢 LOW PRIORITY (Optional)

### 10. Hardcoded Strings (i18n)

**Multiple Files:** All UI files  
**Severity:** 🟢 Low

**Issue:**

```dart
throw Exception('Cart is empty'); // ❌ Hardcoded
'Failed to print: $e' // ❌ Hardcoded
'THANK YOU' // ❌ Hardcoded
```

**Impact:**

- Not internationalization ready
- Hard to maintain consistency
- No multi-language support

**Fix:**

- Create `AppStrings` class or use flutter_localizations
- Extract all user-facing strings
- Implement l10n if needed

**Status:** 🟡 Pending

---

## 📊 SUMMARY

| Priority    | Count  | Must Fix Before Production |
| ----------- | ------ | -------------------------- |
| 🔴 Critical | 2      | ✅ YES                     |
| 🟡 High     | 4      | ✅ YES                     |
| 🟠 Medium   | 3      | ⚠️ Recommended             |
| 🟢 Low      | 1      | ❌ Optional                |
| **TOTAL**   | **10** | **6 Required**             |

---

## 🎯 FIX PLAN

### Phase 1: After Manual Testing (Critical + High)

1. ✅ Fix stream disposal (15 mins)
2. ✅ Fix image file cleanup (20 mins)
3. ✅ Add input validation (30 mins)
4. ✅ Improve error messages (20 mins)
5. ⚠️ Add pagination (optional - can defer)
6. ⚠️ Server-side search (optional - can defer)

**Estimated Time:** ~1.5 hours

### Phase 2: Before Production (Medium)

7. Extract receipt code duplication (20 mins)
8. Implement consistent offline handling (1 hour)

**Estimated Time:** ~1.5 hours

### Phase 3: Future Enhancement (Low)

9. Implement i18n/l10n

---

## 📝 NOTES FOR MANUAL TESTING

When testing, look for:

- **Memory usage** increasing over time (Issue #1, #2)
- **Slow loading** with many orders (Issue #3, #4)
- **Invalid data entry** accepted in forms (Issue #5, #6)
- **Confusing error messages** (Issue #8)
- **Offline behavior** inconsistencies (Issue #9)

---

## 🔥 MANUAL TESTING FINDINGS (December 16, 2025)

**Test Status:** 30/35 Passed | 5 Issues Found | 3 Critical

---

### 11. CRITICAL: Product Images Not Displaying ⚠️🔴

**Files:**

- `lib/features/admin/inventory/presentation/providers/product_form_provider.dart`
- `lib/features/admin/inventory/presentation/providers/edit_product_provider.dart`

**Test Cases:** 4.3, 4.4  
**Severity:** 🔴 CRITICAL

**Issue:**

- Upload berhasil (notifikasi muncul)
- Image tidak tampil di product list/detail
- Placeholder icon kategori tampil instead

**Impact:**

- Product images tidak bisa dilihat user
- Bad UX, terlihat unprofessional
- Storage terisi tapi tidak digunakan

**Possible Causes:**

1. Image URL construction salah
2. AppWrite Storage bucket not public
3. Image view URL tidak accessible
4. CORS or permissions issue

**Investigation Needed:**

- Check AppWrite storage bucket settings (public access)
- Verify image URL format in database
- Check browser network logs for 403/404 errors
- Test direct URL access

**Status:** 🔴 URGENT - Must investigate & fix

---

### 12. CRITICAL: Stock Adjustment - Waste Type Error (400) ⚠️🔴

**Feature:** Stock Adjustment - Waste tracking  
**Severity:** 🔴 CRITICAL

**Issue:**

```
Error 400: value must be one of(sale, restock, adjustment)
"waste" is not accepted
```

**Root Cause:**
AppWrite enum validation - "waste" not in allowed movement types

**Expected Behavior:**

- Admin pilih "Waste" (Expired/Damaged/Spilled/Other)
- Stock movement created with type "waste"
- Entry muncul di Waste Logs page

**Fix Options:**

1. **Update AppWrite schema**: Add "waste" to enum [sale, restock, adjustment, waste]
2. **Code workaround**: Map waste → "adjustment" + add metadata field for waste reason

**Files to Update:**

- AppWrite stock_movements collection schema
- `lib/features/admin/inventory/data/models/stock_movement_model.dart`
- Stock adjustment provider

**Status:** 🔴 URGENT - Blocks waste tracking feature

---

### 13. Product Category Inconsistency 🟡

**File:** Product form dropdown  
**Test Case:** 4.3  
**Severity:** 🟡 High

**Issue:**

- Inventory displays: Coffee, Non-Coffee, Food, **Dessert**
- Add Product form shows: Coffee, Non-Coffee, Food, **Snack**
- Inconsistent category naming

**Fix:**
Replace "Snack" with "Dessert" in product form dropdown

**File to Update:**
`lib/features/admin/inventory/presentation/screens/product_form_screen.dart`

```dart
// Change from:
['Coffee', 'Non-Coffee', 'Food', 'Snack']
// To:
['Coffee', 'Non-Coffee', 'Food', 'Dessert']
```

**Status:** 🟡 Pending - Quick fix

---

### 14. Orders Management - UX Improvements 🟡

**File:** Orders screen  
**Test Cases:** 3.1, 3.6  
**Severity:** 🟡 High

**Issues & Requirements:**

1. **Pagination Missing** ⚠️

   - All orders loaded at once
   - Need limit 50 orders per page
   - Add "Load More" button or infinite scroll

2. **Date Filter Default**

   - Should default to "Today" on load
   - Currently shows all dates

3. **Status Badge Color** (Minor)

   - Pending orders show grey badge
   - Should be orange/yellow for visibility

4. **Redundant UI Elements**
   - Refresh button (pull-to-refresh already exists)
   - Back button (bottom nav handles navigation)
   - Remove these

**Files to Update:**

- `lib/features/admin/orders/presentation/providers/orders_provider.dart`
- `lib/features/admin/orders/presentation/screens/orders_screen.dart`
- `lib/features/admin/orders/presentation/widgets/order_status_badge.dart`

**Status:** 🟡 Pending - Medium priority

---

### 15. Reports - Hourly Breakdown for Today 🟠

**File:** Reports screen  
**Test Case:** 5.1  
**Severity:** 🟠 Medium

**Issue:**

- "Today" period should show hourly sales trend (00:00 - 23:00)
- Currently shows same daily format

**Expected Behavior:**

```
Period = Today → Chart shows 24 hours (0-23)
Period = Week/Month → Chart shows daily data
```

**Fix:**

```dart
if (filter.period == 'today') {
  // Group orders by hour
  // X-axis: 00:00, 01:00, ..., 23:00
} else {
  // Group by day
}
```

**Status:** 🟡 Pending - Nice to have

---

### 16. Reports - Low Text Contrast 🟠

**File:** Reports screen  
**Test Case:** 5.1  
**Severity:** 🟠 Medium

**Issue:**
Section headers hard to read:

- Sales Trend
- Top Products
- Category Performance
- Hourly Activity
- Payment Methods
- Stock Insights

**Fix:**

- Increase font weight (normal → bold)
- Or increase color contrast (grey → darker)

**Status:** 🟡 Pending - Accessibility fix

---

### 17. Inventory - Delete Product Feature Missing 🟠

**File:** Product detail screen  
**Test Case:** 4.5  
**Severity:** 🟠 Medium

**Issue:**

- No delete option in product detail
- User requested this feature

**Requirements:**

- Add delete button in product detail screen
- Confirmation dialog: "Delete this product? This action cannot be undone."
- Delete product from AppWrite
- Delete associated image from Storage
- Refresh product list

**Files to Update:**

- `lib/features/admin/inventory/presentation/screens/product_detail_screen.dart`
- Create delete provider/method

**Status:** 🟡 Pending - User requested

---

### 18. Inventory - Incomplete UI Features 🟢

**File:** Inventory screen  
**Severity:** 🟢 Low

**Issues:**

1. **Waste Logs Icon**

   - Icon exists, redirects to waste logs page
   - Need to verify page exists & functional

2. **Filter Icon**
   - Shows "Filter coming soon" notification
   - Either implement or remove icon

**Status:** 🟢 Low priority - Can defer

---

## 📊 UPDATED SUMMARY

| Priority    | Count  | Code Review | Testing Findings | Must Fix |
| ----------- | ------ | ----------- | ---------------- | -------- |
| 🔴 Critical | 4      | 2           | 2                | ✅ YES   |
| 🟡 High     | 7      | 4           | 3                | ✅ YES   |
| 🟠 Medium   | 6      | 3           | 3                | ⚠️ Rec   |
| 🟢 Low      | 2      | 1           | 1                | ❌ No    |
| **TOTAL**   | **19** | **10**      | **+9**           | **11**   |

---

## 🎯 REVISED FIX PLAN

### Phase 1: CRITICAL FIXES (MUST DO NOW) 🔴

**Estimated Time:** 1-2 hours

1. **Fix product images not displaying** (30-45 mins)
   - Investigation + AppWrite storage config
   - Image URL format fix
2. **Fix waste tracking error** (20-30 mins)
   - Update AppWrite schema OR
   - Implement code workaround

### Phase 2: HIGH PRIORITY 🟡

**Estimated Time:** 2-3 hours

3. **Fix category inconsistency** (5 mins)
4. **Add delete product feature** (30 mins)
5. **Orders pagination + date filter** (1 hour)
6. **Status badge color** (10 mins)
7. **Remove redundant buttons** (10 mins)
8. **Code review fixes** (memory leaks, validation) (1 hour)

### Phase 3: POLISH 🟠

**Estimated Time:** 1-2 hours

9. **Reports hourly breakdown** (30 mins)
10. **Text contrast improvements** (15 mins)
11. **Receipt code deduplication** (20 mins)
12. **Other code review items** (remaining)

---

## ✅ TESTING RESULTS

**Overall:** 30/35 test cases passed (86%)

### Passed ✅

- Authentication (2/2)
- POS & Cart (7/7)
- Orders Management (5/6)
- Inventory (2/5)
- Reports (2/2)
- Settings (3/3)
- UI/UX (2/3)

### Failed/Issues ❌

- Product image upload (4.3, 4.4)
- Stock waste tracking
- Delete product missing (4.5)
- Category inconsistency (4.3)
- Orders UX improvements needed (3.1, 3.6)

---

## ✅ COMPLETED FIXES

_(Will be updated as fixes are implemented)_

**None yet** - Starting fix phase

---

**Last Updated:** December 16, 2025 - After Manual Testing  
**Next Action:** Fix critical issues (Phase 1)
