# ปรับปรุงการปริ๊นใบเสร็จให้แสดงเงินทอนและส่วนลด

## ภาพรวมการปรับปรุง

เพิ่มการแสดงเงินทอนและส่วนลดในใบเสร็จที่ปริ๊นออกมา โดยแสดงไว้ใต้ข้อมูลการชำระเงิน

## ✅ การปรับปรุงหลัก

### 1. **ปรับปรุงฟังก์ชัน printReceiptFromCartItems**

#### ก่อนแก้ไข:
```dart
Future<void> printReceiptFromCartItems(List<Map<String, dynamic>> cartItems) async {
  // รับเฉพาะ cartItems
}
```

#### หลังแก้ไข:
```dart
Future<void> printReceiptFromCartItems(
  List<Map<String, dynamic>> cartItems, {
  double? receivedAmount,
  double? changeAmount,
  double? discountAmount,
  String? paymentMethod,
}) async {
  // รับข้อมูลเพิ่มเติมสำหรับการปริ๊น
}
```

### 2. **เพิ่มการแสดงส่วนลด**

```dart
// ✅ แสดงส่วนลด (ถ้ามี)
if (discountAmount != null && discountAmount > 0) {
  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
  final discountLeft = 'ส่วนลด';
  final discountRight = '-฿${discountAmount.toStringAsFixed(2)}';
  final discountSpace = 42 - discountLeft.length - discountRight.length;
  await SunmiPrinter.printText('${discountLeft.padRight(discountLeft.length + discountSpace)}$discountRight\n');
}
```

### 3. **ปรับปรุงการแสดงยอดรวม**

```dart
// 💵 Total (หลังหักส่วนลด)
final finalTotal = total - (discountAmount ?? 0);
await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
await SunmiPrinter.setFontSize(2);
await SunmiPrinter.printText('รวมทั้งหมด ฿${finalTotal.toStringAsFixed(2)}\n');
await SunmiPrinter.setFontSize(1);
```

### 4. **เพิ่มการแสดงวิธีการชำระเงิน**

```dart
// ✅ แสดงวิธีการชำระเงิน
final paymentMethodText = paymentMethod ?? 'เงินสด';
final paymentLeft = paymentMethodText;
final paymentRight = '฿${(receivedAmount ?? finalTotal).toStringAsFixed(2)}';
final paymentSpace = 42 - paymentLeft.length - paymentRight.length;
await SunmiPrinter.printText('${paymentLeft.padRight(paymentLeft.length + paymentSpace)}$paymentRight\n');
```

### 5. **เพิ่มการแสดงเงินทอน**

```dart
// ✅ แสดงเงินทอน (ถ้ามี)
if (changeAmount != null && changeAmount > 0) {
  final changeLeft = 'เงินทอน';
  final changeRight = '฿${changeAmount.toStringAsFixed(2)}';
  final changeSpace = 42 - changeLeft.length - changeRight.length;
  await SunmiPrinter.printText('${changeLeft.padRight(changeLeft.length + changeSpace)}$changeRight\n');
}
```

## 🔄 การแก้ไข PaymentPageD2s

### 1. **เพิ่มตัวแปร currentPaymentMethodId**

```dart
class _PaymentPageD2sState extends State<PaymentPageD2s> {
  double receivedAmount = 0;
  bool isPaid = false;
  double totalDiscountApplied = 0;
  int currentPaymentMethodId = 1; // ✅ เก็บ paymentMethodId ปัจจุบัน (default: เงินสด)
  // ...
}
```

### 2. **เพิ่มฟังก์ชัน _getPaymentMethodName**

```dart
// ✅ ได้ชื่อวิธีการชำระเงินจาก paymentMethodId ปัจจุบัน
String _getPaymentMethodName() {
  switch (currentPaymentMethodId) {
    case 1:
      return 'เงินสด';
    case 2:
      return 'โอน';
    case 3:
      return 'เครดิต';
    default:
      return 'เงินสด';
  }
}
```

### 3. **ปรับปรุงการเรียกใช้ฟังก์ชันปริ๊น**

#### ก่อนแก้ไข:
```dart
await printReceiptFromCartItems(widget.cartItems);
```

#### หลังแก้ไข:
```dart
final total = calculateTotalWithDiscount();
final changeAmount = receivedAmount >= total ? (receivedAmount - total).toDouble() : 0.0;

// ✅ ส่งข้อมูลเพิ่มเติมไปยังฟังก์ชันปริ๊น
await printReceiptFromCartItems(
  widget.cartItems,
  receivedAmount: receivedAmount,
  changeAmount: changeAmount,
  discountAmount: totalDiscountApplied > 0 ? totalDiscountApplied : null,
  paymentMethod: _getPaymentMethodName(),
);
```

### 4. **อัปเดต onConfirm Callbacks**

```dart
onConfirm: (paymentMethodId, autoSetAmount) async {
  // ✅ เก็บ paymentMethodId สำหรับการปริ๊น
  setState(() {
    currentPaymentMethodId = paymentMethodId;
  });

  // ✅ ตั้งค่า receivedAmount สำหรับโอนและเครดิต
  if (autoSetAmount) {
    setState(() {
      receivedAmount = total;
    });
  }

  // ... rest of the logic
  await createOrders(paymentMethodId: paymentMethodId);
}
```

## 🎯 ผลลัพธ์การปริ๊น

### ตัวอย่างใบเสร็จที่ปริ๊นออกมา:

```
              พิซากพ
           เปิด 24 ชั่วโมง

พนักงาน: unknown unknown
ระบบขายหน้าร้าน: POS 4
------------------------------------------
กาแฟ
1 x ฿35.00                        ฿35.00
ขนมปัง
2 x ฿15.00                        ฿30.00
------------------------------------------
ส่วนลด                            -฿5.00
          รวมทั้งหมด ฿60.00
เงินสด                            ฿70.00
เงินทอน                           ฿10.00

            ขอบคุณที่ใช้บริการ

28/12/2567 14:30                        
```

### สำหรับการชำระแบบโอน/เครดิต:

```
              พิซากพ
           เปิด 24 ชั่วโมง

พนักงาน: unknown unknown
ระบบขายหน้าร้าน: POS 4
------------------------------------------
กาแฟ
1 x ฿35.00                        ฿35.00
ขนมปัง
2 x ฿15.00                        ฿30.00
------------------------------------------
ส่วนลด                            -฿5.00
          รวมทั้งหมด ฿60.00
โอน                               ฿60.00

            ขอบคุณที่ใช้บริการ

28/12/2567 14:30                        
```

## 🔧 Technical Details

### 1. **Parameter Types**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| cartItems | List<Map<String, dynamic>> | ✅ | รายการสินค้าในตะกร้า |
| receivedAmount | double? | ❌ | จำนวนเงินที่รับ |
| changeAmount | double? | ❌ | เงินทอน |
| discountAmount | double? | ❌ | ส่วนลด |
| paymentMethod | String? | ❌ | วิธีการชำระเงิน |

### 2. **Conditional Display Logic**

#### ส่วนลด:
- แสดงเฉพาะเมื่อ `discountAmount != null && discountAmount > 0`
- แสดงเป็น `-฿xx.xx` (เครื่องหมายลบ)

#### เงินทอน:
- แสดงเฉพาะเมื่อ `changeAmount != null && changeAmount > 0`
- แสดงเฉพาะสำหรับการชำระด้วยเงินสด

#### วิธีการชำระเงิน:
- แสดงชื่อวิธีการชำระเงิน (เงินสด, โอน, เครดิต)
- แสดงจำนวนเงินที่รับ

### 3. **Layout Structure**

```
รายการสินค้า
------------------------------------------
ส่วนลด (ถ้ามี)                    -฿xx.xx
          รวมทั้งหมด ฿xx.xx
วิธีการชำระเงิน                   ฿xx.xx
เงินทอน (ถ้ามี)                   ฿xx.xx
```

## 🎨 UI Improvements

### 1. **Alignment และ Spacing**
- ใช้ความกว้าง 42 ตัวอักษรสำหรับการจัดตำแหน่ง
- จัดข้อความซ้าย-ขวาด้วย `padRight()`
- ใช้ `setAlignment()` สำหรับจัดกลาง

### 2. **Typography**
- ยอดรวม: ขนาดใหญ่ (setFontSize(2)) และจัดกลาง
- รายละเอียดอื่น: ขนาดปกติ (setFontSize(1)) และจัดซ้าย

### 3. **Visual Hierarchy**
- เส้นแบ่ง (`-` * 42) ก่อนและหลังรายการสินค้า
- ส่วนลดแสดงด้วยเครื่องหมายลบ
- ยอดรวมเด่นด้วยขนาดตัวอักษรใหญ่

## 🚀 การพัฒนาต่อ

### ฟีเจอร์ที่สามารถเพิ่มได้:

1. **Tax Information**:
   ```dart
   double? taxAmount,
   double? taxRate,
   ```

2. **Customer Information**:
   ```dart
   String? customerName,
   String? customerPhone,
   ```

3. **Order Information**:
   ```dart
   String? orderNumber,
   String? tableNumber,
   ```

4. **Promotion Details**:
   ```dart
   String? promotionName,
   List<String>? appliedPromotions,
   ```

### การปรับปรุงเพิ่มเติม:

1. **QR Code**:
   - เพิ่ม QR code สำหรับการตรวจสอบใบเสร็จ
   - QR code สำหรับการให้คะแนน

2. **Barcode**:
   - เพิ่ม barcode สำหรับหมายเลขใบเสร็จ

3. **Logo**:
   - เพิ่มโลโก้ร้านค้า
   - รองรับการปริ๊นรูปภาพ

4. **Multi-language**:
   - รองรับหลายภาษา
   - ปรับเปลี่ยนภาษาตามการตั้งค่า

## ✅ ผลลัพธ์

### 1. **Functionality**
- ✅ แสดงส่วนลดในใบเสร็จ
- ✅ แสดงเงินทอนสำหรับเงินสด
- ✅ แสดงวิธีการชำระเงินที่ถูกต้อง
- ✅ คำนวณยอดรวมหลังหักส่วนลด

### 2. **User Experience**
- ✅ ใบเสร็จมีข้อมูลครบถ้วน
- ✅ แสดงข้อมูลการชำระเงินชัดเจน
- ✅ ง่ายต่อการอ่านและเข้าใจ
- ✅ สอดคล้องกับมาตรฐานใบเสร็จ

### 3. **Technical Quality**
- ✅ รองรับหลายวิธีการชำระเงิน
- ✅ จัดการข้อมูลที่เป็น null ได้
- ✅ คำนวณเงินทอนถูกต้อง
- ✅ แสดงส่วนลดแบบสะสม

### 4. **Business Value**
- ✅ เพิ่มความน่าเชื่อถือของระบบ
- ✅ ลูกค้าได้ข้อมูลครบถ้วน
- ✅ ง่ายต่อการตรวจสอบและบัญชี
- ✅ รองรับการใช้งานจริง

## 📝 หมายเหตุ

### Best Practices ที่ใช้:
1. **Optional Parameters**: ใช้ named parameters ที่เป็น optional
2. **Null Safety**: ตรวจสอบ null ก่อนแสดงข้อมูล
3. **Conditional Display**: แสดงข้อมูลเฉพาะเมื่อจำเป็น
4. **Consistent Formatting**: ใช้รูปแบบการแสดงผลที่สม่ำเสมอ

### การใช้งาน:
- ฟังก์ชันจะแสดงข้อมูลเฉพาะที่ส่งมา
- ถ้าไม่ส่งข้อมูลใด จะไม่แสดงในใบเสร็จ
- รองรับการชำระเงินหลายรูปแบบ
- คำนวณเงินทอนอัตโนมัติ

### Performance Considerations:
- ใช้ conditional rendering เพื่อลดการประมวลผล
- ตรวจสอบ null เฉพาะเมื่อจำเป็น
- ใช้ string interpolation อย่างมีประสิทธิภาพ
- จัดการ memory อย่างเหมาะสม
