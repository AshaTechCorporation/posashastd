import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:posashastd/services/isar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:posashastd/constants.dart';

import '../D2S/home/homePage.dart';
import '../D2S/controllers/home_controller.dart';
import '../services/homeService.dart';
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
  final _isarService = IsarService();

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
        await _isarService.loadData();
        // await _databaseService.loadDataSync();
        
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

        // ✅ ตรวจสอบ deviceId หลังจากล็อกอินสำเร็จ
        log('🔍 Checking device registration...');
        await _checkDeviceRegistration();
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

  // ✅ ดึง deviceId จากเครื่อง (ไม่เปลี่ยนแปลง)
  Future<String> _getDeviceId() async {
    try {
      // ตรวจสอบว่าเคยเก็บ deviceId ไว้แล้วหรือไม่
      final prefs = await SharedPreferences.getInstance();
      String? savedDeviceId = prefs.getString('unique_device_id');

      if (savedDeviceId != null && savedDeviceId.isNotEmpty) {
        log('📱 Found saved deviceId: $savedDeviceId');
        return savedDeviceId;
      }

      // ถ้ายังไม่เคยเก็บ ให้สร้างใหม่จาก device info + MAC Address
      String deviceId;

      // ดึง MAC Address ก่อน
      log('🔄 Getting MAC Address...');
      final macAddress = await _getMacAddress();
      log('📱 MAC Address result: $macAddress');

      if (Platform.isAndroid) {
        // สำหรับ Android ใช้ Android ID + MAC Address
        deviceId = await _getAndroidDeviceId(macAddress);
      } else if (Platform.isIOS) {
        // สำหรับ iOS ใช้ identifierForVendor + MAC Address
        deviceId = await _getIOSDeviceId(macAddress);
      } else {
        // สำหรับ platform อื่นๆ ใช้ hostname + MAC Address
        deviceId = await _getGenericDeviceId(macAddress);
      }

      // เก็บ deviceId ไว้ใช้ครั้งต่อไป
      await prefs.setString('unique_device_id', deviceId);
      log('📱 Generated and saved new deviceId: $deviceId');

      return deviceId;
    } catch (e) {
      log('❌ Error getting deviceId: $e');
      // ใช้ค่าเริ่มต้นถ้าเกิดข้อผิดพลาด
      final fallbackId = 'POS-${DateTime.now().millisecondsSinceEpoch}';

      // พยายามเก็บ fallback ID
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('unique_device_id', fallbackId);
      } catch (_) {}

      return fallbackId;
    }
  }

  // ✅ ดึง MAC Address จากเครื่อง
  Future<String> _getMacAddress() async {
    try {
      log('🔍 Attempting to get MAC Address...');
      const platform = MethodChannel('device_info');
      final String macAddress = await platform.invokeMethod('getMacAddress');
      log('📱 Raw MAC Address: $macAddress');

      // ลบ : และ - และเอาแค่ 6 ตัวท้าย
      final cleanMac = macAddress.replaceAll(':', '').replaceAll('-', '').toUpperCase();
      final finalMac = cleanMac.length > 6 ? cleanMac.substring(cleanMac.length - 6) : cleanMac;
      log('✅ Cleaned MAC Address: $finalMac');

      return finalMac;
    } catch (e) {
      log('❌ Error getting MAC Address: $e');
      log('🔄 Using hostname hash as fallback...');

      // ใช้ hostname hash แทน
      try {
        final hostname = Platform.localHostname;
        log('🏠 Hostname: $hostname');
        final hostHash = hostname.hashCode.abs().toString();
        final finalHash = hostHash.length > 6 ? hostHash.substring(0, 6) : hostHash;
        log('✅ Fallback MAC (hostname hash): $finalHash');

        return finalHash;
      } catch (e2) {
        log('❌ Error getting hostname: $e2');
        // ใช้ timestamp เป็นทางเลือกสุดท้าย
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final finalTimestamp = timestamp.substring(timestamp.length - 6);
        log('✅ Fallback MAC (timestamp): $finalTimestamp');

        return finalTimestamp;
      }
    }
  }

  // ดึง Android Device ID + MAC Address
  Future<String> _getAndroidDeviceId(String macAddress) async {
    try {
      const platform = MethodChannel('device_info');
      final String androidId = await platform.invokeMethod('getAndroidId');
      final cleanAndroidId = androidId.length > 8 ? androidId.substring(0, 8) : androidId;
      return 'POS-AND-$cleanAndroidId-$macAddress';
    } catch (e) {
      log('❌ Error getting Android ID: $e');
      // ใช้ hostname + MAC Address แทน
      final hostname = Platform.localHostname;
      final hostHash = hostname.hashCode.abs().toString();
      final cleanHostHash = hostHash.length > 8 ? hostHash.substring(0, 8) : hostHash;
      return 'POS-AND-$cleanHostHash-$macAddress';
    }
  }

  // ดึง iOS Device ID + MAC Address
  Future<String> _getIOSDeviceId(String macAddress) async {
    try {
      const platform = MethodChannel('device_info');
      final String vendorId = await platform.invokeMethod('getVendorId');
      final cleanVendorId = vendorId.length > 8 ? vendorId.substring(0, 8) : vendorId;
      return 'POS-IOS-$cleanVendorId-$macAddress';
    } catch (e) {
      log('❌ Error getting iOS Vendor ID: $e');
      // ใช้ hostname + MAC Address แทน
      final hostname = Platform.localHostname;
      final hostHash = hostname.hashCode.abs().toString();
      final cleanHostHash = hostHash.length > 8 ? hostHash.substring(0, 8) : hostHash;
      return 'POS-IOS-$cleanHostHash-$macAddress';
    }
  }

  // ดึง Generic Device ID + MAC Address (สำหรับ platform อื่นๆ)
  Future<String> _getGenericDeviceId(String macAddress) async {
    try {
      final hostname = Platform.localHostname;
      final hostHash = hostname.hashCode.abs().toString();
      final cleanHostHash = hostHash.length > 8 ? hostHash.substring(0, 8) : hostHash;
      return 'POS-GEN-$cleanHostHash-$macAddress';
    } catch (e) {
      log('❌ Error getting generic device ID: $e');
      // ใช้ timestamp + MAC Address เป็นทางเลือกสุดท้าย
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final cleanTimestamp = timestamp.length > 8 ? timestamp.substring(timestamp.length - 8) : timestamp;
      return 'POS-GEN-$cleanTimestamp-$macAddress';
    }
  }

  // ✅ ตรวจสอบการลงทะเบียน device
  Future<void> _checkDeviceRegistration() async {
    try {
      // ดึง deviceId จากเครื่อง
      final deviceId = await _getDeviceId();

      // เรียกใช้ฟังก์ชัน checkDevice จาก HomeService
      final isRegistered = await Homeservice.checkDevice(deviceId: deviceId);

      if (isRegistered) {
        // Device ลงทะเบียนแล้ว - ไปหน้า HomePage ตามปกติ
        log('✅ Device is registered, navigating to HomePage');
        if (mounted) {
          Get.offAll(HomePage());
        }
      } else {
        // Device ยังไม่ลงทะเบียน - แสดง dialog สำหรับลงทะเบียน
        log('⚠️ Device not registered, showing registration dialog');
        if (mounted) {
          await _showDeviceRegistrationDialog();
        }
      }
    } catch (e) {
      log('❌ Error checking device registration: $e');
      // ถ้าเกิดข้อผิดพลาด ให้ไปหน้า HomePage ตามปกติ
      if (mounted) {
        _showMessage('ไม่สามารถตรวจสอบการลงทะเบียนอุปกรณ์ได้', isError: true);
        Get.offAll(HomePage());
      }
    }
  }

  // ✅ แสดง dialog สำหรับลงทะเบียน device
  Future<void> _showDeviceRegistrationDialog() async {
    final deviceNameController = TextEditingController();
    final locationController = TextEditingController();

    await Get.dialog<bool>(
      AlertDialog(
        title: Row(children: const [Icon(Icons.devices, color: Colors.blue), SizedBox(width: 8), Text('ลงทะเบียนอุปกรณ์')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('อุปกรณ์นี้ยังไม่ได้ลงทะเบียน กรุณากรอกข้อมูลเพื่อลงทะเบียน', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 16),

            // ชื่ออุปกรณ์
            TextField(
              controller: deviceNameController,
              decoration: const InputDecoration(labelText: 'ชื่ออุปกรณ์', hintText: 'เช่น POS-001, เครื่องหน้าร้าน', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            // ตำแหน่ง/สถานที่
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'ตำแหน่ง/สถานที่', hintText: 'เช่น หน้าร้าน, เคาน์เตอร์ 1', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          //TextButton(onPressed: () => Get.back(result: false), child: const Text('ข้ามไปก่อน')),
          ElevatedButton(
            onPressed: () async {
              if (deviceNameController.text.trim().isEmpty) {
                Get.snackbar('ข้อมูลไม่ครบ', 'กรุณากรอกชื่ออุปกรณ์', backgroundColor: Colors.orange, colorText: Colors.white);
                return;
              }

              // ส่งข้อมูลไปลงทะเบียน
              final deviceId = await _getDeviceId();
              await _registerDevice(deviceId, deviceNameController.text.trim(), locationController.text.trim());

              Get.back(result: true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('ลงทะเบียน', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    // ไม่ว่าผลลัพธ์จะเป็นอย่างไร ให้ไปหน้า HomePage
    if (mounted) {
      Get.offAll(HomePage());
    }
  }

  // ✅ ลงทะเบียน device
  Future<void> _registerDevice(String deviceId, String deviceName, String location) async {
    try {
      log('📝 Registering device: $deviceId - $deviceName at $location');

      // เรียกใช้ API สำหรับลงทะเบียน device
      final deviceData = await Homeservice.registerDevice(
        deviceId: deviceId,
        name: deviceName,
        description: location.isNotEmpty ? location : 'POS Device',
      );

      // เก็บข้อมูล device ที่ได้รับจาก API
      await _saveDeviceData(deviceData);

      _showMessage('ลงทะเบียนอุปกรณ์สำเร็จ', isError: false);
      log('✅ Device registration successful: ${deviceData['id']}');
    } catch (e) {
      log('❌ Error registering device: $e');
      _showMessage('ไม่สามารถลงทะเบียนอุปกรณ์ได้: $e', isError: true);
    }
  }

  // ✅ เก็บข้อมูล device ลง SharedPreferences
  Future<void> _saveDeviceData(Map<String, dynamic> deviceData) async {
    try {
      // ใช้ HomeController เพื่อเก็บข้อมูล device
      final homeController = Get.find<HomeController>();
      await homeController.saveDeviceInfo(deviceData);

      log('💾 Device data saved: ${deviceData['deviceId']}');
    } catch (e) {
      log('❌ Error saving device data: $e');
      // ไม่ throw error เพราะการลงทะเบียนสำเร็จแล้ว
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
                            decoration: InputDecoration(labelText: 'ชื่อผู้ใช้'),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
