import 'dart:developer';

import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:posashastd/models/product.dart';
import 'package:posashastd/services/homeService.dart';

import '../../models/panel.dart';
import '../../models/panel_product.dart';
import '../../services/database_service.dart';

class HomeController extends GetxController {
  RxList<Product> products = <Product>[].obs;
  RxList<Panel> panels = <Panel>[].obs;
  RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  RxString selectedCategoryCode = ''.obs;
  RxBool isConnected = false.obs;

  final _databaseService = DatebaseService();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void fetchProducts() async {
    log('Fetch Products');
    try {
      // final products = await _databaseService.getProducts();
      // this.products.assignAll(products);

      final panel = await _databaseService.getPanels();
      panels.assignAll(panel);
    } catch (e) {
      log('Fetch Products Error: $e');
      // handle error
    }
  }

  void addPanel() {
    panels.add(Panel(0, panelProducts: List.generate(20, (i) => PanelProduct(0))));
    update();
  }

  // ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตและโหลดข้อมูล
  Future<void> checkConnectivityAndLoadData() async {
    try {
      log('🌐 Checking connectivity and loading data...');
      final connectivityResult = await Connectivity().checkConnectivity();
      isConnected.value = !connectivityResult.contains(ConnectivityResult.none);
      log('📶 Connected: ${isConnected.value}');

      if (isConnected.value) {
        log('🔄 Loading categories...');
        await getlistCategory();
        log('✅ Categories loaded successfully');
      } else {
        log('❌ No internet connection');
        // แสดงข้อความแจ้งเตือนไม่มีอินเทอร์เน็ต
        Get.snackbar(
          'ไม่มีการเชื่อมต่อ',
          'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      log('❌ Error checking connectivity: $e');
    }
  }

  // ดึงข้อมูล Category
  Future<void> getlistCategory() async {
    try {
      log('📂 Fetching categories...');
      final rawData = await Homeservice.getCategory();
      log('📦 Raw category data received: ${rawData.toString()}');

      // แปลงให้แน่ใจว่าเป็น List<Map<String, dynamic>>
      final List<Map<String, dynamic>> parsedCategories = List<Map<String, dynamic>>.from(rawData);
      log('📋 Parsed categories count: ${parsedCategories.length}');

      categories.assignAll([
        {'code': 'ALL', 'name': 'ทั้งหมด'},
        ...parsedCategories,
      ]);
      selectedCategoryCode.value = categories.first['code'];
      log('🎯 Selected category: ${selectedCategoryCode.value}');

      final int categoryId = categories.first['id'] ?? 0;
      log('🛍️ Loading products for category: $categoryId');
      await getProductByCategory(categoryId: categoryId, branchId: 0);
    } catch (e) {
      log('❌ Error loading categories: $e');
    }
  }

  // ดึงข้อมูล Product ตาม Category
  Future<void> getProductByCategory({required int categoryId, required int branchId}) async {
    try {
      final rawData = await Homeservice.getProduct(categoryId: categoryId, branchId: branchId);
      // แปลงข้อมูลเป็น List<Product>
      final List<Map<String, dynamic>> parsedProducts = List<Map<String, dynamic>>.from(rawData);
      final List<Product> productList = parsedProducts.map((productData) => Product.fromJson(productData)).toList();
      products.assignAll(productList);
    } catch (e) {
      log('Error loading products: $e');
    }
  }

  // เพิ่มสินค้าลงตะกร้า
  void addToCart(Product product) {
    final existingIndex = cartItems.indexWhere((item) => item['id'] == product.id);

    if (existingIndex >= 0) {
      final currentQty = cartItems[existingIndex]['qty'] ?? 1;
      // สร้าง List ใหม่เพื่อให้ GetX ตรวจจับการเปลี่ยนแปลง
      final updatedList = List<Map<String, dynamic>>.from(cartItems);
      updatedList[existingIndex] = {...updatedList[existingIndex], 'qty': currentQty + 1};
      cartItems.assignAll(updatedList); // บังคับให้ RxList อัพเดท
    } else {
      final newItem = {'id': product.id, 'name': product.name ?? 'ไม่มีชื่อ', 'price': product.price ?? 0, 'qty': 1};
      cartItems.add(newItem);
    }
  }

  // คำนวณยอดรวมราคา
  double get totalPrice {
    return cartItems.fold<double>(0, (sum, item) => sum + ((item['price'] ?? 0) * (item['qty'] ?? 1)));
  }

  // เคลียร์ตะกร้า
  void clearCart() {
    cartItems.clear();
  }
}
