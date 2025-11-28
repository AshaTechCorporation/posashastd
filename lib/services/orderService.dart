import 'dart:convert' as convert;
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:posashastd/constants.dart';
import 'package:posashastd/services/auth_service.dart';

class OrderService {
  const OrderService();

  static Future getOrders({DateTime? selectedDate}) async {
    log('🌐 OrderService.getOrders() called');
    final authService = AuthService();

    // ✅ ใช้วันที่ที่เลือก หรือวันที่ปัจจุบันถ้าไม่ได้เลือก
    final now = selectedDate ?? DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // ✅ Format วันที่เป็น String (YYYY-MM-DD HH:mm:ss)
    final startDateStr =
        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')} ${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}:${startDate.second.toString().padLeft(2, '0')}';
    final endDateStr =
        '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')} ${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}:${endDate.second.toString().padLeft(2, '0')}';

    // ✅ สร้าง URL พร้อม query parameters
    final url = Uri.https(publicUrl, '/api/order/datatables', {
      'page': '1',
      'limit': '500',
      'sortBy': 'no:ASC',
      'search': '',
      'filter.orderDate': '\$btw:$startDateStr,$endDateStr',
      'filter.orderType': 'order',
    });

    log('🔗 API URL: $url');
    log('🔑 Token: ${authService.currentToken}');
    log('📅 Date range: $startDateStr to $endDateStr');

    var headers = {'Authorization': 'Bearer ${authService.currentToken}', 'Content-Type': 'application/json'};
    final response = await http.get(url, headers: headers);

    log('📡 Response status: ${response.statusCode}');
    log('📄 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      log('✅ Orders data received: ${data['data']?.length ?? 0} orders');
      return data['data'];
    } else {
      final data = convert.jsonDecode(response.body);
      log('❌ API Error: ${data['message']}');
      throw Exception(data['message']);
    }
  }

  //เช็คสินค้าส่วนลด
  static Future checkDiscount() async {
    final authService = AuthService();
    final url = Uri.https(publicUrl, '/api/mix-and-match-rule');
    var headers = {'Authorization': 'Bearer ${authService.currentToken}', 'Content-Type': 'application/json'};
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return data;
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }
}
