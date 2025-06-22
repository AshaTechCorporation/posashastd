import 'package:flutter/material.dart';

class SettingsV2s extends StatelessWidget {
  const SettingsV2s({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(), // หรือ AppDrawerv2s() หากใช้ Drawer จริง
      appBar: AppBar(backgroundColor: Colors.green, title: const Text('การตั้งค่า', style: TextStyle(color: Colors.white))),
      body: Column(
        children: [
          const ListTile(leading: Icon(Icons.print), title: Text('เครื่องพิมพ์')),
          const ListTile(leading: Icon(Icons.percent), title: Text('ภาษี')),
          const ListTile(leading: Icon(Icons.settings), title: Text('ทั่วไป')),
          const Spacer(),
          const Padding(padding: EdgeInsets.only(bottom: 4), child: Text('jumpoil2107@hotmail.com', style: TextStyle(color: Colors.grey))),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300, foregroundColor: Colors.black87),
              child: const Text('ออกจากระบบ'),
            ),
          ),
        ],
      ),
    );
  }
}
