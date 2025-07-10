import 'package:flutter/material.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int selectedTab = 0;

  final List<String> tabs = ['เครื่องพิมพ์', 'ภาษี', 'ทั่วไป'];

  Widget buildTabContent() {
    switch (selectedTab) {
      case 0:
        return _printerTab();
      case 1:
        return _taxTab();
      case 2:
        return _generalTab();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Row(
          children: [
            // 🔹 Side menu and tabs
            Container(
              width: 250,
              color: const Color(0xFFEFEFEF),
              child: Column(
                children: [
                  // ✅ Menu button
                  Container(
                    height: 50,
                    color: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Builder(
                          builder:
                              (context) =>
                                  IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer()),
                        ),
                        const SizedBox(width: 8),
                        Text('ตั้งค่า', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (int i = 0; i < tabs.length; i++)
                    ListTile(
                      leading: Icon(
                        i == 0
                            ? Icons.print
                            : i == 1
                            ? Icons.percent
                            : Icons.settings,
                        color: selectedTab == i ? Colors.green : Colors.black54,
                      ),
                      title: Text(
                        tabs[i],
                        style: TextStyle(
                          color: selectedTab == i ? Colors.green : Colors.black87,
                          fontWeight: selectedTab == i ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: selectedTab == i,
                      onTap: () => setState(() => selectedTab = i),
                    ),
                  const Spacer(),
                  const Divider(),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text("jumpoll7107@hotmail.com", style: TextStyle(fontSize: 12))),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text("ออกจากระบบ"),
                    ),
                  ),
                ],
              ),
            ),
            // 🔸 Tab Content
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 50,
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(tabs[selectedTab], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: buildTabContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _printerTab() {
    return Column(
      children: [
        ListTile(leading: const Icon(Icons.print), title: const Text('test'), subtitle: const Text('Sunmi'), trailing: const Text('ใบเสร็จรับเงิน')),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(onPressed: () {}, backgroundColor: Colors.green, child: const Icon(Icons.add)),
          ),
        ),
      ],
    );
  }

  Widget _taxTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.percent, size: 64, color: Colors.grey),
          SizedBox(height: 20),
          Text("คุณยังไม่มีการใช้ภาษีของคุณ"),
          SizedBox(height: 8),
          Text("โปรดแตะที่การรวม รายการคำสั่งขาย", style: TextStyle(color: Colors.grey)),
          Text("ได้ภาษีที่ถูกต้อง", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _generalTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          SwitchListTile(title: const Text("ใช้ต้นฉบับและสำเนาใบเสร็จ"), value: false, onChanged: (val) {}),
          SwitchListTile(title: const Text("โหมดเงียบ"), value: false, onChanged: (val) {}),
          const SizedBox(height: 16),
          const Text("เผื่อโครงหน้าอาจารย์การขาย: ระบบ", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          const Text("ภาษา: ใช้ค่าตั้งต้นอุปกรณ์", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
