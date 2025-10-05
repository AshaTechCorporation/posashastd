import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:posashastd/constants.dart';
import 'package:posashastd/D2S/controllers/printer_controller.dart';

class PrinterSetting extends StatefulWidget {
  const PrinterSetting({super.key});

  @override
  State<PrinterSetting> createState() => _PrinterSettingState();
}

class _PrinterSettingState extends State<PrinterSetting> {
  late PrinterController printerController;
  final TextEditingController ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    log('🖨️ PrinterSetting initState called');

    // ลบ controller เก่าและสร้างใหม่เพื่อให้แน่ใจว่าข้อมูลจะถูกโหลดใหม่
    if (Get.isRegistered<PrinterController>()) {
      log('🗑️ Deleting existing PrinterController');
      Get.delete<PrinterController>();
    }

    printerController = Get.put(PrinterController());
    log('🖨️ PrinterController created: ${printerController.hashCode}');

    // ✅ ตั้งค่าเริ่มต้น IP
    ipController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: ktextColr,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('เครื่องปริ๊นเตอร์', style: TextStyle(color: Colors.white)),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: () => printerController.loadSavedPrinters())],
      ),
      body: Column(
        children: [
          // ✅ ค้นหาปริ๊นเตอร์ด้วย IP Address
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ค้นหาปริ๊นเตอร์', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // ✅ ช่องกรอก IP และปุ่มสแกน
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ipController,
                        decoration: InputDecoration(
                          labelText: 'IP Address หรือช่วง IP',
                          hintText: '192.168.1.110 หรือ 192.168.1.100-192.168.1.120',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.computer),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          helperText: 'ตัวอย่าง: 192.168.1.110 หรือ 192.168.1.100-192.168.1.120',
                          helperStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: SizedBox(
                        height: 60,
                        child: Obx(
                          () =>
                              printerController.isScanning.value
                                  ? ElevatedButton.icon(
                                    onPressed: () => _stopScanning(),
                                    icon: const Icon(Icons.stop, color: Colors.white, size: 16),
                                    label: const Text('หยุดสแกน', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                  )
                                  : ElevatedButton.icon(
                                    onPressed: () => _scanSpecificIP(),
                                    icon: const Icon(Icons.search, color: Colors.white, size: 16),
                                    label: const Text('สแกน IP', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ✅ แสดงสถานะการสแกน
                Obx(
                  () =>
                      printerController.isScanning.value
                          ? Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                const SizedBox(width: 8),
                                Text(
                                  printerController.scanStatus.value.isEmpty ? 'กำลังสแกน...' : printerController.scanStatus.value,
                                  style: TextStyle(color: Colors.blue[600], fontSize: 12),
                                ),
                              ],
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // ปุ่มสแกนหาเครื่องปริ๊นเตอร์ (เดิม)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _showScanDialog(),
              icon: const Icon(Icons.wifi, color: Colors.white, size: 18),
              label: const Text('สแกนหาเครื่องปริ๊นเตอร์ในเครือข่าย', style: TextStyle(color: Colors.white, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: ktextColr,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          // รายการเครื่องปริ๊นเตอร์ที่บันทึกไว้
          Expanded(
            child: Obx(() {
              if (printerController.savedPrinters.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.print_disabled, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('ยังไม่มีเครื่องปริ๊นเตอร์ที่บันทึกไว้', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('กดปุ่ม "สแกนหาเครื่องปริ๊นเตอร์" เพื่อค้นหา', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: printerController.savedPrinters.length,
                itemBuilder: (context, index) {
                  final printer = printerController.savedPrinters[index];
                  return _buildPrinterCard(printer);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // สร้างการ์ดแสดงข้อมูลเครื่องปริ๊นเตอร์
  Widget _buildPrinterCard(PrinterInfo printer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ชื่อเครื่องปริ๊นเตอร์และไอคอน
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: _getPrinterTypeColor(printer.type), borderRadius: BorderRadius.circular(8)),
                  child: Icon(_getPrinterTypeIcon(printer.type), color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(printer.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${printer.type} • ${printer.address}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
                // แสดงสถานะค่าเริ่มต้น
                if (printer.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                    child: const Text('ค่าเริ่มต้น', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ปุ่มต่างๆ
            Row(
              children: [
                // ปุ่มทดสอบการเชื่อมต่อ
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: () => _testConnection(printer),
                    icon: const Icon(Icons.wifi_tethering, size: 14),
                    label: const Text('ทดสอบ', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // ปุ่มตั้งเป็นค่าเริ่มต้น
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: printer.isDefault ? null : () => _setAsDefault(printer),
                    icon: Icon(printer.isDefault ? Icons.check : Icons.star, size: 14),
                    label: Text(printer.isDefault ? 'ค่าเริ่มต้น' : 'ตั้งเป็นหลัก', style: const TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: printer.isDefault ? Colors.grey : ktextColr,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // ปุ่มลบ
                SizedBox(
                  width: 40,
                  height: 36,
                  child: IconButton(
                    onPressed: () => _deletePrinter(printer),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // แสดง BottomSheet สำหรับสแกนหาเครื่องปริ๊นเตอร์
  void _showScanDialog() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),

            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: ktextColr,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white, size: 28),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('สแกนหาเครื่องปริ๊นเตอร์', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, color: Colors.white, size: 24), padding: EdgeInsets.zero),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // สถานะการสแกน
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Obx(() {
                        if (printerController.isScanning.value) {
                          return Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  printerController.scanStatus.value.isEmpty ? 'กำลังสแกนหาเครื่องปริ๊นเตอร์...' : printerController.scanStatus.value,
                                  style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'กดปุ่ม "เริ่มสแกน" เพื่อค้นหาเครื่องปริ๊นเตอร์ในเครือข่าย',
                                  style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                    ),

                    const SizedBox(height: 24),

                    // รายการเครื่องปริ๊นเตอร์ที่พบ
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        child: Obx(() {
                          if (printerController.availablePrinters.isEmpty && !printerController.isScanning.value) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.print_disabled, size: 80, color: Colors.grey.shade400),
                                  const SizedBox(height: 20),
                                  Text(
                                    'ยังไม่พบเครื่องปริ๊นเตอร์',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 18, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'ตรวจสอบการเชื่อมต่อเครือข่ายและลองสแกนใหม่',
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          if (printerController.availablePrinters.isEmpty && printerController.isScanning.value) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: CircularProgressIndicator(strokeWidth: 4, valueColor: AlwaysStoppedAnimation<Color>(ktextColr)),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'กำลังค้นหาเครื่องปริ๊นเตอร์...',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 18, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: [
                              // Header รายการ
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.devices, color: Colors.grey.shade600, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'พบเครื่องปริ๊นเตอร์ ${printerController.availablePrinters.length} เครื่อง',
                                      style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              // รายการ
                              Expanded(
                                child: ListView.separated(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: printerController.availablePrinters.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final printer = printerController.availablePrinters[index];
                                    return _buildAvailablePrinterTile(printer);
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: const Text('ปิด', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Obx(
                        () => ElevatedButton.icon(
                          onPressed: printerController.isScanning.value ? null : () => printerController.scanForPrinters(),
                          icon:
                              printerController.isScanning.value
                                  ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
                                  )
                                  : const Icon(Icons.refresh, size: 18),
                          label: Text(
                            printerController.isScanning.value ? 'กำลังสแกน...' : 'เริ่มสแกน',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ktextColr,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }

  // สร้าง tile สำหรับเครื่องปริ๊นเตอร์ที่พบ
  Widget _buildAvailablePrinterTile(PrinterInfo printer) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          // ไอคอนเครื่องปริ๊นเตอร์
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: _getPrinterTypeColor(printer.type), borderRadius: BorderRadius.circular(8)),
            child: Icon(_getPrinterTypeIcon(printer.type), color: Colors.white, size: 20),
          ),

          const SizedBox(width: 12),

          // ข้อมูลเครื่องปริ๊นเตอร์
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(printer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPrinterTypeColor(printer.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        printer.type.toUpperCase(),
                        style: TextStyle(color: _getPrinterTypeColor(printer.type), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        printer.address,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ปุ่มเพิ่ม
          ElevatedButton.icon(
            onPressed: () => _addPrinter(printer),
            icon: const Icon(Icons.add, size: 14, color: Colors.white),
            label: const Text('เพิ่ม', style: TextStyle(color: Colors.white, fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: ktextColr,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(60, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ],
      ),
    );
  }

  // ทดสอบการเชื่อมต่อ
  Future<void> _testConnection(PrinterInfo printer) async {
    final isConnected = await printerController.testPrinterConnection(printer);

    Get.snackbar(
      isConnected ? 'เชื่อมต่อสำเร็จ' : 'เชื่อมต่อไม่สำเร็จ',
      isConnected ? 'เครื่องปริ๊นเตอร์ ${printer.name} พร้อมใช้งาน' : 'ไม่สามารถเชื่อมต่อกับ ${printer.name} ได้',
      backgroundColor: isConnected ? Colors.green : Colors.red,
      colorText: Colors.white,
    );
  }

  // ตั้งเป็นเครื่องปริ๊นเตอร์เริ่มต้น
  Future<void> _setAsDefault(PrinterInfo printer) async {
    await printerController.setDefaultPrinter(printer);
  }

  // ลบเครื่องปริ๊นเตอร์
  Future<void> _deletePrinter(PrinterInfo printer) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบเครื่องปริ๊นเตอร์ "${printer.name}" หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // ลบเครื่องปริ๊นเตอร์จากรายการ
      printerController.savedPrinters.removeWhere((p) => p.address == printer.address);

      // บันทึกการเปลี่ยนแปลงลง SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final printersJson = printerController.savedPrinters.map((p) => '${p.name}|${p.address}|${p.type}|${p.isDefault}').toList();
        await prefs.setStringList('saved_printers', printersJson);
      } catch (e) {
        log('Error deleting printer: $e');
      }

      Get.snackbar('ลบสำเร็จ', 'ลบเครื่องปริ๊นเตอร์ ${printer.name} แล้ว', backgroundColor: Colors.green, colorText: Colors.white);
    }
  }

  // เพิ่มเครื่องปริ๊นเตอร์
  Future<void> _addPrinter(PrinterInfo printer) async {
    // ทดสอบการเชื่อมต่อก่อน
    final isConnected = await printerController.testPrinterConnection(printer);

    if (isConnected) {
      // บันทึกเครื่องปริ๊นเตอร์
      await printerController.savePrinter(printer);
      Get.back(); // ปิด dialog
    }
  }

  // ได้สีตามประเภทเครื่องปริ๊นเตอร์
  Color _getPrinterTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'wifi':
        return Colors.blue;
      case 'lan':
        return Colors.green;
      case 'bluetooth':
        return Colors.purple;
      case 'usb':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // ได้ไอคอนตามประเภทเครื่องปริ๊นเตอร์
  IconData _getPrinterTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'lan':
        return Icons.lan;
      case 'bluetooth':
        return Icons.bluetooth;
      case 'usb':
        return Icons.usb;
      default:
        return Icons.print;
    }
  }

  // ✅ หยุดการสแกน
  void _stopScanning() {
    try {
      printerController.isScanning.value = false;
      printerController.scanStatus.value = '';

      Get.snackbar(
        'หยุดการสแกน',
        'การสแกนหาปริ๊นเตอร์ถูกยกเลิกแล้ว',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.stop_circle, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถหยุดการสแกนได้: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ✅ สแกน IP เฉพาะ (รองรับทั้งไอพีเดี่ยวและช่วงไอพี)
  Future<void> _scanSpecificIP() async {
    final input = ipController.text.trim();
    if (input.isEmpty) {
      Get.snackbar('ข้อผิดพลาด', 'กรุณากรอก IP Address', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // ✅ ตรวจสอบรูปแบบ IP (เดี่ยวหรือช่วง)
    List<String> ipsToScan = [];

    if (input.contains('-')) {
      // ✅ รูปแบบช่วง: 192.168.1.1-192.168.1.10 หรือ 192.168.1.1 - 192.168.1.10
      final parts = input.contains(' - ') ? input.split(' - ') : input.split('-');
      if (parts.length != 2) {
        Get.snackbar(
          'ข้อผิดพลาด',
          'รูปแบบช่วง IP ไม่ถูกต้อง\nใช้รูปแบบ: 192.168.1.1-192.168.1.10 หรือ 192.168.1.1 - 192.168.1.10',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final startIP = parts[0].trim();
      final endIP = parts[1].trim();

      // ตรวจสอบรูปแบบ IP ทั้งสอง
      final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
      if (!ipRegex.hasMatch(startIP) || !ipRegex.hasMatch(endIP)) {
        Get.snackbar('ข้อผิดพลาด', 'รูปแบบ IP ไม่ถูกต้อง', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // สร้างรายการ IP ในช่วง
      ipsToScan = _generateIPRange(startIP, endIP);
      if (ipsToScan.isEmpty) {
        Get.snackbar('ข้อผิดพลาด', 'ช่วง IP ไม่ถูกต้อง', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    } else {
      // ✅ รูปแบบเดี่ยว: 192.168.1.1
      final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
      if (!ipRegex.hasMatch(input)) {
        Get.snackbar(
          'ข้อผิดพลาด',
          'รูปแบบ IP ไม่ถูกต้อง\nใช้รูปแบบ: 192.168.1.1 หรือ 192.168.1.1-192.168.1.10',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      ipsToScan = [input];
    }

    try {
      printerController.isScanning.value = true;
      printerController.scanStatus.value = 'กำลังตรวจสอบ ${ipsToScan.length} IP...';
      printerController.availablePrinters.clear();

      int foundCount = 0;

      // ✅ สแกนทุก IP ในรายการ (สามารถหยุดได้)
      for (int i = 0; i < ipsToScan.length; i++) {
        // ✅ ตรวจสอบว่าถูกหยุดหรือไม่
        if (!printerController.isScanning.value) {
          break; // หยุดการสแกนถ้าผู้ใช้กดหยุด
        }

        final currentIP = ipsToScan[i];
        printerController.scanStatus.value = 'กำลังตรวจสอบ $currentIP (${i + 1}/${ipsToScan.length})...';

        // ทดสอบการเชื่อมต่อ
        final isReachable = await printerController.pingHost(currentIP);

        // ✅ ตรวจสอบอีกครั้งหลังจาก async operation
        if (!printerController.isScanning.value) {
          break; // หยุดการสแกนถ้าผู้ใช้กดหยุดระหว่างรอ
        }

        if (isReachable) {
          // ตรวจสอบว่าเป็นปริ๊นเตอร์หรือไม่
          final printerInfo = await printerController.identifyPrinter(currentIP);

          // ✅ ตรวจสอบอีกครั้งหลังจาก async operation
          if (!printerController.isScanning.value) {
            break; // หยุดการสแกนถ้าผู้ใช้กดหยุดระหว่างรอ
          }

          if (printerInfo != null) {
            // ตรวจสอบว่ามีอยู่แล้วหรือไม่
            final existingIndex = printerController.availablePrinters.indexWhere((p) => p.address == currentIP);
            if (existingIndex >= 0) {
              printerController.availablePrinters[existingIndex] = printerInfo;
            } else {
              printerController.availablePrinters.add(printerInfo);
            }
            foundCount++;
          }
        }
      }

      // ✅ แสดงผลลัพธ์
      if (foundCount > 0) {
        Get.dialog(
          AlertDialog(
            title: Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('พบปริ๊นเตอร์')]),
            content: SizedBox(
              width: 400,
              height: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('พบปริ๊นเตอร์ $foundCount เครื่องจาก ${ipsToScan.length} IP', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: printerController.availablePrinters.length,
                      itemBuilder: (context, index) {
                        final printer = printerController.availablePrinters[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.print, color: Colors.blue),
                            title: Text(printer.name),
                            subtitle: Text('${printer.address} (${printer.type})'),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                final isConnected = await printerController.testPrinterConnection(printer);
                                if (isConnected) {
                                  await printerController.savePrinter(printer);
                                  Get.back();
                                }
                              },
                              child: Text('เพิ่ม'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [TextButton(onPressed: () => Get.back(), child: Text('ปิด'))],
          ),
        );
      } else {
        Get.snackbar('ไม่พบปริ๊นเตอร์', 'ไม่พบปริ๊นเตอร์ในช่วง IP ที่ระบุ', backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'เกิดข้อผิดพลาด: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      printerController.isScanning.value = false;
      printerController.scanStatus.value = '';
    }
  }

  // ✅ สร้างรายการ IP ในช่วงที่ระบุ
  List<String> _generateIPRange(String startIP, String endIP) {
    try {
      // แยกส่วนของ IP
      final startParts = startIP.split('.').map(int.parse).toList();
      final endParts = endIP.split('.').map(int.parse).toList();

      // ตรวจสอบว่าอยู่ใน subnet เดียวกัน (3 ส่วนแรกต้องเหมือนกัน)
      if (startParts[0] != endParts[0] || startParts[1] != endParts[1] || startParts[2] != endParts[2]) {
        return []; // ไม่อยู่ใน subnet เดียวกัน
      }

      final startHost = startParts[3];
      final endHost = endParts[3];

      if (startHost > endHost) {
        return []; // ช่วงไม่ถูกต้อง
      }

      // สร้างรายการ IP
      final List<String> ips = [];
      final baseIP = '${startParts[0]}.${startParts[1]}.${startParts[2]}';

      for (int i = startHost; i <= endHost; i++) {
        ips.add('$baseIP.$i');
      }

      return ips;
    } catch (e) {
      return [];
    }
  }
}
