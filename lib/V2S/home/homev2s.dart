import 'package:flutter/material.dart';
import 'package:posashastd/V2S/home/orderPagev2s.dart';
import 'package:posashastd/V2S/home/widgets/PaymentSummaryBar.dart';
import 'package:posashastd/V2S/widgets/AppDrawerv2s.dart';
import 'package:posashastd/services/homeService.dart';
import 'package:posashastd/utils/color_utils.dart';

class Homev2s extends StatefulWidget {
  const Homev2s({super.key});

  @override
  State<Homev2s> createState() => _Homev2sState();
}

class _Homev2sState extends State<Homev2s> {
  List<Map<String, dynamic>> categories = []; // เก็บ category ทั้งหมด
  String? selectedCategoryCode; // ใช้รหัสแทน
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
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
      final List<Map<String, dynamic>> parsedCategories = List<Map<String, dynamic>>.from(rawData);
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

  Future<void> getProductByCategory({required int categoryId, required int branchId}) async {
    try {
      final rawData = await Homeservice.getProduct(categoryId: categoryId, branchId: branchId);
      if (!mounted) return;
      // ✅ แปลงให้แน่ใจว่าเป็น List<Map<String, dynamic>>
      final List<Map<String, dynamic>> parsedProducts = List<Map<String, dynamic>>.from(rawData);
      setState(() {
        products = parsedProducts;
      });
    } catch (e) {
      // handle error
    }
  }

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      final existingIndex = cartItems.indexWhere((item) => item['id'] == product['id']);

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
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawerv2s(),
      appBar: AppBar(
        backgroundColor: Colors.green,
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
                    onTap: () {
                      if (cartItems.isNotEmpty) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPagev2s(items: cartItems)));
                      }
                    },
                    child: const Text('ตัวออเดอร์', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),

                  const SizedBox(width: 8),

                  // 🔢 กล่องตัวเลข
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    child: Text('${cartItems.length}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),

                  const Spacer(),

                  // 👤 ไอคอนรูปคน
                  IconButton(
                    onPressed: () {
                      // เปิดโปรไฟล์ หรือหน้า setting
                    },
                    icon: const Icon(Icons.person, color: Colors.white),
                  ),

                  // ⋮ เมนูเพิ่มเติม
                  IconButton(
                    onPressed: () {
                      // ตัวเลือกเพิ่มเติม
                    },
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),
        ),
      ),

      body: Column(
        children: [
          // ปุ่มชำระเงิน
          // ✅ ปุ่มชำระเงิน (ขยายให้สูงขึ้น + ขีดเส้นล่าง)
          PaymentSummaryBar(totalAmount: 80.00),

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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCategoryCode,
                        onChanged: (value) async {
                          setState(() {
                            selectedCategoryCode = value!;
                          });
                          // ✅ หา categoryId จาก code
                          final selectedCategory = categories.firstWhere(
                            (cat) => cat['code'] == value,
                            orElse: () => {'id': 0}, // fallback ป้องกัน error
                          );
                          final int categoryId = selectedCategory['id'] ?? 0;
                          // ✅ เรียก API สินค้า โดยใช้ branchId = 0
                          await getProductByCategory(categoryId: categoryId, branchId: 0);
                        },

                        icon: const Icon(Icons.arrow_drop_down),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        items:
                            categories.map((category) {
                              return DropdownMenuItem<String>(value: category['code'], child: Text(category['name']));
                            }).toList(),
                      ),
                    ),
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
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final name = product['name'] ?? 'ไม่ระบุชื่อ';
                  final showType = product['showType'];
                  final colorHex = product['color'];
                  final imageUrl = product['imageUrl'];

                  return GestureDetector(
                    onTap: () {
                      addToCart(product);
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // ✅ พื้นหลังสินค้า
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              showType == 'color'
                                  ? Container(color: hexToColor(colorHex))
                                  : imageUrl != null && showType == 'image'
                                  ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                                  )
                                  : Container(color: Colors.grey[300]), // fallback
                        ),

                        // ✅ ชื่อสินค้า
                        Container(
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black45],
                            ),
                          ),
                          child: Text(
                            name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
