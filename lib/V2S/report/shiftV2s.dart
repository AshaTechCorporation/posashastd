import 'package:flutter/material.dart';
import 'package:posashastd/V2S/widgets/AppDrawerv2s.dart';

class ShiftV2s extends StatelessWidget {
  const ShiftV2s({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawerv2s(),
      appBar: AppBar(
        title: const Text('กะ'),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.print, color: Colors.white))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔘 ปุ่มจัดการเงินสด / ปิดกะ
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFullWidthButton(
                label: 'การจัดการ เงินสด',
                backgroundColor: Colors.white,
                textColor: Colors.black87,
                borderColor: Colors.green,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildFullWidthButton(
                label: 'ปิดกะ',
                backgroundColor: Colors.white,
                textColor: Colors.black87,
                borderColor: Colors.green,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 🔘 ข้อมูลกะ
          const Text('จำนวนกะที่ทำงาน: 1', style: TextStyle(fontSize: 15)),
          const SizedBox(height: 6),
          Row(
            children: const [
              Expanded(child: Text('เปิดแล้ว: unknown unknown', style: TextStyle(fontSize: 15))),
              Text('24/2/25 10:20 ก่อนเที่ยง', style: TextStyle(fontSize: 15)),
            ],
          ),

          const SizedBox(height: 24),

          // 🔘 หัวข้อสรุปการเก็บเงิน
          const Text('สรุปการเก็บเงิน', style: TextStyle(color: Color(0xFF558B2F), fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // 🔘 รายการเงิน
          _buildSummaryRow('เงินสดเริ่มต้นเปิดกะ', '฿0.00'),
          _buildSummaryRow('ชำระเงินสด', '฿3,999.00'),
          _buildSummaryRow('คืนเงินสด', '฿0.00'),
          _buildSummaryRow('จ่ายเงินเข้า', '฿0.00'),
          _buildSummaryRow('จ่ายออก', '฿0.00'),

          const SizedBox(height: 12),
          const Divider(thickness: 0.8),
          const SizedBox(height: 6),

          // 🔘 เงินคาดไร (รวมยอด)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: const [
                Expanded(child: Text('เงินคาดไร', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Colors.black))),
                Text('฿3,999.00', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 15))), Text(amount, style: const TextStyle(fontSize: 15))]),
    );
  }

  Widget _buildFullWidthButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: borderColor != null ? Border.all(color: borderColor) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
