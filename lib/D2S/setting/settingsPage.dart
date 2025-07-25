import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/controllers/printer_controller.dart';
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
  late PrinterController printerController;

  final List<String> tabs = ['เครื่องพิมพ์'];
  //final List<String> tabs = ['เครื่องพิมพ์', 'ภาษี', 'ทั่วไป'];

  @override
  void initState() {
    super.initState();
    printerController = Get.put(PrinterController());
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
    return Obx(
      () => Column(
        children: [
          // ✅ Header พร้อมปุ่มสแกน
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ปริ๊นเตอร์ที่บันทึกไว้ (${printerController.savedPrinters.length})',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: printerController.isScanning.value ? null : () => _showScanDialog(),
                  icon:
                      printerController.isScanning.value
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.search, color: Colors.white),
                  label: Text(
                    printerController.isScanning.value ? 'กำลังสแกน...' : 'สแกนปริ๊นเตอร์',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: kTabColor),
                ),
              ],
            ),
          ),

          // ✅ รายการปริ๊นเตอร์ที่บันทึกไว้
          Expanded(
            child:
                printerController.savedPrinters.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.print_disabled, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('ยังไม่มีปริ๊นเตอร์ที่บันทึกไว้', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          SizedBox(height: 8),
                          Text('กดปุ่ม "สแกนปริ๊นเตอร์" เพื่อค้นหาปริ๊นเตอร์', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: printerController.savedPrinters.length,
                      itemBuilder: (context, index) {
                        final printer = printerController.savedPrinters[index];
                        return _buildPrinterTile(printer, true);
                      },
                    ),
          ),
        ],
      ),
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

  // ✅ แสดง Dialog สำหรับสแกนปริ๊นเตอร์
  void _showScanDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(children: [Icon(Icons.search, color: Colors.blue), SizedBox(width: 8), Text('สแกนหาปริ๊นเตอร์')]),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Obx(
            () => Column(
              children: [
                // Status
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      if (printerController.isScanning.value)
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      else
                        Icon(Icons.info_outline, color: Colors.blue[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          printerController.scanStatus.value.isEmpty ? 'กดปุ่ม "เริ่มสแกน" เพื่อค้นหาปริ๊นเตอร์' : printerController.scanStatus.value,
                          style: TextStyle(color: Colors.blue[600]),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // รายการปริ๊นเตอร์ที่พบ
                Expanded(
                  child:
                      printerController.availablePrinters.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 48, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('ยังไม่พบปริ๊นเตอร์', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                          : ListView.builder(
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
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('ปิด')),
          ElevatedButton(
            onPressed: printerController.isScanning.value ? null : () => printerController.scanForPrinters(),
            style: ElevatedButton.styleFrom(backgroundColor: kTabColor),
            child: Text(printerController.isScanning.value ? 'กำลังสแกน...' : 'เริ่มสแกน', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ✅ สร้าง Tile สำหรับแสดงปริ๊นเตอร์
  Widget _buildPrinterTile(PrinterInfo printer, bool isSaved) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPrinterTypeColor(printer.type),
          child: Icon(_getPrinterTypeIcon(printer.type), color: Colors.white, size: 20),
        ),
        title: Text(printer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${printer.type} • ${printer.address}'),
            if (printer.isDefault)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                child: const Text('ค่าเริ่มต้น', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
          ],
        ),
        trailing: isSaved ? _buildSavedPrinterActions(printer) : _buildAvailablePrinterActions(printer),
      ),
    );
  }

  // ✅ Actions สำหรับปริ๊นเตอร์ที่บันทึกไว้
  Widget _buildSavedPrinterActions(PrinterInfo printer) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'test':
            await printerController.testPrinterConnection(printer);
            break;
          case 'default':
            await printerController.setDefaultPrinter(printer);
            break;
          case 'delete':
            _showDeleteConfirmDialog(printer);
            break;
        }
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'test',
              child: Row(children: [Icon(Icons.wifi_tethering, size: 20), SizedBox(width: 8), Text('ทดสอบการเชื่อมต่อ')]),
            ),
            if (!printer.isDefault)
              const PopupMenuItem(
                value: 'default',
                child: Row(children: [Icon(Icons.star, size: 20), SizedBox(width: 8), Text('ตั้งเป็นค่าเริ่มต้น')]),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('ลบ', style: TextStyle(color: Colors.red))],
              ),
            ),
          ],
    );
  }

  // ✅ Actions สำหรับปริ๊นเตอร์ที่พบ
  Widget _buildAvailablePrinterActions(PrinterInfo printer) {
    return ElevatedButton.icon(
      onPressed: () async {
        // ทดสอบการเชื่อมต่อก่อน
        final isConnected = await printerController.testPrinterConnection(printer);
        if (isConnected) {
          // บันทึกปริ๊นเตอร์
          await printerController.savePrinter(printer);
          Get.back(); // ปิด dialog
        }
      },
      icon: Icon(Icons.add, size: 16, color: Colors.white),
      label: Text('เพิ่ม', style: TextStyle(fontSize: 16, color: Colors.white)),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
    );
  }

  // ✅ แสดง Dialog ยืนยันการลบ
  void _showDeleteConfirmDialog(PrinterInfo printer) {
    Get.dialog(
      AlertDialog(
        title: const Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('ลบปริ๊นเตอร์')]),
        content: Text('ต้องการลบปริ๊นเตอร์ "${printer.name}" หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () {
              printerController.removeSavedPrinter(printer);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ✅ Helper functions
  Color _getPrinterTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'wifi':
        return Colors.blue;
      case 'lan':
        return Colors.green;
      case 'usb':
        return Colors.orange;
      case 'bluetooth':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getPrinterTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'lan':
        return Icons.lan;
      case 'usb':
        return Icons.usb;
      case 'bluetooth':
        return Icons.bluetooth;
      default:
        return Icons.print;
    }
  }
}
