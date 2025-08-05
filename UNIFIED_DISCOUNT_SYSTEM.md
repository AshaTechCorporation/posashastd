# ปรับปรุงระบบลดราคาให้ทุกปุ่มทำงานเหมือนกัน

## ภาพรวมการปรับปรุง

ปรับปรุงระบบส่วนลดให้ทุกปุ่มทำงานเหมือนกัน คือลดราคาลงเรื่อยๆ และมีปุ่มเคลียร์เดียวเพื่อรีเซ็ตราคากลับเป็นเหมือนเดิม

## ✅ การปรับปรุงหลัก

### 1. **ปรับปรุงฟังก์ชันลดราคา**

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
// ✅ จัดการการลดราคา (ทุกปุ่มทำงานเหมือนกัน - ลดราคาลงเรื่อยๆ)
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
      
      // แสดงข้อความยืนยัน
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ลดราคา ฿${discountToApply.toStringAsFixed(0)} (รวมลดแล้ว ฿${totalDiscountApplied.toStringAsFixed(0)})'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 1),
        ),
      );
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

### 2. **ปรับปรุง UI ให้ชัดเจนขึ้น**

#### เปลี่ยนหัวข้อ:
```dart
// ก่อน: 'ส่วนลด'
// หลัง: 'ลดราคา'
const Text('ลดราคา', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))
```

#### ปรับปรุง Badge:
```dart
// ก่อน: 'รวมลด ฿XX'
// หลัง: 'ลดไปแล้ว ฿XX'
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.red.shade100,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: Colors.red.shade300, width: 1.5),
  ),
  child: Text(
    'ลดไปแล้ว ฿${totalDiscountApplied.toStringAsFixed(0)}',
    style: TextStyle(
      color: Colors.red.shade800,
      fontWeight: FontWeight.bold,
      fontSize: 13,
    ),
  ),
)
```

### 3. **ปรับปรุงปุ่มลดราคา**

#### ก่อนแก้ไข:
```dart
OutlinedButton(
  onPressed: () => handleDiscountSelection(amount),
  style: OutlinedButton.styleFrom(
    side: BorderSide(
      color: selectedDiscountAmount == amount ? Colors.green : Colors.grey,
    ),
    backgroundColor: selectedDiscountAmount == amount ? Colors.green.shade50 : Colors.white,
  ),
  child: Text('฿${amount.toStringAsFixed(0)}'),
)
```

#### หลังแก้ไข:
```dart
ElevatedButton(
  onPressed: () => handleDiscountSelection(amount),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange.shade400,
    foregroundColor: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(vertical: 12),
  ),
  child: Text(
    'ลด ฿${amount.toStringAsFixed(0)}',
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
    ),
  ),
)
```

### 4. **ปรับปรุงปุ่มเคลียร์**

#### ก่อนแก้ไข:
```dart
if (totalDiscountApplied > 0) ...[
  OutlinedButton.icon(
    onPressed: clearAllDiscounts,
    icon: const Icon(Icons.clear),
    label: const Text('เคลียร์ส่วนลด'),
  ),
]
```

#### หลังแก้ไข:
```dart
ElevatedButton.icon(
  onPressed: totalDiscountApplied > 0 ? clearAllDiscounts : null,
  style: ElevatedButton.styleFrom(
    backgroundColor: totalDiscountApplied > 0 ? Colors.green.shade500 : Colors.grey.shade300,
    foregroundColor: Colors.white,
    elevation: totalDiscountApplied > 0 ? 2 : 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(vertical: 14),
  ),
  icon: Icon(
    Icons.refresh,
    color: totalDiscountApplied > 0 ? Colors.white : Colors.grey.shade600,
    size: 20,
  ),
  label: Text(
    totalDiscountApplied > 0 
      ? 'เคลียร์ - กลับเป็นราคาเดิม' 
      : 'ไม่มีส่วนลดที่จะเคลียร์',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: totalDiscountApplied > 0 ? Colors.white : Colors.grey.shade600,
    ),
  ),
)
```

## 🎯 การทำงานของระบบใหม่

### 1. **Unified Behavior - ทุกปุ่มทำงานเหมือนกัน**

```
ปุ่ม "ลด ฿1" → ลดราคา 1 บาท
ปุ่ม "ลด ฿2" → ลดราคา 2 บาท  
ปุ่ม "ลด ฿5" → ลดราคา 5 บาท
ปุ่ม "ลด ฿10" → ลดราคา 10 บาท

ทุกปุ่มสามารถกดได้เรื่อยๆ เพื่อลดราคาสะสม
```

### 2. **Flow การใช้งาน**

```
ราคาเดิม: ฿100
         ↓
กด "ลด ฿5" → ฿95 (ลดไปแล้ว ฿5)
         ↓
กด "ลด ฿2" → ฿93 (ลดไปแล้ว ฿7)
         ↓
กด "ลด ฿10" → ฿83 (ลดไปแล้ว ฿17)
         ↓
กด "เคลียร์" → ฿100 (กลับเป็นราคาเดิม)
```

### 3. **Edge Cases**

#### กรณีลดเกินยอด:
```
ราคาคงเหลือ: ฿3
กด "ลด ฿10" → ลดได้เพียง ฿3 (ยอดเป็น ฿0)
แสดงข้อความ: "ลดราคา ฿3 (รวมลดแล้ว ฿XX)"
```

#### กรณียอดเป็น 0:
```
ราคาคงเหลือ: ฿0
กดปุ่มลดราคาใดๆ → แสดงข้อความ "ไม่สามารถลดเพิ่มได้ ยอดเป็น 0 แล้ว"
```

## 📱 User Experience

### 1. **Visual Design**

#### Color Scheme:
- **ส้ม**: ปุ่มลดราคา (action buttons)
- **เขียว**: ปุ่มเคลียร์เมื่อใช้งานได้
- **เทา**: ปุ่มเคลียร์เมื่อไม่สามารถใช้งานได้
- **แดง**: Badge แสดงยอดที่ลดไป

#### Typography:
- **22px**: หัวข้อ "ลดราคา"
- **13px**: ข้อความในปุ่มลดราคา
- **15px**: ข้อความในปุ่มเคลียร์
- **13px**: ข้อความใน Badge

### 2. **Interactive Feedback**

#### เมื่อกดปุ่มลดราคา:
```dart
SnackBar(
  content: Text('ลดราคา ฿5 (รวมลดแล้ว ฿17)'),
  backgroundColor: Colors.blue,
  duration: const Duration(seconds: 1),
)
```

#### เมื่อกดปุ่มเคลียร์:
```dart
SnackBar(
  content: Text('เคลียร์ส่วนลดแล้ว'),
  backgroundColor: Colors.green,
  duration: const Duration(seconds: 1),
)
```

#### เมื่อไม่สามารถลดได้:
```dart
SnackBar(
  content: Text('ไม่สามารถลดเพิ่มได้ ยอดเป็น 0 แล้ว'),
  backgroundColor: Colors.orange,
  duration: const Duration(seconds: 2),
)
```

### 3. **Button States**

#### ปุ่มลดราคา:
- **Active**: สีส้ม, กดได้เสมอ
- **Behavior**: ลดราคาตามจำนวนที่ระบุ

#### ปุ่มเคลียร์:
- **Active**: สีเขียว เมื่อมีส่วนลดที่จะเคลียร์
- **Disabled**: สีเทา เมื่อไม่มีส่วนลดที่จะเคลียร์
- **Text**: เปลี่ยนตามสถานะ

## 🔧 Technical Implementation

### 1. **State Management**

```dart
// ตัวแปรหลัก
double totalDiscountApplied = 0; // ยอดส่วนลดสะสม
double discountAmount = 0;       // สำหรับส่งไป API
double? selectedDiscountAmount;  // ไม่ใช้แล้ว (เก็บไว้เพื่อ compatibility)
```

### 2. **Core Functions**

```dart
// ฟังก์ชันลดราคา
void handleDiscountSelection(double amount) {
  // Logic การลดราคาสะสม
}

// ฟังก์ชันเคลียร์
void clearAllDiscounts() {
  // รีเซ็ตค่าทั้งหมดกลับเป็น 0
}

// ฟังก์ชันคำนวณ
double calculateTotalWithDiscount() {
  // คำนวณราคาหลังหักส่วนลด
}
```

### 3. **API Integration**

```dart
// ข้อมูลที่ส่งไป API
{
  "discount": totalDiscountApplied,
  "remark": totalDiscountApplied > 0 
    ? "ส่วนลดรวม ฿${totalDiscountApplied.toStringAsFixed(0)}" 
    : "string",
}
```

## ✅ ผลลัพธ์

### 1. **Functionality**
- ✅ ทุกปุ่มทำงานเหมือนกัน (ลดราคาลงเรื่อยๆ)
- ✅ กดได้เรื่อยๆ จนยอดเป็น 0
- ✅ ปุ่มเคลียร์เดียวรีเซ็ตทั้งหมด
- ✅ ป้องกันยอดติดลบ

### 2. **User Experience**
- ✅ UI ชัดเจนและเข้าใจง่าย
- ✅ Feedback ทันทีเมื่อกดปุ่ม
- ✅ Visual indicators ที่เหมาะสม
- ✅ Error handling ที่ครบถ้วน

### 3. **Technical Quality**
- ✅ โค้ดสะอาดและเข้าใจง่าย
- ✅ State management ที่ถูกต้อง
- ✅ Consistent behavior
- ✅ Proper error prevention

## 🚀 การพัฒนาต่อ

### ฟีเจอร์ที่สามารถเพิ่มได้:

1. **Custom Amount**:
   - ช่องกรอกจำนวนเงินที่ต้องการลด
   - ปุ่ม "ลดทั้งหมด" เพื่อลดเป็น 0

2. **Discount History**:
   - แสดงประวัติการลดราคา
   - ปุ่ม Undo การลดครั้งล่าสุด

3. **Preset Discounts**:
   - ส่วนลดเปอร์เซ็นต์
   - ส่วนลดตามเงื่อนไข

4. **Animation**:
   - Animation เมื่อลดราคา
   - Smooth transition ของยอดเงิน

### การปรับปรุงเพิ่มเติม:

1. **Accessibility**:
   - Screen reader support
   - Keyboard navigation

2. **Performance**:
   - Debounce การกดปุ่มเร็วๆ
   - Optimize การคำนวณ

3. **Validation**:
   - ตรวจสอบสิทธิ์การใช้ส่วนลด
   - จำกัดจำนวนครั้งการใช้

## 📝 หมายเหตุ

### การใช้งาน:
1. กดปุ่ม "ลด ฿X" เพื่อลดราคา
2. ดูยอดที่ลดไปแล้วที่ Badge
3. กดปุ่ม "เคลียร์" เพื่อรีเซ็ตราคา
4. ระบบป้องกันยอดติดลบอัตโนมัติ

### Best Practices:
- ใช้ totalDiscountApplied เป็น single source of truth
- ให้ feedback ทันทีเมื่อ user กระทำ
- แยก UI state และ business logic ชัดเจน
- ป้องกัน edge cases ทั้งหมด

### Button Labels:
- **"ลด ฿1"**: ชัดเจนว่าจะลดราคา 1 บาท
- **"ลด ฿2"**: ชัดเจนว่าจะลดราคา 2 บาท
- **"เคลียร์ - กลับเป็นราคาเดิม"**: ชัดเจนว่าจะรีเซ็ตทั้งหมด
