import 'dart:developer';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:posashastd/models/product.dart';
import 'package:posashastd/services/homeService.dart';

class ProductController extends GetxController {
  RxList<Product> showproducts = <Product>[].obs;
  RxList<Product> products = <Product>[].obs;
  RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  RxString selectedCategoryCode = ''.obs;
  RxBool isConnected = false.obs;
  RxBool isLoading = false.obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    log('🚀 ProductController onInit called');
    checkConnectivityAndLoadData();
  }

  // ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตและโหลดข้อมูล
  Future<void> checkConnectivityAndLoadData() async {
    try {
      log('🌐 ProductController: Checking connectivity and loading data...');
      isLoading.value = true;

      final connectivityResult = await Connectivity().checkConnectivity();
      isConnected.value = !connectivityResult.contains(ConnectivityResult.none);
      log('📶 ProductController Connected: ${isConnected.value}');

      if (isConnected.value) {
        log('🔄 ProductController: Loading categories...');
        await getlistCategory();
        log('✅ ProductController: Categories loaded successfully');
      } else {
        log('❌ ProductController: No internet connection');
        Get.snackbar(
          'ไม่มีการเชื่อมต่อ',
          'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      log('❌ ProductController Error checking connectivity: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ดึงข้อมูล Category (เหมือนกับ HomeController)
  Future<void> getlistCategory() async {
    try {
      log('📂 ProductController: Fetching categories...');
      final rawData = await Homeservice.getCategory();
      log('📦 ProductController: Raw category data received: ${rawData.toString()}');

      // แปลงให้แน่ใจว่าเป็น List<Map<String, dynamic>>
      final List<Map<String, dynamic>> parsedCategories = List<Map<String, dynamic>>.from(rawData);
      log('📋 ProductController: Parsed categories count: ${parsedCategories.length}');

      categories.assignAll([
        {'code': 'ALL', 'name': 'ทั้งหมด', 'id': 0},
        ...parsedCategories,
      ]);

      if (categories.isNotEmpty) {
        selectedCategoryCode.value = categories.first['code'];
        log('🎯 ProductController: Selected category: ${selectedCategoryCode.value}');

        final int categoryId = categories.first['id'] ?? 0;
        log('🛍️ ProductController: Loading products for category: $categoryId');
        await getProductByCategory(categoryId: categoryId, branchId: 0);
      } else {
        log('⚠️ ProductController: No categories found');
      }
    } catch (e) {
      log('❌ ProductController: Error loading categories: $e');
    }
  }

  // ดึงข้อมูล Product ตาม Category (เหมือนกับ HomeController)
  Future<void> getProductByCategory({required int categoryId, required int branchId}) async {
    try {
      log('🛒 ProductController: Loading products for category $categoryId, branch $branchId');
      final rawData = await Homeservice.getProduct(categoryId: categoryId, branchId: branchId);

      // แปลงข้อมูลเป็น List<Product>
      final List<Map<String, dynamic>> parsedProducts = List<Map<String, dynamic>>.from(rawData);
      final List<Product> productList = parsedProducts.map((productData) => Product.fromJson(productData)).toList();

      products.assignAll(productList);
      showproducts.assignAll(productList); // เก็บไว้เพื่อ backward compatibility
      log('✅ ProductController: Loaded ${productList.length} products');
    } catch (e) {
      log('❌ ProductController: Error loading products: $e');
    }
  }

  // เลือก Category และโหลดสินค้า
  Future<void> selectCategory(String categoryCode) async {
    selectedCategoryCode.value = categoryCode;

    final selectedCategory = categories.firstWhere((category) => category['code'] == categoryCode, orElse: () => categories.first);

    final int categoryId = selectedCategory['id'] ?? 0;
    await getProductByCategory(categoryId: categoryId, branchId: 0);
  }

  // ค้นหาสินค้า
  List<Product> get filteredProducts {
    if (searchQuery.value.isEmpty) {
      return products;
    }
    return products.where((product) {
      final query = searchQuery.value.toLowerCase();
      return (product.name?.toLowerCase().contains(query) ?? false) || (product.code?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  // รีเฟรชข้อมูล
  Future<void> refreshData() async {
    await checkConnectivityAndLoadData();
  }
}
