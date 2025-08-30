// mix_match_multi_units.dart
// Engine คำนวณ Mix & Match หลายโปรพร้อมกัน (priority + combinable)
// ทำงานกับ cartItems และ discounts โดยตรง
// เงิน = บาท (double ปัด 2 ตำแหน่ง), จำนวน = "ชิ้น" (double), ไม่ใช้ milli

import 'dart:developer';

/// ประเภทผลประโยชน์ของโปร
enum MmBenefitType { fixedTotal, fixedUnit, discountAmount, discountPercent }

/// กติกา Mix & Match
class MixMatchRule {
  final String id;
  final int priority; // ยิ่งน้อยยิ่งคิดก่อน
  final double stepQty; // ต้องครบกี่ "ชิ้น" ต่อชุด (เช่น 3.0)
  final MmBenefitType benefitType;
  final double benefitValue; // บาท หรือ % (ตาม type)
  final bool combinable; // true = ซ้อนโปรอื่นได้ (ไม่กินจำนวน)
  final int? maxSetsPerTxn; // จำกัดจำนวนชุด/บิล (null = ไม่จำกัด)
  final Set<String> productIds; // สินค้าที่นับรวมได้

  const MixMatchRule({
    required this.id,
    required this.priority,
    required this.stepQty,
    required this.benefitType,
    required this.benefitValue,
    required this.combinable,
    this.maxSetsPerTxn,
    required this.productIds,
  });
}

/// ผลการจัดสรรส่วนลดต่อรายการ
class DiscountAllocation {
  final String ruleId;
  final int cartIndex; // index ของ cartItem
  final double discount; // บาท (ปัด 2 ตำแหน่งแล้ว)

  const DiscountAllocation({required this.ruleId, required this.cartIndex, required this.discount});
}

/// ผลรวมการคำนวณส่วนลด
class DiscountResult {
  final List<DiscountAllocation> allocations;
  final double discountTotal; // บาทรวม
  final Map<int, double> consumedQtyPerItem; // qty ถูกกินจริงจากโปรที่ห้ามซ้อน

  const DiscountResult({required this.allocations, required this.discountTotal, required this.consumedQtyPerItem});
}

/// ===== Utilities =====

double _round2(num v) => (v * 100).round() / 100.0;

/// คำนวณมูลค่าของ cartItem
double _amountOfCartItem(Map<String, dynamic> item) {
  final price = (item['price'] ?? 0).toDouble();
  final qty = (item['qty'] ?? 1).toDouble();
  return _round2(price * qty);
}

/// รวมมูลค่าของ cartItems หลายรายการ
double _sumCartItemsAmount(List<Map<String, dynamic>> items) {
  double sum = 0;
  for (final item in items) {
    sum = _round2(sum + _amountOfCartItem(item));
  }
  return _round2(sum);
}

/// ตรวจสอบว่า cartItem เข้าเงื่อนไขของ discount หรือไม่
bool _isCartItemEligible(Map<String, dynamic> cartItem, Map<String, dynamic> discount) {
  final cartItemId = (cartItem['id'] ?? cartItem['productId']).toString();

  // ตรวจสอบ items ใน discount
  final items = discount['items'] as List<dynamic>?;
  if (items == null || items.isEmpty) {
    return true; // ไม่ระบุสินค้า = ใช้ได้กับทุกสินค้า
  }

  // ตรวจสอบว่า cartItem อยู่ใน items หรือไม่
  for (final item in items) {
    final productId = item['product']?['id']?.toString();
    if (productId == cartItemId) {
      return true;
    }
  }

  return false;
}

/// กระจายส่วนลดแบบสัดส่วน (pro-rata) + โยนเศษให้ตัวท้าย
List<DiscountAllocation> _allocateProRata({
  required List<Map<String, dynamic>> pickedItems,
  required List<int> pickedIndexes,
  required double discountBaht,
  required String ruleId,
}) {
  if (discountBaht <= 0) {
    return pickedIndexes.map((index) => DiscountAllocation(ruleId: ruleId, cartIndex: index, discount: 0.0)).toList();
  }

  final base = _sumCartItemsAmount(pickedItems);
  if (base <= 0) {
    return pickedIndexes.map((index) => DiscountAllocation(ruleId: ruleId, cartIndex: index, discount: 0.0)).toList();
  }

  final out = <DiscountAllocation>[];
  double allocated = 0.0;

  for (var i = 0; i < pickedItems.length; i++) {
    if (i == pickedItems.length - 1) {
      final last = _round2(discountBaht - allocated);
      out.add(DiscountAllocation(ruleId: ruleId, cartIndex: pickedIndexes[i], discount: last));
    } else {
      final portion = _round2((_amountOfCartItem(pickedItems[i]) / base) * discountBaht);
      out.add(DiscountAllocation(ruleId: ruleId, cartIndex: pickedIndexes[i], discount: portion));
      allocated = _round2(allocated + portion);
    }
  }
  return out;
}

/// คำนวณราคาหลังโปรต่อ "ชุด" (หน่วยบาท)
double _finalSetPrice({required double normalBaht, required double stepQty, required String benefitType, required double benefitValue}) {
  switch (benefitType.toUpperCase()) {
    case 'FIXED_TOTAL':
      return _round2(benefitValue);
    case 'FIXED_UNIT':
      return _round2(benefitValue * stepQty); // ราคา/ชิ้น * จำนวนในชุด
    case 'DISCOUNT_AMOUNT':
      return _round2((normalBaht - benefitValue) < 0 ? 0 : (normalBaht - benefitValue));
    case 'DISCOUNT_PERCENT':
    case 'PERCENTAGE':
    default:
      // benefitValue = เปอร์เซ็นต์ เช่น 10 = 10%
      final p = (100 - benefitValue) / 100.0;
      return _round2(normalBaht * p);
  }
}

/// ตรวจสอบว่า cartItem เข้าเงื่อนไขของ MixMatchRule หรือไม่
bool _isCartItemEligibleForRule(Map<String, dynamic> cartItem, MixMatchRule rule) {
  final cartItemId = (cartItem['id'] ?? cartItem['productId']).toString();
  return rule.productIds.contains(cartItemId);
}

/// คำนวณราคาหลังโปรสำหรับจำนวนที่ใช้จริง สำหรับ MixMatchRule
double _finalSetPriceForRule({
  required double normalBaht,
  required double usedQty,
  required double stepQty,
  required MmBenefitType benefitType,
  required double benefitValue,
}) {
  final sets = (usedQty / stepQty).floor();

  switch (benefitType) {
    case MmBenefitType.fixedTotal:
      // ราคาคงที่ต่อชุด × จำนวนชุด
      return _round2(benefitValue * sets);
    case MmBenefitType.fixedUnit:
      // ราคาคงที่ต่อชิ้น × จำนวนชิ้นที่ใช้
      return _round2(benefitValue * usedQty);
    case MmBenefitType.discountAmount:
      // ลดจำนวนเงินต่อชุด × จำนวนชุด
      final totalDiscount = benefitValue * sets;
      return _round2((normalBaht - totalDiscount) < 0 ? 0 : (normalBaht - totalDiscount));
    case MmBenefitType.discountPercent:
      // ลดเปอร์เซ็นต์
      final p = (100 - benefitValue) / 100.0;
      return _round2(normalBaht * p);
  }
}

/// คำนวณส่วนลดจาก MixMatchRule เดียว
Map<String, dynamic> _applySingleRule({
  required List<Map<String, dynamic>> cartItems,
  required MixMatchRule rule,
  Map<int, double>? availableQty, // ส่งเข้ามาเมื่อโปรห้ามซ้อน
}) {
  // 1) คัดสินค้าเข้าโปร
  final eligibleItems = <Map<String, dynamic>>[];
  final eligibleIndexes = <int>[];

  for (int i = 0; i < cartItems.length; i++) {
    final item = cartItems[i];
    final qty = (item['qty'] ?? 1).toDouble();

    if (qty > 0 && _isCartItemEligibleForRule(item, rule)) {
      final availableForThisItem = availableQty?[i] ?? qty;
      if (availableForThisItem > 0) {
        final usableQty = availableForThisItem < qty ? availableForThisItem : qty;
        final itemCopy = Map<String, dynamic>.from(item);
        itemCopy['qty'] = usableQty;
        eligibleItems.add(itemCopy);
        eligibleIndexes.add(i);
      }
    }
  }

  if (eligibleItems.isEmpty) {
    return {'allocations': <DiscountAllocation>[], 'usedQtyPerItem': <int, double>{}, 'discountTotal': 0.0};
  }

  // 2) คิดจำนวนชุดจากปริมาณที่ใช้ได้จริง
  final totalQty = eligibleItems.fold<double>(0, (sum, item) => sum + (item['qty'] ?? 1).toDouble());
  int sets = (totalQty / rule.stepQty).floor();
  if (rule.maxSetsPerTxn != null) {
    sets = sets.clamp(0, rule.maxSetsPerTxn!);
  }
  if (sets <= 0) {
    return {'allocations': <DiscountAllocation>[], 'usedQtyPerItem': <int, double>{}, 'discountTotal': 0.0};
  }

  // 3) คำนวณส่วนลด
  final usedQty = (sets * rule.stepQty).toDouble();
  final usedItems = <Map<String, dynamic>>[];
  final usedIndexes = <int>[];
  final usedQtyPerItem = <int, double>{};

  double remainingQty = usedQty;
  for (int i = 0; i < eligibleItems.length && remainingQty > 0; i++) {
    final item = eligibleItems[i];
    final itemQty = (item['qty'] ?? 1).toDouble();
    final takeQty = remainingQty >= itemQty ? itemQty : remainingQty;

    if (takeQty > 0) {
      final itemCopy = Map<String, dynamic>.from(item);
      itemCopy['qty'] = takeQty;
      usedItems.add(itemCopy);
      usedIndexes.add(eligibleIndexes[i]);
      usedQtyPerItem[eligibleIndexes[i]] = takeQty;
      remainingQty -= takeQty;
    }
  }

  final normalAmount = _sumCartItemsAmount(usedItems);
  final finalAmount = _finalSetPriceForRule(
    normalBaht: normalAmount,
    usedQty: usedQty,
    stepQty: rule.stepQty,
    benefitType: rule.benefitType,
    benefitValue: rule.benefitValue,
  );

  final setDiscount = _round2(normalAmount - finalAmount);
  final nonNegativeDiscount = setDiscount < 0 ? 0.0 : setDiscount;

  List<DiscountAllocation> allocations = [];
  if (nonNegativeDiscount > 0) {
    allocations = _allocateProRata(pickedItems: usedItems, pickedIndexes: usedIndexes, discountBaht: nonNegativeDiscount, ruleId: rule.id);
  }

  return {'allocations': allocations, 'usedQtyPerItem': usedQtyPerItem, 'discountTotal': _round2(nonNegativeDiscount)};
}

/// แปลง discounts จาก API เป็น MixMatchRule
List<MixMatchRule> _convertDiscountsToRules(List<Map<String, dynamic>> discounts, List<Map<String, dynamic>> cartItems) {
  final rules = <MixMatchRule>[];

  for (final discount in discounts) {
    try {
      final id = discount['id'].toString();
      final priority = discount['priority'] ?? 999;
      final stepQty = (discount['stepQty'] ?? 1).toDouble();
      final benefitValue = (discount['benefitValue'] ?? 0).toDouble();
      final combinable = discount['combinable'] ?? true;
      final maxSets = discount['maxSetsPerTxn'];
      final isActive = discount['isActive'] ?? true;

      if (!isActive) continue;

      // แปลง benefitType
      MmBenefitType benefitType;
      final typeStr = (discount['benefitType'] ?? 'PERCENTAGE').toString().toUpperCase();
      switch (typeStr) {
        case 'FIXED_TOTAL':
          benefitType = MmBenefitType.fixedTotal;
          break;
        case 'FIXED_UNIT':
          benefitType = MmBenefitType.fixedUnit;
          break;
        case 'DISCOUNT_AMOUNT':
          benefitType = MmBenefitType.discountAmount;
          break;
        case 'DISCOUNT_PERCENT':
        case 'PERCENTAGE':
        default:
          benefitType = MmBenefitType.discountPercent;
          break;
      }

      // กำหนดสินค้าที่ใช้ได้
      Set<String> productIds = {};
      final items = discount['items'] as List<dynamic>?;
      if (items == null || items.isEmpty) {
        // ไม่ระบุสินค้า = ใช้ได้กับทุกสินค้า
        productIds = cartItems.map((item) => (item['id'] ?? item['productId']).toString()).toSet();
      } else {
        // ระบุสินค้าเฉพาะ
        for (final item in items) {
          final productId = item['product']?['id']?.toString();
          if (productId != null) {
            productIds.add(productId);
          }
        }
      }

      rules.add(
        MixMatchRule(
          id: id,
          priority: priority,
          stepQty: stepQty,
          benefitType: benefitType,
          benefitValue: benefitValue,
          combinable: combinable,
          maxSetsPerTxn: maxSets,
          productIds: productIds,
        ),
      );
    } catch (e) {
      log('❌ Error converting discount to rule: $e');
      continue;
    }
  }

  return rules;
}

/// คำนวณส่วนลดจาก cartItems และ discounts หลายโปรพร้อมกัน
double calculateDiscountFromRules({required List<Map<String, dynamic>> cartItems, required List<Map<String, dynamic>> discounts}) {
  if (cartItems.isEmpty || discounts.isEmpty) {
    return 0.0;
  }

  try {
    // แปลง discounts เป็น MixMatchRule
    final rules = _convertDiscountsToRules(discounts, cartItems);
    if (rules.isEmpty) {
      return 0.0;
    }

    // ปริมาณคงเหลือ ต่อรายการเพื่อ "กัน" ให้โปรที่ห้ามซ้อน
    final remaining = <int, double>{};
    for (int i = 0; i < cartItems.length; i++) {
      remaining[i] = (cartItems[i]['qty'] ?? 1).toDouble();
    }

    // เรียงโปรตาม priority (น้อยมาก่อน)
    final sortedRules = [...rules];
    sortedRules.sort((a, b) => a.priority.compareTo(b.priority));

    final allAllocations = <DiscountAllocation>[];
    double totalDiscount = 0.0;

    for (final rule in sortedRules) {
      final availableQty = rule.combinable ? null : Map<int, double>.from(remaining);

      final result = _applySingleRule(cartItems: cartItems, rule: rule, availableQty: availableQty);

      final discountAmount = result['discountTotal'] as double;
      if (discountAmount <= 0) continue;

      final allocations = result['allocations'] as List<DiscountAllocation>;
      final usedQtyPerItem = result['usedQtyPerItem'] as Map<int, double>;

      allAllocations.addAll(allocations);
      totalDiscount = _round2(totalDiscount + discountAmount);

      if (!rule.combinable) {
        // หักปริมาณที่ถูกใช้ไปจริงจาก remaining
        usedQtyPerItem.forEach((itemIndex, used) {
          final current = remaining[itemIndex] ?? 0.0;
          final next = _round2(current - used);
          remaining[itemIndex] = next > 0 ? next : 0.0;
        });
      }
    }

    return _round2(totalDiscount);
  } catch (e) {
    log('❌ Error calculating discount: $e');
    return 0.0;
  }
}
