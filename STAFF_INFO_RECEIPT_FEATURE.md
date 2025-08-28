# เพิ่มการแสดงชื่อพนักงานในใบเสร็จ

## ภาพรวมฟีเจอร์

เพิ่มการเรียก API `checkLogin` เพื่อดึงข้อมูลพนักงานและนำ firstName และ lastName ไปแสดงในใบเสร็จแทน "unknown unknown"

## ✅ การเพิ่มฟีเจอร์

### 1. **ปรับปรุง HomeController.checkLogin()**

#### ก่อนแก้ไข:
```dart
Future<void> checkLogin() async {
  try {
    final data = await Homeservice.checkLogin();
    log('✅ Login successful, token: ${data}');
  } catch (e) {
    log('❌ Error checking login: $e');
  }
}
```

#### หลังแก้ไข:
```dart
Future<Map<String, dynamic>?> checkLogin() async {
  try {
    final data = await Homeservice.checkLogin();
    log('✅ Login successful, data: ${data}');
    return data;
  } catch (e) {
    log('❌ Error checking login: $e');
    return null;
  }
}
```

### 2. **เพิ่มตัวแปรใน PaymentPageD2s**

```dart
class _PaymentPageD2sState extends State<PaymentPageD2s> {
  double receivedAmount = 0;
  bool isPaid = false;
  double totalDiscountApplied = 0;
  int currentPaymentMethodId = 1;
  String staffName = 'unknown unknown'; // ✅ เก็บชื่อพนักงานจาก API
  late HomeController homeController;
  late PrinterController printerController;
  // ...
}
```

### 3. **เพิ่มการเรียก API ใน initState**

```dart
WidgetsBinding.instance.addPostFrameCallback((_) async {
  log('⏰ PostFrameCallback: loading data');
  await homeController.checkConnectivityAndLoadData();
  log('✅ Data loading completed');
  print(homeController.currentShiftId.value);

  // ✅ เรียก checkLogin เพื่อดึงข้อมูลพนักงาน
  await _loadStaffInfo();

  // หลังจากโหลดข้อมูลเสร็จ ให้เช็คพาเนลและสร้างแท็บ
});
```

### 4. **เพิ่มฟังก์ชัน _loadStaffInfo**

```dart
// ✅ โหลดข้อมูลพนักงานจาก API
Future<void> _loadStaffInfo() async {
  try {
    final staffData = await homeController.checkLogin();
    if (staffData != null && mounted) {
      setState(() {
        final firstName = staffData['firstName'] ?? '';
        final lastName = staffData['lastName'] ?? '';
        staffName = '$firstName $lastName'.trim();
        if (staffName.isEmpty) {
          staffName = 'unknown unknown';
        }
      });
      log('✅ Staff info loaded: $staffName');
    }
  } catch (e) {
    log('❌ Error loading staff info: $e');
    // ใช้ค่า default ถ้าเกิด error
    if (mounted) {
      setState(() {
        staffName = 'unknown unknown';
      });
    }
  }
}
```

### 5. **ปรับปรุงการเรียกใช้ฟังก์ชันปริ๊น**

#### ก่อนแก้ไข:
```dart
await printReceiptFromCartItems(
  widget.cartItems,
  receivedAmount: receivedAmount,
  changeAmount: changeAmount,
  discountAmount: totalDiscountApplied > 0 ? totalDiscountApplied : null,
  paymentMethod: _getPaymentMethodName(),
);
```

#### หลังแก้ไข:
```dart
await printReceiptFromCartItems(
  widget.cartItems,
  receivedAmount: receivedAmount,
  changeAmount: changeAmount,
  discountAmount: totalDiscountApplied > 0 ? totalDiscountApplied : null,
  paymentMethod: _getPaymentMethodName(),
  staffName: staffName, // ✅ ส่งชื่อพนักงาน
);
```

### 6. **ปรับปรุงฟังก์ชัน printReceiptFromCartItems**

#### เพิ่ม Parameter:
```dart
Future<void> printReceiptFromCartItems(
  List<Map<String, dynamic>> cartItems, {
  double? receivedAmount,
  double? changeAmount,
  double? discountAmount,
  String? paymentMethod,
  String? staffName, // ✅ เพิ่ม parameter ชื่อพนักงาน
}) async {
```

#### แก้ไขการแสดงผล:
```dart
// 👨‍💼 Staff
await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
final staffDisplayName = staffName ?? 'unknown unknown';
await SunmiPrinter.printText('พนักงาน: $staffDisplayName\n');
await SunmiPrinter.printText('ระบบขายหน้าร้าน: POS 4\n');
await SunmiPrinter.printText('-' * 42 + '\n');
```

## 🔄 Flow การทำงาน

### 1. **การโหลดข้อมูลพนักงาน**

```
PaymentPageD2s เปิด
    ↓
initState() เรียก PostFrameCallback
    ↓
เรียก homeController.checkConnectivityAndLoadData()
    ↓
เรียก _loadStaffInfo()
    ↓
เรียก homeController.checkLogin()
    ↓
เรียก Homeservice.checkLogin()
    ↓
ได้ข้อมูล: { "firstName": "Shop1", "lastName": "Shop1", ... }
    ↓
setState() อัปเดต staffName = "Shop1 Shop1"
    ↓
พร้อมใช้งานในการปริ๊น
```

### 2. **การจัดการ Error**

```
API Call ล้มเหลว
    ↓
catch (e) ใน _loadStaffInfo()
    ↓
log error message
    ↓
setState() ตั้งค่า staffName = "unknown unknown"
    ↓
ใช้ค่า default ในการปริ๊น
```

## 🎯 ตัวอย่างข้อมูลจาก API

### Response จาก `/api/auth/me`:
```json
{
  "id": 2,
  "createdAt": "2025-06-23T10:46:00.822Z",
  "updatedAt": "2025-08-28T07:54:10.197Z",
  "deletedAt": null,
  "username": "shop",
  "email": null,
  "code": "SHOP1",
  "firstName": "Shop1",
  "lastName": "Shop1",
  "phoneNumber": null,
  "isActive": true,
  "confirmed": true,
  "role": null
}
```

### การประมวลผลข้อมูล:
```dart
final firstName = staffData['firstName'] ?? ''; // "Shop1"
final lastName = staffData['lastName'] ?? '';   // "Shop1"
staffName = '$firstName $lastName'.trim();      // "Shop1 Shop1"
```

## 📄 ผลลัพธ์ในใบเสร็จ

### ก่อนแก้ไข:
```
              พิซากพ
           เปิด 24 ชั่วโมง

พนักงาน: unknown unknown
ระบบขายหน้าร้าน: POS 4
------------------------------------------
```

### หลังแก้ไข:
```
              พิซากพ
           เปิด 24 ชั่วโมง

พนักงาน: Shop1 Shop1
ระบบขายหน้าร้าน: POS 4
------------------------------------------
```

### กรณี Error หรือข้อมูลว่าง:
```
              พิซากพ
           เปิด 24 ชั่วโมง

พนักงาน: unknown unknown
ระบบขายหน้าร้าน: POS 4
------------------------------------------
```

## 🔧 Technical Details

### 1. **API Integration**

#### Homeservice.checkLogin():
```dart
static Future checkLogin() async {
  final _authService = AuthService();
  final url = Uri.https(publicUrl, '/api/auth/me');
  var headers = {
    'Authorization': 'Bearer ${_authService.currentToken}',
    'Content-Type': 'application/json'
  };
  final response = await http.get(headers: headers, url);
  if (response.statusCode == 200) {
    final data = convert.jsonDecode(response.body);
    return data;
  } else {
    final data = convert.jsonDecode(response.body);
    throw Exception(data['message']);
  }
}
```

### 2. **Error Handling**

#### Network Error:
- ไม่มีการเชื่อมต่ออินเทอร์เน็ต
- Server ไม่ตอบสนอง
- Timeout

#### Authentication Error:
- Token หมดอายุ
- Token ไม่ถูกต้อง
- User ไม่มีสิทธิ์

#### Data Error:
- firstName หรือ lastName เป็น null
- Response format ไม่ถูกต้อง
- ข้อมูลว่างเปล่า

### 3. **State Management**

#### Loading States:
```dart
// เริ่มต้น
String staffName = 'unknown unknown';

// กำลังโหลด
// ไม่มี loading indicator เพราะทำงานใน background

// สำเร็จ
staffName = 'Shop1 Shop1';

// ล้มเหลว
staffName = 'unknown unknown'; // คืนค่า default
```

## 🚀 การพัฒนาต่อ

### ฟีเจอร์ที่สามารถเพิ่มได้:

1. **Cache Staff Info**:
   ```dart
   // เก็บข้อมูลใน SharedPreferences
   final prefs = await SharedPreferences.getInstance();
   await prefs.setString('staff_name', staffName);
   ```

2. **Loading Indicator**:
   ```dart
   bool isLoadingStaff = true;
   // แสดง loading ขณะดึงข้อมูล
   ```

3. **Staff Role Display**:
   ```dart
   final role = staffData['role'] ?? '';
   await SunmiPrinter.printText('ตำแหน่ง: $role\n');
   ```

4. **Staff Code Display**:
   ```dart
   final code = staffData['code'] ?? '';
   await SunmiPrinter.printText('รหัสพนักงาน: $code\n');
   ```

### การปรับปรุงเพิ่มเติม:

1. **Retry Mechanism**:
   ```dart
   int retryCount = 0;
   const maxRetries = 3;
   
   while (retryCount < maxRetries) {
     try {
       final data = await homeController.checkLogin();
       break;
     } catch (e) {
       retryCount++;
       if (retryCount >= maxRetries) throw e;
       await Future.delayed(Duration(seconds: 2));
     }
   }
   ```

2. **Offline Support**:
   ```dart
   // ใช้ข้อมูลที่เก็บไว้ล่าสุดเมื่อออฟไลน์
   final cachedStaffName = prefs.getString('staff_name');
   if (cachedStaffName != null) {
     staffName = cachedStaffName;
   }
   ```

3. **Real-time Updates**:
   ```dart
   // อัปเดตข้อมูลเมื่อมีการเปลี่ยนแปลง
   Timer.periodic(Duration(minutes: 5), (timer) {
     _loadStaffInfo();
   });
   ```

## ✅ ผลลัพธ์

### 1. **Functionality**
- ✅ แสดงชื่อพนักงานจริงในใบเสร็จ
- ✅ ดึงข้อมูลจาก API `/api/auth/me`
- ✅ จัดการ error และใช้ค่า default
- ✅ อัปเดต UI เมื่อได้ข้อมูล

### 2. **User Experience**
- ✅ ใบเสร็จแสดงข้อมูลพนักงานที่ถูกต้อง
- ✅ ไม่มีการหน่วงเวลาในการใช้งาน
- ✅ ทำงานใน background
- ✅ Fallback เมื่อเกิด error

### 3. **Technical Quality**
- ✅ Error handling ครบถ้วน
- ✅ State management ที่ถูกต้อง
- ✅ API integration ที่เสถียร
- ✅ Memory safe (mounted check)

### 4. **Business Value**
- ✅ เพิ่มความน่าเชื่อถือของใบเสร็จ
- ✅ ติดตามพนักงานที่ทำการขาย
- ✅ รองรับการตรวจสอบและ audit
- ✅ เป็นมาตรฐานของใบเสร็จ

## 📝 หมายเหตุ

### Best Practices ที่ใช้:
1. **Async/Await Pattern**: ใช้ async programming อย่างถูกต้อง
2. **Error Handling**: จัดการ error ทุกระดับ
3. **State Management**: ใช้ setState และ mounted check
4. **API Integration**: ใช้ existing service layer

### การใช้งาน:
- ข้อมูลจะถูกโหลดเมื่อเปิดหน้า PaymentPageD2s
- ใช้ข้อมูลล่าสุดในการปริ๊นใบเสร็จ
- Fallback เป็น "unknown unknown" เมื่อเกิด error
- ไม่ส่งผลกระทบต่อการทำงานหลัก

### Performance Considerations:
- API call ทำงานใน background
- ไม่ block UI thread
- ใช้ PostFrameCallback เพื่อไม่รบกวน initial render
- Cache ข้อมูลใน memory สำหรับการใช้งานซ้ำ
