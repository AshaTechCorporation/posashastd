import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/controllers/home_controller.dart';
import 'package:posashastd/D2S/controllers/report_controller.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';
import 'package:posashastd/constants.dart';

class SummaryReportPage extends StatefulWidget {
  const SummaryReportPage({super.key});

  @override
  State<SummaryReportPage> createState() => _SummaryReportPageState();
}

class _SummaryReportPageState extends State<SummaryReportPage> {
  late HomeController homeController;
  late ReportController reportController;

  @override
  void initState() {
    super.initState();
    log('📊 SummaryReportPage initState called');

    // ลบ controller เก่าและสร้างใหม่เพื่อให้แน่ใจว่าข้อมูลจะถูกโหลดใหม่
    if (Get.isRegistered<HomeController>()) {
      log('🗑️ Deleting existing HomeController');
      Get.delete<HomeController>();
    }
    if (Get.isRegistered<ReportController>()) {
      log('🗑️ Deleting existing ReportController');
      Get.delete<ReportController>();
    }

    log('🆕 Creating new HomeController');
    homeController = Get.put(HomeController());
    log('🆕 Creating new ReportController');
    reportController = Get.put(ReportController());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      log('⏰ PostFrameCallback: loading data');
      await homeController.checkConnectivityAndLoadData();
      log('✅ Data loading completed');
      log('🔢 Current shift ID: ${homeController.currentShiftId.value}');

      // โหลดข้อมูลสรุปรายงานด้วย shift ID ที่ถูกต้อง
      await _loadSummaryReport();
    });
  }

  // ✅ โหลดข้อมูลสรุปรายงาน
  Future<void> _loadSummaryReport() async {
    final shiftId = homeController.currentShiftId.value;
    if (shiftId != null && shiftId.isNotEmpty) {
      log('📊 Loading summary report for shift ID: $shiftId');
      await reportController.getSummaryReportWithShiftId(shiftId);
    } else {
      log('⚠️ No valid shift ID found, cannot load summary report');
    }
  }

  // ✅ รีเฟรชข้อมูล
  Future<void> _refreshData() async {
    log('🔄 Refreshing summary report data...');
    await _loadSummaryReport();
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
                        _refreshData();
                      },
                    ),
                    // IconButton(
                    //   icon: const Icon(Icons.print, color: Colors.white),
                    //   tooltip: 'พิมพ์',
                    //   onPressed: () {
                    //     // TODO: เพิ่มฟังก์ชันพิมพ์
                    //   },
                    // ),
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
                        // ElevatedButton.icon(
                        //   style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        //   icon: const Icon(Icons.attach_money, color: Colors.white, size: 18),
                        //   label: const Text('จัดการเงินสด', style: TextStyle(color: Colors.white)),
                        //   onPressed: () {
                        //     // TODO: แสดงหน้าจัดการเงินสด
                        //   },
                        // ),
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
                      child: Obx(() {
                        if (reportController.isLoading.value) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [CircularProgressIndicator(), SizedBox(height: 16), Text('กำลังโหลดข้อมูลสรุปรายงาน...')],
                            ),
                          );
                        }

                        if (reportController.errorMessage.value.isNotEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                                const SizedBox(height: 16),
                                Text('เกิดข้อผิดพลาด', style: TextStyle(fontSize: 18, color: Colors.red[600])),
                                const SizedBox(height: 8),
                                Text(reportController.errorMessage.value, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                ElevatedButton(onPressed: _refreshData, child: const Text('ลองใหม่')),
                              ],
                            ),
                          );
                        }

                        return ListView(
                          children: [
                            Center(
                              child: Text(
                                'การสรุปรายรับยอดขาย',
                                style: TextStyle(color: Colors.green.shade700, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // แสดงข้อมูลจาก API
                            if (reportController.summary.isNotEmpty) ...[
                              const Text(
                                'สรุปยอดขายตามประเภทการชำระ',
                                style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),

                              // แสดงข้อมูลแต่ละประเภทการชำระ
                              ...reportController.summary.map((summary) => _buildSummaryRow(summary)),

                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 16),

                              // คำนวณยอดรวม
                              _buildRowBold('รายได้รวม', _calculateTotalAmount()),
                            ] else ...[
                              const Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text('ไม่มีข้อมูลสรุปรายงาน', style: TextStyle(color: Colors.grey, fontSize: 16)),
                                    SizedBox(height: 8),
                                    Text('อาจยังไม่มีการขายในกะนี้', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      }),
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

  // ✅ สร้าง row สำหรับข้อมูล summary จาก API
  Widget _buildSummaryRow(summary) {
    final paymentName = summary.payment_name ?? 'ไม่ระบุ';
    final totalTransactions = summary.total_transactions ?? '0';
    final totalAmount = summary.total_amount ?? '0';

    // แปลงจำนวนเงินเป็น double เพื่อจัดรูปแบบ
    double amount = 0.0;
    try {
      amount = double.parse(totalAmount);
    } catch (e) {
      log('Error parsing amount: $totalAmount');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(paymentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Text('฿${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('จำนวนรายการ: $totalTransactions', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                Text(
                  'เฉลี่ย: ฿${totalTransactions != '0' ? (amount / int.parse(totalTransactions)).toStringAsFixed(2) : '0.00'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ คำนวณยอดรวมทั้งหมด
  String _calculateTotalAmount() {
    double total = 0.0;

    for (var summary in reportController.summary) {
      try {
        final amount = double.parse(summary.total_amount ?? '0');
        total += amount;
      } catch (e) {
        log('Error parsing amount for calculation: ${summary.total_amount}');
      }
    }

    return '฿${total.toStringAsFixed(2)}';
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
