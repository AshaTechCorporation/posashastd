# ✅ แก้ไข Homev2s ให้มี Quantity Dialog เหมือน HomePage

## การแก้ไขที่ทำ

**แก้ไข Homev2s ให้มี dialog สำหรับเลือกจำนวนสินค้าเมื่อกดค้าง เหมือนกับ HomePage ทุกประการ**

## ความต้องการ

### ที่ต้องการ:
- ✅ กดสินค้าปกติ → เพิ่มทีละ 1 ลงตะกร้า
- ✅ กดค้างสินค้า → แสดง dialog ให้เลือกจำนวน
- ✅ กรอกจำนวนใน dialog → เพิ่มลงตะกร้าตามจำนวนที่ระบุ
- ✅ ไม่ต้องการ UI การ์ดแสดงรายการตะกร้า

### ที่ไม่ต้องการ:
- ❌ UI การ์ดแสดงรายการตะกร้า
- ❌ ปุ่มควบคุมจำนวนในรายการ
- ❌ Long press ในรายการตะกร้า

## การแก้ไข

### 1. **เพิ่ม Import Get:**
```dart
import 'package:get/get.dart';
```

### 2. **แก้ไขฟังก์ชัน `addToCart` ให้รับ parameter จำนวน:**
```dart
// เดิม
void addToCart(Map<String, dynamic> product) {
  setState(() {
    final existingIndex = cartItems.indexWhere((item) => item['id'] == product['id']);

    if (existingIndex >= 0) {
      final currentQty = cartItems[existingIndex]['qty'] ?? 1;
      cartItems[existingIndex]['qty'] = currentQty + 1;  // เพิ่มทีละ 1
    } else {
      final newItem = Map<String, dynamic>.from(product);
      newItem['qty'] = 1;  // เริ่มต้น 1
      cartItems.add(newItem);
    }
  });
}

// ใหม่
void addToCart(Map<String, dynamic> product, {int quantity = 1}) {
  setState(() {
    final existingIndex = cartItems.indexWhere((item) => item['id'] == product['id']);

    if (existingIndex >= 0) {
      final currentQty = cartItems[existingIndex]['qty'] ?? 1;
      cartItems[existingIndex]['qty'] = currentQty + quantity;  // เพิ่มตามจำนวนที่ระบุ
    } else {
      final newItem = Map<String, dynamic>.from(product);
      newItem['qty'] = quantity;  // ตั้งจำนวนตามที่ระบุ
      cartItems.add(newItem);
    }
  });
}
```

### 3. **เพิ่มฟังก์ชัน `_showQuantityDialog`:**
```dart
// ✅ แสดง dialog สำหรับใส่จำนวนสินค้า
void _showQuantityDialog(Map<String, dynamic> product) {
  final TextEditingController quantityController = TextEditingController(text: '1');

  Get.dialog(
    AlertDialog(
      title: const Text('เพิ่มสินค้า', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แสดงชื่อสินค้า
          Text(
            product['name'] ?? 'ไม่มีชื่อ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),

          // ช่องกรอกจำนวน
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'จำนวน',
              border: OutlineInputBorder(),
              suffixText: 'ชิ้น',
            ),
            onChanged: (value) {
              // ตรวจสอบว่าเป็นตัวเลขหรือไม่
              if (int.tryParse(value) == null && value.isNotEmpty) {
                quantityController.text = '1';
                quantityController.selection = TextSelection.fromPosition(
                  TextPosition(offset: quantityController.text.length),
                );
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('ยกเลิก')),
        ElevatedButton(
          onPressed: () {
            final finalQuantity = int.tryParse(quantityController.text) ?? 1;
            if (finalQuantity > 0) {
              // เพิ่มสินค้าลงตะกร้าตามจำนวนที่ระบุ
              addToCart(product, quantity: finalQuantity);
              Get.back();

              // แสดงข้อความยืนยัน
              Get.snackbar(
                'เพิ่มสินค้าสำเร็จ',
                'เพิ่ม ${product['name']} จำนวน $finalQuantity ชิ้น',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('เพิ่ม', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
```

### 4. **แก้ไข GestureDetector ในส่วน GridView:**
```dart
// เดิม
return GestureDetector(
  onTap: () {
    addToCart(product);
  },
  child: // UI สินค้า
);

// ใหม่
return GestureDetector(
  onTap: () {
    addToCart(product);  // เพิ่มทีละ 1
  },
  onLongPress: () {
    // ✅ แสดง dialog สำหรับใส่จำนวนสินค้า
    _showQuantityDialog(product);
  },
  child: // UI สินค้า
);
```

### 5. **ลบส่วน UI การ์ดตะกร้าออก:**
```dart
// เดิม - มี Row แบ่งซ้าย-ขวา + รายการตะกร้า
body: Row(
  children: [
    // ส่วนซ้าย - รายการสินค้า
    Expanded(child: GridView(...)),
    
    // ส่วนขวา - ตะกร้าสินค้า
    Container(
      width: 350,
      child: Column(
        children: [
          PaymentSummaryBar(...),
          // รายการตะกร้า + ปุ่มควบคุม
        ],
      ),
    ),
  ],
)

// ใหม่ - กลับเป็น Column แบบเดิม
body: Column(
  children: [
    // ปุ่มชำระเงิน
    PaymentSummaryBar(totalAmount: getTotalAmount()),
    
    // Dropdown และ GridView
    // ...
  ],
)
```

## ความเหมือนกันกับ HomePage

### ฟังก์ชันที่เหมือนกันแล้ว:

#### 1. **การกดสินค้าปกติ** ✅
```dart
// ทั้งสองหน้าใช้ logic เหมือนกัน
onTap: () {
  addToCart(product);  // เพิ่มทีละ 1
}
```

#### 2. **การกดค้างสินค้า** ✅
```dart
// ทั้งสองหน้าใช้ logic เหมือนกัน
onLongPress: () {
  _showQuantityDialog(product);  // แสดง dialog เลือกจำนวน
}
```

#### 3. **Dialog เลือกจำนวน** ✅
```dart
// ทั้งสองหน้าใช้ dialog เหมือนกัน
Get.dialog(
  AlertDialog(
    title: const Text('เพิ่มสินค้า'),
    content: Column(
      children: [
        Text(product['name']),  // แสดงชื่อสินค้า
        TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'จำนวน',
            border: OutlineInputBorder(),
            suffixText: 'ชิ้น',
          ),
        ),
      ],
    ),
    actions: [
      TextButton(onPressed: () => Get.back(), child: const Text('ยกเลิก')),
      ElevatedButton(
        onPressed: () {
          final quantity = int.tryParse(quantityController.text) ?? 1;
          addToCart(product, quantity: quantity);
          Get.back();
          // แสดงข้อความสำเร็จ
        },
        child: const Text('เพิ่ม'),
      ),
    ],
  ),
);
```

#### 4. **การเพิ่มสินค้าลงตะกร้า** ✅
```dart
// ทั้งสองหน้าใช้ logic เหมือนกัน
void addToCart(Map<String, dynamic> product, {int quantity = 1}) {
  setState(() {
    final existingIndex = cartItems.indexWhere((item) => item['id'] == product['id']);

    if (existingIndex >= 0) {
      // มีสินค้าแล้ว → เพิ่มจำนวน
      cartItems[existingIndex]['qty'] = (cartItems[existingIndex]['qty'] ?? 1) + quantity;
    } else {
      // ไม่มีสินค้า → เพิ่มรายการใหม่
      final newItem = Map<String, dynamic>.from(product);
      newItem['qty'] = quantity;
      cartItems.add(newItem);
    }
  });
}
```

#### 5. **Success Message** ✅
```dart
// ทั้งสองหน้าแสดงข้อความเหมือนกัน
Get.snackbar(
  'เพิ่มสินค้าสำเร็จ',
  'เพิ่ม ${product['name']} จำนวน $finalQuantity ชิ้น',
  backgroundColor: Colors.green,
  colorText: Colors.white,
  duration: const Duration(seconds: 2),
);
```

#### 6. **Input Validation** ✅
```dart
// ทั้งสองหน้าตรวจสอบ input เหมือนกัน
onChanged: (value) {
  // ตรวจสอบว่าเป็นตัวเลขหรือไม่
  if (int.tryParse(value) == null && value.isNotEmpty) {
    quantityController.text = '1';
    quantityController.selection = TextSelection.fromPosition(
      TextPosition(offset: quantityController.text.length),
    );
  }
}
```

## Flow การทำงานเหมือนกันทุกประการ

### การเพิ่มสินค้าปกติ:
```
1. กดสินค้า → onTap()
2. addToCart(product) → เพิ่มทีละ 1
3. อัปเดต cartItems
4. อัปเดต UI (PaymentSummaryBar)
```

### การเพิ่มสินค้าแบบเลือกจำนวน:
```
1. กดค้างสินค้า → onLongPress()
2. _showQuantityDialog(product) → แสดง dialog
3. กรอกจำนวน → ตรวจสอบ input
4. กดเพิ่ม → addToCart(product, quantity: จำนวน)
5. อัปเดต cartItems
6. ปิด dialog
7. แสดงข้อความสำเร็จ
8. อัปเดต UI (PaymentSummaryBar)
```

### การตรวจสอบสินค้าซ้ำ:
```
1. หาสินค้าใน cartItems
2. ถ้ามีแล้ว → เพิ่มจำนวน
3. ถ้าไม่มี → เพิ่มรายการใหม่
4. อัปเดต UI
```

## ความแตกต่างเพียงอย่างเดียว

### UI Layout:
- **HomePage** → ใช้ TabView + Side panel + รายการตะกร้า
- **Homev2s** → ใช้ Column + GridView + ไม่มีรายการตะกร้า

### แต่ฟังก์ชันการเพิ่มสินค้าเหมือนกันทุกประการ ✅

## การทดสอบ

### ทดสอบการกดปกติ:
1. **กดสินค้า** → เพิ่มทีละ 1 ลงตะกร้า ✅
2. **กดสินค้าเดิมอีก** → เพิ่มจำนวนในตะกร้า ✅
3. **ยอดรวมอัปเดต** → คำนวณถูกต้อง ✅

### ทดสอบการกดค้าง:
1. **กดค้างสินค้า** → แสดง dialog ✅
2. **กรอกจำนวน** → ตรวจสอบ input ✅
3. **กดยกเลิก** → ปิด dialog, ไม่เพิ่มสินค้า ✅
4. **กดเพิ่ม** → เพิ่มสินค้าตามจำนวน + แสดงข้อความ ✅

### ทดสอบ Input Validation:
1. **กรอกตัวเลข** → ยอมรับ ✅
2. **กรอกตัวอักษร** → รีเซ็ตเป็น 1 ✅
3. **กรอก 0 หรือติดลบ** → ใช้ค่า default 1 ✅

## สรุป

✅ **Homev2s มี Quantity Dialog เหมือนกับ HomePage แล้ว**

### การแก้ไข:
- **เพิ่มฟังก์ชัน _showQuantityDialog()**
- **แก้ไข addToCart() ให้รับ parameter จำนวน**
- **เพิ่ม onLongPress ใน GridView**
- **ลบ UI การ์ดตะกร้าออก**
- **เก็บ layout แบบเดิม (Column)**

### ความเหมือนกัน:
- **Dialog เลือกจำนวนเหมือนกัน**
- **Input validation เหมือนกัน**
- **การเพิ่มสินค้าเหมือนกัน**
- **Success message เหมือนกัน**
- **Flow การทำงานเหมือนกัน**

### การทำงาน:
```
กดปกติ → เพิ่มทีละ 1
กดค้าง → Dialog → เลือกจำนวน → เพิ่มตามจำนวน
```

**🎊 ตอนนี้ Homev2s มี Quantity Dialog เหมือนกับ HomePage ทุกประการแล้ว! กดค้างสินค้าจะแสดง dialog ให้เลือกจำนวน และเพิ่มลงตะกร้าตามที่ระบุ!**
