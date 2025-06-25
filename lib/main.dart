import 'package:flutter/material.dart';
import 'package:posashastd/D2S/home/homePage.dart';
import 'package:posashastd/V2S/home/homev2s.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      debugShowCheckedModeBanner: false,
      home: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 720) {
            // 👉 ถ้าจอเล็ก เช่น Sunmi V2s
            return const Homev2s();
          } else {
            // 👉 จอใหญ่ แสดงหน้า HomePage
            return const HomePage();
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
