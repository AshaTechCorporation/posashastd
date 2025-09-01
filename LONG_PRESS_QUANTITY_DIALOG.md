# ✅ เพิ่มฟีเจอร์กดค้างสินค้าเพื่อใส่จำนวน

## ฟีเจอร์ที่เพิ่ม

**เมื่อกดค้างที่รายการสินค้าใน HomePage จะแสดง dialog ให้ใส่จำนวนสินค้าที่ต้องการเพิ่มลงตะกร้า**

## การทำงาน

### 🖱️ **การใช้งาน:**
- **กดปกติ** → เพิ่มสินค้า 1 ชิ้น
- **กดค้าง** → แสดง dialog ใส่จำนวน

### 📱 **Dialog ที่แสดง:**
- แสดงชื่อสินค้า
- ช่องใส่จำนวน (เลือกข้อความทั้งหมดอัตโนมัติ)
- ปุ่มยกเลิก / เพิ่ม

## ไฟล์ที่แก้ไข

### `lib/D2S/home/widgets/GridContentWidget.dart`

#### 1. เพิ่ม imports:
```dart
import 'package:flutter/services.dart';
import 'package:posashastd/models/product.dart';
```

#### 2. เพิ่ม onLongPress ใน GestureDetector:
```dart
return GestureDetector(
  onTap: () {
    homeController.addToCart(product);
  },
  onLongPress: () {
    // ✅ แสดง dialog สำหรับใส่จำนวนสินค้า
    _showQuantityDialog(product, homeController);
  },
  child: Container(
    // ... UI สินค้า
  ),
);
```

#### 3. เพิ่มฟังก์ชัน _showQuantityDialog:
```dart
void _showQuantityDialog(Product product, HomeController homeController) {
  final TextEditingController quantityController = TextEditingController(text: '1');

  Get.dialog(
    AlertDialog(
      title: Text('เพิ่มสินค้า', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แสดงชื่อสินค้า
          Text(
            product.name ?? 'ไม่มีชื่อ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 16),
          
          // ช่องใส่จำนวน
          Text('จำนวน:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'ใส่จำนวน',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            autofocus: true,
            onTap: () {
              // เลือกข้อความทั้งหมดเมื่อกดที่ TextField
              quantityController.selection = TextSelection(
                baseOffset: 0, 
                extentOffset: quantityController.text.length
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: () {
            final finalQuantity = int.tryParse(quantityController.text) ?? 1;
            if (finalQuantity > 0) {
              // เพิ่มสินค้าลงตะกร้าตามจำนวนที่ระบุ
              for (int i = 0; i < finalQuantity; i++) {
                homeController.addToCart(product);
              }
              Get.back();
              
              // แสดงข้อความยืนยัน
              Get.snackbar(
                'เพิ่มสินค้าสำเร็จ',
                'เพิ่ม ${product.name} จำนวน $finalQuantity ชิ้น',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: Duration(seconds: 2),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: Text('เพิ่ม', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
```

## ตัวอย่างการใช้งาน

### Scenario 1: เพิ่มสินค้า 1 ชิ้น
```
1. กดปกติที่สินค้า "ชาไทย"
2. เพิ่มลงตะกร้า 1 ชิ้น
3. ไม่มี dialog
```

### Scenario 2: เพิ่มสินค้าหลายชิ้น
```
1. กดค้างที่สินค้า "ชาไทย"
2. แสดง dialog:
   ┌─────────────────────┐
   │ เพิ่มสินค้า          │
   ├─────────────────────┤
   │ ชาไทย               │
   │                     │
   │ จำนวน:              │
   │ [    5    ]         │
   │                     │
   │ [ยกเลิก]  [เพิ่ม]    │
   └─────────────────────┘
3. ใส่จำนวน 5
4. กดปุ่ม "เพิ่ม"
5. เพิ่มลงตะกร้า 5 ชิ้น
6. แสดงข้อความ "เพิ่ม ชาไทย จำนวน 5 ชิ้น"
```

### Scenario 3: ยกเลิกการเพิ่ม
```
1. กดค้างที่สินค้า
2. แสดง dialog
3. กดปุ่ม "ยกเลิก"
4. ปิด dialog ไม่เพิ่มสินค้า
```

## คุณสมบัติของ Dialog

### 1. **การแสดงผล**
- ✅ แสดงชื่อสินค้าที่เลือก
- ✅ ช่องใส่จำนวนที่ชัดเจน
- ✅ ปุ่มยกเลิกและเพิ่ม

### 2. **การป้อนข้อมูล**
- ✅ รับเฉพาะตัวเลข (FilteringTextInputFormatter.digitsOnly)
- ✅ เลือกข้อความทั้งหมดเมื่อกดที่ช่อง
- ✅ เปิด keyboard ตัวเลขอัตโนมัติ
- ✅ Focus ที่ช่องใส่จำนวนทันที

### 3. **การตรวจสอบ**
- ✅ ตรวจสอบจำนวนต้องมากกว่า 0
- ✅ ใช้ค่าเริ่มต้น 1 ถ้าใส่ข้อมูลผิด
- ✅ ป้องกันการใส่ตัวอักษร

### 4. **การทำงาน**
- ✅ เพิ่มสินค้าลงตะกร้าตามจำนวนที่ระบุ
- ✅ แสดงข้อความยืนยันหลังเพิ่มสำเร็จ
- ✅ ปิด dialog อัตโนมัติหลังเพิ่ม

## การจัดการข้อผิดพลาด

### 1. **ใส่จำนวน 0 หรือติดลบ**
```dart
if (finalQuantity > 0) {
  // เพิ่มสินค้า
} else {
  // ไม่ทำอะไร (ไม่เพิ่มสินค้า)
}
```

### 2. **ใส่ข้อความที่ไม่ใช่ตัวเลข**
```dart
final finalQuantity = int.tryParse(quantityController.text) ?? 1;
// ถ้า parse ไม่ได้จะใช้ค่า 1
```

### 3. **ช่องว่าง**
```dart
// ถ้าไม่ใส่อะไรจะใช้ค่าเริ่มต้น 1
TextEditingController(text: '1')
```

## ข้อดีของฟีเจอร์

### 1. **ความสะดวก**
- ✅ เพิ่มสินค้าหลายชิ้นในครั้งเดียว
- ✅ ไม่ต้องกดหลายครั้ง
- ✅ ลดเวลาในการทำงาน

### 2. **ประสบการณ์ผู้ใช้**
- ✅ การใช้งานที่เป็นธรรมชาติ (long press)
- ✅ Dialog ที่เข้าใจง่าย
- ✅ ข้อความยืนยันที่ชัดเจน

### 3. **ความแม่นยำ**
- ✅ ระบุจำนวนที่ต้องการได้แม่นยำ
- ✅ ป้องกันการเพิ่มผิดจำนวน
- ✅ ตรวจสอบข้อมูลก่อนเพิ่ม

## การทดสอบ

### ทดสอบการทำงาน:
1. **กดปกติ** → เพิ่ม 1 ชิ้น
2. **กดค้าง** → แสดง dialog
3. **ใส่จำนวน 5** → เพิ่ม 5 ชิ้น
4. **ใส่จำนวน 0** → ไม่เพิ่ม
5. **กดยกเลิก** → ไม่เพิ่ม

### ทดสอบ UI:
1. **แสดงชื่อสินค้า** → ถูกต้อง
2. **เลือกข้อความ** → เลือกทั้งหมด
3. **Keyboard** → แสดงตัวเลข
4. **ข้อความยืนยัน** → แสดงชื่อและจำนวน

### ทดสอบ Edge Cases:
1. **ใส่ตัวอักษร** → ป้องกันได้
2. **ใส่จำนวนมาก** → ทำงานได้
3. **ช่องว่าง** → ใช้ค่าเริ่มต้น

## สรุป

✅ **ฟีเจอร์กดค้างเพื่อใส่จำนวนพร้อมใช้งาน**

### ฟีเจอร์หลัก:
- **กดค้างสินค้า → แสดง dialog**
- **ใส่จำนวนที่ต้องการ**
- **เพิ่มลงตะกร้าตามจำนวน**
- **แสดงข้อความยืนยัน**

### ประโยชน์:
- **เพิ่มสินค้าหลายชิ้นได้ง่าย**
- **ลดเวลาในการทำงาน**
- **ประสบการณ์ผู้ใช้ที่ดี**
- **ความแม่นยำสูง**

### การใช้งาน:
```
กดปกติ = เพิ่ม 1 ชิ้น
กดค้าง = เลือกจำนวน
```

**🎊 ตอนนี้สามารถกดค้างสินค้าเพื่อใส่จำนวนที่ต้องการได้แล้ว ทำให้การเพิ่มสินค้าหลายชิ้นสะดวกมากขึ้น!**
