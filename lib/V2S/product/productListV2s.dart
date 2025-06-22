import 'package:flutter/material.dart';

class ProductListV2s extends StatelessWidget {
  const ProductListV2s({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 🔹 Sidebar Left
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Column(
              children: [
                // Header AppBar (แทน appbar จริง)
                Container(
                  height: 50,
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: const Row(
                    children: [
                      Icon(Icons.menu, color: Colors.white),
                      SizedBox(width: 8),
                      Text('รายการสินค้า', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                // Menu List
                Expanded(
                  child: ListView(
                    children: const [
                      ListTile(leading: Icon(Icons.list), title: Text('รายการสินค้า')),
                      ListTile(leading: Icon(Icons.dashboard), title: Text('หมวดหมู่')),
                      ListTile(leading: Icon(Icons.insert_drive_file), title: Text('ตัวเลือกเพิ่มเติม')),
                      ListTile(leading: Icon(Icons.local_offer), title: Text('ส่วนลด')),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔸 Vertical Divider
          const VerticalDivider(width: 1, color: Colors.grey),

          // 🔸 Main Content Right
          const Expanded(child: Center(child: Text('เลือกเมนูจากด้านซ้ายเพื่อดำเนินการ', style: TextStyle(color: Colors.black54)))),
        ],
      ),
    );
  }
}
