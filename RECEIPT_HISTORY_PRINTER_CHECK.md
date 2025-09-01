# ✅ เพิ่มการตรวจสอบปริ๊นเตอร์ในหน้า Receipt History

## ฟีเจอร์ที่เพิ่ม

**เพิ่มการตรวจสอบการเชื่อมต่อปริ๊นเตอร์และปริ๊นเตอร์เริ่มต้นก่อนปริ๊นใบเสร็จในหน้า receiptHistoryPage**

## การตรวจสอบที่เพิ่ม

### 1. **ตรวจสอบปริ๊นเตอร์เริ่มต้น**
- ตรวจสอบว่ามีปริ๊นเตอร์ที่ถูกตั้งเป็นเริ่มต้นหรือไม่
- แสดงข้อความแจ้งเตือนถ้าไม่มีปริ๊นเตอร์เริ่มต้น

### 2. **ตรวจสอบการเชื่อมต่อ**
- ทดสอบการเชื่อมต่อกับปริ๊นเตอร์เริ่มต้น
- แสดง dialog ยืนยันถ้าไม่สามารถเชื่อมต่อได้

### 3. **Dialog ตัวเลือก**
- ให้ผู้ใช้เลือกว่าจะปริ๊นต่อหรือยกเลิก
- มีตัวเลือกทดสอบการเชื่อมต่อใหม่

## การทำงาน

### Flow การตรวจสอบ:
```
1. กดปุ่มปริ๊น
2. ตรวจสอบปริ๊นเตอร์เริ่มต้น
   ├─ ไม่มี → แสดงข้อความแจ้งเตือน → จบ
   └─ มี → ไปขั้นตอนต่อไป
3. ทดสอบการเชื่อมต่อ
   ├─ เชื่อมต่อได้ → ปริ๊นทันที
   └─ เชื่อมต่อไม่ได้ → แสดง dialog ตัวเลือก
4. Dialog ตัวเลือก:
   ├─ ยกเลิก → จบ
   ├─ ทดสอบใหม่ → กลับไปขั้นตอน 3
   └─ ปริ๊นต่อ → ปริ๊นแม้ไม่เชื่อมต่อ
```

## โค้ดที่เพิ่ม

### 1. การตรวจสอบปริ๊นเตอร์เริ่มต้น:
```dart
// ตรวจสอบว่ามีปริ๊นเตอร์เริ่มต้นหรือไม่
final printerController = Get.find<PrinterController>();
final defaultPrinter = printerController.getDefaultPrinter();

if (defaultPrinter == null) {
  Get.snackbar(
    'ไม่มีปริ๊นเตอร์',
    'กรุณาตั้งค่าปริ๊นเตอร์เริ่มต้นก่อนใช้งาน',
    backgroundColor: Colors.orange,
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
  );
  return;
}
```

### 2. การทดสอบการเชื่อมต่อ:
```dart
// ตรวจสอบการเชื่อมต่อปริ๊นเตอร์
log('🔍 Checking printer connection: ${defaultPrinter.name}');
final isConnected = await printerController.testPrinterConnection(
  defaultPrinter, 
  showSnackbar: false
);

if (!isConnected) {
  // แสดง dialog ยืนยันการปริ๊นแม้ปริ๊นเตอร์ไม่เชื่อมต่อ
  final shouldPrint = await _showPrinterConnectionDialog(defaultPrinter);
  if (!shouldPrint) {
    return;
  }
}
```

### 3. Dialog ตัวเลือก:
```dart
Future<bool> _showPrinterConnectionDialog(dynamic printer) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: Row(children: const [
        Icon(Icons.warning, color: Colors.orange),
        SizedBox(width: 8),
        Text('ปริ๊นเตอร์ไม่เชื่อมต่อ'),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ไม่สามารถเชื่อมต่อกับปริ๊นเตอร์ได้:'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ชื่อ: ${printer.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('ประเภท: ${printer.type}'),
                Text('ที่อยู่: ${printer.address}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('คุณต้องการลองปริ๊นต่อหรือไม่?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('ยกเลิก'),
        ),
        TextButton(
          onPressed: () async {
            // ทดสอบการเชื่อมต่อใหม่
            // ... โค้ดทดสอบ
          },
          child: const Text('ทดสอบใหม่'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('ปริ๊นต่อ', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  
  return result ?? false;
}
```

## ตัวอย่างการใช้งาน

### Scenario 1: ไม่มีปริ๊นเตอร์เริ่มต้น
```
1. กดปุ่มปริ๊น
2. ระบบตรวจสอบ → ไม่มีปริ๊นเตอร์เริ่มต้น
3. แสดงข้อความ: "กรุณาตั้งค่าปริ๊นเตอร์เริ่มต้นก่อนใช้งาน"
4. จบการทำงาน
```

### Scenario 2: ปริ๊นเตอร์เชื่อมต่อได้
```
1. กดปุ่มปริ๊น
2. ระบบตรวจสอบ → มีปริ๊นเตอร์เริ่มต้น
3. ทดสอบการเชื่อมต่อ → เชื่อมต่อได้
4. ปริ๊นใบเสร็จทันที
5. แสดงข้อความ: "ปริ๊นใบเสร็จ #12345 เรียบร้อยแล้ว"
```

### Scenario 3: ปริ๊นเตอร์เชื่อมต่อไม่ได้
```
1. กดปุ่มปริ๊น
2. ระบบตรวจสอบ → มีปริ๊นเตอร์เริ่มต้น
3. ทดสอบการเชื่อมต่อ → เชื่อมต่อไม่ได้
4. แสดง dialog:
   ┌─────────────────────────────────┐
   │ ⚠️ ปริ๊นเตอร์ไม่เชื่อมต่อ        │
   ├─────────────────────────────────┤
   │ ไม่สามารถเชื่อมต่อกับปริ๊นเตอร์ได้: │
   │                                 │
   │ ชื่อ: Thermal Printer WiFi      │
   │ ประเภท: WiFi                    │
   │ ที่อยู่: 192.168.1.100          │
   │                                 │
   │ คุณต้องการลองปริ๊นต่อหรือไม่?      │
   │                                 │
   │ [ยกเลิก] [ทดสอบใหม่] [ปริ๊นต่อ]  │
   └─────────────────────────────────┘
5. ผู้ใช้เลือก:
   - ยกเลิก → จบการทำงาน
   - ทดสอบใหม่ → ทดสอบการเชื่อมต่อใหม่
   - ปริ๊นต่อ → ปริ๊นแม้ไม่เชื่อมต่อ
```

### Scenario 4: ทดสอบการเชื่อมต่อใหม่
```
1. ในขั้นตอน dialog → กด "ทดสอบใหม่"
2. แสดง loading: "กำลังทดสอบการเชื่อมต่อ..."
3. ทดสอบการเชื่อมต่อ
4. ผลลัพธ์:
   - เชื่อมต่อได้ → แสดง "เชื่อมต่อสำเร็จ" → ปริ๊นทันที
   - เชื่อมต่อไม่ได้ → แสดง "ยังไม่สามารถเชื่อมต่อได้" → แสดง dialog อีกครั้ง
```

## ข้อดีของการตรวจสอบ

### 1. **ความปลอดภัย**
- ✅ ป้องกันการปริ๊นเมื่อไม่มีปริ๊นเตอร์
- ✅ แจ้งเตือนปัญหาการเชื่อมต่อล่วงหน้า
- ✅ ให้ผู้ใช้ตัดสินใจเอง

### 2. **ประสบการณ์ผู้ใช้**
- ✅ ข้อความแจ้งเตือนที่ชัดเจน
- ✅ ตัวเลือกที่หลากหลาย
- ✅ สามารถทดสอบการเชื่อมต่อใหม่ได้

### 3. **ความยืดหยุ่น**
- ✅ สามารถปริ๊นต่อแม้ไม่เชื่อมต่อ (สำหรับกรณีพิเศษ)
- ✅ ทดสอบการเชื่อมต่อได้หลายครั้ง
- ✅ ยกเลิกได้ตลอดเวลา

## การจัดการข้อผิดพลาด

### 1. **ไม่มี PrinterController**
```dart
try {
  final printerController = Get.find<PrinterController>();
} catch (e) {
  Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถเข้าถึงระบบปริ๊นเตอร์ได้');
  return;
}
```

### 2. **การทดสอบการเชื่อมต่อล้มเหลว**
```dart
try {
  final isConnected = await printerController.testPrinterConnection(defaultPrinter);
} catch (e) {
  log('❌ Error testing printer connection: $e');
  // ถือว่าไม่เชื่อมต่อและแสดง dialog
  final shouldPrint = await _showPrinterConnectionDialog(defaultPrinter);
}
```

### 3. **Dialog ถูกปิดโดยไม่เลือก**
```dart
final result = await Get.dialog<bool>(...);
return result ?? false; // ถ้าไม่ได้เลือกให้ถือว่า false
```

## การทดสอบ

### ทดสอบการตรวจสอบ:
1. **ไม่มีปริ๊นเตอร์เริ่มต้น** → แสดงข้อความแจ้งเตือน
2. **มีปริ๊นเตอร์และเชื่อมต่อได้** → ปริ๊นทันที
3. **มีปริ๊นเตอร์แต่เชื่อมต่อไม่ได้** → แสดง dialog

### ทดสอบ Dialog:
1. **กดยกเลิก** → ไม่ปริ๊น
2. **กดปริ๊นต่อ** → ปริ๊นแม้ไม่เชื่อมต่อ
3. **กดทดสอบใหม่** → ทดสอบการเชื่อมต่อใหม่

### ทดสอบการทดสอบใหม่:
1. **ทดสอบสำเร็จ** → ปริ๊นทันที
2. **ทดสอบล้มเหลว** → แสดง dialog อีกครั้ง

## สรุป

✅ **การตรวจสอบปริ๊นเตอร์ในหน้า Receipt History เสร็จสิ้น**

### ฟีเจอร์หลัก:
- **ตรวจสอบปริ๊นเตอร์เริ่มต้น**
- **ทดสอบการเชื่อมต่อก่อนปริ๊น**
- **Dialog ตัวเลือกเมื่อไม่เชื่อมต่อ**
- **ทดสอบการเชื่อมต่อใหม่ได้**

### ประโยชน์:
- **ป้องกันการปริ๊นเมื่อไม่พร้อม**
- **แจ้งเตือนปัญหาล่วงหน้า**
- **ให้ตัวเลือกที่ยืดหยุ่น**
- **ประสบการณ์ผู้ใช้ที่ดี**

### การทำงาน:
```
ตรวจสอบปริ๊นเตอร์ → ทดสอบการเชื่อมต่อ → แสดง dialog (ถ้าจำเป็น) → ปริ๊น
```

**🎊 ตอนนี้หน้า Receipt History จะตรวจสอบปริ๊นเตอร์และการเชื่อมต่อก่อนปริ๊นทุกครั้ง เพื่อให้แน่ใจว่าการปริ๊นจะสำเร็จ!**
