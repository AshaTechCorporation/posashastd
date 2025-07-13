import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';
import 'package:posashastd/constants.dart';
import 'package:posashastd/services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int selectedTab = 0;

  final List<String> tabs = ['เครื่องพิมพ์', 'ภาษี', 'ทั่วไป'];

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
        Get.offAllNamed('/login');

        // แสดงข้อความสำเร็จ
        Get.snackbar('ออกจากระบบสำเร็จ', 'กรุณาเข้าสู่ระบบใหม่', backgroundColor: kTabColor, colorText: Colors.white);
      } catch (e) {
        Get.back(); // ปิด loading
        Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถออกจากระบบได้: ${e.toString()}', backgroundColor: Colors.red, colorText: Colors.white);
        print(e);
      }
    }
  }

  Widget buildTabContent() {
    switch (selectedTab) {
      case 0:
        return _printerTab();
      case 1:
        return _taxTab();
      case 2:
        return _generalTab();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Row(
          children: [
            // 🔹 Side menu and tabs
            Container(
              width: 350,
              color: const Color(0xFFEFEFEF),
              child: Column(
                children: [
                  // ✅ Menu button
                  Container(
                    height: 50,
                    color: kTabColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Builder(
                          builder:
                              (context) =>
                                  IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer()),
                        ),
                        const SizedBox(width: 8),
                        Text('ตั้งค่า', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (int i = 0; i < tabs.length; i++)
                    ListTile(
                      leading: Icon(
                        i == 0
                            ? Icons.print
                            : i == 1
                            ? Icons.percent
                            : Icons.settings,
                        color: selectedTab == i ? Colors.green : Colors.black54,
                      ),
                      title: Text(
                        tabs[i],
                        style: TextStyle(
                          color: selectedTab == i ? Colors.green : Colors.black87,
                          fontWeight: selectedTab == i ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: selectedTab == i,
                      onTap: () => setState(() => selectedTab = i),
                    ),
                  const Spacer(),
                  const Divider(),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text("jumpoll7107@hotmail.com", style: TextStyle(fontSize: 16))),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text("ออกจากระบบ", style: TextStyle(color: Colors.black, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
            // 🔸 Tab Content
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 50,
                    color: kTabColor,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(tabs[selectedTab], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: buildTabContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _printerTab() {
    return Column(
      children: [
        ListTile(leading: const Icon(Icons.print), title: const Text('test'), subtitle: const Text('Sunmi'), trailing: const Text('ใบเสร็จรับเงิน')),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(onPressed: () {}, backgroundColor: kTabColor, child: const Icon(Icons.add, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _taxTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.percent, size: 64, color: Colors.grey),
          SizedBox(height: 20),
          Text("คุณยังไม่มีการใช้ภาษีของคุณ"),
          SizedBox(height: 8),
          Text("โปรดแตะที่การรวม รายการคำสั่งขาย", style: TextStyle(color: Colors.grey)),
          Text("ได้ภาษีที่ถูกต้อง", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _generalTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          SwitchListTile(title: const Text("ใช้ต้นฉบับและสำเนาใบเสร็จ"), value: false, onChanged: (val) {}),
          SwitchListTile(title: const Text("โหมดเงียบ"), value: false, onChanged: (val) {}),
          const SizedBox(height: 16),
          const Text("เผื่อโครงหน้าอาจารย์การขาย: ระบบ", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          const Text("ภาษา: ใช้ค่าตั้งต้นอุปกรณ์", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
