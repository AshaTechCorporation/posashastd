import 'package:flutter/material.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // ✅ Header
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
                    const Text('การตั้งค่า', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const Text('เครื่องพิมพ์', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),

          // ✅ Main Body
          Expanded(
            child: Row(
              children: [
                // 🔹 Left menu
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SettingsMenuItem(icon: Icons.print, label: 'เครื่องพิมพ์', selected: true),
                      _SettingsMenuItem(icon: Icons.percent, label: 'ภาษี'),
                      _SettingsMenuItem(icon: Icons.settings, label: 'ทั่วไป'),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('jumpoll207@hotmail.com', style: TextStyle(color: Colors.black54)),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
                          onPressed: () {},
                          child: const Text('ออกจากระบบ'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // 🔸 Divider
                const VerticalDivider(width: 1, color: Colors.grey),

                // 🟩 Right content
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.print, size: 80, color: Colors.black26),
                        SizedBox(height: 16),
                        Text('ไม่ได้เชื่อมต่อเครื่องพิมพ์', style: TextStyle(fontSize: 16, color: Colors.black54)),
                        SizedBox(height: 4),
                        Text('คุณสามารถเชื่อมต่อเครื่องพิมพ์ในเครือข่ายของคุณได้ที่', style: TextStyle(fontSize: 14, color: Colors.black45)),
                        SizedBox(height: 4),
                        Text('ตั้งค่าเพิ่มเติม', style: TextStyle(fontSize: 14, color: Colors.blue, decoration: TextDecoration.underline)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Floating Add Button
          Padding(
            padding: const EdgeInsets.only(bottom: 16, right: 16),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(onPressed: () {}, backgroundColor: Colors.green, child: const Icon(Icons.add)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _SettingsMenuItem({required this.icon, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selected ? Colors.grey[200] : null,
      child: ListTile(
        leading: Icon(icon, color: selected ? Colors.green : Colors.black54),
        title: Text(label, style: TextStyle(color: selected ? Colors.green : Colors.black87)),
        onTap: () {},
      ),
    );
  }
}
