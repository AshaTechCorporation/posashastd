import 'package:flutter/material.dart';

class OrderPagev2s extends StatelessWidget {
  const OrderPagev2s({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 AppBar
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            const Text('ตัวออเดอร์', style: TextStyle(color: Colors.white)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: const Text('0', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.person_add_alt_1, color: Colors.white),
          SizedBox(width: 12),
          Icon(Icons.more_vert, color: Colors.white),
          SizedBox(width: 8),
        ],
      ),

      // 🔸 พื้นหลังว่างเปล่า
      body: const SizedBox.expand(),

      // 🔸 ปุ่มชำระเงินด้านล่าง
      bottomNavigationBar: Container(
        color: Colors.green.shade400,
        height: 50,
        alignment: Alignment.center,
        child: const Text('ชำระเงิน\n฿80.00', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ),
    );
  }
}
