import 'package:flutter/material.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';

class SummaryReportPage extends StatelessWidget {
  const SummaryReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // 🔰 Header
          Container(
            height: 50,
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Builder(
                      builder:
                          (context) =>
                              IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer()),
                    ),
                    const SizedBox(width: 4),
                    const Text('สรุปยอดขาย', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const Icon(Icons.refresh, color: Colors.white),
              ],
            ),
          ),

          // 🔳 Content block (single column)
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 700),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: Colors.white,
                child: ListView(
                  children: [
                    const Text('รายการทั้งหมด ปิดแล้ว', style: TextStyle(color: Colors.green, fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildRow('จำนวนรายการ:', '3'),
                    _buildRow('ปิดแล้ว:', 'บทหอพา บทหอพก'),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerRight, child: Text('21/3/24 16:42 น.', style: Theme.of(context).textTheme.bodySmall)),
                    const SizedBox(height: 24),
                    const Text('ตั้งแต่วันที่เริ่มต้นถึงปิดรอบ', style: TextStyle(color: Colors.green)),
                    const SizedBox(height: 12),
                    _buildRow('วันเริ่มต้นถึง.ปิดรอบ', '฿80.00'),
                    _buildRow('ชำระเป็นสด', '฿6,337.00'),
                    _buildRow('ชำระแอพ', '฿80.00'),
                    _buildRow('ส่วน.เงินท้า', '฿80.00'),
                    _buildRow('เงิน ออก', '฿80.00'),
                    _buildRowBold('เงินที่ควรได้', '฿6,337.00'),
                    const SizedBox(height: 16),
                    const Text('สรุปยอดขาย', style: TextStyle(color: Colors.green)),
                    const SizedBox(height: 12),
                    _buildRowBold('ยอดขาย', '฿6,462.00'),
                    _buildRow('รับแล้ว', '฿80.00'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value)]),
    );
  }

  Widget _buildRowBold(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
