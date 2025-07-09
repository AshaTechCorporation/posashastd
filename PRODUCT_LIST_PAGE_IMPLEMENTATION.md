# การปรับปรุงหน้า ProductListPage

## ภาพรวมการเปลี่ยนแปลง

ได้ปรับปรุงหน้า ProductListPage ให้ดึงข้อมูลเหมือนกับหน้า HomePage โดยใช้ฟังก์ชัน getlistCategory จาก HomeController และแสดงข้อมูลจริงจาก API

## ✅ การปรับปรุงหลัก

### 1. **ProductController Enhancement**

#### เพิ่มฟังก์ชันเหมือนกับ HomeController:
```dart
class ProductController extends GetxController {
  RxList<Product> products = <Product>[].obs;
  RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  RxString selectedCategoryCode = ''.obs;
  RxBool isConnected = false.obs;
  RxBool isLoading = false.obs;
  RxString searchQuery = ''.obs;

  // ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตและโหลดข้อมูล
  Future<void> checkConnectivityAndLoadData() async { ... }

  // ดึงข้อมูล Category (เหมือนกับ HomeController)
  Future<void> getlistCategory() async { ... }

  // ดึงข้อมูล Product ตาม Category (เหมือนกับ HomeController)
  Future<void> getProductByCategory({required int categoryId, required int branchId}) async { ... }

  // เลือก Category และโหลดสินค้า
  Future<void> selectCategory(String categoryCode) async { ... }

  // ค้นหาสินค้า
  List<Product> get filteredProducts { ... }
}
```

### 2. **ProductListPage Improvements**

#### การใช้ ProductController:
```dart
class _ProductListPageState extends State<ProductListPage> {
  late ProductController productController;

  @override
  void initState() {
    super.initState();
    log('🏠 ProductListPage initState called');
    
    // ลบ controller เก่าและสร้างใหม่
    if (Get.isRegistered<ProductController>()) {
      Get.delete<ProductController>();
    }
    productController = Get.put(ProductController());
  }
}
```

#### Dynamic Dropdown สำหรับหมวดหมู่:
```dart
child: Obx(() {
  if (productController.categories.isEmpty) {
    return const Text('กำลังโหลด...', style: TextStyle(color: Colors.white, fontSize: 16));
  }
  
  return DropdownButton<String>(
    value: productController.selectedCategoryCode.value.isNotEmpty 
        ? productController.selectedCategoryCode.value 
        : productController.categories.first['code'],
    items: productController.categories.map((category) {
      return DropdownMenuItem<String>(
        value: category['code'],
        child: Text(category['name'] ?? 'ไม่ระบุ'),
      );
    }).toList(),
    onChanged: (value) {
      if (value != null) {
        productController.selectCategory(value);
      }
    },
  );
}),
```

### 3. **Dynamic Content Display**

#### แท็บ "รายการสินค้าทั้งหมด":
```dart
case 0:
  return Obx(() {
    if (productController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    final products = productController.filteredProducts;
    if (products.isEmpty) {
      return const Center(
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
            Text('ไม่มีสินค้าในหมวดหมู่นี้'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: productController.refreshData,
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            leading: CircleAvatar(
              child: product.imageUrl != null
                  ? ClipOval(child: Image.network(product.imageUrl!))
                  : const Icon(Icons.shopping_bag),
            ),
            title: Text(product.name ?? 'ไม่ระบุชื่อสินค้า'),
            subtitle: Text(product.code ?? '-'),
            trailing: Text('฿${(product.price ?? 0).toStringAsFixed(2)}'),
          );
        },
      ),
    );
  });
```

#### แท็บ "หมวดหมู่":
```dart
case 1:
  return Obx(() {
    final categories = productController.categories;
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getCategoryColor(index),
            child: Text(category['name'][0].toUpperCase()),
          ),
          title: Text(category['name'] ?? 'ไม่ระบุ'),
          subtitle: Text('รหัส: ${category['code']}'),
          onTap: () {
            // เปลี่ยนไปแท็บรายการสินค้าและเลือกหมวดหมู่นี้
            setState(() => selectedTabIndex = 0);
            productController.selectCategory(category['code']);
          },
        );
      },
    );
  });
```

## 🎯 ฟีเจอร์ที่ได้รับ

### 1. **Real-time Data**
- ดึงข้อมูลหมวดหมู่และสินค้าจาก API จริง
- แสดงข้อมูลที่เป็นปัจจุบัน
- รองรับการ refresh ข้อมูล

### 2. **Dynamic Dropdown**
- แสดงหมวดหมู่จาก API ใน dropdown
- เปลี่ยนหมวดหมู่แล้วโหลดสินค้าใหม่
- แสดง "กำลังโหลด..." ขณะรอข้อมูล

### 3. **Interactive Product List**
- แสดงรายการสินค้าตามหมวดหมู่ที่เลือก
- แสดงรูปภาพ, ชื่อ, รหัส, และราคาสินค้า
- Pull-to-refresh สำหรับโหลดข้อมูลใหม่

### 4. **Interactive Category List**
- แสดงรายการหมวดหมู่ทั้งหมด
- กดเลือกหมวดหมู่แล้วไปแท็บสินค้า
- แสดงสีที่แตกต่างกันสำหรับแต่ละหมวดหมู่

### 5. **Loading States**
- แสดง CircularProgressIndicator ขณะโหลด
- แสดงข้อความเมื่อไม่มีข้อมูล
- Error handling และแสดง Snackbar

### 6. **Search Ready**
- เตรียมฟังก์ชัน filteredProducts สำหรับการค้นหา
- สามารถเพิ่ม search field ได้ในอนาคต

## 📱 การใช้งาน

### สำหรับผู้ใช้:
1. เปิดหน้า ProductListPage
2. รอโหลดข้อมูลหมวดหมู่และสินค้าจาก API
3. **แท็บ "รายการสินค้าทั้งหมด":**
   - ใช้ dropdown เลือกหมวดหมู่
   - ดูรายการสินค้าในหมวดหมู่ที่เลือก
   - Pull-to-refresh เพื่อโหลดข้อมูลใหม่
4. **แท็บ "หมวดหมู่":**
   - ดูรายการหมวดหมู่ทั้งหมด
   - กดเลือกหมวดหมู่เพื่อไปดูสินค้า

### การทำงานของระบบ:
1. **เริ่มต้น**: ProductController.checkConnectivityAndLoadData()
2. **โหลดหมวดหมู่**: getlistCategory() ดึงข้อมูลจาก API
3. **โหลดสินค้า**: getProductByCategory() ดึงสินค้าตามหมวดหมู่
4. **เลือกหมวดหมู่**: selectCategory() เปลี่ยนหมวดหมู่และโหลดสินค้าใหม่
5. **แสดงผล**: Obx() อัพเดท UI เมื่อข้อมูลเปลี่ยน

## 🔧 Dependencies ที่ใช้

### Packages:
```yaml
dependencies:
  get: ^4.6.6              # State management
  connectivity_plus: ^4.0.2 # Network connectivity check
```

### Models:
- Product
- Category (Map<String, dynamic>)

### Services:
- Homeservice.getCategory()
- Homeservice.getProduct()

### Controllers:
- ProductController (ใหม่ - เพิ่มฟังก์ชันจาก HomeController)

## ✅ สรุป

การปรับปรุงนี้ทำให้:
- หน้า ProductListPage ใช้ข้อมูลจริงจาก API เหมือนกับหน้า HomePage
- UI เป็น reactive และ interactive
- รองรับการเลือกหมวดหมู่และแสดงสินค้า
- มี loading states และ error handling ที่ดี
- โค้ดเป็นระเบียบและใช้ GetX pattern อย่างถูกต้อง
- ผู้ใช้สามารถดูและจัดการข้อมูลสินค้าได้อย่างสะดวก

## 🚀 การพัฒนาต่อ

### ฟีเจอร์ที่สามารถเพิ่มได้:
1. **Search Functionality**: เพิ่ม TextField สำหรับค้นหาสินค้า
2. **Product Details**: เพิ่มหน้ารายละเอียดสินค้าเมื่อกด
3. **Add/Edit Product**: เพิ่มฟังก์ชันเพิ่ม/แก้ไขสินค้า
4. **Category Management**: เพิ่มฟังก์ชันจัดการหมวดหมู่
5. **Sorting/Filtering**: เพิ่มการเรียงลำดับและกรองข้อมูล
