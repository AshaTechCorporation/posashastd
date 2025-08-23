import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/constants.dart';

import '../D2S/home/homePage.dart';
import '../models/login_response.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _databaseService = DatebaseService();

  bool _isLoading = false;
  bool _isCheckingLogin = true; // ✅ สำหรับ loading ตอน check existing login
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkExistingLogin();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ตรวจสอบว่ามีการ login อยู่แล้วหรือไม่
  Future<void> _checkExistingLogin() async {
    try {
      setState(() {
        _isCheckingLogin = true;
      });

      final isLoggedIn = await _authService.checkLoginStatus();
      if (isLoggedIn && mounted) {
        await _databaseService.loadDataSync();
        Get.offAll(HomePage());
      }
    } catch (e) {
      log('❌ Error checking existing login: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingLogin = false;
        });
      }
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final LoginResponse response = await _authService.login(_usernameController.text, _passwordController.text);

      if (response.accessToken != null) {
        // Login สำเร็จ
        log('✅ Login successful, token: ${response.accessToken}');
        _showMessage('เข้าสู่ระบบสำเร็จ', isError: false);

        // โหลดข้อมูลจาก database
        log('🔄 Loading data sync...');
        await _databaseService.loadDataSync();
        log('✅ Data sync completed');

        // นำทางไปหน้าหลัก
        if (mounted) {
          log('🏠 Navigating to HomePage');
          Get.offAll(HomePage());
        }
      } else {
        // Login ไม่สำเร็จ
        _showMessage(response.message ?? 'เข้าสู่ระบบไม่สำเร็จ');
      }
    } catch (e) {
      _showMessage('เกิดข้อผิดพลาดที่ไม่คาดคิด');
      log('🔄 เกิดข้อผิดพลาด... $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : kTabColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ แสดง loading screen ขณะตรวจสอบ existing login
    if (_isCheckingLogin) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.point_of_sale, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text('POS System', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 32),
              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), strokeWidth: 3),
              const SizedBox(height: 16),
              const Text('กำลังตรวจสอบการเข้าสู่ระบบ...', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ลงชื่อเข้าใช้', style: TextStyle(color: Colors.white)),
        backgroundColor: kTabColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 360,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.point_of_sale, size: 80, color: Colors.blue),
                          const SizedBox(height: 16),
                          const Text(
                            'POS System',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                          const SizedBox(height: 16),
                          // ช่องกรอกอีเมล
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(labelText: 'อีเมล'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณาระบุชื่อผู้ใช้';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 16),

                          // ช่องกรอกรหัสผ่าน
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'รหัสผ่าน',
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณาระบุรหัสผ่าน';
                              }
                              // if (value.length < 8) {
                              //   return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
                              // }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
                          ),
                          SizedBox(height: 24),

                          // ปุ่มลงชื่อเข้าใช้
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(backgroundColor: kTabColor, padding: EdgeInsets.symmetric(vertical: 14)),
                              child:
                                  _isLoading
                                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Text('ลงชื่อเข้าใช้', style: TextStyle(fontSize: 16, color: Colors.white)),
                            ),
                          ),
                          SizedBox(height: 12),

                          // ลิงก์ลืมรหัสผ่าน
                          GestureDetector(
                            onTap: () {
                              // TODO: ไปหน้าลืมรหัสผ่าน
                            },
                            child: const Text('ลืมรหัสผ่าน?', style: TextStyle(color: Colors.blue, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Card(
                  //   elevation: 8,
                  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  //   child: Padding(
                  //     padding: EdgeInsets.all(32.0),
                  //     child: Form(
                  //       key: _formKey,
                  //       child: Column(
                  //         mainAxisSize: MainAxisSize.min,
                  //         crossAxisAlignment: CrossAxisAlignment.stretch,
                  //         children: [
                  //           // Logo หรือชื่อระบบ
                  //           const Icon(Icons.point_of_sale, size: 80, color: Colors.blue),
                  //           const SizedBox(height: 16),
                  //           const Text(
                  //             'POS System',
                  //             textAlign: TextAlign.center,
                  //             style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                  //           ),
                  //           const SizedBox(height: 8),
                  //           const Text('เข้าสู่ระบบ', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                  //           const SizedBox(height: 32),

                  //           // Username Field
                  //           TextFormField(
                  //             controller: _usernameController,
                  //             decoration: InputDecoration(
                  //               labelText: 'ชื่อผู้ใช้',
                  //               prefixIcon: const Icon(Icons.person),
                  //               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  //               focusedBorder: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(12),
                  //                 borderSide: const BorderSide(color: Colors.blue, width: 2),
                  //               ),
                  //             ),
                  //             validator: (value) {
                  //               if (value == null || value.isEmpty) {
                  //                 return 'กรุณาระบุชื่อผู้ใช้';
                  //               }
                  //               return null;
                  //             },
                  //             textInputAction: TextInputAction.next,
                  //           ),
                  //           const SizedBox(height: 16),

                  //           // Password Field
                  //           TextFormField(
                  //             controller: _passwordController,
                  //             obscureText: _obscurePassword,
                  //             decoration: InputDecoration(
                  //               labelText: 'รหัสผ่าน',
                  //               prefixIcon: const Icon(Icons.lock),
                  //               suffixIcon: IconButton(
                  //                 icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  //                 onPressed: () {
                  //                   setState(() {
                  //                     _obscurePassword = !_obscurePassword;
                  //                   });
                  //                 },
                  //               ),
                  //               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  //               focusedBorder: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(12),
                  //                 borderSide: const BorderSide(color: Colors.blue, width: 2),
                  //               ),
                  //             ),
                  //             validator: (value) {
                  //               if (value == null || value.isEmpty) {
                  //                 return 'กรุณาระบุรหัสผ่าน';
                  //               }
                  //               // if (value.length < 8) {
                  //               //   return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
                  //               // }
                  //               return null;
                  //             },
                  //             textInputAction: TextInputAction.done,
                  //             onFieldSubmitted: (_) => _login(),
                  //           ),
                  //           const SizedBox(height: 24),

                  //           // Login Button
                  //           ElevatedButton(
                  //             onPressed: _isLoading ? null : _login,
                  //             style: ElevatedButton.styleFrom(
                  //               backgroundColor: Colors.blue,
                  //               foregroundColor: Colors.white,
                  //               padding: const EdgeInsets.symmetric(vertical: 16),
                  //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  //               elevation: 2,
                  //             ),
                  //             child:
                  //                 _isLoading
                  //                     ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  //                     : const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  //           ),
                  //           const SizedBox(height: 16),

                  //           // Forgot Password Link
                  //           TextButton(
                  //             onPressed: () {
                  //               // นำทางไปหน้าลืมรหัสผ่าน
                  //               Navigator.of(context).pushNamed('/forgot-password');
                  //             },
                  //             child: const Text('ลืมรหัสผ่าน?', style: TextStyle(color: Colors.blue)),
                  //           ),
                  //           const SizedBox(height: 16),

                  //           // Register Link
                  //           Row(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: [
                  //               const Text('ยังไม่มีบัญชี? ', style: TextStyle(color: Colors.grey)),
                  //               TextButton(
                  //                 onPressed: () {
                  //                   Get.to(() => const RegisterScreen());
                  //                 },
                  //                 child: const Text('สมัครสมาชิก', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  //               ),
                  //             ],
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
