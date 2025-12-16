# Seed Data untuk Coffee House POS

## Database Setup di AppWrite

### 1. Database Configuration

- Database ID: `coffee_house_db`
- Region: Singapore (SGP)

### 2. Collections yang Diperlukan

#### Collection: products

**Attributes:**

- `name` (string, required, 100 chars)
- `description` (string, required, 500 chars)
- `category` (string, required, enum: Coffee, Non-Coffee, Food, Dessert)
- `imageUrl` (string, optional, 500 chars)
- `variants` (JSON, required) - Array of {size: string, price: number}
- `availableAddOnIds` (string[], required) - Array of addon IDs
- `stockUnit` (string, required, enum: pcs, kg, liter, gram, ml)
- `currentStock` (double, required, min: 0)
- `minStock` (double, required, min: 0)
- `isActive` (boolean, required, default: true)
- `createdAt` (datetime, required)
- `updatedAt` (datetime, required)

**Indexes:**

- `category_idx` on category (asc)
- `isActive_idx` on isActive (asc)

#### Collection: addons

**Attributes:**

- `name` (string, required, 100 chars)
- `category` (string, required, enum: Milk, Syrup, Topping, Extra)
- `price` (double, required, min: 0)
- `isAvailable` (boolean, required, default: true)
- `createdAt` (datetime, required)
- `updatedAt` (datetime, required)

**Indexes:**

- `category_idx` on category (asc)
- `isAvailable_idx` on isAvailable (asc)

---

## Sample Data Products

### Coffee Products

#### 1. Americano

```json
{
  "name": "Americano",
  "description": "Espresso dengan air panas, rasa kopi yang kuat dan seimbang",
  "category": "Coffee",
  "imageUrl": "",
  "variants": [
    { "size": "M", "price": 18000 },
    { "size": "L", "price": 22000 }
  ],
  "availableAddOnIds": [
    "addon_milk_fresh",
    "addon_syrup_vanilla",
    "addon_syrup_hazelnut",
    "addon_extra_shot"
  ],
  "stockUnit": "ml",
  "currentStock": 5000,
  "minStock": 1000,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 2. Cappuccino

```json
{
  "name": "Cappuccino",
  "description": "Espresso dengan susu steamed dan foam lembut, perpaduan sempurna kopi dan susu",
  "category": "Coffee",
  "imageUrl": "",
  "variants": [
    { "size": "M", "price": 22000 },
    { "size": "L", "price": 26000 }
  ],
  "availableAddOnIds": [
    "addon_milk_oat",
    "addon_milk_almond",
    "addon_syrup_vanilla",
    "addon_syrup_caramel",
    "addon_topping_cinnamon",
    "addon_extra_shot"
  ],
  "stockUnit": "ml",
  "currentStock": 4500,
  "minStock": 1000,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 3. Caffe Latte

```json
{
  "name": "Caffe Latte",
  "description": "Espresso dengan susu steamed lebih banyak, rasa susu yang dominan dan lembut",
  "category": "Coffee",
  "imageUrl": "",
  "variants": [
    { "size": "M", "price": 24000 },
    { "size": "L", "price": 28000 }
  ],
  "availableAddOnIds": [
    "addon_milk_oat",
    "addon_milk_soy",
    "addon_syrup_vanilla",
    "addon_syrup_caramel",
    "addon_syrup_hazelnut",
    "addon_extra_shot"
  ],
  "stockUnit": "ml",
  "currentStock": 5000,
  "minStock": 1000,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 4. Mocha

```json
{
  "name": "Mocha",
  "description": "Espresso dengan coklat dan susu steamed, perpaduan kopi dan coklat yang sempurna",
  "category": "Coffee",
  "imageUrl": "",
  "variants": [
    { "size": "M", "price": 26000 },
    { "size": "L", "price": 30000 }
  ],
  "availableAddOnIds": [
    "addon_milk_oat",
    "addon_topping_whipped",
    "addon_topping_chocolate",
    "addon_extra_shot"
  ],
  "stockUnit": "ml",
  "currentStock": 4000,
  "minStock": 1000,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 5. Vietnam Drip

```json
{
  "name": "Vietnam Drip",
  "description": "Kopi Vietnam tradisional dengan susu kental manis, rasa manis dan kuat",
  "category": "Coffee",
  "imageUrl": "",
  "variants": [
    { "size": "M", "price": 20000 },
    { "size": "L", "price": 24000 }
  ],
  "availableAddOnIds": ["addon_extra_shot"],
  "stockUnit": "ml",
  "currentStock": 3000,
  "minStock": 500,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 6. Kopi Susu Gula Aren

```json
{
  "name": "Kopi Susu Gula Aren",
  "description": "Kopi susu dengan gula aren asli, manis alami dan gurih",
  "category": "Coffee",
  "imageUrl": "",
  "variants": [
    { "size": "M", "price": 22000 },
    { "size": "L", "price": 26000 }
  ],
  "availableAddOnIds": ["addon_milk_oat", "addon_topping_cheese_foam"],
  "stockUnit": "ml",
  "currentStock": 3500,
  "minStock": 800,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

### Non-Coffee Products

#### 7. Matcha Latte

```json
{
  "name": "Matcha Latte",
  "description": "Matcha premium dengan susu steamed, rasa teh hijau yang creamy",
  "category": "Non-Coffee",
  "imageUrl": "",
  "variants": [
    { "size": "M", "price": 26000 },
    { "size": "L", "price": 30000 }
  ],
  "availableAddOnIds": [
    "addon_milk_oat",
    "addon_milk_almond",
    "addon_syrup_vanilla",
    "addon_topping_whipped"
  ],
  "stockUnit": "gram",
  "currentStock": 500,
  "minStock": 100,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 8. Chocolate

```json
{
  "name": "Chocolate",
  "description": "Coklat premium dengan susu steamed, rasa coklat yang rich dan creamy",
  "category": "Non-Coffee",
  "imageUrl": "",
  "variants": [
    { "size": "M", "price": 24000 },
    { "size": "L", "price": 28000 }
  ],
  "availableAddOnIds": [
    "addon_milk_oat",
    "addon_topping_whipped",
    "addon_topping_marshmallow",
    "addon_topping_chocolate"
  ],
  "stockUnit": "gram",
  "currentStock": 800,
  "minStock": 200,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 9. Thai Tea

```json
{
  "name": "Thai Tea",
  "description": "Teh Thailand dengan susu, rasa manis dan creamy khas Thailand",
  "category": "Non-Coffee",
  "imageUrl": "",
  "variants": [
    { "size": "M", "price": 20000 },
    { "size": "L", "price": 24000 }
  ],
  "availableAddOnIds": ["addon_topping_boba", "addon_topping_jelly"],
  "stockUnit": "ml",
  "currentStock": 2000,
  "minStock": 500,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 10. Lemon Tea

```json
{
  "name": "Lemon Tea",
  "description": "Teh dengan lemon segar, rasa asam manis yang menyegarkan",
  "category": "Non-Coffee",
  "imageUrl": "",
  "variants": [
    { "size": "M", "price": 18000 },
    { "size": "L", "price": 22000 }
  ],
  "availableAddOnIds": ["addon_topping_jelly"],
  "stockUnit": "ml",
  "currentStock": 2500,
  "minStock": 500,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

### Food Products

#### 11. Croissant Original

```json
{
  "name": "Croissant Original",
  "description": "Croissant butter klasik yang renyah dan buttery",
  "category": "Food",
  "imageUrl": "",
  "variants": [{ "size": "M", "price": 18000 }],
  "availableAddOnIds": [],
  "stockUnit": "pcs",
  "currentStock": 30,
  "minStock": 10,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 12. Croissant Almond

```json
{
  "name": "Croissant Almond",
  "description": "Croissant dengan krim almond dan taburan almond slice",
  "category": "Food",
  "imageUrl": "",
  "variants": [{ "size": "M", "price": 22000 }],
  "availableAddOnIds": [],
  "stockUnit": "pcs",
  "currentStock": 25,
  "minStock": 10,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 13. Sandwich Tuna

```json
{
  "name": "Sandwich Tuna",
  "description": "Sandwich dengan tuna mayo, sayuran segar, dan roti gandum",
  "category": "Food",
  "imageUrl": "",
  "variants": [{ "size": "M", "price": 28000 }],
  "availableAddOnIds": [],
  "stockUnit": "pcs",
  "currentStock": 20,
  "minStock": 5,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 14. Sandwich Chicken

```json
{
  "name": "Sandwich Chicken",
  "description": "Sandwich dengan ayam panggang, keju, dan sayuran segar",
  "category": "Food",
  "imageUrl": "",
  "variants": [{ "size": "M", "price": 30000 }],
  "availableAddOnIds": [],
  "stockUnit": "pcs",
  "currentStock": 18,
  "minStock": 5,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

### Dessert Products

#### 15. French Fries

```json
{
  "name": "French Fries",
  "description": "Kentang goreng crispy dengan pilihan saus",
  "category": "Dessert",
  "imageUrl": "",
  "variants": [
    { "size": "M", "price": 15000 },
    { "size": "L", "price": 20000 }
  ],
  "availableAddOnIds": [],
  "stockUnit": "gram",
  "currentStock": 2000,
  "minStock": 500,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 16. Cookies Chocolate Chip

```json
{
  "name": "Cookies Chocolate Chip",
  "description": "Cookies lembut dengan chocolate chip melimpah",
  "category": "Dessert",
  "imageUrl": "",
  "variants": [{ "size": "M", "price": 12000 }],
  "availableAddOnIds": [],
  "stockUnit": "pcs",
  "currentStock": 40,
  "minStock": 15,
  "isActive": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

---

## Sample Data Add-Ons

### Milk Category

#### 1. Fresh Milk (ID: addon_milk_fresh)

```json
{
  "name": "Fresh Milk",
  "category": "Milk",
  "price": 5000,
  "isAvailable": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 2. Oat Milk (ID: addon_milk_oat)

```json
{
  "name": "Oat Milk",
  "category": "Milk",
  "price": 8000,
  "isAvailable": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 3. Almond Milk (ID: addon_milk_almond)

```json
{
  "name": "Almond Milk",
  "category": "Milk",
  "price": 8000,
  "isAvailable": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 4. Soy Milk (ID: addon_milk_soy)

```json
{
  "name": "Soy Milk",
  "category": "Milk",
  "price": 6000,
  "isAvailable": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

### Syrup Category

#### 5. Vanilla Syrup (ID: addon_syrup_vanilla)

```json
{
  "name": "Vanilla Syrup",
  "category": "Syrup",
  "price": 5000,
  "isAvailable": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 6. Caramel Syrup (ID: addon_syrup_caramel)

```json
{
  "name": "Caramel Syrup",
  "category": "Syrup",
  "price": 5000,
  "isAvailable": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 7. Hazelnut Syrup (ID: addon_syrup_hazelnut)

```json
{
  "name": "Hazelnut Syrup",
  "category": "Syrup",
  "price": 5000,
  "isAvailable": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

### Topping Category

#### 8. Whipped Cream (ID: addon_topping_whipped)

```json
{
  "name": "Whipped Cream",
  "category": "Topping",
  "price": 7000,
  "isAvailable": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 9. Chocolate Drizzle (ID: addon_topping_chocolate)

```json
{
  "name": "Chocolate Drizzle",
  "category": "Topping",
  "price": 5000,
  "isAvailable": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 10. Cinnamon Powder (ID: addon_topping_cinnamon)

```json
{
  "name": "Cinnamon Powder",
  "category": "Topping",
  "price": 3000,
  "isAvailable": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 11. Cheese Foam (ID: addon_topping_cheese_foam)

```json
{
  "name": "Cheese Foam",
  "category": "Topping",
  "price": 10000,
  "isAvailable": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 12. Marshmallow (ID: addon_topping_marshmallow)

```json
{
  "name": "Marshmallow",
  "category": "Topping",
  "price": 5000,
  "isAvailable": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 13. Boba Pearls (ID: addon_topping_boba)

```json
{
  "name": "Boba Pearls",
  "category": "Topping",
  "price": 6000,
  "isAvailable": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

#### 14. Jelly (ID: addon_topping_jelly)

```json
{
  "name": "Jelly",
  "category": "Topping",
  "price": 5000,
  "isAvailable": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

### Extra Category

#### 15. Extra Shot Espresso (ID: addon_extra_shot)

```json
{
  "name": "Extra Shot Espresso",
  "category": "Extra",
  "price": 8000,
  "isAvailable": true,
  "createdAt": "2025-11-21T10:00:00.000Z",
  "updatedAt": "2025-11-21T10:00:00.000Z"
}
```

---

## Cara Input Data ke AppWrite

### Via AppWrite Console (Web):

1. **Login ke AppWrite Console**: https://cloud.appwrite.io
2. **Pilih Project**: coffee_house_pos
3. **Buat Database**:

   - Klik "Databases" di sidebar
   - Create Database dengan ID: `coffee_house_db`

4. **Buat Collection "addons"**:

   - Klik database yang baru dibuat
   - Create Collection dengan ID: `addons`
   - Tambahkan attributes sesuai spec di atas
   - **PENTING**: Input addons DULU karena products referensi ke addon IDs

5. **Input Data Addons**:

   - Klik collection "addons"
   - Create Document
   - Salin JSON data dari seed data di atas (15 addons)
   - **CATAT Document ID** yang di-generate AppWrite untuk setiap addon
   - Ganti `availableAddOnIds` di products dengan Document ID yang sebenarnya

6. **Buat Collection "products"**:

   - Create Collection dengan ID: `products`
   - Tambahkan attributes sesuai spec di atas
   - Pastikan `variants` dan `availableAddOnIds` bertipe JSON/Array

7. **Input Data Products**:
   - Klik collection "products"
   - Create Document
   - Salin JSON data dari seed data (16 products)
   - **Update `availableAddOnIds`** dengan Document ID addon yang sebenarnya

### Mapping Addon IDs:

Setelah membuat addons di AppWrite, catat mapping seperti ini:

```
addon_milk_fresh → 67xxx (AppWrite generated ID)
addon_milk_oat → 67yyy
addon_syrup_vanilla → 67zzz
... dst
```

Lalu update field `availableAddOnIds` di setiap product dengan ID yang sebenarnya.

---

## Tips

1. **Input Addons Dulu**: Karena products referensi ke addon IDs
2. **Gunakan Custom ID**: Di AppWrite, Anda bisa set custom Document ID (misal: `addon_milk_fresh`) saat create document agar tidak perlu mapping manual
3. **Batch Import**: Gunakan AppWrite CLI untuk import JSON batch jika data banyak
4. **Test Data**: Setelah input, test fetch di Flutter app untuk pastikan data muncul
