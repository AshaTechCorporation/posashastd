import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

Future<void> printReceiptFromCartItems(List<Map<String, dynamic>> cartItems) async {
  double total = 0;

  // 🏪 Header
  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT); // ปิดการจัดกลางอัตโนมัติ
  await SunmiPrinter.setFontSize(2);
  const storeName = 'พิซากพ';
  final storeCentered = storeName.padLeft(((42 + storeName.length) ~/ 2)).padRight(42);
  await SunmiPrinter.printText('$storeCentered\n');

  await SunmiPrinter.setFontSize(1);
  const openText = 'เปิด 24 ชั่วโมง';
  final openCentered = openText.padLeft(((42 + openText.length) ~/ 2)).padRight(42);
  await SunmiPrinter.printText('$openCentered\n');
  await SunmiPrinter.lineWrap(1);

  // 👨‍💼 Staff
  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
  await SunmiPrinter.printText('พนักงาน: unknown unknown\n');
  await SunmiPrinter.printText('ระบบขายหน้าร้าน: POS 4\n');
  await SunmiPrinter.printText('-' * 42 + '\n');

  // 🧾 Items
  for (final item in cartItems) {
    final name = (item['name'] ?? '').toString();
    final qty = item['qty'] ?? 1;
    final price = (item['price'] ?? 0).toDouble();
    final lineTotal = qty * price;
    total += lineTotal;

    // พิมพ์ชื่อสินค้า
    await SunmiPrinter.printText('$name\n');

    // พิมพ์รายละเอียด x ราคาชิ้น และรวม ยึดความกว้างบรรทัด 42 ตัวอักษร
    final left = '$qty x ฿${price.toStringAsFixed(2)}';
    final right = '฿${lineTotal.toStringAsFixed(2)}';
    final space = 42 - left.length - right.length;
    await SunmiPrinter.printText('${left.padRight(left.length + space)}$right\n');
  }

  await SunmiPrinter.printText('-' * 42 + '\n');

  // 💵 Total
  await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  await SunmiPrinter.setFontSize(2);
  await SunmiPrinter.printText('รวมทั้งหมด ฿${total.toStringAsFixed(2)}\n');
  await SunmiPrinter.setFontSize(1);

  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
  final cashLeft = 'เงินสด';
  final cashRight = '฿${total.toStringAsFixed(2)}';
  final space = 42 - cashLeft.length - cashRight.length;
  await SunmiPrinter.printText('${cashLeft.padRight(cashLeft.length + space)}$cashRight\n');

  // 🙏 Thank you
  await SunmiPrinter.lineWrap(1);
  await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  await SunmiPrinter.printText('ขอบคุณที่ใช้บริการ\n');

  // 🕐 Footer
  await SunmiPrinter.lineWrap(1);
  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
  final now = DateTime.now();
  final time = '${now.day}/${now.month}/${now.year + 543} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  final receiptNo = '#4-1013';
  final footerSpace = 42 - time.length - receiptNo.length;
  await SunmiPrinter.printText('${time.padRight(time.length + footerSpace)}$receiptNo\n');

  // ✂️ End
  await SunmiPrinter.lineWrap(3);
  await SunmiPrinter.cutPaper();
}
