import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/home/homePage.dart';
import 'package:posashastd/V2S/home/homev2s.dart';
import 'package:posashastd/login/loginPage.dart';
import 'package:posashastd/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? token;
late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  prefs = await SharedPreferences.getInstance();
  token = prefs.getString('token');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      debugShowCheckedModeBanner: false,
      home: LayoutBuilder(
        builder: (context, constraints) {
          final _authService = AuthService();
          if (constraints.maxWidth < 720) {
            // 👉 ถ้าจอเล็ก เช่น Sunmi V2s
            return const Homev2s();
          } else {
            // 👉 จอใหญ่ เช่น D2S
            if (_authService.currentToken != null) {
              return const HomePage();
            }
            return const LoginPage();
          }
        },
      ),
    );
  }
}

class BlockedMobilePage extends StatelessWidget {
  const BlockedMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('แอปรองรับเฉพาะบน Desktop หรือ Tablet เท่านั้น', style: TextStyle(fontSize: 18, color: Colors.red), textAlign: TextAlign.center),
      ),
    );
  }
}
