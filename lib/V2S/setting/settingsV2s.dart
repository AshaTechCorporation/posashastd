import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/V2S/widgets/AppDrawerv2s.dart';
import 'package:posashastd/constants.dart';
import 'package:posashastd/services/auth_service.dart';

class SettingsV2s extends StatefulWidget {
  const SettingsV2s({super.key});

  @override
  State<SettingsV2s> createState() => _SettingsV2sState();
}

class _SettingsV2sState extends State<SettingsV2s> {
  // ฟังก์ชันออกจากระบบ
  Future<void> _logout() async {
    // แสดง Dialog ยืนยัน
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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
        Get.offAllNamed('/loginV2s');

        // แสดงข้อความสำเร็จ
        Get.snackbar('ออกจากระบบสำเร็จ', 'กรุณาเข้าสู่ระบบใหม่', backgroundColor: kTabColor, colorText: Colors.white);
      } catch (e) {
        Get.back(); // ปิด loading
        Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถออกจากระบบได้: ${e.toString()}', backgroundColor: Colors.red, colorText: Colors.white);
        log('❌ Logout error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawerv2s(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
        title: const Text('การตั้งค่า', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          ListTile(leading: Icon(Icons.print), title: Text('เครื่องพิมพ์')),
          ListTile(leading: Icon(Icons.percent), title: Text('ภาษี')),
          ListTile(leading: Icon(Icons.settings), title: Text('ทั่วไป')),
          Spacer(),
          Padding(padding: EdgeInsets.only(bottom: 4), child: Text('jumpoil2107@hotmail.com', style: TextStyle(color: Colors.grey))),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300, foregroundColor: Colors.black87),
              child: const Text('ออกจากระบบ'),
            ),
          ),
        ],
      ),
    );
  }
}
