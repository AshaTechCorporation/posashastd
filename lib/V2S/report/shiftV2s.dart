import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/V2S/widgets/AppDrawerv2s.dart';
import 'package:posashastd/D2S/controllers/home_controller.dart';
import 'package:posashastd/D2S/controllers/report_controller.dart';
import 'package:posashastd/constants.dart';

class ShiftV2s extends StatefulWidget {
  const ShiftV2s({super.key});

  @override
  State<ShiftV2s> createState() => _ShiftV2sState();
}

class _ShiftV2sState extends State<ShiftV2s> {
  late HomeController homeController;
  late ReportController reportController;

  @override
  void initState() {
    super.initState();
    log('📊 ShiftV2s initState called');

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
    if (shiftId.isNotEmpty) {
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
    setState(() {}); // รีเฟรช UI
  }

  // ✅ ปิดกะ
  Future<void> _closeShift() async {
    final shiftId = homeController.currentShiftId.value;
    if (shiftId.isEmpty) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่พบ shift ID', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final success = await homeController.closeShift();

    if (success) {
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
                Get.offAllNamed('/homev2s');
              },
              style: ElevatedButton.styleFrom(backgroundColor: kTabColor),
              child: const Text('ตกลง', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawerv2s(),
      appBar: AppBar(
        title: const Text('กะ'),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        //actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.print, color: Colors.white))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔘 ปุ่มจัดการเงินสด / ปิดกะ
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // _buildFullWidthButton(
              //   label: 'การจัดการ เงินสด',
              //   backgroundColor: Colors.white,
              //   textColor: Colors.black87,
              //   borderColor: Colors.green,
              //   onTap: () {},
              // ),
              const SizedBox(height: 12),
              _buildFullWidthButton(
                label: 'ปิดกะ',
                backgroundColor: Colors.white,
                textColor: Colors.black87,
                borderColor: Colors.green,
                onTap: _closeShift,
              ),
            ],
          ),

          SizedBox(height: 20),

          // 🔘 ข้อมูลกะ
          Obx(
            () => Text(
              'จำนวนกะที่ทำงาน: ${homeController.currentShiftId.value.isNotEmpty ? homeController.currentShiftId.value : "ไม่ทราบ"}',
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(height: 6),
          Obx(
            () => Row(
              children: [
                Expanded(child: Text('เปิดแล้ว: ${homeController.isShiftOpen.value ? "เปิดอยู่" : "ปิดอยู่"}', style: const TextStyle(fontSize: 15))),
                Text(
                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 🔘 หัวข้อสรุปการเก็บเงิน
          const Text('สรุปการเก็บเงิน', style: TextStyle(color: Color(0xFF558B2F), fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // 🔘 แสดงข้อมูลจาก API
          Obx(() {
            if (reportController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (reportController.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text('เกิดข้อผิดพลาด', style: TextStyle(fontSize: 16, color: Colors.red[600])),
                    const SizedBox(height: 4),
                    Text(reportController.errorMessage.value, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _refreshData, child: const Text('ลองใหม่')),
                  ],
                ),
              );
            }

            if (reportController.summary.isNotEmpty) {
              return Column(
                children: [
                  // แสดงข้อมูลแต่ละประเภทการชำระ
                  ...reportController.summary.map((summary) => _buildSummaryRowFromAPI(summary)),

                  const SizedBox(height: 12),
                  const Divider(thickness: 0.8),
                  const SizedBox(height: 6),

                  // คำนวณยอดรวม
                  _buildSummaryRow('รายได้รวม', _calculateTotalAmount()),
                ],
              );
            } else {
              return const Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('ไม่มีข้อมูลสรุปรายงาน', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('อาจยังไม่มีการขายในกะนี้', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 15))), Text(amount, style: const TextStyle(fontSize: 15))]),
    );
  }

  // ✅ สร้าง row สำหรับข้อมูล summary จาก API
  Widget _buildSummaryRowFromAPI(summary) {
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(paymentName, style: const TextStyle(fontSize: 15))),
          Text('฿${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15)),
        ],
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

  Widget _buildFullWidthButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: borderColor != null ? Border.all(color: borderColor) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
