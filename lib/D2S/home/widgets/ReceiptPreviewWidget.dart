import 'package:flutter/material.dart';

class ReceiptPreviewWidget extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double receivedAmount;
  final double changeAmount;
  final double? discountAmount;
  final String paymentMethod;
  final String staffName;
  final String? receiptNumber;

  const ReceiptPreviewWidget({
    super.key,
    required this.cartItems,
    required this.receivedAmount,
    required this.changeAmount,
    this.discountAmount,
    required this.paymentMethod,
    required this.staffName,
    this.receiptNumber,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final time = '${now.day}/${now.month}/${now.year + 543} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    // คำนวณยอดรวมจากรายการสินค้า (เหมือน Sunmi)
    double total = 0;
    for (final item in cartItems) {
      final qty = item['qty'] ?? 1;
      final price = (item['price'] ?? 0).toDouble();
      total += qty * price;
    }

    // ยอดสุดท้ายหลังหักส่วนลด
    final finalTotal = total - (discountAmount ?? 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 10), // padding เล็กน้อยด้านซ้าย-ขวา
      decoration: const BoxDecoration(color: Colors.white), // เอาขอบและมุมโค้งออก
      width: double.infinity, // ให้เต็มความกว้าง
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Header (ชิดซ้าย)
          const Text('พิชาภพ สินค้าแปรรูป', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('ตลาดสี่มุมเมือง (ตลาดสด)', style: TextStyle(fontSize: 16)),
          const Text('355/115-116 หมู่ 15 ถ. พหลโยธิน', style: TextStyle(fontSize: 16)),
          const Text('ต. คูคต อ. ลำลูกกา จ. ปทุมธานี 12130', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 6),
          const Text('โทร. 099-746-2846', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),

          // Staff & POS (ชิดซ้าย)
          Text('พนักงาน: $staffName', style: const TextStyle(fontSize: 16)),
          const Text('ระบบขายหน้าร้าน: POS', style: TextStyle(fontSize: 16)),

          // เลขที่ใบเสร็จ (ถ้ามี)
          if (receiptNumber != null && receiptNumber!.isNotEmpty) ...[Text('เลขที่ใบเสร็จ: $receiptNumber', style: const TextStyle(fontSize: 16))],

          const SizedBox(height: 12),
          Container(width: double.infinity, height: 1, color: Colors.grey[400]),
          const SizedBox(height: 12),

          // Items (แบบ Sunmi)
          ...cartItems.map((item) {
            final name = item['name'] ?? 'ไม่ระบุชื่อ';
            final qty = item['qty'] ?? 1;
            final price = (item['price'] ?? 0).toDouble();
            final lineTotal = qty * price;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ชื่อสินค้า
                SizedBox(width: double.infinity, child: Text(name, style: const TextStyle(fontSize: 16))),
                // จำนวน x ราคา = รวม
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$qty x ฿${price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                    Text('฿${lineTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            );
          }),

          Container(width: double.infinity, height: 1, color: Colors.grey[400]),
          const SizedBox(height: 12),

          // ส่วนลด (ถ้ามี)
          if (discountAmount != null && discountAmount! > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ส่วนลด', style: TextStyle(fontSize: 16)),
                Text('-฿${discountAmount!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // รวมทั้งหมด (ชิดซ้าย)
          Text('รวมทั้งหมด ฿${finalTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // วิธีชำระ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(paymentMethod, style: const TextStyle(fontSize: 16)),
              Text('฿${receivedAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            ],
          ),

          // เงินทอน (ถ้ามี)
          if (changeAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('เงินทอน', style: TextStyle(fontSize: 16)),
                Text('฿${changeAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Thank you (ชิดซ้าย)
          const Text('ขอบคุณที่ใช้บริการ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          const SizedBox(height: 12),

          // Footer - วันที่เวลา (แบบ Sunmi)
          Text(time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
