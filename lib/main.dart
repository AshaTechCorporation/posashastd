import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/home/homePage.dart';
import 'package:posashastd/V2S/home/homev2s.dart';

import 'login/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      // theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow)),
      debugShowCheckedModeBanner: false,
      home: LayoutBuilder(
        builder: (context, constraints) {
          return LoginScreen();
          // if (constraints.maxWidth < 720) {
          //   // 👉 ถ้าจอเล็ก เช่น Sunmi V2s
          //   return const Homev2s();
          // } else {
          //   // 👉 จอใหญ่ แสดงหน้า HomePage
          //   return const HomePage();
          // }
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
