# เพิ่มฟีเจอร์ Dialog ยืนยันการชำระเงิน

## ภาพรวมฟีเจอร์

เพิ่ม dialog ยืนยันการชำระเงินสำหรับทุกประเภทการชำระ (เงินสด, โอน, เครดิต) พร้อมกับการตั้งค่า receivedAmount และ paymentMethodId อัตโนมัติ

## ✅ การเพิ่มฟีเจอร์

### 1. **เพิ่ม Import GetX**

```dart
import 'package:get/get.dart';
```

### 2. **ปรับปรุงปุ่มการชำระเงิน**

#### ปุ่มเงินสด:
```dart
// ก่อนแก้ไข
onTap: () async {
  if (receivedAmount >= total) {
    setState(() { isPaid = true; });
    await createOrders(paymentMethodId: 1);
  } else {
    // แสดง error
  }
}

// หลังแก้ไข
onTap: () {
  _showPaymentConfirmDialog(
    context,
    'เงินสด',
    Icons.payments,
    1, // paymentMethodId สำหรับเงินสด
    false, // ไม่ auto set receivedAmount
  );
}
```

#### ปุ่มโอน:
```dart
// ก่อนแก้ไข
onTap: () {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('ฟังก์ชั่นนี้ยังไม่เปิดใช้งาน'))
  );
}

// หลังแก้ไข
onTap: () {
  _showPaymentConfirmDialog(
    context,
    'โอน',
    Icons.account_balance,
    2, // paymentMethodId สำหรับโอน
    true, // auto set receivedAmount = total
  );
}
```

#### ปุ่มเครดิต:
```dart
// ก่อนแก้ไข
onTap: () {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('ฟังก์ชั่นนี้ยังไม่เปิดใช้งาน'))
  );
}

// หลังแก้ไข
onTap: () {
  _showPaymentConfirmDialog(
    context,
    'เครดิต',
    Icons.add_card,
    3, // paymentMethodId สำหรับเครดิต
    true, // auto set receivedAmount = total
  );
}
```

### 3. **เพิ่มฟังก์ชัน _showPaymentConfirmDialog**

```dart
void _showPaymentConfirmDialog(
  BuildContext context,
  String paymentMethod,
  IconData icon,
  int paymentMethodId,
  bool autoSetAmount,
) {
  final total = calculateTotalWithDiscount();
  
  Get.dialog(
    AlertDialog(
      title: Row(children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 8),
        Text('ยืนยันการชำระเงิน')
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ต้องการชำระเงินด้วย$paymentMethod หรือไม่?',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ยอดรวม:', style: TextStyle(fontSize: 16)),
                    Text('฿${total.toStringAsFixed(2)}', 
                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                // แสดงข้อมูลเพิ่มเติมสำหรับเงินสด
                if (!autoSetAmount) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('จำนวนรับ:', style: TextStyle(fontSize: 16)),
                      Text('฿${receivedAmount.toStringAsFixed(2)}', 
                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('เงินทอน:', style: TextStyle(fontSize: 16)),
                      Text(
                        '฿${(receivedAmount - total).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: receivedAmount >= total ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('ยกเลิก', style: TextStyle(fontSize: 18)),
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back(); // ปิด dialog
            
            // ✅ ตั้งค่า receivedAmount สำหรับโอนและเครดิต
            if (autoSetAmount) {
              setState(() {
                receivedAmount = total;
              });
            }
            
            // ✅ ตรวจสอบจำนวนเงินสำหรับเงินสด
            if (!autoSetAmount && receivedAmount < total) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('จำนวนที่รับชำระไม่เพียงพอ'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            
            // ✅ ดำเนินการชำระเงิน
            setState(() {
              isPaid = true;
            });
            
            await createOrders(paymentMethodId: paymentMethodId);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('ยืนยัน', style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}
```

## 🎯 การทำงานของฟีเจอร์

### 1. **Payment Method Configuration**

| ประเภท | paymentMethodId | Auto Set Amount | receivedAmount |
|--------|-----------------|-----------------|----------------|
| เงินสด | 1 | ❌ | ใช้ค่าที่ผู้ใช้ป้อน |
| โอน | 2 | ✅ | = total |
| เครดิต | 3 | ✅ | = total |

### 2. **User Flow**

#### สำหรับเงินสด:
```
User taps "เงินสด"
         ↓
แสดง Dialog ยืนยัน
         ↓
แสดงยอดรวม, จำนวนรับ, เงินทอน
         ↓
User taps "ยืนยัน"
         ↓
ตรวจสอบ receivedAmount >= total
         ↓
หากเพียงพอ: ดำเนินการชำระ
หากไม่พอ: แสดง error
```

#### สำหรับโอน/เครดิต:
```
User taps "โอน" หรือ "เครดิต"
         ↓
แสดง Dialog ยืนยัน
         ↓
แสดงยอดรวมเท่านั้น
         ↓
User taps "ยืนยัน"
         ↓
ตั้งค่า receivedAmount = total
         ↓
ดำเนินการชำระเงินทันที
```

### 3. **Technical Flow**
```
_showPaymentConfirmDialog()
         ↓
Get.dialog(AlertDialog)
         ↓
User confirms
         ↓
if (autoSetAmount) receivedAmount = total
         ↓
Validate amount (for cash only)
         ↓
setState({ isPaid = true })
         ↓
createOrders(paymentMethodId)
         ↓
API call with correct paymentMethodId
```

## 🔧 Technical Details

### 1. **Dialog Configuration**
```dart
Get.dialog(
  AlertDialog(...),
  barrierDismissible: false, // ป้องกันการปิดโดยการแตะข้างนอก
)
```

### 2. **Conditional UI**
```dart
// แสดงข้อมูลเพิ่มเติมเฉพาะเงินสด
if (!autoSetAmount) ...[
  // จำนวนรับ และ เงินทอน
]
```

### 3. **Amount Validation**
```dart
// ตรวจสอบเฉพาะเงินสด
if (!autoSetAmount && receivedAmount < total) {
  // แสดง error
  return;
}
```

### 4. **State Management**
```dart
// ตั้งค่า receivedAmount สำหรับโอน/เครดิต
if (autoSetAmount) {
  setState(() {
    receivedAmount = total;
  });
}
```

## 📱 User Experience

### 1. **Visual Design**
- **Icon**: แต่ละประเภทมีไอคอนเฉพาะ
- **Color**: สีเขียวสำหรับการยืนยัน
- **Layout**: ข้อมูลจัดเรียงอย่างชัดเจน

### 2. **Information Display**

#### เงินสด:
- ยอดรวม
- จำนวนรับ
- เงินทอน (สีเขียว/แดงตามสถานะ)

#### โอน/เครดิต:
- ยอดรวมเท่านั้น
- ไม่แสดงจำนวนรับและเงินทอน

### 3. **Error Handling**
- ตรวจสอบจำนวนเงินสำหรับเงินสด
- แสดง SnackBar เมื่อจำนวนไม่เพียงพอ
- ป้องกันการปิด dialog โดยไม่ตั้งใจ

## 🎨 UI Components

### 1. **Dialog Header**
```dart
Row(children: [
  Icon(icon, color: Colors.green),
  SizedBox(width: 8),
  Text('ยืนยันการชำระเงิน')
])
```

### 2. **Content Section**
```dart
Column(
  children: [
    Text('ต้องการชำระเงินด้วย$paymentMethod หรือไม่?'),
    Container(
      // Summary box with payment details
    ),
  ],
)
```

### 3. **Action Buttons**
```dart
actions: [
  TextButton('ยกเลิก'),
  ElevatedButton('ยืนยัน'),
]
```

## ✅ ผลลัพธ์

### 1. **Functionality**
- ✅ Dialog ยืนยันสำหรับทุกประเภทการชำระ
- ✅ Auto set receivedAmount สำหรับโอน/เครดิต
- ✅ paymentMethodId ถูกต้อง (1=เงินสด, 2=โอน, 3=เครดิต)
- ✅ Validation สำหรับเงินสด
- ✅ Error handling ที่เหมาะสม

### 2. **User Experience**
- ✅ ข้อมูลแสดงชัดเจน
- ✅ ป้องกันการกดผิด
- ✅ Feedback ที่เข้าใจง่าย
- ✅ UI ที่สอดคล้องกัน

### 3. **Technical Quality**
- ✅ Code ที่สะอาดและเข้าใจง่าย
- ✅ Reusable dialog function
- ✅ Proper state management
- ✅ Error prevention

## 🚀 การพัฒนาต่อ

### ฟีเจอร์ที่สามารถเพิ่มได้:
1. **QR Code Payment**: เพิ่มการชำระด้วย QR Code
2. **Multiple Payment**: ชำระด้วยหลายวิธีในครั้งเดียว
3. **Payment History**: บันทึกประวัติการชำระ
4. **Receipt Options**: เลือกประเภทใบเสร็จ
5. **Customer Info**: เพิ่มข้อมูลลูกค้า

### การปรับปรุงเพิ่มเติม:
- เพิ่ม animation สำหรับ dialog
- เพิ่ม sound effect เมื่อชำระสำเร็จ
- เพิ่มการ validate ข้อมูลเพิ่มเติม
- เพิ่มการ track payment method usage

## 📝 หมายเหตุ

### Payment Method IDs:
- **1**: เงินสด (Cash)
- **2**: โอน (Transfer)
- **3**: เครดิต (Credit)

### Auto Amount Setting:
- **เงินสด**: ใช้ receivedAmount ที่ผู้ใช้ป้อน
- **โอน/เครดิต**: ตั้งค่า receivedAmount = total อัตโนมัติ

### Validation Rules:
- **เงินสด**: receivedAmount >= total
- **โอน/เครดิต**: ไม่ต้อง validate (เพราะ receivedAmount = total)
