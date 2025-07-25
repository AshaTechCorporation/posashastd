import 'dart:convert' as convert;
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:posashastd/constants.dart';
import 'package:posashastd/services/auth_service.dart';

class ReportService {
  const ReportService();

  static Future getSummaryReport({required int shift_id}) async {
    final authService = AuthService();
    final url = Uri.https(publicUrl, '/api/shift/$shift_id/summary');
    var headers = {'Authorization': 'Bearer ${authService.currentToken}', 'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    log('📡 Response status: ${response.statusCode}');
    log('📄 Response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return data;
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }
}
