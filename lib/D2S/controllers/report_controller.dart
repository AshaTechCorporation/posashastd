import 'dart:developer';

import 'package:get/get.dart';
import 'package:posashastd/models/summary.dart';
import 'package:posashastd/services/reportService.dart';

class ReportController extends GetxController {
  // TODO: สร้าง controller สำหรับ report
  RxList<Summary> summary = <Summary>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // ไม่เรียก getSummaryReport() ที่นี่ เพราะยังไม่มี shift_id
  }

  Future<void> getSummaryReport({int? shift_id}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      log('🔄 Loading summary report...');

      final shiftId = shift_id ?? 1; // ใช้ค่าเริ่มต้นเป็น 1 ถ้าไม่ได้ส่งมา
      final rawData = await ReportService.getSummaryReport(shift_id: shiftId);
      log('📦 Raw API response: $rawData');
      log('📦 Response type: ${rawData.runtimeType}');

      if (rawData == null) {
        throw Exception('API returned null data');
      }

      // ตรวจสอบว่า response เป็น List
      List<Map<String, dynamic>> parsedSummary;
      if (rawData is List) {
        parsedSummary = List<Map<String, dynamic>>.from(rawData);
      } else if (rawData is Map && rawData.containsKey('data')) {
        // API ส่งมาเป็น {data: [...]}
        parsedSummary = List<Map<String, dynamic>>.from(rawData['data']);
      } else {
        throw Exception('Unexpected API response format: ${rawData.runtimeType}');
      }

      final List<Summary> summaryList = parsedSummary.map((summaryData) => Summary.fromJson(summaryData)).toList();
      summary.assignAll(summaryList);
      isLoading.value = false;

      log('✅ Loaded ${summaryList.length} summary items for shift $shiftId');
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      log('❌ Error loading summary report: $e');
    }
  }

  // ✅ ฟังก์ชันสำหรับเรียกด้วย shift_id เฉพาะ
  Future<void> getSummaryReportWithShiftId(dynamic shiftId) async {
    int? parsedShiftId;

    if (shiftId is int) {
      parsedShiftId = shiftId;
    } else if (shiftId is String) {
      parsedShiftId = int.tryParse(shiftId);
    }

    if (parsedShiftId != null && parsedShiftId > 0) {
      await getSummaryReport(shift_id: parsedShiftId);
    } else {
      log('⚠️ Invalid shift ID: $shiftId');
      errorMessage.value = 'Invalid shift ID: $shiftId';
    }
  }
}
