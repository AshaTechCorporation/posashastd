import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';
import 'package:posashastd/D2S/controllers/order_controller.dart';
import 'package:posashastd/D2S/controllers/printer_controller.dart';
import 'package:posashastd/helpers/printReceiptFromCartItems.dart';
import 'package:posashastd/constants.dart';
import 'package:posashastd/models/order.dart';
import 'package:intl/intl.dart';

class ReceiptHistoryPage extends StatefulWidget {
  const ReceiptHistoryPage({super.key});

  @override
  State<ReceiptHistoryPage> createState() => _ReceiptHistoryPageState();
}

class _ReceiptHistoryPageState extends State<ReceiptHistoryPage> {
  late OrderController orderController;

  @override
  void initState() {
    super.initState();
    log('🏠 ReceiptHistoryPage initState called');
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: Row(
        children: [
          // ฝั่งซ้าย (40%)
          SizedBox(
            width: screenWidth * 0.4,
            child: Column(
              children: [
                Container(
                  height: 50,
                  color: kTabColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Builder(
                        builder: (c) => IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(c).openDrawer()),
                      ),
                      const SizedBox(width: 4),
                      const Text('ใบเสร็จรับเงิน', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                Expanded(child: _buildReceiptList(orderController)),
              ],
            ),
          ),

          // เส้นแบ่งกลาง
          const VerticalDivider(width: 1, color: Colors.grey),

          // ฝั่งขวา (60%)
          Expanded(child: _buildReceiptDetail(orderController)),
        ],
      ),
    );
  }

  Widget _buildReceiptList(OrderController orderController) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(hintText: 'ค้นหา...', border: InputBorder.none, isCollapsed: true),
                    style: const TextStyle(fontSize: 16),
                    onChanged: (value) {
                      orderController.searchQuery.value = value;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(thickness: 2),

        Expanded(
          child: Obx(() {
            if (orderController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final groupedOrders = orderController.groupedOrders;
            if (groupedOrders.isEmpty) {
              return const Center(child: Text('ไม่มีข้อมูลออเดอร์', style: TextStyle(color: Colors.grey)));
            }

            return RefreshIndicator(
              onRefresh: orderController.refreshOrders,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 8),
                itemCount: groupedOrders.length,
                itemBuilder: (context, index) {
                  final dateKey = groupedOrders.keys.elementAt(index);
                  final orders = groupedOrders[dateKey]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateGroup(dateKey),
                      ...orders.map(
                        (order) => Obx(
                          () => _buildReceiptItem(
                            order: order,
                            orderController: orderController,
                            selected: orderController.selectedOrder.value?.id == order.id,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildReceiptDetail(OrderController orderController) {
    return Column(
      children: [
        Obx(() {
          final selectedOrder = orderController.selectedOrder.value;
          return Container(
            height: 50,
            color: kTabColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(selectedOrder?.orderNo ?? '#-', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(selectedOrder?.orderStatus ?? 'ไม่ระบุ', style: const TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(width: 8),
                // ✅ ปุ่มปริ๊นแทนไอคอน more_vert
                GestureDetector(
                  onTap: () => _printOrderReceipt(selectedOrder!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.print, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text('ปริ๊น', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        Expanded(
          child: Obx(() {
            final selectedOrder = orderController.selectedOrder.value;
            if (selectedOrder == null) {
              return const Center(child: Text('เลือกออเดอร์เพื่อดูรายละเอียด', style: TextStyle(color: Colors.grey)));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Padding(padding: const EdgeInsets.all(20), child: _buildOrderDetails(selectedOrder)),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(Order order) {
    final grandTotal = order.total ?? 0;
    final change = order.change ?? 0;
    final orderDate = order.orderDate?.add(Duration(hours: 7));
    final deviceName = order.device?.name ?? 'POS 1';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Text('฿${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
        const SizedBox(height: 4),
        const Center(child: Text('รวมทั้งหมด', style: TextStyle(fontSize: 18))),
        const SizedBox(height: 16),
        Text('พนักงาน: ${order.shift?.user?.username ?? 'ไม่ระบุ'}', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text('ระบบขาย: $deviceName', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 16),

        // แสดงรายการสินค้า
        if (order.orderItems != null && order.orderItems!.isNotEmpty) ...[
          ...order.orderItems!.map((item) {
            final quantity = item.quantity ?? 0;
            final unitPrice = item.price ?? 0;
            final totalPrice = quantity * unitPrice;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item.product?.name ?? 'ไม่ระบุชื่อสินค้า', style: const TextStyle(fontSize: 18))),
                    Text('฿${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text('$quantity x ฿${unitPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 8),
              ],
            );
          }),
        ],

        const Divider(height: 24),
        _buildRow('รวมทั้งหมด', '฿${grandTotal.toStringAsFixed(2)}'),
        _buildRow('ชำระแล้ว', '฿${(order.paid != null ? double.tryParse(order.paid!.toString()) ?? 0 : 0).toStringAsFixed(2)}'),
        _buildRow('เงินทอน', '฿${change.toStringAsFixed(2)}'),
        const SizedBox(height: 16),
        _buildRow(orderDate != null ? DateFormat('d/M/yy HH:mm น.').format(orderDate) : 'ไม่ระบุวันที่', order.orderNo ?? '#-'),
      ],
    );
  }

  Widget _buildRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(left), Text(right)]),
    );
  }

  Widget _buildDateGroup(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Text(date, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildReceiptItem({required Order order, required OrderController orderController, bool selected = false}) {
    final grandTotal = order.total ?? 0;
    final orderDate = order.orderDate?.add(Duration(hours: 7));
    final timeString = orderDate != null ? DateFormat('HH:mm น.').format(orderDate) : 'ไม่ระบุเวลา';

    return Container(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE0F7FA) : null, // สีฟ้าอ่อนเมื่อเลือก
        border:
            selected
                ? Border(left: BorderSide(width: 4, color: Colors.green)) // เส้นขอบซ้ายเมื่อเลือก
                : null,
      ),
      child: ListTile(
        leading: Icon(Icons.receipt_long, color: selected ? Colors.green : Colors.grey),
        title: Text(
          '฿${grandTotal.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? Colors.black : Colors.grey[800]),
        ),
        subtitle: Text(timeString, style: TextStyle(color: selected ? Colors.black : Colors.grey)),
        trailing: Text(
          order.orderNo ?? '#-',
          style: TextStyle(color: selected ? Colors.green : Colors.black, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
        ),
        onTap: () {
          orderController.selectOrder(order);
        },
      ),
    );
  }

  // ✅ ฟังก์ชันปริ๊นใบเสร็จจาก Order
  Future<void> _printOrderReceipt(Order order) async {
    try {
      log('🖨️ Starting to print receipt for order: ${order.orderNo}');

      // ✅ ตรวจสอบการเชื่อมต่อปริ๊นเตอร์ก่อนปริ๊น
      final printerController = Get.find<PrinterController>();

      // ตรวจสอบว่ามีปริ๊นเตอร์เริ่มต้นหรือไม่
      final defaultPrinter = printerController.getDefaultPrinter();
      if (defaultPrinter == null) {
        Get.snackbar(
          'ไม่มีปริ๊นเตอร์',
          'กรุณาตั้งค่าปริ๊นเตอร์เริ่มต้นก่อนใช้งาน',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // ตรวจสอบการเชื่อมต่อปริ๊นเตอร์
      log('🔍 Checking printer connection: ${defaultPrinter.name}');
      final isConnected = await printerController.testPrinterConnection(defaultPrinter, showSnackbar: false);

      if (!isConnected) {
        // แสดง dialog ยืนยันการปริ๊นแม้ปริ๊นเตอร์ไม่เชื่อมต่อ
        final shouldPrint = await _showPrinterConnectionDialog(defaultPrinter);
        if (!shouldPrint) {
          return;
        }
      }

      // แปลงข้อมูล OrderItems เป็น cartItems format
      final cartItems = <Map<String, dynamic>>[];

      if (order.orderItems != null) {
        for (final orderItem in order.orderItems!) {
          cartItems.add({
            'id': orderItem.product?.id ?? 0,
            'name': orderItem.product?.name ?? 'ไม่มีชื่อ',
            'price': (orderItem.price ?? 0).toDouble(), // ใช้ค่าจาก order โดยตรง
            'qty': orderItem.quantity ?? 1,
          });
        }
      }

      log('📦 Converted cart items: ${cartItems.length} items');

      // คำนวณข้อมูลการชำระเงิน
      final grandTotal = (order.grandTotal ?? 0).toDouble(); // ใช้ค่าจาก order โดยตรง
      final paid = (order.paid ?? 0).toDouble();
      final change = (order.change ?? 0).toDouble();
      final discount = (order.discount ?? 0).toDouble();

      // ข้อมูลพนักงาน (ถ้ามี)
      final staffName = order.shift?.user?.firstName ?? 'พนักงาน';

      log('💰 Payment info - Total: $grandTotal, Paid: $paid, Change: $change, Discount: $discount');

      // เรียกใช้ฟังก์ชันปริ๊นเดียวกับ PaymentPageD2s
      await printReceiptFromCartItems(
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
      log('❌ Error printing receipt: $e');

      // แสดงข้อความข้อผิดพลาด
      Get.snackbar(
        'เกิดข้อผิดพลาด',
        'ไม่สามารถปริ๊นใบเสร็จได้: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ✅ แสดง dialog เมื่อปริ๊นเตอร์ไม่เชื่อมต่อ
  Future<bool> _showPrinterConnectionDialog(dynamic printer) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Row(children: const [Icon(Icons.warning, color: Colors.orange), SizedBox(width: 8), Text('ปริ๊นเตอร์ไม่เชื่อมต่อ')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ไม่สามารถเชื่อมต่อกับปริ๊นเตอร์ได้:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ชื่อ: ${printer.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('ประเภท: ${printer.type}'),
                  Text('ที่อยู่: ${printer.address}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('คุณต้องการลองปริ๊นต่อหรือไม่?'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () async {
              // ทดสอบการเชื่อมต่อใหม่
              Get.back(result: false);
              Get.dialog(
                const AlertDialog(content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('กำลังทดสอบการเชื่อมต่อ...')])),
                barrierDismissible: false,
              );

              final printerController = Get.find<PrinterController>();
              final isConnected = await printerController.testPrinterConnection(printer);
              Get.back(); // ปิด loading dialog

              if (isConnected) {
                Get.snackbar('เชื่อมต่อสำเร็จ', 'ปริ๊นเตอร์พร้อมใช้งานแล้ว', backgroundColor: Colors.green, colorText: Colors.white);
                // ปิด dialog และส่งผลลัพธ์ true
                Get.back(result: true);
              } else {
                Get.snackbar('ยังไม่สามารถเชื่อมต่อได้', 'กรุณาตรวจสอบปริ๊นเตอร์และลองใหม่', backgroundColor: Colors.red, colorText: Colors.white);
                // แสดง dialog เดิมอีกครั้ง
                final shouldPrint = await _showPrinterConnectionDialog(printer);
                Get.back(result: shouldPrint);
              }
            },
            child: const Text('ทดสอบใหม่'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('ปริ๊นต่อ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
