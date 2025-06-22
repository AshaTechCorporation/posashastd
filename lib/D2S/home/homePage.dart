import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';
import 'package:posashastd/D2S/home/widgets/ProductGrid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String selectedCategory = "ปูอัด-เต้าหู้-ปลาเส้น";
  late TabController _tabController;
  List<String> tabs = ['แท็บ 1'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.dispose();
  }

  void _addTab() {
    setState(() {
      tabs.add("แท็บ \${tabs.length + 1}");
      _tabController = TabController(length: tabs.length, vsync: this);
    });
  }

  void _removeTab(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('ยืนยันการลบ'),
            content: Text('ต้องการลบ "\${tabs[index]}" หรือไม่?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('ลบ')),
            ],
          ),
    );

    if (confirm == true) {
      setState(() {
        tabs.removeAt(index);
        _tabController = TabController(length: tabs.length, vsync: this);
      });
    }
  }

  Widget _buildGridContent(double width, double height) {
    return ProductGrid(
      itemCount: 20,
      isMainTab: _tabController.index == 0,
      width: width,
      height: height,
      onTap: (index) {
        print("กดสินค้า index: \$index");
      },
      onLongPress: (index) {
        print("กดค้างที่ index: \$index ของแท็บเพิ่ม");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final leftWidth = width * 0.7;
          final rightWidth = width * 0.3;

          return Row(
            children: [
              // 🔵 ฝั่งสินค้า 70%
              SizedBox(
                width: leftWidth,
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      color: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Builder(
                        builder:
                            (context) => Row(
                              children: [
                                IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer()),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedCategory,
                                    dropdownColor: Colors.white,
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                    iconEnabledColor: Colors.white,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => selectedCategory = value);
                                      }
                                    },
                                    items:
                                        ["ปูอัด-เต้าหู้-ปลาเส้น", "เนื้อสัตว์", "ผักสด"]
                                            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.black))))
                                            .toList(),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.search, size: 26, color: Colors.white),
                              ],
                            ),
                      ),
                    ),

                    // GridView
                    Expanded(child: AnimatedBuilder(animation: _tabController, builder: (_, __) => _buildGridContent(width, height))),

                    // TabBar
                    SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          IconButton(icon: const Icon(Icons.add, color: Colors.green), onPressed: _addTab),
                          Expanded(
                            child: TabBar(
                              isScrollable: true,
                              controller: _tabController,
                              tabs: List.generate(
                                tabs.length,
                                (index) => GestureDetector(onLongPress: () => _removeTab(index), child: Tab(text: tabs[index])),
                              ),
                              labelColor: Colors.green,
                              unselectedLabelColor: Colors.black54,
                              indicatorColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 🔴 ฝั่งตะกร้า 30%
              SizedBox(
                width: rightWidth,
                child: Column(
                  children: [
                    const ListTile(title: Text('ตะกร้า', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(child: Center(child: Text('ยังไม่มีสินค้า', style: TextStyle(color: Colors.grey)))),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size.fromHeight(50)),
                        child: const Text("ชำระเงิน"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
