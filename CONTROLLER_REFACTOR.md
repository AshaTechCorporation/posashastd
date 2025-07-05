# การย้ายฟังก์ชันไปยัง HomeController

## ภาพรวมการเปลี่ยนแปลง

ได้ย้ายฟังก์ชันหลักจากหน้า HomePage ไปยัง HomeController เพื่อให้การจัดการ state และ business logic อยู่ในที่เดียวกัน

## ✅ ฟังก์ชันที่ย้ายไปยัง HomeController

### 1. **ตัวแปร State**
```dart
// เพิ่มใน HomeController
List<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
List<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
RxString selectedCategoryCode = ''.obs;
RxBool isConnected = false.obs;
```

### 2. **checkConnectivityAndLoadData()**
- ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
- เรียก `getlistCategory()` หากมีการเชื่อมต่อ
- แสดง Snackbar หากไม่มีอินเทอร์เน็ต

### 3. **getlistCategory()**
- ดึงข้อมูล categories จาก API
- เพิ่ม "ทั้งหมด" เป็นตัวเลือกแรก
- เรียก `getProductByCategory()` อัตโนมัติ

### 4. **getProductByCategory()**
- ดึงข้อมูลสินค้าตาม category
- แปลงข้อมูลเป็น `List<Product>`
- อัพเดท `products` observable

### 5. **addToCart()**
- เพิ่มสินค้าลงตะกร้า
- บวกจำนวนหากสินค้าซ้ำ
- เรียก `update()` เพื่ออัพเดท UI

### 6. **ฟังก์ชันเสริม**
```dart
// คำนวณยอดรวมราคา
double get totalPrice {
  return cartItems.fold<double>(0, (sum, item) => 
    sum + ((item['price'] ?? 0) * (item['qty'] ?? 1)));
}

// เคลียร์ตะกร้า
void clearCart() {
  cartItems.clear();
}
```

## ✅ การปรับปรุงหน้า HomePage

### 1. **ลดตัวแปร State**
```dart
// เดิม
class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> categories = [];
  String? selectedCategoryCode;
  List<Product> products = <Product>[].obs;
  List<Map<String, dynamic>> cartItems = [];
  bool isConnected = false;
  // ...

// ใหม่
class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> tabs = ['แท็บ 1'];
  final HomeController homeController = Get.put(HomeController());
}
```

### 2. **ปรับปรุง initState**
```dart
@override
void initState() {
  super.initState();
  _tabController = TabController(length: tabs.length, vsync: this);
  SystemChrome.setPreferredOrientations([...]);
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await homeController.checkConnectivityAndLoadData(); // ใช้ controller
  });
}
```

### 3. **ปรับปรุง _buildGridContent**
```dart
// แท็บ 1: ใช้ GetX<HomeController>
return GetX<HomeController>(
  builder: (controller) {
    return GridView.builder(
      itemCount: controller.products.length,
      itemBuilder: (context, index) {
        final product = controller.products[index];
        return GestureDetector(
          onTap: () {
            controller.addToCart(product); // ใช้ controller
          },
          // ...
        );
      },
    );
  },
);
```

### 4. **ปรับปรุง Dropdown**
```dart
GetX<HomeController>(
  builder: (controller) {
    return DropdownButton<String>(
      value: controller.selectedCategoryCode.value.isEmpty ? null : controller.selectedCategoryCode.value,
      onChanged: (value) async {
        if (value != null) {
          controller.selectedCategoryCode.value = value;
          final selectedCategory = controller.categories.firstWhere(...);
          await controller.getProductByCategory(categoryId: categoryId, branchId: 0);
        }
      },
      items: controller.categories.map((category) => ...).toList(),
    );
  },
);
```

### 5. **ปรับปรุงตะกร้าสินค้า**
```dart
// ปุ่มเคลียร์
GetX<HomeController>(
  builder: (controller) {
    return ListTile(
      trailing: TextButton.icon(
        onPressed: () {
          controller.clearCart(); // ใช้ controller
        },
        // ...
      ),
    );
  },
);

// รายการสินค้า
GetX<HomeController>(
  builder: (controller) {
    return controller.cartItems.isEmpty
        ? const Center(child: Text('ยังไม่มีสินค้า'))
        : ListView.builder(
            itemCount: controller.cartItems.length,
            itemBuilder: (context, index) {
              final item = controller.cartItems[index];
              // ...
            },
          );
  },
);

// ยอดรวม
GetX<HomeController>(
  builder: (controller) {
    return controller.cartItems.isNotEmpty
        ? Container(
            child: Text('฿${controller.totalPrice.toStringAsFixed(2)}'),
          )
        : const SizedBox.shrink();
  },
);
```

## 🎯 ประโยชน์ที่ได้รับ

### 1. **Separation of Concerns**
- Business logic อยู่ใน Controller
- UI logic อยู่ใน Widget
- ง่ายต่อการ maintain และ test

### 2. **Reactive UI**
- ใช้ GetX observable (`obs`, `RxString`, `RxBool`)
- UI อัพเดทอัตโนมัติเมื่อ state เปลี่ยน
- ไม่ต้องเรียก `setState()` ใน HomePage

### 3. **Code Reusability**
- Controller สามารถใช้ร่วมกับหน้าอื่นได้
- ฟังก์ชันสามารถเรียกใช้จากที่ไหนก็ได้

### 4. **Better State Management**
- State ทั้งหมดอยู่ในที่เดียว
- ง่ายต่อการ debug และ track changes

## 📱 การใช้งาน

### สำหรับผู้ใช้:
- การใช้งานเหมือนเดิมทุกประการ
- ประสิทธิภาพดีขึ้นเนื่องจาก reactive updates

### สำหรับนักพัฒนา:
```dart
// เข้าถึง controller จากที่ไหนก็ได้
final controller = Get.find<HomeController>();

// เรียกใช้ฟังก์ชัน
await controller.getlistCategory();
controller.addToCart(product);
controller.clearCart();

// เข้าถึง state
print(controller.cartItems.length);
print(controller.totalPrice);
print(controller.isConnected.value);
```

## 🔧 ไฟล์ที่แก้ไข

1. **`lib/D2S/home/home_controller.dart`**
   - เพิ่มตัวแปร state
   - เพิ่มฟังก์ชัน business logic
   - เพิ่ม imports ที่จำเป็น

2. **`lib/D2S/home/homePage.dart`**
   - ลดตัวแปร state
   - ใช้ GetX<HomeController> ในทุกส่วน
   - ลบฟังก์ชันที่ย้ายไป controller แล้ว
   - ลบ imports ที่ไม่ใช้

## ✅ สรุป
การย้ายฟังก์ชันไปยัง HomeController ทำให้:
- โค้ดเป็นระเบียบมากขึ้น
- ง่ายต่อการ maintain
- UI reactive และ responsive
- ประสิทธิภาพดีขึ้น
- ยังคงการทำงานเดิมทุกอย่าง
