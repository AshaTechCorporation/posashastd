import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/login_response.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Headers สำหรับ API calls
  Map<String, String> get _headers => {'Content-Type': 'application/json', 'Accept': 'application/json'};

  String? _currentToken;

  // Getters
  String? get currentToken => _currentToken;
  bool get isLoggedIn => _currentToken != null;

  /// ตรวจสอบสถานะการ login จาก SharedPreferences
  Future<bool> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      // final userDataString = prefs.getString('user_data');

      if (token != null) {
        _currentToken = token;

        // ตรวจสอบว่า token ยังใช้งานได้อยู่หรือไม่
        // return await _validateToken();
        return true;
      }
    } catch (e) {
      print('Check login status error: $e');
    }

    return false;
  }

  /// เข้าสู่ระบบด้วย username และ password
  Future login(String username, String password) async {
    try {
      final url = Uri.https(publicUrl, '/api/auth/sign-in');

      final body = jsonEncode({
        'username': username.trim(),
        'password': password,
        // 'device_info': await _getDeviceInfo(),
      });

      final response = await http
          .post(url, headers: _headers, body: body)
          .timeout(const Duration(seconds: 30), onTimeout: () => throw Exception('การเชื่อมต่อหมดเวลา'));

      // final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));

      if (response.statusCode == 200) {
        final data = LoginResponse.fromJson(jsonDecode(response.body));

        // บันทึกข้อมูล login
        await _saveLoginData(data.accessToken!, data.refreshToken!);
        // _currentToken = loginResponse.token;
        // _currentUser = loginResponse.user;

        return data;
      } else if (response.statusCode == 401) {
        // return LoginResponse(
        //   success: false,
        //   message: 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
        // );
      } else if (response.statusCode == 429) {
        // return LoginResponse(
        //   success: false,
        //   message: 'พยายามเข้าสู่ระบบบ่อยเกินไป กรุณาลองใหม่ภายหลัง',
        // );
      } else {
        // return LoginResponse(
        //   success: false,
        //   message: loginResponse.message ?? 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ',
        // );
      }
    } catch (e) {
      // return LoginResponse(success: false, message: _handleError(e));
    }
  }

  /// สมัครสมาชิกใหม่
  Future<LoginResponse> register(String username, String password) async {
    try {
      final url = Uri.https(publicUrl, '/api/auth/sign-up');

      final body = jsonEncode({'username': username.trim(), 'password': password});

      final response = await http
          .post(url, headers: _headers, body: body)
          .timeout(const Duration(seconds: 30), onTimeout: () => throw Exception('การเชื่อมต่อหมดเวลา'));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = LoginResponse.fromJson(jsonDecode(response.body));
        return data;
      } else if (response.statusCode == 409) {
        return LoginResponse(accessToken: null, message: 'ชื่อผู้ใช้นี้มีอยู่ในระบบแล้ว');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        return LoginResponse(accessToken: null, message: errorData['message'] ?? 'ข้อมูลไม่ถูกต้อง');
      } else {
        return LoginResponse(accessToken: null, message: 'เกิดข้อผิดพลาดในการสมัครสมาชิก');
      }
    } catch (e) {
      return LoginResponse(accessToken: null, message: 'เกิดข้อผิดพลาดที่ไม่คาดคิด: ${e.toString()}');
    }
  }

  /// บันทึกข้อมูล login
  Future<void> _saveLoginData(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setString('refresh_token', refreshToken);
    // await prefs.setString('user_data', jsonEncode(user.toJson()));
    await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);
  }
}
