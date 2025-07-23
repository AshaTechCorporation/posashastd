# เพิ่มฟีเจอร์สแกนและจัดการปริ๊นเตอร์

## ภาพรวมฟีเจอร์

เพิ่มฟีเจอร์สแกนหาปริ๊นเตอร์ทุกประเภท (WiFi, LAN, USB, Bluetooth) แสดงรายการปริ๊นเตอร์ที่พบ ทดสอบการเชื่อมต่อ และบันทึกการตั้งค่าปริ๊นเตอร์

## ✅ ฟีเจอร์ที่เพิ่ม

### 1. **PrinterController - จัดการปริ๊นเตอร์**

#### Data Model:
```dart
class PrinterInfo {
  final String name;        // ชื่อปริ๊นเตอร์
  final String address;     // IP Address, MAC Address, หรือ Path
  final String type;        // 'WiFi', 'LAN', 'USB', 'Bluetooth'
  final bool isConnected;   // สถานะการเชื่อมต่อ
  final bool isDefault;     // ปริ๊นเตอร์เริ่มต้น
}
```

#### State Management:
```dart
class PrinterController extends GetxController {
  RxList<PrinterInfo> availablePrinters = <PrinterInfo>[].obs;  // ปริ๊นเตอร์ที่พบ
  RxList<PrinterInfo> savedPrinters = <PrinterInfo>[].obs;      // ปริ๊นเตอร์ที่บันทึกไว้
  RxBool isScanning = false.obs;                                // สถานะการสแกน
  RxString scanStatus = ''.obs;                                 // ข้อความสถานะ
  Rx<PrinterInfo?> selectedPrinter = Rx<PrinterInfo?>(null);   // ปริ๊นเตอร์ที่เลือก
}
```

### 2. **ฟีเจอร์การสแกน**

#### สแกนปริ๊นเตอร์หลายประเภท:
```dart
Future<void> scanForPrinters() async {
  isScanning.value = true;
  availablePrinters.clear();

  // สแกนปริ๊นเตอร์ในเครือข่าย LAN/WiFi
  await _scanNetworkPrinters();
  
  // สแกนปริ๊นเตอร์ USB (สำหรับ Android)
  await _scanUSBPrinters();
  
  // สแกนปริ๊นเตอร์ Bluetooth
  await _scanBluetoothPrinters();

  isScanning.value = false;
}
```

#### ประเภทปริ๊นเตอร์ที่รองรับ:
- **WiFi**: ปริ๊นเตอร์ไร้สายในเครือข่าย
- **LAN**: ปริ๊นเตอร์ที่เชื่อมต่อผ่านสาย Ethernet
- **USB**: ปริ๊นเตอร์ที่เชื่อมต่อผ่าน USB (Android)
- **Bluetooth**: ปริ๊นเตอร์ไร้สายผ่าน Bluetooth

### 3. **การทดสอบการเชื่อมต่อ**

```dart
Future<bool> testPrinterConnection(PrinterInfo printer) async {
  try {
    // จำลองการทดสอบการเชื่อมต่อ
    await Future.delayed(const Duration(seconds: 2));
    
    // ในการใช้งานจริงจะเป็นการเชื่อมต่อจริงกับปริ๊นเตอร์
    final isConnected = /* ผลการทดสอบ */;
    
    if (isConnected) {
      Get.snackbar('เชื่อมต่อสำเร็จ', 'เชื่อมต่อกับ ${printer.name} สำเร็จ');
    } else {
      Get.snackbar('เชื่อมต่อล้มเหลว', 'ไม่สามารถเชื่อมต่อกับ ${printer.name} ได้');
    }
    
    return isConnected;
  } catch (e) {
    Get.snackbar('ข้อผิดพลาด', 'เกิดข้อผิดพลาดในการทดสอบการเชื่อมต่อ');
    return false;
  }
}
```

### 4. **การบันทึกและจัดการปริ๊นเตอร์**

#### บันทึกปริ๊นเตอร์:
```dart
Future<void> savePrinter(PrinterInfo printer) async {
  // ลบปริ๊นเตอร์เดิมถ้ามี
  savedPrinters.removeWhere((p) => p.address == printer.address);
  
  // เพิ่มปริ๊นเตอร์ใหม่
  savedPrinters.add(printer);
  
  // บันทึกลง SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final printersJson = savedPrinters.map((p) => 
    '${p.name}|${p.address}|${p.type}|${p.isDefault}'
  ).toList();
  
  await prefs.setStringList('saved_printers', printersJson);
}
```

#### ตั้งค่าปริ๊นเตอร์เริ่มต้น:
```dart
Future<void> setDefaultPrinter(PrinterInfo printer) async {
  // ลบการตั้งค่าเป็นค่าเริ่มต้นของปริ๊นเตอร์อื่น
  for (int i = 0; i < savedPrinters.length; i++) {
    savedPrinters[i] = PrinterInfo(/* isDefault: false */);
  }
  
  // ตั้งค่าปริ๊นเตอร์ที่เลือกเป็นค่าเริ่มต้น
  savedPrinters[index] = PrinterInfo(/* isDefault: true */);
}
```

## 🎨 UI Design

### 1. **หน้าหลัก - รายการปริ๊นเตอร์ที่บันทึกไว้**

```dart
Widget _printerTab() {
  return Obx(() => Column(
    children: [
      // Header พร้อมปุ่มสแกน
      Container(
        child: Row(
          children: [
            Text('ปริ๊นเตอร์ที่บันทึกไว้ (${printerController.savedPrinters.length})'),
            ElevatedButton.icon(
              onPressed: () => _showScanDialog(),
              icon: Icon(Icons.search),
              label: Text('สแกนปริ๊นเตอร์'),
            ),
          ],
        ),
      ),
      
      // รายการปริ๊นเตอร์
      Expanded(
        child: ListView.builder(
          itemCount: printerController.savedPrinters.length,
          itemBuilder: (context, index) {
            final printer = printerController.savedPrinters[index];
            return _buildPrinterTile(printer, true);
          },
        ),
      ),
    ],
  ));
}
```

### 2. **Dialog สแกนปริ๊นเตอร์**

```dart
void _showScanDialog() {
  Get.dialog(
    AlertDialog(
      title: Text('สแกนหาปริ๊นเตอร์'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          children: [
            // Status แสดงสถานะการสแกน
            Container(/* Status UI */),
            
            // รายการปริ๊นเตอร์ที่พบ
            Expanded(
              child: ListView.builder(
                itemCount: printerController.availablePrinters.length,
                itemBuilder: (context, index) {
                  final printer = printerController.availablePrinters[index];
                  return _buildPrinterTile(printer, false);
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton('ปิด'),
        ElevatedButton('เริ่มสแกน'),
      ],
    ),
  );
}
```

### 3. **Printer Tile - แสดงข้อมูลปริ๊นเตอร์**

```dart
Widget _buildPrinterTile(PrinterInfo printer, bool isSaved) {
  return Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: _getPrinterTypeColor(printer.type),
        child: Icon(_getPrinterTypeIcon(printer.type)),
      ),
      title: Text(printer.name),
      subtitle: Column(
        children: [
          Text('${printer.type} • ${printer.address}'),
          if (printer.isDefault)
            Container(/* Default badge */),
        ],
      ),
      trailing: isSaved 
        ? _buildSavedPrinterActions(printer)    // เมนูสำหรับปริ๊นเตอร์ที่บันทึกไว้
        : _buildAvailablePrinterActions(printer), // ปุ่มเพิ่มสำหรับปริ๊นเตอร์ที่พบ
    ),
  );
}
```

## 🔧 การทำงานของระบบ

### 1. **Flow การสแกนปริ๊นเตอร์**

```
User กดปุ่ม "สแกนปริ๊นเตอร์"
         ↓
แสดง Scan Dialog
         ↓
User กดปุ่ม "เริ่มสแกน"
         ↓
scanForPrinters() เริ่มทำงาน
         ↓
สแกนปริ๊นเตอร์แต่ละประเภทตามลำดับ:
  1. Network Printers (WiFi/LAN)
  2. USB Printers
  3. Bluetooth Printers
         ↓
แสดงรายการปริ๊นเตอร์ที่พบ
         ↓
User เลือกปริ๊นเตอร์และกด "เพิ่ม"
         ↓
ทดสอบการเชื่อมต่อ
         ↓
หากเชื่อมต่อสำเร็จ → บันทึกปริ๊นเตอร์
```

### 2. **Flow การจัดการปริ๊นเตอร์**

```
User เลือกปริ๊นเตอร์ที่บันทึกไว้
         ↓
กดเมนู (⋮)
         ↓
เลือกการกระทำ:
  - ทดสอบการเชื่อมต่อ
  - ตั้งเป็นค่าเริ่มต้น
  - ลบ
         ↓
ดำเนินการตามที่เลือก
         ↓
อัพเดท UI และบันทึกการเปลี่ยนแปลง
```

## 📱 User Experience

### 1. **Visual Indicators**

#### ประเภทปริ๊นเตอร์:
- **WiFi**: ไอคอน WiFi สีน้ำเงิน
- **LAN**: ไอคอน LAN สีเขียว
- **USB**: ไอคอน USB สีส้ม
- **Bluetooth**: ไอคอน Bluetooth สีม่วง

#### สถานะ:
- **กำลังสแกน**: Loading indicator + ข้อความสถานะ
- **ปริ๊นเตอร์เริ่มต้น**: Badge สีเขียว "ค่าเริ่มต้น"
- **การเชื่อมต่อ**: Snackbar แสดงผลสำเร็จ/ล้มเหลว

### 2. **Interactive Elements**

#### ปุ่มและการกระทำ:
- **สแกนปริ๊นเตอร์**: ปุ่มหลักสำหรับเริ่มสแกน
- **เพิ่ม**: เพิ่มปริ๊นเตอร์ที่พบลงในรายการ
- **เมนู**: ทดสอบ, ตั้งเป็นค่าเริ่มต้น, ลบ
- **ยืนยันการลบ**: Dialog ป้องกันการลบโดยไม่ตั้งใจ

### 3. **Feedback และ Notifications**

```dart
// การแจ้งเตือนต่างๆ
Get.snackbar('เชื่อมต่อสำเร็จ', 'เชื่อมต่อกับ HP LaserJet สำเร็จ');
Get.snackbar('บันทึกสำเร็จ', 'บันทึกปริ๊นเตอร์ Canon PIXMA แล้ว');
Get.snackbar('ตั้งค่าสำเร็จ', 'ตั้งค่า Epson L3150 เป็นปริ๊นเตอร์เริ่มต้นแล้ว');
```

## 🔍 การพัฒนาต่อ

### ฟีเจอร์ที่สามารถเพิ่มได้:

1. **การเชื่อมต่อจริง**:
   - ใช้ library สำหรับเชื่อมต่อปริ๊นเตอร์จริง
   - รองรับ ESC/POS commands
   - รองรับการพิมพ์ทดสอบ

2. **การสแกนขั้นสูง**:
   - Auto-discovery ด้วย mDNS/Bonjour
   - Network scanning ด้วย IP range
   - Bluetooth pairing

3. **การจัดการขั้นสูง**:
   - Printer profiles และ settings
   - Print queue management
   - Error handling และ diagnostics

4. **Integration**:
   - เชื่อมต่อกับระบบพิมพ์ใบเสร็จ
   - รองรับ multiple paper sizes
   - Template management

## 📝 หมายเหตุ

### การใช้งานจริง:
- ปัจจุบันเป็นการจำลองการทำงาน (mock data)
- ต้องเพิ่ม dependencies สำหรับการเชื่อมต่อจริง
- ต้องขออนุญาต permissions สำหรับ Bluetooth และ Network

### Dependencies ที่แนะนำ:
```yaml
dependencies:
  # สำหรับ network discovery
  network_info_plus: ^4.0.0
  ping_discover_network: ^2.0.0
  
  # สำหรับ Bluetooth
  flutter_bluetooth_serial: ^0.4.0
  
  # สำหรับ USB (Android)
  usb_serial: ^0.4.0
  
  # สำหรับการพิมพ์
  esc_pos_utils: ^1.1.0
  esc_pos_printer: ^4.0.0
```

### Permissions ที่ต้องการ:
```xml
<!-- Android -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```
