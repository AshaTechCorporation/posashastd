# ระบบจัดการกะงาน (Shift Management System)

## ภาพรวมการเปลี่ยนแปลง

ได้เพิ่มระบบจัดการกะงานในหน้า HomePage โดยเช็ค shift_id จาก SharedPreferences และแสดง UI เปิดกะเมื่อยังไม่ได้เปิดกะ พร้อมปิดการใช้งานฟีเจอร์ต่างๆ จนกว่าจะเปิดกะ

## ✅ การปรับปรุงหลัก

### 1. **HomeController - Shift Management**

#### เพิ่มตัวแปรจัดการ shift:
```dart
class HomeController extends GetxController {
  // ตัวแปรเดิม...
  
  // ✅ ตัวแปรใหม่สำหรับจัดการ shift
  RxBool isShiftOpen = false.obs;
  RxString currentShiftId = ''.obs;
}
```

#### ฟังก์ชันเช็คสถานะ shift:
```dart
Future<void> checkShiftStatus() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final shiftId = prefs.getString('shift_id');
    
    if (shiftId != null && shiftId.isNotEmpty) {
      log('✅ Found shift_id: $shiftId');
      currentShiftId.value = shiftId;
      isShiftOpen.value = true;
      // โหลดข้อมูลเมื่อมี shift
      await checkConnectivityAndLoadData();
    } else {
      log('❌ No shift_id found - shift is closed');
      isShiftOpen.value = false;
    }
  } catch (e) {
    log('❌ Error checking shift status: $e');
    isShiftOpen.value = false;
  }
}
```

#### ฟังก์ชันเปิดกะ:
```dart
Future<bool> openShift({
  required double change,
  required double cash,
  required String remark,
}) async {
  try {
    final shiftData = {
      "deviceId": 1,
      "change": change,
      "cash": cash,
      "remark": remark,
    };
    
    final response = await Homeservice.openShift(formattedShift: shiftData);
    
    if (response != null && response['id'] != null) {
      final shiftId = response['id'].toString();
      
      // บันทึก shift_id ลง SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('shift_id', shiftId);
      
      currentShiftId.value = shiftId;
      isShiftOpen.value = true;
      
      // โหลดข้อมูลหลังเปิดกะ
      await checkConnectivityAndLoadData();
      
      return true;
    }
    return false;
  } catch (e) {
    Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถเปิดกะได้: ${e.toString()}');
    return false;
  }
}
```

### 2. **HomePage - UI Conditional Rendering**

#### UI เมื่อกะปิดอยู่:
```dart
Widget _buildShiftClosedUI() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.access_time, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'กะปิดอยู่ กรุณาเปิดกะ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _showOpenShiftDialog,
          icon: const Icon(Icons.play_arrow, color: Colors.white),
          label: const Text('เปิดกะ'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    ),
  );
}
```

#### Dialog เปิดกะ:
```dart
void _showOpenShiftDialog() {
  final changeController = TextEditingController();
  final cashController = TextEditingController();
  final remarkController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.access_time, color: Colors.green),
          SizedBox(width: 8),
          Text('เปิดกะ'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: changeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'จำนวนเงินทอน',
              hintText: 'เช่น 100',
              prefixIcon: Icon(Icons.money),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: cashController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'ยอดยกมา',
              hintText: 'เช่น 1000',
              prefixIcon: Icon(Icons.account_balance_wallet),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: remarkController,
            decoration: const InputDecoration(
              labelText: 'หมายเหตุ',
              hintText: 'เช่น เปิดกะเช้า',
              prefixIcon: Icon(Icons.note),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: () async {
            // ตรวจสอบข้อมูลและเรียก openShift
            final success = await homeController.openShift(
              change: double.tryParse(changeController.text) ?? 0,
              cash: double.tryParse(cashController.text) ?? 0,
              remark: remarkController.text.trim(),
            );
            
            if (success) {
              Get.snackbar('สำเร็จ', 'เปิดกะเรียบร้อยแล้ว');
            }
          },
          child: const Text('ตกลง'),
        ),
      ],
    ),
  );
}
```

### 3. **Conditional UI Controls**

#### GridView แบบมีเงื่อนไข:
```dart
Expanded(
  child: Obx(() {
    // ถ้ากะปิดอยู่ แสดง UI เปิดกะ
    if (!homeController.isShiftOpen.value) {
      return _buildShiftClosedUI();
    }
    
    // ถ้ากะเปิดแล้ว แสดง GridView ปกติ
    return AnimatedBuilder(
      animation: _tabController, 
      builder: (_, __) => _buildGridContent(width, height)
    );
  }),
),
```

#### TabBar ปิดการใช้งานเมื่อกะปิด:
```dart
TabBar(
  controller: _tabController,
  tabs: List.generate(
    tabs.length,
    (index) => GestureDetector(
      onLongPress: homeController.isShiftOpen.value ? () => _removeTab(index) : null,
      child: Tab(text: tabs[index]),
    ),
  ),
  labelColor: homeController.isShiftOpen.value ? Colors.green : Colors.grey,
  unselectedLabelColor: homeController.isShiftOpen.value ? Colors.black54 : Colors.grey,
  indicatorColor: homeController.isShiftOpen.value ? Colors.green : Colors.grey,
  onTap: homeController.isShiftOpen.value ? null : (index) {
    // ป้องกันการเปลี่ยนแท็บเมื่อกะปิด
  },
),
```

#### Dropdown ปิดการใช้งานเมื่อกะปิด:
```dart
DropdownButton<String>(
  onChanged: homeController.isShiftOpen.value ? (value) async {
    // ทำงานปกติเมื่อกะเปิด
    if (value != null) {
      homeController.selectedCategoryCode.value = value;
      // โหลดสินค้าตามหมวดหมู่
    }
  } : null, // ปิดการใช้งานเมื่อกะปิด
  // ... other properties
),
```

## 🎯 ฟีเจอร์ที่ได้รับ

### 1. **Automatic Shift Detection**
- เช็ค shift_id จาก SharedPreferences เมื่อเข้าแอป
- แสดงสถานะกะเปิด/ปิดแบบ real-time
- โหลดข้อมูลอัตโนมัติเมื่อมี shift

### 2. **Shift Opening System**
- Dialog เปิดกะพร้อมฟอร์มกรอกข้อมูล
- ส่งข้อมูลไป API openShift
- บันทึก shift_id ลง SharedPreferences
- แสดงข้อความสำเร็จ/ผิดพลาด

### 3. **UI State Management**
- แสดง UI เปิดกะเมื่อกะปิด
- ปิดการใช้งาน TabBar เมื่อกะปิด
- ปิดการใช้งาน Dropdown เมื่อกะปิด
- ป้องกันการกดแท็บและพาเนลเมื่อกะปิด

### 4. **Data Flow Control**
- ไม่โหลดข้อมูลสินค้าเมื่อกะปิด
- โหลดข้อมูลอัตโนมัติหลังเปิดกะ
- จัดการสถานะแบบ reactive

## 📱 การใช้งาน

### สำหรับผู้ใช้:

#### เมื่อกะปิด:
1. **เข้าแอป**: แสดงหน้าจอ "กะปิดอยู่ กรุณาเปิดกะ"
2. **ไม่สามารถใช้งาน**: TabBar, Dropdown, การกดสินค้า
3. **กดปุ่มเปิดกะ**: แสดง Dialog กรอกข้อมูล

#### การเปิดกะ:
1. **กรอกข้อมูล**:
   - จำนวนเงินทอน (change)
   - ยอดยกมา (cash)
   - หมายเหตุ (remark) - บังคับกรอก
2. **กดตกลง**: ส่งข้อมูลไป API
3. **รอผลลัพธ์**: แสดง loading และข้อความผลลัพธ์

#### เมื่อกะเปิดแล้ว:
1. **ใช้งานปกติ**: TabBar, Dropdown, การกดสินค้าทำงานได้
2. **โหลดข้อมูล**: สินค้า, หมวดหมู่, พาเนลโหลดอัตโนมัติ
3. **บันทึก shift_id**: เก็บไว้ใน SharedPreferences

### การทำงานของระบบ:

#### Startup Flow:
```
App starts
    ↓
HomeController.onInit()
    ↓
checkShiftStatus()
    ↓
Check SharedPreferences for 'shift_id'
    ↓
If found: isShiftOpen = true, load data
If not found: isShiftOpen = false, show open shift UI
```

#### Open Shift Flow:
```
User taps "เปิดกะ"
    ↓
Show dialog with form
    ↓
User fills data and taps "ตกลง"
    ↓
Call homeController.openShift()
    ↓
Send data to API
    ↓
Save shift_id to SharedPreferences
    ↓
Set isShiftOpen = true
    ↓
Load data and show success message
```

## 🔧 Technical Details

### API Request Format:
```json
{
  "deviceId": 1,
  "change": 110,
  "cash": 110,
  "remark": "string"
}
```

### SharedPreferences Storage:
```dart
// บันทึก
final prefs = await SharedPreferences.getInstance();
await prefs.setString('shift_id', shiftId);

// อ่าน
final shiftId = prefs.getString('shift_id');
```

### State Management:
```dart
// Reactive variables
RxBool isShiftOpen = false.obs;
RxString currentShiftId = ''.obs;

// UI updates automatically with Obx()
Obx(() {
  if (!homeController.isShiftOpen.value) {
    return _buildShiftClosedUI();
  }
  return normalUI();
})
```

## ✅ สรุป

การปรับปรุงนี้ทำให้:
- **ความปลอดภัย**: ป้องกันการใช้งานก่อนเปิดกะ
- **การจัดการ**: ระบบเปิดกะที่สมบูรณ์
- **UX ที่ดี**: UI ชัดเจนและใช้งานง่าย
- **Data Integrity**: ควบคุมการโหลดข้อมูลตามสถานะกะ

## 🚀 การพัฒนาต่อ

### ฟีเจอร์ที่สามารถเพิ่มได้:
1. **Close Shift**: ระบบปิดกะ
2. **Shift History**: ประวัติการเปิด/ปิดกะ
3. **Multiple Devices**: จัดการกะหลายเครื่อง
4. **Shift Reports**: รายงานยอดขายในกะ
5. **Auto Close**: ปิดกะอัตโนมัติตามเวลา

### การปรับปรุงเพิ่มเติม:
- เพิ่มการตรวจสอบสิทธิ์การเปิดกะ
- เพิ่มการแจ้งเตือนเมื่อใกล้หมดกะ
- เพิ่มการ backup ข้อมูลก่อนปิดกะ
- เพิ่มการซิงค์สถานะกะระหว่างเครื่อง
