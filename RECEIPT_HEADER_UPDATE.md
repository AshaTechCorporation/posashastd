# อัปเดตหัวใบเสร็จให้แสดงข้อมูลร้านค้าที่ถูกต้อง

## การเปลี่ยนแปลง

เปลี่ยนข้อมูลหัวใบเสร็จจาก "พิซากพ" เป็นข้อมูลร้านค้าจริง "พิชาภพ สินค้าแปรรูป" พร้อมที่อยู่และเบอร์โทรศัพท์ครบถ้วน

## ✅ การปรับปรุง

### ก่อนแก้ไข:
```dart
// 🏪 Header
await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
await SunmiPrinter.setFontSize(2);
const storeName = 'พิซากพ';
final storeCentered = storeName.padLeft(((42 + storeName.length) ~/ 2)).padRight(42);
await SunmiPrinter.printText('$storeCentered\n');

await SunmiPrinter.setFontSize(1);
const openText = 'เปิด 24 ชั่วโมง';
final openCentered = openText.padLeft(((42 + openText.length) ~/ 2)).padRight(42);
await SunmiPrinter.printText('$openCentered\n');
await SunmiPrinter.lineWrap(1);
```

### หลังแก้ไข:
```dart
// 🏪 Header
await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
await SunmiPrinter.setFontSize(2);
await SunmiPrinter.printText('พิชาภพ สินค้าแปรรูป\n');

await SunmiPrinter.setFontSize(1);
await SunmiPrinter.printText('ตลาดสี่มุมเมือง (ตลาดสด)\n');
await SunmiPrinter.printText('355/115-116 หมู่ 15 ถ. พหลโยธิน\n');
await SunmiPrinter.printText('ต. คูคต อ. ลำลูกกา จ. ปทุมธานี 12130\n');
await SunmiPrinter.printText('โทร. 099-746-2846\n');
await SunmiPrinter.lineWrap(1);
```

## 📄 ผลลัพธ์ใบเสร็จ

### ก่อนแก้ไข:
```
              พิซากพ
           เปิด 24 ชั่วโมง

พนักงาน: Shop1 Shop1
ระบบขายหน้าร้าน: POS 4
------------------------------------------
```

### หลังแก้ไข:
```
         พิชาภพ สินค้าแปรรูป
       ตลาดสี่มุมเมือง (ตลาดสด)
    355/115-116 หมู่ 15 ถ. พหลโยธิน
  ต. คูคต อ. ลำลูกกา จ. ปทุมธานี 12130
           โทร. 099-746-2846

พนักงาน: Shop1 Shop1
ระบบขายหน้าร้าน: POS 4
------------------------------------------
```

## 🎯 รายละเอียดการปรับปรุง

### 1. **ชื่อร้าน**
- **ก่อน**: "พิซากพ"
- **หลัง**: "พิชาภพ สินค้าแปรรูป"
- **ขนาดตัวอักษร**: ใหญ่ (setFontSize(2))

### 2. **ข้อมูลร้าน**
- **สถานที่**: "ตลาดสี่มุมเมือง (ตลาดสด)"
- **ที่อยู่**: "355/115-116 หมู่ 15 ถ. พหลโยธิน"
- **จังหวัด**: "ต. คูคต อ. ลำลูกกา จ. ปทุมธานี 12130"
- **โทรศัพท์**: "โทร. 099-746-2846"

### 3. **การจัดตำแหน่ง**
- **ใช้**: `SunmiPrintAlign.CENTER`
- **ผลลัพธ์**: ข้อความทั้งหมดจัดกลางอัตโนมัติ
- **ไม่ต้อง**: คำนวณ padding เอง

## 🔧 Technical Details

### 1. **Font Sizes**
```dart
await SunmiPrinter.setFontSize(2); // ชื่อร้าน (ใหญ่)
await SunmiPrinter.setFontSize(1); // ข้อมูลอื่นๆ (ปกติ)
```

### 2. **Text Alignment**
```dart
await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
// ข้อความทั้งหมดจัดกลางอัตโนมัติ
```

### 3. **Line Spacing**
```dart
await SunmiPrinter.lineWrap(1); // เว้นบรรทัดหลังหัวใบเสร็จ
```

## 📱 การแสดงผลบนใบเสร็จ

### Layout Structure:
```
┌─────────────────────────────────────────┐
│         พิชาภพ สินค้าแปรรูป              │ ← Font Size 2, Center
│       ตลาดสี่มุมเมือง (ตลาดสด)          │ ← Font Size 1, Center
│    355/115-116 หมู่ 15 ถ. พหลโยธิน     │ ← Font Size 1, Center
│  ต. คูคต อ. ลำลูกกา จ. ปทุมธานี 12130  │ ← Font Size 1, Center
│           โทร. 099-746-2846            │ ← Font Size 1, Center
│                                         │ ← Line wrap
│ พนักงาน: Shop1 Shop1                   │ ← Font Size 1, Left
│ ระบบขายหน้าร้าน: POS 4                 │ ← Font Size 1, Left
│ ─────────────────────────────────────── │
└─────────────────────────────────────────┘
```

## 🎨 Visual Hierarchy

### 1. **Primary (ชื่อร้าน)**
- **Font**: Size 2 (ใหญ่)
- **Position**: Center
- **Content**: "พิชาภพ สินค้าแปรรูป"

### 2. **Secondary (ข้อมูลร้าน)**
- **Font**: Size 1 (ปกติ)
- **Position**: Center
- **Content**: สถานที่, ที่อยู่, โทรศัพท์

### 3. **Tertiary (ข้อมูลระบบ)**
- **Font**: Size 1 (ปกติ)
- **Position**: Left
- **Content**: พนักงาน, ระบบ POS

## 🏪 ข้อมูลร้านค้า

### ชื่อธุรกิจ:
**พิชาภพ สินค้าแปรรูป**

### ที่ตั้ง:
**ตลาดสี่มุมเมือง (ตลาดสด)**

### ที่อยู่เต็ม:
```
355/115-116 หมู่ 15 ถ. พหลโยธิน
ต. คูคต อ. ลำลูกกา จ. ปทุมธานี 12130
```

### ติดต่อ:
**โทร. 099-746-2846**

## 📋 ข้อมูลเพิ่มเติม

### 1. **ประเภทธุรกิจ**
- สินค้าแปรรูป
- ตลาดสด

### 2. **ที่ตั้ง**
- ตลาดสี่มุมเมือง
- จังหวัดปทุมธานี

### 3. **การติดต่อ**
- โทรศัพท์: 099-746-2846

## 🔄 การเปรียบเทียบ

### ข้อมูลเก่า:
```
พิซากพ
เปิด 24 ชั่วโมง
```

### ข้อมูลใหม่:
```
พิชาภพ สินค้าแปรรูป
ตลาดสี่มุมเมือง (ตลาดสด)
355/115-116 หมู่ 15 ถ. พหลโยธิน
ต. คูคต อ. ลำลูกกา จ. ปทุมธานี 12130
โทร. 099-746-2846
```

## ✅ ผลลัพธ์

### 1. **ความถูกต้อง**
- ✅ แสดงชื่อร้านที่ถูกต้อง
- ✅ ที่อยู่ครบถ้วน
- ✅ เบอร์โทรศัพท์ติดต่อได้

### 2. **ความเป็นมืออาชีพ**
- ✅ ข้อมูลครบถ้วนตามมาตรฐาน
- ✅ จัดรูปแบบเป็นระเบียบ
- ✅ ง่ายต่อการอ่าน

### 3. **การใช้งาน**
- ✅ ลูกค้าสามารถติดต่อได้
- ✅ ทราบที่ตั้งร้านค้า
- ✅ ใช้สำหรับการอ้างอิง

### 4. **ความสอดคล้อง**
- ✅ ตรงกับข้อมูลจริงของร้าน
- ✅ เป็นไปตามกฎหมาย
- ✅ รองรับการตรวจสอบ

## 🚀 การพัฒนาต่อ

### ฟีเจอร์ที่สามารถเพิ่มได้:

1. **QR Code**:
   ```dart
   // เพิ่ม QR Code ที่มีข้อมูลร้าน
   await SunmiPrinter.printQRCode('https://maps.google.com/...');
   ```

2. **Logo**:
   ```dart
   // เพิ่มโลโก้ร้าน
   await SunmiPrinter.printBitmap(logoImage);
   ```

3. **Social Media**:
   ```dart
   await SunmiPrinter.printText('Facebook: พิชาภพสินค้าแปรรูป\n');
   await SunmiPrinter.printText('Line: @pichaphop\n');
   ```

4. **Business Hours**:
   ```dart
   await SunmiPrinter.printText('เปิด: 06:00 - 18:00 น.\n');
   await SunmiPrinter.printText('ปิด: วันอาทิตย์\n');
   ```

## 📝 หมายเหตุ

### การใช้งาน:
- ข้อมูลจะแสดงในทุกใบเสร็จที่ปริ๊น
- จัดกลางอัตโนมัติด้วย SunmiPrintAlign.CENTER
- ใช้ขนาดตัวอักษรที่เหมาะสม
- รองรับการแสดงผลภาษาไทย

### การบำรุงรักษา:
- สามารถแก้ไขข้อมูลได้ง่าย
- เปลี่ยนแปลงในไฟล์เดียว
- ไม่ส่งผลกระทบต่อฟังก์ชันอื่น
- รองรับการอัปเดตในอนาคต
