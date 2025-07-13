import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/controllers/home_controller.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';
import 'package:posashastd/constants.dart';

class SummaryReportPage extends StatefulWidget {
  const SummaryReportPage({super.key});

  @override
  State<SummaryReportPage> createState() => _SummaryReportPageState();
}

class _SummaryReportPageState extends State<SummaryReportPage> {
  late HomeController homeController;

  @override
  void initState() {
    super.initState();
    log('🏠 HomePage initState called');

    // ลบ controller เก่าและสร้างใหม่เพื่อให้แน่ใจว่าข้อมูลจะถูกโหลดใหม่
    if (Get.isRegistered<HomeController>()) {
      log('🗑️ Deleting existing HomeController');
      Get.delete<HomeController>();
    }
    log('🆕 Creating new HomeController');
    homeController = Get.put(HomeController());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      log('⏰ PostFrameCallback: loading data');
      await homeController.checkConnectivityAndLoadData();
      log('✅ Data loading completed');

      // หลังจากโหลดข้อมูลเสร็จ ให้เช็คพาเนลและสร้างแท็บ
    });
  }

  // ฟังก์ชันแสดง Dialog ปิดกะ
  void _showCloseShiftDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Row(children: [Icon(Icons.lock, color: Colors.red), SizedBox(width: 8), Text('ยืนยันการปิดกะ')]),
        content: const Text('คุณต้องการปิดกะหรือไม่?\nเมื่อปิดกะแล้วจะไม่สามารถทำรายการได้จนกว่าจะเปิดกะใหม่', style: TextStyle(fontSize: 18)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // ปิด dialog ยืนยัน
              await _closeShift(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ปิดกะ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ฟังก์ชันปิดกะ
  Future<void> _closeShift(BuildContext context) async {
    try {
      // ✅ ใช้ homeController ที่สร้างใน initState แล้ว
      log('🔍 Debug - Before closing shift:');
      log('   currentShiftId: ${homeController.currentShiftId.value}');
      log('   isShiftOpen: ${homeController.isShiftOpen.value}');

      // ถ้า currentShiftId ว่าง ให้โหลดข้อมูลใหม่ก่อน
      if (homeController.currentShiftId.value.isEmpty) {
        log('⚠️ currentShiftId is empty, checking shift status...');
        await homeController.checkShiftStatus();

        // ถ้ายังว่างอยู่ แสดงว่าไม่มีกะเปิดอยู่
        if (homeController.currentShiftId.value.isEmpty) {
          Get.snackbar('ข้อผิดพลาด', 'ไม่พบข้อมูลกะที่เปิดอยู่', backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
      }

      // แสดง loading
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final success = await homeController.closeShift();

      // 🔍 Debug: ตรวจสอบผลลัพธ์
      log('🔍 Debug - Close shift result: $success');

      // ✅ ปิด loading dialog ก่อนแสดง result dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (success) {
        // ✅ ใช้ Get.dialog แทน showDialog เพื่อหลีกเลี่ยงปัญหา BuildContext
        Get.dialog(
          AlertDialog(
            title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('ปิดกะสำเร็จ')]),
            content: const Text('ปิดกะเรียบร้อยแล้ว\nระบบจะกลับไปหน้าหลักเพื่อเปิดกะใหม่', style: TextStyle(fontSize: 18)),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  Get.back(); // ปิด dialog

                  // ✅ เคลียร์ shiftId และอัพเดทสถานะให้แสดง UI เปิดกะใหม่
                  homeController.currentShiftId.value = '';
                  homeController.isShiftOpen.value = false;

                  // ✅ เช็คสถานะ shift อีกครั้งเพื่อให้แน่ใจ
                  await homeController.checkShiftStatus();

                  // กลับไปหน้าหลัก
                  Get.offAllNamed('/home');
                },
                style: ElevatedButton.styleFrom(backgroundColor: kTabColor),
                child: const Text('ตกลง', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        // ❌ แสดง error dialog เมื่อปิดกะไม่สำเร็จ
        Get.dialog(
          AlertDialog(
            title: const Row(children: [Icon(Icons.error, color: Colors.red), SizedBox(width: 8), Text('ปิดกะไม่สำเร็จ')]),
            content: const Text('ไม่สามารถปิดกะได้\nกรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ตและลองใหม่อีกครั้ง', style: TextStyle(fontSize: 18)),
            actions: [
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('ตกลง', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      // ✅ ปิด loading dialog หากเกิด error
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      log('❌ Error in _closeShift: $e');
      Get.snackbar('ข้อผิดพลาด', 'เกิดข้อผิดพลาดในการปิดกะ: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // 🔰 Header Bar
          Container(
            height: 50,
            color: kTabColor,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Builder(
                      builder:
                          (context) =>
                              IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer()),
                    ),
                    const SizedBox(width: 4),
                    const Text('กะ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      tooltip: 'รีเฟรช',
                      onPressed: () {
                        // TODO: เพิ่มฟังก์ชันรีเฟรช
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.print, color: Colors.white),
                      tooltip: 'พิมพ์',
                      onPressed: () {
                        // TODO: เพิ่มฟังก์ชันพิมพ์
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔳 Content
          Expanded(
            child: Center(
              child: Container(
                width: screenWidth > 900 ? 700 : screenWidth * 0.9,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔘 ปุ่มด้านขวาบนของกล่อง
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          icon: const Icon(Icons.attach_money, color: Colors.white, size: 18),
                          label: const Text('จัดการเงินสด', style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            // TODO: แสดงหน้าจัดการเงินสด
                          },
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          icon: const Icon(Icons.lock, color: Colors.white, size: 18),
                          label: const Text('ปิดกะ', style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            _showCloseShiftDialog(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 🔢 รายงาน
                    Expanded(
                      child: ListView(
                        children: [
                          Center(
                            child: Text(
                              'การสรุปราย รับยอดขาย',
                              style: TextStyle(color: Colors.green.shade700, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildRow('จำนวนรายการทั้งหมด:', '3'),
                          _buildRow('ปิดแล้ว:', 'unknown unknown'),
                          Align(alignment: Alignment.centerRight, child: Text('21/3/24 16:42 น.', style: Theme.of(context).textTheme.bodySmall)),
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          const Text('ตั้งแต่วันเริ่มต้น ถึงปิดรอบ', style: TextStyle(color: Colors.green)),
                          const SizedBox(height: 12),
                          _buildRow('วันเริ่มต้นถึง ปิดรอบ', '฿80.00'),
                          _buildRow('ชำระเป็นสด', '฿6,347.00'),
                          _buildRow('ชำระแอพ', '฿80.00'),
                          _buildRow('ส่วน เงินท้า', '฿80.00'),
                          _buildRow('เงิน ออก', '฿80.00'),
                          _buildRowBold('เงินที่ควรได้', '฿6,347.00'),
                          const SizedBox(height: 24),
                          const Text('สรุปยอดขาย', style: TextStyle(color: Colors.green)),
                          const SizedBox(height: 12),
                          _buildRowBold('ยอดขาย', '฿6,933.00'),
                          _buildRow('รับแล้ว', '฿80.00'),
                          _buildRow('เงินสด', '฿6,347.00'),
                          _buildRow('ชำระด้วยบัตร', '฿65.00'),
                          _buildRow('โอนชำระ', '฿521.00'),
                          const Divider(height: 24),
                          _buildRowBold('รายได้รวม', '฿6,933.00'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Helper Widget
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Flexible(child: Text(label, overflow: TextOverflow.ellipsis)), Text(value)],
      ),
    );
  }

  Widget _buildRowBold(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
