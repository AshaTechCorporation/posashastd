import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';
import 'package:posashastd/D2S/controllers/product_controller.dart';
import 'package:posashastd/constants.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  int selectedTabIndex = 0;
  String selectedDropdown = 'ทั้งหมด';
  late ProductController productController;

  final List<String> tabTitles = ['รายการทั้งหมด', 'หมวดหมู่', 'ตัวเลือกเพิ่มเติม', 'ป้าย'];

  @override
  void initState() {
    super.initState();
    log('🏠 ProductListPage initState called');

    // ลบ controller เก่าและสร้างใหม่เพื่อให้แน่ใจว่าข้อมูลจะถูกโหลดใหม่
    if (Get.isRegistered<ProductController>()) {
      log('🗑️ Deleting existing ProductController');
      Get.delete<ProductController>();
    }
    log('🆕 Creating new ProductController');
    productController = Get.put(ProductController());
  }

  @override
  void dispose() {
    // ไม่ลบ controller ที่นี่เพื่อให้สามารถใช้ร่วมกับหน้าอื่นได้
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      //floatingActionButton: FloatingActionButton(onPressed: () {}, backgroundColor: kTabColor, child: const Icon(Icons.add, color: Colors.white)),
      body: Row(
        children: [
          // 🔹 Sidebar
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            child: Column(
              children: [
                // Header
                Container(
                  height: 50,
                  color: kTabColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Builder(
                        builder:
                            (context) =>
                                IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer()),
                      ),
                      const SizedBox(width: 8),
                      const Text('รายการสินค้า', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),

                // Tabs
                Expanded(
                  child: ListView(
                    children: [_buildMenuItem(0, 'รายการสินค้าทั้งหมด', icon: Icons.list), _buildMenuItem(1, 'หมวดหมู่', icon: Icons.category)],
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(width: 1, color: Colors.grey),

          // 🔸 Content Area
          Expanded(
            child: Column(
              children: [
                // Header with Dropdown
                Container(
                  height: 50,
                  color: kTabColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child:
                      selectedTabIndex == 0
                          ? Align(
                            alignment: Alignment.centerLeft,
                            child: Obx(() {
                              if (productController.categories.isEmpty) {
                                return const Text('กำลังโหลด...', style: TextStyle(color: Colors.white, fontSize: 18));
                              }

                              return DropdownButton<String>(
                                value:
                                    productController.selectedCategoryCode.value.isNotEmpty
                                        ? productController.selectedCategoryCode.value
                                        : productController.categories.first['code'],
                                isDense: true,
                                dropdownColor: Colors.white,
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                underline: const SizedBox(),
                                selectedItemBuilder: (BuildContext context) {
                                  return productController.categories.map((category) {
                                    return Text(category['name'] ?? 'ไม่ระบุ', style: const TextStyle(color: Colors.white, fontSize: 18));
                                  }).toList();
                                },
                                style: const TextStyle(color: Colors.black, fontSize: 16),
                                items:
                                    productController.categories.map((category) {
                                      return DropdownMenuItem<String>(value: category['code'], child: Text(category['name'] ?? 'ไม่ระบุ'));
                                    }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    productController.selectCategory(value);
                                  }
                                },
                              );
                            }),
                          )
                          : Text(tabTitles[selectedTabIndex], style: const TextStyle(color: Colors.white, fontSize: 18)),
                ),

                // Content
                Expanded(child: _buildRightContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, String title, {IconData? icon}) {
    return ListTile(
      selected: selectedTabIndex == index,
      selectedTileColor: Colors.grey.shade200,
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(
          color: selectedTabIndex == index ? Colors.green : Colors.black,
          fontWeight: selectedTabIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => setState(() => selectedTabIndex = index),
    );
  }

  Widget _buildRightContent() {
    switch (selectedTabIndex) {
      case 0:
        // รายการสินค้าทั้งหมด - ใช้ข้อมูลจาก ProductController
        return Obx(() {
          if (productController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = productController.filteredProducts;
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('ไม่มีสินค้าในหมวดหมู่นี้', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: productController.refreshData,
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    child:
                        product.imageUrl != null
                            ? ClipOval(
                              child: Image.network(
                                product.imageUrl!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag, color: Colors.grey),
                              ),
                            )
                            : const Icon(Icons.shopping_bag, color: Colors.grey),
                  ),
                  title: Text(product.name ?? 'ไม่ระบุชื่อสินค้า'),
                  subtitle: Text(product.code ?? '-'),
                  trailing: Text('฿${(product.price ?? 0).toStringAsFixed(2)}'),
                  onTap: () {
                    // TODO: เพิ่มการทำงานเมื่อกดสินค้า
                  },
                );
              },
            ),
          );
        });

      case 1:
        // หมวดหมู่ - ใช้ข้อมูลจาก ProductController
        return Obx(() {
          if (productController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = productController.categories;
          if (categories.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('ไม่มีหมวดหมู่', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final String name = category['name'] ?? 'ไม่ระบุ';
              final String code = category['code'] ?? '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getCategoryColor(index),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(name),
                subtitle: Text('รหัส: $code'),
                onTap: () {
                  // เปลี่ยนไปแท็บรายการสินค้าและเลือกหมวดหมู่นี้
                  // setState(() => selectedTabIndex = 0);
                  // productController.selectCategory(code);
                },
              );
            },
          );
        });

      case 2:
        // ตัวเลือกเพิ่มเติม
        return _buildEmptyState('คุณยังไม่มีตัวเลือกเพิ่มเติม', 'ตัวเลือกเพิ่มเติม');

      case 3:
        // ป้าย
        return _buildEmptyState('คุณยังไม่มีป้าย', 'ป้าย');

      default:
        return const SizedBox();
    }
  }

  // ฟังก์ชันสำหรับกำหนดสีของหมวดหมู่
  Color _getCategoryColor(int index) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.indigo, Colors.pink];
    return colors[index % colors.length];
  }

  Widget _buildEmptyState(String message, String linkText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 8),
          Text(linkText, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
        ],
      ),
    );
  }
}
