import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

Future<String?> getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<String?> getRefreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<void> saveTokens(String accessToken) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', accessToken);
  // await prefs.setString('refresh_token', refreshToken);
}

Future<http.Response> refreshAccessToken() async {
  final refreshToken = await getRefreshToken();

  final response = await http.post(
    Uri.parse('$publicUrl/api/auth/refresh'),
    headers: {'Authorization': 'Bearer $refreshToken', 'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final newAccessToken = data['data']['token'];

    await saveTokens(newAccessToken);
    return response;
  } else {
    throw Exception('Failed to refresh token');
  }
}

Future<http.Response> authenticatedRequest(
  String url, {
  String method = 'GET',
  Map<String, String>? headers,
  Object? body,
}) async {
  final accessToken = await getAccessToken();

  headers ??= {};
  headers['Authorization'] = 'Bearer $accessToken';

  http.Response response;
  final uri = Uri.parse(url);

  switch (method.toUpperCase()) {
    case 'POST':
      response = await http.post(uri, headers: headers, body: body);
      break;
    case 'PUT':
      response = await http.put(uri, headers: headers, body: body);
      break;
    case 'DELETE':
      response = await http.delete(uri, headers: headers, body: body);
      break;
    default:
      response = await http.get(uri, headers: headers);
  }

  if (response.statusCode == 401) {
    // Refresh token
    try {
      await refreshAccessToken();
      final newAccessToken = await getAccessToken();
      headers['Authorization'] = 'Bearer $newAccessToken';

      // Retry request
      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(uri, headers: headers, body: body);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers, body: body);
          break;
        default:
          response = await http.get(uri, headers: headers);
      }
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }

  return response;
}