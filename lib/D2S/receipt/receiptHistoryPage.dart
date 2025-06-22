import 'package:flutter/material.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';

class ReceiptHistoryPage extends StatelessWidget {
  const ReceiptHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: Row(
        children: [
          // ฝั่งซ้าย (40%)
          SizedBox(
            width: screenWidth * 0.4,
            child: Column(
              children: [
                Container(
                  height: 50,
                  color: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Builder(
                        builder: (c) => IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(c).openDrawer()),
                      ),
                      const SizedBox(width: 4),
                      const Text('ใบเสร็จรับเงิน', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                Expanded(child: _buildReceiptList()),
              ],
            ),
          ),

          // เส้นแบ่งกลาง
          const VerticalDivider(width: 1, color: Colors.grey),

          // ฝั่งขวา (60%)
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 50,
                  color: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      Text('#1-1018', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Text('ยืนยัน', style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(width: 8),
                      Icon(Icons.more_vert, color: Colors.white),
                    ],
                  ),
                ),

                // ปรับการแสดง Card ให้เหมือนรูป
                GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Padding(padding: const EdgeInsets.all(20), child: _buildReceiptDetail()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: SizedBox(
            height: 40,
            child: Row(
              children: const [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: 'ค้นหา...', border: InputBorder.none, isCollapsed: true),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(thickness: 2),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(left: 8),
            children: [
              _buildDateGroup('วันที่ 21 มิ.ย. พ.ศ. 2025'),
              _buildReceiptItem(price: 60, time: '18:57 น.', code: '#1-1018', selected: true),
              _buildReceiptItem(price: 60, time: '18:57 น.', code: '#1-1019'),
              _buildDateGroup('วันที่ 20 กุมภาพันธ์ พ.ศ. 2025'),
              _buildReceiptItem(price: 255, time: '13:21 น.', code: '#4-1008'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: const Text('฿60.00', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
        const SizedBox(height: 4),
        const Text('รวมทั้งหมด', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        const Text('พนักงาน: unknown unknown', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        const Text('ระบบขาย: POS 1', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        const Text('AFMหมึกญี่ปุ่น', style: TextStyle(fontSize: 14)),
        const Text('1 x ฿60.00', style: TextStyle(fontSize: 14)),
        const Divider(height: 24),
        _buildRow('รวมทั้งหมด', '฿60.00'),
        _buildRow('โอนชำระ', '฿60.00'),
        const SizedBox(height: 16),
        _buildRow('21/6/25 18:57 น.', '#1-1018'),
      ],
    );
  }

  Widget _buildRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(left), Text(right)]),
    );
  }

  Widget _buildDateGroup(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Text(date, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildReceiptItem({required double price, required String time, required String code, bool selected = false}) {
    return Container(
      color: selected ? Colors.grey[200] : null,
      child: ListTile(
        leading: const Icon(Icons.receipt_long),
        title: Text('฿${price.toStringAsFixed(2)}'),
        subtitle: Text(time),
        trailing: Text(code),
        onTap: () {},
      ),
    );
  }
}
