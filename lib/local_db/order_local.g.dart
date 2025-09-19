// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOrderLocalCollection on Isar {
  IsarCollection<OrderLocal> get orderLocals => this.collection();
}

const OrderLocalSchema = CollectionSchema(
  name: r'OrderLocal',
  id: -7888226103119407276,
  properties: {
    r'branchId': PropertySchema(id: 0, name: r'branchId', type: IsarType.long),
    r'change': PropertySchema(id: 1, name: r'change', type: IsarType.double),
    r'date': PropertySchema(id: 2, name: r'date', type: IsarType.dateTime),
    r'deviceId': PropertySchema(id: 3, name: r'deviceId', type: IsarType.long),
    r'discount': PropertySchema(
      id: 4,
      name: r'discount',
      type: IsarType.double,
    ),
    r'memberId': PropertySchema(id: 5, name: r'memberId', type: IsarType.long),
    r'paid': PropertySchema(id: 6, name: r'paid', type: IsarType.double),
    r'paymentMethodId': PropertySchema(
      id: 7,
      name: r'paymentMethodId',
      type: IsarType.long,
    ),
    r'remark': PropertySchema(id: 8, name: r'remark', type: IsarType.string),
    r'shiftId': PropertySchema(id: 9, name: r'shiftId', type: IsarType.long),
    r'total': PropertySchema(id: 10, name: r'total', type: IsarType.double),
  },

  estimateSize: _orderLocalEstimateSize,
  serialize: _orderLocalSerialize,
  deserialize: _orderLocalDeserialize,
  deserializeProp: _orderLocalDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'orderItems': LinkSchema(
      id: 3184828690784768520,
      name: r'orderItems',
      target: r'OrderItemLocal',
      single: false,
    ),
  },
  embeddedSchemas: {},

  getId: _orderLocalGetId,
  getLinks: _orderLocalGetLinks,
  attach: _orderLocalAttach,
  version: '3.3.0-dev.2',
);

int _orderLocalEstimateSize(
  OrderLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.remark;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _orderLocalSerialize(
  OrderLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.branchId);
  writer.writeDouble(offsets[1], object.change);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeLong(offsets[3], object.deviceId);
  writer.writeDouble(offsets[4], object.discount);
  writer.writeLong(offsets[5], object.memberId);
  writer.writeDouble(offsets[6], object.paid);
  writer.writeLong(offsets[7], object.paymentMethodId);
  writer.writeString(offsets[8], object.remark);
  writer.writeLong(offsets[9], object.shiftId);
  writer.writeDouble(offsets[10], object.total);
}

OrderLocal _orderLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OrderLocal();
  object.branchId = reader.readLongOrNull(offsets[0]);
  object.change = reader.readDoubleOrNull(offsets[1]);
  object.date = reader.readDateTimeOrNull(offsets[2]);
  object.deviceId = reader.readLongOrNull(offsets[3]);
  object.discount = reader.readDoubleOrNull(offsets[4]);
  object.id = id;
  object.memberId = reader.readLongOrNull(offsets[5]);
  object.paid = reader.readDoubleOrNull(offsets[6]);
  object.paymentMethodId = reader.readLongOrNull(offsets[7]);
  object.remark = reader.readStringOrNull(offsets[8]);
  object.shiftId = reader.readLongOrNull(offsets[9]);
  object.total = reader.readDoubleOrNull(offsets[10]);
  return object;
}

P _orderLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _orderLocalGetId(OrderLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _orderLocalGetLinks(OrderLocal object) {
  return [object.orderItems];
}

void _orderLocalAttach(IsarCollection<dynamic> col, Id id, OrderLocal object) {
  object.id = id;
  object.orderItems.attach(
    col,
    col.isar.collection<OrderItemLocal>(),
    r'orderItems',
    id,
  );
}

extension OrderLocalQueryWhereSort
    on QueryBuilder<OrderLocal, OrderLocal, QWhere> {
  QueryBuilder<OrderLocal, OrderLocal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OrderLocalQueryWhere
    on QueryBuilder<OrderLocal, OrderLocal, QWhereClause> {
  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension OrderLocalQueryFilter
    on QueryBuilder<OrderLocal, OrderLocal, QFilterCondition> {
  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> branchIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'branchId'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  branchIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'branchId'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> branchIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'branchId', value: value),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  branchIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'branchId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> branchIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'branchId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> branchIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'branchId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> changeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'change'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  changeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'change'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> changeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'change',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> changeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'change',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> changeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'change',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> changeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'change',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> dateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'date'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> dateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'date'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> dateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> dateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> dateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> dateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> deviceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deviceId'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  deviceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deviceId'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> deviceIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deviceId', value: value),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  deviceIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deviceId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> deviceIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deviceId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> deviceIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deviceId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> discountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'discount'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  discountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'discount'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> discountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'discount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  discountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'discount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> discountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'discount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> discountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'discount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> memberIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'memberId'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  memberIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'memberId'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> memberIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'memberId', value: value),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  memberIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'memberId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> memberIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'memberId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> memberIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'memberId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> paidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'paid'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> paidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'paid'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> paidEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'paid',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> paidGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'paid',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> paidLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'paid',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> paidBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'paid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentMethodIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'paymentMethodId'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentMethodIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'paymentMethodId'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentMethodIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'paymentMethodId', value: value),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentMethodIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'paymentMethodId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentMethodIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'paymentMethodId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentMethodIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'paymentMethodId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remarkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'remark'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  remarkIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'remark'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remarkEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'remark',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remarkGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remark',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remarkLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remark',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remarkBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remark',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remarkStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'remark',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remarkEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'remark',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remarkContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'remark',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remarkMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'remark',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remarkIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remark', value: ''),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  remarkIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remark', value: ''),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> shiftIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'shiftId'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  shiftIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'shiftId'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> shiftIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'shiftId', value: value),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  shiftIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'shiftId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> shiftIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'shiftId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> shiftIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'shiftId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> totalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'total'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> totalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'total'),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> totalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'total',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> totalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'total',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> totalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'total',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> totalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'total',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension OrderLocalQueryObject
    on QueryBuilder<OrderLocal, OrderLocal, QFilterCondition> {}

extension OrderLocalQueryLinks
    on QueryBuilder<OrderLocal, OrderLocal, QFilterCondition> {
  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> orderItems(
    FilterQuery<OrderItemLocal> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'orderItems');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  orderItemsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'orderItems', length, true, length, true);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  orderItemsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'orderItems', 0, true, 0, true);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  orderItemsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'orderItems', 0, false, 999999, true);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  orderItemsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'orderItems', 0, true, length, include);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  orderItemsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'orderItems', length, include, 999999, true);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  orderItemsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'orderItems',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension OrderLocalQuerySortBy
    on QueryBuilder<OrderLocal, OrderLocal, QSortBy> {
  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByBranchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByBranchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByChangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByDiscount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discount', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByDiscountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discount', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paid', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paid', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByPaymentMethodId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethodId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy>
  sortByPaymentMethodIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethodId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByRemark() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remark', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByRemarkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remark', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByShiftId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByShiftIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }
}

extension OrderLocalQuerySortThenBy
    on QueryBuilder<OrderLocal, OrderLocal, QSortThenBy> {
  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByBranchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByBranchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByChangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByDiscount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discount', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByDiscountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discount', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paid', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paid', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByPaymentMethodId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethodId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy>
  thenByPaymentMethodIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethodId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByRemark() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remark', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByRemarkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remark', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByShiftId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByShiftIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }
}

extension OrderLocalQueryWhereDistinct
    on QueryBuilder<OrderLocal, OrderLocal, QDistinct> {
  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByBranchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'branchId');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'change');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByDiscount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discount');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'memberId');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paid');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByPaymentMethodId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentMethodId');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByRemark({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remark', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByShiftId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shiftId');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'total');
    });
  }
}

extension OrderLocalQueryProperty
    on QueryBuilder<OrderLocal, OrderLocal, QQueryProperty> {
  QueryBuilder<OrderLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OrderLocal, int?, QQueryOperations> branchIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'branchId');
    });
  }

  QueryBuilder<OrderLocal, double?, QQueryOperations> changeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'change');
    });
  }

  QueryBuilder<OrderLocal, DateTime?, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<OrderLocal, int?, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<OrderLocal, double?, QQueryOperations> discountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discount');
    });
  }

  QueryBuilder<OrderLocal, int?, QQueryOperations> memberIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'memberId');
    });
  }

  QueryBuilder<OrderLocal, double?, QQueryOperations> paidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paid');
    });
  }

  QueryBuilder<OrderLocal, int?, QQueryOperations> paymentMethodIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentMethodId');
    });
  }

  QueryBuilder<OrderLocal, String?, QQueryOperations> remarkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remark');
    });
  }

  QueryBuilder<OrderLocal, int?, QQueryOperations> shiftIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shiftId');
    });
  }

  QueryBuilder<OrderLocal, double?, QQueryOperations> totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOrderItemLocalCollection on Isar {
  IsarCollection<OrderItemLocal> get orderItemLocals => this.collection();
}

const OrderItemLocalSchema = CollectionSchema(
  name: r'OrderItemLocal',
  id: -3865200514212471944,
  properties: {
    r'price': PropertySchema(id: 0, name: r'price', type: IsarType.double),
    r'productId': PropertySchema(
      id: 1,
      name: r'productId',
      type: IsarType.long,
    ),
    r'quantity': PropertySchema(id: 2, name: r'quantity', type: IsarType.long),
    r'total': PropertySchema(id: 3, name: r'total', type: IsarType.double),
  },

  estimateSize: _orderItemLocalEstimateSize,
  serialize: _orderItemLocalSerialize,
  deserialize: _orderItemLocalDeserialize,
  deserializeProp: _orderItemLocalDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _orderItemLocalGetId,
  getLinks: _orderItemLocalGetLinks,
  attach: _orderItemLocalAttach,
  version: '3.3.0-dev.2',
);

int _orderItemLocalEstimateSize(
  OrderItemLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _orderItemLocalSerialize(
  OrderItemLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.price);
  writer.writeLong(offsets[1], object.productId);
  writer.writeLong(offsets[2], object.quantity);
  writer.writeDouble(offsets[3], object.total);
}

OrderItemLocal _orderItemLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OrderItemLocal();
  object.id = id;
  object.price = reader.readDoubleOrNull(offsets[0]);
  object.productId = reader.readLongOrNull(offsets[1]);
  object.quantity = reader.readLongOrNull(offsets[2]);
  object.total = reader.readDoubleOrNull(offsets[3]);
  return object;
}

P _orderItemLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _orderItemLocalGetId(OrderItemLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _orderItemLocalGetLinks(OrderItemLocal object) {
  return [];
}

void _orderItemLocalAttach(
  IsarCollection<dynamic> col,
  Id id,
  OrderItemLocal object,
) {
  object.id = id;
}

extension OrderItemLocalQueryWhereSort
    on QueryBuilder<OrderItemLocal, OrderItemLocal, QWhere> {
  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OrderItemLocalQueryWhere
    on QueryBuilder<OrderItemLocal, OrderItemLocal, QWhereClause> {
  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension OrderItemLocalQueryFilter
    on QueryBuilder<OrderItemLocal, OrderItemLocal, QFilterCondition> {
  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  priceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'price'),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  priceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'price'),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  priceEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'price',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  priceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'price',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  priceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'price',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  priceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'price',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  productIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'productId'),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  productIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'productId'),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  productIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'productId', value: value),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  productIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'productId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  productIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'productId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  productIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'productId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  quantityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'quantity'),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  quantityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'quantity'),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  quantityEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quantity', value: value),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  quantityGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quantity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  quantityLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quantity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  quantityBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quantity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  totalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'total'),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  totalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'total'),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  totalEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'total',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  totalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'total',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  totalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'total',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterFilterCondition>
  totalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'total',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension OrderItemLocalQueryObject
    on QueryBuilder<OrderItemLocal, OrderItemLocal, QFilterCondition> {}

extension OrderItemLocalQueryLinks
    on QueryBuilder<OrderItemLocal, OrderItemLocal, QFilterCondition> {}

extension OrderItemLocalQuerySortBy
    on QueryBuilder<OrderItemLocal, OrderItemLocal, QSortBy> {
  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy> sortByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy> sortByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy> sortByProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.asc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy>
  sortByProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.desc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy> sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy>
  sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy> sortByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy> sortByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }
}

extension OrderItemLocalQuerySortThenBy
    on QueryBuilder<OrderItemLocal, OrderItemLocal, QSortThenBy> {
  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy> thenByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy> thenByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy> thenByProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.asc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy>
  thenByProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.desc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy> thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy>
  thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy> thenByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QAfterSortBy> thenByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }
}

extension OrderItemLocalQueryWhereDistinct
    on QueryBuilder<OrderItemLocal, OrderItemLocal, QDistinct> {
  QueryBuilder<OrderItemLocal, OrderItemLocal, QDistinct> distinctByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'price');
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QDistinct>
  distinctByProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productId');
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QDistinct> distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<OrderItemLocal, OrderItemLocal, QDistinct> distinctByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'total');
    });
  }
}

extension OrderItemLocalQueryProperty
    on QueryBuilder<OrderItemLocal, OrderItemLocal, QQueryProperty> {
  QueryBuilder<OrderItemLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OrderItemLocal, double?, QQueryOperations> priceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'price');
    });
  }

  QueryBuilder<OrderItemLocal, int?, QQueryOperations> productIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productId');
    });
  }

  QueryBuilder<OrderItemLocal, int?, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<OrderItemLocal, double?, QQueryOperations> totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }
}
