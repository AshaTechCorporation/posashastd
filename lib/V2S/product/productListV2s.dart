import 'package:flutter/material.dart';
import 'package:posashastd/V2S/widgets/AppDrawerv2s.dart';

class ProductListV2s extends StatelessWidget {
  const ProductListV2s({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawerv2s(),
      appBar: AppBar(
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('รายการสินค้า', style: TextStyle(color: Colors.white)),
      ),

      // ✅ รายการเมนูใน Body
      body: Column(
        children: const [
          _MenuItem(icon: Icons.inventory_2, label: 'รายการสินค้า'),
          _MenuItem(icon: Icons.category, label: 'หมวดหมู่'),
          _MenuItem(icon: Icons.insert_drive_file, label: 'ตัวเลือกเพิ่มเติม'),
          _MenuItem(icon: Icons.local_offer, label: 'ส่วนลด'),
        ],
      ),
    );
  }
}

// ✅ เมนูแต่ละรายการ พร้อมเส้นขีดด้านล่าง
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black54),
          title: Text(label, style: const TextStyle(color: Colors.black87, fontSize: 15)),
          onTap: () {
            // เพิ่มการทำงานเมื่อกด
          },
        ),
        const Divider(height: 1, thickness: 0.6, indent: 16, endIndent: 16, color: Colors.black12),
      ],
    );
  }
}
