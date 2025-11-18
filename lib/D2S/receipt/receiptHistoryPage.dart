import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/controllers/home_controller.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';
import 'package:posashastd/D2S/controllers/order_controller.dart';
import 'package:posashastd/D2S/controllers/printer_controller.dart';
import 'package:posashastd/helpers/printReceiptFromCartItems.dart';
import 'package:posashastd/constants.dart';
import 'package:posashastd/local_db/order_local.dart';
import 'package:posashastd/models/order.dart';
import 'package:intl/intl.dart';
import 'package:posashastd/D2S/home/widgets/ReceiptPreviewWidget.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceiptHistoryPage extends StatefulWidget {
  const ReceiptHistoryPage({super.key});

  @override
  State<ReceiptHistoryPage> createState() => _ReceiptHistoryPageState();
}

class _ReceiptHistoryPageState extends State<ReceiptHistoryPage> {
  late OrderController orderController;
  late HomeController homeController;
  RxBool isConnected = false.obs;
  late SharedPreferences prefs;
  OrderLocal? order;

  @override
  void initState() {
    super.initState();
    fristLoad();
    log('🏠 ReceiptHistoryPage initState called');
    orderController = Get.put(OrderController());
    homeController = Get.put(HomeController());
    log('📱 OrderController created: ${orderController.hashCode}');
    // เรียก API เมื่อหน้าโหลด
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkConnectivityAndLoadData();
      await _loadOrders();
      log('⏰ PostFrameCallback: calling fetchOrders');
      orderController.fetchOrders();
    });
  }

  Future<void> _loadOrders() async {
    await homeController.getOrders();
    setState(() {});
  }

  // ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตและโหลดข้อมูล
  Future<void> checkConnectivityAndLoadData() async {
    try {
      log('🌐 Checking connectivity and loading data...');
      final connectivityResult = await Connectivity().checkConnectivity();
      isConnected.value = !connectivityResult.contains(ConnectivityResult.none);
      log('📶 Connected: ${isConnected.value}');

      if (isConnected.value) {
        log('🔄 Loading categories...');
        log('✅ Categories loaded successfully');
      } else {
        log('❌ No internet connection');
        // แสดงข้อความแจ้งเตือนไม่มีอินเทอร์เน็ต
        Get.snackbar('ไม่มีการเชื่อมต่อ', 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต', backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
      }
      setState(() {});
    } catch (e) {
      log('❌ Error checking connectivity: $e');
    }
  }

  bool vehicleCheck = false;

  Future<void> fristLoad() async {
    prefs = await SharedPreferences.getInstance();
    final vehicleCheck1 = prefs.getBool('vehicle');

    if (mounted) {
      setState(() {
        vehicleCheck = vehicleCheck1 ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body:
          vehicleCheck == true
              ? Row(
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
                              Builder(builder: (c) => IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(c).openDrawer())),
                              const SizedBox(width: 4),
                              const Text('ใบเสร็จรับเงิน', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(vehicleCheck == true ? 'ออฟไลน์' : 'ออนไลน์', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                  Switch(
                                    value: vehicleCheck,
                                    inactiveThumbColor: Colors.grey,
                                    inactiveTrackColor: const Color.fromARGB(137, 158, 158, 158),
                                    activeColor: Colors.green,
                                    onChanged: (value) async {
                                      vehicleCheck = value;
                                      await prefs.setBool('vehicle', vehicleCheck);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              // Padding(
                              //   padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                              //   child: SizedBox(
                              //     height: 40,
                              //     child: Row(
                              //       children: [
                              //         const Icon(Icons.search, color: Colors.grey),
                              //         const SizedBox(width: 8),
                              //         Expanded(
                              //           child: TextField(
                              //             decoration: const InputDecoration(hintText: 'ค้นหา...', border: InputBorder.none, isCollapsed: true),
                              //             style: const TextStyle(fontSize: 16),
                              //             onChanged: (value) {
                              //               // orderController.searchQuery.value = value;
                              //             },
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              // const Divider(thickness: 2),
                              Container(
                                // color: Colors.amber,
                                height: MediaQuery.of(context).size.height * 0.9,
                                child: Obx(() {
                                  // if (orderController.isLoading.value) {
                                  //   return const Center(child: CircularProgressIndicator());
                                  // }

                                  final groupedOrders = homeController.orders;
                                  if (groupedOrders.isEmpty) {
                                    return const Center(child: Text('ไม่มีข้อมูลออเดอร์', style: TextStyle(color: Colors.grey)));
                                  }

                                  return SingleChildScrollView(
                                    child: Column(
                                      children:
                                          List.generate(
                                            homeController.orders.length,
                                            (index) => ListTile(
                                              leading: Icon(Icons.receipt_long, color: Colors.green),
                                              title: Text('฿${homeController.orders[index].total!.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                              subtitle: Text(DateFormat('HH:mm น.').format(homeController.orders[index].date!), style: TextStyle(color: Colors.black)),
                                              // trailing: SizedBox(
                                              //   width: screenWidth * 0.1,
                                              //   child: Text(homeController.orders[index].localNo ?? '#-', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                              // ),
                                              onTap: () {
                                                order = homeController.orders[index];
                                                setState(() {});
                                              },
                                            ),
                                          ).reversed.toList(),
                                    ),
                                  );

                                  // return ListView.builder(
                                  //   padding: const EdgeInsets.only(left: 8),
                                  //   itemCount: homeController.orders.length,
                                  //   itemBuilder: (context, index) {
                                  //     return ListTile(
                                  //       leading: Icon(Icons.receipt_long, color: Colors.green),
                                  //       title: Text('฿${homeController.orders[index].total!.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                  //       subtitle: Text(DateFormat('HH:mm น.').format(homeController.orders[index].date!), style: TextStyle(color: Colors.black)),
                                  //       // trailing: SizedBox(
                                  //       //   width: screenWidth * 0.1,
                                  //       //   child: Text(homeController.orders[index].localNo ?? '#-', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                  //       // ),
                                  //       onTap: () {
                                  //         order = homeController.orders[index];
                                  //         setState(() {});
                                  //       },
                                  //     );
                                  //   },
                                  // );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // เส้นแบ่งกลาง
                  const VerticalDivider(width: 1, color: Colors.grey),
                  // ฝั่งขวา (60%)
                  Expanded(
                    child: Column(
                      children: [
                        Obx(() {
                          return Container(
                            height: 50,
                            color: kTabColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                // // Text(order?.localNo ?? '#-', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                // const Spacer(),
                                // // Text(order?.remark ?? 'ไม่ระบุ', style: const TextStyle(color: Colors.white, fontSize: 18)),
                                // // const SizedBox(width: 8),
                                // // ✅ ปุ่มแก้ไข
                                // GestureDetector(
                                //   // onTap: selectedOrder != null ? () => _editOrder(selectedOrder) : null,
                                //   child: Container(
                                //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                //     decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(6)),
                                //     child: Row(
                                //       mainAxisSize: MainAxisSize.min,
                                //       children: const [Icon(Icons.edit, color: Colors.white, size: 18), SizedBox(width: 4), Text('แก้ไข', style: TextStyle(color: Colors.white, fontSize: 14))],
                                //     ),
                                //   ),
                                // ),
                                // const SizedBox(width: 8),
                                // // ✅ ปุ่มปริ๊นแทนไอคอน more_vert
                                // GestureDetector(
                                //   // onTap: selectedOrder != null ? () => _printOrderReceipt(selectedOrder) : null,
                                //   child: Container(
                                //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                //     decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                                //     child: Row(
                                //       mainAxisSize: MainAxisSize.min,
                                //       children: const [Icon(Icons.print, color: Colors.white, size: 18), SizedBox(width: 4), Text('ปริ๊น', style: TextStyle(color: Colors.white, fontSize: 14))],
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          );
                        }),
                        order == null
                            ? SizedBox.shrink()
                            : Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                                child: Container(
                                  width: double.infinity,
                                  constraints: const BoxConstraints(maxWidth: 400),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Center(child: Text('฿${order!.total!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
                                        const SizedBox(height: 4),
                                        const Center(child: Text('รวมทั้งหมด', style: TextStyle(fontSize: 18))),
                                        const SizedBox(height: 16),
                                        Text('พนักงาน: ${order!.shiftId!.toString()}', style: const TextStyle(fontSize: 18)),
                                        const SizedBox(height: 4),
                                        // Text('ระบบขาย: $deviceName', style: const TextStyle(fontSize: 18)),
                                        // const SizedBox(height: 16),

                                        // แสดงรายการสินค้า
                                        if (order!.orderItems.isNotEmpty) ...[
                                          ...order!.orderItems.map((item) {
                                            final quantity = item.quantity ?? 0;
                                            final unitPrice = item.price ?? 0;
                                            final totalPrice = quantity * unitPrice;

                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(child: Text(item.productName ?? 'ไม่ระบุชื่อสินค้า', style: const TextStyle(fontSize: 18))),
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
                                        _buildRow('รวมทั้งหมด', '฿${order!.total!.toStringAsFixed(2)}'),
                                        _buildRow('ชำระแล้ว', '฿${(order!.paid != null ? double.tryParse(order!.paid!.toString()) ?? 0 : 0).toStringAsFixed(2)}'),
                                        _buildRow('เงินทอน', '฿${order!.change?.toStringAsFixed(2) ?? '0'}'),
                                        const SizedBox(height: 16),
                                        _buildRow(DateFormat('d/M/yy HH:mm น.').format(order!.date!), ''),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              )
              : Row(
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
                              Builder(builder: (c) => IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(c).openDrawer())),
                              const SizedBox(width: 4),
                              const Text('ใบเสร็จรับเงิน', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(vehicleCheck == true ? 'ออฟไลน์' : 'ออนไลน์', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                  Switch(
                                    value: vehicleCheck,
                                    inactiveThumbColor: Colors.grey,
                                    inactiveTrackColor: const Color.fromARGB(137, 158, 158, 158),
                                    activeColor: Colors.green,
                                    onChanged: (value) async {
                                      vehicleCheck = value;
                                      await prefs.setBool('vehicle', vehicleCheck);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
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
                      ...orders.map((order) => Obx(() => _buildReceiptItem(order: order, orderController: orderController, selected: orderController.selectedOrder.value?.id == order.id))),
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
                // ✅ ปุ่มแก้ไข
                GestureDetector(
                  onTap: selectedOrder != null ? () => _editOrder(selectedOrder) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [Icon(Icons.edit, color: Colors.white, size: 18), SizedBox(width: 4), Text('แก้ไข', style: TextStyle(color: Colors.white, fontSize: 14))],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // ✅ ปุ่มปริ๊นแทนไอคอน more_vert
                GestureDetector(
                  onTap: selectedOrder != null ? () => _printOrderReceipt(selectedOrder) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [Icon(Icons.print, color: Colors.white, size: 18), SizedBox(width: 4), Text('ปริ๊น', style: TextStyle(color: Colors.white, fontSize: 14))],
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
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
                child: Padding(padding: EdgeInsets.all(20), child: _buildOrderDetails(selectedOrder)),
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
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(left), Text(right)]));
  }

  Widget _buildDateGroup(String date) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), child: Text(date, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)));
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
        title: Text('฿${grandTotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? Colors.black : Colors.grey[800])),
        subtitle: Text(timeString, style: TextStyle(color: selected ? Colors.black : Colors.grey)),
        trailing: Text(order.orderNo ?? '#-', style: TextStyle(color: selected ? Colors.green : Colors.black, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        onTap: () {
          orderController.selectOrder(order);
        },
      ),
    );
  }

  // ✅ ฟังก์ชันแก้ไขออเดอร์ - นำทางไปหน้าโฮมเพจพร้อมข้อมูลออเดอร์
  void _editOrder(Order order) {
    //inspect(order.canVoid);
    // ✅ ตรวจสอบว่าออเดอร์สามารถแก้ไขได้หรือไม่
    if (order.canVoid != true) {
      Get.snackbar(
        'ไม่สามารถแก้ไขได้',
        'ออเดอร์นี้ไม่สามารถแก้ไขได้',
        icon: const Icon(Icons.warning, color: Colors.white),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // เตรียมข้อมูลสินค้าสำหรับส่งไปหน้าโฮมเพจ
    final cartItems = <Map<String, dynamic>>[];

    if (order.orderItems != null && order.orderItems!.isNotEmpty) {
      for (final orderItem in order.orderItems!) {
        cartItems.add({'id': orderItem.product?.id ?? 0, 'name': orderItem.product?.name ?? 'ไม่มีชื่อ', 'price': (orderItem.price ?? 0).toDouble(), 'qty': orderItem.quantity ?? 1});
      }
    }

    log('📦 Prepared cart items for edit: ${cartItems.length} items');
    log('🆔 Order ID: ${order.id}');
    log('🔢 Order number: ${order.orderNo}');

    // นำทางไปหน้าโฮมเพจพร้อมข้อมูล
    Get.offAllNamed(
      '/home',
      arguments: {
        'editMode': true,
        'orderId': order.id, // ✅ เพิ่ม orderId
        'orderNumber': order.orderNo,
        'cartItems': cartItems,
      },
    );
  }

  // ✅ ฟังก์ชันปริ๊นใบเสร็จจาก Order
  Future<void> _printOrderReceipt(Order order) async {
    try {
      log('🖨️ Starting to print receipt for order: ${order.orderNo}');

      // ✅ ตรวจสอบการเชื่อมต่อปริ๊นเตอร์ก่อนปริ๊น
      final printerController = Get.find<PrinterController>();

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
  Future<void> _printToSunmi(Order order) async {
    try {
      // แปลงข้อมูล OrderItems เป็น cartItems format
      final cartItems = _convertOrderToCartItems(order);

      // คำนวณข้อมูลการชำระเงิน
      final grandTotal = (order.grandTotal ?? 0).toDouble();
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
      Get.snackbar('ปริ๊นสำเร็จ', 'ปริ๊นใบเสร็จ ${order.orderNo} เรียบร้อยแล้ว', backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 2));
    } catch (e) {
      log('❌ Error printing to Sunmi: $e');
      Get.snackbar('เกิดข้อผิดพลาด', 'ไม่สามารถปริ๊นใบเสร็จได้: $e', backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 3));
    }
  }

  // ✅ แปลงข้อมูล Order เป็น cartItems format
  List<Map<String, dynamic>> _convertOrderToCartItems(Order order) {
    final cartItems = <Map<String, dynamic>>[];

    if (order.orderItems != null) {
      for (final orderItem in order.orderItems!) {
        cartItems.add({'id': orderItem.product?.id ?? 0, 'name': orderItem.product?.name ?? 'ไม่มีชื่อ', 'price': (orderItem.price ?? 0).toDouble(), 'qty': orderItem.quantity ?? 1});
      }
    }

    log('📦 Converted cart items: ${cartItems.length} items');
    return cartItems;
  }

  // ✅ แสดง Print Preview Dialog
  void _showPrintPreviewDialog(Order order) {
    final GlobalKey previewKey = GlobalKey();
    final cartItems = _convertOrderToCartItems(order);

    // คำนวณข้อมูลการชำระเงิน
    final paid = (order.paid ?? 0).toDouble();
    final change = (order.change ?? 0).toDouble();
    final discount = (order.discount ?? 0).toDouble();
    final staffName = order.shift?.user?.firstName ?? 'พนักงาน';

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
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                    child: RepaintBoundary(
                      key: previewKey,
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

              const SizedBox(height: 16),

              // Print Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _captureAndPrintReceipt(previewKey, order); // แคปภาพและปริ๊นก่อน
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('ปริ๊น'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
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
  Future<void> _captureAndPrintReceipt(GlobalKey key, Order order) async {
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
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
  Future<void> _captureAndPrintSingleImage(RenderRepaintBoundary boundary, Order order) async {
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
  Future<void> _captureAndPrintInStrips(RenderRepaintBoundary boundary, Order order) async {
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
      log('🔢 Number of strips: $numberOfStrips');

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
  Future<void> _sendImageToPrinter(Uint8List imageBytes, Order order, {bool isStrip = false, int stripNumber = 1, int totalStrips = 1}) async {
    try {
      final printerController = Get.find<PrinterController>();
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

      // เชื่อมต่อปริ๊นเตอร์
      final connectSuccess = await _connectToPrinter(defaultPrinter, printerController);
      if (!connectSuccess) {
        throw Exception('ไม่สามารถเชื่อมต่อกับปริ๊นเตอร์ ${defaultPrinter.name}');
      }

      // ส่งภาพไปปริ๊นเตอร์
      final printSuccess = await printerController.printImage(defaultPrinter, imageBytes);

      // ปิดการเชื่อมต่อ
      await _disconnectFromPrinter(defaultPrinter, printerController);

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

  // ✅ ปิดการเชื่อมต่อปริ๊นเตอร์เพื่อประหยัด RAM
  Future<void> _disconnectFromPrinter(PrinterInfo printer, PrinterController printerController) async {
    try {
      log('🔌 Disconnecting from printer: ${printer.name}');

      // ปิดการเชื่อมต่อตามประเภทปริ๊นเตอร์
      switch (printer.type.toLowerCase()) {
        case 'wifi':
        case 'lan':
          // สำหรับ Network printer ไม่ต้องทำอะไรเพิ่ม (Socket จะปิดเอง)
          log('📡 Network printer connection will close automatically');
          break;

        case 'bluetooth':
          // สำหรับ Bluetooth printer ควรปิดการเชื่อมต่อ
          log('📱 Closing Bluetooth connection');
          // TODO: เพิ่มการปิด Bluetooth connection เมื่อมี library
          break;

        case 'usb':
          // สำหรับ USB printer ปิด USB connection
          log('🔌 Closing USB connection');
          // TODO: เพิ่มการปิด USB connection เมื่อมี library
          break;

        default:
          log('🖨️ Generic printer - no specific disconnect needed');
          break;
      }

      // รอให้การปิดการเชื่อมต่อเสร็จสิ้น
      await Future.delayed(const Duration(milliseconds: 500));
      log('✅ Printer disconnected successfully');
    } catch (e) {
      log('⚠️ Error disconnecting from printer: $e');
      // ไม่ throw error เพราะการปิดการเชื่อมต่อไม่สำคัญมาก
    }
  }

  // ✅ ลบฟังก์ชันเก่าทั้งหมด - ตอนนี้ใช้รูปภาพสำหรับทุกปริ๊นเตอร์
  // ฟังก์ชันเหล่านี้ถูกลบแล้วเพราะใช้การแปลงเป็นรูปภาพแทน:
  // - _printTextToBARIGAN
  // - _convertToESCPOS
  // - _convertThaiToASCII
  // - _generateTextReceipt
  //
  // การใช้รูปภาพจะรองรับภาษาไทยได้ดีกว่าและแสดงผลถูกต้อง
}
