import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/home/paymentPageD2s.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';
import 'package:posashastd/D2S/home/widgets/ProductGrid.dart';
import 'package:posashastd/utils/color_utils.dart';

import '../controllers/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> tabs = ['สินค้าทั้งหมด'];
  late HomeController homeController;

  @override
  void initState() {
    super.initState();
    log('🏠 HomePage initState called');
    _tabController = TabController(length: tabs.length, vsync: this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);

    // ลบ controller เก่าและสร้างใหม่เพื่อให้แน่ใจว่าข้อมูลจะถูกโหลดใหม่
    if (Get.isRegistered<HomeController>()) {
      log('🗑️ Deleting existing HomeController');
      Get.delete<HomeController>();
    }
    log('🆕 Creating new HomeController');
    homeController = Get.put(HomeController());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      log('⏰ PostFrameCallback: loading data');
      await homeController.checkConnectivityAndLoadData();
      log('✅ Data loading completed');

      // หลังจากโหลดข้อมูลเสร็จ ให้เช็คพาเนลและสร้างแท็บ
      _updateTabsFromPanels();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.dispose();
  }

  // อัพเดทแท็บตามจำนวนพาเนลที่มี
  void _updateTabsFromPanels() {
    setState(() {
      // เริ่มต้นด้วยแท็บแรกที่เป็นสินค้าทั้งหมด
      List<String> newTabs = ['สินค้าทั้งหมด'];

      // เพิ่มแท็บตามจำนวนพาเนลที่มี
      for (int i = 0; i < homeController.panels.length; i++) {
        newTabs.add('พาเนล ${i + 1}');
      }

      // อัพเดทแท็บและ TabController
      tabs = newTabs;
      _tabController.dispose(); // ลบ controller เก่า
      _tabController = TabController(length: tabs.length, vsync: this);

      log('📋 Updated tabs: ${tabs.length} tabs total');
      log('🎯 Tabs: ${tabs.join(", ")}');
    });
  }

  void _addTab() {
    setState(() {
      homeController.addPanel();
      tabs.add("พาเนล ${homeController.panels.length}");
      _tabController.dispose();
      _tabController = TabController(length: tabs.length, vsync: this);
    });
  }

  void _removeTab(int index) async {
    // ป้องกันการลบแท็บแรก (สินค้าทั้งหมด)
    if (index == 0) {
      Get.snackbar(
        'ไม่สามารถลบได้',
        'ไม่สามารถลบแท็บ "สินค้าทั้งหมด" ได้',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('ยืนยันการลบ'),
            content: Text('ต้องการลบ "\${tabs[index]}" หรือไม่?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('ลบ')),
            ],
          ),
    );

    if (confirm == true) {
      setState(() {
        // ลบแท็บและพาเนลที่สอดคล้องกัน (index - 1 เพราะแท็บแรกไม่ใช่พาเนล)
        final panelIndex = index - 1;
        if (panelIndex >= 0 && panelIndex < homeController.panels.length) {
          homeController.panels.removeAt(panelIndex);
        }

        tabs.removeAt(index);
        _tabController.dispose();
        _tabController = TabController(length: tabs.length, vsync: this);

        log('🗑️ Removed tab at index $index, panel at index $panelIndex');
      });
    }
  }

  Widget _buildGridContent(double width, double height) {
    // แท็บแรก (สินค้าทั้งหมด) แสดงสินค้าจาก products, แท็บอื่นๆ แสดงจาก panels
    if (_tabController.index == 0) {
      // แท็บแรก: แสดงสินค้าทั้งหมดจาก API
      return Obx(() {
        return GridView.builder(
          key: const ValueKey("grid_main_products"),
          padding: const EdgeInsets.all(8),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: (width * 0.7) / 5,
            mainAxisExtent: (height - 50 - 48 - 34) / 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: homeController.products.length,
          itemBuilder: (context, index) {
            final product = homeController.products[index];
            final String name = product.name ?? 'ไม่ระบุชื่อ';
            final String? showType = product.showType;
            final String? colorHex = product.color;
            final String? imageUrl = product.imageUrl;

            // สร้างส่วนแสดงผลสินค้าตาม showType
            final Widget productVisual =
                showType == 'color' && colorHex != null
                    ? Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: hexToColor(colorHex), borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
                    )
                    : (showType == 'image' && imageUrl != null
                        ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) =>
                                    Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey)),
                          ),
                        )
                        : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
                          child: const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                        ));

            final content = Column(
              children: [
                Expanded(child: productVisual),
                Container(
                  decoration: const BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.vertical(bottom: Radius.circular(6))),
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '฿${product.price ?? 0}',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            );

            return GestureDetector(
              onTap: () {
                homeController.addToCart(product);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(6), child: content),
              ),
            );
          },
        );
      });
    } else {
      // แท็บอื่นๆ: แสดงจาก panels (index - 1 เพราะแท็บแรกเป็นสินค้าทั้งหมด)
      final panelIndex = _tabController.index - 1;
      return GetX<HomeController>(
        builder: (controller) {
          // ตรวจสอบว่ามีพาเนลในตำแหน่งนี้หรือไม่
          if (panelIndex < 0 || panelIndex >= controller.panels.length) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.dashboard_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('ไม่มีข้อมูลพาเนล', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ProductGrid(
            itemCount: controller.panels[panelIndex].panelProducts?.length ?? 0,
            panelProduct: controller.panels[panelIndex].panelProducts ?? [],
            isMainTab: false,
            width: width,
            height: height,
            onTap: (index, product) {
              // เมื่อกดสินค้าในพาเนล ให้เพิ่มลงตะกร้าเหมือนกับแท็บสินค้าทั้งหมด
              if (product != null) {
                log("🛒 Adding product to cart from panel ${panelIndex + 1}: ${product.name}");
                homeController.addToCart(product);
              } else {
                log("📝 Empty slot clicked at index: $index ของพาเนล ${panelIndex + 1}");
                // TODO: เพิ่มฟังก์ชันเลือกสินค้าเพื่อเพิ่มลงพาเนล
              }
            },
            onLongPress: (index) {
              log("🔧 Long press at index: $index ของพาเนล ${panelIndex + 1}");
              // TODO: เพิ่มฟังก์ชันแก้ไขหรือลบสินค้าจากพาเนล
            },
          );
        },
      );
    }
  }

  // UI เมื่อกะปิดอยู่
  Widget _buildShiftClosedUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('กะปิดอยู่ กรุณาเปิดกะ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showOpenShiftDialog,
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text('เปิดกะ', style: TextStyle(color: Colors.white, fontSize: 22)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
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
        final screenWidth = MediaQuery.of(context).size.width;

        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          title: Row(
            children: const [
              Icon(Icons.access_time, color: Colors.green),
              SizedBox(width: 8),
              Text('เปิดกะ', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: screenWidth * 0.5,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 จำนวนเงินทอน
                  TextFormField(
                    controller: changeController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'จำนวนเงินทอน',
                      hintText: 'เช่น 100',
                      labelStyle: const TextStyle(fontSize: 20),
                      prefixIcon: const Icon(Icons.money),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      errorStyle: const TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกจำนวนเงินทอน';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 🔹 ยอดยกมา
                  TextFormField(
                    controller: cashController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'ยอดยกมา',
                      hintText: 'เช่น 1000',
                      labelStyle: const TextStyle(fontSize: 20),
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      errorStyle: const TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกยอดยกมา';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 🔹 หมายเหตุ
                  TextFormField(
                    controller: remarkController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'หมายเหตุ',
                      hintText: 'เช่น เปิดกะเช้า',
                      labelStyle: const TextStyle(fontSize: 20),
                      prefixIcon: const Icon(Icons.note),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final change = double.tryParse(changeController.text) ?? 0;
                final cash = double.tryParse(cashController.text) ?? 0;
                final remark = remarkController.text.trim();

                Navigator.pop(context);

                Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

                final success = await homeController.openShift(change: change, cash: cash, remark: remark);

                Get.back(); // ปิด loading

                if (success) {
                  Get.snackbar('สำเร็จ', 'เปิดกะเรียบร้อยแล้ว', backgroundColor: Colors.green, colorText: Colors.white);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              child: const Text('ตกลง', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final leftWidth = width * 0.7;
          final rightWidth = width * 0.3;

          return Row(
            children: [
              // 🔵 ฝั่งสินค้า 70%
              SizedBox(
                width: leftWidth,
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      color: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Builder(
                        builder:
                            (context) => Row(
                              children: [
                                IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer()),

                                // ✅ Dropdown
                                Obx(() {
                                  return SizedBox(
                                    width: 250,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: homeController.selectedCategoryCode.value.isEmpty ? null : homeController.selectedCategoryCode.value,
                                        dropdownColor: Colors.white,
                                        iconEnabledColor: Colors.white,
                                        onChanged:
                                            homeController.isShiftOpen.value
                                                ? (value) async {
                                                  if (value != null) {
                                                    homeController.selectedCategoryCode.value = value;
                                                    final selectedCategory = homeController.categories.firstWhere(
                                                      (cat) => cat['code'] == value,
                                                      orElse: () => {'id': 0},
                                                    );
                                                    final int categoryId = selectedCategory['id'] ?? 0;
                                                    await homeController.getProductByCategory(categoryId: categoryId, branchId: 0);
                                                  }
                                                }
                                                : null,

                                        // ✅ ควบคุมการแสดงผลของตัวเลือกที่ถูกเลือก
                                        selectedItemBuilder: (context) {
                                          return homeController.categories.map((category) {
                                            return Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                child: Text(category['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 18)),
                                              ),
                                            );
                                          }).toList();
                                        },

                                        // ✅ รายการ dropdown
                                        items:
                                            homeController.categories.map((category) {
                                              return DropdownMenuItem<String>(
                                                value: category['code'],
                                                child: Text(category['name'] ?? '', style: const TextStyle(color: Colors.black)),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  );
                                }),

                                const Spacer(), // ✅ ดันให้ปุ่มค้นหาชิดขวาสุด

                                const Icon(Icons.search, size: 30, color: Colors.white),
                              ],
                            ),
                      ),
                    ),

                    // GridView
                    Expanded(
                      child: Obx(() {
                        // ถ้ากะปิดอยู่ แสดง UI เปิดกะ
                        if (!homeController.isShiftOpen.value) {
                          return _buildShiftClosedUI();
                        }

                        // ถ้ากะเปิดแล้ว แสดง GridView ปกติ
                        return AnimatedBuilder(animation: _tabController, builder: (_, __) => _buildGridContent(width, height));
                      }),
                    ),

                    // TabBar
                    Obx(() {
                      return SizedBox(
                        height: 48,
                        child: Row(
                          children: [
                            //IconButton(icon: const Icon(Icons.add, color: Colors.green), onPressed: _addTab),
                            Expanded(
                              child: TabBar(
                                isScrollable: true,
                                controller: _tabController,
                                tabs: List.generate(
                                  tabs.length,
                                  (index) => GestureDetector(
                                    onLongPress: homeController.isShiftOpen.value ? () => _removeTab(index) : null,
                                    child: Tab(text: tabs[index]),
                                  ),
                                ),
                                labelColor: homeController.isShiftOpen.value ? Colors.green : Colors.grey,
                                unselectedLabelColor: homeController.isShiftOpen.value ? Colors.black54 : Colors.grey,
                                indicatorColor: homeController.isShiftOpen.value ? Colors.green : Colors.grey,
                                onTap:
                                    homeController.isShiftOpen.value
                                        ? null
                                        : (index) {
                                          // ป้องกันการเปลี่ยนแท็บเมื่อกะปิด
                                        },
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // 🔴 ฝั่งตะกร้า 30%
              SizedBox(
                width: rightWidth,
                child: Column(
                  children: [
                    // ✅ หัวตาราง + ปุ่มเคลียร์
                    ListTile(
                      title: const Text('ตะกร้า', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: TextButton.icon(
                        onPressed: () {
                          homeController.clearCart();
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('เคลียร์', style: TextStyle(color: Colors.red)),
                      ),
                    ),

                    // ✅ แสดงรายการสินค้าในตะกร้า
                    Expanded(
                      child: Obx(() {
                        return homeController.cartItems.isEmpty
                            ? const Center(child: Text('ยังไม่มีสินค้า', style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                              itemCount: homeController.cartItems.length,
                              itemBuilder: (context, index) {
                                final item = homeController.cartItems[index];
                                final name = item['name'] ?? 'ไม่มีชื่อ';
                                final qty = item['qty'] ?? 1;
                                final price = item['price'] ?? 0;

                                return ListTile(
                                  dense: true,
                                  title: Text(name, style: TextStyle(fontSize: 16)),
                                  subtitle: Text('จำนวน: $qty', style: TextStyle(fontSize: 16)),
                                  trailing: Text('฿${(price * qty).toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                                );
                              },
                            );
                      }),
                    ),

                    // ✅ แสดงยอดรวมราคา
                    Obx(() {
                      return homeController.cartItems.isNotEmpty
                          ? Container(
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('ยอดรวม:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text(
                                  '฿${homeController.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                          )
                          : const SizedBox.shrink();
                    }),

                    // ✅ ปุ่มชำระเงิน
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (homeController.cartItems.isNotEmpty) {
                            final success = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PaymentPageD2s(cartItems: homeController.cartItems)),
                            );
                            if (success == true) {
                              homeController.clearCart();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size.fromHeight(50)),
                        child: const Text("ชำระเงิน", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
