// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:posashastd/D2S/home/paymentPageD2s.dart';
// import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';
// import 'package:posashastd/D2S/home/widgets/GridContentWidget.dart';
// import 'package:posashastd/D2S/home/widgets/ShiftClosedWidget.dart';
// import 'package:posashastd/constants.dart';

// import '../controllers/home_controller.dart';
// import '../controllers/order_controller.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
//   late TabController _tabController;
//   List<String> tabs = ['สินค้าทั้งหมด'];
//   late HomeController homeController;
//   late OrderController orderController;

//   // ✅ เพิ่ม ScrollController สำหรับตะกร้าและ GridView
//   late ScrollController _cartScrollController;
//   late ScrollController _gridScrollController;

//   @override
//   void initState() {
//     super.initState();
//     log('🏠 HomePage initState called');
//     _tabController = TabController(length: tabs.length, vsync: this);
//     _cartScrollController = ScrollController(); // ✅ เริ่มต้น ScrollController สำหรับตะกร้า
//     _gridScrollController = ScrollController(); // ✅ เริ่มต้น ScrollController สำหรับ GridView
//     SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);

//     // ลบ controller เก่าและสร้างใหม่เพื่อให้แน่ใจว่าข้อมูลจะถูกโหลดใหม่
//     if (Get.isRegistered<HomeController>()) {
//       log('🗑️ Deleting existing HomeController');
//       Get.delete<HomeController>();
//     }
//     log('🆕 Creating new HomeController');
//     homeController = Get.put(HomeController());

//     // ✅ สร้าง OrderController เพื่อจัดการข้อมูลส่วนลด
//     if (Get.isRegistered<OrderController>()) {
//       log('🗑️ Deleting existing OrderController');
//       Get.delete<OrderController>();
//     }
//     log('🆕 Creating new OrderController');
//     orderController = Get.put(OrderController());

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       log('⏰ PostFrameCallback: loading data');
//       await homeController.checkConnectivityAndLoadData();
//       log('✅ Data loading completed');

//       // ✅ เรียก checkDiscount เพื่อดึงข้อมูลส่วนลด
//       log('🎯 Loading discount data...');
//       await orderController.checkDiscount();
//       log('✅ Discount data loaded: ${orderController.discounts.length} discounts');

//       // หลังจากโหลดข้อมูลเสร็จ ให้เช็คพาเนลและสร้างแท็บ
//       _updateTabsFromPanels();

//       // ✅ ฟังการเปลี่ยนแปลงของตะกร้าและเลื่อนลงด้านล่าง
//       _setupCartScrollListener();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _cartScrollController.dispose(); // ✅ ทำลาย ScrollController สำหรับตะกร้า
//     _gridScrollController.dispose(); // ✅ ทำลาย ScrollController สำหรับ GridView
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//       DeviceOrientation.landscapeRight,
//       DeviceOrientation.landscapeLeft,
//     ]);
//     super.dispose();
//   }

//   // ✅ ฟังก์ชันเลื่อนตะกร้าลงด้านล่างสุด
//   void _scrollCartToBottom() {
//     if (_cartScrollController.hasClients) {
//       _cartScrollController.animateTo(
//         _cartScrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   // ✅ ฟังก์ชันเลื่อน GridView กลับไปด้านบน
//   void _scrollGridToTop() {
//     if (_gridScrollController.hasClients) {
//       _gridScrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
//     }
//   }

//   // ✅ ตั้งค่าการฟังการเปลี่ยนแปลงของตะกร้า
//   void _setupCartScrollListener() {
//     int previousCartLength = homeController.cartItems.length;
//     int previousTotalQuantity = _getTotalQuantity();

//     // ฟังการเปลี่ยนแปลงของ cartItems
//     homeController.cartItems.listen((cartItems) {
//       final currentTotalQuantity = _getTotalQuantity();

//       // ถ้ามีการเพิ่มสินค้าใหม่หรือเพิ่มจำนวน
//       if (cartItems.length > previousCartLength || currentTotalQuantity > previousTotalQuantity) {
//         // รอให้ UI อัปเดตแล้วค่อยเลื่อน
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _scrollCartToBottom();
//         });
//       }

//       previousCartLength = cartItems.length;
//       previousTotalQuantity = currentTotalQuantity;
//     });
//   }

//   // ✅ คำนวณจำนวนสินค้าทั้งหมดในตะกร้า
//   int _getTotalQuantity() {
//     return homeController.cartItems.fold<int>(0, (sum, item) => sum + (item['qty'] as int? ?? 0));
//   }

//   // อัพเดทแท็บตามจำนวนพาเนลที่มี
//   void _updateTabsFromPanels() {
//     setState(() {
//       // เริ่มต้นด้วยแท็บแรกที่เป็นสินค้าทั้งหมด
//       List<String> newTabs = ['สินค้าทั้งหมด'];

//       // เพิ่มแท็บตามจำนวนพาเนลที่มี
//       for (int i = 0; i < homeController.panels.length; i++) {
//         newTabs.add('${homeController.panels[i].name}');
//       }

//       // อัพเดทแท็บและ TabController
//       tabs = newTabs;
//       _tabController.dispose(); // ลบ controller เก่า
//       _tabController = TabController(length: tabs.length, vsync: this);

//       log('📋 Updated tabs: ${tabs.length} tabs total');
//       log('🎯 Tabs: ${tabs.join(", ")}');
//     });
//   }

//   // ✅ แสดง Dialog ยืนยันการลบสินค้าจากตะกร้า
//   void _showDeleteItemDialog(BuildContext context, Map<String, dynamic> item, int index) {
//     final itemName = item['name'] ?? 'ไม่มีชื่อ';
//     final qty = item['qty'] ?? 1;

//     Get.dialog(
//       AlertDialog(
//         title: const Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('ลบสินค้า')]),
//         content: Text('ต้องการลบ "$itemName" (จำนวน: $qty) ออกจากตะกร้าหรือไม่?', style: const TextStyle(fontSize: 18)),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text('ยกเลิก', style: TextStyle(fontSize: 18))),
//           ElevatedButton(
//             onPressed: () {
//               // ลบสินค้าออกจากตะกร้า
//               homeController.removeFromCart(index);
//               Get.back();

//               // แสดงข้อความยืนยัน
//               Get.snackbar(
//                 'ลบสำเร็จ',
//                 'ลบ "$itemName" ออกจากตะกร้าแล้ว',
//                 backgroundColor: kTabColor,
//                 colorText: Colors.white,
//                 duration: const Duration(seconds: 2),
//               );
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('ลบ', style: TextStyle(color: Colors.white, fontSize: 18)),
//           ),
//         ],
//       ),
//       barrierDismissible: false,
//     );
//   }

//   // แสดง Dialog เปิดกะ
//   void _showOpenShiftDialog() {
//     final changeController = TextEditingController();
//     final cashController = TextEditingController();
//     final remarkController = TextEditingController();

//     final formKey = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         final screenWidth = MediaQuery.of(context).size.width;

//         return AlertDialog(
//           titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
//           contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
//           title: Row(
//             children: const [
//               Icon(Icons.access_time, color: Colors.green),
//               SizedBox(width: 8),
//               Text('เปิดกะ', style: TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//           content: SizedBox(
//             width: screenWidth * 0.5,
//             child: Form(
//               key: formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // 🔹 จำนวนเงินทอน
//                   TextFormField(
//                     controller: changeController,
//                     keyboardType: TextInputType.number,
//                     textInputAction: TextInputAction.next,
//                     decoration: InputDecoration(
//                       labelText: 'จำนวนเงินทอน',
//                       hintText: 'เช่น 100',
//                       labelStyle: const TextStyle(fontSize: 20),
//                       prefixIcon: const Icon(Icons.money),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                       contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//                       errorStyle: const TextStyle(fontSize: 18, color: Colors.red),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'กรุณากรอกจำนวนเงินทอน';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // 🔹 ยอดยกมา
//                   TextFormField(
//                     controller: cashController,
//                     keyboardType: TextInputType.number,
//                     textInputAction: TextInputAction.next,
//                     decoration: InputDecoration(
//                       labelText: 'ยอดยกมา',
//                       hintText: 'เช่น 1000',
//                       labelStyle: const TextStyle(fontSize: 20),
//                       prefixIcon: const Icon(Icons.account_balance_wallet),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                       contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//                       errorStyle: const TextStyle(fontSize: 18, color: Colors.red),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'กรุณากรอกยอดยกมา';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // 🔹 หมายเหตุ
//                   TextFormField(
//                     controller: remarkController,
//                     textInputAction: TextInputAction.done,
//                     decoration: InputDecoration(
//                       labelText: 'หมายเหตุ',
//                       hintText: 'เช่น เปิดกะเช้า',
//                       labelStyle: const TextStyle(fontSize: 20),
//                       prefixIcon: const Icon(Icons.note),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                       contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           actions: [
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
//               child: const Text('ยกเลิก', style: TextStyle(color: Colors.white, fontSize: 20)),
//             ),
//             const SizedBox(width: 12),
//             ElevatedButton(
//               onPressed: () async {
//                 if (!formKey.currentState!.validate()) return;

//                 final change = double.tryParse(changeController.text) ?? 0;
//                 final cash = double.tryParse(cashController.text) ?? 0;
//                 final remark = remarkController.text.trim();

//                 Navigator.pop(context);

//                 // ใช้ setState เพื่อแสดง loading แทน dialog
//                 setState(() {
//                   // สามารถเพิ่มตัวแปร isLoading ได้ถ้าต้องการ
//                 });

//                 // แสดง loading overlay
//                 OverlayEntry? overlayEntry;
//                 overlayEntry = OverlayEntry(
//                   builder:
//                       (context) => Material(
//                         color: Colors.black54,
//                         child: Center(
//                           child: Container(
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
//                             child: const Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [CircularProgressIndicator(), SizedBox(height: 16), Text('กำลังเปิดกะ...')],
//                             ),
//                           ),
//                         ),
//                       ),
//                 );

//                 Overlay.of(context).insert(overlayEntry);

//                 try {
//                   final success = await homeController.openShift(change: change, cash: cash, remark: remark);

//                   // ✅ ปิด loading overlay
//                   overlayEntry.remove();

//                   if (success) {
//                     Get.snackbar(
//                       'สำเร็จ',
//                       'เปิดกะเรียบร้อยแล้ว',
//                       backgroundColor: kTabColor,
//                       colorText: Colors.white,
//                       duration: const Duration(seconds: 3),
//                     );
//                   } else {
//                     Get.snackbar(
//                       'ไม่สำเร็จ',
//                       'ไม่สามารถเปิดกะได้ กรุณาลองใหม่อีกครั้ง',
//                       backgroundColor: Colors.red,
//                       colorText: Colors.white,
//                       duration: const Duration(seconds: 4),
//                     );
//                   }
//                 } catch (e) {
//                   // ✅ ปิด loading ในกรณี error
//                   overlayEntry.remove();

//                   // แสดง error message
//                   Get.snackbar(
//                     'เกิดข้อผิดพลาด',
//                     'ไม่สามารถเปิดกะได้: ${e.toString()}',
//                     backgroundColor: Colors.red,
//                     colorText: Colors.white,
//                     duration: const Duration(seconds: 5),
//                   );

//                   // Log error สำหรับ debugging
//                   log('❌ Error opening shift: $e');
//                 }
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: kTabColor, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
//               child: const Text('ตกลง', style: TextStyle(color: Colors.white, fontSize: 20)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const AppDrawer(),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final width = constraints.maxWidth;
//           final height = constraints.maxHeight;
//           final leftWidth = width * 0.7;
//           final rightWidth = width * 0.3;

//           return Row(
//             children: [
//               // 🔵 ฝั่งสินค้า 70%
//               SizedBox(
//                 width: leftWidth,
//                 child: Column(
//                   children: [
//                     Container(
//                       height: 50,
//                       color: kTabColor,
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: Builder(
//                         builder:
//                             (context) => Row(
//                               children: [
//                                 IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer()),

//                                 // ✅ Dropdown
//                                 Obx(() {
//                                   return SizedBox(
//                                     width: 250,
//                                     child: DropdownButtonHideUnderline(
//                                       child: DropdownButton<String>(
//                                         isExpanded: true,
//                                         value: homeController.selectedCategoryCode.value.isEmpty ? null : homeController.selectedCategoryCode.value,
//                                         dropdownColor: Colors.white,
//                                         iconEnabledColor: Colors.white,
//                                         onChanged:
//                                             homeController.isShiftOpen.value
//                                                 ? (value) async {
//                                                   if (value != null) {
//                                                     homeController.selectedCategoryCode.value = value;
//                                                     final selectedCategory = homeController.categories.firstWhere(
//                                                       (cat) => cat['code'] == value,
//                                                       orElse: () => {'id': 0},
//                                                     );
//                                                     final int categoryId = selectedCategory['id'] ?? 0;
//                                                     await homeController.getProductByCategory(categoryId: categoryId, branchId: 0);

//                                                     // ✅ เลื่อน GridView กลับไปด้านบนหลังจากโหลดข้อมูลใหม่
//                                                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                                                       _scrollGridToTop();
//                                                     });
//                                                   }
//                                                 }
//                                                 : null,

//                                         // ✅ ควบคุมการแสดงผลของตัวเลือกที่ถูกเลือก
//                                         selectedItemBuilder: (context) {
//                                           return homeController.categories.map((category) {
//                                             return Align(
//                                               alignment: Alignment.centerLeft,
//                                               child: Padding(
//                                                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                                                 child: Text(category['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 18)),
//                                               ),
//                                             );
//                                           }).toList();
//                                         },

//                                         // ✅ รายการ dropdown
//                                         items:
//                                             homeController.categories.map((category) {
//                                               return DropdownMenuItem<String>(
//                                                 value: category['code'],
//                                                 child: Text(category['name'] ?? '', style: const TextStyle(color: Colors.black)),
//                                               );
//                                             }).toList(),
//                                       ),
//                                     ),
//                                   );
//                                 }),

//                                 const Spacer(), // ✅ ดันให้ปุ่มค้นหาชิดขวาสุด

//                                 const Icon(Icons.search, size: 30, color: Colors.white),
//                               ],
//                             ),
//                       ),
//                     ),

//                     // GridView
//                     Expanded(
//                       child: Obx(() {
//                         // ถ้ากะปิดอยู่ แสดง UI เปิดกะ
//                         if (!homeController.isShiftOpen.value) {
//                           return ShiftClosedWidget(onOpenShift: _showOpenShiftDialog);
//                         }

//                         // ถ้ากะเปิดแล้ว แสดง GridView ปกติ
//                         return AnimatedBuilder(
//                           animation: _tabController,
//                           builder:
//                               (_, __) => GridContentWidget(
//                                 width: width,
//                                 height: height,
//                                 tabController: _tabController,
//                                 homeController: homeController,
//                                 scrollController: _gridScrollController, // ✅ ส่ง ScrollController
//                               ),
//                         );
//                       }),
//                     ),

//                     // TabBar
//                     Obx(() {
//                       return SizedBox(
//                         height: 48,
//                         child: Row(
//                           children: [
//                             //IconButton(icon: const Icon(Icons.add, color: Colors.green), onPressed: _addTab),
//                             Expanded(
//                               child: TabBar(
//                                 isScrollable: true,
//                                 controller: _tabController,
//                                 tabs: List.generate(
//                                   tabs.length,
//                                   (index) => GestureDetector(
//                                     onLongPress:
//                                         homeController.isShiftOpen.value
//                                             ? () {
//                                               //_removeTab(index);
//                                             }
//                                             : null,
//                                     child: Tab(text: tabs[index]),
//                                   ),
//                                 ),
//                                 labelColor: homeController.isShiftOpen.value ? Colors.green : Colors.grey,
//                                 unselectedLabelColor: homeController.isShiftOpen.value ? Colors.black54 : Colors.grey,
//                                 indicatorColor: homeController.isShiftOpen.value ? Colors.green : Colors.grey,
//                                 onTap:
//                                     homeController.isShiftOpen.value
//                                         ? null
//                                         : (index) {
//                                           // ป้องกันการเปลี่ยนแท็บเมื่อกะปิด
//                                         },
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//               ),

//               // 🔴 ฝั่งตะกร้า 30%
//               SizedBox(
//                 width: rightWidth,
//                 child: Column(
//                   children: [
//                     // ✅ หัวตาราง + ปุ่มเคลียร์
//                     ListTile(
//                       title: const Text('ตะกร้า', style: TextStyle(fontWeight: FontWeight.bold)),
//                       trailing: TextButton.icon(
//                         onPressed: () {
//                           homeController.clearCart();
//                         },
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         label: const Text('เคลียร์', style: TextStyle(color: Colors.red)),
//                       ),
//                     ),

//                     // ✅ แสดงรายการสินค้าในตะกร้า
//                     Expanded(
//                       child: Obx(() {
//                         return homeController.cartItems.isEmpty
//                             ? const Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text('ยังไม่มีสินค้า', style: TextStyle(color: Colors.grey, fontSize: 18)),
//                                   SizedBox(height: 8),
//                                   Text('เลือกสินค้าเพื่อเพิ่มลงตะกร้า', style: TextStyle(color: Colors.grey, fontSize: 14)),
//                                 ],
//                               ),
//                             )
//                             : Column(
//                               children: [
//                                 // ✅ คำแนะนำการใช้งาน
//                                 Container(
//                                   width: double.infinity,
//                                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                   margin: const EdgeInsets.only(bottom: 8),
//                                   decoration: BoxDecoration(
//                                     color: Colors.blue[50],
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(color: Colors.blue[200]!),
//                                   ),
//                                   child: const Row(
//                                     children: [
//                                       Icon(Icons.info_outline, color: Colors.blue, size: 16),
//                                       SizedBox(width: 8),
//                                       Expanded(
//                                         child: Text(
//                                           'ใช้ปุ่ม +/- เพื่อเพิ่มลดจำนวน • กดค้างเพื่อลบสินค้า',
//                                           style: TextStyle(color: Colors.blue, fontSize: 14),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 // ✅ รายการสินค้า
//                                 Expanded(
//                                   child: ListView.builder(
//                                     controller: _cartScrollController, // ✅ เพิ่ม ScrollController
//                                     itemCount: homeController.cartItems.length,
//                                     itemBuilder: (context, index) {
//                                       final item = homeController.cartItems[index];
//                                       final name = item['name'] ?? 'ไม่มีชื่อ';
//                                       final qty = item['qty'] ?? 1;
//                                       final price = item['price'] ?? 0;

//                                       return GestureDetector(
//                                         onLongPress: () {
//                                           // ✅ แสดง dialog ยืนยันการลบเมื่อกดค้าง
//                                           _showDeleteItemDialog(context, item, index);
//                                         },
//                                         child: Container(
//                                           margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                                           padding: const EdgeInsets.all(12),
//                                           decoration: BoxDecoration(
//                                             color: Colors.white,
//                                             borderRadius: BorderRadius.circular(8),
//                                             border: Border.all(color: Colors.grey[300]!),
//                                             boxShadow: [
//                                               BoxShadow(
//                                                 color: Colors.grey.withValues(alpha: 0.1),
//                                                 spreadRadius: 1,
//                                                 blurRadius: 2,
//                                                 offset: const Offset(0, 1),
//                                               ),
//                                             ],
//                                           ),
//                                           child: Row(
//                                             children: [
//                                               // ข้อมูลสินค้า
//                                               Expanded(
//                                                 flex: 3,
//                                                 child: Column(
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       name,
//                                                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                                       maxLines: 2,
//                                                       overflow: TextOverflow.ellipsis,
//                                                     ),
//                                                     const SizedBox(height: 4),
//                                                     Text(
//                                                       '฿${price.toStringAsFixed(2)} / ชิ้น',
//                                                       style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                                                     ),
//                                                     Text(
//                                                       '฿${(price * qty).toStringAsFixed(2)}',
//                                                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
//                                                       textAlign: TextAlign.right,
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),

//                                               // ปุ่มควบคุมจำนวน
//                                               Expanded(
//                                                 flex: 3,
//                                                 child: Row(
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   children: [
//                                                     // ปุ่มลบ
//                                                     Container(
//                                                       width: 32,
//                                                       height: 32,
//                                                       decoration: BoxDecoration(
//                                                         color: Colors.red[50],
//                                                         borderRadius: BorderRadius.circular(6),
//                                                         border: Border.all(color: Colors.red[200]!),
//                                                       ),
//                                                       child: IconButton(
//                                                         padding: EdgeInsets.zero,
//                                                         onPressed: () {
//                                                           if (qty > 1) {
//                                                             homeController.updateCartItemQuantity(index, qty - 1);
//                                                           } else {
//                                                             _showDeleteItemDialog(context, item, index);
//                                                           }
//                                                         },
//                                                         icon: Icon(qty > 1 ? Icons.remove : Icons.delete, color: Colors.red, size: 16),
//                                                       ),
//                                                     ),

//                                                     // แสดงจำนวน
//                                                     Container(
//                                                       width: 40,
//                                                       margin: const EdgeInsets.symmetric(horizontal: 8),
//                                                       child: Text(
//                                                         '$qty',
//                                                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                                         textAlign: TextAlign.center,
//                                                       ),
//                                                     ),

//                                                     // ปุ่มเพิ่ม
//                                                     Container(
//                                                       width: 32,
//                                                       height: 32,
//                                                       decoration: BoxDecoration(
//                                                         color: Colors.green[50],
//                                                         borderRadius: BorderRadius.circular(6),
//                                                         border: Border.all(color: Colors.green[200]!),
//                                                       ),
//                                                       child: IconButton(
//                                                         padding: EdgeInsets.zero,
//                                                         onPressed: () {
//                                                           homeController.updateCartItemQuantity(index, qty + 1);
//                                                           // ✅ เลื่อนลงด้านล่างเมื่อเพิ่มจำนวน
//                                                           WidgetsBinding.instance.addPostFrameCallback((_) {
//                                                             _scrollCartToBottom();
//                                                           });
//                                                         },
//                                                         icon: const Icon(Icons.add, color: Colors.green, size: 16),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             );
//                       }),
//                     ),

//                     // ✅ แสดงยอดรวมราคา
//                     Obx(() {
//                       return homeController.cartItems.isNotEmpty
//                           ? Container(
//                             padding: const EdgeInsets.all(16.0),
//                             margin: const EdgeInsets.symmetric(horizontal: 8.0),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[100],
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.grey[300]!),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('ยอดรวม:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                                 Text(
//                                   '฿${homeController.totalPrice.toStringAsFixed(2)}',
//                                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
//                                 ),
//                               ],
//                             ),
//                           )
//                           : const SizedBox.shrink();
//                     }),

//                     // ✅ ปุ่มชำระเงิน
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           if (homeController.cartItems.isNotEmpty) {
//                             final success = await Navigator.push(
//                               context,
//                               MaterialPageRoute(builder: (context) => PaymentPageD2s(cartItems: homeController.cartItems)),
//                             );
//                             if (success == true) {
//                               homeController.clearCart();
//                             }
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(backgroundColor: kTabColor, minimumSize: const Size.fromHeight(50)),
//                         child: const Text("ชำระเงิน", style: TextStyle(color: Colors.white)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
