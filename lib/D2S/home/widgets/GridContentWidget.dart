import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/controllers/home_controller.dart';
import 'package:posashastd/D2S/home/widgets/ProductGrid.dart';
import 'package:posashastd/local_db/product_local.dart';
import 'package:posashastd/utils/color_utils.dart';

class GridContentWidget extends StatelessWidget {
  final double width;
  final double height;
  final TabController tabController;
  final HomeController homeController;
  final ScrollController? scrollController;

  const GridContentWidget({
    super.key,
    required this.width,
    required this.height,
    required this.tabController,
    required this.homeController,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // แท็บแรก (สินค้าทั้งหมด) แสดงสินค้าจาก products, แท็บอื่นๆ แสดงจาก panels
    if (tabController.index == 0) {
      // แท็บแรก: แสดงสินค้าทั้งหมดจาก API
      return Obx(() {
        return GridView.builder(
          key: const ValueKey("grid_main_products"),
          controller: scrollController, // ✅ เพิ่ม ScrollController
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
            final String? imageLocal = product.imageLocal;

            // สร้างส่วนแสดงผลสินค้าตาม showType
            final Widget productVisual = _buildProductVisual(
              showType,
              colorHex,
              imageLocal,
            );

            final content = Column(
              children: [
                Expanded(child: productVisual),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(6),
                    ),
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '฿${product.price ?? 0}',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
              onLongPress: () {
                // ✅ แสดง dialog สำหรับใส่จำนวนสินค้า
                _showQuantityDialog(product, homeController);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: content,
                ),
              ),
            );
          },
        );
      });
    } else {
      // แท็บอื่นๆ: แสดงจาก panels (index - 1 เพราะแท็บแรกเป็นสินค้าทั้งหมด)
      final panelIndex = tabController.index - 1;
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
                  Text(
                    'ไม่มีข้อมูลพาเนล',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ProductGrid(
            itemCount: controller.panels[panelIndex].panelProducts.length ?? 0,
            panelProduct: controller.panels[panelIndex].panelProducts.toList(),
            isMainTab: false,
            width: width,
            height: height,
            onTap: (index, product) {
              // เมื่อกดสินค้าในพาเนล ให้เพิ่มลงตะกร้าเหมือนกับแท็บสินค้าทั้งหมด
              if (product != null) {
                log(
                  "🛒 Adding product to cart from panel ${panelIndex + 1}: ${product.name}",
                );
                homeController.addToCart(product);
              } else {
                log(
                  "📝 Empty slot clicked at index: $index ของพาเนล ${panelIndex + 1}",
                );
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

  // ✅ สร้างส่วนแสดงผลสินค้าตาม showType
  Widget _buildProductVisual(
    String? showType,
    String? colorHex,
    String? imageUrl,
  ) {
    if (showType == 'color' && colorHex != null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: hexToColor(colorHex),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      );
    } else if (showType == 'image' && imageUrl != null && imageUrl.isNotEmpty) {
      final file = File(imageUrl);

      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        child:
            file.existsSync()
                ? Image.file(
                  file,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                )
                : Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
      );
    } else {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
        child: const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
      );
    }
  }

  // ✅ แสดง dialog สำหรับใส่จำนวนสินค้า
  void _showQuantityDialog(
    ProductLocal product,
    HomeController homeController,
  ) {
    final TextEditingController quantityController = TextEditingController(
      text: '1',
    );

    Get.dialog(
      AlertDialog(
        title: Text(
          'เพิ่มสินค้า',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงชื่อสินค้า
            Text(
              product.name ?? 'ไม่มีชื่อ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),

            // ช่องใส่จำนวน
            Text(
              'จำนวน:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'ใส่จำนวน',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              autofocus: true,
              onTap: () {
                // เลือกข้อความทั้งหมดเมื่อกดที่ TextField
                quantityController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: quantityController.text.length,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('ยกเลิก')),
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
                  'เพิ่ม ${product.name} จำนวน $finalQuantity ชิ้น',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: Duration(seconds: 2),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('เพิ่ม', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
