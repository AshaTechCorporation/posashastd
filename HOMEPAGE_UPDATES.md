# การปรับปรุงหน้า HomePage

## ภาพรวมการเปลี่ยนแปลง

ได้ปรับปรุงหน้า HomePage ตามความต้องการดังนี้:

### 1. ✅ เพิ่มการตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
- เพิ่ม `connectivity_plus` package
- ตรวจสอบการเชื่อมต่อก่อนเรียก API
- แสดงข้อความแจ้งเตือนเมื่อไม่มีอินเทอร์เน็ต

### 2. ✅ เปลี่ยน products จาก Map เป็น List<Product>
```dart
// เดิม
List<Map<String, dynamic>> products = [];

// ใหม่
List<Product> products = <Product>[].obs;
```

### 3. ✅ ปรับปรุงการแสดงสินค้า
- **แท็บ 1**: แสดงสินค้าจาก API (`getlistCategory()`)
- **แท็บอื่นๆ**: แสดงสินค้าจาก panels (ระบบเดิม)

### 4. ✅ ปรับปรุงการเพิ่มสินค้าลงตะกร้า
- รองรับ Product model
- เมื่อกดสินค้าตัวเดิม จะบวกจำนวน +1
- แสดงชื่อ, ราคา, และจำนวน

### 5. ✅ เพิ่มการแสดงยอดรวมราคา
- แสดงยอดรวมก่อนปุ่มชำระเงิน
- คำนวณจากราคา × จำนวนของทุกรายการ

## ไฟล์ที่แก้ไข

### `lib/D2S/home/homePage.dart`

#### การเพิ่ม imports:
```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:posashastd/models/product.dart';
```

#### การเพิ่มตัวแปร:
```dart
List<Product> products = <Product>[].obs;
bool isConnected = false;
```

#### ฟังก์ชันใหม่:
```dart
Future<void> _checkConnectivityAndLoadData() async {
  // ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
  final connectivityResult = await Connectivity().checkConnectivity();
  isConnected = !connectivityResult.contains(ConnectivityResult.none);
  
  if (isConnected) {
    await getlistCategory();
  } else {
    // แสดงข้อความแจ้งเตือน
  }
}
```

#### การปรับปรุง getProductByCategory:
```dart
// แปลงข้อมูลเป็น List<Product>
final List<Map<String, dynamic>> parsedProducts = List<Map<String, dynamic>>.from(rawData);
final List<Product> productList = parsedProducts.map((productData) => Product.fromJson(productData)).toList();
setState(() {
  products = productList;
});
```

#### การปรับปรุง addToCart:
```dart
void addToCart(Product product) {
  setState(() {
    final existingIndex = cartItems.indexWhere((item) => item['id'] == product.id);
    
    if (existingIndex >= 0) {
      // บวกจำนวน +1
      final currentQty = cartItems[existingIndex]['qty'] ?? 1;
      cartItems[existingIndex]['qty'] = currentQty + 1;
    } else {
      // เพิ่มรายการใหม่
      final newItem = {
        'id': product.id,
        'name': product.name ?? 'ไม่มีชื่อ',
        'price': product.price ?? 0,
        'qty': 1,
      };
      cartItems.add(newItem);
    }
  });
}
```

#### การปรับปรุง _buildGridContent:
```dart
Widget _buildGridContent(double width, double height) {
  if (_tabController.index == 0) {
    // แท็บ 1: แสดงสินค้าจาก API
    return GridView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            addToCart(product); // เพิ่มลงตะกร้าเมื่อกด
          },
          child: Card(
            // แสดงรูป, ชื่อ, ราคา
          ),
        );
      },
    );
  } else {
    // แท็บอื่นๆ: ใช้ระบบเดิม (panels)
    return GetX<HomeController>(...);
  }
}
```

#### การเพิ่มยอดรวมราคา:
```dart
// แสดงยอดรวมราคา
if (cartItems.isNotEmpty)
  Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('ยอดรวม:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
          '฿${cartItems.fold<double>(0, (sum, item) => sum + ((item['price'] ?? 0) * (item['qty'] ?? 1))).toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ],
    ),
  ),
```

## การใช้งาน

### สำหรับผู้ใช้:
1. เปิดแอป → ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
2. หากมีอินเทอร์เน็ต → โหลดข้อมูลสินค้าจาก API
3. **แท็บ 1**: แสดงสินค้าจาก API
   - กดสินค้า → เพิ่มลงตะกร้า
   - กดสินค้าซ้ำ → บวกจำนวน +1
4. **แท็บอื่นๆ**: แสดงสินค้าจาก panels (ระบบเดิม)
5. ดูยอดรวมราคาก่อนชำระเงิน

### การทดสอบ:
1. ทดสอบการเชื่อมต่ออินเทอร์เน็ต (เปิด/ปิด WiFi)
2. ทดสอบการเพิ่มสินค้าลงตะกร้า
3. ทดสอบการบวกจำนวนเมื่อกดสินค้าซ้ำ
4. ทดสอบการแสดงยอดรวมราคา
5. ทดสอบการสลับระหว่างแท็บต่างๆ

## Dependencies ที่เพิ่ม
```yaml
dependencies:
  connectivity_plus: ^6.1.4
```

## หมายเหตุ
- ใช้ Product model สำหรับแท็บ 1
- แท็บอื่นๆ ยังใช้ระบบ panels เดิม
- รองรับการแสดงรูปสินค้าจาก URL
- มี error handling สำหรับการโหลดรูป
- แสดงยอดรวมแบบ real-time
