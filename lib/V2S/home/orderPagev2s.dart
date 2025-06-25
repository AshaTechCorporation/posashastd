import 'package:flutter/material.dart';
import 'package:posashastd/V2S/home/paymentPagev2s.dart';

class OrderPagev2s extends StatefulWidget {
  OrderPagev2s({super.key, required this.items});
  final List<Map<String, dynamic>> items;

  @override
  State<OrderPagev2s> createState() => _OrderPagev2sState();
}

class _OrderPagev2sState extends State<OrderPagev2s> {
  @override
  Widget build(BuildContext context) {
    double total = widget.items.fold(0, (sum, item) => sum + (item['price'] * (item['qty'] ?? 1)));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            const Text('ตัวออเดอร์', style: TextStyle(color: Colors.white)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: Text(widget.items.length.toString(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          ...widget.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item['name']} x ${item['qty'] ?? 1}', style: const TextStyle(fontSize: 16)),
                  Text('฿${(item['price'] * (item['qty'] ?? 1)).toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          const Divider(height: 32, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('รวมทั้งหมด', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('฿${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),

      bottomNavigationBar: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPagev2s(items: widget.items, totalAmount: total)));
        },
        child: Container(
          height: 60,
          color: Colors.green,
          alignment: Alignment.center,
          child: Text(
            'ชำระเงิน\n฿${total.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
