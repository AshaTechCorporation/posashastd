import 'package:flutter/material.dart';
import 'package:posashastd/V2S/home/saleSummaryPagev2s.dart';

class PaymentPagev2s extends StatelessWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> items;

  PaymentPagev2s({super.key, required this.totalAmount, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const SizedBox(),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16.0), child: Center(child: Text('แยก', style: TextStyle(color: Colors.white, fontSize: 16)))),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '฿${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text('จำนวนเงินที่ต้องชำระ', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            const Text('เงินสดรับ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('฿${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
            const Divider(height: 32),
            _buildPaymentButton(context, Icons.money, 'เงินสด'),
            const SizedBox(height: 12),
            _buildPaymentButton(context, Icons.credit_card, 'ชำระด้วยบัตร'),
            const SizedBox(height: 12),
            _buildPaymentButton(context, Icons.receipt_long, 'โอนชำระ'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(BuildContext context, IconData icon, String label) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.grey[800]),
      label: Text(label, style: TextStyle(color: Colors.grey[800])),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.centerLeft,
        elevation: 0,
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SaleSummaryPagev2s(totalAmount: totalAmount, items: items)));
      },
    );
  }
}
