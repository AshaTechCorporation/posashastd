import 'package:flutter/material.dart';
import 'package:posashastd/D2S/home/homePage.dart';
import 'package:posashastd/D2S/product/productListPage.dart';
import 'package:posashastd/D2S/receipt/receiptHistoryPage.dart';
import 'package:posashastd/D2S/report/summaryReportPage.dart';
import 'package:posashastd/D2S/setting/settingsPage.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 ส่วนหัว
          Container(
            color: Colors.green,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('unknown unknown', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('POS 1', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text('ตะวันตก', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),

          // 🔸 รายการเมนู
          Expanded(
            child: ListView(
              children: [
                _DrawerItem(
                  icon: Icons.shopping_basket,
                  label: 'ขาย',
                  onTap: () {
                    Navigator.pop(context); // ปิด Drawer ก่อน
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => HomePage()),
                      (route) => false, // ลบ route ทั้งหมด
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.receipt_long,
                  label: 'ใบเสร็จรับเงิน',
                  onTap: () {
                    Navigator.pop(context); // ปิด Drawer ก่อน
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => ReceiptHistoryPage()),
                      (route) => false, // ลบ route ทั้งหมด
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.access_time,
                  label: 'กะ',
                  onTap: () {
                    Navigator.pop(context); // ปิด Drawer ก่อน
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => SummaryReportPage()),
                      (route) => false, // ลบ route ทั้งหมด
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.list_alt,
                  label: 'รายการสินค้า',
                  onTap: () {
                    Navigator.pop(context); // ปิด Drawer ก่อน
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => ProductListPage()),
                      (route) => false, // ลบ route ทั้งหมด
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.settings,
                  label: 'การตั้งค่า',
                  onTap: () {
                    Navigator.pop(context); // ปิด Drawer ก่อน
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => SettingsPage()),
                      (route) => false, // ลบ route ทั้งหมด
                    );
                  },
                ),
                _DrawerItem(icon: Icons.bar_chart, label: 'รายงานการขาย', onTap: () {}),
                _DrawerItem(icon: Icons.inventory, label: 'สต็อก', onTap: () {}),
                _DrawerItem(icon: Icons.info_outline, label: 'รายละเอียดบัญชี', onTap: () {}),
              ],
            ),
          ),

          const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('v2.55.1', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon, color: Colors.black54), title: Text(label), onTap: onTap);
  }
}
