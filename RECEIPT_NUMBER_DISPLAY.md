# ✅ เพิ่มการแสดงเลขที่ใบเสร็จในการปริ๊น

## ฟีเจอร์ที่เพิ่ม

**เพิ่มการแสดงเลขที่ใบเสร็จจาก order ในใบเสร็จที่ปริ๊น โดยแสดงด้านล่าง "ระบบขายหน้าร้าน: POS" และจัดตรงกลาง**

## การเปลี่ยนแปลง

### ก่อนแก้ไข:
```
พนักงาน: John Doe
ระบบขายหน้าร้าน: POS
----------------------------------------
รายการสินค้า...
```

### หลังแก้ไข:
```
พนักงาน: John Doe
ระบบขายหน้าร้าน: POS
เลขที่ใบเสร็จ: 12345
----------------------------------------
รายการสินค้า...
```

## ไฟล์ที่แก้ไข

### 1. `lib/helpers/printReceiptFromCartItems.dart`

#### เพิ่ม parameter สำหรับเลขที่ใบเสร็จ:
```dart
Future<void> printReceiptFromCartItems(
  List<Map<String, dynamic>> cartItems, {
  double? receivedAmount,
  double? changeAmount,
  double? discountAmount,
  String? paymentMethod,
  String? staffName,
  String? receiptNumber, // ✅ เพิ่ม parameter สำหรับเลขที่ใบเสร็จ
}) async {
```

#### เพิ่มการแสดงเลขที่ใบเสร็จ:
```dart
const posText = 'ระบบขายหน้าร้าน: POS';
final posCentered = posText.padLeft(((42 + posText.length) ~/ 2)).padRight(42);
await SunmiPrinter.printText('$posCentered\n');

// ✅ แสดงเลขที่ใบเสร็จ (ถ้ามี)
if (receiptNumber != null && receiptNumber.isNotEmpty) {
  final receiptText = 'เลขที่ใบเสร็จ: $receiptNumber';
  final receiptCentered = receiptText.padLeft(((42 + receiptText.length) ~/ 2)).padRight(42);
  await SunmiPrinter.printText('$receiptCentered\n');
}

await SunmiPrinter.printText('-' * 42 + '\n');
```

### 2. `lib/D2S/home/paymentPageD2s.dart`

#### เพิ่มตัวแปรเก็บเลขที่ใบเสร็จ:
```dart
class _PaymentPageD2sState extends State<PaymentPageD2s> {
  double receivedAmount = 0;
  bool isPaid = false;
  final ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey receiptKey = GlobalKey();
  String? orderReceiptNumber; // ✅ เก็บเลขที่ใบเสร็จจาก API
```

#### แก้ไขฟังก์ชัน createOrders เพื่อเก็บเลขที่ใบเสร็จ:
```dart
print("📦 JSON ที่จะส่ง: $formattedOrder");
final order = await Homeservice.createOrders(formattedOrder: formattedOrder);
if (!mounted) return;

// ✅ เก็บเลขที่ใบเสร็จจาก response
if (order != null && order['id'] != null) {
  orderReceiptNumber = order['id'].toString();
  log('✅ Order created with receipt number: $orderReceiptNumber');
}

setState(() {});
```

#### แก้ไขการเรียกใช้ฟังก์ชันปริ๊น:
```dart
// ✅ ส่งข้อมูลเพิ่มเติมไปยังฟังก์ชันปริ๊น
await printReceiptFromCartItems(
  widget.cartItems,
  receivedAmount: receivedAmount,
  changeAmount: changeAmount,
  discountAmount: totalDiscountApplied > 0 ? totalDiscountApplied : null,
  paymentMethod: _getPaymentMethodName(),
  staffName: staffName,
  receiptNumber: orderReceiptNumber, // ✅ ส่งเลขที่ใบเสร็จไปด้วย
);
```

## การทำงาน

### 1. **สร้าง Order**
```dart
// เมื่อชำระเงินสำเร็จ
final order = await Homeservice.createOrders(formattedOrder: formattedOrder);

// เก็บเลขที่ใบเสร็จจาก response
orderReceiptNumber = order['id'].toString(); // เช่น "12345"
```

### 2. **ส่งไปยังฟังก์ชันปริ๊น**
```dart
await printReceiptFromCartItems(
  widget.cartItems,
  // ... parameters อื่นๆ
  receiptNumber: orderReceiptNumber, // ส่งเลขที่ใบเสร็จ
);
```

### 3. **แสดงในใบเสร็จ**
```dart
// ตรวจสอบว่ามีเลขที่ใบเสร็จหรือไม่
if (receiptNumber != null && receiptNumber.isNotEmpty) {
  // สร้างข้อความและจัดตรงกลาง
  final receiptText = 'เลขที่ใบเสร็จ: $receiptNumber';
  final receiptCentered = receiptText.padLeft(((42 + receiptText.length) ~/ 2)).padRight(42);
  await SunmiPrinter.printText('$receiptCentered\n');
}
```

## ตัวอย่างการแสดงผล

### ใบเสร็จที่ปริ๊นออกมา:
```
        พิชาภพ สินค้าแปรรูป
      ตลาดสี่มุมเมือง (ตลาดสด)
    355/115-116 หมู่ 15 ถ. พหลโยธิน
  ต. คูคต อ. ลำลูกกา จ. ปทุมธานี 12130

         โทร. 099-746-2846


         พนักงาน: John Doe
       ระบบขายหน้าร้าน: POS
        เลขที่ใบเสร็จ: 12345
------------------------------------------
ชาไทย
2 x ฿30.00                        ฿60.00
กาแฟเย็น
1 x ฿35.00                        ฿35.00
------------------------------------------
ส่วนลด                           -฿10.00
        รวมทั้งหมด ฿85.00
เงินสด                            ฿100.00
เงินทอน                           ฿15.00

         ขอบคุณที่ใช้บริการ

1/12/2567 14:30                        
```

## การจัดตำแหน่ง

### การคำนวณตำแหน่งกลาง:
```dart
// สำหรับใบเสร็จกว้าง 42 ตัวอักษร
final receiptText = 'เลขที่ใบเสร็จ: $receiptNumber';
final receiptCentered = receiptText.padLeft(((42 + receiptText.length) ~/ 2)).padRight(42);
```

### ตัวอย่างการคำนวณ:
```
ข้อความ: "เลขที่ใบเสร็จ: 12345" (ยาว 20 ตัวอักษร)
ความกว้างใบเสร็จ: 42 ตัวอักษร
ตำแหน่งเริ่มต้น: (42 + 20) / 2 = 31
ผลลัพธ์: "           เลขที่ใบเสร็จ: 12345           "
```

## การจัดการกรณีพิเศษ

### 1. **ไม่มีเลขที่ใบเสร็จ**
```dart
// ถ้า receiptNumber เป็น null หรือ empty
if (receiptNumber != null && receiptNumber.isNotEmpty) {
  // แสดงเลขที่ใบเสร็จ
} else {
  // ไม่แสดงอะไร (ข้ามไป)
}
```

### 2. **API ไม่ส่ง ID กลับมา**
```dart
// ตรวจสอบ response จาก API
if (order != null && order['id'] != null) {
  orderReceiptNumber = order['id'].toString();
} else {
  orderReceiptNumber = null; // ไม่มีเลขที่ใบเสร็จ
}
```

### 3. **เลขที่ใบเสร็จยาวเกินไป**
```dart
// ถ้าเลขที่ใบเสร็จยาวเกิน 30 ตัวอักษร อาจต้องตัดหรือแสดงในบรรทัดใหม่
final receiptText = 'เลขที่ใบเสร็จ: $receiptNumber';
if (receiptText.length > 42) {
  // จัดการกรณีข้อความยาวเกินไป
}
```

## ข้อดีของการแสดงเลขที่ใบเสร็จ

### 1. **การติดตาม**
- ✅ ลูกค้าสามารถอ้างอิงเลขที่ใบเสร็จได้
- ✅ ง่ายต่อการค้นหาในระบบ
- ✅ ใช้สำหรับการคืนสินค้าหรือเคลม

### 2. **การตรวจสอบ**
- ✅ พนักงานตรวจสอบการขายได้
- ✅ ใช้สำหรับการตรวจสอบยอดขาย
- ✅ ช่วยในการทำบัญชี

### 3. **ความน่าเชื่อถือ**
- ✅ ใบเสร็จดูเป็นทางการมากขึ้น
- ✅ เพิ่มความมั่นใจให้ลูกค้า
- ✅ ตรงตามมาตรฐานการออกใบเสร็จ

## การทดสอบ

### ทดสอบการแสดงผล:
1. **มีเลขที่ใบเสร็จ** → แสดงเลขที่ใบเสร็จตรงกลาง
2. **ไม่มีเลขที่ใบเสร็จ** → ไม่แสดงบรรทัดเลขที่ใบเสร็จ
3. **เลขที่ใบเสร็จยาว** → ตรวจสอบการจัดตำแหน่ง

### ทดสอบการทำงาน:
1. **สร้าง order สำเร็จ** → ได้เลขที่ใบเสร็จ
2. **สร้าง order ล้มเหลว** → ไม่มีเลขที่ใบเสร็จ
3. **API ไม่ส่ง ID** → จัดการกรณีพิเศษ

## สรุป

✅ **การแสดงเลขที่ใบเสร็จในการปริ๊นเสร็จสิ้น**

### การเปลี่ยนแปลง:
- **เพิ่ม parameter receiptNumber ในฟังก์ชันปริ๊น**
- **เก็บเลขที่ใบเสร็จจาก API response**
- **แสดงเลขที่ใบเสร็จตรงกลางด้านล่าง "ระบบขายหน้าร้าน: POS"**

### ผลลัพธ์:
- **ใบเสร็จมีเลขที่อ้างอิง**
- **ลูกค้าสามารถติดตามได้**
- **ระบบดูเป็นทางการมากขึ้น**

### รูปแบบการแสดงผล:
```
ระบบขายหน้าร้าน: POS
เลขที่ใบเสร็จ: [เลขที่จาก API]
----------------------------------------
```

**🎊 ตอนนี้ใบเสร็จจะแสดงเลขที่ใบเสร็จจาก order แล้ว ทำให้ง่ายต่อการติดตามและอ้างอิง!**
