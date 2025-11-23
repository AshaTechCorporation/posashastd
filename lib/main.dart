import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:posashastd/D2S/controllers/home_controller.dart';
import 'package:posashastd/D2S/home/homePage.dart';
import 'package:posashastd/D2S/receipt/receiptHistoryPage.dart';
import 'package:posashastd/V2S/home/homev2s.dart';
import 'package:posashastd/V2S/login/loginPageV2s.dart';
import 'package:posashastd/login/loginPage.dart';
import 'package:posashastd/services/auth_service.dart';
import 'package:posashastd/services/isar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? token;
late SharedPreferences prefs;
late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  isar = await IsarService().openIsar();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  prefs = await SharedPreferences.getInstance();
  token = prefs.getString('token');

  // ✅ Register HomeController ใน GetX dependency injection
  Get.put(HomeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'IBMPlexSansThai', // กำหนดชื่อฟอนต์ที่ใช้
        // ✅ กำหนดขนาดฟอนต์ขั้นต่ำ 18 และปรับหัวข้อให้ใหญ่ขึ้น
        textTheme: const TextTheme(
          // หัวข้อใหญ่
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),

          // หัวข้อย่อย
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),

          // เนื้อหาทั่วไป (ขั้นต่ำ 18)
          bodyLarge: TextStyle(fontSize: 20),
          bodyMedium: TextStyle(fontSize: 18),
          bodySmall: TextStyle(fontSize: 18),

          // ป้ายกำกับ
          labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(fontSize: 18),
          labelSmall: TextStyle(fontSize: 18),
        ),
      ),
      debugShowCheckedModeBanner: false,
      // เพิ่ม routes สำหรับ GetX
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => _getInitialPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/loginV2s', page: () => const LoginPageV2s()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/homev2s', page: () => const Homev2s()),
        GetPage(name: '/receipt-history', page: () => const ReceiptHistoryPage()),
      ],
    );
  }

  // ฟังก์ชันกำหนดหน้าเริ่มต้น
  Widget _getInitialPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final authService = AuthService();
        if (constraints.maxWidth < 720) {
          // 👉 ถ้าจอเล็ก เช่น Sunmi V2s
          if (authService.currentToken != null) {
            return const Homev2s();
          }
          return const LoginPageV2s();
        } else {
          // 👉 จอใหญ่ เช่น D2S
          if (authService.currentToken != null) {
            return const HomePage();
          }
          return const LoginPage();
        }
      },
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
