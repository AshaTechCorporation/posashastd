import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/home/paymentPageD2s.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';
import 'package:posashastd/D2S/home/widgets/ProductGrid.dart';
import 'package:posashastd/services/homeService.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> categories = []; // เก็บ category ทั้งหมด
  String? selectedCategoryCode; // ใช้รหัสแทน
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> cartItems = [];
  String selectedCategory = "ปูอัด-เต้าหู้-ปลาเส้น";
  late TabController _tabController;
  List<String> tabs = ['แท็บ 1'];

  final HomeController _homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getlistCategory();
    });
  }

  //ดึงข้อมูล Category
  Future<void> getlistCategory() async {
    try {
      final rawData = await Homeservice.getCategory();
      if (!mounted) return;
      // ✅ แปลงให้แน่ใจว่าเป็น List<Map<String, dynamic>>
      final List<Map<String, dynamic>> parsedCategories =
          List<Map<String, dynamic>>.from(rawData);
      setState(() {
        categories = [
          {'code': 'ALL', 'name': 'ทั้งหมด'},
          ...parsedCategories,
        ];
        selectedCategoryCode = categories.first['code'];
      });
      final int categoryId = categories.first['id'] ?? 0;
      await getProductByCategory(categoryId: categoryId, branchId: 0);
    } catch (e) {
      // handle error
    }
  }

  Future<void> getProductByCategory({
    required int categoryId,
    required int branchId,
  }) async {
    try {
      final rawData = await Homeservice.getProduct(
        categoryId: categoryId,
        branchId: branchId,
      );
      if (!mounted) return;
      // ✅ แปลงให้แน่ใจว่าเป็น List<Map<String, dynamic>>
      final List<Map<String, dynamic>> parsedProducts =
          List<Map<String, dynamic>>.from(rawData);
      setState(() {
        products = parsedProducts;
      });
    } catch (e) {
      // handle error
    }
  }

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      final existingIndex = cartItems.indexWhere(
        (item) => item['id'] == product['id'],
      );

      if (existingIndex >= 0) {
        final currentQty = cartItems[existingIndex]['qty'] ?? 1;
        cartItems[existingIndex]['qty'] = currentQty + 1;
      } else {
        final newItem = Map<String, dynamic>.from(product);
        newItem['qty'] = 1;
        cartItems.add(newItem);
      }
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
      tabs.add("แท็บ \${tabs.length + 1}");
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
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ยกเลิก'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('ลบ'),
              ),
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
    return GetX<HomeController>(
      builder: (controller) {
        return ProductGrid(
          itemCount: controller.products.length,
          products: controller.products,
          isMainTab: _tabController.index == 0,
          width: width,
          height: height,
          onTap: (index) {
            // addToCart(products[index]);
          },
          onLongPress: (index) {
            print("กดค้างที่ index: $index ของแท็บเพิ่ม");
          },
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
                                IconButton(
                                  icon: const Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                  ),
                                  onPressed:
                                      () => Scaffold.of(context).openDrawer(),
                                ),

                                // ✅ Dropdown
                                SizedBox(
                                  width: 250,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedCategoryCode,
                                      dropdownColor: Colors.white,
                                      iconEnabledColor: Colors.white,
                                      onChanged: (value) async {
                                        if (value != null) {
                                          setState(() {
                                            selectedCategoryCode = value;
                                          });
                                          final selectedCategory = categories
                                              .firstWhere(
                                                (cat) => cat['code'] == value,
                                                orElse: () => {'id': 0},
                                              );
                                          final int categoryId =
                                              selectedCategory['id'] ?? 0;
                                          await getProductByCategory(
                                            categoryId: categoryId,
                                            branchId: 0,
                                          );
                                        }
                                      },

                                      // ✅ ควบคุมการแสดงผลของตัวเลือกที่ถูกเลือก
                                      selectedItemBuilder: (context) {
                                        return categories.map((category) {
                                          return Align(
                                            alignment:
                                                Alignment
                                                    .centerLeft, // หรือ Alignment.center ถ้าต้องการให้อยู่ตรงกลางแนวนอน
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ), // ✅ แก้ให้ไม่ชิดขอบบน
                                              child: Text(
                                                category['name'] ?? '',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList();
                                      },

                                      // ✅ รายการ dropdown
                                      items:
                                          categories.map((category) {
                                            return DropdownMenuItem<String>(
                                              value: category['code'],
                                              child: Text(
                                                category['name'] ?? '',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),

                                const Spacer(), // ✅ ดันให้ปุ่มค้นหาชิดขวาสุด

                                const Icon(
                                  Icons.search,
                                  size: 26,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                      ),
                    ),

                    // GridView
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _tabController,
                        builder: (_, __) => _buildGridContent(width, height),
                      ),
                    ),

                    // TabBar
                    SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: _addTab,
                          ),
                          Expanded(
                            child: TabBar(
                              isScrollable: true,
                              controller: _tabController,
                              tabs: List.generate(
                                tabs.length,
                                (index) => GestureDetector(
                                  onLongPress: () => _removeTab(index),
                                  child: Tab(text: tabs[index]),
                                ),
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
                      title: const Text(
                        'ตะกร้า',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            cartItems.clear();
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'เคลียร์',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),

                    // ✅ แสดงรายการสินค้าในตะกร้า
                    Expanded(
                      child:
                          cartItems.isEmpty
                              ? const Center(
                                child: Text(
                                  'ยังไม่มีสินค้า',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                              : ListView.builder(
                                itemCount: cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = cartItems[index];
                                  final name = item['name'] ?? 'ไม่มีชื่อ';
                                  final qty = item['qty'] ?? 1;
                                  final price = item['price'] ?? 0;

                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      name,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    subtitle: Text('จำนวน: $qty'),
                                    trailing: Text(
                                      '฿${(price * qty).toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                },
                              ),
                    ),

                    // ✅ ปุ่มชำระเงิน
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          // TODO: ทำการชำระเงิน
                          if (cartItems.isNotEmpty) {
                            final success = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        PaymentPageD2s(cartItems: cartItems),
                              ),
                            );
                            if (success == true) {
                              setState(() {
                                cartItems.clear();
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text(
                          "ชำระเงิน",
                          style: TextStyle(color: Colors.white),
                        ),
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
