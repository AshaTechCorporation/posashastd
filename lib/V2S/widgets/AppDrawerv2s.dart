import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/V2S/home/homeV2S.dart';
import 'package:posashastd/V2S/product/productListV2s.dart';
import 'package:posashastd/V2S/receipt/receiptHistoryV2s.dart';
import 'package:posashastd/V2S/report/shiftV2s.dart';
import 'package:posashastd/V2S/setting/settingsV2s.dart';
import 'package:posashastd/constants.dart';
import 'package:posashastd/services/auth_service.dart';
import 'package:posashastd/D2S/controllers/home_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawerv2s extends StatefulWidget {
  const AppDrawerv2s({super.key});

  @override
  State<AppDrawerv2s> createState() => _AppDrawerv2sState();
}

class _AppDrawerv2sState extends State<AppDrawerv2s> {
  int selectedIndex = 0;
  String staffName = 'unknown unknown';
  String branchName = 'ตะวันตก';
  String deviceName = 'POS 1';

  final List<_DrawerItemData> menuItems = [
    _DrawerItemData(Icons.shopping_basket, 'ขาย', const Homev2s()),
    _DrawerItemData(Icons.receipt_long, 'ใบเสร็จรับเงิน', const ReceiptHistoryV2s()),
    _DrawerItemData(Icons.access_time, 'กะ', const ShiftV2s()),
    _DrawerItemData(Icons.settings, 'การตั้งค่า', const SettingsV2s()),
    _DrawerItemData(Icons.inventory, 'สต็อก', null),
  ];

  @override
  void initState() {
    super.initState();
    _loadStaffInfo();
  }

  // โหลดข้อมูลพนักงาน
  Future<void> _loadStaffInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ดึงข้อมูลพนักงาน
      final firstName = prefs.getString('user_data') ?? 'unknown';
      final lastName = prefs.getString('currentLastName') ?? '';
      final branch = prefs.getString('currentBranchName') ?? 'POS 1';
      final device = prefs.getString('device_name') ?? 'POS 1';

      log('📋 Staff info loaded: $firstName $lastName, Branch: $branch, Device: $device');

      if (mounted) {
        setState(() {
          staffName = '$firstName $lastName';
          branchName = branch;
          deviceName = device;
        });
      }
    } catch (e) {
      log('❌ Error loading staff info: $e');
    }
  }

  void _onItemTap(int index) async {
    setState(() {
      selectedIndex = index;
    });

    Navigator.pop(context);

    final targetPage = menuItems[index].targetPage;
    final label = menuItems[index].label;

    // จัดการปุ่มสต๊อกแยกต่างหาก
    if (label == 'สต็อก') {
      await _handleStockTap();
      return;
    }

    if (targetPage != null) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => targetPage), (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ฟีเจอร์ "$label" ยังไม่พร้อมใช้งาน')));
    }
  }

  // จัดการการกดปุ่มสต๊อก
  Future<void> _handleStockTap() async {
    try {
      final authService = AuthService();
      final token = authService.currentToken;

      log('🔍 Debug: Current token = $token');

      if (token == null || token.isEmpty) {
        log('❌ Token is null or empty');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่พบ token การเข้าสู่ระบบ กรุณาเข้าสู่ระบบใหม่')));
        }
        return;
      }

      final stockUrlString = 'https://pos-asha.dev-asha.com/inventory?token=$token';
      log('🔍 Debug: Stock URL = $stockUrlString');

      final stockUrl = Uri.parse(stockUrlString);
      log('🔍 Debug: Parsed URI = $stockUrl');

      final canLaunch = await canLaunchUrl(stockUrl);
      log('🔍 Debug: Can launch URL = $canLaunch');

      if (canLaunch) {
        log('🚀 Launching stock URL...');
        await launchUrl(stockUrl, mode: LaunchMode.externalApplication);
        log('✅ Stock URL launched successfully');
      } else {
        log('❌ Cannot launch stock URL');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่สามารถเปิดหน้าสต๊อกได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต')));
        }
      }
    } catch (e) {
      log('❌ Error in _handleStockTap: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')));
      }
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
            color: ktextColr,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(staffName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(deviceName, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                Text(branchName, style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
