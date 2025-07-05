import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/home/paymentPageD2s.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';
import 'package:posashastd/D2S/home/widgets/ProductGrid.dart';
import 'package:posashastd/utils/color_utils.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> tabs = ['แท็บ 1'];
  final HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await homeController.checkConnectivityAndLoadData();
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

  void _addTab() {
    setState(() {
      homeController.addPanel();
      tabs.add("แท็บ ${tabs.length + 1}");
      _tabController = TabController(length: tabs.length, vsync: this);
    });
  }

  void _removeTab(int index) async {
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
        tabs.removeAt(index);
        _tabController = TabController(length: tabs.length, vsync: this);
      });
    }
  }

  Widget _buildGridContent(double width, double height) {
    // แท็บ 1 แสดงสินค้าจาก products, แท็บอื่นๆ แสดงจาก panels
    if (_tabController.index == 0) {
      // แท็บ 1: แสดงสินค้าจาก API
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
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '฿${product.price ?? 0}',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
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
      // แท็บอื่นๆ: แสดงจาก panels
      return GetX<HomeController>(
        builder: (controller) {
          return ProductGrid(
            itemCount: controller.panels.isNotEmpty ? controller.panels[_tabController.index].panelProducts!.length : 0,
            panelProduct: controller.panels.isNotEmpty ? controller.panels[_tabController.index].panelProducts! : [],
            isMainTab: false,
            width: width,
            height: height,
            onTap: (index, product) {
              // สำหรับแท็บอื่นๆ ยังใช้ระบบเดิม
            },
            onLongPress: (index) {
              log("กดค้างที่ index: $index ของแท็บเพิ่ม");
            },
          );
        },
      );
    }
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
                                        onChanged: (value) async {
                                          if (value != null) {
                                            homeController.selectedCategoryCode.value = value;
                                            final selectedCategory = homeController.categories.firstWhere(
                                              (cat) => cat['code'] == value,
                                              orElse: () => {'id': 0},
                                            );
                                            final int categoryId = selectedCategory['id'] ?? 0;
                                            await homeController.getProductByCategory(categoryId: categoryId, branchId: 0);
                                          }
                                        },

                                        // ✅ ควบคุมการแสดงผลของตัวเลือกที่ถูกเลือก
                                        selectedItemBuilder: (context) {
                                          return homeController.categories.map((category) {
                                            return Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                child: Text(category['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16)),
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

                                const Icon(Icons.search, size: 26, color: Colors.white),
                              ],
                            ),
                      ),
                    ),

                    // GridView
                    Expanded(child: AnimatedBuilder(animation: _tabController, builder: (_, __) => _buildGridContent(width, height))),

                    // TabBar
                    SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          IconButton(icon: const Icon(Icons.add, color: Colors.green), onPressed: _addTab),
                          Expanded(
                            child: TabBar(
                              isScrollable: true,
                              controller: _tabController,
                              tabs: List.generate(
                                tabs.length,
                                (index) => GestureDetector(onLongPress: () => _removeTab(index), child: Tab(text: tabs[index])),
                              ),
                              labelColor: Colors.green,
                              unselectedLabelColor: Colors.black54,
                              indicatorColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                                  title: Text(name, style: const TextStyle(fontSize: 14)),
                                  subtitle: Text('จำนวน: $qty'),
                                  trailing: Text('฿${(price * qty).toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
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
