import 'package:flutter/material.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(onPressed: () {}, backgroundColor: Colors.green, child: const Icon(Icons.add, color: Colors.white)),
      body: Row(
        children: [
          // 🔹 Sidebar Left
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            child: Column(
              children: [
                // Header
                Container(
                  height: 50,
                  color: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Builder(
                        builder:
                            (context) =>
                                IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer()),
                      ),
                      const SizedBox(width: 8),
                      const Text('รายการสินค้า', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),

                // Categories
                Expanded(
                  child: ListView(
                    children: const [
                      ListTile(title: Text('รายการสินค้าทั้งหมด', style: TextStyle(color: Colors.green))),
                      ListTile(leading: Icon(Icons.restaurant), title: Text('หมูชาชู')),
                      ListTile(leading: Icon(Icons.receipt), title: Text('อัฟ.กิตะ.รับแซ่บ')),
                      ListTile(leading: Icon(Icons.search), title: Text('ซ่า..เวอร์')),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔸 Vertical Divider
          const VerticalDivider(width: 1, color: Colors.grey),

          // 🔸 Product List Right
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  height: 50,
                  color: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: const Text('รายการทั้งหมด', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),

                // Product List
                Expanded(
                  child: ListView(
                    children: List.generate(10, (index) {
                      return ListTile(
                        leading: Container(width: 40, height: 40, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
                        title: Text('AFMสินค้าทดสอบ $index'),
                        subtitle: const Text('-'),
                        trailing: Text('฿${(30 + index * 5)}.00'),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
