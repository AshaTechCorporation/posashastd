import 'package:flutter/material.dart';
import 'package:posashastd/D2S/login/signInPage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50), // เขียวหลัก
      body: Column(
        children: [
          // ส่วนบน (โลโก้และชื่อแอป)
          const Expanded(
            flex: 3,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard, size: 64, color: Colors.white),
                  SizedBox(height: 12),
                  Text('POSASHA', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('POINT OF SALE', style: TextStyle(fontSize: 14, letterSpacing: 1.5, color: Colors.white)),
                ],
              ),
            ),
          ),

          // ส่วนล่าง (ปุ่ม)
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ปุ่ม "ลงทะเบียน"
                  SizedBox(
                    width: screenWidth * 0.25,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8BC34A), padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: () {
                        // TODO: ไปหน้าลงทะเบียน
                      },
                      child: const Text('ลงทะเบียน', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ปุ่ม "ลงชื่อเข้าใช้"
                  SizedBox(
                    width: screenWidth * 0.25,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8BC34A), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SignInPage()));
                      },
                      child: const Text('ลงชื่อเข้าใช้', style: TextStyle(fontSize: 18, color: Color(0xFF8BC34A))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
