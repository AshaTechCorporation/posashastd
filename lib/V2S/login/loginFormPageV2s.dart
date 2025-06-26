import 'package:flutter/material.dart';
import 'package:posashastd/V2S/home/homev2s.dart';
import 'package:posashastd/V2S/login/loginController.dart';
import 'package:provider/provider.dart';

class LoginFormPageV2s extends StatefulWidget {
  const LoginFormPageV2s({super.key});

  @override
  State<LoginFormPageV2s> createState() => _LoginFormPageV2sState();
}

class _LoginFormPageV2sState extends State<LoginFormPageV2s> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(
      builder:
          (context, controller, child) => Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: const Color(0xFF4CAF50),
              title: const Text('ลงชื่อเข้าใช้', style: TextStyle(color: Colors.white)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Center(
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 ช่องอีเมล
                    TextField(controller: emailController, decoration: const InputDecoration(labelText: 'อีเมล', border: UnderlineInputBorder())),
                    const SizedBox(height: 16),

                    // 🔹 ช่องรหัสผ่าน
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'รหัสผ่าน',
                        border: const UnderlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🔹 ปุ่มลงชื่อเข้าใช้
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                        onPressed: () async {
                          // ล็อกอิน
                          try {
                            final _login = await controller.signIn(username: emailController.text, password: passwordController.text);
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Homev2s()), (route) => false);
                          } on Exception catch (e) {
                            if (!mounted) return;
                          }
                        },
                        child: const Text('ลงชื่อเข้าใช้', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🔹 ลิงก์ลืมรหัสผ่าน
                    GestureDetector(
                      onTap: () {
                        // ลืมรหัสผ่าน
                      },
                      child: const Text('ลืมรหัสผ่าน?', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
