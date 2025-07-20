import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/controllers/stock_controller.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';
import 'package:posashastd/constants.dart';
import 'package:posashastd/models/branch.dart';

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ใช้ Get.put เพื่อให้แน่ใจว่า controller ถูกสร้างและเก็บไว้
    final stockController = Get.put(StockController());
    return _StockPageContent(stockController: stockController);
  }
}

class _StockPageContent extends StatefulWidget {
  final StockController stockController;

  const _StockPageContent({required this.stockController});

  @override
  State<_StockPageContent> createState() => _StockPageContentState();
}

class _StockPageContentState extends State<_StockPageContent> {
  Branch? selectedBranch;
  String? selectedStock;
  String? selectedProduct;

  List<String> rightItems = [];
  Set<int> selectedRightIndices = {};

  void _addSelectedItemsToRight() {
    final toAdd = [if (selectedBranch != null) 'สาขา: ${selectedBranch!.name}'];

    setState(() {
      for (var item in toAdd) {
        if (!rightItems.contains(item)) {
          rightItems.add(item);
        }
      }
    });
  }

  void _removeSelectedItemsFromRight() {
    setState(() {
      rightItems = rightItems.asMap().entries.where((entry) => !selectedRightIndices.contains(entry.key)).map((entry) => entry.value).toList();
      selectedRightIndices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('โอนสินค้า', style: TextStyle(color: Colors.white)),
        backgroundColor: kTabColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Row(
          children: [
            // 🔹 ฝั่งซ้าย
            Expanded(child: Padding(padding: const EdgeInsets.all(16), child: _buildLeftPanel())),

            // 🔄 ปุ่มลูกศร
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTransferButton(icon: Icons.arrow_forward_ios, onPressed: _addSelectedItemsToRight),
                const SizedBox(height: 10),
                _buildTransferButton(icon: Icons.arrow_back_ios, onPressed: _removeSelectedItemsFromRight),
              ],
            ),

            // 🔹 ฝั่งขวา
            Expanded(child: Padding(padding: const EdgeInsets.all(16), child: _buildRightPanel())),
          ],
        ),
      ),
    );
  }

  // 🔻 ฝั่งซ้าย
  Widget _buildLeftPanel() {
    return Container(
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelHeader('ต้นทาง'),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16), child: Column(children: [_buildBranchDropdown(), const SizedBox(height: 12)])),
        ],
      ),
    );
  }

  // 🔻 ฝั่งขวา
  Widget _buildRightPanel() {
    return Container(
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelHeader('ปลายทาง'),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rightItems.length,
              itemBuilder: (context, index) {
                final item = rightItems[index];
                final isSelected = selectedRightIndices.contains(index);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedRightIndices.remove(index);
                      } else {
                        selectedRightIndices.add(index);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red.shade100 : Colors.transparent,
                      border: Border.all(color: isSelected ? Colors.red : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(item, style: const TextStyle(fontSize: 14)),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: ดำเนินการ "ยืนยัน"
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: kTabColor),
                child: const Text('ยืนยัน', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Dropdown สำหรับสาขา (ใช้ API)
  Widget _buildBranchDropdown() {
    return Obx(() {
      // แสดง error state
      if (widget.stockController.errorMessage.value.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.red[300]!), borderRadius: BorderRadius.circular(8), color: Colors.red[50]),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text('เกิดข้อผิดพลาด: ${widget.stockController.errorMessage.value}', style: TextStyle(color: Colors.red[600]))),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => widget.stockController.getBranches(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
                child: const Text('ลองใหม่', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }

      // แสดง loading state
      if (widget.stockController.isLoading.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
          child: const Row(
            children: [
              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 12),
              Text('กำลังโหลดข้อมูลสาขา...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      // แสดง empty state
      if (widget.stockController.branches.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.orange[300]!), borderRadius: BorderRadius.circular(8), color: Colors.orange[50]),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
              const SizedBox(width: 12),
              const Expanded(child: Text('ไม่พบข้อมูลสาขา', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () => widget.stockController.getBranches(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
                child: const Text('โหลดใหม่', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }

      // แสดง dropdown ปกติ
      return DropdownButtonFormField<Branch>(
        value: selectedBranch,
        decoration: InputDecoration(
          labelText: 'เลือกสาขา',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items:
            widget.stockController.branches
                .map((branch) => DropdownMenuItem<Branch>(value: branch, child: Text(branch.name ?? 'ไม่มีชื่อสาขา')))
                .toList(),
        onChanged: (Branch? newBranch) {
          setState(() {
            selectedBranch = newBranch;
          });
        },
      );
    });
  }

  // 🔧 Dropdown ตัวเดียว (สำหรับอื่นๆ)
  Widget _buildDropdown({required String label, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  // 🔧 UI Util
  BoxDecoration _panelDecoration() {
    return BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]);
  }

  Widget _panelHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Color(0xFFE8EAF0), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTransferButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 80,
      alignment: Alignment.center,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(18), backgroundColor: kTabColor, elevation: 4),
        onPressed: onPressed,
        child: Icon(icon, size: 30, color: Colors.white),
      ),
    );
  }
}
