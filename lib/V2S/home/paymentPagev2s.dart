import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/V2S/home/saleSummaryPagev2s.dart';
import 'package:posashastd/D2S/controllers/home_controller.dart';
import 'package:posashastd/D2S/controllers/order_controller.dart';
import 'package:posashastd/D2S/controllers/printer_controller.dart';
import 'package:posashastd/D2S/home/widgets/PaymentConfirmDialog.dart';
import 'package:posashastd/helpers/mix_match_multi_units.dart';
import 'package:posashastd/helpers/printReceiptFromCartItemsV2s.dart';
import 'package:posashastd/services/homeService.dart';
import 'package:posashastd/constants.dart';

class PaymentPagev2s extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> items;

  PaymentPagev2s({super.key, required this.totalAmount, required this.items});

  @override
  State<PaymentPagev2s> createState() => _PaymentPagev2sState();
}

class _PaymentPagev2sState extends State<PaymentPagev2s> {
  double receivedAmount = 0;
  bool isPaid = false;
  String? orderReceiptNumber;

  // ตัวแปรสำหรับจัดการส่วนลด
  double? selectedDiscountAmount;
  double discountAmount = 0;
  double totalDiscountApplied = 0;
  int currentPaymentMethodId = 1;
  String staffName = 'unknown unknown';
  bool isCalculatingDiscount = true; // ✅ เริ่มต้นด้วย true เพื่อแสดง loading ทันที
  late HomeController homeController;
  late OrderController orderController;
  late PrinterController printerController;

  @override
  void initState() {
    super.initState();
    log('🏠 PaymentPagev2s initState called');

    // ลบ controller เก่าและสร้างใหม่
    if (Get.isRegistered<HomeController>()) {
      log('🗑️ Deleting existing HomeController');
      Get.delete<HomeController>();
    }
    log('🆕 Creating new HomeController');
    homeController = Get.put(HomeController());

    // เชื่อมต่อ OrderController
    try {
      orderController = Get.find<OrderController>();
      log('✅ Found existing OrderController with ${orderController.discounts.length} discounts');
    } catch (e) {
      log('❌ OrderController not found, creating new one');
      orderController = Get.put(OrderController());
    }

    // เชื่อมต่อ PrinterController
    try {
      printerController = Get.find<PrinterController>();
      log('✅ Found existing PrinterController');
    } catch (e) {
      log('❌ PrinterController not found, creating new one');
      printerController = Get.put(PrinterController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      log('⏰ PostFrameCallback: loading data');

      // ✅ เช็คสถานะ shift ก่อน
      await homeController.checkShiftStatus();
      log('✅ Shift status checked - currentShiftId: ${homeController.currentShiftId.value}');

      await homeController.checkConnectivityAndLoadData();
      log('✅ Data loading completed');

      // โหลดข้อมูลส่วนลด
      log('🎯 Loading discount data...');
      await orderController.checkDiscount();
      log('✅ Discount data loaded: ${orderController.discounts.length} discounts');

      // แสดงรายละเอียดส่วนลดที่โหลดมา
      for (int i = 0; i < orderController.discounts.length; i++) {
        final discount = orderController.discounts[i];
        log('   Loaded Discount $i: ${discount.toString()}');
      }

      await _loadStaffInfo();

      // เพิ่ม delay เล็กน้อยเพื่อให้แน่ใจว่าข้อมูลโหลดเสร็จ
      await Future.delayed(const Duration(milliseconds: 100));
      await _calculateAutoDiscount();
    });
  }

  // คำนวณยอดรวมเดิม (ก่อนหักส่วนลด)
  double get originalTotal {
    return widget.items.fold(0.0, (sum, item) {
      final price = item['price'] ?? 0;
      final qty = item['qty'] ?? 1;
      return sum + (price * qty);
    });
  }

  // คำนวณยอดรวมหลังหักส่วนลด
  double calculateTotalWithDiscount() {
    final total = originalTotal - totalDiscountApplied;
    return total < 0 ? 0 : total;
  }

  // คำนวณส่วนลดจาก mix_match_multi_units
  Future<double> calculateDiscountFromMixMatch() async {
    log('🔍 calculateDiscountFromMixMatch called');

    // ✅ loading state จะแสดงอยู่แล้วตั้งแต่เริ่มต้น
    // ไม่ต้องตั้งค่าใหม่ที่นี่

    try {
      if (orderController.discounts.isEmpty) {
        log('⚠️ No discounts available in orderController');
        return 0.0;
      }

      if (widget.items.isEmpty) {
        log('⚠️ No items in cart for discount calculation');
        return 0.0;
      }

      log('📦 Sending to mix_match_multi_units:');
      log('   cartItems count: ${widget.items.length}');
      log('   discounts count: ${orderController.discounts.length}');

      // ✅ เพิ่ม delay เล็กน้อยเพื่อให้ UI อัปเดต
      await Future.delayed(const Duration(milliseconds: 100));

      // แสดงรายละเอียดสินค้าในตะกร้า
      for (int i = 0; i < widget.items.length; i++) {
        final item = widget.items[i];
        log('   Item $i: id=${item['id']}, name=${item['name']}, qty=${item['qty']}, price=฿${item['price']}');
      }

      // แสดงรายละเอียดส่วนลด
      for (int i = 0; i < orderController.discounts.length; i++) {
        final discount = orderController.discounts[i];
        log(
          '   Discount $i: id=${discount['id']}, name=${discount['name']}, stepQty=${discount['stepQty']}, benefitType=${discount['benefitType']}, benefitValue=${discount['benefitValue']}',
        );
        log('     isActive=${discount['isActive']}, items=${discount['items']}');

        // ตรวจสอบว่าสินค้าในตะกร้าตรงกับ discount rule หรือไม่
        if (discount['items'] != null) {
          final discountItems = discount['items'] as List;
          log('     Discount items count: ${discountItems.length}');
          for (int j = 0; j < discountItems.length; j++) {
            final discountItem = discountItems[j];
            log('       Discount item $j: productId=${discountItem['product']?['id']}, name=${discountItem['product']?['name']}');
          }

          // เช็คว่าสินค้าในตะกร้าตรงกับ discount items หรือไม่
          for (final cartItem in widget.items) {
            final cartProductId = cartItem['id'];
            Map<String, dynamic>? matchingDiscountItem;
            try {
              matchingDiscountItem = discountItems.firstWhere((item) => item['product']?['id'] == cartProductId);
            } catch (e) {
              matchingDiscountItem = null;
            }

            if (matchingDiscountItem != null) {
              log('       ✅ Found matching product: cartId=$cartProductId, qty=${cartItem['qty']}');
            } else {
              log('       ❌ No match for cartId=$cartProductId');

              // ลองเปรียบเทียบแบบ string
              try {
                matchingDiscountItem = discountItems.firstWhere((item) => item['product']?['id'].toString() == cartProductId.toString());
                log('       ✅ Found matching product (string comparison): cartId=$cartProductId');
              } catch (e) {
                log('       ❌ Still no match even with string comparison');
              }
            }
          }
        }
      }

      log('🔧 Calling calculateDiscountFromRules...');
      final calculatedDiscount = calculateDiscountFromRules(cartItems: widget.items, discounts: orderController.discounts);

      log('🎯 Calculated discount from rules: ฿$calculatedDiscount');
      return calculatedDiscount;
    } catch (e) {
      log('❌ Error calculating discount from rules: $e');
      log('❌ Stack trace: ${StackTrace.current}');
      return 0.0;
    } finally {
      // ✅ ซ่อน loading state เมื่อเสร็จสิ้น
      if (mounted) {
        setState(() {
          isCalculatingDiscount = false;
        });
      }
    }
  }

  // คำนวณส่วนลดอัตโนมัติเมื่อเข้าหน้า
  Future<void> _calculateAutoDiscount() async {
    log('🔍 _calculateAutoDiscount called');
    log('   orderController.discounts.length: ${orderController.discounts.length}');
    log('   widget.items.length: ${widget.items.length}');
    log('   originalTotal: ฿$originalTotal');

    // แสดงรายละเอียดสินค้าในตะกร้า
    log('📦 Cart items details:');
    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      log('   Item $i: id=${item['id']}, name=${item['name']}, qty=${item['qty']}, price=฿${item['price']}');
    }

    if (orderController.discounts.isEmpty) {
      log('⚠️ No discounts available, skipping auto discount calculation');
      return;
    }

    if (widget.items.isEmpty) {
      log('⚠️ No items in cart, skipping auto discount calculation');
      return;
    }

    log('🎯 Starting auto discount calculation...');
    final autoDiscount = await calculateDiscountFromMixMatch();
    log('🎯 Auto discount result: ฿$autoDiscount');

    if (autoDiscount > 0) {
      setState(() {
        totalDiscountApplied = autoDiscount;
        discountAmount = totalDiscountApplied;
      });
      log('💰 Auto applied discount on page load: ฿$autoDiscount');
      log('💰 totalDiscountApplied is now: ฿$totalDiscountApplied');
      log('💰 Final total after discount: ฿${calculateTotalWithDiscount()}');
    } else {
      log('ℹ️ No auto discount applied (discount = 0)');
      log('ℹ️ Possible reasons:');
      log('   - No matching products in discount rules');
      log('   - Quantity not enough for discount');
      log('   - Discount rules not active');
    }
  }

  // จัดการการลดราคาเพิ่มเติม
  void handleDiscountSelection(double amount) {
    setState(() {
      final currentTotal = calculateTotalWithDiscount();

      if (currentTotal > 0) {
        final discountToApply = amount > currentTotal ? currentTotal : amount;
        totalDiscountApplied += discountToApply;
        discountAmount = totalDiscountApplied;

        log('💰 Applied additional manual discount: ฿$discountToApply, Total discount: ฿$totalDiscountApplied');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลดเพิ่ม ฿${discountToApply.toStringAsFixed(0)} (รวมลดแล้ว ฿${totalDiscountApplied.toStringAsFixed(0)})'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        log('⚠️ Cannot apply more discount, total is already 0');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถลดเพิ่มได้ ยอดเป็น 0 แล้ว'), backgroundColor: Colors.orange, duration: Duration(seconds: 2)),
        );
      }
    });
  }

  // เคลียร์ส่วนลดทั้งหมด
  Future<void> clearAllDiscounts() async {
    setState(() {
      selectedDiscountAmount = null;
      discountAmount = 0;
      totalDiscountApplied = 0;
      isCalculatingDiscount = true; // ✅ แสดง loading เมื่อเคลียร์ส่วนลด

      log('🧹 Cleared all discounts');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('เคลียร์ส่วนลดแล้ว'), backgroundColor: Colors.green, duration: Duration(seconds: 1)));
    });

    await _calculateAutoDiscount();
  }

  // โหลดข้อมูลพนักงานจาก API
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
      if (mounted) {
        setState(() {
          staffName = 'unknown unknown';
        });
      }
    }
  }

  // ได้ชื่อวิธีการชำระเงินจาก paymentMethodId
  String _getPaymentMethodName() {
    switch (currentPaymentMethodId) {
      case 1:
        return 'เงินสด';
      case 2:
        return 'โอน';
      case 3:
        return 'เครดิต';
      default:
        return 'เงินสด';
    }
  }

  // ✅ เช็คเครื่องปริ๊นเตอร์และปริ๊นใบเสร็จ
  Future<void> checkPrinterAndPrint() async {
    try {
      log('🖨️ Starting printer check and print process...');

      // ✅ ใช้ฟังก์ชันใหม่ที่ตรวจสอบและเชื่อมต่อปริ๊นเตอร์อัตโนมัติ
      final isConnected = await printerController.checkAndReconnectPrinter(showProgress: true);

      if (!isConnected) {
        log('❌ Cannot connect to printer after reconnection attempts');
        _showNoPrinterDialog(); // ใช้ dialog ไม่มีปริ๊นเตอร์แทน
        return;
      }

      log('✅ Printer is connected, proceeding to print...');

      // ดำเนินการปริ๊น
      final defaultPrinter = printerController.getDefaultPrinter();
      if (defaultPrinter != null) {
        await _printToDefaultPrinter(defaultPrinter);
        log('✅ Print process completed successfully');
      } else {
        log('❌ Default printer not found after connection check');
        _showNoPrinterDialog();
      }
    } catch (e) {
      log('❌ Error in checkPrinterAndPrint: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาดในการปริ๊น: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // ✅ หาปริ๊นเตอร์เริ่มต้น
  PrinterInfo? _getDefaultPrinter() {
    try {
      return printerController.savedPrinters.firstWhere((printer) => printer.isDefault);
    } catch (e) {
      log('No default printer found: $e');
      return null;
    }
  }

  // ✅ แสดง dialog เมื่อไม่พบปริ๊นเตอร์
  void _showNoPrinterDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('ไม่พบปริ๊นเตอร์'),
            content: const Text('กรุณาตั้งค่าปริ๊นเตอร์เริ่มต้นในหน้าการตั้งค่า'),
            actions: [TextButton(onPressed: () => Get.back(), child: const Text('ปิด'))],
          ),
    );
  }

  // ✅ แสดง dialog เมื่อเชื่อมต่อปริ๊นเตอร์ไม่ได้
  void _showPrinterConnectionErrorDialog(PrinterInfo printer) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('เชื่อมต่อปริ๊นเตอร์ไม่ได้'),
            content: Text('ไม่สามารถเชื่อมต่อกับปริ๊นเตอร์ ${printer.name} ได้\nกรุณาตรวจสอบการเชื่อมต่อ'),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('ปิด')),
              ElevatedButton(
                onPressed: () async {
                  Get.back();
                  // ลองทดสอบการเชื่อมต่อใหม่
                  await printerController.testPrinterConnection(printer);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('ทดสอบใหม่', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  // ✅ ปริ๊นไปยังปริ๊นเตอร์เริ่มต้น
  Future<void> _printToDefaultPrinter(PrinterInfo printer) async {
    try {
      log('🖨️ Printing to ${printer.name} (${printer.type})...');

      final total = calculateTotalWithDiscount();
      final changeAmount = receivedAmount - total;

      // ✅ ส่งข้อมูลเพิ่มเติมไปยังฟังก์ชันปริ๊น
      await printReceiptFromCartItemsV2s(
        widget.items,
        receivedAmount: receivedAmount,
        changeAmount: changeAmount,
        discountAmount: totalDiscountApplied > 0 ? totalDiscountApplied : null,
        paymentMethod: _getPaymentMethodName(),
        staffName: staffName,
        receiptNumber: orderReceiptNumber, // ✅ ส่งเลขที่ใบเสร็จไปด้วย
      );

      log('✅ Print completed successfully');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ปริ๊นใบเสร็จไปยัง ${printer.name} สำเร็จ'), backgroundColor: Colors.green));
      }
    } catch (e) {
      log('❌ Print failed: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ปริ๊นใบเสร็จล้มเหลว: $e'), backgroundColor: Colors.red));
      }

      // แสดง dialog แนะนำให้ตรวจสอบปริ๊นเตอร์
      _showPrintFailedDialog(printer, e.toString());
    }
  }

  // ✅ แสดง dialog เมื่อปริ๊นล้มเหลว
  void _showPrintFailedDialog(PrinterInfo printer, String error) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('ปริ๊นล้มเหลว'),
            content: Text(
              'ไม่สามารถปริ๊นใบเสร็จไปยัง ${printer.name} ได้\n\nข้อผิดพลาด: $error\n\nกรุณาตรวจสอบ:\n• การเชื่อมต่อปริ๊นเตอร์\n• กระดาษในเครื่องปริ๊น\n• สถานะเครื่องปริ๊น',
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('ปิด')),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  // ลองปริ๊นใหม่
                  checkPrinterAndPrint();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('ลองใหม่', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  // สร้างออเดอร์
  Future<void> createOrders({required int paymentMethodId}) async {
    try {
      final total = calculateTotalWithDiscount();

      // ✅ ตรวจสอบ shift ID ก่อน
      if (homeController.currentShiftId.value.isEmpty) {
        log('❌ No shift ID found - cannot create order');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ไม่พบข้อมูลกะ กรุณาเปิดกะก่อนทำรายการ'), backgroundColor: Colors.red));
        return;
      }

      await homeController.loadDeviceInfo();

      final currentDeviceInternalId = homeController.getCurrentDeviceInternalId();
      final deviceIdToUse = currentDeviceInternalId ?? 1;

      log('📱 Device info loaded for order: ${homeController.deviceInfo.isNotEmpty}');
      log('📱 Current device internal ID: $currentDeviceInternalId');
      log('📱 Using device ID for order: $deviceIdToUse');
      log('📱 Current shift ID: ${homeController.currentShiftId.value}');

      final formattedOrder = {
        "deviceId": deviceIdToUse,
        "shiftId": homeController.currentShiftId.value,
        "branchId": 1,
        "total": total,
        "memberId": null,
        "date": DateTime.now().toIso8601String(),
        "orderItems":
            widget.items.map((item) {
              return {
                "productId": item["id"] ?? 0,
                "price": item["price"] ?? 0,
                "quantity": item["qty"] ?? 0,
                "total": item["price"] * item["qty"] ?? 0,
              };
            }).toList(),
        "paymentMethodId": paymentMethodId,
        "paid": receivedAmount,
        "change": receivedAmount - total,
        "discount": totalDiscountApplied,
        "remark": totalDiscountApplied > 0 ? "ส่วนลดรวม ฿${totalDiscountApplied.toStringAsFixed(0)}" : "string",
      };

      log("📦 JSON ที่จะส่ง: $formattedOrder");
      final order = await Homeservice.createOrders(formattedOrder: formattedOrder);
      if (!mounted) return;

      if (order != null && order['id'] != null) {
        orderReceiptNumber = order['orderNo'].toString();
        log('✅ Order created with receipt number: $orderReceiptNumber');
      }

      setState(() {
        isPaid = true;
      });
    } catch (e) {
      log('❌ Error creating order: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double total = calculateTotalWithDiscount();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: kTabColor,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const SizedBox(),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16.0), child: Center(child: Text('', style: TextStyle(color: Colors.white, fontSize: 16)))),
        ],
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // แสดงรายละเอียดยอดเงิน
                  if (totalDiscountApplied > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ยอดรวมเดิม:', style: TextStyle(fontSize: 16)),
                              Text('฿${originalTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ส่วนลดที่ได้รับ:', style: TextStyle(fontSize: 16, color: Colors.red)),
                              Text(
                                '-฿${totalDiscountApplied.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ยอดที่ต้องชำระ:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(
                                '฿${total.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Row(
                    children: [
                      // ส่วนยอดเงินที่ต้องชำระ
                      Expanded(
                        child: Column(
                          children: [
                            Text('฿${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('จำนวนเงินที่ต้องชำระ', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),

                      // เส้นแบ่งกลาง
                      if (receivedAmount > 0) ...[
                        Container(width: 1, height: 60, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 16)),

                        // ส่วนเงินทอน
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '฿${(receivedAmount - total).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: receivedAmount >= total ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('เงินทอน', style: TextStyle(color: Colors.grey, fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 20),

                  // ส่วนจำนวนเงินที่รับ
                  const Text('จำนวนรับ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('฿${receivedAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                      OutlinedButton(
                        onPressed: () async {
                          final amount = await showDialog<double>(
                            context: context,
                            builder: (context) {
                              double tempAmount = 0;
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text("ใส่จำนวนเงิน"),
                                content: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(hintText: 'เช่น 500'),
                                  onChanged: (value) {
                                    tempAmount = double.tryParse(value) ?? 0;
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("ตกลง"),
                                    onPressed: () {
                                      Navigator.of(context).pop(tempAmount);
                                    },
                                  ),
                                ],
                              );
                            },
                          );

                          if (amount != null && amount > 0) {
                            setState(() {
                              receivedAmount = amount;
                            });
                          }
                        },
                        child: const Text("จำนวนเงิน", style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ปุ่มจำนวนเงิน
                  Column(
                    children: [
                      // แถวที่ 1: ปุ่มรับเงินพอดี
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              receivedAmount = total;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.green),
                            backgroundColor: Colors.green[50],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('รับเงินพอดี', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // แถวที่ 2: ปุ่มจำนวนเงิน 100 และ 200
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    receivedAmount = 100.0;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('฿100.00', style: const TextStyle(color: Colors.black, fontSize: 16)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    receivedAmount = 200.0;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('฿200.00', style: const TextStyle(color: Colors.black, fontSize: 16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // แถวที่ 3: ปุ่มจำนวนเงิน 500 และ 1000
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    receivedAmount = 500.0;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('฿500.00', style: const TextStyle(color: Colors.black, fontSize: 16)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    receivedAmount = 1000.0;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('฿1000.00', style: const TextStyle(color: Colors.black, fontSize: 16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  const Divider(height: 32),

                  // ปุ่มชำระเงินในแถวเดียว
                  if (!isPaid) ...[
                    Row(
                      children: [
                        Expanded(child: _buildPaymentButton(context, Icons.money, 'เงินสด', 1)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPaymentButton(context, Icons.credit_card, 'บัตร', 3)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPaymentButton(context, Icons.receipt_long, 'โอน', 2)),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // ส่วนลดราคา
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ลดราคา', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        if (totalDiscountApplied > 0) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade300, width: 1),
                            ),
                            child: Text(
                              'ลดไปแล้ว ฿${totalDiscountApplied.toStringAsFixed(0)}',
                              style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ปุ่มลดราคา
                    Row(
                      children: [
                        for (final amount in [1.0, 2.0, 5.0, 10.0])
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: ElevatedButton(
                                onPressed: () => handleDiscountSelection(amount),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade400,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                child: Text('ลด ฿${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // ปุ่มเคลียร์
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: totalDiscountApplied > 0 ? clearAllDiscounts : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: totalDiscountApplied > 0 ? Colors.green.shade500 : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          elevation: totalDiscountApplied > 0 ? 2 : 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(Icons.refresh, color: totalDiscountApplied > 0 ? Colors.white : Colors.grey.shade600, size: 18),
                        label: Text(
                          totalDiscountApplied > 0 ? 'เคลียร์ - กลับเป็นราคาเดิม' : 'ไม่มีส่วนลดที่จะเคลียร์',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: totalDiscountApplied > 0 ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // หลังจากชำระเงินแล้ว
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 48),
                          const SizedBox(height: 8),
                          Text('ชำระเงินสำเร็จ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                          if (orderReceiptNumber != null) ...[
                            const SizedBox(height: 4),
                            Text('เลขที่ใบเสร็จ: $orderReceiptNumber', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    // ปุ่มปริ๊นใบเสร็จ
                    Obx(() {
                      final isConnected = printerController.isDefaultPrinterConnected.value;
                      return GestureDetector(
                        onTap: () async {
                          await checkPrinterAndPrint();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isConnected ? Colors.blue.shade100 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: isConnected ? Border.all(color: Colors.blue.shade300) : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.print, color: isConnected ? Colors.blue.shade700 : Colors.black),
                                const SizedBox(width: 8),
                                Text(
                                  'พิมพ์ใบเสร็จ',
                                  style: TextStyle(
                                    color: isConnected ? Colors.blue.shade700 : Colors.black,
                                    fontWeight: isConnected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          //Navigator.pop(context, true);
                          Navigator.of(context)
                            ..pop()
                            ..pop(true);
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text('เริ่มรายการใหม่', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ✅ Progress indicator สำหรับการคำนวณส่วนลด
          if (isCalculatingDiscount)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [CircularProgressIndicator(), SizedBox(height: 16), Text('กำลังคำนวณส่วนลด...', style: TextStyle(fontSize: 16))],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(BuildContext context, IconData icon, String label, int paymentMethodId) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        final total = calculateTotalWithDiscount();

        // ตรวจสอบจำนวนเงินสำหรับเงินสด
        if (paymentMethodId == 1 && receivedAmount < total) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('จำนวนที่รับชำระไม่เพียงพอ'), backgroundColor: Colors.red));
          return;
        }

        // แสดง PaymentConfirmDialog
        PaymentConfirmDialog.show(
          context: context,
          paymentMethod: label,
          icon: icon,
          paymentMethodId: paymentMethodId,
          autoSetAmount: paymentMethodId != 1, // เงินสดไม่ auto set, โอนและเครดิต auto set
          total: total,
          receivedAmount: receivedAmount,
          onCancel: () => Get.back(),
          onConfirm: (paymentMethodId, autoSetAmount) async {
            // เก็บ paymentMethodId สำหรับการปริ๊น
            setState(() {
              currentPaymentMethodId = paymentMethodId;
            });

            // ตั้งค่า receivedAmount สำหรับโอนและเครดิต
            if (autoSetAmount) {
              setState(() {
                receivedAmount = total;
              });
            }

            // ตรวจสอบจำนวนเงินสำหรับเงินสด
            if (!autoSetAmount && receivedAmount < total) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('จำนวนที่รับชำระไม่เพียงพอ'), backgroundColor: Colors.red));
              return;
            }

            // ดำเนินการชำระเงิน
            await createOrders(paymentMethodId: paymentMethodId);
          },
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey[800], size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[800], fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
