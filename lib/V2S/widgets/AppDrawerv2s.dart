import 'package:flutter/material.dart';

class AppDrawerv2s extends StatelessWidget {
  const AppDrawerv2s({super.key});

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
                Text('POS 4', style: TextStyle(color: Colors.white70)),
                Text('พีเจาภาพ', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          // 🔸 เมนูรายการ
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: const [
                _DrawerItem(icon: Icons.shopping_basket, label: 'ยอดขาย', selected: true),
                _DrawerItem(icon: Icons.receipt_long, label: 'ใบเสร็จรับเงิน'),
                _DrawerItem(icon: Icons.access_time, label: 'กะ'),
                _DrawerItem(icon: Icons.list, label: 'รายการสินค้า'),
                _DrawerItem(icon: Icons.settings, label: 'การตั้งค่า'),
                Divider(),
                _DrawerItem(icon: Icons.bar_chart, label: 'ระบบหลังร้าน'),
                _DrawerItem(icon: Icons.apps, label: 'แอป'),
                _DrawerItem(icon: Icons.info_outline, label: 'การสนับสนุน'),
              ],
            ),
          ),

          const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('v.2.55.1', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _DrawerItem({required this.icon, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selected ? Colors.green.shade50 : null,
      child: ListTile(
        leading: Icon(icon, color: selected ? Colors.green : Colors.black54),
        title: Text(
          label,
          style: TextStyle(color: selected ? Colors.green : Colors.black87, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
        ),
        onTap: () {
          Navigator.pop(context);
          // เพิ่ม navigation ตามต้องการ เช่น Navigator.push...
        },
      ),
    );
  }
}
