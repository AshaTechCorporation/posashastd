import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

Future<void> printReceiptFromCartItems(
  List<Map<String, dynamic>> cartItems, {
  double? receivedAmount,
  double? changeAmount,
  double? discountAmount,
  String? paymentMethod,
  String? staffName,
}) async {
  double total = 0;

  // 🏪 Header
  await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  await SunmiPrinter.setFontSize(2);
  await SunmiPrinter.printText('พิชาภพ สินค้าแปรรูป\n');

  await SunmiPrinter.setFontSize(1);
  await SunmiPrinter.printText('ตลาดสี่มุมเมือง (ตลาดสด)\n');
  await SunmiPrinter.printText('355/115-116 หมู่ 15 ถ. พหลโยธิน\n');
  await SunmiPrinter.printText('ต. คูคต อ. ลำลูกกา จ. ปทุมธานี 12130\n');
  await SunmiPrinter.printText('โทร. 099-746-2846\n');
  await SunmiPrinter.lineWrap(1);

  // 👨‍💼 Staff
  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
  final staffDisplayName = staffName ?? 'unknown unknown';
  await SunmiPrinter.printText('พนักงาน: $staffDisplayName\n');
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

  // ✅ แสดงส่วนลด (ถ้ามี)
  if (discountAmount != null && discountAmount > 0) {
    await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
    final discountLeft = 'ส่วนลด';
    final discountRight = '-฿${discountAmount.toStringAsFixed(2)}';
    final discountSpace = 42 - discountLeft.length - discountRight.length;
    await SunmiPrinter.printText('${discountLeft.padRight(discountLeft.length + discountSpace)}$discountRight\n');
  }

  // 💵 Total (หลังหักส่วนลด)
  final finalTotal = total - (discountAmount ?? 0);
  await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  await SunmiPrinter.setFontSize(2);
  await SunmiPrinter.printText('รวมทั้งหมด ฿${finalTotal.toStringAsFixed(2)}\n');
  await SunmiPrinter.setFontSize(1);

  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);

  // ✅ แสดงวิธีการชำระเงิน
  final paymentMethodText = paymentMethod ?? 'เงินสด';
  final paymentLeft = paymentMethodText;
  final paymentRight = '฿${(receivedAmount ?? finalTotal).toStringAsFixed(2)}';
  final paymentSpace = 42 - paymentLeft.length - paymentRight.length;
  await SunmiPrinter.printText('${paymentLeft.padRight(paymentLeft.length + paymentSpace)}$paymentRight\n');

  // ✅ แสดงเงินทอน (ถ้ามี)
  if (changeAmount != null && changeAmount > 0) {
    final changeLeft = 'เงินทอน';
    final changeRight = '฿${changeAmount.toStringAsFixed(2)}';
    final changeSpace = 42 - changeLeft.length - changeRight.length;
    await SunmiPrinter.printText('${changeLeft.padRight(changeLeft.length + changeSpace)}$changeRight\n');
  }

  // 🙏 Thank you
  await SunmiPrinter.lineWrap(1);
  await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  await SunmiPrinter.printText('ขอบคุณที่ใช้บริการ\n');

  // 🕐 Footer
  await SunmiPrinter.lineWrap(1);
  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
  final now = DateTime.now();
  final time = '${now.day}/${now.month}/${now.year + 543} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  final receiptNo = '';
  final footerSpace = 42 - time.length - receiptNo.length;
  await SunmiPrinter.printText('${time.padRight(time.length + footerSpace)}$receiptNo\n');

  // ✂️ End
  await SunmiPrinter.lineWrap(3);
  await SunmiPrinter.cutPaper();
}
