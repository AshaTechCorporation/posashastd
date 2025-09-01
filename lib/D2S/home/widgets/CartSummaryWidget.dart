import 'package:flutter/material.dart';

class CartSummaryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double? selectedDiscountAmount;
  final double discountAmount;

  const CartSummaryWidget({super.key, required this.cartItems, this.selectedDiscountAmount, required this.discountAmount});

  // คำนวณยอดรวมเดิม (ก่อนหักส่วนลด)
  double get originalTotal {
    return cartItems.fold(0.0, (sum, item) {
      final price = item['price'] ?? 0;
      final qty = item['qty'] ?? 1;
      return sum + (price * qty);
    });
  }

  // คำนวณยอดรวมหลังหักส่วนลด
  double get totalWithDiscount {
    return originalTotal - discountAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.grey))),
      child: Column(
        children: [
          // ✅ รายการสินค้าในตะกร้า
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final name = item['name'] ?? '';
                final qty = item['qty'] ?? 1;
                final price = item['price'] ?? 0;
                final totalItem = qty * price;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$name x $qty (฿${price.toStringAsFixed(2)})',
                          style: const TextStyle(fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('฿${totalItem.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // ✅ แสดงยอดรวมก่อนส่วนลด
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ยอดรวม', style: TextStyle(fontSize: 18)),
                Text('฿${originalTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),

          // ✅ แสดงส่วนลด (ถ้ามี)
          if (selectedDiscountAmount != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ส่วนลด', style: TextStyle(fontSize: 18, color: Colors.red)),
                  Text('-฿${discountAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Colors.red)),
                ],
              ),
            ),
          ],

          // ✅ แสดงยอดรวมหลังหักส่วนลด
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('รวมทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                Text(
                  '฿${totalWithDiscount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
