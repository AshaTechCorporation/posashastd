import 'dart:developer';
import 'package:get/get.dart';
import 'package:posashastd/models/order.dart';
import 'package:posashastd/services/orderService.dart';

class OrderController extends GetxController {
  RxList<Order> orders = <Order>[].obs;
  Rx<Order?> selectedOrder = Rx<Order?>(null);
  RxBool isLoading = false.obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    log('🚀 OrderController onInit called');
    fetchOrders();
  }

  // ดึงข้อมูล orders จาก API
  Future<void> fetchOrders() async {
    try {
      log('🔄 Starting to fetch orders...');
      isLoading.value = true;

      final rawData = await OrderService.getOrders();
      log('📦 Raw data received: ${rawData.toString()}');

      // แปลงข้อมูลเป็น List<Order>
      final List<Map<String, dynamic>> ordersList = List<Map<String, dynamic>>.from(rawData);
      log('📋 Orders list length: ${ordersList.length}');

      final List<Order> orderList = ordersList.map((orderData) => Order.fromJson(orderData)).toList();
      log('✅ Converted to Order objects: ${orderList.length}');

      orders.assignAll(orderList);

      // เลือก order แรกเป็น default
      if (orderList.isNotEmpty) {
        selectedOrder.value = orderList.first;
        log('🎯 Selected first order: ${orderList.first.orderNo}');
      }

      log('✅ Orders fetched successfully');
    } catch (e) {
      log('❌ Error fetching orders: $e');
      Get.snackbar(
        'ข้อผิดพลาด',
        'ไม่สามารถดึงข้อมูลออเดอร์ได้: ${e.toString()}',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
      log('🏁 Fetch orders completed');
    }
  }

  // เลือก order
  void selectOrder(Order order) {
    selectedOrder.value = order;
    selectedOrder.refresh();
  }

  // ค้นหา orders
  List<Order> get filteredOrders {
    if (searchQuery.value.isEmpty) {
      return orders;
    }
    return orders.where((order) {
      final query = searchQuery.value.toLowerCase();
      return (order.orderNo?.toLowerCase().contains(query) ?? false) || (order.grandTotal?.toString().contains(query) ?? false);
    }).toList();
  }

  // จัดกลุ่ม orders ตามวันที่
  Map<String, List<Order>> get groupedOrders {
    final Map<String, List<Order>> grouped = {};

    for (final order in filteredOrders) {
      if (order.orderDate != null) {
        final dateKey = _formatDateGroup(order.orderDate!);
        if (!grouped.containsKey(dateKey)) {
          grouped[dateKey] = [];
        }
        grouped[dateKey]!.add(order);
      }
    }

    return grouped;
  }

  // จัดรูปแบบวันที่สำหรับการจัดกลุ่ม
  String _formatDateGroup(DateTime date) {
    final months = ['', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];

    return 'วันที่ ${date.day} ${months[date.month]} พ.ศ. ${date.year + 543}';
  }

  // รีเฟรชข้อมูล
  Future<void> refreshOrders() async {
    await fetchOrders();
  }
}
