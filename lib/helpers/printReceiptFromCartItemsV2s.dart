import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

Future<void> printReceiptFromCartItemsV2s(
  List<Map<String, dynamic>> cartItems, {
  double? receivedAmount,
  double? changeAmount,
  double? discountAmount,
  String? paymentMethod,
  String? staffName,
  String? receiptNumber,
}) async {
  double total = 0;

  // 🏪 Header - สำหรับ V2S
  await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

  const storeName = 'พิชาภพ สินค้าแปรรูป';
  await SunmiPrinter.printText('$storeName\n', style: SunmiTextStyle(fontSize: 24));

  const marketText = 'ตลาดสี่มุมเมือง (ตลาดสด)';
  await SunmiPrinter.printText('$marketText\n', style: SunmiTextStyle(fontSize: 24));

  const addressText1 = '355/115-116 หมู่ 15 ถ. พหลโยธิน';
  await SunmiPrinter.printText('$addressText1\n', style: SunmiTextStyle(fontSize: 24));

  const addressText2 = 'ต. คูคต อ. ลำลูกกา จ. ปทุมธานี 12130';
  await SunmiPrinter.printText('$addressText2\n', style: SunmiTextStyle(fontSize: 24));

  const phoneText = 'โทร. 099-746-2846';
  await SunmiPrinter.printText('$phoneText\n', style: SunmiTextStyle(fontSize: 24));

  await SunmiPrinter.lineWrap(2);

  // 👨‍💼 Staff
  await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  final staffDisplayName = staffName ?? 'unknown unknown';
  final staffText = 'พนักงาน: $staffDisplayName';
  await SunmiPrinter.printText('$staffText\n', style: SunmiTextStyle(fontSize: 24));

  const posText = 'ระบบขายหน้าร้าน: POS';
  await SunmiPrinter.printText('$posText\n', style: SunmiTextStyle(fontSize: 24));

  // ✅ แสดงเลขที่ใบเสร็จ (ถ้ามี)
  if (receiptNumber != null && receiptNumber.isNotEmpty) {
    final receiptText = 'เลขที่ใบเสร็จ: $receiptNumber';
    await SunmiPrinter.printText('$receiptText\n', style: SunmiTextStyle(fontSize: 24));
  }

  await SunmiPrinter.printText('-' * 30 + '\n', style: SunmiTextStyle(fontSize: 24));

  // 🧾 Items - ปรับขนาดให้เหมาะกับ V2S
  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
  for (final item in cartItems) {
    final name = (item['name'] ?? '').toString();
    final qty = item['qty'] ?? 1;
    final price = (item['price'] ?? 0).toDouble();
    final lineTotal = qty * price;
    total += lineTotal;

    // พิมพ์ชื่อสินค้า
    await SunmiPrinter.printText('$name\n', style: SunmiTextStyle(fontSize: 24));

    // พิมพ์รายละเอียด x ราคาชิ้น และรวม ยึดความกว้างบรรทัด 30 ตัวอักษร
    final left = '$qty x ฿${price.toStringAsFixed(2)}';
    final right = '฿${lineTotal.toStringAsFixed(2)}';
    final space = 30 - left.length - right.length;
    if (space > 0) {
      await SunmiPrinter.printText('${left.padRight(left.length + space)}$right\n', style: SunmiTextStyle(fontSize: 24));
    } else {
      await SunmiPrinter.printText('$left\n', style: SunmiTextStyle(fontSize: 24));
      await SunmiPrinter.printText('${' ' * (30 - right.length)}$right\n', style: SunmiTextStyle(fontSize: 24));
    }
  }

  await SunmiPrinter.printText('-' * 30 + '\n', style: SunmiTextStyle(fontSize: 24));

  // ✅ แสดงส่วนลด (ถ้ามี)
  if (discountAmount != null && discountAmount > 0) {
    await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
    final discountLeft = 'ส่วนลด';
    final discountRight = '-฿${discountAmount.toStringAsFixed(2)}';
    final discountSpace = 30 - discountLeft.length - discountRight.length;
    if (discountSpace > 0) {
      await SunmiPrinter.printText(
        '${discountLeft.padRight(discountLeft.length + discountSpace)}$discountRight\n',
        style: SunmiTextStyle(fontSize: 24),
      );
    } else {
      await SunmiPrinter.printText('$discountLeft\n', style: SunmiTextStyle(fontSize: 24));
      await SunmiPrinter.printText('${' ' * (30 - discountRight.length)}$discountRight\n', style: SunmiTextStyle(fontSize: 24));
    }
  }

  // 💵 Total (หลังหักส่วนลด)
  final finalTotal = total - (discountAmount ?? 0);
  await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  await SunmiPrinter.printText('รวมทั้งหมด ฿${finalTotal.toStringAsFixed(2)}\n', style: SunmiTextStyle(fontSize: 24));

  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);

  // ✅ แสดงวิธีการชำระเงิน
  final paymentMethodText = paymentMethod ?? 'เงินสด';
  final paymentLeft = paymentMethodText;
  final paymentRight = '฿${(receivedAmount ?? finalTotal).toStringAsFixed(2)}';
  final paymentSpace = 30 - paymentLeft.length - paymentRight.length;
  if (paymentSpace > 0) {
    await SunmiPrinter.printText('${paymentLeft.padRight(paymentLeft.length + paymentSpace)}$paymentRight\n', style: SunmiTextStyle(fontSize: 24));
  } else {
    await SunmiPrinter.printText('$paymentLeft\n', style: SunmiTextStyle(fontSize: 24));
    await SunmiPrinter.printText('${' ' * (30 - paymentRight.length)}$paymentRight\n', style: SunmiTextStyle(fontSize: 24));
  }

  // ✅ แสดงเงินทอน (ถ้ามี)
  if (changeAmount != null && changeAmount > 0) {
    final changeLeft = 'เงินทอน';
    final changeRight = '฿${changeAmount.toStringAsFixed(2)}';
    final changeSpace = 30 - changeLeft.length - changeRight.length;
    if (changeSpace > 0) {
      await SunmiPrinter.printText('${changeLeft.padRight(changeLeft.length + changeSpace)}$changeRight\n', style: SunmiTextStyle(fontSize: 24));
    } else {
      await SunmiPrinter.printText('$changeLeft\n', style: SunmiTextStyle(fontSize: 24));
      await SunmiPrinter.printText('${' ' * (30 - changeRight.length)}$changeRight\n', style: SunmiTextStyle(fontSize: 24));
    }
  }

  // 🙏 Thank you
  await SunmiPrinter.lineWrap(1);
  await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  await SunmiPrinter.printText('ขอบคุณที่ใช้บริการ\n', style: SunmiTextStyle(fontSize: 24));

  // 🕐 Footer
  await SunmiPrinter.lineWrap(1);
  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
  final now = DateTime.now();
  final time = '${now.day}/${now.month}/${now.year + 543} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  final receiptNo = '';
  final footerSpace = 30 - time.length - receiptNo.length;
  if (footerSpace > 0) {
    await SunmiPrinter.printText('${time.padRight(time.length + footerSpace)}$receiptNo\n', style: SunmiTextStyle(fontSize: 24));
  } else {
    await SunmiPrinter.printText('$time\n', style: SunmiTextStyle(fontSize: 24));
  }

  // ✂️ End
  await SunmiPrinter.lineWrap(3);
  await SunmiPrinter.cutPaper();
}
