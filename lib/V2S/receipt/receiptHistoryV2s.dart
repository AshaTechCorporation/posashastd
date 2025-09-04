import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/V2S/widgets/AppDrawerv2s.dart';
import 'package:posashastd/D2S/controllers/order_controller.dart';
import 'package:posashastd/D2S/controllers/printer_controller.dart';
import 'package:posashastd/helpers/printReceiptFromCartItemsV2s.dart';
import 'package:posashastd/constants.dart';
import 'package:intl/intl.dart';

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
        title: const Text('ใบเสร็จรับเงิน'),
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

              return RefreshIndicator(
                onRefresh: orderController.refreshOrders,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildReceiptItemFromAPI(order);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
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
      final time = order.orderDate;
      final hour = time.hour;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = hour < 12 ? 'ก่อนเที่ยง' : 'หลังเที่ยง';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      timeString = '$displayHour:$minute $period';
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
                  const Icon(Icons.receipt_long, color: Colors.white, size: 28),
                  const SizedBox(width: 16),
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

      // แสดงข้อความทดสอบก่อน
      Get.snackbar(
        'เริ่มการปริ๊น',
        'กำลังเตรียมข้อมูลสำหรับปริ๊นใบเสร็จ ${order.orderNo ?? '#-'}',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        icon: const Icon(Icons.info, color: Colors.white),
        duration: const Duration(seconds: 2),
      );

      // ตรวจสอบว่ามี PrinterController หรือไม่
      PrinterController printerController;
      if (Get.isRegistered<PrinterController>()) {
        printerController = Get.find<PrinterController>();
        log('✅ Found existing PrinterController');
      } else {
        printerController = Get.put(PrinterController());
        log('🆕 Created new PrinterController');
      }

      // ตรวจสอบว่ามีเครื่องปริ๊นเตอร์เริ่มต้นหรือไม่
      final defaultPrinter = printerController.getDefaultPrinter();
      log('🔍 Default printer: ${defaultPrinter?.name ?? 'null'}');

      if (defaultPrinter == null) {
        log('❌ No default printer found - proceeding without printer check');
        Get.snackbar(
          'ไม่พบเครื่องปริ๊นเตอร์',
          'จะดำเนินการปริ๊นโดยไม่ตรวจสอบเครื่องปริ๊นเตอร์',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.warning, color: Colors.white),
          duration: const Duration(seconds: 3),
        );

        // ดำเนินการปริ๊นต่อไปโดยไม่ตรวจสอบเครื่องปริ๊นเตอร์
      } else {
        // ทดสอบการเชื่อมต่อเครื่องปริ๊นเตอร์
        log('🔄 Testing printer connection...');
        final isConnected = await printerController.testPrinterConnection(defaultPrinter);
        log('📡 Connection result: $isConnected');

        if (!isConnected) {
          log('❌ Printer connection failed - proceeding anyway');
          Get.snackbar(
            'เชื่อมต่อไม่สำเร็จ',
            'จะดำเนินการปริ๊นต่อไปแม้ไม่สามารถเชื่อมต่อได้',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            icon: const Icon(Icons.warning, color: Colors.white),
            duration: const Duration(seconds: 3),
          );
        }
      }

      // สร้างข้อมูล cartItems จาก order
      final cartItems = <Map<String, dynamic>>[];

      if (order.orderItems != null) {
        for (final orderItem in order.orderItems!) {
          cartItems.add({'name': orderItem.product?.name ?? 'ไม่มีชื่อ', 'qty': orderItem.quantity ?? 1, 'price': (orderItem.price ?? 0).toDouble()});
        }
      }

      log('📦 Cart items prepared: ${cartItems.length} items');

      // คำนวณข้อมูลการชำระเงิน
      final grandTotal = (order.total ?? 0).toDouble();
      final paid = (order.paid != null ? double.tryParse(order.paid!.toString()) ?? 0 : 0).toDouble();
      final change = (order.change ?? 0).toDouble();
      final discount = (order.discount ?? 0).toDouble();

      // ข้อมูลพนักงาน
      final staffName = order.shift?.user?.username ?? 'พนักงาน';

      log('💰 Payment info - Total: $grandTotal, Paid: $paid, Change: $change, Discount: $discount');

      // เรียกใช้ฟังก์ชันปริ๊นสำหรับ V2S
      await printReceiptFromCartItemsV2s(
        cartItems,
        receivedAmount: paid,
        changeAmount: change,
        discountAmount: discount > 0 ? discount : null,
        paymentMethod: 'เงินสด',
        staffName: staffName,
        receiptNumber: order.orderNo,
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
      log('❌ Error printing receipt: $e');
      Get.snackbar(
        'เกิดข้อผิดพลาด',
        'ไม่สามารถปริ๊นใบเสร็จได้: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
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
}
