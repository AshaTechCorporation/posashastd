import 'package:flutter/material.dart';
import 'package:posashastd/D2S/home/homePage.dart';
import 'package:posashastd/V2S/login/loginController.dart';
import 'package:posashastd/D2S/login/forgotPasswordPage.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(
      builder:
          (context, controller, child) => Scaffold(
            appBar: AppBar(
              title: const Text('ลงชื่อเข้าใช้', style: TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFF4CAF50),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            backgroundColor: const Color(0xFFF5F5F5), // สีพื้นเทาอ่อน
            body: Center(
              child: Container(
                width: 360,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ช่องกรอกอีเมล
                    TextField(controller: emailController, decoration: const InputDecoration(labelText: 'อีเมล')),
                    const SizedBox(height: 16),

                    // ช่องกรอกรหัสผ่าน
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'รหัสผ่าน',
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

                    // ปุ่มลงชื่อเข้าใช้
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // ล็อกอิน
                          try {
                            final _login = await controller.signIn(username: emailController.text, password: passwordController.text);
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
                          } on Exception catch (e) {
                            if (!mounted) return;
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8BC34A), padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('ลงชื่อเข้าใช้', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ลิงก์ลืมรหัสผ่าน
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
                      },
                      child: const Text('ลืมรหัสผ่าน?', style: TextStyle(color: Colors.blue, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
