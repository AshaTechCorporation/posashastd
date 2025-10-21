import 'dart:developer';

import 'package:flutter/material.dart'; // ✅ เพิ่ม import สำหรับ Colors และ Icon
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:posashastd/local_db/category_local.dart';
import 'package:posashastd/local_db/panel_local.dart';
import 'package:posashastd/local_db/panel_product_local.dart';
import 'package:posashastd/local_db/product_local.dart';
import 'package:posashastd/models/product.dart';
import 'package:posashastd/services/homeService.dart';
import 'package:posashastd/services/isar_service.dart';

import '../../models/panel.dart';
import '../../models/panel_product.dart';
import '../../services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  // RxList<Product> products = <Product>[].obs;
  // RxList<Panel> panels = <Panel>[].obs;
  // RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  // RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  RxList<ProductLocal> products = <ProductLocal>[].obs;
  RxList<PanelLocal> panels = <PanelLocal>[].obs;
  RxList<CategoryLocal> categories = <CategoryLocal>[].obs;
  RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  RxString selectedCategoryCode = ''.obs;
  RxBool isConnected = false.obs;

  // ตัวแปรสำหรับจัดการ shift
  RxBool isShiftOpen = false.obs;
  RxString currentShiftId = ''.obs;

  // ตัวแปรสำหรับจัดการ device info
  RxMap<String, dynamic> deviceInfo = <String, dynamic>{}.obs;

  // ✅ ตัวแปรสำหรับเก็บข้อมูลออเดอร์ที่แก้ไข
  int? editOrderId;
  String? editOrderNumber;

  final _databaseService = DatebaseService();
  final _isarService = IsarService();

  @override
  void onInit() {
    super.onInit();
    log('🚀 HomeController onInit called');

    // ✅ โหลดข้อมูล device ตั้งแต่เริ่มต้น
    loadDeviceInfo();

    checkShiftStatus();
    fetchProducts();
  }

  //เช็คล็อกอิน
  Future<Map<String, dynamic>?> checkLogin() async {
    try {
      final data = await Homeservice.checkLogin();
      log('✅ Login successful, data: ${data}');
      return data;
    } catch (e) {
      log('❌ Error checking login: $e');
      return null;
    }
  }

  //เช็ค device id
  Future checkDevice({required String deviceId}) async {
    try {
      final data = await Homeservice.checkDevice(deviceId: deviceId);
      log('✅ Device checked, data: ${data}');
      return data;
    } catch (e) {
      log('❌ Error checking device: $e');
      return null;
    }
  }

  // เพิ่ม device id
  Future registerDevice({required String deviceId, required String name, required String description}) async {
    try {
      final data = await Homeservice.registerDevice(deviceId: deviceId, name: name, description: description);
      log('✅ Device registered, data: ${data}');
      return data;
    } catch (e) {
      log('❌ Error registering device: $e');
      return null;
    }
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

      // ✅ โหลดข้อมูล device ก่อนเพื่อให้แน่ใจว่ามี deviceId
      await loadDeviceInfo();

      // ✅ ใช้ device internal ID ที่บันทึกไว้แทนเลข 1
      final currentDeviceInternalId = getCurrentDeviceInternalId();
      final deviceIdToUse = currentDeviceInternalId ?? 1; // ใช้ 1 เป็น fallback

      log('📱 Device info loaded: ${deviceInfo.isNotEmpty}');
      log('📱 Current device internal ID: $currentDeviceInternalId');
      log('📱 Using device ID for shift: $deviceIdToUse');

      final shiftData = {"deviceId": deviceIdToUse, "change": change, "cash": cash, "remark": remark};

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
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถเปิดกะได้: ${e.toString()}', backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
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
        Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถปิดกะได้ - ไม่ได้รับการตอบกลับจากเซิร์ฟเวอร์', backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
        return false;
      }
    } catch (e) {
      log('❌ Error closing shift: $e');
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถปิดกะได้: ${e.toString()}', backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
      return false;
    }
  }

  void fetchProducts() async {
    log('Fetch Products');
    try {
      // final products = await _databaseService.getProducts();
      // this.products.assignAll(products);
      final panel = await _isarService.getPanels();
      // final panel = await _databaseService.getPanels();
      panels.assignAll(panel);
    } catch (e) {
      log('Fetch Products Error: $e');
      // handle error
    }
  }

  void addPanel() {
    // panels.add(Panel(0, panelProducts: List.generate(20, (i) => PanelProduct(0))));
    panels.add(
      PanelLocal()
        ..name = 'Panel ${panels.length + 1}'
        ..panelProducts.addAll(List.generate(20, (i) => PanelProductLocal())),
    );
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
        Get.snackbar('ไม่มีการเชื่อมต่อ', 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต', backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
      }
    } catch (e) {
      log('❌ Error checking connectivity: $e');
    }
  }

  // ดึงข้อมูล Category
  Future<void> getlistCategory() async {
    try {
      log('📂 Fetching categories...');
      final List<CategoryLocal> rawData = await _isarService.getCategories();

      categories.assignAll([
        CategoryLocal()
          ..id = 0
          ..code = 'ALL'
          ..name = 'ทั้งหมด',
        ...rawData,
      ]);

      selectedCategoryCode.value = categories.first.code!;
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
      final List<ProductLocal> parsedProducts = await _isarService.getProducts(categoryId: categoryId);
      products.assignAll(parsedProducts);
    } catch (e) {
      log('Error loading products: $e');
    }
  }

  // เพิ่มสินค้าลงตะกร้า
  void addToCart(ProductLocal product) {
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

  // ✅ เก็บข้อมูล device ลง SharedPreferences
  Future<void> saveDeviceInfo(Map<String, dynamic> deviceData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // เก็บข้อมูล device แต่ละฟิลด์
      await prefs.setString('device_id', deviceData['deviceId'] ?? '');
      await prefs.setString('device_name', deviceData['name'] ?? '');
      await prefs.setString('device_description', deviceData['description'] ?? '');
      await prefs.setBool('device_active', deviceData['active'] ?? true);
      await prefs.setInt('device_store_id', deviceData['store']?['id'] ?? 1);
      await prefs.setInt('device_internal_id', deviceData['id'] ?? 0);
      await prefs.setString('device_created_at', deviceData['createdAt'] ?? '');
      await prefs.setString('device_updated_at', deviceData['updatedAt'] ?? '');

      // อัปเดต observable
      deviceInfo.value = deviceData;

      log('💾 Device info saved successfully: ${deviceData['deviceId']}');
    } catch (e) {
      log('❌ Error saving device info: $e');
      rethrow;
    }
  }

  // ✅ โหลดข้อมูล device จาก SharedPreferences
  Future<Map<String, dynamic>?> loadDeviceInfo() async {
    try {
      log('🔄 Loading device info from SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();

      final deviceId = prefs.getString('unique_device_id');
      log('📱 Found deviceId in SharedPreferences: $deviceId');

      if (deviceId == null || deviceId.isEmpty) {
        log('⚠️ No device info found in SharedPreferences');
        return null;
      }

      final deviceData = {
        'deviceId': deviceId,
        'name': prefs.getString('device_name') ?? '',
        'description': prefs.getString('device_description') ?? '',
        'active': prefs.getBool('device_active') ?? true,
        'store': {'id': prefs.getInt('device_store_id') ?? 1},
        'id': prefs.getInt('device_internal_id') ?? 0,
        'createdAt': prefs.getString('device_created_at') ?? '',
        'updatedAt': prefs.getString('device_updated_at') ?? '',
      };

      // อัปเดต observable
      deviceInfo.value = deviceData;

      log('📱 Device info loaded: ${deviceData['deviceId']} ${deviceData['id']}');
      return deviceData;
    } catch (e) {
      log('❌ Error loading device info: $e');
      return null;
    }
  }

  // ✅ ลบข้อมูล device (สำหรับ logout หรือ reset)
  Future<void> clearDeviceInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('device_id');
      await prefs.remove('device_name');
      await prefs.remove('device_description');
      await prefs.remove('device_active');
      await prefs.remove('device_store_id');
      await prefs.remove('device_internal_id');
      await prefs.remove('device_created_at');
      await prefs.remove('device_updated_at');

      // เคลียร์ observable
      deviceInfo.clear();

      log('🗑️ Device info cleared');
    } catch (e) {
      log('❌ Error clearing device info: $e');
    }
  }

  // ✅ ดึงข้อมูล device ปัจจุบัน
  Map<String, dynamic>? getCurrentDeviceInfo() {
    return deviceInfo.isNotEmpty ? Map<String, dynamic>.from(deviceInfo) : null;
  }

  // ✅ ดึง deviceId ปัจจุบัน
  String? getCurrentDeviceId() {
    final deviceId = deviceInfo['deviceId'];
    log('🔍 getCurrentDeviceId() called - deviceInfo.length: ${deviceInfo.length}, deviceId: $deviceId');
    return deviceId;
  }

  // ✅ ดึง device internal ID ปัจจุบัน (สำหรับส่ง API)
  int? getCurrentDeviceInternalId() {
    final deviceId = deviceInfo['id'];
    log('🔍 getCurrentDeviceInternalId() called - deviceInfo.length: ${deviceInfo.length}, id: $deviceId');
    return deviceId;
  }
}
