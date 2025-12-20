# 🧪 Customer Side - Testing Checklist

**Project:** Coffee House POS - Customer App  
**Date:** December 19, 2025  
**Status:** Ready for Testing

---

## 📋 Pre-Testing Setup

### **Environment Check**

- [ ] Flutter SDK installed and updated
- [ ] Device/Emulator ready (Android/iOS)
- [ ] AppWrite backend running and accessible
- [ ] Test data seeded (products, categories, add-ons)
- [ ] Test account created (Google Sign-in or email)
- [ ] Internet connection stable
- [ ] Clear app data before testing

### **Build & Run**

```bash
cd coffee_house_pos
flutter clean
flutter pub get
flutter run
```

---

## 🔐 Authentication Flow

### **Login Screen**

- [ ] Google Sign-in button displays correctly
- [ ] Click Google Sign-in initiates auth flow
- [ ] Successfully authenticates with Google account
- [ ] Navigates to menu screen after login
- [ ] Error handling if auth fails
- [ ] Loading state shows during authentication

### **Session Management**

- [ ] User stays logged in after app restart
- [ ] Auto-login works with existing session
- [ ] Logout works correctly from profile screen
- [ ] Logout shows confirmation dialog
- [ ] After logout, navigates back to login

---

## 🏠 Menu Screen (Phase 1)

### **Initial Load**

- [ ] Menu screen loads successfully
- [ ] Products display in 2-column grid
- [ ] Product images load with placeholders
- [ ] Category badges show correct colors
- [ ] Product names display correctly
- [ ] Prices (M/L) show formatted (Rp X,XXX)
- [ ] Loading state: Shimmer grid appears
- [ ] Error state: Shows retry button if fails

### **AppBar**

- [ ] "Coffee House" title displays
- [ ] Profile icon (leading) displays
- [ ] Cart icon (trailing) displays
- [ ] Cart badge NOT shown (badge removed from implementation)

### **Search Functionality**

- [ ] Search bar displays correctly
- [ ] Typing filters products real-time
- [ ] Debounce works (300ms delay)
- [ ] Clear button (X) appears when typing
- [ ] Clear button clears search
- [ ] Empty state shows when no results
- [ ] Search is case-insensitive

### **Category Filtering**

- [ ] Category chips display (All/Coffee/Non-Coffee/Food/Dessert)
- [ ] Chips scroll horizontally if needed
- [ ] Selecting "All" shows all products
- [ ] Selecting "Coffee" shows only coffee
- [ ] Selecting "Non-Coffee" shows only non-coffee
- [ ] Selecting "Food" shows only food
- [ ] Selecting "Dessert" shows only desserts
- [ ] Selected chip has colorful highlight
- [ ] Chips animate on selection

### **Product Cards**

- [ ] Card displays image (or placeholder if no image)
- [ ] Category badge in top-right corner
- [ ] Category badge has correct color
- [ ] Product name is bold and readable
- [ ] Prices row shows M and L prices
- [ ] Quick add button (+) displays
- [ ] Tap card opens product detail modal
- [ ] Hero animation on image tap

### **Pull to Refresh**

- [ ] Pull down gesture works
- [ ] Refresh indicator appears
- [ ] Products reload from server
- [ ] Updated products display
- [ ] Works on Android and iOS

### **Empty States**

- [ ] No products: Shows empty icon and message
- [ ] No search results: Shows search empty state with query

### **Navigation**

- [ ] Bottom nav shows (Menu/Orders/Profile)
- [ ] Menu tab is selected (highlighted)
- [ ] Tapping other tabs navigates correctly

---

## 📦 Product Detail Modal (Phase 1)

### **Modal Open**

- [ ] Modal opens from product card tap
- [ ] Modal displays fullscreen (or bottom sheet)
- [ ] Hero animation on product image
- [ ] Close button (X) in top-right
- [ ] Modal has gradient overlay on image

### **Product Info**

- [ ] Product name displays (large, bold)
- [ ] Description displays correctly
- [ ] Category badge shows with correct color
- [ ] Image displays with gradient based on category

### **Size Selector**

- [ ] Size options (M/L) display as radio tiles
- [ ] Default size selected (M or first variant)
- [ ] Price updates when size changes
- [ ] Selected radio has colorful highlight
- [ ] Tap to select works smoothly

### **Add-ons Section**

- [ ] Add-ons grouped by category (Expansion tiles)
- [ ] Categories: Milk Type, Sugar Level, Extras, Ice Level
- [ ] Each category has colorful icon
- [ ] Expansion tiles expand/collapse
- [ ] Checkboxes for each add-on
- [ ] Additional price shown (+Rp X)
- [ ] Multiple add-ons can be selected
- [ ] Price updates when add-ons selected/deselected

### **Quantity Stepper**

- [ ] Minus button (-) displays
- [ ] Number displays in center
- [ ] Plus button (+) displays
- [ ] Default quantity is 1
- [ ] Plus increases quantity
- [ ] Minus decreases quantity
- [ ] Cannot go below 1 (minus disabled at 1)
- [ ] Quantity updates price calculation

### **Price Calculator**

- [ ] Shows "Total: Rp X,XXX"
- [ ] Updates when size changes
- [ ] Updates when add-ons change
- [ ] Updates when quantity changes
- [ ] Calculation is correct:
  - Base price = variant price + sum of addon prices
  - Total = base price × quantity
- [ ] Price formatted with thousand separators

### **Add to Cart Button**

- [ ] Button displays "Add to Cart"
- [ ] Button is full width
- [ ] Gradient background (category color)
- [ ] Icon (shopping cart) shows
- [ ] Click triggers add to cart
- [ ] Loading state shows during add
- [ ] Success feedback (icon changes to checkmark)
- [ ] Modal closes after adding
- [ ] Scale animation on button press

---

## 🛒 Cart Screen (Phase 2)

### **Navigation to Cart**

- [ ] Access from menu (via bottom nav)
- [ ] AppBar shows "My Cart"

### **Cart Items Display**

- [ ] Items display in list
- [ ] Each item shows:
  - [ ] Product image (small)
  - [ ] Product name
  - [ ] Category badge
  - [ ] Size (M/L)
  - [ ] Add-ons (as chips)
  - [ ] Quantity
  - [ ] Item total price
- [ ] Items are scrollable if many

### **Item Actions**

- [ ] Edit button displays
- [ ] Edit reopens product detail modal
- [ ] Modal pre-fills selections (size, add-ons, quantity)
- [ ] Editing updates item in cart
- [ ] Delete button displays
- [ ] Delete shows confirmation dialog
- [ ] Confirm delete removes item
- [ ] Cancel keeps item

### **Swipe to Delete**

- [ ] Swipe left on item
- [ ] Delete action appears
- [ ] Swipe completes deletion
- [ ] Confirmation dialog appears before delete

### **Price Breakdown Card**

- [ ] Shows "Subtotal"
- [ ] Shows "PPN 11%"
- [ ] Shows calculated tax amount
- [ ] Shows divider
- [ ] Shows "Total" (bold, large)
- [ ] All amounts formatted correctly
- [ ] Calculations are accurate:
  - Subtotal = sum of all item totals
  - Tax = subtotal × 0.11
  - Total = subtotal + tax

### **Checkout Button**

- [ ] Fixed at bottom of screen
- [ ] Full width button
- [ ] Gradient background
- [ ] Shows "Checkout" text
- [ ] Disabled if cart is empty
- [ ] Enabled if cart has items
- [ ] Click navigates to checkout screen
- [ ] Animation on press

### **Empty Cart**

- [ ] Shows empty cart icon (animated)
- [ ] Shows "Cart is Empty" title
- [ ] Shows descriptive message
- [ ] Shows "Browse Menu" button
- [ ] Button navigates to menu screen
- [ ] All elements animate on appear

### **Cart Persistence**

- [ ] Items persist after app close
- [ ] Items reload after app restart
- [ ] Cart survives device reboot (if Hive working)

---

## 💳 Checkout Screen (Phase 3)

### **Screen Load**

- [ ] Navigates from cart checkout button
- [ ] AppBar shows "Checkout"
- [ ] All sections display

### **Order Review Card**

- [ ] Shows item count summary
- [ ] Shows expandable item list
- [ ] Expand shows all items with details

### **Customer Info Card**

- [ ] TextField for name displays
- [ ] Label: "Your Name (Optional)"
- [ ] Helper text shows
- [ ] Can type name
- [ ] Can leave empty

### **Payment Method Card**

- [ ] Shows "Cash at Store"
- [ ] Money icon displays
- [ ] Info text: "Pay when you pick up"
- [ ] No other payment options (correct)

### **Order Summary Card**

- [ ] Shows subtotal
- [ ] Shows PPN 11%
- [ ] Shows divider
- [ ] Shows total (bold)
- [ ] Amounts match cart totals

### **Confirm Order Button**

- [ ] Fixed at bottom
- [ ] Full width
- [ ] Gradient background
- [ ] Shows "Confirm Order"
- [ ] Click creates order
- [ ] Loading state: spinner appears
- [ ] Success: navigates to tracking screen
- [ ] Error: shows error snackbar
- [ ] Error snackbar has retry option

### **Order Creation**

- [ ] Order number generated (YYYYMMDD-###)
- [ ] Order saved to AppWrite
- [ ] Order saved to Hive (offline)
- [ ] Cart cleared after order
- [ ] Navigate to tracking with order ID

### **Back Button Handling**

- [ ] Back button shows confirmation
- [ ] "Discard order?" dialog appears
- [ ] Confirm navigates back to cart
- [ ] Cancel stays on checkout

---

## 📍 Order Tracking Screen (Phase 3 & 4)

### **Screen Load**

- [ ] Receives order ID parameter
- [ ] Loads order from AppWrite
- [ ] Real-time subscription starts
- [ ] AppBar shows "Order Tracking"

### **Order Number Card**

- [ ] Shows order number (large)
- [ ] Format: #YYYYMMDD-###
- [ ] Copy button displays
- [ ] Copy button copies to clipboard
- [ ] Snackbar confirms copy

### **Status Stepper**

- [ ] Displays vertically
- [ ] Shows 4 steps:
  1. [ ] **Pending** (⏰ grey)
     - [ ] Icon: clock
     - [ ] Text: "Order Received"
     - [ ] Time: order created time
  2. [ ] **Preparing** (🍳 blue)
     - [ ] Icon: cooking/local_cafe
     - [ ] Text: "Being Prepared"
     - [ ] Estimated time shows
  3. [ ] **Ready** (✅ green)
     - [ ] Icon: check_circle
     - [ ] Text: "Ready for Pickup"
  4. [ ] **Completed** (✨ peach)
     - [ ] Icon: done_all
     - [ ] Text: "Completed"
- [ ] Current step highlighted
- [ ] Past steps filled/colored
- [ ] Future steps greyed out
- [ ] Status updates in real-time (no refresh needed)

### **Real-time Updates**

- [ ] Status changes reflect immediately
- [ ] No need to refresh manually
- [ ] Stepper updates automatically
- [ ] Times update when status changes

### **Order Details Card**

- [ ] Collapsible section
- [ ] Shows item list when expanded
- [ ] Shows total amount
- [ ] Each item shows details

### **Help Card**

- [ ] Shows "Need help?" text
- [ ] Shows contact info or placeholder
- [ ] Call button (optional) displays

### **Pull to Refresh**

- [ ] Pull down gesture works
- [ ] Refresh indicator appears
- [ ] Re-fetches order data
- [ ] Updates display

### **Loading State**

- [ ] Shimmer or spinner on initial load
- [ ] Smooth transition to content

### **Error Handling**

- [ ] Invalid order ID shows error
- [ ] Network error shows retry
- [ ] Error state has descriptive message

---

## 📜 Order History Screen (Phase 4)

### **Screen Load**

- [ ] Accessible from bottom nav (Orders tab)
- [ ] AppBar shows "My Orders"
- [ ] Orders load from AppWrite
- [ ] Loading state: Shimmer order list

### **Filter Chips**

- [ ] Chips display horizontally
- [ ] Options: All, Pending, Preparing, Ready, Completed
- [ ] Scroll horizontally if needed
- [ ] "All" selected by default
- [ ] Selecting filter updates list
- [ ] Selected chip highlighted with color
- [ ] Animation on selection

### **Search Bar**

- [ ] Search bar displays
- [ ] Can search by order number
- [ ] Real-time search filtering
- [ ] Clear button appears when typing
- [ ] Empty state if no results

### **Order List**

- [ ] Orders display in list
- [ ] Most recent orders first
- [ ] Each order card shows:
  - [ ] Order number (bold)
  - [ ] Status badge (colorful)
  - [ ] Date & time
  - [ ] Items count
  - [ ] Total amount
- [ ] Orders are scrollable

### **Order Card Interaction**

- [ ] Tap card navigates to order detail
- [ ] Passes order ID to detail screen
- [ ] Navigation is smooth

### **Empty States**

- [ ] No orders: Shows empty orders state
- [ ] Empty with "Order Now" button
- [ ] Button navigates to menu
- [ ] Filtered empty: Shows filter empty state
- [ ] Search empty: Shows search empty state

### **Pull to Refresh**

- [ ] Pull down refreshes orders
- [ ] Refresh indicator appears
- [ ] Updated orders display

### **Bottom Navigation**

- [ ] Bottom nav shows
- [ ] Orders tab is selected
- [ ] Other tabs clickable

---

## 📄 Order Detail Screen (Phase 4)

### **Screen Load**

- [ ] Receives order ID parameter
- [ ] Loads order from AppWrite
- [ ] AppBar shows "Order Details"
- [ ] Refresh button in AppBar

### **Digital Receipt View**

#### **Header Card**

- [ ] Store name displays ("Coffee House")
- [ ] Order number (large, bold)
- [ ] Date & time formatted correctly
- [ ] Status badge displays with color

#### **Customer Info Section**

- [ ] Shows if customer name provided
- [ ] Name displays correctly
- [ ] Section hidden if no name

#### **Items Table**

- [ ] Each item row shows:
  - [ ] Product name
  - [ ] Size (M/L) badge
  - [ ] Add-ons (colorful chips)
  - [ ] Quantity (Qty: X)
  - [ ] Item total price
- [ ] Items are well formatted
- [ ] Long names don't overflow

#### **Price Breakdown**

- [ ] Subtotal row
- [ ] PPN 11% row
- [ ] Divider
- [ ] Total (bold, highlighted card)
- [ ] All amounts formatted (Rp X,XXX)

#### **Payment Method**

- [ ] Shows "Cash at Store"
- [ ] Icon displays (money/payments)
- [ ] Styled in card

#### **Footer**

- [ ] Shows "Thank you for your order!"
- [ ] Nice typography

### **Action Buttons**

- [ ] "Track Order" button shows (if not completed)
- [ ] Button navigates to tracking screen
- [ ] "View All Orders" button shows
- [ ] Button navigates to order history

### **Loading State**

- [ ] Shimmer or spinner on load
- [ ] Smooth transition

### **Error Handling**

- [ ] Invalid order ID shows error
- [ ] Network error shows retry
- [ ] Retry button works

---

## 👤 Profile Screen (Phase 5)

### **Screen Load**

- [ ] Accessible from bottom nav (Profile tab)
- [ ] AppBar shows "Profile"
- [ ] Stats load from provider

### **User Info Card**

- [ ] CircleAvatar displays
- [ ] Gradient border (peach/mauve/teal)
- [ ] User name displays (from auth)
- [ ] User email displays
- [ ] Initial letter in avatar if no photo

### **Statistics Cards**

- [ ] 4 cards in 2×2 grid:
  1. [ ] **Total Orders** (Peach, receipt icon)
  2. [ ] **Total Spent** (Mauve, payments icon, Rp formatted)
  3. [ ] **Pending Orders** (Yellow, hourglass icon)
  4. [ ] **Completed Orders** (Green, check_circle icon)
- [ ] Each card shows:
  - [ ] Colorful icon
  - [ ] Value (number)
  - [ ] Label text
- [ ] Cards have correct colors
- [ ] Stats calculate correctly

### **Stats Calculation**

- [ ] Total orders = count of all user orders
- [ ] Total spent = sum of all order totals
- [ ] Pending = count of pending status orders
- [ ] Completed = count of completed status orders

### **Settings Section**

- [ ] Card with "Settings" header
- [ ] Theme ListTile:
  - [ ] Icon: brightness_6
  - [ ] Title: "Theme"
  - [ ] Subtitle: Current theme mode
  - [ ] Trailing: Switch
  - [ ] Switch toggles theme (Mocha ↔ Latte)
  - [ ] Theme changes immediately
  - [ ] App updates colors
- [ ] Notifications ListTile:
  - [ ] Icon: notifications
  - [ ] Title: "Notifications"
  - [ ] Trailing: Switch (disabled)
  - [ ] Shows "Coming soon" if tapped

### **About Section**

- [ ] Card with "About" header
- [ ] About App ListTile:
  - [ ] Icon: info
  - [ ] Title: "About App"
  - [ ] Shows dialog on tap
  - [ ] Dialog has app name, version, description
- [ ] Terms & Conditions ListTile:
  - [ ] Icon: description
  - [ ] Shows "Coming soon" snackbar
- [ ] Privacy Policy ListTile:
  - [ ] Icon: privacy_tip
  - [ ] Shows "Coming soon" snackbar

### **Logout Button**

- [ ] Red button at bottom
- [ ] Icon (logout) + text
- [ ] Full width
- [ ] Tap shows confirmation dialog
- [ ] Dialog: "Logout from your account?"
- [ ] Confirm logs out
- [ ] Cancel stays logged in
- [ ] After logout, navigates to login screen

### **Pull to Refresh**

- [ ] Pull down refreshes stats
- [ ] Stats reload from server
- [ ] Updated stats display

### **Loading State**

- [ ] Stats loading: Shimmer stat cards
- [ ] Smooth transition to content

---

## 🎨 Polish Features (Phase 7)

### **Shimmer Loading**

- [ ] Menu screen: Shimmer product grid
- [ ] Order history: Shimmer order list
- [ ] Profile: Shimmer stat cards
- [ ] Loading is smooth, not jarring
- [ ] Shimmer matches content structure

### **Hero Animations**

- [ ] Product image animates from card to detail
- [ ] Animation is smooth
- [ ] No flicker or jump
- [ ] Works on both Android and iOS

### **Empty States**

- [ ] All empty states use new widget
- [ ] Icons animate (scale & fade in)
- [ ] Text slides up
- [ ] Action buttons bounce in
- [ ] Colors match categories

### **Error States**

- [ ] All errors use ErrorStateWidget
- [ ] Error icon shakes
- [ ] Retry button animates
- [ ] Snackbars use helpers
- [ ] Success snackbars are green

### **Animated Buttons**

- [ ] Buttons scale down on press
- [ ] Shadow animates
- [ ] Loading state works
- [ ] Add to cart button shows success

### **Page Transitions**

- [ ] Navigation is smooth
- [ ] No abrupt changes
- [ ] Material transitions work

---

## 🌐 Offline Behavior

### **Cart Persistence**

- [ ] Cart saved to Hive
- [ ] Cart loads after app restart (offline)
- [ ] Items persist without network

### **Cached Data**

- [ ] Products cached in Hive
- [ ] Orders cached in Hive
- [ ] Images cached (CachedNetworkImage)
- [ ] Data loads from cache if offline

### **Network Errors**

- [ ] Shows network error state
- [ ] Retry button available
- [ ] Explains issue clearly

---

## 📱 Cross-Platform Testing

### **Android**

- [ ] All features work on Android
- [ ] Material design looks correct
- [ ] Back button behaves correctly
- [ ] Permissions work (storage, network)

### **iOS (if available)**

- [ ] All features work on iOS
- [ ] Material design adapts
- [ ] Gestures work (swipe back)
- [ ] Permissions work

---

## 🎯 Performance Testing

### **App Startup**

- [ ] App starts in < 3 seconds
- [ ] Splash screen shows (if any)
- [ ] No white screen flash

### **Scrolling**

- [ ] Product grid scrolls smoothly (60fps)
- [ ] Order list scrolls smoothly
- [ ] No stuttering or lag

### **Images**

- [ ] Images load progressively
- [ ] Placeholders show immediately
- [ ] No blank frames
- [ ] Cached images load instantly

### **Memory Usage**

- [ ] No memory leaks
- [ ] App doesn't crash after extended use
- [ ] Image cache doesn't grow too large

### **Network Performance**

- [ ] Works on slow network
- [ ] Timeout handled gracefully
- [ ] Loading states appropriate

---

## 🐛 Edge Cases

### **Cart Edge Cases**

- [ ] Adding same item twice (different configs) ✓
- [ ] Editing item after adding ✓
- [ ] Deleting all items shows empty state ✓
- [ ] Very large quantity (e.g., 50) ✓
- [ ] Many items in cart (scrolling) ✓

### **Search Edge Cases**

- [ ] Empty search shows all products ✓
- [ ] Special characters in search ✓
- [ ] Very long search query ✓
- [ ] Search with no results ✓

### **Order Edge Cases**

- [ ] Very long product names ✓
- [ ] Many add-ons selected ✓
- [ ] Order with 1 item ✓
- [ ] Order with 20+ items ✓
- [ ] Order number uniqueness ✓

### **Profile Edge Cases**

- [ ] User with 0 orders ✓
- [ ] User with 100+ orders ✓
- [ ] Very long user name ✓
- [ ] No email provided ✓

---

## ✅ Final Checks

### **Visual Polish**

- [ ] Colors consistent (Catppuccin)
- [ ] Text readable (good contrast)
- [ ] Spacing consistent (16-24px)
- [ ] Icons colorful and meaningful
- [ ] Shadows subtle (elevation 1-2)
- [ ] Rounded corners (12-20px)
- [ ] No visual bugs or glitches

### **Accessibility**

- [ ] Tap targets ≥ 48×48 dp
- [ ] Text size adjustable
- [ ] Color contrast sufficient
- [ ] Error messages clear and descriptive

### **Code Quality**

- [ ] No compiler warnings
- [ ] No runtime errors in console
- [ ] No memory leaks
- [ ] Code is clean and readable

### **Documentation**

- [ ] Implementation guide updated
- [ ] Polish features documented
- [ ] Testing checklist complete

---

## 🎉 Success Criteria

**Customer app is ready for production when:**

✅ **All Core Features Work:**

- Browse menu ✓
- Add to cart ✓
- Checkout ✓
- Track order ✓
- View history ✓
- View details ✓
- Manage profile ✓

✅ **UX is Polished:**

- Smooth animations ✓
- Good loading states ✓
- Clear error messages ✓
- Helpful empty states ✓
- Intuitive navigation ✓

✅ **Performance is Good:**

- Fast startup ✓
- Smooth scrolling ✓
- Quick image loading ✓
- Works offline ✓

✅ **No Critical Bugs:**

- No crashes ✓
- No data loss ✓
- No broken features ✓

---

## 📝 Bug Report Template

```markdown
### Bug Description

[What went wrong?]

### Steps to Reproduce

1. [Step 1]
2. [Step 2]
3. [Step 3]

### Expected Behavior

[What should happen?]

### Actual Behavior

[What actually happened?]

### Screenshots

[If applicable]

### Device Info

- Device: [e.g., Pixel 6]
- OS: [e.g., Android 13]
- App Version: [e.g., 1.0.0]

### Additional Context

[Any other relevant info]
```

---

**Testing Start Date:** ******\_\_\_******  
**Testing End Date:** ******\_\_\_******  
**Tested By:** ******\_\_\_******  
**Status:** ⏳ Pending / ✅ Passed / ❌ Failed

---

**Last Updated:** December 19, 2025  
**Version:** 1.0
