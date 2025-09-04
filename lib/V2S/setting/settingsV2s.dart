import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/V2S/setting/printerSetting.dart';
import 'package:posashastd/V2S/widgets/AppDrawerv2s.dart';
import 'package:posashastd/constants.dart';
import 'package:posashastd/services/auth_service.dart';

class SettingsV2s extends StatefulWidget {
  const SettingsV2s({super.key});

  @override
  State<SettingsV2s> createState() => _SettingsV2sState();
}

class _SettingsV2sState extends State<SettingsV2s> {
  // ฟังก์ชันแสดงข้อความฟีเจอร์ยังไม่พร้อม
  void _showFeatureNotReady(String featureName) {
    Get.snackbar(
      'ฟีเจอร์ยังไม่พร้อม',
      'ฟังก์ชั่น "$featureName" ยังไม่พร้อมใช้งาน',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

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
        backgroundColor: ktextColr,
        title: const Text('การตั้งค่า', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          ListTile(leading: const Icon(Icons.print), title: const Text('เครื่องพิมพ์'), onTap: () => Get.to(() => const PrinterSetting())),
          ListTile(leading: const Icon(Icons.percent), title: const Text('ภาษี'), onTap: () => _showFeatureNotReady('ภาษี')),
          ListTile(leading: const Icon(Icons.settings), title: const Text('ทั่วไป'), onTap: () => _showFeatureNotReady('ทั่วไป')),
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
