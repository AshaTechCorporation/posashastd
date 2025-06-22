import 'package:flutter/material.dart';

class ReceiptHistoryV2s extends StatelessWidget {
  const ReceiptHistoryV2s({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ใบเสร็จรับเงิน'), backgroundColor: Colors.green),
      body: Column(
        children: [
          // 🔍 ช่องค้นหา
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ค้นหา',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          // 🔘 รายการใบเสร็จ
          Expanded(
            child: ListView(
              children: [
                _buildDateHeader('วันเสาร์ที่ 21 มิถุนายน ค.ศ. 2025'),
                _buildReceiptItem(Icons.payments, '฿60.00', '6:57 หลังเที่ยง', '#1-1019'),
                _buildReceiptItem(Icons.receipt, '฿60.00', '6:57 หลังเที่ยง', '#1-1018'),

                _buildDateHeader('วันพุธที่ 26 กุมภาพันธ์ ค.ศ. 2025'),
                _buildReceiptItem(Icons.payments, '฿601.00', '2:56 หลังเที่ยง', '#1-1015'),
                _buildReceiptItem(Icons.payments, '฿352.00', '9:08 ก่อนเที่ยง', '#1-1014'),

                _buildDateHeader('วันจันทร์ที่ 24 กุมภาพันธ์ ค.ศ. 2025'),
                _buildReceiptItem(Icons.payments, '฿350.00', '12:02 ก่อนเที่ยง', '#4-1010'),
                _buildReceiptItem(Icons.payments, '฿255.00', '', '#4-1009'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(date, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildReceiptItem(IconData icon, String amount, String time, String number) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(time),
      trailing: Text(number),
    );
  }
}
