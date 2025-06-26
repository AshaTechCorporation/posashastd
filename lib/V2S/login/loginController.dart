import 'package:flutter/material.dart';
import 'package:posashastd/services/loginService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends ChangeNotifier {
  LoginController({this.loginService = const LoginService()});
  LoginService? loginService;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences? pref;

  Future signIn({required String username, required String password}) async {
    final data = await LoginService.login(username: username, password: password);
    //user = User.fromJson(data['data']);
    final SharedPreferences prefs = await _prefs;
    //await prefs.setInt('userID', user!.id);
    await prefs.setString('token', data['accessToken']);
    notifyListeners();
    return data;
  }
}
