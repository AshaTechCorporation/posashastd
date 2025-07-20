# แก้ไข StockPage ให้ใช้ API จริงผ่าน GetX

## ภาพรวมการแก้ไข

แก้ไขหน้า StockPage จากการใช้ mock data เป็นการเรียก API จริงผ่าน StockController และ StockService โดยใช้ GetX สำหรับ state management

## ✅ การแก้ไขหลัก

### 1. **เพิ่ม Import ที่จำเป็น**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/D2S/controllers/stock_controller.dart';
import 'package:posashastd/D2S/home/widgets/AppDrawer.dart';
import 'package:posashastd/constants.dart';
import 'package:posashastd/models/branch.dart';
```

### 2. **เปลี่ยน StockPage เป็น StatelessWidget ที่ใช้ GetX**

#### ก่อนแก้ไข:
```dart
class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final List<String> branches = ['สาขา1', 'สาขา2', 'สาขา3']; // Mock data
  String? selectedBranch;
  // ...
}
```

#### หลังแก้ไข:
```dart
class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StockController>(
      init: StockController(),
      builder: (stockController) => _StockPageContent(stockController: stockController),
    );
  }
}

class _StockPageContent extends StatefulWidget {
  final StockController stockController;
  
  const _StockPageContent({required this.stockController});

  @override
  State<_StockPageContent> createState() => _StockPageContentState();
}

class _StockPageContentState extends State<_StockPageContent> {
  Branch? selectedBranch; // เปลี่ยนจาก String? เป็น Branch?
  String? selectedStock;
  String? selectedProduct;
  // ...
}
```

### 3. **สร้าง _buildBranchDropdown ใหม่ที่ใช้ API**

```dart
// ✅ Dropdown สำหรับสาขา (ใช้ API)
Widget _buildBranchDropdown() {
  // แสดง loading เมื่อยังไม่มีข้อมูล
  if (widget.stockController.branches.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('กำลังโหลดข้อมูลสาขา...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // แสดง dropdown เมื่อมีข้อมูลแล้ว
  return DropdownButtonFormField<Branch>(
    value: selectedBranch,
    decoration: InputDecoration(
      labelText: 'เลือกสาขา',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    items: widget.stockController.branches
        .map((branch) => DropdownMenuItem<Branch>(
              value: branch,
              child: Text(branch.name ?? 'ไม่มีชื่อสาขา'),
            ))
        .toList(),
    onChanged: (Branch? newBranch) {
      setState(() {
        selectedBranch = newBranch;
      });
    },
  );
}
```

### 4. **แก้ไขการใช้ Dropdown ในหน้า**

#### ก่อนแก้ไข:
```dart
_buildDropdown(
  label: 'เลือกสาขา', 
  value: selectedBranch, 
  items: branches, // Mock data
  onChanged: (val) => setState(() => selectedBranch = val)
),
```

#### หลังแก้ไข:
```dart
Obx(() => _buildBranchDropdown()),
```

### 5. **แก้ไขฟังก์ชัน _addSelectedItemsToRight**

#### ก่อนแก้ไข:
```dart
void _addSelectedItemsToRight() {
  final toAdd = [if (selectedBranch != null) 'สาขา: $selectedBranch'];
  // ...
}
```

#### หลังแก้ไข:
```dart
void _addSelectedItemsToRight() {
  final toAdd = [if (selectedBranch != null) 'สาขา: ${selectedBranch!.name}'];
  // ...
}
```

### 6. **ปรับปรุง StockController**

```dart
Future<void> getBranches() async {
  try {
    log('🔄 Loading branches from API...');
    final rawData = await StockService.getProducts();
    log('📦 Raw API response: $rawData');
    
    final List<Map<String, dynamic>> parsedBranches = List<Map<String, dynamic>>.from(rawData);
    final List<Branch> branchesList = parsedBranches.map((branchesData) => Branch.fromJson(branchesData)).toList();
    
    branches.assignAll(branchesList);
    log('✅ Loaded ${branchesList.length} branches successfully');
    
    for (var branch in branchesList) {
      log('🏢 Branch: ${branch.name} (ID: ${branch.id})');
    }
  } catch (e) {
    log('❌ Error loading branches: $e');
  }
}
```

## 🎯 การทำงานของระบบ

### 1. **Flow การโหลดข้อมูล**

```
StockPage loads
         ↓
GetBuilder<StockController> initializes
         ↓
StockController.onInit() calls getBranches()
         ↓
StockService.getProducts() calls API /api/branch
         ↓
Response parsed to List<Branch>
         ↓
branches.assignAll(branchesList)
         ↓
Obx() detects change and rebuilds dropdown
         ↓
User sees branch options in dropdown
```

### 2. **State Management**

```dart
// StockController
RxList<Branch> branches = <Branch>[].obs;

// StockPage
Obx(() => _buildBranchDropdown()) // Reactive to branches changes

// Local State
Branch? selectedBranch; // Selected branch object
```

### 3. **API Integration**

```dart
// StockService
static Future getProducts() async {
  final authService = AuthService();
  final url = Uri.https(publicUrl, '/api/branch');
  var headers = {
    'Authorization': 'Bearer ${authService.currentToken}',
    'Content-Type': 'application/json'
  };
  final response = await http.get(headers: headers, url);
  // ...
}
```

## 🔧 Technical Details

### 1. **Data Models**

```dart
// Branch Model
@JsonSerializable()
class Branch {
  int id;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  String? code;
  String? name;
  String? address;
  String? description;
  String? active;
  
  // fromJson และ toJson methods
}
```

### 2. **Widget Architecture**

```
StockPage (StatelessWidget)
    ↓
GetBuilder<StockController>
    ↓
_StockPageContent (StatefulWidget)
    ↓
_StockPageContentState
    ↓
Obx(() => _buildBranchDropdown())
```

### 3. **Error Handling**

```dart
// Loading State
if (widget.stockController.branches.isEmpty) {
  return Container(/* Loading UI */);
}

// API Error Handling
try {
  final rawData = await StockService.getProducts();
  // ...
} catch (e) {
  log('❌ Error loading branches: $e');
}
```

## 📱 User Experience

### 1. **Loading States**

- **เริ่มต้น**: แสดง loading indicator พร้อมข้อความ "กำลังโหลดข้อมูลสาขา..."
- **โหลดสำเร็จ**: แสดง dropdown พร้อมรายการสาขาจาก API
- **โหลดล้มเหลว**: ยังคงแสดง loading (อาจปรับปรุงให้แสดง error message)

### 2. **Dropdown Behavior**

- **ก่อนโหลด**: แสดง loading container
- **หลังโหลด**: แสดง dropdown ปกติ
- **เลือกสาขา**: เก็บ Branch object ใน selectedBranch
- **แสดงชื่อ**: ใช้ branch.name ในการแสดงผล

### 3. **Reactive Updates**

- ใช้ `Obx()` เพื่อ reactive updates
- เมื่อ `branches` เปลี่ยน dropdown จะ rebuild อัตโนมัติ
- ใช้ `setState()` สำหรับ local state (selectedBranch)

## ✅ ผลลัพธ์

### 1. **Functionality**
- ✅ เรียก API /api/branch เพื่อดึงข้อมูลสาขา
- ✅ แสดงรายการสาขาใน dropdown จากข้อมูลจริง
- ✅ Loading state เมื่อกำลังโหลดข้อมูล
- ✅ เลือกสาขาได้และเก็บ Branch object
- ✅ แสดงชื่อสาขาที่เลือกในรายการด้านขวา

### 2. **Technical Quality**
- ✅ ใช้ GetX สำหรับ state management
- ✅ Separation of concerns (Controller, Service, UI)
- ✅ Proper error handling และ logging
- ✅ Reactive UI updates

### 3. **User Experience**
- ✅ Loading indicator ที่เข้าใจง่าย
- ✅ Smooth transition จาก loading เป็น dropdown
- ✅ ข้อมูลจริงจาก API
- ✅ UI ที่ responsive

## 🚀 การพัฒนาต่อ

### ฟีเจอร์ที่สามารถเพิ่มได้:
1. **Error State**: แสดง error message เมื่อโหลดข้อมูลล้มเหลว
2. **Refresh Button**: ปุ่มโหลดข้อมูลใหม่
3. **Search/Filter**: ค้นหาสาขาใน dropdown
4. **Caching**: เก็บข้อมูลสาขาใน cache
5. **Offline Support**: แสดงข้อมูลล่าสุดเมื่อไม่มีเน็ต

### การปรับปรุงเพิ่มเติม:
- เพิ่ม pull-to-refresh
- เพิ่ม skeleton loading
- เพิ่มการ validate ข้อมูลก่อนส่ง
- เพิ่ม analytics tracking

## 📝 หมายเหตุ

### API Endpoint:
- **URL**: `/api/branch`
- **Method**: GET
- **Headers**: Authorization Bearer token
- **Response**: Array of Branch objects

### Dependencies:
- **GetX**: State management และ dependency injection
- **HTTP**: API calls
- **JSON Annotation**: Model serialization

### File Structure:
```
lib/
├── D2S/
│   ├── controllers/
│   │   └── stock_controller.dart
│   └── stock/
│       └── stockPage.dart
├── models/
│   └── branch.dart
└── services/
    └── stock_service.dart
```
