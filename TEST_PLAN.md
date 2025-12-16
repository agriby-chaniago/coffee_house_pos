# 🧪 TEST PLAN - Bug Verification

**Date:** December 16, 2025  
**Purpose:** Verify all 14 resolved bugs are actually fixed  
**Focus:** Critical & High Priority issues only

---

## 🔴 CRITICAL BUGS (4 items)

### ✅ Bug #1: Memory Leak - Stream Not Disposed

**What was fixed:** Riverpod StreamProvider automatically handles disposal  
**Test Steps:**

1. [ ] Open app and navigate between screens 10+ times
2. [ ] Monitor memory usage (should remain stable)
3. [ ] Leave app running for 5+ minutes
4. [ ] Check battery usage (should be normal)

**Expected Result:** No memory increase, no crash

---

### ✅ Bug #2: Memory Leak - Image File Not Cleaned

**What was fixed:** Added file.delete() after upload in product forms  
**Test Steps:**

1. [ ] Go to Inventory → Add Product
2. [ ] Pick an image from gallery
3. [ ] Save product
4. [ ] Repeat 5 times with different products
5. [ ] Check device storage (temp files should be cleaned)

**Expected Result:** No temp files accumulate in storage

---

### ✅ Bug #5: Missing Input Validation

**What was fixed:** Added validators to all forms  
**Test Steps:**

**Product Form:**

1. [ ] Try to save product with empty name → Should show error
2. [ ] Try to save with negative price → Should show error
3. [ ] Try to save with empty category → Should show error
4. [ ] Enter valid data → Should save successfully

**Addon Form:**

1. [ ] Try to save addon with empty name → Should show error
2. [ ] Try to save with negative price → Should show error
3. [ ] Enter valid data → Should save successfully

**Stock Adjustment:**

1. [ ] Try to adjust with empty quantity → Should show error
2. [ ] Try to adjust with 0 or negative → Should show error
3. [ ] Enter valid quantity → Should save successfully

**Expected Result:** All validations work, no empty/invalid data saved

---

### ✅ Bug #6: Missing Numeric Validation

**What was fixed:** Added proper number validation and keyboard types  
**Test Steps:**

1. [ ] Go to Add Product → Price field
2. [ ] Keyboard should show numeric only
3. [ ] Try to type letters → Should not accept
4. [ ] Try to enter "abc" → Should show validation error
5. [ ] Enter "12.5" → Should accept
6. [ ] Same test for Stock and Quantity fields

**Expected Result:** Only numbers accepted, proper error messages

---

## 🟡 HIGH PRIORITY BUGS (7 items)

### ✅ Bug #8: Error Messages Not User-Friendly

**What was fixed:** Changed technical errors to friendly Indonesian messages  
**Test Steps:**

1. [ ] Turn off internet/WiFi
2. [ ] Try to save a product → Should show "Tidak ada koneksi internet"
3. [ ] Try invalid operation → Should show friendly message in Indonesian
4. [ ] No technical error codes should be visible

**Expected Result:** All errors in friendly Indonesian language

---

### ✅ Bug #9: Inconsistent Offline Handling

**What was fixed:** All write operations now queue when offline  
**Test Steps:**

**Order Creation:**

1. [ ] Turn off internet
2. [ ] Create an order at POS
3. [ ] Order should save locally (check "🟡 Belum sinkron" badge)
4. [ ] Turn on internet
5. [ ] Wait 30 seconds
6. [ ] Order should sync automatically (badge changes to "✅ Tersinkron")

**Product Creation:**

1. [ ] Turn off internet
2. [ ] Add new product
3. [ ] Should save with "queued for sync" message
4. [ ] Turn on internet
5. [ ] Product should sync automatically

**Stock Adjustment:**

1. [ ] Turn off internet
2. [ ] Adjust stock for a product
3. [ ] Should save locally
4. [ ] Turn on internet
5. [ ] Should sync automatically

**Expected Result:** All operations work offline and auto-sync

---

### ✅ Bug #11: Product Images Not Displaying

**What was fixed:** Corrected image URL generation with proper bucket ID  
**Test Steps:**

1. [ ] Go to Inventory → Products
2. [ ] All product images should display correctly
3. [ ] Go to POS screen
4. [ ] Product images in order list should display
5. [ ] Create an order and check receipt
6. [ ] No broken image placeholders

**Expected Result:** All images load properly everywhere

---

### ✅ Bug #12: Stock Adjustment - Waste Type Error (400)

**What was fixed:** Changed "Waste" to lowercase "waste" in enum  
**Test Steps:**

1. [ ] Go to Inventory → Stock Movements
2. [ ] Click "Waste" tab
3. [ ] Select a product
4. [ ] Enter quantity and reason
5. [ ] Click Save
6. [ ] Should save successfully (no 400 error)
7. [ ] Verify in Stock History

**Expected Result:** Waste adjustment saves without error

---

### ✅ Bug #14: Orders Management - UX Improvements

**What was fixed:** Added pull-to-refresh, better date picker, scroll to top  
**Test Steps:**

1. [ ] Go to Orders Management
2. [ ] Pull down to refresh → Should show loading indicator and refresh
3. [ ] Click date range → Should open calendar picker (not dropdown)
4. [ ] Select date range → Should filter orders
5. [ ] Scroll down, then click "scroll to top" button → Should jump to top
6. [ ] Filter by "paid" status → Should show only paid orders

**Expected Result:** All UX improvements work smoothly

---

### ✅ Bug #15: Reports - Hourly Breakdown

**What was fixed:** Added hourly sales breakdown for Today view  
**Test Steps:**

1. [ ] Go to Reports
2. [ ] Select date range = "Today"
3. [ ] Should show hourly breakdown chart
4. [ ] Chart should show sales by hour (00:00 - 23:00)
5. [ ] Select "This Week" → Should show daily breakdown
6. [ ] Select "This Month" → Should show daily breakdown

**Expected Result:** Hourly breakdown appears only for Today

---

### ✅ Bug #16: Reports - Text Contrast

**What was fixed:** Already verified - white text on colored background  
**Test Steps:**

1. [ ] Go to Reports → Summary Cards
2. [ ] Check "Total Revenue" card (blue) - text should be white
3. [ ] Check "Total Orders" card (green) - text should be white
4. [ ] Check "Average Order" card (orange) - text should be white
5. [ ] All text should be easily readable

**Expected Result:** High contrast, all text readable

---

### ✅ Bug #17: Inventory - Delete Product

**What was fixed:** Added delete confirmation dialog and functionality  
**Test Steps:**

1. [ ] Go to Inventory → Select a product
2. [ ] Click Delete button
3. [ ] Should show confirmation dialog with product name
4. [ ] Click "Cancel" → Should not delete
5. [ ] Click Delete again → Click "Delete" → Should delete product
6. [ ] Product should disappear from list
7. [ ] Check POS screen → Product should not appear

**Expected Result:** Delete works with confirmation

---

## 📝 TEST SUMMARY TEMPLATE

```
Date Tested: _______________
Tester: ___________________

CRITICAL BUGS (4):
[ ] Bug #1 - Memory Leak Stream     : PASS / FAIL
[ ] Bug #2 - Memory Leak Images     : PASS / FAIL
[ ] Bug #5 - Input Validation       : PASS / FAIL
[ ] Bug #6 - Numeric Validation     : PASS / FAIL

HIGH PRIORITY BUGS (7):
[ ] Bug #8  - Error Messages        : PASS / FAIL
[ ] Bug #9  - Offline Handling      : PASS / FAIL
[ ] Bug #11 - Product Images        : PASS / FAIL
[ ] Bug #12 - Waste Type Error      : PASS / FAIL
[ ] Bug #14 - Orders UX             : PASS / FAIL
[ ] Bug #15 - Hourly Reports        : PASS / FAIL
[ ] Bug #16 - Text Contrast         : PASS / FAIL
[ ] Bug #17 - Delete Product        : PASS / FAIL

TOTAL PASSED: _____ / 11
TOTAL FAILED: _____

Issues Found:
________________________________
________________________________
________________________________
```

---

## 🚀 QUICK TEST MODE

Untuk tes cepat (10-15 menit), fokus ke bug paling critical:

1. **Offline Mode Test** (Bug #9):

   - Turn off WiFi
   - Create order
   - Add product
   - Turn on WiFi
   - Verify auto-sync

2. **Validation Test** (Bug #5, #6):

   - Try to save empty forms
   - Try to enter invalid numbers
   - Should all show errors

3. **Image Test** (Bug #11):

   - Check product images everywhere
   - Should all display

4. **Waste Adjustment** (Bug #12):

   - Add waste entry
   - Should save without 400 error

5. **Delete Product** (Bug #17):
   - Delete a product
   - Should work with confirmation

If these 5 pass, app is production-ready! ✅
