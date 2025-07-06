import 'dart:convert' as convert;
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:posashastd/constants.dart';
import 'package:posashastd/services/auth_service.dart';

class OrderService {
  const OrderService();

  static Future getOrders() async {
    log('🌐 OrderService.getOrders() called');
    final authService = AuthService();
    final url = Uri.https(publicUrl, '/api/order/datatables');
    log('🔗 API URL: $url');
    log('🔑 Token: ${authService.currentToken}');

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
}
