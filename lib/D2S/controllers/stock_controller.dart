import 'dart:developer';

import 'package:get/get.dart';
import 'package:posashastd/models/branch.dart';
import 'package:posashastd/services/stock_service.dart';

class StockController extends GetxController {
  RxList<Branch> branches = <Branch>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    log('🚀 StockController onInit called');
    super.onInit();
    getBranches();
  }

  Future<void> getBranches() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      log('🔄 Loading branches from API...');

      final rawData = await StockService.getProducts();
      log('📦 Raw API response: $rawData');
      log('📦 Response type: ${rawData.runtimeType}');

      if (rawData == null) {
        throw Exception('API returned null data');
      }

      // ตรวจสอบว่า response เป็น List หรือ Object
      List<Map<String, dynamic>> parsedBranches;
      if (rawData is List) {
        parsedBranches = List<Map<String, dynamic>>.from(rawData);
      } else if (rawData is Map && rawData.containsKey('data')) {
        // กรณีที่ API ส่งมาเป็น {data: [...]}
        parsedBranches = List<Map<String, dynamic>>.from(rawData['data']);
      } else {
        throw Exception('Unexpected API response format: ${rawData.runtimeType}');
      }

      final List<Branch> branchesList =
          parsedBranches.map((branchData) {
            log('🔍 Processing branch data: $branchData');
            return Branch.fromJson(branchData);
          }).toList();

      branches.assignAll(branchesList);
      log('✅ Loaded ${branchesList.length} branches successfully');

      for (var branch in branchesList) {
        log('🏢 Branch: ${branch.name} (ID: ${branch.id})');
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      log('❌ Error loading branches: $e');
      log('❌ Error type: ${e.runtimeType}');
    }
  }

  // ✅ ฟังก์ชันสำหรับ refresh ข้อมูล
  Future<void> refreshBranches() async {
    await getBranches();
  }
}
