// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOrderDtoCollection on Isar {
  IsarCollection<OrderDto> get orderDtos => this.collection();
}

const OrderDtoSchema = CollectionSchema(
  name: r'OrderDto',
  id: -3024455581531254206,
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

  estimateSize: _orderDtoEstimateSize,
  serialize: _orderDtoSerialize,
  deserialize: _orderDtoDeserialize,
  deserializeProp: _orderDtoDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'orderItems': LinkSchema(
      id: 1692987613741115096,
      name: r'orderItems',
      target: r'OrderItemDto',
      single: false,
    ),
  },
  embeddedSchemas: {},

  getId: _orderDtoGetId,
  getLinks: _orderDtoGetLinks,
  attach: _orderDtoAttach,
  version: '3.3.0-dev.2',
);

int _orderDtoEstimateSize(
  OrderDto object,
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

void _orderDtoSerialize(
  OrderDto object,
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

OrderDto _orderDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OrderDto();
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

P _orderDtoDeserializeProp<P>(
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

Id _orderDtoGetId(OrderDto object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _orderDtoGetLinks(OrderDto object) {
  return [object.orderItems];
}

void _orderDtoAttach(IsarCollection<dynamic> col, Id id, OrderDto object) {
  object.id = id;
  object.orderItems.attach(
    col,
    col.isar.collection<OrderItemDto>(),
    r'orderItems',
    id,
  );
}

extension OrderDtoQueryWhereSort on QueryBuilder<OrderDto, OrderDto, QWhere> {
  QueryBuilder<OrderDto, OrderDto, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OrderDtoQueryWhere on QueryBuilder<OrderDto, OrderDto, QWhereClause> {
  QueryBuilder<OrderDto, OrderDto, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<OrderDto, OrderDto, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterWhereClause> idBetween(
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

extension OrderDtoQueryFilter
    on QueryBuilder<OrderDto, OrderDto, QFilterCondition> {
  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> branchIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'branchId'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> branchIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'branchId'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> branchIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'branchId', value: value),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> branchIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> branchIdLessThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> branchIdBetween(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> changeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'change'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> changeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'change'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> changeEqualTo(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> changeGreaterThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> changeLessThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> changeBetween(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> dateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'date'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> dateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'date'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> dateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> dateGreaterThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> dateLessThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> dateBetween(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> deviceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deviceId'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> deviceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deviceId'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> deviceIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deviceId', value: value),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> deviceIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> deviceIdLessThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> deviceIdBetween(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> discountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'discount'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> discountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'discount'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> discountEqualTo(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> discountGreaterThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> discountLessThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> discountBetween(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> idBetween(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> memberIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'memberId'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> memberIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'memberId'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> memberIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'memberId', value: value),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> memberIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> memberIdLessThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> memberIdBetween(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> paidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'paid'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> paidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'paid'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> paidEqualTo(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> paidGreaterThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> paidLessThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> paidBetween(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition>
  paymentMethodIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'paymentMethodId'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition>
  paymentMethodIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'paymentMethodId'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition>
  paymentMethodIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'paymentMethodId', value: value),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition>
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition>
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition>
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> remarkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'remark'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> remarkIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'remark'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> remarkEqualTo(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> remarkGreaterThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> remarkLessThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> remarkBetween(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> remarkStartsWith(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> remarkEndsWith(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> remarkContains(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> remarkMatches(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> remarkIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remark', value: ''),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> remarkIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remark', value: ''),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> shiftIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'shiftId'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> shiftIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'shiftId'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> shiftIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'shiftId', value: value),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> shiftIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> shiftIdLessThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> shiftIdBetween(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> totalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'total'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> totalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'total'),
      );
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> totalEqualTo(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> totalGreaterThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> totalLessThan(
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

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> totalBetween(
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

extension OrderDtoQueryObject
    on QueryBuilder<OrderDto, OrderDto, QFilterCondition> {}

extension OrderDtoQueryLinks
    on QueryBuilder<OrderDto, OrderDto, QFilterCondition> {
  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> orderItems(
    FilterQuery<OrderItemDto> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'orderItems');
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition>
  orderItemsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'orderItems', length, true, length, true);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition> orderItemsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'orderItems', 0, true, 0, true);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition>
  orderItemsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'orderItems', 0, false, 999999, true);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition>
  orderItemsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'orderItems', 0, true, length, include);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition>
  orderItemsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'orderItems', length, include, 999999, true);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterFilterCondition>
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

extension OrderDtoQuerySortBy on QueryBuilder<OrderDto, OrderDto, QSortBy> {
  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByBranchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchId', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByBranchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchId', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByChangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByDiscount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discount', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByDiscountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discount', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberId', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberId', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paid', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paid', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByPaymentMethodId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethodId', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByPaymentMethodIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethodId', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByRemark() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remark', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByRemarkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remark', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByShiftId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftId', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByShiftIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftId', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> sortByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }
}

extension OrderDtoQuerySortThenBy
    on QueryBuilder<OrderDto, OrderDto, QSortThenBy> {
  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByBranchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchId', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByBranchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchId', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByChangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByDiscount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discount', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByDiscountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discount', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberId', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberId', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paid', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paid', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByPaymentMethodId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethodId', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByPaymentMethodIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethodId', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByRemark() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remark', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByRemarkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remark', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByShiftId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftId', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByShiftIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftId', Sort.desc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QAfterSortBy> thenByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }
}

extension OrderDtoQueryWhereDistinct
    on QueryBuilder<OrderDto, OrderDto, QDistinct> {
  QueryBuilder<OrderDto, OrderDto, QDistinct> distinctByBranchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'branchId');
    });
  }

  QueryBuilder<OrderDto, OrderDto, QDistinct> distinctByChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'change');
    });
  }

  QueryBuilder<OrderDto, OrderDto, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<OrderDto, OrderDto, QDistinct> distinctByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId');
    });
  }

  QueryBuilder<OrderDto, OrderDto, QDistinct> distinctByDiscount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discount');
    });
  }

  QueryBuilder<OrderDto, OrderDto, QDistinct> distinctByMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'memberId');
    });
  }

  QueryBuilder<OrderDto, OrderDto, QDistinct> distinctByPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paid');
    });
  }

  QueryBuilder<OrderDto, OrderDto, QDistinct> distinctByPaymentMethodId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentMethodId');
    });
  }

  QueryBuilder<OrderDto, OrderDto, QDistinct> distinctByRemark({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remark', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderDto, OrderDto, QDistinct> distinctByShiftId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shiftId');
    });
  }

  QueryBuilder<OrderDto, OrderDto, QDistinct> distinctByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'total');
    });
  }
}

extension OrderDtoQueryProperty
    on QueryBuilder<OrderDto, OrderDto, QQueryProperty> {
  QueryBuilder<OrderDto, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OrderDto, int?, QQueryOperations> branchIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'branchId');
    });
  }

  QueryBuilder<OrderDto, double?, QQueryOperations> changeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'change');
    });
  }

  QueryBuilder<OrderDto, DateTime?, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<OrderDto, int?, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<OrderDto, double?, QQueryOperations> discountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discount');
    });
  }

  QueryBuilder<OrderDto, int?, QQueryOperations> memberIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'memberId');
    });
  }

  QueryBuilder<OrderDto, double?, QQueryOperations> paidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paid');
    });
  }

  QueryBuilder<OrderDto, int?, QQueryOperations> paymentMethodIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentMethodId');
    });
  }

  QueryBuilder<OrderDto, String?, QQueryOperations> remarkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remark');
    });
  }

  QueryBuilder<OrderDto, int?, QQueryOperations> shiftIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shiftId');
    });
  }

  QueryBuilder<OrderDto, double?, QQueryOperations> totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOrderItemDtoCollection on Isar {
  IsarCollection<OrderItemDto> get orderItemDtos => this.collection();
}

const OrderItemDtoSchema = CollectionSchema(
  name: r'OrderItemDto',
  id: -797921217198979877,
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

  estimateSize: _orderItemDtoEstimateSize,
  serialize: _orderItemDtoSerialize,
  deserialize: _orderItemDtoDeserialize,
  deserializeProp: _orderItemDtoDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _orderItemDtoGetId,
  getLinks: _orderItemDtoGetLinks,
  attach: _orderItemDtoAttach,
  version: '3.3.0-dev.2',
);

int _orderItemDtoEstimateSize(
  OrderItemDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _orderItemDtoSerialize(
  OrderItemDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.price);
  writer.writeLong(offsets[1], object.productId);
  writer.writeLong(offsets[2], object.quantity);
  writer.writeDouble(offsets[3], object.total);
}

OrderItemDto _orderItemDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OrderItemDto();
  object.id = id;
  object.price = reader.readDoubleOrNull(offsets[0]);
  object.productId = reader.readLongOrNull(offsets[1]);
  object.quantity = reader.readLongOrNull(offsets[2]);
  object.total = reader.readDoubleOrNull(offsets[3]);
  return object;
}

P _orderItemDtoDeserializeProp<P>(
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

Id _orderItemDtoGetId(OrderItemDto object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _orderItemDtoGetLinks(OrderItemDto object) {
  return [];
}

void _orderItemDtoAttach(
  IsarCollection<dynamic> col,
  Id id,
  OrderItemDto object,
) {
  object.id = id;
}

extension OrderItemDtoQueryWhereSort
    on QueryBuilder<OrderItemDto, OrderItemDto, QWhere> {
  QueryBuilder<OrderItemDto, OrderItemDto, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OrderItemDtoQueryWhere
    on QueryBuilder<OrderItemDto, OrderItemDto, QWhereClause> {
  QueryBuilder<OrderItemDto, OrderItemDto, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterWhereClause> idBetween(
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

extension OrderItemDtoQueryFilter
    on QueryBuilder<OrderItemDto, OrderItemDto, QFilterCondition> {
  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition> idBetween(
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
  priceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'price'),
      );
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
  priceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'price'),
      );
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition> priceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition> priceLessThan(
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition> priceBetween(
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
  productIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'productId'),
      );
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
  productIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'productId'),
      );
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
  productIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'productId', value: value),
      );
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
  quantityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'quantity'),
      );
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
  quantityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'quantity'),
      );
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
  quantityEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quantity', value: value),
      );
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
  totalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'total'),
      );
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
  totalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'total'),
      );
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition> totalEqualTo(
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition>
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition> totalLessThan(
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

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterFilterCondition> totalBetween(
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

extension OrderItemDtoQueryObject
    on QueryBuilder<OrderItemDto, OrderItemDto, QFilterCondition> {}

extension OrderItemDtoQueryLinks
    on QueryBuilder<OrderItemDto, OrderItemDto, QFilterCondition> {}

extension OrderItemDtoQuerySortBy
    on QueryBuilder<OrderItemDto, OrderItemDto, QSortBy> {
  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> sortByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> sortByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> sortByProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.asc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> sortByProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.desc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> sortByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> sortByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }
}

extension OrderItemDtoQuerySortThenBy
    on QueryBuilder<OrderItemDto, OrderItemDto, QSortThenBy> {
  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> thenByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> thenByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> thenByProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.asc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> thenByProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.desc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> thenByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QAfterSortBy> thenByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }
}

extension OrderItemDtoQueryWhereDistinct
    on QueryBuilder<OrderItemDto, OrderItemDto, QDistinct> {
  QueryBuilder<OrderItemDto, OrderItemDto, QDistinct> distinctByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'price');
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QDistinct> distinctByProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productId');
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QDistinct> distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<OrderItemDto, OrderItemDto, QDistinct> distinctByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'total');
    });
  }
}

extension OrderItemDtoQueryProperty
    on QueryBuilder<OrderItemDto, OrderItemDto, QQueryProperty> {
  QueryBuilder<OrderItemDto, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OrderItemDto, double?, QQueryOperations> priceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'price');
    });
  }

  QueryBuilder<OrderItemDto, int?, QQueryOperations> productIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productId');
    });
  }

  QueryBuilder<OrderItemDto, int?, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<OrderItemDto, double?, QQueryOperations> totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }
}
