// import 'package:sunmi_printer_plus/core/enums/enums.dart';
// import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

Future<void> printReceipt() async {
  await SunmiPrinter.bindingPrinter();

  // 🏪 หัวใบเสร็จ
  await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  await SunmiPrinter.setFontSize(2);
  await SunmiPrinter.printText('พิซากพ\n');
  await SunmiPrinter.setFontSize(1);
  await SunmiPrinter.printText('เปิด 24 ชั่วโมง\n');
  await SunmiPrinter.lineWrap(1);

  // 👨‍💼 ข้อมูลพนักงาน
  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
  await SunmiPrinter.printText('พนักงาน: unknown unknown\n');
  await SunmiPrinter.printText('ระบบขายหน้าร้าน: POS 4\n');
  await SunmiPrinter.printText('--------------------------------\n');

  // 🧾 รายการสินค้า
  await SunmiPrinter.printText('กุ้งโยเด้ง\n');
  await SunmiPrinter.printText('1 x ฿98.00                         ฿98.00\n');

  await SunmiPrinter.printText('ปลาทอดขาว5ดาว\n');
  await SunmiPrinter.printText('1 x ฿45.00                         ฿45.00\n');

  await SunmiPrinter.printText('ปลามหาชัย\n');
  await SunmiPrinter.printText('1 x ฿34.00                         ฿34.00\n');

  await SunmiPrinter.printText('--------------------------------\n');

  // 💵 รวมทั้งหมด
  await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  await SunmiPrinter.setFontSize(2);
  await SunmiPrinter.printText('รวมทั้งหมด ฿177.00\n');
  await SunmiPrinter.setFontSize(1);

  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
  await SunmiPrinter.printText('เงินสด                                ฿177.00\n');

  // 🙏 ขอบคุณ
  await SunmiPrinter.lineWrap(1);
  await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  await SunmiPrinter.printText('Thank you\n');

  // 🕐 วันที่/เลข
  await SunmiPrinter.lineWrap(1);
  await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
  await SunmiPrinter.printText('24/6/25 6:23 หลังเที่ยง           #4-1013\n');

  // ✂️ จบการพิมพ์
  await SunmiPrinter.lineWrap(3);
  await SunmiPrinter.cutPaper();
}
