# ปรับปรุงระบบส่วนลดให้กดได้เรื่อยๆ และเพิ่มปุ่มเคลียร์

## ภาพรวมการปรับปรุง

ปรับปรุงระบบส่วนลดในหน้า PaymentPageD2s ให้สามารถกดปุ่มส่วนลดได้เรื่อยๆ จนกว่ายอดจะเป็น 0 และเพิ่มปุ่มเคลียร์ส่วนลดเพื่อรีเซ็ตกลับสู่ราคาเดิม

## ✅ การปรับปรุงหลัก

### 1. **เพิ่มตัวแปรใหม่สำหรับส่วนลดสะสม**

#### ก่อนแก้ไข:
```dart
// ตัวแปรสำหรับจัดการส่วนลด
double? selectedDiscountAmount;
double discountAmount = 0;
```

#### หลังแก้ไข:
```dart
// ตัวแปรสำหรับจัดการส่วนลด
double? selectedDiscountAmount;
double discountAmount = 0;
double totalDiscountApplied = 0; // ✅ เก็บยอดส่วนลดรวมที่ใช้ไปแล้ว
```

### 2. **ปรับปรุงการคำนวณยอดรวม**

#### ก่อนแก้ไข:
```dart
double calculateTotalWithDiscount() {
  final originalTotal = widget.cartItems.fold(0.0, (sum, item) {
    final price = item['price'] ?? 0;
    final qty = item['qty'] ?? 1;
    return sum + (price * qty);
  });

  if (selectedDiscountAmount != null) {
    discountAmount = selectedDiscountAmount!;
    if (discountAmount > originalTotal) {
      discountAmount = originalTotal;
    }
    return originalTotal - discountAmount;
  }

  discountAmount = 0;
  return originalTotal;
}
```

#### หลังแก้ไข:
```dart
// ✅ คำนวณยอดรวมเดิม (ก่อนหักส่วนลด)
double get originalTotal {
  return widget.cartItems.fold(0.0, (sum, item) {
    final price = item['price'] ?? 0;
    final qty = item['qty'] ?? 1;
    return sum + (price * qty);
  });
}

// ✅ คำนวณยอดรวมหลังหักส่วนลด
double calculateTotalWithDiscount() {
  final total = originalTotal - totalDiscountApplied;
  return total < 0 ? 0 : total; // ไม่ให้ติดลบ
}
```

### 3. **ปรับปรุงฟังก์ชันจัดการส่วนลด**

#### ก่อนแก้ไข:
```dart
void handleDiscountSelection(double amount) {
  setState(() {
    if (selectedDiscountAmount == amount) {
      // ถ้ากดปุ่มเดิม ให้ยกเลิกส่วนลด
      selectedDiscountAmount = null;
      discountAmount = 0;
    } else {
      // เลือกส่วนลดใหม่
      selectedDiscountAmount = amount;
    }
  });
}
```

#### หลังแก้ไข:
```dart
// ✅ จัดการการเพิ่มส่วนลด (กดได้เรื่อยๆ)
void handleDiscountSelection(double amount) {
  setState(() {
    final currentTotal = calculateTotalWithDiscount();
    
    // ตรวจสอบว่าสามารถลดได้อีกหรือไม่
    if (currentTotal > 0) {
      // คำนวณจำนวนที่จะลด (ไม่เกินยอดที่เหลือ)
      final discountToApply = amount > currentTotal ? currentTotal : amount;
      
      // เพิ่มส่วนลดสะสม
      totalDiscountApplied += discountToApply;
      discountAmount = totalDiscountApplied;
      
      log('💰 Applied discount: ฿$discountToApply, Total discount: ฿$totalDiscountApplied');
    } else {
      // ถ้ายอดเป็น 0 แล้ว แสดงข้อความ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่สามารถลดเพิ่มได้ ยอดเป็น 0 แล้ว'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  });
}
```

### 4. **เพิ่มฟังก์ชันเคลียร์ส่วนลด**

```dart
// ✅ เคลียร์ส่วนลดทั้งหมด
void clearAllDiscounts() {
  setState(() {
    selectedDiscountAmount = null;
    discountAmount = 0;
    totalDiscountApplied = 0;
    
    log('🧹 Cleared all discounts');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('เคลียร์ส่วนลดแล้ว'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  });
}
```

## 🎨 การปรับปรุง UI

### 1. **ปรับปรุงหัวข้อส่วนลด**

#### ก่อนแก้ไข:
```dart
const Text('ส่วนลด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
```

#### หลังแก้ไข:
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text('ส่วนลด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
    if (totalDiscountApplied > 0) ...[
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Text(
          'รวมลด ฿${totalDiscountApplied.toStringAsFixed(0)}',
          style: TextStyle(
            color: Colors.red.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    ],
  ],
),
```

### 2. **ปรับปรุงปุ่มส่วนลด**

#### ก่อนแก้ไข:
```dart
OutlinedButton(
  onPressed: () => handleDiscountSelection(amount),
  style: OutlinedButton.styleFrom(
    side: BorderSide(
      color: selectedDiscountAmount == amount ? Colors.green : Colors.grey,
      width: selectedDiscountAmount == amount ? 2 : 1,
    ),
    backgroundColor: selectedDiscountAmount == amount ? Colors.green.shade50 : Colors.white,
  ),
  child: Text('฿${amount.toStringAsFixed(0)}'),
)
```

#### หลังแก้ไข:
```dart
OutlinedButton(
  onPressed: () => handleDiscountSelection(amount),
  style: OutlinedButton.styleFrom(
    side: const BorderSide(color: Colors.blue, width: 1),
    backgroundColor: Colors.blue.shade50,
    fixedSize: const Size.fromHeight(44),
  ),
  child: Text(
    '-฿${amount.toStringAsFixed(0)}',
    style: const TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
  ),
)
```

### 3. **เพิ่มปุ่มเคลียร์ส่วนลด**

```dart
// ✅ ปุ่มเคลียร์ส่วนลด
if (totalDiscountApplied > 0) ...[
  const SizedBox(height: 8),
  SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: clearAllDiscounts,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red, width: 1),
        backgroundColor: Colors.red.shade50,
        fixedSize: const Size.fromHeight(40),
      ),
      icon: const Icon(Icons.clear, color: Colors.red, size: 18),
      label: const Text(
        'เคลียร์ส่วนลด',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
  ),
],
```

## 🔧 การปรับปรุงข้อมูลที่ส่งไป API

### ก่อนแก้ไข:
```dart
"discount": discountAmount,
"remark": selectedDiscountAmount != null ? "ส่วนลด ฿${selectedDiscountAmount!.toStringAsFixed(0)}" : "string",
```

### หลังแก้ไข:
```dart
"discount": totalDiscountApplied,
"remark": totalDiscountApplied > 0 ? "ส่วนลดรวม ฿${totalDiscountApplied.toStringAsFixed(0)}" : "string",
```

## 🎯 การทำงานของระบบใหม่

### 1. **Flow การใช้ส่วนลด**

```
User กดปุ่มส่วนลด (เช่น ฿5)
         ↓
ตรวจสอบยอดปัจจุบัน > 0?
    ↓ ใช่                    ↓ ไม่ใช่
คำนวณจำนวนที่จะลด          แสดงข้อความ "ยอดเป็น 0 แล้ว"
    ↓
เพิ่มเข้า totalDiscountApplied
    ↓
อัพเดท UI และแสดงยอดใหม่
    ↓
User สามารถกดปุ่มส่วนลดต่อได้
```

### 2. **Flow การเคลียร์ส่วนลด**

```
User กดปุ่ม "เคลียร์ส่วนลด"
         ↓
รีเซ็ต totalDiscountApplied = 0
         ↓
รีเซ็ต discountAmount = 0
         ↓
รีเซ็ต selectedDiscountAmount = null
         ↓
อัพเดท UI กลับสู่ราคาเดิม
         ↓
แสดงข้อความ "เคลียร์ส่วนลดแล้ว"
```

### 3. **Logic การคำนวณ**

```
ยอดเดิม: ฿100
กดส่วนลด ฿5 → ยอดเหลือ ฿95 (totalDiscountApplied = ฿5)
กดส่วนลด ฿10 → ยอดเหลือ ฿85 (totalDiscountApplied = ฿15)
กดส่วนลด ฿100 → ยอดเหลือ ฿0 (totalDiscountApplied = ฿100, ลดได้เพียง ฿85)
กดส่วนลดอีก → แสดงข้อความ "ไม่สามารถลดเพิ่มได้"
กดเคลียร์ → ยอดกลับเป็น ฿100 (totalDiscountApplied = ฿0)
```

## 📱 User Experience

### 1. **Visual Feedback**

#### แสดงยอดส่วนลดสะสม:
- Badge สีแดงแสดง "รวมลด ฿XX" เมื่อมีส่วนลด
- ปรากฏข้างหัวข้อ "ส่วนลด"

#### ปุ่มส่วนลด:
- เปลี่ยนจาก "฿5" เป็น "-฿5" เพื่อแสดงการลด
- สีฟ้าแทนสีเขียว เพื่อแยกจากสถานะ "เลือกแล้ว"

#### ปุ่มเคลียร์:
- ปรากฏเฉพาะเมื่อมีส่วนลด
- สีแดงเพื่อแสดงการรีเซ็ต
- มีไอคอน clear

### 2. **User Interaction**

#### การกดปุ่มส่วนลด:
- กดได้เรื่อยๆ ไม่จำกัดครั้ง
- ลดได้จนยอดเป็น 0
- แสดงข้อความเตือนเมื่อไม่สามารถลดเพิ่มได้

#### การเคลียร์ส่วนลด:
- กดปุ่มเดียวรีเซ็ตทั้งหมด
- แสดงข้อความยืนยัน
- ยอดกลับสู่ราคาเดิมทันที

### 3. **Error Prevention**

#### ป้องกันยอดติดลบ:
```dart
final total = originalTotal - totalDiscountApplied;
return total < 0 ? 0 : total; // ไม่ให้ติดลบ
```

#### ป้องกันส่วนลดเกินยอด:
```dart
final discountToApply = amount > currentTotal ? currentTotal : amount;
```

#### แจ้งเตือนเมื่อไม่สามารถลดได้:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('ไม่สามารถลดเพิ่มได้ ยอดเป็น 0 แล้ว'),
    backgroundColor: Colors.orange,
  ),
);
```

## ✅ ผลลัพธ์

### 1. **Functionality**
- ✅ กดปุ่มส่วนลดได้เรื่อยๆ จนยอดเป็น 0
- ✅ ปุ่มเคลียร์ส่วนลดทำงานถูกต้อง
- ✅ แสดงยอดส่วนลดสะสมแบบ real-time
- ✅ ป้องกันยอดติดลบและส่วนลดเกินยอด

### 2. **User Experience**
- ✅ UI ชัดเจนและเข้าใจง่าย
- ✅ Visual feedback ที่เหมาะสม
- ✅ Error handling ที่ครบถ้วน
- ✅ การใช้งานที่สะดวกและรวดเร็ว

### 3. **Technical Quality**
- ✅ โค้ดสะอาดและอ่านง่าย
- ✅ การจัดการ state ที่ถูกต้อง
- ✅ Logging สำหรับ debugging
- ✅ Integration กับ API ที่ถูกต้อง

## 🚀 การพัฒนาต่อ

### ฟีเจอร์ที่สามารถเพิ่มได้:

1. **Undo/Redo**:
   - ปุ่มยกเลิกส่วนลดครั้งล่าสุด
   - ประวัติการใช้ส่วนลด

2. **Preset Discounts**:
   - ส่วนลดเปอร์เซ็นต์
   - ส่วนลดตามจำนวนสินค้า

3. **Discount Validation**:
   - ตรวจสอบสิทธิ์การใช้ส่วนลด
   - จำกัดจำนวนครั้งการใช้

4. **Animation**:
   - Animation เมื่อเพิ่ม/ลบส่วนลด
   - Smooth transition ของยอดเงิน

### การปรับปรุงเพิ่มเติม:

1. **Performance**:
   - Debounce การกดปุ่มเร็วๆ
   - Optimize การคำนวณ

2. **Accessibility**:
   - Screen reader support
   - Keyboard navigation

3. **Analytics**:
   - Track การใช้ส่วนลด
   - รายงานส่วนลดที่ใช้บ่อย

## 📝 หมายเหตุ

### การใช้งาน:
1. กดปุ่มส่วนลดเพื่อลดยอด
2. ดูยอดส่วนลดสะสมที่ badge
3. กดปุ่มเคลียร์เพื่อรีเซ็ต
4. ระบบป้องกันยอดติดลบอัตโนมัติ

### Best Practices:
- ใช้ totalDiscountApplied เป็น single source of truth
- แยก UI state และ business logic
- ให้ feedback ทันทีเมื่อ user กระทำ
- ป้องกัน edge cases ทั้งหมด
