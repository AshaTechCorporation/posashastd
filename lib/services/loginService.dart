import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:posashastd/constants.dart';

class LoginService {
  const LoginService();

  static Future login({required String username, required String password}) async {
    final url = Uri.https(publicUrl, '/api/auth/sign-in');
    final response = await http.post(url, body: {'username': username, 'password': password});
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return data;
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }
}
