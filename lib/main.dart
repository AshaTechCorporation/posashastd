import 'package:flutter/material.dart';
import 'package:posashastd/D2S/home/homePage.dart';
import 'package:posashastd/D2S/login/loginPage.dart';
import 'package:posashastd/V2S/home/homev2s.dart';
import 'package:posashastd/V2S/login/loginController.dart';
import 'package:posashastd/V2S/login/loginPageV2s.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? token;
late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  prefs = await SharedPreferences.getInstance();
  token = prefs.getString('token');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => LoginController())],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
        debugShowCheckedModeBanner: false,
        home: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 720) {
              // 👉 ถ้าจอเล็ก เช่น Sunmi V2s
              return token == null ? LoginPageV2s() : Homev2s();
            } else {
              // 👉 จอใหญ่ แสดงหน้า HomePage
              return token == null ? LoginPage() : HomePage();
            }
          },
        ),
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
