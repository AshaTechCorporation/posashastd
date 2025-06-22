import 'package:flutter/material.dart';

class ShiftV2s extends StatelessWidget {
  const ShiftV2s({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('กะ'), backgroundColor: Colors.green, actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.print))]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔘 ปุ่มจัดการเงินสด และปิดกะ
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green), foregroundColor: Colors.green),
                  onPressed: () {},
                  child: const Text('การจัดการ เงินสด'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () {}, child: const Text('ปิดกะ')),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 🔘 ข้อมูลกะ
          const Text('จำนวนกะที่ทำงาน: 1'),
          const SizedBox(height: 4),
          Row(children: const [Text('เปิดแล้ว: unknown unknown'), Spacer(), Text('24/2/25 10:20 ก่อนเที่ยง')]),
          const SizedBox(height: 20),

          // 🔘 สรุปเงิน
          const Text('สรุปการเก็บเงิน', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildSummaryRow('เงินสดเริ่มต้นเปิดกะ', '฿0.00'),
          _buildSummaryRow('ชำระเงินสด', '฿3,999.00'),
          _buildSummaryRow('คืนเงินสด', '฿0.00'),
          _buildSummaryRow('จ่ายเงินเข้า', '฿0.00'),
          _buildSummaryRow('จ่ายออก', '฿0.00'),
          const Divider(height: 24),
          _buildSummaryRow('เงินคงเหลือ', '฿3,999.00', isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Expanded(child: Text(title)), Text(amount, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal))]),
    );
  }
}
