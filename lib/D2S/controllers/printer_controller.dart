import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart'; // ✅ เพิ่ม import สำหรับ Colors, Icon, AlertDialog
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterInfo {
  final String name;
  final String address;
  final String type; // 'WiFi', 'LAN', 'USB', 'Bluetooth'
  final bool isConnected;
  final bool isDefault;

  PrinterInfo({required this.name, required this.address, required this.type, this.isConnected = false, this.isDefault = false});

  Map<String, dynamic> toJson() => {'name': name, 'address': address, 'type': type, 'isConnected': isConnected, 'isDefault': isDefault};

  factory PrinterInfo.fromJson(Map<String, dynamic> json) => PrinterInfo(
    name: json['name'] ?? '',
    address: json['address'] ?? '',
    type: json['type'] ?? '',
    isConnected: json['isConnected'] ?? false,
    isDefault: json['isDefault'] ?? false,
  );
}

class PrinterController extends GetxController {
  RxList<PrinterInfo> availablePrinters = <PrinterInfo>[].obs;
  RxList<PrinterInfo> savedPrinters = <PrinterInfo>[].obs;
  RxBool isScanning = false.obs;
  RxString scanStatus = ''.obs;
  Rx<PrinterInfo?> selectedPrinter = Rx<PrinterInfo?>(null);

  // ✅ เพิ่มการเช็คการเชื่อมต่อแบบต่อเนื่อง
  Timer? _connectionCheckTimer;
  RxBool isDefaultPrinterConnected = false.obs;
  RxString connectionStatus = 'ไม่ได้เชื่อมต่อ'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedPrinters();
    // ✅ เริ่มการเช็คการเชื่อมต่อแบบต่อเนื่อง
    startPeriodicConnectionCheck();
  }

  @override
  void onClose() {
    // ✅ หยุด timer เมื่อ controller ถูกทำลาย
    _connectionCheckTimer?.cancel();
    super.onClose();
  }

  // ✅ เพิ่มปริ๊นเตอร์เริ่มต้นสำหรับการทดสอบ
  void _addDefaultPrinters() {
    log('📝 Adding default printers for testing...');

    final defaultPrinters = [
      PrinterInfo(name: 'Thermal Printer WiFi', address: '192.168.1.100', type: 'WiFi', isDefault: true, isConnected: false),
      PrinterInfo(name: 'POS Printer USB', address: 'VID_04B8&PID_0202', type: 'USB', isDefault: false, isConnected: false),
      PrinterInfo(name: 'Mobile Printer BT', address: '00:11:22:33:44:55', type: 'Bluetooth', isDefault: false, isConnected: false),
    ];

    savedPrinters.addAll(defaultPrinters);
    _savePrintersToPrefs(); // บันทึกลง SharedPreferences

    log('✅ Added ${defaultPrinters.length} default printers');
  }

  // ✅ บันทึกปริ๊นเตอร์ทั้งหมดลง SharedPreferences
  Future<void> _savePrintersToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final printersJson = savedPrinters.map((p) => '${p.name}|${p.address}|${p.type}|${p.isDefault}').toList();
      await prefs.setStringList('saved_printers', printersJson);
      log('✅ Saved ${savedPrinters.length} printers to preferences');
    } catch (e) {
      log('❌ Error saving printers to preferences: $e');
    }
  }

  // โหลดปริ๊นเตอร์ที่บันทึกไว้
  Future<void> loadSavedPrinters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final printersJson = prefs.getStringList('saved_printers') ?? [];

      savedPrinters.clear();

      // ✅ ถ้าไม่มีปริ๊นเตอร์ที่บันทึกไว้ ให้เพิ่มปริ๊นเตอร์ตัวอย่าง
      if (printersJson.isEmpty) {
        _addDefaultPrinters();
        return;
      }

      for (String printerStr in printersJson) {
        try {
          final Map<String, dynamic> printerMap = {};
          final parts = printerStr.split('|');
          if (parts.length >= 4) {
            printerMap['name'] = parts[0];
            printerMap['address'] = parts[1];
            printerMap['type'] = parts[2];
            printerMap['isDefault'] = parts[3] == 'true';
            savedPrinters.add(PrinterInfo.fromJson(printerMap));
          }
        } catch (e) {
          log('Error parsing saved printer: $e');
        }
      }

      log('✅ Loaded ${savedPrinters.length} saved printers');
    } catch (e) {
      log('❌ Error loading saved printers: $e');
    }
  }

  // บันทึกปริ๊นเตอร์
  Future<void> savePrinter(PrinterInfo printer) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ลบปริ๊นเตอร์เดิมถ้ามี
      savedPrinters.removeWhere((p) => p.address == printer.address);

      // เพิ่มปริ๊นเตอร์ใหม่
      savedPrinters.add(printer);

      // บันทึกลง SharedPreferences
      final printersJson = savedPrinters.map((p) => '${p.name}|${p.address}|${p.type}|${p.isDefault}').toList();

      await prefs.setStringList('saved_printers', printersJson);

      log('✅ Saved printer: ${printer.name}');
      Get.snackbar(
        'บันทึกสำเร็จ',
        'บันทึกปริ๊นเตอร์ ${printer.name} แล้ว',
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      log('❌ Error saving printer: $e');
      Get.snackbar(
        'ข้อผิดพลาด',
        'ไม่สามารถบันทึกปริ๊นเตอร์ได้: $e',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  // ลบปริ๊นเตอร์ที่บันทึกไว้
  Future<void> removeSavedPrinter(PrinterInfo printer) async {
    try {
      savedPrinters.removeWhere((p) => p.address == printer.address);

      final prefs = await SharedPreferences.getInstance();
      final printersJson = savedPrinters.map((p) => '${p.name}|${p.address}|${p.type}|${p.isDefault}').toList();

      await prefs.setStringList('saved_printers', printersJson);

      log('✅ Removed printer: ${printer.name}');
      Get.snackbar(
        'ลบสำเร็จ',
        'ลบปริ๊นเตอร์ ${printer.name} แล้ว',
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      log('❌ Error removing printer: $e');
    }
  }

  // สแกนหาปริ๊นเตอร์
  Future<void> scanForPrinters() async {
    try {
      isScanning.value = true;
      scanStatus.value = 'กำลังสแกนหาปริ๊นเตอร์...';
      availablePrinters.clear();

      // สแกนปริ๊นเตอร์ในเครือข่าย LAN/WiFi
      await _scanNetworkPrinters();

      // สแกนปริ๊นเตอร์ USB (สำหรับ Android)
      await _scanUSBPrinters();

      // สแกนปริ๊นเตอร์ Bluetooth
      await _scanBluetoothPrinters();

      isScanning.value = false;
      scanStatus.value = 'พบปริ๊นเตอร์ ${availablePrinters.length} เครื่อง';

      log('✅ Scan completed. Found ${availablePrinters.length} printers');
    } catch (e) {
      isScanning.value = false;
      scanStatus.value = 'เกิดข้อผิดพลาดในการสแกน';
      log('❌ Error scanning printers: $e');
    }
  }

  // สแกนปริ๊นเตอร์ในเครือข่าย
  Future<void> _scanNetworkPrinters() async {
    try {
      scanStatus.value = 'กำลังสแกนปริ๊นเตอร์ในเครือข่าย...';

      // จำลองการสแกนปริ๊นเตอร์ในเครือข่าย
      // ในการใช้งานจริงจะต้องใช้ library เช่น network_info_plus และ ping
      await Future.delayed(const Duration(seconds: 2));

      // เพิ่มปริ๊นเตอร์ตัวอย่าง
      availablePrinters.addAll([
        PrinterInfo(name: 'HP LaserJet Pro', address: '192.168.1.100', type: 'WiFi'),
        PrinterInfo(name: 'Canon PIXMA', address: '192.168.1.101', type: 'LAN'),
        PrinterInfo(name: 'Epson L3150', address: '192.168.1.102', type: 'WiFi'),
      ]);
    } catch (e) {
      log('❌ Error scanning network printers: $e');
    }
  }

  // สแกนปริ๊นเตอร์ USB
  Future<void> _scanUSBPrinters() async {
    try {
      scanStatus.value = 'กำลังสแกนปริ๊นเตอร์ USB...';
      await Future.delayed(const Duration(seconds: 1));

      // เพิ่มปริ๊นเตอร์ USB ตัวอย่าง (สำหรับ Android)
      if (Platform.isAndroid) {
        availablePrinters.add(PrinterInfo(name: 'Sunmi V2 Pro', address: '/dev/usb/lp0', type: 'USB'));
      }
    } catch (e) {
      log('❌ Error scanning USB printers: $e');
    }
  }

  // สแกนปริ๊นเตอร์ Bluetooth
  Future<void> _scanBluetoothPrinters() async {
    try {
      scanStatus.value = 'กำลังสแกนปริ๊นเตอร์ Bluetooth...';
      await Future.delayed(const Duration(seconds: 1));

      // เพิ่มปริ๊นเตอร์ Bluetooth ตัวอย่าง
      availablePrinters.addAll([
        PrinterInfo(name: 'Thermal Printer BT', address: '00:11:22:33:44:55', type: 'Bluetooth'),
        PrinterInfo(name: 'Mobile Printer', address: '00:11:22:33:44:66', type: 'Bluetooth'),
      ]);
    } catch (e) {
      log('❌ Error scanning Bluetooth printers: $e');
    }
  }

  // ✅ เริ่มการเช็คการเชื่อมต่อแบบต่อเนื่อง
  void startPeriodicConnectionCheck() {
    // เช็คทุก 30 วินาที
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkDefaultPrinterConnection();
    });

    // เช็คครั้งแรกทันที
    _checkDefaultPrinterConnection();
  }

  // ✅ เช็คการเชื่อมต่อปริ๊นเตอร์เริ่มต้น
  Future<void> _checkDefaultPrinterConnection() async {
    try {
      final defaultPrinter = getDefaultPrinter();
      if (defaultPrinter == null) {
        isDefaultPrinterConnected.value = false;
        connectionStatus.value = 'ไม่มีปริ๊นเตอร์เริ่มต้น';
        return;
      }

      connectionStatus.value = 'กำลังเช็คการเชื่อมต่อ...';
      final isConnected = await testPrinterConnection(defaultPrinter, showSnackbar: false);

      isDefaultPrinterConnected.value = isConnected;
      connectionStatus.value = isConnected ? 'เชื่อมต่อแล้ว: ${defaultPrinter.name}' : 'ไม่สามารถเชื่อมต่อ: ${defaultPrinter.name}';

      log('🖨️ Default printer connection status: $isConnected');
    } catch (e) {
      log('❌ Error checking default printer connection: $e');
      isDefaultPrinterConnected.value = false;
      connectionStatus.value = 'เกิดข้อผิดพลาด';
    }
  }

  // ✅ หาปริ๊นเตอร์เริ่มต้น
  PrinterInfo? getDefaultPrinter() {
    try {
      return savedPrinters.firstWhere((printer) => printer.isDefault);
    } catch (e) {
      return null;
    }
  }

  // ทดสอบการเชื่อมต่อปริ๊นเตอร์
  Future<bool> testPrinterConnection(PrinterInfo printer, {bool showSnackbar = true}) async {
    try {
      log('🔄 Testing connection to ${printer.name}...');

      // ทดสอบการเชื่อมต่อตามประเภทปริ๊นเตอร์
      bool isConnected = false;

      switch (printer.type.toLowerCase()) {
        case 'wifi':
        case 'lan':
          isConnected = await _testNetworkPrinter(printer);
          break;
        case 'bluetooth':
          isConnected = await _testBluetoothPrinter(printer);
          break;
        case 'usb':
          isConnected = await _testUSBPrinter(printer);
          break;
        default:
          // ถ้าไม่ระบุประเภท ให้ทดสอบแบบทั่วไป
          isConnected = await _testGenericPrinter(printer);
      }

      if (showSnackbar) {
        if (isConnected) {
          log('✅ Successfully connected to ${printer.name}');
          Get.snackbar(
            'เชื่อมต่อสำเร็จ',
            'เชื่อมต่อกับ ${printer.name} สำเร็จ',
            backgroundColor: Get.theme.primaryColor,
            colorText: Get.theme.colorScheme.onPrimary,
          );
        } else {
          log('❌ Failed to connect to ${printer.name}');
          Get.snackbar(
            'เชื่อมต่อล้มเหลว',
            'ไม่สามารถเชื่อมต่อกับ ${printer.name} ได้',
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        }
      }

      return isConnected;
    } catch (e) {
      log('❌ Error testing printer connection: $e');
      if (showSnackbar) {
        Get.snackbar(
          'ข้อผิดพลาด',
          'เกิดข้อผิดพลาดในการทดสอบการเชื่อมต่อ: $e',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
      return false;
    }
  }

  // ✅ ฟังก์ชันใหม่: ตรวจสอบและเชื่อมต่อปริ๊นเตอร์ใหม่อัตโนมัติ
  Future<bool> checkAndReconnectPrinter({bool showProgress = true}) async {
    try {
      log('🔄 Starting automatic printer check and reconnection...');

      final defaultPrinter = getDefaultPrinter();
      if (defaultPrinter == null) {
        log('⚠️ No default printer found');
        if (showProgress) {
          Get.snackbar(
            'ไม่พบปริ๊นเตอร์',
            'ไม่มีปริ๊นเตอร์เริ่มต้น กรุณาตั้งค่าปริ๊นเตอร์ก่อน',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            icon: const Icon(Icons.warning, color: Colors.white),
          );
        }
        return false;
      }

      if (showProgress) {
        Get.dialog(
          const AlertDialog(
            content: Row(
              children: [CircularProgressIndicator(), SizedBox(width: 16), Expanded(child: Text('กำลังตรวจสอบและเชื่อมต่อปริ๊นเตอร์...'))],
            ),
          ),
          barrierDismissible: false,
        );
      }

      // ทดสอบการเชื่อมต่อปัจจุบัน
      log('🔍 Testing current connection to ${defaultPrinter.name}...');
      bool isConnected = await testPrinterConnection(defaultPrinter, showSnackbar: false);

      if (!isConnected) {
        log('❌ Current connection failed, attempting reconnection...');

        // พยายามเชื่อมต่อใหม่ 3 ครั้ง
        for (int attempt = 1; attempt <= 3; attempt++) {
          log('🔄 Reconnection attempt $attempt/3...');

          // รอสักครู่ก่อนลองใหม่
          await Future.delayed(Duration(seconds: attempt));

          isConnected = await testPrinterConnection(defaultPrinter, showSnackbar: false);

          if (isConnected) {
            log('✅ Reconnection successful on attempt $attempt');
            break;
          }
        }
      }

      if (showProgress) {
        Get.back(); // ปิด loading dialog
      }

      // อัพเดทสถานะการเชื่อมต่อ
      isDefaultPrinterConnected.value = isConnected;
      connectionStatus.value = isConnected ? 'เชื่อมต่อแล้ว: ${defaultPrinter.name}' : 'ไม่สามารถเชื่อมต่อ: ${defaultPrinter.name}';

      if (showProgress) {
        if (isConnected) {
          Get.snackbar(
            'เชื่อมต่อสำเร็จ',
            'เชื่อมต่อกับปริ๊นเตอร์ ${defaultPrinter.name} สำเร็จ',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
        } else {
          Get.snackbar(
            'เชื่อมต่อล้มเหลว',
            'ไม่สามารถเชื่อมต่อกับปริ๊นเตอร์ ${defaultPrinter.name} ได้',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            icon: const Icon(Icons.error, color: Colors.white),
          );
        }
      }

      return isConnected;
    } catch (e) {
      log('❌ Error in checkAndReconnectPrinter: $e');

      if (showProgress && Get.isDialogOpen == true) {
        Get.back(); // ปิด loading dialog
      }

      if (showProgress) {
        Get.snackbar(
          'เกิดข้อผิดพลาด',
          'เกิดข้อผิดพลาดในการตรวจสอบปริ๊นเตอร์: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }

      return false;
    }
  }

  // ✅ ทดสอบปริ๊นเตอร์เครือข่าย (WiFi/LAN)
  Future<bool> _testNetworkPrinter(PrinterInfo printer) async {
    try {
      log('🔄 Testing network printer: ${printer.name} at ${printer.address}');

      // ในการพัฒนา: จำลองการทดสอบ (สำเร็จ 80% ของเวลา)
      await Future.delayed(const Duration(milliseconds: 500));
      final success = DateTime.now().millisecond % 5 != 0; // 80% success rate

      // TODO: ในการใช้งานจริง ให้ใช้ ping command
      // final result = await Process.run('ping', ['-c', '1', '-W', '3000', printer.address]);
      // return result.exitCode == 0;

      log(success ? '✅ Network printer connected' : '❌ Network printer failed');
      return success;
    } catch (e) {
      log('❌ Network printer test failed: $e');
      return false;
    }
  }

  // ✅ ทดสอบปริ๊นเตอร์ Bluetooth
  Future<bool> _testBluetoothPrinter(PrinterInfo printer) async {
    try {
      log('🔄 Testing Bluetooth printer: ${printer.name} at ${printer.address}');

      // ในการพัฒนา: จำลองการทดสอบ (สำเร็จ 90% ของเวลา)
      await Future.delayed(const Duration(milliseconds: 800));
      final success = DateTime.now().millisecond % 10 != 0; // 90% success rate

      // TODO: ในการใช้งานจริง ให้ใช้ bluetooth library
      // เช่น flutter_bluetooth_serial หรือ blue_thermal

      log(success ? '✅ Bluetooth printer connected' : '❌ Bluetooth printer failed');
      return success;
    } catch (e) {
      log('❌ Bluetooth printer test failed: $e');
      return false;
    }
  }

  // ✅ ทดสอบปริ๊นเตอร์ USB
  Future<bool> _testUSBPrinter(PrinterInfo printer) async {
    try {
      log('🔄 Testing USB printer: ${printer.name} at ${printer.address}');

      // ในการพัฒนา: จำลองการทดสอบ (สำเร็จ 95% ของเวลา)
      await Future.delayed(const Duration(milliseconds: 300));
      final success = DateTime.now().millisecond % 20 != 0; // 95% success rate

      // TODO: ในการใช้งานจริง ให้ใช้ system commands
      // if (Platform.isLinux || Platform.isMacOS) {
      //   final result = await Process.run('lsusb', []);
      //   return result.stdout.toString().contains(printer.address);
      // } else if (Platform.isWindows) {
      //   final result = await Process.run('wmic', ['path', 'win32_usbdevice', 'get', 'deviceid']);
      //   return result.stdout.toString().contains(printer.address);
      // }

      log(success ? '✅ USB printer connected' : '❌ USB printer failed');
      return success;
    } catch (e) {
      log('❌ USB printer test failed: $e');
      return false;
    }
  }

  // ✅ ทดสอบปริ๊นเตอร์แบบทั่วไป
  Future<bool> _testGenericPrinter(PrinterInfo printer) async {
    try {
      log('🔄 Testing generic printer: ${printer.name}');

      // ในการพัฒนา: จำลองการทดสอบ (สำเร็จ 85% ของเวลา)
      await Future.delayed(const Duration(milliseconds: 600));
      final success = DateTime.now().millisecond % 7 != 0; // 85% success rate

      log(success ? '✅ Generic printer connected' : '❌ Generic printer failed');
      return success;
    } catch (e) {
      log('❌ Generic printer test failed: $e');
      return false;
    }
  }

  // ตั้งค่าปริ๊นเตอร์เป็นค่าเริ่มต้น
  Future<void> setDefaultPrinter(PrinterInfo printer) async {
    try {
      // ลบการตั้งค่าเป็นค่าเริ่มต้นของปริ๊นเตอร์อื่น
      for (int i = 0; i < savedPrinters.length; i++) {
        if (savedPrinters[i].address != printer.address) {
          savedPrinters[i] = PrinterInfo(
            name: savedPrinters[i].name,
            address: savedPrinters[i].address,
            type: savedPrinters[i].type,
            isConnected: savedPrinters[i].isConnected,
            isDefault: false,
          );
        }
      }

      // ตั้งค่าปริ๊นเตอร์ที่เลือกเป็นค่าเริ่มต้น
      final index = savedPrinters.indexWhere((p) => p.address == printer.address);
      if (index != -1) {
        savedPrinters[index] = PrinterInfo(
          name: printer.name,
          address: printer.address,
          type: printer.type,
          isConnected: printer.isConnected,
          isDefault: true,
        );
      }

      // บันทึกการเปลี่ยนแปลง
      final prefs = await SharedPreferences.getInstance();
      final printersJson = savedPrinters.map((p) => '${p.name}|${p.address}|${p.type}|${p.isDefault}').toList();

      await prefs.setStringList('saved_printers', printersJson);

      log('✅ Set ${printer.name} as default printer');
      Get.snackbar(
        'ตั้งค่าสำเร็จ',
        'ตั้งค่า ${printer.name} เป็นปริ๊นเตอร์เริ่มต้นแล้ว',
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      log('❌ Error setting default printer: $e');
    }
  }

  // ✅ ส่งภาพไปปริ๊นเตอร์
  Future<bool> printImage(PrinterInfo printer, List<int> imageBytes) async {
    try {
      log('🖨️ Sending image to printer: ${printer.name}');
      log('📸 Image size: ${imageBytes.length} bytes');

      // ตรวจสอบการเชื่อมต่อก่อน
      final isConnected = await testPrinterConnection(printer, showSnackbar: false);
      if (!isConnected) {
        log('❌ Printer not connected, cannot print image');
        return false;
      }

      // ส่งภาพตามประเภทปริ๊นเตอร์
      bool success = false;
      switch (printer.type.toLowerCase()) {
        case 'wifi':
        case 'lan':
          success = await _printImageToNetworkPrinter(printer, imageBytes);
          break;
        case 'bluetooth':
          success = await _printImageToBluetoothPrinter(printer, imageBytes);
          break;
        case 'usb':
          success = await _printImageToUSBPrinter(printer, imageBytes);
          break;
        default:
          success = await _printImageToGenericPrinter(printer, imageBytes);
      }

      if (success) {
        log('✅ Image sent to printer successfully');
      } else {
        log('❌ Failed to send image to printer');
      }

      return success;
    } catch (e) {
      log('❌ Error printing image: $e');
      return false;
    }
  }

  // ✅ ส่งภาพไปปริ๊นเตอร์เครือข่าย
  Future<bool> _printImageToNetworkPrinter(PrinterInfo printer, List<int> imageBytes) async {
    try {
      log('🌐 Sending image to network printer: ${printer.address}');

      // TODO: ในการใช้งานจริง ให้ใช้ HTTP POST หรือ Socket
      // ส่งข้อมูลภาพไปยัง IP address ของปริ๊นเตอร์

      // จำลองการส่งข้อมูล
      await Future.delayed(const Duration(seconds: 2));

      // สำหรับการพัฒนา: สำเร็จ 90% ของเวลา
      final success = DateTime.now().millisecond % 10 != 0;

      log(success ? '✅ Network printer received image' : '❌ Network printer failed to receive image');
      return success;
    } catch (e) {
      log('❌ Network printer image send failed: $e');
      return false;
    }
  }

  // ✅ ส่งภาพไปปริ๊นเตอร์ Bluetooth
  Future<bool> _printImageToBluetoothPrinter(PrinterInfo printer, List<int> imageBytes) async {
    try {
      log('📱 Sending image to Bluetooth printer: ${printer.address}');

      // TODO: ในการใช้งานจริง ให้ใช้ Bluetooth library
      // เช่น flutter_bluetooth_serial หรือ blue_thermal

      // จำลองการส่งข้อมูล
      await Future.delayed(const Duration(seconds: 3));

      // สำหรับการพัฒนา: สำเร็จ 85% ของเวลา
      final success = DateTime.now().millisecond % 7 != 0;

      log(success ? '✅ Bluetooth printer received image' : '❌ Bluetooth printer failed to receive image');
      return success;
    } catch (e) {
      log('❌ Bluetooth printer image send failed: $e');
      return false;
    }
  }

  // ✅ ส่งภาพไปปริ๊นเตอร์ USB
  Future<bool> _printImageToUSBPrinter(PrinterInfo printer, List<int> imageBytes) async {
    try {
      log('🔌 Sending image to USB printer: ${printer.name}');

      // TODO: ในการใช้งานจริง ให้ใช้ USB library
      // เช่น usb_serial หรือ platform channels

      // จำลองการส่งข้อมูล
      await Future.delayed(const Duration(seconds: 1));

      // สำหรับการพัฒนา: สำเร็จ 95% ของเวลา
      final success = DateTime.now().millisecond % 20 != 0;

      log(success ? '✅ USB printer received image' : '❌ USB printer failed to receive image');
      return success;
    } catch (e) {
      log('❌ USB printer image send failed: $e');
      return false;
    }
  }

  // ✅ ส่งภาพไปปริ๊นเตอร์แบบทั่วไป
  Future<bool> _printImageToGenericPrinter(PrinterInfo printer, List<int> imageBytes) async {
    try {
      log('🖨️ Sending image to generic printer: ${printer.name}');

      // จำลองการส่งข้อมูล
      await Future.delayed(const Duration(seconds: 2));

      // สำหรับการพัฒนา: สำเร็จ 80% ของเวลา
      final success = DateTime.now().millisecond % 5 != 0;

      log(success ? '✅ Generic printer received image' : '❌ Generic printer failed to receive image');
      return success;
    } catch (e) {
      log('❌ Generic printer image send failed: $e');
      return false;
    }
  }
}
