import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:posashastd/V2S/home/orderPagev2s.dart';
import 'package:posashastd/V2S/home/widgets/PaymentSummaryBar.dart';
import 'package:posashastd/V2S/home/widgets/ProductNameOverlay.dart';
import 'package:posashastd/V2S/widgets/AppDrawerv2s.dart';
import 'package:posashastd/constants.dart';
import 'package:posashastd/utils/color_utils.dart';
import 'package:posashastd/D2S/controllers/home_controller.dart';
import 'package:posashastd/D2S/controllers/order_controller.dart';
import 'package:posashastd/V2S/home/widgets/ShiftClosedWidgetv2s.dart';
import 'package:posashastd/services/isar_service.dart';

class Homev2s extends StatefulWidget {
  const Homev2s({super.key});

  @override
  State<Homev2s> createState() => _Homev2sState();
}

class _Homev2sState extends State<Homev2s> {
  late HomeController homeController;
  late OrderController orderController;

  @override
  void initState() {
    super.initState();
    log('🏠 Homev2s initState called');

    // ลบ controller เก่าและสร้างใหม่เพื่อให้แน่ใจว่าข้อมูลจะถูกโหลดใหม่
    if (Get.isRegistered<HomeController>()) {
      log('🗑️ Deleting existing HomeController');
      Get.delete<HomeController>();
    }
    log('🆕 Creating new HomeController');
    homeController = Get.put(HomeController());

    // สร้าง OrderController เพื่อจัดการข้อมูลส่วนลด
    if (Get.isRegistered<OrderController>()) {
      log('🗑️ Deleting existing OrderController');
      Get.delete<OrderController>();
    }
    log('🆕 Creating new OrderController');
    orderController = Get.put(OrderController());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      log('⏰ PostFrameCallback: loading data');

      // เช็คสถานะ shift ก่อน
      await homeController.checkShiftStatus();
      log('✅ Shift status checked - currentShiftId: ${homeController.currentShiftId.value}');

      await homeController.checkConnectivityAndLoadData();
      log('✅ Data loading completed');
      log('📂 Categories loaded: ${homeController.categories.length} categories');
      log('📦 Products loaded: ${homeController.products.length} products');
      log('🎨 Panels loaded: ${homeController.panels.length} panels');

      // เรียก checkDiscount เพื่อดึงข้อมูลส่วนลด
      log('🎯 Loading discount data...');
      await orderController.checkDiscount();
      log('✅ Discount data loaded: ${orderController.discounts.length} discounts');

      // ✅ ถ้าไม่มีข้อมูล แสดงข้อความแนะนำให้ซิ้ง
      if (homeController.categories.isEmpty || homeController.products.isEmpty) {
        log('⚠️ No data found in database - user should sync data');
        Get.snackbar(
          'ไม่พบข้อมูล',
          'กรุณากดปุ่ม Sync (ไอคอนวงกลม) เพื่อดึงข้อมูลจากเซิร์ฟเวอร์',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          icon: const Icon(Icons.sync, color: Colors.white),
        );
      }
    });
  }

  // แสดง Dialog เปิดกะ
  void _showOpenShiftDialog() {
    final changeController = TextEditingController();
    final cashController = TextEditingController();
    final remarkController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Row(children: [Icon(Icons.play_arrow, color: Colors.green), SizedBox(width: 8), Text('เปิดกะ')]),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: changeController,
                  decoration: const InputDecoration(labelText: 'เงินทอน', hintText: 'ใส่จำนวนเงินทอน', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาใส่จำนวนเงินทอน';
                    }
                    if (double.tryParse(value) == null) {
                      return 'กรุณาใส่ตัวเลขที่ถูกต้อง';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: cashController,
                  decoration: const InputDecoration(labelText: 'เงินสด', hintText: 'ใส่จำนวนเงินสด', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาใส่จำนวนเงินสด';
                    }
                    if (double.tryParse(value) == null) {
                      return 'กรุณาใส่ตัวเลขที่ถูกต้อง';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: remarkController,
                  decoration: const InputDecoration(labelText: 'หมายเหตุ', hintText: 'ใส่หมายเหตุ (ถ้ามี)', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('ยกเลิก')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();

                  final change = double.parse(changeController.text);
                  final cash = double.parse(cashController.text);
                  final remark = remarkController.text.isEmpty ? 'เปิดกะ' : remarkController.text;

                  try {
                    final success = await homeController.openShift(change: change, cash: cash, remark: remark);

                    if (success) {
                      Get.snackbar(
                        'สำเร็จ',
                        'เปิดกะเรียบร้อยแล้ว',
                        backgroundColor: kTabColor,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 3),
                      );
                    } else {
                      Get.snackbar(
                        'ไม่สำเร็จ',
                        'ไม่สามารถเปิดกะได้ กรุณาลองใหม่อีกครั้ง',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 4),
                      );
                    }
                  } catch (e) {
                    Get.snackbar(
                      'เกิดข้อผิดพลาด',
                      'ไม่สามารถเปิดกะได้: ${e.toString()}',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 5),
                    );
                    log('❌ Error opening shift: $e');
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: kTabColor),
              child: const Text('ตกลง', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ✅ แสดง dialog สำหรับใส่จำนวนสินค้า
  void _showQuantityDialog(product) {
    final TextEditingController quantityController = TextEditingController(text: '1');

    Get.dialog(
      AlertDialog(
        title: const Text('เพิ่มสินค้า', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงชื่อสินค้า
            Text(product['name'] ?? 'ไม่มีชื่อ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700])),
            const SizedBox(height: 16),

            // ช่องกรอกจำนวน
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'จำนวน', border: OutlineInputBorder(), suffixText: 'ชิ้น'),
              onChanged: (value) {
                // ตรวจสอบว่าเป็นตัวเลขหรือไม่
                if (int.tryParse(value) == null && value.isNotEmpty) {
                  quantityController.text = '1';
                  quantityController.selection = TextSelection.fromPosition(TextPosition(offset: quantityController.text.length));
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () {
              final finalQuantity = int.tryParse(quantityController.text) ?? 1;
              if (finalQuantity > 0) {
                // เพิ่มสินค้าลงตะกร้าตามจำนวนที่ระบุ
                for (int i = 0; i < finalQuantity; i++) {
                  homeController.addToCart(product);
                }
                Get.back();

                // แสดงข้อความยืนยัน
                Get.snackbar(
                  'เพิ่มสินค้าสำเร็จ',
                  'เพิ่ม ${product['name']} จำนวน $finalQuantity ชิ้น',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('เพิ่ม', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ✅ ฟังก์ชันซิ้งข้อมูล
  Future<void> _syncData() async {
    try {
      // แสดง loading dialog
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [CircularProgressIndicator(), SizedBox(height: 16), Text('กำลังซิ้งข้อมูล...')],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      log('🔄 Starting data sync...');

      // ✅ เรียก IsarService.loadData() โดยตรง
      final isarService = IsarService();
      await isarService.loadData();
      log('✅ IsarService.loadData() completed');

      // ✅ รีเซ็ตข้อมูลในตะกร้า
      homeController.cartItems.clear();

      // ✅ โหลดข้อมูลใหม่จาก Isar database
      homeController.fetchProducts();
      log('✅ Products reloaded from database');

      await homeController.getlistCategory();
      log('✅ Categories reloaded from database');

      // โหลดข้อมูลส่วนลด
      await orderController.checkDiscount();
      log('✅ Discount data reloaded');

      // ปิด loading dialog
      Get.back();

      // แสดงข้อความสำเร็จ
      Get.snackbar(
        'ซิ้งข้อมูลสำเร็จ',
        'ข้อมูลได้รับการอัพเดทแล้ว',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // ปิด loading dialog
      Get.back();

      log('❌ Error syncing data: $e');
      Get.snackbar(
        'เกิดข้อผิดพลาด',
        'ไม่สามารถซิ้งข้อมูลได้: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  double getTotalAmount() {
    return homeController.cartItems.fold(0.0, (sum, item) {
      final price = (item['price'] ?? 0).toDouble();
      final qty = item['qty'] ?? 1;
      return sum + (price * qty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawerv2s(),
      appBar: AppBar(
        backgroundColor: kTabColor,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Builder(
          builder:
              (context) => Row(
                children: [
                  // ☰ เมนู
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),

                  // “ตัวออเดอร์”
                  GestureDetector(
                    onTap: () async {
                      if (homeController.cartItems.isNotEmpty) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => OrderPagev2s(
                                  items: homeController.cartItems,
                                  onClearAll: () {
                                    homeController.clearCart();
                                    Navigator.pop(context, true);
                                  },
                                ),
                          ),
                        );

                        // ถ้าได้ค่า true กลับมา ให้เคลียร์ออเดอร์ทั้งหมด
                        if (result == true) {
                          homeController.clearCart();
                        }
                      }
                    },
                    child: const Text('ตัวออเดอร์', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),

                  const SizedBox(width: 8),

                  // 🔢 กล่องตัวเลข
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      child: Text('${homeController.cartItems.length}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const Spacer(),

                  // ✅ ปุ่มซิ้งข้อมูล (แสดงเฉพาะเมื่อกะเปิดและมีเน็ต)
                  Obx(() {
                    if (homeController.isShiftOpen.value && homeController.isConnected.value) {
                      return IconButton(onPressed: _syncData, icon: const Icon(Icons.sync, color: Colors.white), tooltip: 'ซิ้งข้อมูล');
                    }
                    return const SizedBox.shrink();
                  }),

                  // 👤 ไอคอนรูปคน
                  // IconButton(
                  //   onPressed: () {
                  //     // เปิดโปรไฟล์ หรือหน้า setting
                  //   },
                  //   icon: const Icon(Icons.person, color: Colors.white),
                  // ),

                  // ⋮ เมนูเพิ่มเติม
                  // IconButton(
                  //   onPressed: () {
                  //     // ตัวเลือกเพิ่มเติม
                  //   },
                  //   icon: const Icon(Icons.more_vert, color: Colors.white),
                  // ),
                ],
              ),
        ),
      ),

      body: Obx(() {
        // ถ้ากะปิดอยู่ แสดง UI เปิดกะ
        if (!homeController.isShiftOpen.value) {
          return ShiftClosedWidgetv2s(onOpenShift: _showOpenShiftDialog);
        }

        // ถ้ากะเปิดแล้ว แสดง UI ปกติ
        return Column(
          children: [
            // ปุ่มชำระเงิน
            // ✅ ปุ่มชำระเงิน (ขยายให้สูงขึ้น + ขีดเส้นล่าง)
            Obx(() => PaymentSummaryBar(totalAmount: getTotalAmount())),

            // Dropdown และค้นหา
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // ครอบ Row ด้วย Expanded เพื่อให้กินพื้นที่ด้านซ้าย
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)), // เส้นแบ่งล่าง
                      ),
                      padding: const EdgeInsets.only(bottom: 4), // ระยะห่างจากข้อความถึงเส้น
                      child: Obx(() {
                        // ✅ Log จำนวน categories
                        log('📂 Categories count: ${homeController.categories.length}');

                        // ✅ ถ้าไม่มี categories แสดงข้อความ
                        if (homeController.categories.isEmpty) {
                          return const Text('ไม่มีหมวดหมู่ - กรุณาซิ้งข้อมูล', style: TextStyle(fontSize: 14, color: Colors.grey));
                        }

                        return DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: homeController.selectedCategoryCode.value.isEmpty ? null : homeController.selectedCategoryCode.value,
                            onChanged: (value) async {
                              if (value != null) {
                                homeController.selectedCategoryCode.value = value;
                                // หา categoryId จาก code
                                final selectedCategory = homeController.categories.firstWhere((cat) => cat.code == value);
                                final int categoryId = selectedCategory.id;
                                // เรียก API สินค้า โดยใช้ branchId = 0
                                log('🔄 Loading products for category: ${selectedCategory.name} (ID: $categoryId)');
                                await homeController.getProductByCategory(categoryId: categoryId, branchId: 0);
                                log('✅ Products loaded: ${homeController.products.length} items');
                              }
                            },

                            icon: const Icon(Icons.arrow_drop_down),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'IBMPlexSansThai'),
                            items:
                                homeController.categories.map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category.code,
                                    child: Text(category.name ?? '', style: const TextStyle(fontFamily: 'IBMPlexSansThai')),
                                  );
                                }).toList(),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(width: 8), // ระยะห่างระหว่าง dropdown กับปุ่มค้นหา
                  // ไอคอนค้นหา
                  IconButton(
                    onPressed: () {
                      // โค้ดค้นหา
                    },
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
            ),

            // GridView แสดงสินค้า
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Obx(() {
                  // ✅ Log จำนวนสินค้า
                  log('📦 Products count: ${homeController.products.length}');

                  // ✅ ถ้าไม่มีสินค้า แสดงข้อความ
                  if (homeController.products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('ไม่พบสินค้า', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            'กรุณาเลือกหมวดหมู่สินค้า\nหรือตรวจสอบการเชื่อมต่ออินเทอร์เน็ต',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: homeController.products.length,
                    itemBuilder: (context, index) {
                      final product = homeController.products[index];
                      final name = product.name ?? 'ไม่ระบุชื่อ';
                      final showType = product.showType;
                      final colorHex = product.color;
                      final imageUrl = product.imageUrl;

                      return GestureDetector(
                        onTap: () {
                          homeController.addToCart(product);
                        },
                        onLongPress: () {
                          // ✅ แสดง dialog สำหรับใส่จำนวนสินค้า
                          _showQuantityDialog(product);
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // ✅ พื้นหลังสินค้า
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  showType == 'color'
                                      ? Container(color: hexToColor(colorHex ?? '#FFFFFF'))
                                      : imageUrl != null && showType == 'image'
                                      ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder:
                                            (context, url) => Container(
                                              color: Colors.grey[200],
                                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                            ),
                                        errorWidget:
                                            (context, url, error) =>
                                                Container(color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey)),
                                      )
                                      : Container(color: Colors.grey[300]), // fallback
                            ),

                            // ✅ ราคาสินค้า (มุมซ้ายบน)
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                  '฿${(product.price ?? 0).toStringAsFixed(0)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                            // ✅ ชื่อสินค้า
                            ProductNameOverlay(name: name),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }
}
