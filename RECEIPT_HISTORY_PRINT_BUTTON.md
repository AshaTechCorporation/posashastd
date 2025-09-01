# ✅ เพิ่มปุ่มปริ๊นในหน้า Receipt History

## ฟีเจอร์ที่เพิ่ม

**เพิ่มปุ่มสำหรับสั่งปริ๊นแทนไอคอน more_vert ในหน้า receiptHistoryPage โดยการปริ๊นมีการทำงานเหมือนกับหน้า PaymentPageD2s และใช้ข้อมูลจาก Order**

## การเปลี่ยนแปลง

### ก่อนแก้ไข:
```
[#12345] [สำเร็จ] [⋮]
```

### หลังแก้ไข:
```
[#12345] [สำเร็จ] [🖨️ ปริ๊น]
```

## ไฟล์ที่แก้ไข

### `lib/D2S/receipt/receiptHistoryPage.dart`

#### 1. เพิ่ม imports:
```dart
import 'package:posashastd/D2S/controllers/printer_controller.dart';
import 'package:posashastd/helpers/printReceiptFromCartItems.dart';
```

#### 2. แก้ไขปุ่มจากไอคอน more_vert เป็นปุ่มปริ๊น:
```dart
// ก่อนแก้ไข
const Icon(Icons.more_vert, color: Colors.white),

// หลังแก้ไข
GestureDetector(
  onTap: () => _printOrderReceipt(selectedOrder!),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.print, color: Colors.white, size: 18),
        SizedBox(width: 4),
        Text('ปริ๊น', style: TextStyle(color: Colors.white, fontSize: 14)),
      ],
    ),
  ),
),
```

#### 3. เพิ่มฟังก์ชัน _printOrderReceipt:
```dart
Future<void> _printOrderReceipt(Order order) async {
  try {
    log('🖨️ Starting to print receipt for order: ${order.orderNo}');

    // แปลงข้อมูล OrderItems เป็น cartItems format
    final cartItems = <Map<String, dynamic>>[];
    
    if (order.orderItems != null) {
      for (final orderItem in order.orderItems!) {
        cartItems.add({
          'id': orderItem.product?.id ?? 0,
          'name': orderItem.product?.name ?? 'ไม่มีชื่อ',
          'price': (orderItem.price ?? 0) / 100.0, // แปลงจาก satang เป็น baht
          'qty': orderItem.quantity ?? 1,
        });
      }
    }

    // คำนวณข้อมูลการชำระเงิน
    final grandTotal = (order.grandTotal ?? 0) / 100.0;
    final paid = (order.paid ?? 0) / 100.0;
    final change = (order.change ?? 0) / 100.0;
    final discount = (order.discount ?? 0) / 100.0;

    // ข้อมูลพนักงาน
    final staffName = order.shift?.user?.firstName ?? 'พนักงาน';

    // เรียกใช้ฟังก์ชันปริ๊นเดียวกับ PaymentPageD2s
    await printReceiptFromCartItems(
      cartItems,
      receivedAmount: paid,
      changeAmount: change,
      discountAmount: discount > 0 ? discount : null,
      paymentMethod: 'เงินสด',
      staffName: staffName,
      receiptNumber: order.orderNo,
    );

    // แสดงข้อความยืนยัน
    Get.snackbar(
      'ปริ๊นสำเร็จ',
      'ปริ๊นใบเสร็จ ${order.orderNo} เรียบร้อยแล้ว',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

  } catch (e) {
    // แสดงข้อความข้อผิดพลาด
    Get.snackbar(
      'เกิดข้อผิดพลาด',
      'ไม่สามารถปริ๊นใบเสร็จได้: $e',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
```

## การทำงานของฟังก์ชันปริ๊น

### 1. **แปลงข้อมูล OrderItems เป็น cartItems:**
```dart
// จาก Order.orderItems (OrderItems[])
// เป็น cartItems (Map<String, dynamic>[])
{
  'id': orderItem.product?.id ?? 0,
  'name': orderItem.product?.name ?? 'ไม่มีชื่อ',
  'price': (orderItem.price ?? 0) / 100.0, // satang → baht
  'qty': orderItem.quantity ?? 1,
}
```

### 2. **แปลงข้อมูลการชำระเงิน:**
```dart
// แปลงจาก satang เป็น baht (หาร 100)
final grandTotal = (order.grandTotal ?? 0) / 100.0;
final paid = (order.paid ?? 0) / 100.0;
final change = (order.change ?? 0) / 100.0;
final discount = (order.discount ?? 0) / 100.0;
```

### 3. **ใช้ฟังก์ชันปริ๊นเดียวกับ PaymentPageD2s:**
```dart
await printReceiptFromCartItems(
  cartItems,                                    // รายการสินค้า
  receivedAmount: paid,                         // จำนวนเงินที่รับ
  changeAmount: change,                         // เงินทอน
  discountAmount: discount > 0 ? discount : null, // ส่วนลด
  paymentMethod: 'เงินสด',                      // วิธีการชำระ
  staffName: staffName,                         // ชื่อพนักงาน
  receiptNumber: order.orderNo,                 // เลขที่ใบเสร็จ
);
```

## ตัวอย่างการใช้งาน

### Scenario 1: ปริ๊นใบเสร็จสำเร็จ
```
1. เลือก order ในรายการ
2. กดปุ่ม "ปริ๊น"
3. ระบบแปลงข้อมูล order เป็น cartItems
4. เรียกใช้ฟังก์ชันปริ๊น
5. ปริ๊นใบเสร็จออกมา
6. แสดงข้อความ "ปริ๊นใบเสร็จ #12345 เรียบร้อยแล้ว"
```

### Scenario 2: เกิดข้อผิดพลาดในการปริ๊น
```
1. เลือก order ในรายการ
2. กดปุ่ม "ปริ๊น"
3. เกิดข้อผิดพลาด (เช่น ปริ๊นเตอร์ไม่เชื่อมต่อ)
4. แสดงข้อความ "ไม่สามารถปริ๊นใบเสร็จได้: [รายละเอียดข้อผิดพลาด]"
```

## การจัดการข้อมูล

### 1. **Order Model Structure:**
```dart
class Order {
  String? orderNo;           // เลขที่ใบเสร็จ
  int? grandTotal;          // ยอดรวม (satang)
  int? paid;                // จำนวนที่จ่าย (satang)
  int? change;              // เงินทอน (satang)
  int? discount;            // ส่วนลด (satang)
  List<OrderItems>? orderItems; // รายการสินค้า
  Shift? shift;             // ข้อมูลกะ (มีข้อมูลพนักงาน)
}
```

### 2. **OrderItems Structure:**
```dart
class OrderItems {
  int? quantity;            // จำนวน
  int? price;               // ราคาต่อหน่วย (satang)
  Product? product;         // ข้อมูลสินค้า
}
```

### 3. **การแปลงหน่วยเงิน:**
```dart
// API ส่งมาเป็น satang (1 บาท = 100 satang)
// ต้องแปลงเป็น baht สำหรับการปริ๊น
final baht = satang / 100.0;
```

## ข้อดีของการใช้ฟังก์ชันเดียวกัน

### 1. **ความสอดคล้อง**
- ✅ ใบเสร็จมีรูปแบบเดียวกัน
- ✅ ไม่ต้องเขียนโค้ดซ้ำ
- ✅ การแก้ไขทำที่เดียวได้ผลทุกที่

### 2. **การดูแลรักษา**
- ✅ โค้ดเข้าใจง่าย
- ✅ ลดจุดที่อาจเกิดข้อผิดพลาด
- ✅ การอัปเดตง่าย

### 3. **ความถูกต้อง**
- ✅ ใช้ข้อมูลจาก Order จริง
- ✅ แสดงข้อมูลที่ถูกต้อง
- ✅ ไม่กระทบการทำงานเดิม

## การทดสอบ

### ทดสอบการทำงาน:
1. **เลือก order** → ปุ่มปริ๊นแสดง
2. **กดปุ่มปริ๊น** → เริ่มกระบวนการปริ๊น
3. **ปริ๊นสำเร็จ** → แสดงข้อความยืนยัน
4. **ปริ๊นล้มเหลว** → แสดงข้อความข้อผิดพลาด

### ทดสอบข้อมูล:
1. **Order มี orderItems** → ปริ๊นรายการสินค้า
2. **Order ไม่มี orderItems** → ปริ๊นใบเสร็จว่าง
3. **ข้อมูลการชำระ** → แสดงยอดเงินถูกต้อง
4. **ข้อมูลพนักงาน** → แสดงชื่อพนักงาน

### ทดสอบ UI:
1. **ปุ่มปริ๊น** → แสดงไอคอนและข้อความ
2. **สีและสไตล์** → สอดคล้องกับธีม
3. **ตำแหน่ง** → อยู่ตำแหน่งเดิมของ more_vert

## การจัดการข้อผิดพลาด

### 1. **ไม่มี Order**
```dart
// ตรวจสอบก่อนเรียกใช้
if (selectedOrder != null) {
  _printOrderReceipt(selectedOrder!);
}
```

### 2. **ข้อมูลไม่ครบ**
```dart
// ใช้ค่าเริ่มต้นสำหรับข้อมูลที่ขาด
final staffName = order.shift?.user?.firstName ?? 'พนักงาน';
final productName = orderItem.product?.name ?? 'ไม่มีชื่อ';
```

### 3. **ปริ๊นเตอร์ไม่พร้อม**
```dart
try {
  await printReceiptFromCartItems(...);
} catch (e) {
  // แสดงข้อความข้อผิดพลาด
  Get.snackbar('เกิดข้อผิดพลาด', 'ไม่สามารถปริ๊นได้: $e');
}
```

## สรุป

✅ **ปุ่มปริ๊นในหน้า Receipt History พร้อมใช้งาน**

### การเปลี่ยนแปลง:
- **แทนที่ไอคอน more_vert ด้วยปุ่มปริ๊น**
- **ใช้ฟังก์ชันปริ๊นเดียวกับ PaymentPageD2s**
- **แปลงข้อมูล Order เป็น cartItems format**
- **แสดงข้อความยืนยันและข้อผิดพลาด**

### ฟีเจอร์หลัก:
- **ปุ่มปริ๊นที่ชัดเจน**
- **ใช้ข้อมูลจาก Order จริง**
- **ไม่กระทบการทำงานเดิม**
- **จัดการข้อผิดพลาดอย่างเหมาะสม**

### ประโยชน์:
- **ปริ๊นใบเสร็จซ้ำได้**
- **ใบเสร็จมีรูปแบบเดียวกัน**
- **ใช้งานง่ายและสะดวก**

**🎊 ตอนนี้สามารถปริ๊นใบเสร็จจากหน้า Receipt History ได้แล้ว โดยใช้ข้อมูลจาก Order และมีการทำงานเหมือนกับหน้า PaymentPageD2s!**
