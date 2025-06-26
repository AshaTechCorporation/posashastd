import 'package:flutter/material.dart';
import 'package:posashastd/V2S/login/loginFormPageV2s.dart';

class LoginPageV2s extends StatelessWidget {
  const LoginPageV2s({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50), // เขียว Loyverse
      body: Column(
        children: [
          // 🔹 โลโก้และชื่อแอป
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ไอคอนของแอป (ใช้ Icon แทน หรือใส่รูป logo จริงก็ได้)
                  const Icon(Icons.card_giftcard, size: 80, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text('POSASHA', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  const Text('POINT OF SALE', style: TextStyle(fontSize: 16, color: Colors.white70, letterSpacing: 1.2)),
                ],
              ),
            ),
          ),

          // 🔹 ปุ่มด้านล่าง
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ปุ่มลงทะเบียน
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                      onPressed: () {
                        // ลงทะเบียน
                      },
                      child: const Text('ลงทะเบียน', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ปุ่มเข้าสู่ระบบ (ขอบเขียว)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF4CAF50), width: 2)),
                      onPressed: () {
                        // เข้าสู่ระบบ
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginFormPageV2s()));
                      },
                      child: const Text('ลงชื่อเข้าใช้', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 16)),
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
