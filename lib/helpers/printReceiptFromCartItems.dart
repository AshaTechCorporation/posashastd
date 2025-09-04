import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';

Future<void> printReceiptFromCartItems(
  List<Map<String, dynamic>> cartItems, {
  double? receivedAmount,
  double? changeAmount,
  double? discountAmount,
  String? paymentMethod,
  String? staffName,
  String? receiptNumber, // ✅ เพิ่ม parameter สำหรับเลขที่ใบเสร็จ
}) async {
  print('🖨️ printReceiptFromCartItems called with ${cartItems.length} items');
  for (int i = 0; i < cartItems.length; i++) {
    final item = cartItems[i];
    print('🖨️ Received item $i: $item');
  }

  double total = 0;

  // 🏪 Header
  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
  const storeName = 'พิชาภพ สินค้าแปรรูป';
  final storeNameCentered = storeName.padLeft(((42 + storeName.length) ~/ 2)).padRight(42);
  await SunmiPrinter.printText('$storeNameCentered\n', style: SunmiTextStyle(fontSize: 25));

  const marketText = 'ตลาดสี่มุมเมือง (ตลาดสด)';
  final marketCentered = marketText.padLeft(((42 + marketText.length) ~/ 2)).padRight(42);
  await SunmiPrinter.printText('$marketCentered\n', style: SunmiTextStyle(fontSize: 25));

  const addressText1 = '355/115-116 หมู่ 15 ถ. พหลโยธิน';
  final address1Centered = addressText1.padLeft(((42 + addressText1.length) ~/ 2)).padRight(42);
  await SunmiPrinter.printText('$address1Centered\n', style: SunmiTextStyle(fontSize: 25));

  const addressText2 = 'ต. คูคต อ. ลำลูกกา จ. ปทุมธานี 12130';
  final address2Centered = addressText2.padLeft(((42 + addressText2.length) ~/ 2)).padRight(42);
  await SunmiPrinter.printText('$address2Centered\n', style: SunmiTextStyle(fontSize: 25));

  await SunmiPrinter.printText('\n', style: SunmiTextStyle(fontSize: 25)); // เว้นบรรทัดระหว่างที่อยู่และเบอร์โทร

  const phoneText = 'โทร. 099-746-2846';
  final phoneCentered = phoneText.padLeft(((42 + phoneText.length) ~/ 2)).padRight(42);
  await SunmiPrinter.printText('$phoneCentered\n', style: SunmiTextStyle(fontSize: 25));

  await SunmiPrinter.lineWrap(3);

  // 👨‍💼 Staff
  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
  final staffDisplayName = staffName ?? 'unknown unknown';
  final staffText = 'พนักงาน: $staffDisplayName';
  final staffCentered = staffText.padLeft(((42 + staffText.length) ~/ 2)).padRight(42);
  await SunmiPrinter.printText('$staffCentered\n', style: SunmiTextStyle(fontSize: 25));

  const posText = 'ระบบขายหน้าร้าน: POS';
  final posCentered = posText.padLeft(((42 + posText.length) ~/ 2)).padRight(42);
  await SunmiPrinter.printText('$posCentered\n', style: SunmiTextStyle(fontSize: 25));

  // ✅ แสดงเลขที่ใบเสร็จ (ถ้ามี)
  if (receiptNumber != null && receiptNumber.isNotEmpty) {
    final receiptText = 'เลขที่ใบเสร็จ: $receiptNumber';
    final receiptCentered = receiptText.padLeft(((42 + receiptText.length) ~/ 2)).padRight(42);
    await SunmiPrinter.printText('$receiptCentered\n', style: SunmiTextStyle(fontSize: 25));
  }

  await SunmiPrinter.printText('-' * 42 + '\n', style: SunmiTextStyle(fontSize: 25));

  // 🧾 Items
  for (final item in cartItems) {
    final name = (item['name'] ?? '').toString();
    final qty = item['qty'] ?? 1;
    final price = (item['price'] ?? 0).toDouble();
    final lineTotal = qty * price;
    total += lineTotal;

    // พิมพ์ชื่อสินค้า
    await SunmiPrinter.printText('$name\n', style: SunmiTextStyle(fontSize: 25));

    // พิมพ์รายละเอียด x ราคาชิ้น และรวม ยึดความกว้างบรรทัด 42 ตัวอักษร
    final left = '$qty x ฿${price.toStringAsFixed(2)}';
    final right = '฿${lineTotal.toStringAsFixed(2)}';
    final space = 42 - left.length - right.length;
    await SunmiPrinter.printText('${left.padRight(left.length + space)}$right\n', style: SunmiTextStyle(fontSize: 25));
  }

  await SunmiPrinter.printText('-' * 42 + '\n', style: SunmiTextStyle(fontSize: 25));

  // ✅ แสดงส่วนลด (ถ้ามี)
  if (discountAmount != null && discountAmount > 0) {
    await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
    final discountLeft = 'ส่วนลด';
    final discountRight = '-฿${discountAmount.toStringAsFixed(2)}';
    final discountSpace = 42 - discountLeft.length - discountRight.length;
    await SunmiPrinter.printText(
      '${discountLeft.padRight(discountLeft.length + discountSpace)}$discountRight\n',
      style: SunmiTextStyle(fontSize: 25),
    );
  }

  // 💵 Total (หลังหักส่วนลด)
  final finalTotal = total - (discountAmount ?? 0);
  await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  await SunmiPrinter.printText('รวมทั้งหมด ฿${finalTotal.toStringAsFixed(2)}\n', style: SunmiTextStyle(fontSize: 25));

  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);

  // ✅ แสดงวิธีการชำระเงิน
  final paymentMethodText = paymentMethod ?? 'เงินสด';
  final paymentLeft = paymentMethodText;
  final paymentRight = '฿${(receivedAmount ?? finalTotal).toStringAsFixed(2)}';
  final paymentSpace = 42 - paymentLeft.length - paymentRight.length;
  await SunmiPrinter.printText('${paymentLeft.padRight(paymentLeft.length + paymentSpace)}$paymentRight\n', style: SunmiTextStyle(fontSize: 25));

  // ✅ แสดงเงินทอน (ถ้ามี)
  if (changeAmount != null && changeAmount > 0) {
    final changeLeft = 'เงินทอน';
    final changeRight = '฿${changeAmount.toStringAsFixed(2)}';
    final changeSpace = 42 - changeLeft.length - changeRight.length;
    await SunmiPrinter.printText('${changeLeft.padRight(changeLeft.length + changeSpace)}$changeRight\n', style: SunmiTextStyle(fontSize: 25));
  }

  // 🙏 Thank you
  await SunmiPrinter.lineWrap(1);
  await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  await SunmiPrinter.printText('ขอบคุณที่ใช้บริการ\n', style: SunmiTextStyle(fontSize: 25));

  // 🕐 Footer
  await SunmiPrinter.lineWrap(1);
  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
  final now = DateTime.now();
  final time = '${now.day}/${now.month}/${now.year + 543} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  final receiptNo = '';
  final footerSpace = 42 - time.length - receiptNo.length;
  await SunmiPrinter.printText('${time.padRight(time.length + footerSpace)}$receiptNo\n', style: SunmiTextStyle(fontSize: 25));

  // ✂️ End
  await SunmiPrinter.lineWrap(3);
  await SunmiPrinter.cutPaper();
}
