# การปรับปรุงหน้า ReceiptHistoryPage

## ภาพรวมการเปลี่ยนแปลง

ได้ปรับปรุงหน้า ReceiptHistoryPage ให้ดึงข้อมูลจาก OrderService ผ่าน OrderController และแสดงผลข้อมูลออเดอร์จริงจาก API

## ✅ การปรับปรุงหลัก

### 1. **OrderController Enhancement**

#### เพิ่มฟังก์ชันและตัวแปรใหม่:
```dart
class OrderController extends GetxController {
  RxList<Order> orders = <Order>[].obs;
  Rx<Order?> selectedOrder = Rx<Order?>(null);
  RxBool isLoading = false.obs;
  RxString searchQuery = ''.obs;

  // ดึงข้อมูล orders จาก API
  Future<void> fetchOrders() async {
    final rawData = await OrderService.getOrders();
    final List<Order> orderList = ordersList.map((orderData) => Order.fromJson(orderData)).toList();
    orders.assignAll(orderList);
  }

  // เลือก order
  void selectOrder(Order order) {
    selectedOrder.value = order;
  }

  // ค้นหา orders
  List<Order> get filteredOrders { ... }

  // จัดกลุ่ม orders ตามวันที่
  Map<String, List<Order>> get groupedOrders { ... }
}
```

### 2. **ReceiptHistoryPage Improvements**

#### การใช้ OrderController:
```dart
class ReceiptHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.put(OrderController());
    // ...
  }
}
```

#### ปรับปรุง _buildReceiptList:
```dart
Widget _buildReceiptList(OrderController orderController) {
  return Column(
    children: [
      // Search TextField
      TextField(
        onChanged: (value) {
          orderController.searchQuery.value = value;
        },
      ),
      
      // Dynamic Order List
      Obx(() {
        if (orderController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final groupedOrders = orderController.groupedOrders;
        return RefreshIndicator(
          onRefresh: orderController.refreshOrders,
          child: ListView.builder(
            itemCount: groupedOrders.length,
            itemBuilder: (context, index) {
              final dateKey = groupedOrders.keys.elementAt(index);
              final orders = groupedOrders[dateKey]!;
              
              return Column(
                children: [
                  _buildDateGroup(dateKey),
                  ...orders.map((order) => _buildReceiptItem(
                    order: order,
                    orderController: orderController,
                    selected: orderController.selectedOrder.value?.id == order.id,
                  )),
                ],
              );
            },
          ),
        );
      }),
    ],
  );
}
```

#### ปรับปรุง _buildReceiptDetail:
```dart
Widget _buildReceiptDetail(OrderController orderController) {
  return Column(
    children: [
      // Dynamic Header
      Obx(() {
        final selectedOrder = orderController.selectedOrder.value;
        return Container(
          child: Row(
            children: [
              Text(selectedOrder?.orderNo ?? '#-'),
              Text(selectedOrder?.orderStatus ?? 'ไม่ระบุ'),
            ],
          ),
        );
      }),

      // Dynamic Order Details
      Obx(() {
        final selectedOrder = orderController.selectedOrder.value;
        if (selectedOrder == null) {
          return const Center(child: Text('เลือกออเดอร์เพื่อดูรายละเอียด'));
        }
        return _buildOrderDetails(selectedOrder);
      }),
    ],
  );
}
```

### 3. **Dynamic Order Details**

#### _buildOrderDetails ใหม่:
```dart
Widget _buildOrderDetails(Order order) {
  final grandTotal = order.grandTotal ?? 0;
  final orderDate = order.orderDate;
  final deviceName = order.device?.name ?? 'POS 1';
  
  return Column(
    children: [
      // ยอดรวม
      Text('฿${grandTotal.toStringAsFixed(2)}'),
      
      // ข้อมูลพนักงานและระบบ
      Text('พนักงาน: ${order.shift?.user?.username ?? 'ไม่ระบุ'}'),
      Text('ระบบขาย: $deviceName'),
      
      // รายการสินค้า
      if (order.orderItems != null && order.orderItems!.isNotEmpty) ...[
        ...order.orderItems!.map((item) => Column(
          children: [
            Text(item.product?.name ?? 'ไม่ระบุชื่อสินค้า'),
            Text('${item.quantity ?? 0} x ฿${(item.price ?? 0).toStringAsFixed(2)}'),
          ],
        )),
      ],
      
      // สรุปการชำระเงิน
      _buildRow('รวมทั้งหมด', '฿${grandTotal.toStringAsFixed(2)}'),
      _buildRow('ชำระแล้ว', '฿${(order.paid != null ? double.tryParse(order.paid!) ?? 0 : 0).toStringAsFixed(2)}'),
      _buildRow(
        orderDate != null ? DateFormat('d/M/yy HH:mm น.').format(orderDate) : 'ไม่ระบุวันที่',
        order.orderNo ?? '#-',
      ),
    ],
  );
}
```

#### _buildReceiptItem ใหม่:
```dart
Widget _buildReceiptItem({
  required Order order,
  required OrderController orderController,
  bool selected = false,
}) {
  final grandTotal = order.grandTotal ?? 0;
  final orderDate = order.orderDate;
  final timeString = orderDate != null ? DateFormat('HH:mm น.').format(orderDate) : 'ไม่ระบุเวลา';
  
  return Container(
    color: selected ? Colors.grey[200] : null,
    child: ListTile(
      leading: const Icon(Icons.receipt_long),
      title: Text('฿${grandTotal.toStringAsFixed(2)}'),
      subtitle: Text(timeString),
      trailing: Text(order.orderNo ?? '#-'),
      onTap: () {
        orderController.selectOrder(order); // เลือกออเดอร์เมื่อกด
      },
    ),
  );
}
```

## 🎯 ฟีเจอร์ที่ได้รับ

### 1. **Real-time Data**
- ดึงข้อมูลออเดอร์จาก API จริง
- แสดงข้อมูลที่เป็นปัจจุบัน
- รองรับการ refresh ข้อมูล

### 2. **Interactive UI**
- กดเลือกออเดอร์ในรายการซ้าย
- แสดงรายละเอียดออเดอร์ที่เลือกทางขวา
- Highlight ออเดอร์ที่เลือก

### 3. **Search Functionality**
- ค้นหาออเดอร์ด้วย orderNo หรือ grandTotal
- Real-time search ขณะพิมพ์
- Filter รายการตามคำค้นหา

### 4. **Date Grouping**
- จัดกลุ่มออเดอร์ตามวันที่
- แสดงวันที่เป็นภาษาไทย
- เรียงลำดับตามวันที่

### 5. **Loading States**
- แสดง CircularProgressIndicator ขณะโหลด
- แสดงข้อความเมื่อไม่มีข้อมูล
- Error handling และแสดง Snackbar

### 6. **Order Details**
- แสดงยอดรวมเงิน
- แสดงข้อมูลพนักงานและระบบขาย
- แสดงรายการสินค้าในออเดอร์
- แสดงข้อมูลการชำระเงิน
- แสดงวันที่และเวลาที่สั่ง

## 📱 การใช้งาน

### สำหรับผู้ใช้:
1. เปิดหน้า ReceiptHistoryPage
2. รอโหลดข้อมูลออเดอร์จาก API
3. ดูรายการออเดอร์ทางซ้าย (จัดกลุ่มตามวันที่)
4. ใช้ช่องค้นหาเพื่อหาออเดอร์
5. กดเลือกออเดอร์เพื่อดูรายละเอียดทางขวา
6. ดูข้อมูลครบถ้วนของออเดอร์ที่เลือก
7. Pull-to-refresh เพื่อโหลดข้อมูลใหม่

### การทำงานของระบบ:
1. **เริ่มต้น**: OrderController.fetchOrders() ดึงข้อมูลจาก API
2. **แสดงผล**: จัดกลุ่มและแสดงรายการออเดอร์
3. **เลือกออเดอร์**: อัพเดท selectedOrder และแสดงรายละเอียด
4. **ค้นหา**: Filter รายการตาม searchQuery
5. **Refresh**: เรียก fetchOrders() ใหม่

## 🔧 Dependencies ที่ใช้

### Packages:
```yaml
dependencies:
  get: ^4.6.6          # State management
  intl: ^0.19.0        # Date formatting
```

### Models:
- Order
- OrderItems
- Product
- Shift
- User
- Device

### Services:
- OrderService.getOrders()

## ✅ สรุป

การปรับปรุงนี้ทำให้:
- หน้า ReceiptHistoryPage ใช้ข้อมูลจริงจาก API
- UI เป็น reactive และ interactive
- รองรับการค้นหาและ filter
- แสดงรายละเอียดออเดอร์ครบถ้วน
- มี UX ที่ดีด้วย loading states และ error handling
- โค้ดเป็นระเบียบและใช้ GetX pattern อย่างถูกต้อง
