import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterInfo {
  final String name;
  final String address;
  final String type; // 'WiFi', 'LAN', 'USB', 'Bluetooth'
  final bool isConnected;
  final bool isDefault;

  PrinterInfo({
    required this.name,
    required this.address,
    required this.type,
    this.isConnected = false,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'type': type,
    'isConnected': isConnected,
    'isDefault': isDefault,
  };

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

  @override
  void onInit() {
    super.onInit();
    loadSavedPrinters();
  }

  // โหลดปริ๊นเตอร์ที่บันทึกไว้
  Future<void> loadSavedPrinters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final printersJson = prefs.getStringList('saved_printers') ?? [];
      
      savedPrinters.clear();
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
      final printersJson = savedPrinters.map((p) => 
        '${p.name}|${p.address}|${p.type}|${p.isDefault}'
      ).toList();
      
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
      final printersJson = savedPrinters.map((p) => 
        '${p.name}|${p.address}|${p.type}|${p.isDefault}'
      ).toList();
      
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
        PrinterInfo(
          name: 'HP LaserJet Pro',
          address: '192.168.1.100',
          type: 'WiFi',
        ),
        PrinterInfo(
          name: 'Canon PIXMA',
          address: '192.168.1.101',
          type: 'LAN',
        ),
        PrinterInfo(
          name: 'Epson L3150',
          address: '192.168.1.102',
          type: 'WiFi',
        ),
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
        availablePrinters.add(
          PrinterInfo(
            name: 'Sunmi V2 Pro',
            address: '/dev/usb/lp0',
            type: 'USB',
          ),
        );
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
        PrinterInfo(
          name: 'Thermal Printer BT',
          address: '00:11:22:33:44:55',
          type: 'Bluetooth',
        ),
        PrinterInfo(
          name: 'Mobile Printer',
          address: '00:11:22:33:44:66',
          type: 'Bluetooth',
        ),
      ]);
    } catch (e) {
      log('❌ Error scanning Bluetooth printers: $e');
    }
  }

  // ทดสอบการเชื่อมต่อปริ๊นเตอร์
  Future<bool> testPrinterConnection(PrinterInfo printer) async {
    try {
      log('🔄 Testing connection to ${printer.name}...');
      
      // จำลองการทดสอบการเชื่อมต่อ
      await Future.delayed(const Duration(seconds: 2));
      
      // สุ่มผลลัพธ์สำหรับการทดสอบ
      final isConnected = DateTime.now().millisecond % 2 == 0;
      
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
      
      return isConnected;
    } catch (e) {
      log('❌ Error testing printer connection: $e');
      Get.snackbar(
        'ข้อผิดพลาด',
        'เกิดข้อผิดพลาดในการทดสอบการเชื่อมต่อ: $e',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
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
      final printersJson = savedPrinters.map((p) => 
        '${p.name}|${p.address}|${p.type}|${p.isDefault}'
      ).toList();
      
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
}
