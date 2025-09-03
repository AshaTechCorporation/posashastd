# ✅ แก้ไข SettingsV2s ให้มีการออกจากระบบเหมือน SettingsPage

## การแก้ไขที่ทำ

**แก้ไข SettingsV2s ให้มีฟังก์ชันการออกจากระบบเหมือนกับ SettingsPage ทุกประการ**

## ปัญหาเดิม

### SettingsV2s เดิม:
```dart
class SettingsV2s extends StatelessWidget {
  // ...
  child: ElevatedButton(
    onPressed: () {},  // ❌ ไม่มีฟังก์ชันการทำงาน
    child: const Text('ออกจากระบบ'),
  ),
}
```

### ปัญหา:
- ✅ ปุ่มออกจากระบบไม่ทำงาน
- ✅ ไม่มี dialog ยืนยัน
- ✅ ไม่มีการเรียก AuthService
- ✅ ไม่มี loading state
- ✅ ไม่มี error handling

## การแก้ไข

### 1. **เปลี่ยนจาก StatelessWidget เป็น StatefulWidget:**
```dart
// เดิม
class SettingsV2s extends StatelessWidget {
  const SettingsV2s({super.key});

// ใหม่
class SettingsV2s extends StatefulWidget {
  const SettingsV2s({super.key});

  @override
  State<SettingsV2s> createState() => _SettingsV2sState();
}

class _SettingsV2sState extends State<SettingsV2s> {
  // ...
}
```

### 2. **เพิ่ม Import ที่จำเป็น:**
```dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/V2S/widgets/AppDrawerv2s.dart';
import 'package:posashastd/constants.dart';
import 'package:posashastd/services/auth_service.dart';
```

### 3. **เพิ่มฟังก์ชัน `_logout()` เหมือนกับ SettingsPage:**
```dart
// ฟังก์ชันออกจากระบบ
Future<void> _logout() async {
  // แสดง Dialog ยืนยัน
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 8), Text('ออกจากระบบ')]),
      content: const Text('คุณต้องการออกจากระบบหรือไม่?\nข้อมูลทั้งหมดจะถูกลบออกจากเครื่อง', style: TextStyle(fontSize: 18)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก', style: TextStyle(fontSize: 18))),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('ออกจากระบบ', style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ],
    ),
  );

  if (confirm == true) {
    // แสดง loading
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      // ออกจากระบบผ่าน AuthService
      final authService = AuthService();
      await authService.logout();

      Get.back(); // ปิด loading

      // กลับไปหน้า Login และปิดหน้าทั้งหมด
      Get.offAllNamed('/login');

      // แสดงข้อความสำเร็จ
      Get.snackbar('ออกจากระบบสำเร็จ', 'กรุณาเข้าสู่ระบบใหม่', backgroundColor: kTabColor, colorText: Colors.white);
    } catch (e) {
      Get.back(); // ปิด loading
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถออกจากระบบได้: ${e.toString()}', backgroundColor: Colors.red, colorText: Colors.white);
      log('❌ Logout error: $e');
    }
  }
}
```

### 4. **แก้ไขปุ่มออกจากระบบให้เรียกใช้ฟังก์ชัน:**
```dart
// เดิม
ElevatedButton(
  onPressed: () {},  // ❌ ไม่ทำงาน
  child: const Text('ออกจากระบบ'),
),

// ใหม่
ElevatedButton(
  onPressed: _logout,  // ✅ เรียกใช้ฟังก์ชัน _logout
  child: const Text('ออกจากระบบ'),
),
```

## ความเหมือนกันกับ SettingsPage

### ฟังก์ชัน `_logout()` เหมือนกันทุกประการ:

#### 1. **Dialog ยืนยัน** ✅
```dart
// ทั้งสองหน้าใช้ dialog เหมือนกัน
final confirm = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 8), Text('ออกจากระบบ')]),
    content: const Text('คุณต้องการออกจากระบบหรือไม่?\nข้อมูลทั้งหมดจะถูกลบออกจากเครื่อง', style: TextStyle(fontSize: 18)),
    // ...
  ),
);
```

#### 2. **Loading State** ✅
```dart
// ทั้งสองหน้าแสดง loading เหมือนกัน
Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
```

#### 3. **AuthService.logout()** ✅
```dart
// ทั้งสองหน้าใช้ AuthService เหมือนกัน
final authService = AuthService();
await authService.logout();
```

#### 4. **Navigation** ✅
```dart
// ทั้งสองหน้าไปหน้า login เหมือนกัน
Get.offAllNamed('/login');
```

#### 5. **Success Message** ✅
```dart
// ทั้งสองหน้าแสดงข้อความสำเร็จเหมือนกัน
Get.snackbar('ออกจากระบบสำเร็จ', 'กรุณาเข้าสู่ระบบใหม่', backgroundColor: kTabColor, colorText: Colors.white);
```

#### 6. **Error Handling** ✅
```dart
// ทั้งสองหน้าจัดการ error เหมือนกัน
catch (e) {
  Get.back(); // ปิด loading
  Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถออกจากระบบได้: ${e.toString()}', backgroundColor: Colors.red, colorText: Colors.white);
  log('❌ Logout error: $e');
}
```

## Flow การทำงานเหมือนกันทุกประการ

### การออกจากระบบ:
```
1. กดปุ่ม "ออกจากระบบ" → _logout()
2. แสดง Dialog ยืนยัน
3. ถ้ากด "ยกเลิก" → ปิด dialog
4. ถ้ากด "ออกจากระบบ" → แสดง loading
5. เรียก AuthService.logout()
6. ลบข้อมูลทั้งหมดจาก SharedPreferences
7. ปิด loading
8. ไปหน้า Login (Get.offAllNamed('/login'))
9. แสดงข้อความสำเร็จ
10. ถ้าเกิด error → แสดงข้อความ error
```

### การลบข้อมูล (ใน AuthService.logout()):
```
1. ลบ access_token
2. ลบ refresh_token
3. ลบ user_data
4. ลบ device_info
5. ลบ shift_data
6. ลบข้อมูลอื่นๆ ทั้งหมด
```

## การทดสอบ

### ทดสอบการทำงาน:
1. **กดปุ่มออกจากระบบ** → แสดง dialog ยืนยัน ✅
2. **กดยกเลิก** → ปิด dialog, ยังอยู่หน้าเดิม ✅
3. **กดออกจากระบบ** → แสดง loading ✅
4. **รอ AuthService.logout()** → ลบข้อมูลทั้งหมด ✅
5. **ไปหน้า Login** → แสดงหน้า login ✅
6. **แสดงข้อความสำเร็จ** → snackbar เขียว ✅
7. **ถ้าเกิด error** → snackbar แดง ✅

### ตรวจสอบข้อมูล:
```dart
// หลังจากออกจากระบบ ข้อมูลทั้งหมดจะถูกลบ
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('access_token'); // null ✅
final userData = prefs.getString('user_data'); // null ✅
final deviceInfo = prefs.getString('device_info'); // null ✅
```

## ความแตกต่างเพียงอย่างเดียว

### UI Style:
- **SettingsPage** → D2S style (side menu layout)
- **SettingsV2s** → V2S style (simple list layout)

### แต่ฟังก์ชันการออกจากระบบเหมือนกันทุกประการ ✅

## สรุป

✅ **SettingsV2s มีการออกจากระบบเหมือนกับ SettingsPage แล้ว**

### การแก้ไข:
- **เปลี่ยนเป็น StatefulWidget**
- **เพิ่มฟังก์ชัน _logout() เหมือนกัน**
- **เพิ่ม imports ที่จำเป็น**
- **แก้ไขปุ่มให้เรียกใช้ฟังก์ชัน**

### ความเหมือนกัน:
- **Dialog ยืนยันเหมือนกัน**
- **Loading state เหมือนกัน**
- **AuthService.logout() เหมือนกัน**
- **Navigation เหมือนกัน**
- **Error handling เหมือนกัน**
- **Success message เหมือนกัน**

### การทำงาน:
```
SettingsPage._logout() ≡ SettingsV2s._logout()
(เหมือนกันทุกประการ)
```

**🎊 ตอนนี้ SettingsV2s มีการออกจากระบบที่ทำงานเหมือนกับ SettingsPage ทุกประการแล้ว!**
