import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/V2S/widgets/AppDrawerv2s.dart';
import 'package:posashastd/D2S/controllers/order_controller.dart';
import 'package:posashastd/constants.dart';

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
        backgroundColor: Colors.green,
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
                return const Center(child: CircularProgressIndicator());
              }

              final groupedOrders = orderController.groupedOrders;
              if (groupedOrders.isEmpty) {
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
                  itemCount: groupedOrders.length,
                  itemBuilder: (context, index) {
                    final dateKey = groupedOrders.keys.elementAt(index);
                    final orders = groupedOrders[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_buildDateHeader(dateKey), ...orders.map((order) => _buildReceiptItemFromAPI(order))],
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(date, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
        leading: Icon(Icons.receipt_long, color: Colors.green),
        title: Text('฿${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(timeString),
        trailing: Text(order.orderNo ?? '#-', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        onTap: () {
          // แสดงรายละเอียดออเดอร์
          _showOrderDetail(order);
        },
      ),
    );
  }

  // แสดงรายละเอียดออเดอร์
  void _showOrderDetail(order) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('ใบเสร็จ ${order.orderNo ?? '#-'}'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('วันที่: ${_formatDateTime(order.orderDate)}'),
                  Text('สถานะ: ${order.orderStatus ?? 'ไม่ระบุ'}'),
                  const SizedBox(height: 16),
                  const Text('รายการสินค้า:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (order.orderItems != null && order.orderItems!.isNotEmpty)
                    ...order.orderItems!.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('${item.product?.name ?? 'ไม่มีชื่อ'} x${item.quantity ?? 1}')),
                            Text('฿${((item.price ?? 0) * (item.quantity ?? 1)).toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    )
                  else
                    const Text('ไม่มีรายการสินค้า', style: TextStyle(color: Colors.grey)),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ยอดรวม:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('฿${(order.grandTotal ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('ปิด'))],
          ),
    );
  }

  // จัดรูปแบบวันที่และเวลา
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'ไม่ระบุ';

    final months = ['', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'ก่อนเที่ยง' : 'หลังเที่ยง';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '${dateTime.day} ${months[dateTime.month]} ${dateTime.year + 543} เวลา $displayHour:$minute $period';
  }
}
