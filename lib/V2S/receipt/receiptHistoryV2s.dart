import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/V2S/widgets/AppDrawerv2s.dart';
import 'package:posashastd/D2S/controllers/order_controller.dart';
import 'package:posashastd/D2S/controllers/printer_controller.dart';
import 'package:posashastd/helpers/printReceiptFromCartItemsV2s.dart';
import 'package:posashastd/constants.dart';
import 'package:intl/intl.dart';
import 'package:posashastd/D2S/home/widgets/ReceiptPreviewWidget.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';

class ReceiptHistoryV2s extends StatefulWidget {
  const ReceiptHistoryV2s({super.key});

  @override
  State<ReceiptHistoryV2s> createState() => _ReceiptHistoryV2sState();
}

class _ReceiptHistoryV2sState extends State<ReceiptHistoryV2s> {
  late OrderController orderController;

  @override
  void initState() {
    super.initState();
    log('🏠 ReceiptHistoryV2s initState called');

    // ลบ controller เก่าและสร้างใหม่เพื่อให้แน่ใจว่าข้อมูลจะถูกโหลดใหม่
    if (Get.isRegistered<OrderController>()) {
      log('🗑️ Deleting existing OrderController');
      Get.delete<OrderController>();
    }

    orderController = Get.put(OrderController());
    log('📱 OrderController created: ${orderController.hashCode}');

    // เรียก API เมื่อหน้าโหลด
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log('⏰ PostFrameCallback: calling fetchOrders');
      orderController.fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawerv2s(),
      appBar: AppBar(
        title: Text('ใบเสร็จรับเงิน', style: TextStyle(fontFamily: 'IBMPlexSansThai')),
        backgroundColor: ktextColr,
        iconTheme: const IconThemeData(color: Colors.white), // 🔸 เปลี่ยนสีไอคอน
        titleTextStyle: const TextStyle(
          color: Colors.white, // 🔸 เปลี่ยนสีตัวหนังสือ
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      body: Column(
        children: [
          // 🔍 ช่องค้นหา
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ค้นหา...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                orderController.searchQuery.value = value;
              },
            ),
          ),

          // 🔘 รายการใบเสร็จ
          Expanded(
            child: Obx(() {
              if (orderController.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.green),
                      const SizedBox(height: 16),
                      Text('กำลังโหลดข้อมูล...', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                );
              }

              final orders = orderController.filteredOrders;
              if (orders.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('ไม่มีข้อมูลใบเสร็จ', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(onRefresh: orderController.refreshOrders, child: _buildGroupedOrdersList(orders));
            }),
          ),
        ],
      ),
    );
  }

  // สร้างรายการที่แบ่งตามวันที่
  Widget _buildGroupedOrdersList(List orders) {
    // จัดกลุ่มออเดอร์ตามวันที่
    final Map<String, List> groupedOrders = {};

    for (final order in orders) {
      final dateKey = _getDateKey(order.orderDate);
      if (groupedOrders[dateKey] == null) {
        groupedOrders[dateKey] = [];
      }
      groupedOrders[dateKey]!.add(order);
    }

    // เรียงลำดับวันที่จากใหม่ไปเก่า
    final sortedKeys = groupedOrders.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final ordersForDate = groupedOrders[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header วันที่
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ktextColr.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ktextColr.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: ktextColr, size: 20),
                  const SizedBox(width: 8),
                  Text(_formatDateHeader(dateKey), style: TextStyle(color: ktextColr, fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: ktextColr, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '${ordersForDate.length} รายการ',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // รายการออเดอร์ในวันนั้น
            ...ordersForDate.map((order) => _buildReceiptItemFromAPI(order)),
          ],
        );
      },
    );
  }

  // สร้าง key สำหรับจัดกลุ่มตามวันที่
  String _getDateKey(DateTime? dateTime) {
    if (dateTime == null) return 'unknown';

    final adjustedDate = dateTime.add(const Duration(hours: 7));
    return DateFormat('yyyy-MM-dd').format(adjustedDate);
  }

  // จัดรูปแบบ header วันที่
  String _formatDateHeader(String dateKey) {
    if (dateKey == 'unknown') return 'ไม่ระบุวันที่';

    try {
      final date = DateTime.parse(dateKey);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final targetDate = DateTime(date.year, date.month, date.day);

      if (targetDate == today) {
        return 'วันนี้ (${DateFormat('d MMM yyyy', 'th').format(date)})';
      } else if (targetDate == yesterday) {
        return 'เมื่อวาน (${DateFormat('d MMM yyyy', 'th').format(date)})';
      } else {
        return DateFormat('d MMM yyyy', 'th').format(date);
      }
    } catch (e) {
      return dateKey;
    }
  }

  Widget _buildReceiptItemFromAPI(order) {
    // คำนวณยอดรวม
    double grandTotal = 0.0;
    if (order.grandTotal != null) {
      grandTotal = order.grandTotal!.toDouble();
    }

    // จัดรูปแบบเวลา
    String timeString = '';
    if (order.orderDate != null) {
      // ✅ เพิ่ม 7 ชั่วโมงก่อนแสดงเวลา
      final adjustedTime = order.orderDate!.add(const Duration(hours: 7));
      final hour = adjustedTime.hour;
      final minute = adjustedTime.minute.toString().padLeft(2, '0');

      // Debug: แสดงเวลาก่อนและหลังปรับ
      log('🕐 Original time: ${order.orderDate}');
      log('🕐 Adjusted time: $adjustedTime');
      log('🕐 Hour: $hour, Minute: $minute');

      final period = hour >= 12 ? 'หลังเที่ยง' : 'ก่อนเที่ยง';
      final displayHour =
          hour == 0
              ? 12
              : (hour > 12
                  ? hour - 12
                  : hour == 12
                  ? 12
                  : hour);
      timeString = '$displayHour:$minute $period';

      log('🕐 Final display: $timeString');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.receipt_long, color: Colors.green, size: 40),
        title: Text(order.orderNo ?? '#-', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('฿${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (timeString.isNotEmpty) Text(timeString, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        onTap: () => _showOrderDetail(order),
      ),
    );
  }

  // แสดงรายละเอียดออเดอร์
  void _showOrderDetail(order) {
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
                color: Colors.blue.shade600,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt_long, color: Colors.white, size: 28),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'ใบเสร็จ ${order.orderNo ?? '#-'}',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, color: Colors.white, size: 24), padding: EdgeInsets.zero),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // รายละเอียดออเดอร์แบบเดียวกับ ReceiptHistoryPage
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ยอดรวมใหญ่ตรงกลาง
                          Center(
                            child: Text(
                              '฿${(order.total ?? 0).toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Center(child: Text('รวมทั้งหมด', style: TextStyle(fontSize: 18))),
                          const SizedBox(height: 16),

                          // ข้อมูลพนักงานและระบบ
                          Text('พนักงาน: ${order.shift?.user?.username ?? 'ไม่ระบุ'}', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 4),
                          Text('ระบบขาย: ${order.device?.name ?? 'POS 1'}', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 16),

                          // แสดงรายการสินค้า
                          if (order.orderItems != null && order.orderItems!.isNotEmpty) ...[
                            ...order.orderItems!.map(
                              (item) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product?.name ?? 'ไม่ระบุชื่อสินค้า', style: const TextStyle(fontSize: 18)),
                                  Text('${item.quantity ?? 0} x ฿${(item.price ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ],

                          const Divider(height: 24),
                          _buildRow('รวมทั้งหมด', '฿${(order.total ?? 0).toStringAsFixed(2)}'),
                          _buildRow('ชำระแล้ว', '฿${(order.paid != null ? double.tryParse(order.paid!.toString()) ?? 0 : 0).toStringAsFixed(2)}'),
                          _buildRow('เงินทอน', '฿${(order.change ?? 0).toStringAsFixed(2)}'),
                          const SizedBox(height: 16),
                          _buildRow(_formatDateTime(order.orderDate), order.orderNo ?? '#-'),
                        ],
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
                      child: ElevatedButton.icon(
                        onPressed: () {
                          log('🖨️ Print button pressed for order: ${order.orderNo}');
                          _printReceipt(order);
                        },
                        icon: const Icon(Icons.print, color: Colors.white, size: 18),
                        label: const Text('ปริ๊นใบเสร็จ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      isDismissible: true,
      enableDrag: true,
    );
  }

  // ฟังก์ชันปริ๊นใบเสร็จ
  Future<void> _printReceipt(order) async {
    try {
      log('🖨️ Starting print receipt for order: ${order.orderNo}');

      // ตรวจสอบว่ามี PrinterController หรือไม่
      PrinterController printerController;
      if (Get.isRegistered<PrinterController>()) {
        printerController = Get.find<PrinterController>();
        log('✅ Found existing PrinterController');
      } else {
        printerController = Get.put(PrinterController());
        log('🆕 Created new PrinterController');
      }

      // ✅ โหลดข้อมูลปริ๊นเตอร์ก่อนตรวจสอบ
      await printerController.loadSavedPrinters();

      // ✅ ตรวจสอบปริ๊นเตอร์เริ่มต้นทันที
      final defaultPrinter = printerController.getDefaultPrinter();
      if (defaultPrinter != null) {
        log('🔍 Found printer: ${defaultPrinter.name} (${defaultPrinter.type})');

        // ✅ เช็คเร็วๆ ว่าเป็นปริ๊นเตอร์ในตัวหรือไม่ (เช็คทุกกรณี)
        bool isBuiltInPrinter =
            defaultPrinter.name.toLowerCase().contains('sunmi') ||
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
          await _printToSunmi(order);
        } else {
          log('🖨️ External printer - show preview');
          _showPrintPreviewDialog(order);
        }
      } else {
        log('❌ No default printer - show preview');
        _showPrintPreviewDialog(order);
      }
    } catch (e) {
      log('❌ Error: $e');
      _showPrintPreviewDialog(order);
    }
  }

  // ✅ ปริ๊นไปยัง Sunmi โดยตรง
  Future<void> _printToSunmi(order) async {
    try {
      // แปลงข้อมูล OrderItems เป็น cartItems format
      final cartItems = _convertOrderToCartItems(order);

      // คำนวณข้อมูลการชำระเงิน
      final grandTotal = (order.total ?? 0).toDouble();
      final paid = (order.paid != null ? double.tryParse(order.paid!.toString()) ?? 0 : 0).toDouble();
      final change = (order.change ?? 0).toDouble();
      final discount = (order.discount ?? 0).toDouble();

      // ข้อมูลพนักงาน (ถ้ามี)
      final staffName = order.shift?.user?.username ?? 'พนักงาน';

      log('💰 Payment info - Total: $grandTotal, Paid: $paid, Change: $change, Discount: $discount');

      // เรียกใช้ฟังก์ชันปริ๊นเดียวกับ PaymentPagev2s
      await printReceiptFromCartItemsV2s(
        cartItems,
        receivedAmount: paid,
        changeAmount: change,
        discountAmount: discount > 0 ? discount : null,
        paymentMethod: 'เงินสด', // ค่าเริ่มต้น
        staffName: staffName,
        receiptNumber: order.orderNo, // ใช้ orderNo เป็นเลขที่ใบเสร็จ
      );

      log('✅ Receipt printed successfully');

      // แสดงข้อความยืนยัน
      Get.snackbar(
        'ปริ๊นสำเร็จ',
        'ปริ๊นใบเสร็จ ${order.orderNo} เรียบร้อยแล้ว',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      log('❌ Error printing to Sunmi: $e');
      Get.snackbar(
        'เกิดข้อผิดพลาด',
        'ไม่สามารถปริ๊นใบเสร็จได้: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ✅ ปริ๊นไปยัง Network Printer (แบบเดียวกับ ReceiptHistoryPage)
  Future<void> _printToNetworkPrinter(order, PrinterInfo printer) async {
    try {
      log('🖨️ Starting network printer process for: ${printer.name}');

      // แสดง print preview dialog และรอให้ผู้ใช้กดปริ๊น
      _showPrintPreviewDialog(order);
    } catch (e) {
      log('❌ Error in network printer process: $e');
      Get.snackbar('เกิดข้อผิดพลาด', 'เกิดข้อผิดพลาดในการปริ๊น: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ✅ แปลงข้อมูล Order เป็น cartItems format
  List<Map<String, dynamic>> _convertOrderToCartItems(order) {
    final cartItems = <Map<String, dynamic>>[];

    if (order.orderItems != null) {
      for (final orderItem in order.orderItems!) {
        cartItems.add({'name': orderItem.product?.name ?? 'ไม่มีชื่อ', 'qty': orderItem.quantity ?? 1, 'price': (orderItem.price ?? 0).toDouble()});
      }
    }

    log('📦 Converted cart items: ${cartItems.length} items');
    return cartItems;
  }

  // ✅ แสดง Print Preview แบบเต็มจอสำหรับ V2S (ขนาดกระดาษ 80mm)
  void _showPrintPreviewDialog(order) {
    final GlobalKey previewKey = GlobalKey();
    final cartItems = _convertOrderToCartItems(order);

    // คำนวณข้อมูลการชำระเงิน
    final paid = (order.paid != null ? double.tryParse(order.paid!.toString()) ?? 0 : 0).toDouble();
    final grandTotal = (order.grandTotal != null ? double.tryParse(order.grandTotal!.toString()) ?? 0 : 0).toDouble();
    final change = paid - grandTotal;
    final discount = (order.discount ?? 0).toDouble();
    final staffName = order.shift?.user?.username ?? 'พนักงาน';

    // ✅ แสดงเต็มจอแทน Dialog
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.grey[100],
              appBar: AppBar(
                backgroundColor: ktextColr,
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                title: Text('พรีวิวใบเสร็จ ${order.orderNo}', style: const TextStyle(color: Colors.white)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.print, color: Colors.white),
                    onPressed: () async {
                      await _captureAndPrintReceipt(previewKey, order);
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  // ✅ ข้อมูลสรุป
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('ยอดรวม', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('฿${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('รับเงิน', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(
                              '฿${paid.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('เงินทอน', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(
                              '฿${change.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ✅ พรีวิวใบเสร็จ (ขนาดกระดาษ 80mm)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 320, // ขนาดกระดาษ 80mm = 320 pixels (4:1 ratio)
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SingleChildScrollView(
                            child: RepaintBoundary(
                              key: previewKey,
                              child: Container(
                                width: 320, // กำหนดความกว้างให้เท่ากับกระดาษ 80mm
                                color: Colors.white,
                                child: ReceiptPreviewWidget(
                                  cartItems: cartItems,
                                  receivedAmount: paid,
                                  changeAmount: change,
                                  discountAmount: discount > 0 ? discount : null,
                                  paymentMethod: 'เงินสด',
                                  staffName: staffName,
                                  receiptNumber: order.orderNo,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ✅ ปุ่มปริ๊น (ด้านล่าง)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            label: const Text('ปิด'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _captureAndPrintReceipt(previewKey, order);
                            },
                            icon: const Icon(Icons.print, color: Colors.white),
                            label: const Text('ปริ๊นใบเสร็จ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  // ✅ แคปภาพจาก Widget และส่งไปปริ๊น
  Future<void> _captureAndPrintReceipt(GlobalKey key, order) async {
    try {
      log('📸 Starting capture and print process for order: ${order.orderNo}');

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
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(32),
              constraints: const BoxConstraints(minWidth: 280, maxWidth: 320),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.print, color: Colors.blue, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), strokeWidth: 3),
                  const SizedBox(height: 16),
                  const Text('กำลังปริ๊น...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text('กรุณารอสักครู่', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: true,
      );

      // ✅ ตั้งเวลาปิด dialog อัตโนมัติหลัง 3 วินาที
      Timer(const Duration(seconds: 3), () {
        if (Get.isDialogOpen == true) {
          Get.back(); // ปิด loading dialog อัตโนมัติ
          log('⏰ Auto-closed print dialog after 3 seconds');
        }
      });

      // ✅ เช็คจำนวนรายการก่อนตัดสินใจวิธีปริ๊น
      final itemCount = order.orderItems?.length ?? 0;
      final isLongReceipt = itemCount > 20; // ถ้ามีรายการมากกว่า 20 รายการถือว่ายาว

      log('📊 Order items count: $itemCount, isLongReceipt: $isLongReceipt');

      if (isLongReceipt) {
        log('📏 Long receipt detected - using strip printing method');
        await _captureAndPrintInStrips(boundary, order);
      } else {
        log('📄 Normal receipt - using single image method');
        await _captureAndPrintSingleImage(boundary, order);
      }

      Get.back(); // ปิด loading dialog เมื่อปริ๊นสำเร็จ
    } catch (e) {
      log('❌ Error in capture and print: $e');
      Get.back(); // ปิด loading
      Get.snackbar('ข้อผิดพลาด', 'เกิดข้อผิดพลาดในการปริ๊น: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ✅ ปริ๊นแบบภาพเดียว (สำหรับใบเสร็จสั้น)
  Future<void> _captureAndPrintSingleImage(RenderRepaintBoundary boundary, order) async {
    try {
      log('📄 Capturing single image for normal receipt');

      // สร้างภาพ
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        log('❌ Cannot convert image to bytes');
        throw Exception('ไม่สามารถแปลงภาพได้');
      }

      Uint8List imageBytes = byteData.buffer.asUint8List();
      log('✅ Single image captured successfully, size: ${imageBytes.length} bytes');

      await _sendImageToPrinter(imageBytes, order);
    } catch (e) {
      log('❌ Error in _captureAndPrintSingleImage: $e');
      throw e;
    }
  }

  // ✅ ปริ๊นแบบแบ่งเป็นแถบ (สำหรับใบเสร็จยาว)
  Future<void> _captureAndPrintInStrips(RenderRepaintBoundary boundary, order) async {
    try {
      log('📏 Capturing image in strips for long receipt');

      // สร้างภาพเต็มก่อน
      ui.Image fullImage = await boundary.toImage(pixelRatio: 1.0);

      final imageWidth = fullImage.width;
      final imageHeight = fullImage.height;
      final stripHeight = 400; // ความสูงของแต่ละแถบ (pixels)

      log('📐 Full image size: ${imageWidth}x${imageHeight}');
      log('📏 Strip height: $stripHeight pixels');

      final numberOfStrips = (imageHeight / stripHeight).ceil();
      log('� Number of strips: $numberOfStrips');

      // แบ่งและส่งทีละแถบ
      for (int i = 0; i < numberOfStrips; i++) {
        final startY = i * stripHeight;
        final endY = ((i + 1) * stripHeight).clamp(0, imageHeight);
        final currentStripHeight = endY - startY;

        log('📏 Processing strip ${i + 1}/$numberOfStrips: y=$startY-$endY (height=$currentStripHeight)');

        // สร้างภาพแถบ
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);

        // วาดส่วนของภาพที่ต้องการ
        canvas.drawImageRect(
          fullImage,
          Rect.fromLTWH(0, startY.toDouble(), imageWidth.toDouble(), currentStripHeight.toDouble()),
          Rect.fromLTWH(0, 0, imageWidth.toDouble(), currentStripHeight.toDouble()),
          Paint(),
        );

        final picture = recorder.endRecording();
        final stripImage = await picture.toImage(imageWidth, currentStripHeight);

        // แปลงเป็น bytes
        final stripByteData = await stripImage.toByteData(format: ui.ImageByteFormat.png);
        if (stripByteData != null) {
          final stripBytes = stripByteData.buffer.asUint8List();
          log('✅ Strip ${i + 1} captured: ${stripBytes.length} bytes');

          // ส่งแถบไปปริ๊นเตอร์
          await _sendImageToPrinter(stripBytes, order, isStrip: true, stripNumber: i + 1, totalStrips: numberOfStrips);

          // รอสักครู่ระหว่างแถบ
          await Future.delayed(const Duration(milliseconds: 100));
        }

        // ปล่อย memory
        stripImage.dispose();
        picture.dispose();
      }

      // ปล่อย memory ของภาพเต็ม
      fullImage.dispose();

      log('✅ All strips sent successfully');
    } catch (e) {
      log('❌ Error in _captureAndPrintInStrips: $e');
      throw e;
    }
  }

  // ✅ ส่งภาพไปปริ๊นเตอร์
  Future<void> _sendImageToPrinter(Uint8List imageBytes, order, {bool isStrip = false, int stripNumber = 1, int totalStrips = 1}) async {
    try {
      PrinterController printerController;
      if (Get.isRegistered<PrinterController>()) {
        printerController = Get.find<PrinterController>();
      } else {
        printerController = Get.put(PrinterController());
      }

      final defaultPrinter = printerController.getDefaultPrinter();

      if (defaultPrinter == null) {
        log('❌ No default printer found');
        throw Exception('ไม่พบเครื่องปริ๊นเตอร์เริ่มต้น');
      }

      if (isStrip) {
        log('🖨️ Sending strip $stripNumber/$totalStrips to printer: ${defaultPrinter.name}');
      } else {
        log('🖨️ Sending single image to printer: ${defaultPrinter.name}');
      }

      // ส่งภาพไปปริ๊นเตอร์
      final printSuccess = await printerController.printImage(defaultPrinter, imageBytes);

      if (!printSuccess) {
        throw Exception('ไม่สามารถส่งภาพไปปริ๊นเตอร์ได้');
      }

      if (isStrip) {
        log('✅ Strip $stripNumber/$totalStrips sent successfully');

        // แสดงข้อความสำเร็จเมื่อส่งแถบสุดท้าย
        if (stripNumber == totalStrips) {
          Get.snackbar(
            'ปริ๊นสำเร็จ',
            'ส่งใบเสร็จ ${order.orderNo} ไปยังเครื่องปริ๊นเตอร์ ${defaultPrinter.name} แล้ว ($totalStrips แถบ)',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        log('✅ Single image sent successfully');
        Get.snackbar(
          'ปริ๊นสำเร็จ',
          'ส่งใบเสร็จ ${order.orderNo} ไปยังเครื่องปริ๊นเตอร์ ${defaultPrinter.name} แล้ว',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      log('❌ Error in _sendImageToPrinter: $e');

      if (!isStrip || stripNumber == 1) {
        // แสดง error เฉพาะครั้งแรกสำหรับ strips
        Get.snackbar(
          'ปริ๊นล้มเหลว',
          'ไม่สามารถส่งใบเสร็จไปยังเครื่องปริ๊นเตอร์ได้: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          duration: const Duration(seconds: 5),
        );
      }

      throw e;
    }
  }

  Widget _buildRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(left), Text(right)]),
    );
  }

  // จัดรูปแบบวันที่และเวลา
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'ไม่ระบุวันที่';

    final orderDate = dateTime.add(const Duration(hours: 7));
    return DateFormat('d/M/yy HH:mm น.').format(orderDate);
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
}
