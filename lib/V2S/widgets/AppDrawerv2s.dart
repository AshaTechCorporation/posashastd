import 'package:flutter/material.dart';
import 'package:posashastd/V2S/home/homeV2S.dart';
import 'package:posashastd/V2S/product/productListV2s.dart';
import 'package:posashastd/V2S/receipt/receiptHistoryV2s.dart';
import 'package:posashastd/V2S/report/shiftV2s.dart';
import 'package:posashastd/V2S/setting/settingsV2s.dart';

class AppDrawerv2s extends StatefulWidget {
  const AppDrawerv2s({super.key});

  @override
  State<AppDrawerv2s> createState() => _AppDrawerv2sState();
}

class _AppDrawerv2sState extends State<AppDrawerv2s> {
  int selectedIndex = 0;

  final List<_DrawerItemData> menuItems = [
    _DrawerItemData(Icons.shopping_basket, 'ขาย', const Homev2s()),
    _DrawerItemData(Icons.receipt_long, 'ใบเสร็จรับเงิน', const ReceiptHistoryV2s()),
    _DrawerItemData(Icons.access_time, 'กะ', const ShiftV2s()),
    _DrawerItemData(Icons.list_alt, 'รายการสินค้า', const ProductListV2s()),
    _DrawerItemData(Icons.settings, 'การตั้งค่า', const SettingsV2s()),
    _DrawerItemData(Icons.bar_chart, 'รายงานการขาย', null),
    _DrawerItemData(Icons.inventory, 'สต็อก', null),
    _DrawerItemData(Icons.info_outline, 'รายละเอียดบัญชี', null),
  ];

  void _onItemTap(int index) {
    setState(() {
      selectedIndex = index;
    });

    Navigator.pop(context);

    final targetPage = menuItems[index].targetPage;
    if (targetPage != null) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => targetPage), (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ฟีเจอร์ "${menuItems[index].label}" ยังไม่พร้อมใช้งาน')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _DrawerItem(icon: item.icon, label: item.label, selected: selectedIndex == index, onTap: () => _onItemTap(index));
              },
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('v2.55.1', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}

class _DrawerItemData {
  final IconData icon;
  final String label;
  final Widget? targetPage;

  const _DrawerItemData(this.icon, this.label, this.targetPage);
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.label, required this.selected, required this.onTap});

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
        onTap: onTap,
      ),
    );
  }
}
