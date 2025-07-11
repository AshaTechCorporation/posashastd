# ระบบปิดกะและออกจากระบบ

## ภาพรวมการเปลี่ยนแปลง

ได้เพิ่มฟังก์ชันปิดกะในหน้า SummaryReportPage และฟังก์ชันออกจากระบบในหน้า SettingsPage พร้อมการเคลียร์ข้อมูลทั้งหมดและการนำทางกลับไปหน้า Login

## ✅ การปรับปรุงหลัก

### 1. **HomeController - Close Shift Function**

#### ฟังก์ชันปิดกะ:
```dart
Future<bool> closeShift() async {
  try {
    if (currentShiftId.value.isEmpty) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่พบข้อมูลกะที่จะปิด');
      return false;
    }

    final shiftId = int.tryParse(currentShiftId.value);
    if (shiftId == null) {
      log('❌ Invalid shift ID format');
      return false;
    }

    final response = await Homeservice.closedShift(shiftId: shiftId);
    
    if (response != null) {
      // ลบ shift_id จาก SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('shift_id');
      
      currentShiftId.value = '';
      isShiftOpen.value = false;
      
      // เคลียร์ข้อมูลที่โหลดไว้
      products.clear();
      categories.clear();
      cartItems.clear();
      selectedCategoryCode.value = '';
      
      return true;
    }
    return false;
  } catch (e) {
    Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถปิดกะได้: ${e.toString()}');
    return false;
  }
}
```

### 2. **SummaryReportPage - Close Shift UI**

#### Dialog ยืนยันการปิดกะ:
```dart
void _showCloseShiftDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.lock, color: Colors.red),
          SizedBox(width: 8),
          Text('ยืนยันการปิดกะ'),
        ],
      ),
      content: const Text(
        'คุณต้องการปิดกะหรือไม่?\nเมื่อปิดกะแล้วจะไม่สามารถทำรายการได้จนกว่าจะเปิดกะใหม่',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await _closeShift(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('ปิดกะ', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
```

#### ฟังก์ชันปิดกะและแสดงผลลัพธ์:
```dart
Future<void> _closeShift(BuildContext context) async {
  final homeController = Get.find<HomeController>();
  
  // แสดง loading
  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );

  final success = await homeController.closeShift();
  Get.back(); // ปิด loading

  if (success) {
    // แสดง Dialog สำเร็จ
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('ปิดกะสำเร็จ'),
          ],
        ),
        content: const Text(
          'ปิดกะเรียบร้อยแล้ว\nระบบจะกลับไปหน้าหลัก',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.offAllNamed('/home'); // กลับไปหน้าหลัก
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('ตกลง', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
```

### 3. **AuthService - Logout Function**

#### ฟังก์ชันออกจากระบบ:
```dart
/// ออกจากระบบ
Future<void> logout() async {
  try {
    // เคลียร์ข้อมูลจาก SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // เคลียร์ token ในหน่วยความจำ
    _currentToken = null;
  } catch (e) {
    throw Exception('ไม่สามารถออกจากระบบได้: ${e.toString()}');
  }
}
```

### 4. **SettingsPage - Logout UI**

#### Dialog ยืนยันการออกจากระบบ:
```dart
Future<void> _logout() async {
  // แสดง Dialog ยืนยัน
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.logout, color: Colors.red),
          SizedBox(width: 8),
          Text('ออกจากระบบ'),
        ],
      ),
      content: const Text(
        'คุณต้องการออกจากระบบหรือไม่?\nข้อมูลทั้งหมดจะถูกลบออกจากเครื่อง',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('ออกจากระบบ', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  if (confirm == true) {
    // แสดง loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // ออกจากระบบผ่าน AuthService
      final authService = AuthService();
      await authService.logout();

      Get.back(); // ปิด loading

      // กลับไปหน้า Login และปิดหน้าทั้งหมด
      Get.offAllNamed('/login');

      // แสดงข้อความสำเร็จ
      Get.snackbar(
        'ออกจากระบบสำเร็จ',
        'กรุณาเข้าสู่ระบบใหม่',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // ปิด loading
      Get.snackbar(
        'ข้อผิดพลาด',
        'ไม่สามารถออกจากระบบได้: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
```

## 🎯 ฟีเจอร์ที่ได้รับ

### 1. **Close Shift System**
- ปุ่มปิดกะในหน้า SummaryReportPage
- Dialog ยืนยันการปิดกะ
- เรียก API closedShift
- ลบ shift_id จาก SharedPreferences
- เคลียร์ข้อมูลในแอป
- แสดง Dialog สำเร็จ
- นำทางกลับหน้าหลัก

### 2. **Logout System**
- ปุ่มออกจากระบบในหน้า SettingsPage
- Dialog ยืนยันการออกจากระบบ
- เคลียร์ข้อมูลทั้งหมดจาก SharedPreferences
- เคลียร์ currentToken
- ปิดหน้าทั้งหมดและกลับไปหน้า Login
- แสดงข้อความสำเร็จ

### 3. **Data Management**
- เคลียร์ข้อมูลอย่างสมบูรณ์
- จัดการสถานะแอปอย่างถูกต้อง
- ป้องกันการใช้งานหลังปิดกะ
- รีเซ็ตแอปกลับสู่สถานะเริ่มต้น

### 4. **User Experience**
- Dialog ยืนยันที่ชัดเจน
- Loading indicator ระหว่างดำเนินการ
- ข้อความแจ้งผลลัพธ์
- การนำทางที่เหมาะสม

## 📱 การใช้งาน

### สำหรับผู้ใช้:

#### การปิดกะ:
1. **เข้าหน้า SummaryReportPage**
2. **กดปุ่ม "ปิดกะ"**: แสดง Dialog ยืนยัน
3. **ยืนยันการปิดกะ**: แสดง loading
4. **รอผลลัพธ์**: แสดง Dialog สำเร็จ
5. **กดตกลง**: กลับไปหน้าหลัก (กะปิดแล้ว)

#### การออกจากระบบ:
1. **เข้าหน้า SettingsPage**
2. **กดปุ่ม "ออกจากระบบ"**: แสดง Dialog ยืนยัน
3. **ยืนยันการออกจากระบบ**: แสดง loading
4. **รอผลลัพธ์**: เคลียร์ข้อมูลและกลับหน้า Login
5. **แสดงข้อความสำเร็จ**: พร้อมใช้งานใหม่

### การทำงานของระบบ:

#### Close Shift Flow:
```
User taps "ปิดกะ" button
         ↓
Show confirmation dialog
         ↓
User confirms
         ↓
Show loading
         ↓
Call homeController.closeShift()
         ↓
Call API closedShift
         ↓
Remove shift_id from SharedPreferences
         ↓
Clear app data
         ↓
Show success dialog
         ↓
Navigate to home (shift closed state)
```

#### Logout Flow:
```
User taps "ออกจากระบบ" button
         ↓
Show confirmation dialog
         ↓
User confirms
         ↓
Show loading
         ↓
Call authService.logout()
         ↓
Clear all SharedPreferences
         ↓
Clear currentToken
         ↓
Navigate to login (clear all pages)
         ↓
Show success message
```

## 🔧 Technical Details

### API Integration:
```dart
// Close Shift API
static Future closedShift({required int shiftId}) async {
  final url = Uri.https(publicUrl, '/api/shift/$shiftId/off');
  final response = await http.post(url, headers: headers);
  // Handle response...
}
```

### Data Clearing:
```dart
// SharedPreferences
final prefs = await SharedPreferences.getInstance();
await prefs.clear(); // ลบข้อมูลทั้งหมด
await prefs.remove('shift_id'); // ลบเฉพาะ shift_id

// App State
products.clear();
categories.clear();
cartItems.clear();
selectedCategoryCode.value = '';
_currentToken = null;
```

### Navigation:
```dart
// กลับหน้าหลัก
Get.offAllNamed('/home');

// กลับหน้า Login และปิดหน้าทั้งหมด
Get.offAllNamed('/login');
```

## ✅ สรุป

การปรับปรุงนี้ทำให้:
- **ปิดกะได้อย่างสมบูรณ์**: เรียก API และเคลียร์ข้อมูล
- **ออกจากระบบได้อย่างปลอดภัย**: เคลียร์ข้อมูลทั้งหมด
- **UX ที่ดี**: Dialog ยืนยันและข้อความแจ้งผลลัพธ์
- **Data Integrity**: จัดการข้อมูลอย่างถูกต้อง

## 🚀 การพัฒนาต่อ

### ฟีเจอร์ที่สามารถเพิ่มได้:
1. **Shift Summary**: แสดงสรุปยอดขายก่อนปิดกะ
2. **Auto Logout**: ออกจากระบบอัตโนมัติเมื่อ token หมดอายุ
3. **Backup Data**: สำรองข้อมูลก่อนเคลียร์
4. **Logout History**: บันทึกประวัติการออกจากระบบ
5. **Remote Logout**: ออกจากระบบจากเครื่องอื่น

### การปรับปรุงเพิ่มเติม:
- เพิ่มการยืนยันด้วยรหัสผ่านก่อนปิดกะ
- เพิ่มการส่งรายงานอีเมลเมื่อปิดกะ
- เพิ่มการแจ้งเตือนก่อนออกจากระบบ
- เพิ่มการซิงค์ข้อมูลก่อนเคลียร์
