import 'dart:developer';

import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:posashastd/models/product.dart';
import 'package:posashastd/services/homeService.dart';

import '../../models/panel.dart';
import '../../models/panel_product.dart';
import '../../services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  RxList<Product> products = <Product>[].obs;
  RxList<Panel> panels = <Panel>[].obs;
  RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  RxString selectedCategoryCode = ''.obs;
  RxBool isConnected = false.obs;

  // ตัวแปรสำหรับจัดการ shift
  RxBool isShiftOpen = false.obs;
  RxString currentShiftId = ''.obs;

  final _databaseService = DatebaseService();

  @override
  void onInit() {
    super.onInit();
    log('🚀 HomeController onInit called');
    checkShiftStatus();
    fetchProducts();
  }

  // เช็คสถานะ shift
  Future<void> checkShiftStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shiftId = prefs.getString('shift_id');

      if (shiftId != null && shiftId.isNotEmpty) {
        log('✅ Found shift_id: $shiftId');
        currentShiftId.value = shiftId;
        isShiftOpen.value = true;
        // โหลดข้อมูลเมื่อมี shift
        await checkConnectivityAndLoadData();
      } else {
        log('❌ No shift_id found - shift is closed');
        isShiftOpen.value = false;
      }
    } catch (e) {
      log('❌ Error checking shift status: $e');
      isShiftOpen.value = false;
    }
  }

  // เปิดกะ
  Future<bool> openShift({required double change, required double cash, required String remark}) async {
    try {
      log('🔄 Opening shift...');

      final shiftData = {"deviceId": 1, "change": change, "cash": cash, "remark": remark};

      final response = await Homeservice.openShift(formattedShift: shiftData);

      if (response != null && response['id'] != null) {
        final shiftId = response['id'].toString();

        // บันทึก shift_id ลง SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('shift_id', shiftId);

        currentShiftId.value = shiftId;
        isShiftOpen.value = true;

        log('✅ Shift opened successfully with ID: $shiftId');

        // โหลดข้อมูลหลังเปิดกะ
        await checkConnectivityAndLoadData();

        return true;
      } else {
        log('❌ Failed to open shift - no ID returned');
        return false;
      }
    } catch (e) {
      log('❌ Error opening shift: $e');
      Get.snackbar(
        'ข้อผิดพลาด',
        'ไม่สามารถเปิดกะได้: ${e.toString()}',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
  }

  // ปิดกะ
  Future<bool> closeShift() async {
    try {
      if (currentShiftId.value.isEmpty) {
        log('❌ No shift ID to close');
        Get.snackbar('ข้อผิดพลาด', 'ไม่พบข้อมูลกะที่จะปิด', backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
        return false;
      }

      log('🔄 Closing shift with ID: ${currentShiftId.value}');

      final shiftId = int.tryParse(currentShiftId.value);
      if (shiftId == null) {
        log('❌ Invalid shift ID format');
        return false;
      }

      final response = await Homeservice.closedShift(shiftId: shiftId);

      log('🔍 Debug - API Response: $response');

      if (response != null) {
        // ลบ shift_id จาก SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('shift_id');

        //currentShiftId.value = '';
        isShiftOpen.value = false;

        log('✅ Shift closed successfully');

        // เคลียร์ข้อมูลที่โหลดไว้
        products.clear();
        categories.clear();
        cartItems.clear();
        selectedCategoryCode.value = '';

        return true;
      } else {
        log('❌ Failed to close shift - no response');
        Get.snackbar(
          'ข้อผิดพลาด',
          'ไม่สามารถปิดกะได้ - ไม่ได้รับการตอบกลับจากเซิร์ฟเวอร์',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }
    } catch (e) {
      log('❌ Error closing shift: $e');
      Get.snackbar(
        'ข้อผิดพลาด',
        'ไม่สามารถปิดกะได้: ${e.toString()}',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
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

      // โหลดสินค้าทั้งหมด (categoryId = 0 สำหรับทั้งหมด)
      log('🛍️ Loading all products for main tab');
      await getProductByCategory(categoryId: 0, branchId: 0);
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

  // ลบสินค้าออกจากตะกร้าตาม index
  void removeFromCart(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
      log('🗑️ Removed item at index $index from cart');
    }
  }

  // ✅ อัพเดทจำนวนสินค้าในตะกร้า
  void updateCartItemQuantity(int index, int newQuantity) {
    if (index >= 0 && index < cartItems.length && newQuantity > 0) {
      // สร้าง List ใหม่เพื่อให้ GetX ตรวจจับการเปลี่ยนแปลง
      final updatedList = List<Map<String, dynamic>>.from(cartItems);
      updatedList[index] = {...updatedList[index], 'qty': newQuantity};
      cartItems.assignAll(updatedList);

      log('📝 Updated item at index $index to quantity $newQuantity');
    }
  }

  // เคลียร์ตะกร้า
  void clearCart() {
    cartItems.clear();
  }
}
