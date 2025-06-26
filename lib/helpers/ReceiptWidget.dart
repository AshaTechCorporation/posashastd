import 'package:flutter/material.dart';

class ReceiptWidget extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double total;

  const ReceiptWidget({super.key, required this.cartItems, required this.total});

  String formatPrice(num price) {
    return "฿${price.toStringAsFixed(2)}";
  }

  String padRight(String text, int width) {
    return text.length >= width ? text : text.padRight(width, ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 384, // ความกว้างพอดีกับกระดาษ 80mm
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Courier', // ฟอนต์ monospaced
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text('พิเชาภาพ', style: TextStyle(fontWeight: FontWeight.bold))),
            const Center(child: Text('เปิด24ชั่วโมง')),
            const SizedBox(height: 8),
            const Text('พนักงาน: unknown unknown'),
            const Text('ระบบขายหน้าร้าน: POS 1'),
            const Divider(thickness: 1),

            // 🔽 รายการสินค้า
            ...cartItems.map((item) {
              final name = item['name'] ?? '';
              final qty = item['qty'] ?? 1;
              final price = (item['price'] ?? 0).toDouble();
              final totalLine = qty * price;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อสินค้า
                  Text(name),
                  // ปริมาณ และราคารวม
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('$qty x ${formatPrice(price)}'), Text(formatPrice(totalLine))],
                  ),
                  const SizedBox(height: 4),
                ],
              );
            }),

            const Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('รวมทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold)),
                // ราคาแสดงถัดไป
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text(formatPrice(total), style: const TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('เงินสด'), Text('฿')]),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text(formatPrice(total))]),
            const Divider(),
            const Center(child: Text('Thank you')),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year % 100} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} น.',
                ),
                const Text('#1-1022'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
