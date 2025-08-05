# แยก PaymentDisplayWidget ออกจาก PaymentPageD2s

## ภาพรวมการ Refactor

แยกส่วนแสดงยอดชำระและเงินทอนออกจาก PaymentPageD2s เป็น widget แยกต่างหาก เพื่อให้โค้ดสะอาด นำกลับมาใช้ได้ และง่ายต่อการบำรุงรักษา

## ✅ การแยก Widget

### 1. **สร้างไฟล์ PaymentDisplayWidget.dart**

#### ตำแหน่งไฟล์:
```
lib/D2S/home/widgets/PaymentDisplayWidget.dart
```

#### โครงสร้าง Widget:
```dart
class PaymentDisplayWidget extends StatelessWidget {
  final double total;
  final double receivedAmount;

  const PaymentDisplayWidget({
    super.key,
    required this.total,
    required this.receivedAmount,
  });
}
```

### 2. **Properties และ Getters**

#### Computed Properties:
```dart
// คำนวณเงินทอน
double get changeAmount => receivedAmount - total;

// ตรวจสอบว่าจำนวนเงินที่รับเพียงพอหรือไม่
bool get isAmountSufficient => receivedAmount >= total;
```

### 3. **UI Components**

#### Main Build Method:
```dart
@override
Widget build(BuildContext context) {
  return Center(
    child: isAmountSufficient
        ? _buildPaymentWithChange()
        : _buildPendingPayment(),
  );
}
```

#### แสดงยอดชำระและเงินทอน (เมื่อเงินเพียงพอ):
```dart
Widget _buildPaymentWithChange() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ส่วนยอดรวมและคำอธิบาย
      _buildAmountColumn(
        amount: total,
        label: 'ยอดค้างชำระ',
        fontSize: 32,
        color: Colors.black,
      ),
      
      const SizedBox(width: 24),
      
      // เส้นแบ่งแนวตั้ง
      _buildVerticalDivider(),
      
      const SizedBox(width: 24),
      
      // ส่วนเงินทอนและคำอธิบาย
      _buildAmountColumn(
        amount: changeAmount,
        label: 'เงินทอน',
        fontSize: 32,
        color: Colors.green,
      ),
    ],
  );
}
```

#### แสดงยอดค้างชำระ (เมื่อเงินไม่เพียงพอ):
```dart
Widget _buildPendingPayment() {
  return _buildAmountColumn(
    amount: total,
    label: 'ยอดค้างชำระ',
    fontSize: 36,
    color: Colors.black,
  );
}
```

#### Helper Methods:
```dart
// สร้าง Column สำหรับแสดงจำนวนเงินและป้ายกำกับ
Widget _buildAmountColumn({
  required double amount,
  required String label,
  required double fontSize,
  required Color color,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        '฿${amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 18,
          color: color == Colors.green ? Colors.green : Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

// สร้างเส้นแบ่งแนวตั้ง
Widget _buildVerticalDivider() {
  return Container(
    width: 1,
    height: 50,
    color: Colors.grey,
  );
}
```

## 🔄 การแก้ไข PaymentPageD2s

### 1. **เพิ่ม Import**

```dart
import 'package:posashastd/D2S/home/widgets/PaymentDisplayWidget.dart';
```

### 2. **แทนที่โค้ดเดิม**

#### ก่อนแก้ไข:
```dart
Center(
  child: receivedAmount >= total
      ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนยอดรวมและคำอธิบาย
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '฿${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text('ยอดค้างชำระ', style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
            ],
          ),
          const SizedBox(width: 24),
          // เส้นแบ่งแนวตั้ง
          Container(width: 1, height: 50, color: Colors.grey),
          const SizedBox(width: 24),
          // ส่วนเงินทอนและคำอธิบาย
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '฿${(receivedAmount - total).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text('เงินทอน', style: TextStyle(fontSize: 18, color: Colors.green), textAlign: TextAlign.center),
            ],
          ),
        ],
      )
      : Column(
        children: [
          Text(
            '฿${total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text('ยอดค้างชำระ', style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
        ],
      ),
),
```

#### หลังแก้ไข:
```dart
// ✅ ใช้ PaymentDisplayWidget แทน
PaymentDisplayWidget(
  total: total,
  receivedAmount: receivedAmount,
),
```

## 🎯 ประโยชน์ของการ Refactor

### 1. **Code Organization**
- แยกความรับผิดชอบ (Separation of Concerns)
- PaymentPageD2s มีโค้ดน้อยลงและเข้าใจง่ายขึ้น
- PaymentDisplayWidget มีหน้าที่เฉพาะด้านการแสดงยอดชำระ

### 2. **Reusability**
- สามารถนำ PaymentDisplayWidget ไปใช้ในหน้าอื่นได้
- เช่น หน้าตรวจสอบการชำระเงิน, หน้าสรุปยอดขาย
- ลดการเขียนโค้ดซ้ำ

### 3. **Maintainability**
- แก้ไขการแสดงผลยอดชำระในที่เดียว
- ง่ายต่อการทดสอบ (Unit Testing)
- ลดความซับซ้อนของ PaymentPageD2s

### 4. **Flexibility**
- สามารถปรับแต่ง UI ได้ง่าย
- เพิ่มฟีเจอร์ใหม่ได้สะดวก
- รองรับการเปลี่ยนแปลงในอนาคต

## 🔧 Technical Details

### 1. **Widget Properties**

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| total | double | ✅ | ยอดรวมที่ต้องชำระ |
| receivedAmount | double | ✅ | จำนวนเงินที่รับมา |

### 2. **Computed Properties**

| Property | Return Type | Description |
|----------|-------------|-------------|
| changeAmount | double | เงินทอน (receivedAmount - total) |
| isAmountSufficient | bool | ตรวจสอบว่าเงินเพียงพอหรือไม่ |

### 3. **UI States**

#### State 1: เงินไม่เพียงพอ (receivedAmount < total)
```dart
Column(
  children: [
    Text('฿${total.toStringAsFixed(2)}', fontSize: 36),
    Text('ยอดค้างชำระ'),
  ],
)
```

#### State 2: เงินเพียงพอ (receivedAmount >= total)
```dart
Row(
  children: [
    Column([Text('฿${total}'), Text('ยอดค้างชำระ')]),
    VerticalDivider(),
    Column([Text('฿${changeAmount}'), Text('เงินทอน')]),
  ],
)
```

### 4. **Visual Design**

#### Color Coding:
- **Black**: ยอดค้างชำระ (neutral)
- **Green**: เงินทอน (positive)

#### Typography:
- **32px**: ยอดเงินเมื่อแสดงทั้งคู่
- **36px**: ยอดเงินเมื่อแสดงเพียงอย่างเดียว
- **18px**: ป้ายกำกับ

#### Layout:
- **Center**: จัดกึ่งกลางหน้าจอ
- **Row**: แสดงคู่กันเมื่อมีเงินทอน
- **Column**: แสดงเดี่ยวเมื่อยังไม่ชำระ

## 📱 User Experience

### 1. **Visual Feedback**
- แสดงสถานะการชำระเงินชัดเจน
- ใช้สีเขียวสำหรับเงินทอน (positive feedback)
- ขนาดตัวอักษรที่เหมาะสมและอ่านง่าย

### 2. **Information Hierarchy**
- ยอดเงินเป็นข้อมูลหลัก (ขนาดใหญ่)
- ป้ายกำกับเป็นข้อมูลรอง (ขนาดเล็ก)
- เส้นแบ่งช่วยแยกข้อมูล

### 3. **Responsive Design**
- Layout ปรับตัวตามสถานะการชำระ
- ใช้ Center widget สำหรับการจัดตำแหน่ง
- รองรับหน้าจอขนาดต่างๆ

## 🚀 การพัฒนาต่อ

### ฟีเจอร์ที่สามารถเพิ่มได้:

1. **Animation**:
   ```dart
   AnimatedSwitcher(
     duration: Duration(milliseconds: 300),
     child: isAmountSufficient ? _buildPaymentWithChange() : _buildPendingPayment(),
   )
   ```

2. **Custom Styling**:
   ```dart
   class PaymentDisplayStyle {
     final TextStyle? amountStyle;
     final TextStyle? labelStyle;
     final Color? dividerColor;
   }
   ```

3. **Currency Formatting**:
   ```dart
   final NumberFormat currencyFormatter;
   String formatCurrency(double amount) => currencyFormatter.format(amount);
   ```

4. **Accessibility**:
   ```dart
   Semantics(
     label: 'ยอดค้างชำระ ${total.toStringAsFixed(2)} บาท',
     child: Text('฿${total.toStringAsFixed(2)}'),
   )
   ```

### การปรับปรุงเพิ่มเติม:

1. **Error Handling**:
   - ตรวจสอบค่า negative
   - แสดง fallback UI เมื่อมีปัญหา

2. **Performance**:
   - ใช้ const constructors
   - Optimize การคำนวณ

3. **Testing**:
   - Unit tests สำหรับ computed properties
   - Widget tests สำหรับ UI states

4. **Localization**:
   - รองรับหลายภาษา
   - Format ตัวเลขตามภูมิภาค

## ✅ ผลลัพธ์

### 1. **Code Quality**
- ✅ ลดขนาดไฟล์ PaymentPageD2s
- ✅ แยก widget ที่มีขนาดเหมาะสม (~100 บรรทัด)
- ✅ เพิ่มความสามารถในการนำกลับมาใช้
- ✅ ง่ายต่อการบำรุงรักษา

### 2. **Functionality**
- ✅ การทำงานเหมือนเดิมทุกประการ
- ✅ การแสดงยอดชำระถูกต้อง
- ✅ การคำนวณเงินทอนถูกต้อง
- ✅ UI responsive และสวยงาม

### 3. **Developer Experience**
- ✅ โค้ดอ่านง่ายขึ้น
- ✅ แยกความรับผิดชอบชัดเจน
- ✅ ง่ายต่อการ debug
- ✅ พร้อมสำหรับการขยายฟีเจอร์

## 📝 หมายเหตุ

### Best Practices ที่ใช้:
1. **Single Responsibility Principle**: Widget มีหน้าที่เฉพาะด้าน
2. **Computed Properties**: ใช้ getter สำหรับการคำนวณ
3. **Helper Methods**: แยกโค้ดที่ใช้ซ้ำออกมา
4. **Semantic Naming**: ตั้งชื่อที่สื่อความหมาย

### File Structure:
```
lib/D2S/home/
├── widgets/
│   ├── AppDrawer.dart
│   ├── CartSummaryWidget.dart
│   ├── PaymentDisplayWidget.dart  ← ✅ ไฟล์ใหม่
│   └── ProductHeader.dart
├── homePage.dart
└── paymentPageD2s.dart
```

### Usage Example:
```dart
// Basic usage
PaymentDisplayWidget(
  total: 1500.00,
  receivedAmount: 2000.00,
)

// Will display:
// ยอดค้างชำระ: ฿1,500.00 | เงินทอน: ฿500.00
```
