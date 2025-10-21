import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/controllers/home_controller.dart';
import 'package:posashastd/D2S/controllers/order_controller.dart';
import 'package:posashastd/D2S/controllers/printer_controller.dart';
import 'package:posashastd/D2S/home/widgets/CartSummaryWidget.dart';
import 'package:posashastd/D2S/home/widgets/PaymentConfirmDialog.dart';
import 'package:posashastd/D2S/home/widgets/PaymentDisplayWidget.dart';
import 'package:posashastd/D2S/home/widgets/ProductHeader.dart';
import 'package:posashastd/D2S/home/widgets/ReceiptPreviewWidget.dart';
import 'package:posashastd/constants.dart';
import 'package:posashastd/helpers/ReceiptWidget.dart';
import 'package:posashastd/helpers/printReceiptFromCartItems.dart';
import 'package:posashastd/helpers/mix_match_multi_units.dart';
import 'package:posashastd/services/homeService.dart';
import 'package:posashastd/utils/cart_utils.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';

class PaymentPageD2s extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final int? editOrderId;
  final String? editOrderNumber;

  const PaymentPageD2s({super.key, required this.cartItems, this.editOrderId, this.editOrderNumber});

  @override
  State<PaymentPageD2s> createState() => _PaymentPageD2sState();
}

class _PaymentPageD2sState extends State<PaymentPageD2s> {
  double receivedAmount = 0;
  bool isPaid = false;
  final ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey receiptKey = GlobalKey();
  String? orderReceiptNumber; // ✅ เก็บเลขที่ใบเสร็จจาก API

  // ตัวแปรสำหรับจัดการส่วนลด
  double? selectedDiscountAmount;
  double discountAmount = 0;
  double totalDiscountApplied = 0; // ✅ เก็บยอดส่วนลดรวมที่ใช้ไปแล้ว
  int currentPaymentMethodId = 1; // ✅ เก็บ paymentMethodId ปัจจุบัน (default: เงินสด)
  String staffName = 'unknown unknown'; // ✅ เก็บชื่อพนักงานจาก API
  late HomeController homeController;
  late PrinterController printerController;
  late OrderController orderController; // ✅ เพื่อเข้าถึงข้อมูลส่วนลด

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

    // ✅ เพิ่ม PrinterController
    printerController = Get.put(PrinterController());

    // ✅ เชื่อมต่อ OrderController ที่สร้างไว้แล้วใน HomePage
    try {
      orderController = Get.find<OrderController>();
      log('✅ Found existing OrderController with ${orderController.discounts.length} discounts');
    } catch (e) {
      log('❌ OrderController not found, creating new one');
      orderController = Get.put(OrderController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      log('⏰ PostFrameCallback: loading data');
      await homeController.checkConnectivityAndLoadData();
      log('✅ Data loading completed');
      print(homeController.currentShiftId.value);

      // ✅ เรียก checkLogin เพื่อดึงข้อมูลพนักงาน
      await _loadStaffInfo();

      // ✅ ตรวจสอบโหมดแก้ไขออเดอร์
      if (widget.editOrderId != null) {
        log('📝 Edit mode - Order ID: ${widget.editOrderId}, Number: ${widget.editOrderNumber}');
      }

      // ✅ คำนวณส่วนลดอัตโนมัติเมื่อเข้าหน้า
      _calculateAutoDiscount();

      // หลังจากโหลดข้อมูลเสร็จ ให้เช็คพาเนลและสร้างแท็บ
    });
  }

  // ✅ คำนวณยอดรวมเดิม (ก่อนหักส่วนลด)
  double get originalTotal {
    return widget.cartItems.fold(0.0, (sum, item) {
      final price = item['price'] ?? 0;
      final qty = item['qty'] ?? 1;
      return sum + (price * qty);
    });
  }

  // ✅ คำนวณยอดรวมหลังหักส่วนลด
  double calculateTotalWithDiscount() {
    final total = originalTotal - totalDiscountApplied;
    return total < 0 ? 0 : total; // ไม่ให้ติดลบ
  }

  // ✅ คำนวณส่วนลดจาก mix_match_multi_units
  double calculateDiscountFromMixMatch() {
    if (orderController.discounts.isEmpty) {
      log('⚠️ No discounts available in orderController');
      return 0.0;
    }

    try {
      log('📦 Sending to mix_match_multi_units:');
      log('   cartItems: ${widget.cartItems}');
      log('   discounts: ${orderController.discounts}');

      final calculatedDiscount = calculateDiscountFromRules(cartItems: widget.cartItems, discounts: orderController.discounts);

      log('🎯 Calculated discount from rules: ฿$calculatedDiscount');
      return calculatedDiscount;
    } catch (e) {
      log('❌ Error calculating discount from rules: $e');
      return 0.0;
    }
  }

  // ✅ คำนวณส่วนลดอัตโนมัติเมื่อเข้าหน้า
  void _calculateAutoDiscount() {
    if (orderController.discounts.isNotEmpty) {
      final autoDiscount = calculateDiscountFromMixMatch();
      if (autoDiscount > 0) {
        setState(() {
          totalDiscountApplied = autoDiscount;
          discountAmount = totalDiscountApplied;
        });
        log('💰 Auto applied discount on page load: ฿$autoDiscount');
      }
    }
  }

  // ✅ จัดการการลดราคาเพิ่มเติม (Manual Additional Discount)
  void handleDiscountSelection(double amount) {
    setState(() {
      final currentTotal = calculateTotalWithDiscount();

      // ตรวจสอบว่าสามารถลดได้อีกหรือไม่
      if (currentTotal > 0) {
        // คำนวณจำนวนที่จะลด (ไม่เกินยอดที่เหลือ)
        final discountToApply = amount > currentTotal ? currentTotal : amount;

        // เพิ่มส่วนลดสะสม (รวมกับส่วนลดอัตโนมัติที่มีอยู่แล้ว)
        totalDiscountApplied += discountToApply;
        discountAmount = totalDiscountApplied;

        log('💰 Applied additional manual discount: ฿$discountToApply, Total discount: ฿$totalDiscountApplied');

        // แสดงข้อความยืนยัน
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลดเพิ่ม ฿${discountToApply.toStringAsFixed(0)} (รวมลดแล้ว ฿${totalDiscountApplied.toStringAsFixed(0)})'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        log('⚠️ Cannot apply more discount, total is already 0');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถลดเพิ่มได้ ยอดเป็น 0 แล้ว'), backgroundColor: Colors.orange, duration: Duration(seconds: 2)),
        );
      }
    });
  }

  // ✅ เคลียร์ส่วนลดทั้งหมด และคำนวณส่วนลดอัตโนมัติใหม่
  void clearAllDiscounts() {
    setState(() {
      selectedDiscountAmount = null;
      discountAmount = 0;
      totalDiscountApplied = 0;

      log('🧹 Cleared all discounts');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('เคลียร์ส่วนลดแล้ว'), backgroundColor: Colors.green, duration: Duration(seconds: 1)));
    });

    // คำนวณส่วนลดอัตโนมัติใหม่หลังจากเคลียร์
    _calculateAutoDiscount();
  }

  // ✅ เช็คเครื่องปริ๊นเตอร์และปริ๊นใบเสร็จ
  Future<void> checkPrinterAndPrint() async {
    try {
      log('🖨️ Starting printer check and print process...');

      // ✅ ตรวจสอบปริ๊นเตอร์เริ่มต้นทันที
      final defaultPrinter = printerController.getDefaultPrinter();
      if (defaultPrinter != null) {
        log('🔍 Found printer: ${defaultPrinter.name} (${defaultPrinter.type})');

        // ✅ เช็คเร็วๆ ว่าเป็นปริ๊นเตอร์ในตัวหรือไม่ (เช็คทุกกรณี)
        bool isBuiltInPrinter = defaultPrinter.name.toLowerCase().contains('sunmi') ||
            defaultPrinter.name.toLowerCase().contains('built') ||
            defaultPrinter.name.toLowerCase().contains('internal') ||
            defaultPrinter.type.toLowerCase().contains('sunmi') ||
            defaultPrinter.type.toLowerCase().contains('built') ||
            defaultPrinter.address.isEmpty ||
            defaultPrinter.address == 'built-in' ||
            defaultPrinter.address == 'internal' ||
            !defaultPrinter.address.contains('.');

        if (isBuiltInPrinter) {
          log('✅ Built-in printer - direct print');
          await _printToDefaultPrinter(defaultPrinter);
        } else {
          log('🖨️ External printer - show preview');
          _showPrintPreviewDialog();
        }
      } else {
        log('❌ No default printer - show preview');
        _showPrintPreviewDialog();
      }
    } catch (e) {
      log('❌ Error: $e');
      _showPrintPreviewDialog();
    }
  }

  // ✅ ปริ๊นไปยัง Network Printer (แบบเดียวกับ ReceiptHistoryPage)
  Future<void> _printToNetworkPrinter(PrinterInfo printer) async {
    try {
      log('🖨️ Starting network printer process for: ${printer.name}');

      // แสดง print preview dialog และรอให้ผู้ใช้กดปริ๊น
      _showPrintPreviewDialog();
    } catch (e) {
      log('❌ Error in network printer process: $e');
      Get.snackbar('เกิดข้อผิดพลาด', 'เกิดข้อผิดพลาดในการปริ๊น: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ✅ แสดง dialog เมื่อไม่มีปริ๊นเตอร์
  void _showNoPrinterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(children: [Icon(Icons.print_disabled, color: Colors.orange), SizedBox(width: 8), Text('ไม่พบเครื่องปริ๊นเตอร์')]),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ยังไม่มีการตั้งค่าเครื่องปริ๊นเตอร์เริ่มต้น', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Text('กรุณาไปที่หน้าการตั้งค่า > เครื่องพิมพ์ เพื่อ:', style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 8),
            Text('• สแกนหาเครื่องปริ๊นเตอร์', style: TextStyle(fontSize: 14)),
            Text('• เพิ่มเครื่องปริ๊นเตอร์', style: TextStyle(fontSize: 14)),
            Text('• ตั้งค่าเป็นเครื่องปริ๊นเตอร์เริ่มต้น', style: TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ปิด')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // นำทางไปหน้าการตั้งค่า
              _navigateToSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: kTabColor),
            child: const Text('ไปตั้งค่า', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ✅ แสดง dialog พรีวิวใบเสร็จ
  void _showPrintPreviewDialog() {
    final GlobalKey previewKey = GlobalKey();

    Get.dialog(
      Dialog(
        child: Container(
          width: 400,
          height: 600,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text('พรีวิวใบเสร็จ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),

              // Receipt Preview Content
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: RepaintBoundary(
                      key: previewKey,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                        child: ReceiptPreviewWidget(
                          cartItems: widget.cartItems,
                          receivedAmount: receivedAmount,
                          changeAmount: receivedAmount - calculateTotalWithDiscount(),
                          discountAmount: totalDiscountApplied > 0 ? totalDiscountApplied : null,
                          paymentMethod: _getPaymentMethodName(),
                          staffName: staffName,
                          receiptNumber: orderReceiptNumber,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Print Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _captureAndPrintReceipt(previewKey); // แคปภาพและปริ๊นก่อน
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('ปริ๊น'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // ✅ แคปภาพจาก Widget และส่งไปปริ๊น
  Future<void> _captureAndPrintReceipt(GlobalKey key) async {
    try {
      log('📸 Starting capture and print process...');

      // เก็บ context ก่อน async gap
      final context = key.currentContext;
      if (context == null) {
        log('❌ Context is null');
        Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถแคปภาพได้ - Context หายไป');
        return;
      }

      final renderObject = context.findRenderObject();
      if (renderObject == null) {
        log('❌ RenderObject is null');
        Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถแคปภาพได้ - RenderObject หายไป');
        return;
      }

      if (renderObject is! RenderRepaintBoundary) {
        log('❌ RenderObject is not RenderRepaintBoundary');
        Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถแคปภาพได้ - ไม่ใช่ RepaintBoundary');
        return;
      }

      final boundary = renderObject;
      log('✅ Found RenderRepaintBoundary, proceeding to capture...');

      // รอให้ widget render เสร็จก่อนแคป
      await Future.delayed(const Duration(milliseconds: 300));

      // ปิด preview dialog ก่อนแสดง loading
      Get.back(); // ปิด preview dialog

      // แสดง loading dialog
      Get.dialog(
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [CircularProgressIndicator(), SizedBox(height: 16), Text('กำลังแคปภาพและปริ๊น...', style: TextStyle(color: Colors.white))],
          ),
        ),
        barrierDismissible: false,
      );

      // สร้างภาพ
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        log('❌ Cannot convert image to bytes');
        Get.back(); // ปิด loading
        Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถแปลงภาพได้');
        return;
      }

      Uint8List imageBytes = byteData.buffer.asUint8List();
      log('✅ Image captured successfully, size: ${imageBytes.length} bytes');

      // ✅ ส่งภาพไปปริ๊นเตอร์จริง
      final defaultPrinter = printerController.getDefaultPrinter();
      if (defaultPrinter != null) {
        log('🖨️ Sending to printer: ${defaultPrinter.name} (${defaultPrinter.type}) at ${defaultPrinter.address}');

        // ✅ เชื่อมต่อปริ๊นเตอร์เฉพาะตอนปริ๊น (ประหยัด RAM)
        log('📡 Connecting to printer for printing only...');
        log('🔧 Memory optimization: Connect → Print → Disconnect');
        final connectSuccess = await _connectToPrinter(defaultPrinter, printerController);
        if (!connectSuccess) {
          Get.back(); // ปิด loading
          Get.snackbar(
            'ไม่สามารถเชื่อมต่อ',
            'ไม่สามารถเชื่อมต่อกับปริ๊นเตอร์ ${defaultPrinter.name}\nIP: ${defaultPrinter.address}\nตรวจสอบการเชื่อมต่อ WiFi และสถานะปริ๊นเตอร์',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            icon: const Icon(Icons.wifi_off, color: Colors.white),
            duration: const Duration(seconds: 5),
          );
          return;
        }
        log('✅ Connected to printer - starting print job');

        // ✅ ส่งเป็นรูปภาพสำหรับทุกปริ๊นเตอร์ (รองรับภาษาไทยได้ดี)
        bool printSuccess = false;
        try {
          log('🖨️ Sending receipt as REAL bitmap image to support Thai language properly');
          log('📋 Payment details: Items: ${widget.cartItems.length}');
          log('🖼️ Image size: ${imageBytes.length} bytes');
          log('🇹🇭 Using image package to convert PNG to ESC/POS bitmap');
          log('📱 Printer: ${defaultPrinter.name} (${defaultPrinter.type})');
          log('🔍 Image data preview: ${imageBytes.take(20).toList()}...');
          log('📄 Image format: PNG → Grayscale → Monochrome bitmap → ESC/POS commands');

          // ✅ ตรวจสอบข้อมูลภาพก่อนส่ง
          if (imageBytes.isEmpty) {
            log('❌ Empty image data - cannot print');
            throw Exception('ไม่มีข้อมูลภาพสำหรับปริ๊น');
          }

          if (imageBytes.length < 100) {
            log('⚠️ Image data too small: ${imageBytes.length} bytes');
          }

          log('✅ Image data validation passed - sending to printer');

          // ส่งภาพไปปริ๊นเตอร์ทุกประเภท (รองรับภาษาไทยได้ดี)
          printSuccess = await printerController.printImage(defaultPrinter, imageBytes);

          log('📊 Print result: ${printSuccess ? 'SUCCESS' : 'FAILED'}');
        } finally {
          // ✅ ตัดการเชื่อมต่อหลังปริ๊นเสร็จ (ประหยัด RAM)
          log('🔌 Disconnecting from printer to save memory...');
        }

        Get.back(); // ปิด loading

        if (printSuccess) {
          log('✅ Image sent to printer successfully');
          Get.snackbar(
            'ปริ๊นสำเร็จ',
            'ส่งใบเสร็จไปยังเครื่องปริ๊นเตอร์ ${defaultPrinter.name} แล้ว',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 3),
          );
        } else {
          log('❌ Failed to send image to printer');
          Get.snackbar(
            'ปริ๊นล้มเหลว',
            'ไม่สามารถส่งใบเสร็จไปยังเครื่องปริ๊นเตอร์ ${defaultPrinter.name} ได้',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            icon: const Icon(Icons.error, color: Colors.white),
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        log('❌ No default printer found');
        Get.back(); // ปิด loading
        Get.snackbar(
          'ข้อผิดพลาด',
          'ไม่พบเครื่องปริ๊นเตอร์เริ่มต้น',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.warning, color: Colors.white),
        );
      }
    } catch (e) {
      log('❌ Error in capture and print: $e');
      Get.back(); // ปิด loading
      Get.snackbar('ข้อผิดพลาด', 'เกิดข้อผิดพลาดในการปริ๊น: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ✅ เชื่อมต่อปริ๊นเตอร์เฉพาะตอนปริ๊น (ประหยัด RAM)
  Future<bool> _connectToPrinter(PrinterInfo printer, PrinterController printerController) async {
    try {
      log('🔌 Connecting to printer: ${printer.name} (${printer.address})');
      log('💾 Memory-efficient connection: Only for printing session');

      // ทดสอบการเชื่อมต่อ 2 ครั้ง
      for (int attempt = 1; attempt <= 2; attempt++) {
        log('🔄 Connection attempt $attempt/2...');
        final isConnected = await printerController.testPrinterConnection(printer, showSnackbar: false);
        if (isConnected) {
          log('✅ Printer connected successfully on attempt $attempt');
          log('📡 Connection established - ready for print job');
          return true;
        }

        if (attempt < 2) {
          log('⚠️ Connection failed on attempt $attempt, retrying...');
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      log('❌ Failed to connect to printer after 2 attempts');
      log('💾 No persistent connection - memory saved');
      return false;
    } catch (e) {
      log('❌ Error connecting to printer: $e');
      return false;
    }
  }

  // ✅ ปริ๊นแบบบังคับ (ไม่ตรวจสอบปริ๊นเตอร์)
  Future<void> _forcePrintReceipt() async {
    try {
      log('🖨️ Force printing receipt...');

      final totalWithDiscount = calculateTotalWithDiscount();
      final changeAmount = receivedAmount - totalWithDiscount;

      // เรียกใช้ฟังก์ชันปริ๊นจาก helper
      await printReceiptFromCartItems(
        widget.cartItems,
        receivedAmount: receivedAmount,
        changeAmount: changeAmount,
        discountAmount: totalDiscountApplied > 0 ? totalDiscountApplied : null,
        paymentMethod: _getPaymentMethodName(),
        staffName: staffName,
      );

      log('✅ Force print completed');
    } catch (e) {
      log('❌ Error in force print: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาดในการปริ๊น: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // ✅ แสดง dialog เมื่อเชื่อมต่อปริ๊นเตอร์ไม่ได้
  void _showPrinterConnectionErrorDialog(PrinterInfo printer) {
    Get.dialog(
      AlertDialog(
        title: const Row(children: [Icon(Icons.error_outline, color: Colors.red), SizedBox(width: 8), Text('เชื่อมต่อปริ๊นเตอร์ไม่ได้')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ไม่สามารถเชื่อมต่อกับเครื่องปริ๊นเตอร์ "${printer.name}" ได้', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ประเภท: ${printer.type}', style: const TextStyle(fontSize: 14)),
                  Text('ที่อยู่: ${printer.address}', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('กรุณาตรวจสอบ:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('• เครื่องปริ๊นเตอร์เปิดอยู่', style: TextStyle(fontSize: 14)),
            const Text('• สายเชื่อมต่อหรือ WiFi ทำงานปกติ', style: TextStyle(fontSize: 14)),
            const Text('• เครื่องปริ๊นเตอร์อยู่ในเครือข่ายเดียวกัน', style: TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ปิด')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              // ลองทดสอบการเชื่อมต่อใหม่
              await printerController.testPrinterConnection(printer);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('ทดสอบใหม่', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ✅ โหลดข้อมูลพนักงานจาก API
  Future<void> _loadStaffInfo() async {
    try {
      final staffData = await homeController.checkLogin();
      if (staffData != null && mounted) {
        setState(() {
          final firstName = staffData['firstName'] ?? '';
          final lastName = staffData['lastName'] ?? '';
          staffName = '$firstName $lastName'.trim();
          if (staffName.isEmpty) {
            staffName = 'unknown unknown';
          }
        });
        log('✅ Staff info loaded: $staffName');
      }
    } catch (e) {
      log('❌ Error loading staff info: $e');
      // ใช้ค่า default ถ้าเกิด error
      if (mounted) {
        setState(() {
          staffName = 'unknown unknown';
        });
      }
    }
  }

  // ✅ ได้ชื่อวิธีการชำระเงินจาก paymentMethodId ปัจจุบัน
  String _getPaymentMethodName() {
    switch (currentPaymentMethodId) {
      case 1:
        return 'เงินสด';
      case 2:
        return 'โอน';
      case 3:
        return 'เครดิต';
      default:
        return 'เงินสด';
    }
  }

  // ✅ ปริ๊นไปยังปริ๊นเตอร์เริ่มต้น
  Future<void> _printToDefaultPrinter(PrinterInfo printer) async {
    try {
      log('🖨️ Printing to ${printer.name} (${printer.type})...');

      // ในการใช้งานจริง จะต้องใช้ library ที่เหมาะสมกับประเภทปริ๊นเตอร์
      // ตอนนี้ใช้ฟังก์ชันเดิมก่อน
      final total = calculateTotalWithDiscount();
      // ✅ ใช้ค่าเงินทอนจริงที่คำนวณจากการกดปุ่ม
      final changeAmount = receivedAmount - total;

      // ✅ ส่งข้อมูลเพิ่มเติมไปยังฟังก์ชันปริ๊น
      await printReceiptFromCartItems(
        widget.cartItems,
        receivedAmount: receivedAmount,
        changeAmount: changeAmount,
        discountAmount: totalDiscountApplied > 0 ? totalDiscountApplied : null,
        paymentMethod: _getPaymentMethodName(),
        staffName: staffName,
        receiptNumber: orderReceiptNumber, // ✅ ส่งเลขที่ใบเสร็จไปด้วย
      );

      log('✅ Print completed successfully');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ปริ๊นใบเสร็จไปยัง ${printer.name} สำเร็จ'), backgroundColor: Colors.green));
      }
    } catch (e) {
      log('❌ Print failed: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ปริ๊นใบเสร็จล้มเหลว: $e'), backgroundColor: Colors.red));
      }

      // แสดง dialog แนะนำให้ตรวจสอบปริ๊นเตอร์
      _showPrintFailedDialog(printer, e.toString());
    }
  }

  // ✅ แสดง dialog เมื่อปริ๊นล้มเหลว
  void _showPrintFailedDialog(PrinterInfo printer, String error) {
    Get.dialog(
      AlertDialog(
        title: const Row(children: [Icon(Icons.print_disabled, color: Colors.red), SizedBox(width: 8), Text('ปริ๊นล้มเหลว')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ไม่สามารถปริ๊นใบเสร็จไปยัง "${printer.name}" ได้'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(4)),
              child: Text('ข้อผิดพลาด: $error', style: TextStyle(fontSize: 12, color: Colors.red[700])),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ปิด')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // ลองปริ๊นใหม่
              checkPrinterAndPrint();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('ลองใหม่', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ✅ นำทางไปหน้าการตั้งค่า
  void _navigateToSettings() {
    // ปิดหน้าปัจจุบันและกลับไปหน้าหลัก แล้วไปหน้าการตั้งค่า
    Navigator.of(context).popUntil((route) => route.isFirst);

    // ใช้ Navigator.pushNamed หรือวิธีอื่นตามโครงสร้างของแอป
    // ตัวอย่าง: ถ้ามี SettingsPage
    // Navigator.pushNamed(context, '/settings');

    // หรือถ้าใช้ GetX
    // Get.offAllNamed('/settings');

    // สำหรับตอนนี้ให้แสดงข้อความแทน
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('กรุณาไปที่เมนูการตั้งค่า > เครื่องพิมพ์ เพื่อตั้งค่าปริ๊นเตอร์'), duration: Duration(seconds: 3)));
  }

  Future<void> createOrders({required int paymentMethodId}) async {
    try {
      final total = calculateTotalWithDiscount();

      // ✅ ตรวจสอบและ void ออเดอร์เดิมก่อน (ถ้าเป็นโหมดแก้ไข)
      if (widget.editOrderId != null) {
        log('🔄 Edit mode detected, voiding original order ID: ${widget.editOrderId}');

        try {
          final voidResult = await Homeservice.voidOrder(orderId: widget.editOrderId!);
          log('📋 Void order result: $voidResult');

          if (voidResult != null && voidResult is Map<String, dynamic>) {
            final orderStatus = voidResult['orderStatus'] as String?;

            if (orderStatus == 'void') {
              log('✅ Original order voided successfully');
              // แสดงข้อความแจ้งเตือน
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ยกเลิกออเดอร์เดิม ${widget.editOrderNumber} สำเร็จ'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } else {
              throw Exception('ไม่สามารถยกเลิกออเดอร์เดิมได้ สถานะ: $orderStatus');
            }
          } else {
            throw Exception('ไม่ได้รับข้อมูลการยกเลิกออเดอร์');
          }
        } catch (e) {
          log('❌ Error voiding original order: $e');
          throw Exception('ไม่สามารถยกเลิกออเดอร์เดิมได้: $e');
        }
      }

      // ✅ โหลดข้อมูล device ก่อนเพื่อให้แน่ใจว่ามี deviceId
      await homeController.loadDeviceInfo();

      // ✅ ใช้ device internal ID ที่บันทึกไว้แทนเลข 1
      final currentDeviceInternalId = homeController.getCurrentDeviceInternalId();
      final deviceIdToUse = currentDeviceInternalId ?? 1; // ใช้ 1 เป็น fallback

      print('📱 Device info loaded for order: ${homeController.deviceInfo.isNotEmpty}');
      print('📱 Current device internal ID: $currentDeviceInternalId');
      print('📱 Using device ID for order: $deviceIdToUse');

      final formattedOrder = {
        "deviceId": deviceIdToUse,
        "shiftId": homeController.currentShiftId.value,
        "branchId": 1,
        "total": total,
        "memberId": null,
        "date": DateTime.now().toIso8601String(),
        "orderItems": widget.cartItems.map((item) {
          return {
            "productId": item["id"] ?? 0,
            "productName": item["name"] ?? 0,
            "price": item["price"] ?? 0,
            "quantity": item["qty"] ?? 0,
            "total": item["price"] * item["qty"] ?? 0,
          };
        }).toList(),
        "paymentMethodId": paymentMethodId,
        "paid": receivedAmount,
        "change": receivedAmount - total, // ✅ ใช้ค่าเงินทอนจริงจากการกดปุ่ม
        "discount": totalDiscountApplied,
        "remark": totalDiscountApplied > 0 ? "ส่วนลดรวม ฿${totalDiscountApplied.toStringAsFixed(0)}" : "string",
      };

      print("📦 JSON ที่จะส่ง: $formattedOrder");
      final order = await Homeservice.createOrderOffline(formattedOrder: formattedOrder);
      if (!mounted) return;

      // ✅ เก็บเลขที่ใบเสร็จจาก response
      if (order != null && order['id'] != null) {
        orderReceiptNumber = order['orderNo'].toString();
        log('✅ Order created with receipt number: $orderReceiptNumber');
      }

      setState(() {});
    } catch (e) {
      // handle error
      log('❌ Error creating order: $e');
      Get.snackbar('ข้อผิดพลาด', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ย้ายการคำนวณไปใน CartSummaryWidget แล้ว
    final double total = calculateTotalWithDiscount();

    return Scaffold(
      backgroundColor: Colors.white,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Column(
          children: [
            ProductHeader(),

            // ✅ แสดงข้อมูลออเดอร์ที่แก้ไข
            if (widget.editOrderId != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.orange[50],
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'กำลังแก้ไขออเดอร์: ${widget.editOrderNumber ?? widget.editOrderId}',
                      style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],

            Expanded(
              child: Row(
                children: [
                  // ✅ ใช้ CartSummaryWidget แทน
                  Expanded(
                    flex: 2,
                    child: CartSummaryWidget(
                      cartItems: widget.cartItems,
                      selectedDiscountAmount: totalDiscountApplied > 0 ? totalDiscountApplied : null,
                      discountAmount: totalDiscountApplied,
                    ),
                  ),

                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ ใช้ PaymentDisplayWidget แทน
                          PaymentDisplayWidget(total: total, receivedAmount: receivedAmount),

                          const SizedBox(height: 24),

                          if (!isPaid) ...[
                            const Text('จำนวนรับ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('฿${receivedAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                                OutlinedButton(
                                  onPressed: () async {
                                    final amount = await showDialog<double>(
                                      context: context,
                                      builder: (context) {
                                        double tempAmount = 0;
                                        return AlertDialog(
                                          title: const Text("ใส่จำนวนเงิน"),
                                          content: TextField(
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(hintText: 'เช่น 500'),
                                            onChanged: (value) {
                                              tempAmount = double.tryParse(value) ?? 0;
                                            },
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text("ตกลง"),
                                              onPressed: () {
                                                Navigator.of(context).pop(tempAmount);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (amount != null && amount > 0) {
                                      setState(() {
                                        receivedAmount = amount;
                                      });
                                    }
                                  },
                                  child: const Text("จำนวนเงิน", style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // ✅ ใช้ Wrap โดยตรงเพื่อให้ปุ่มสามารถลงมาข้างล่างได้เมื่อเกิน
                            Wrap(
                              alignment: WrapAlignment.start,
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                // ✅ ปุ่มรับเงินพอดี
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      receivedAmount = calculateTotalWithDiscount();
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.green),
                                    backgroundColor: Colors.green[50],
                                    fixedSize: Size(130, 48),
                                  ),
                                  child: Text('รับเงินพอดี', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                ),
                                // ปุ่มจำนวนเงินต่างๆ
                                for (final amount in [100, 200, 500, 1000])
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        receivedAmount = amount.toDouble();
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.grey),
                                      backgroundColor: Colors.white,
                                      fixedSize: Size(130, 48), // ✅ เพิ่มความกว้างตรงนี้
                                    ),
                                    child: Text('฿${amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black)),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                // 🔹 เงินสด
                                Expanded(
                                  child: Card(
                                    elevation: 4, // เพิ่มเงา
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: InkWell(
                                      onTap: () {
                                        // ✅ แสดง dialog ยืนยันการชำระด้วยเงินสด
                                        if (receivedAmount >= total) {
                                          PaymentConfirmDialog.show(
                                            context: context,
                                            paymentMethod: 'เงินสด',
                                            icon: Icons.payments,
                                            paymentMethodId: 1, // paymentMethodId สำหรับเงินสด
                                            autoSetAmount: false, // ไม่ auto set receivedAmount
                                            total: total,
                                            receivedAmount: receivedAmount,
                                            onCancel: () => Get.back(),
                                            onConfirm: (paymentMethodId, autoSetAmount) async {
                                              // ✅ เก็บ paymentMethodId สำหรับการปริ๊น
                                              setState(() {
                                                currentPaymentMethodId = paymentMethodId;
                                              });

                                              // ✅ ตั้งค่า receivedAmount สำหรับโอนและเครดิต
                                              if (autoSetAmount) {
                                                setState(() {
                                                  receivedAmount = total;
                                                });
                                              }

                                              // ✅ ตรวจสอบจำนวนเงินสำหรับเงินสด
                                              if (!autoSetAmount && receivedAmount < total) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('จำนวนที่รับชำระไม่เพียงพอ'), backgroundColor: Colors.red),
                                                );
                                                return;
                                              }

                                              // ✅ ดำเนินการชำระเงิน
                                              setState(() {
                                                isPaid = true;
                                              });

                                              await createOrders(paymentMethodId: paymentMethodId);
                                            },
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(const SnackBar(content: Text('จำนวนที่ชำระไม่พอ'), backgroundColor: Colors.red));
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // ✅ สูงขึ้น
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.payments, color: Colors.black, size: 32), // ✅ ใหญ่ขึ้น
                                            SizedBox(height: 8),
                                            Text("เงินสด", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // 🔹 โอน
                                Expanded(
                                  child: Card(
                                    elevation: 4,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: InkWell(
                                      onTap: () {
                                        // ✅ แสดง dialog ยืนยันการชำระด้วยโอน
                                        PaymentConfirmDialog.show(
                                          context: context,
                                          paymentMethod: 'โอน',
                                          icon: Icons.account_balance,
                                          paymentMethodId: 2, // paymentMethodId สำหรับโอน
                                          autoSetAmount: true, // auto set receivedAmount = total
                                          total: total,
                                          receivedAmount: receivedAmount,
                                          onCancel: () => Get.back(),
                                          onConfirm: (paymentMethodId, autoSetAmount) async {
                                            // ✅ เก็บ paymentMethodId สำหรับการปริ๊น
                                            setState(() {
                                              currentPaymentMethodId = paymentMethodId;
                                            });

                                            // ✅ ตั้งค่า receivedAmount สำหรับโอนและเครดิต
                                            if (autoSetAmount) {
                                              setState(() {
                                                receivedAmount = total;
                                              });
                                            }

                                            // ✅ ตรวจสอบจำนวนเงินสำหรับเงินสด
                                            if (!autoSetAmount && receivedAmount < total) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(const SnackBar(content: Text('จำนวนที่รับชำระไม่เพียงพอ'), backgroundColor: Colors.red));
                                              return;
                                            }

                                            // ✅ ดำเนินการชำระเงิน
                                            setState(() {
                                              isPaid = true;
                                            });

                                            await createOrders(paymentMethodId: paymentMethodId);
                                          },
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.account_balance, color: Colors.black, size: 32),
                                            SizedBox(height: 8),
                                            Text("โอน", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // 🔹 เครดิต
                                Expanded(
                                  child: Card(
                                    elevation: 4,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: InkWell(
                                      onTap: () {
                                        // ✅ แสดง dialog ยืนยันการชำระด้วยเครดิต
                                        PaymentConfirmDialog.show(
                                          context: context,
                                          paymentMethod: 'เครดิต',
                                          icon: Icons.add_card,
                                          paymentMethodId: 3, // paymentMethodId สำหรับเครดิต
                                          autoSetAmount: true, // auto set receivedAmount = total
                                          total: total,
                                          receivedAmount: receivedAmount,
                                          onCancel: () => Get.back(),
                                          onConfirm: (paymentMethodId, autoSetAmount) async {
                                            // ✅ เก็บ paymentMethodId สำหรับการปริ๊น
                                            setState(() {
                                              currentPaymentMethodId = paymentMethodId;
                                            });

                                            // ✅ ตั้งค่า receivedAmount สำหรับโอนและเครดิต
                                            if (autoSetAmount) {
                                              setState(() {
                                                receivedAmount = total;
                                              });
                                            }

                                            // ✅ ตรวจสอบจำนวนเงินสำหรับเงินสด
                                            if (!autoSetAmount && receivedAmount < total) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(const SnackBar(content: Text('จำนวนที่รับชำระไม่เพียงพอ'), backgroundColor: Colors.red));
                                              return;
                                            }

                                            // ✅ ดำเนินการชำระเงิน
                                            setState(() {
                                              isPaid = true;
                                            });

                                            await createOrders(paymentMethodId: paymentMethodId);
                                          },
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.add_card, color: Colors.black, size: 32),
                                            SizedBox(height: 8),
                                            Text("เครดิต", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // ✅ ส่วนลดราคา
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('ลดราคา', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                                if (totalDiscountApplied > 0) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.red.shade300, width: 1.5),
                                    ),
                                    child: Text(
                                      'ลดไปแล้ว ฿${totalDiscountApplied.toStringAsFixed(0)}',
                                      style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),

                            // ✅ ปุ่มลดราคา (ทุกปุ่มทำงานเหมือนกัน)
                            Row(
                              children: [
                                for (final amount in [1.0, 2.0, 5.0, 10.0])
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 3),
                                      child: ElevatedButton(
                                        onPressed: () => handleDiscountSelection(amount),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange.shade400,
                                          foregroundColor: Colors.white,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        child: Text(
                                          'ลด ฿${amount.toStringAsFixed(0)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            // ✅ ปุ่มเคลียร์ (รีเซ็ตราคากลับเป็นเหมือนเดิม)
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: totalDiscountApplied > 0 ? clearAllDiscounts : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: totalDiscountApplied > 0 ? Colors.green.shade500 : Colors.grey.shade300,
                                  foregroundColor: Colors.white,
                                  elevation: totalDiscountApplied > 0 ? 2 : 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                icon: Icon(Icons.refresh, color: totalDiscountApplied > 0 ? Colors.white : Colors.grey.shade600, size: 20),
                                label: Text(
                                  totalDiscountApplied > 0 ? 'เคลียร์ - กลับเป็นราคาเดิม' : 'ไม่มีส่วนลดที่จะเคลียร์',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: totalDiscountApplied > 0 ? Colors.white : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'กรอกอีเมล์',
                                  prefixIcon: Icon(Icons.email),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            // ✅ ปุ่มปริ๊นพร้อมสถานะการเชื่อมต่อ
                            Obx(() {
                              final isConnected = printerController.isDefaultPrinterConnected.value;
                              final connectionStatus = printerController.connectionStatus.value;

                              return Column(
                                children: [
                                  // แสดงสถานะการเชื่อมต่อ
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isConnected ? Colors.green.shade50 : Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: isConnected ? Colors.green.shade200 : Colors.orange.shade200, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isConnected ? Icons.check_circle : Icons.warning,
                                          color: isConnected ? Colors.green.shade600 : Colors.orange.shade600,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            connectionStatus,
                                            style: TextStyle(fontSize: 12, color: isConnected ? Colors.green.shade700 : Colors.orange.shade700),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // ปุ่มปริ๊น
                                  GestureDetector(
                                    onTap: () async {
                                      await checkPrinterAndPrint();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: isConnected ? Colors.blue.shade100 : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                        border: isConnected ? Border.all(color: Colors.blue.shade300) : null,
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.print, color: isConnected ? Colors.blue.shade700 : Colors.black),
                                            const SizedBox(width: 8),
                                            Text(
                                              'พิมพ์ใบเสร็จ',
                                              style: TextStyle(
                                                color: isConnected ? Colors.blue.shade700 : Colors.black,
                                                fontWeight: isConnected ? FontWeight.w600 : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),

                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kTabColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  // ✅ เคลียร์ข้อมูลออเดอร์ที่แก้ไขใน HomeController
                                  final homeController = Get.find<HomeController>();
                                  homeController.editOrderId = null;
                                  homeController.editOrderNumber = null;

                                  Navigator.pop(context, true);
                                },
                                icon: const Icon(Icons.check, color: Colors.white),
                                label: const Text('เริ่มรายการใหม่', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHiddenReceiptWidget() {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: RepaintBoundary(
          key: receiptKey,
          child: Container(
            color: Colors.white,
            width: 384, // 80mm ขนาดพอดีของ Sunmi
            padding: const EdgeInsets.all(16),
            child: ReceiptWidget(cartItems: widget.cartItems, total: calculateCartTotal(widget.cartItems)),
          ),
        ),
      ),
    );
  }
}
