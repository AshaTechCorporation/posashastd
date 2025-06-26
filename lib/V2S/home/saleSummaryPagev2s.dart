import 'package:flutter/material.dart';
import 'package:posashastd/V2S/home/homev2s.dart';
import 'package:posashastd/helpers/receipt_printer_v2s.dart';
import 'package:posashastd/services/homeService.dart';

class SaleSummaryPagev2s extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> items;

  SaleSummaryPagev2s({super.key, required this.totalAmount, required this.items});

  @override
  State<SaleSummaryPagev2s> createState() => _SaleSummaryPagev2sState();
}

class _SaleSummaryPagev2sState extends State<SaleSummaryPagev2s> {
  final double change = 0.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.green, elevation: 0, automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AmountSection(amount: widget.totalAmount, change: change),
            const SizedBox(height: 32),
            _EmailInput(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await printReceipt(); // ✅ เรียกฟังก์ชันพิมพ์
              },
              icon: const Icon(Icons.print, color: Colors.black),
              label: const Text('พิมพ์ใบเสร็จ', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                // TODO: เริ่มการขายใหม่

                final formattedOrder = {
                  "deviceId": 1,
                  "shiftId": 1,
                  "total": widget.totalAmount,
                  "memberId": 2,
                  "date": DateTime.now().toIso8601String(),
                  "orderItems":
                      widget.items.map((item) {
                        return {"productId": item["id"] ?? 0, "price": item["price"] ?? 0, "quantity": item["qty"] ?? 0, "total": item["total"] ?? 0};
                      }).toList(),
                };

                print("📦 JSON ที่จะส่ง: $formattedOrder");

                ///final _order = await Homeservice.createOrders(formattedOrder: formattedOrder);

                // ✅ หากต้องการส่งไป API หรือจัดเก็บ สามารถทำได้ตรงนี้
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Homev2s()),
                  (route) => false, // 🔥 ล้างทุกหน้า
                );
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('เริ่มการขายใหม่', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountSection extends StatelessWidget {
  final double amount;
  final double change;

  const _AmountSection({required this.amount, required this.change});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildAmountBlock('฿${amount.toStringAsFixed(2)}', 'ยอดที่ชำระ'),
        Container(width: 1, height: 40, color: Colors.grey[300]),
        _buildAmountBlock('฿${change.toStringAsFixed(2)}', 'เงินทอน'),
      ],
    );
  }

  Widget _buildAmountBlock(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.email, color: Colors.grey),
        const SizedBox(width: 12),
        const Expanded(child: TextField(decoration: InputDecoration(hintText: 'กรอกอีเมล', isDense: true, border: UnderlineInputBorder()))),
        const SizedBox(width: 12),
        const Icon(Icons.send, color: Colors.green),
      ],
    );
  }
}
