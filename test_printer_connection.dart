// test_printer_connection.dart
// ทดสอบระบบเช็คการเชื่อมต่อปริ๊นเตอร์

import 'dart:developer';
import 'lib/D2S/controllers/printer_controller.dart';

void main() async {
  print('🧪 Testing Printer Connection System...\n');

  // สร้าง PrinterController
  final printerController = PrinterController();

  // เริ่มต้น controller
  await printerController.onInit();

  // รอให้โหลดปริ๊นเตอร์เสร็จ
  await Future.delayed(const Duration(seconds: 2));

  print('📋 Saved Printers:');
  for (int i = 0; i < printerController.savedPrinters.length; i++) {
    final printer = printerController.savedPrinters[i];
    print('  [$i] ${printer.name}');
    print('      Type: ${printer.type}');
    print('      Address: ${printer.address}');
    print('      Default: ${printer.isDefault}');
    print('      Connected: ${printer.isConnected}');
    print('');
  }

  // ทดสอบหาปริ๊นเตอร์เริ่มต้น
  final defaultPrinter = printerController.getDefaultPrinter();
  if (defaultPrinter != null) {
    print('🖨️ Default Printer: ${defaultPrinter.name}');
    print('   Type: ${defaultPrinter.type}');
    print('   Address: ${defaultPrinter.address}');
    print('');

    // ทดสอบการเชื่อมต่อ
    print('🔄 Testing connection...');
    final isConnected = await printerController.testPrinterConnection(defaultPrinter, showSnackbar: false);
    print('Result: ${isConnected ? '✅ Connected' : '❌ Failed'}');
    print('');

    // ทดสอบการเช็คแบบต่อเนื่อง
    print('🔄 Testing periodic check...');
    // รอให้ periodic check ทำงาน
    await Future.delayed(const Duration(seconds: 2));

    print('Connection Status: ${printerController.connectionStatus.value}');
    print('Is Connected: ${printerController.isDefaultPrinterConnected.value}');
  } else {
    print('❌ No default printer found');
  }

  // ทดสอบการเชื่อมต่อหลายครั้ง
  print('\n🔄 Testing multiple connections...');
  for (int i = 1; i <= 5; i++) {
    if (defaultPrinter != null) {
      final result = await printerController.testPrinterConnection(defaultPrinter, showSnackbar: false);
      print('Test $i: ${result ? '✅' : '❌'}');
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ปิด controller
  printerController.onClose();

  print('\n🎉 Test completed!');
}
