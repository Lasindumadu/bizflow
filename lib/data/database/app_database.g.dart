// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellingPriceMeta = const VerificationMeta(
    'sellingPrice',
  );
  @override
  late final GeneratedColumn<double> sellingPrice = GeneratedColumn<double>(
    'selling_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockQuantityMeta = const VerificationMeta(
    'stockQuantity',
  );
  @override
  late final GeneratedColumn<int> stockQuantity = GeneratedColumn<int>(
    'stock_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lowStockThresholdMeta = const VerificationMeta(
    'lowStockThreshold',
  );
  @override
  late final GeneratedColumn<int> lowStockThreshold = GeneratedColumn<int>(
    'low_stock_threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sku,
    category,
    purchasePrice,
    sellingPrice,
    stockQuantity,
    lowStockThreshold,
    barcode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('selling_price')) {
      context.handle(
        _sellingPriceMeta,
        sellingPrice.isAcceptableOrUnknown(
          data['selling_price']!,
          _sellingPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sellingPriceMeta);
    }
    if (data.containsKey('stock_quantity')) {
      context.handle(
        _stockQuantityMeta,
        stockQuantity.isAcceptableOrUnknown(
          data['stock_quantity']!,
          _stockQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stockQuantityMeta);
    }
    if (data.containsKey('low_stock_threshold')) {
      context.handle(
        _lowStockThresholdMeta,
        lowStockThreshold.isAcceptableOrUnknown(
          data['low_stock_threshold']!,
          _lowStockThresholdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lowStockThresholdMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      )!,
      sellingPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}selling_price'],
      )!,
      stockQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_quantity'],
      )!,
      lowStockThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}low_stock_threshold'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double purchasePrice;
  final double sellingPrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final String barcode;
  const ProductRow({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.lowStockThreshold,
    required this.barcode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sku'] = Variable<String>(sku);
    map['category'] = Variable<String>(category);
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['selling_price'] = Variable<double>(sellingPrice);
    map['stock_quantity'] = Variable<int>(stockQuantity);
    map['low_stock_threshold'] = Variable<int>(lowStockThreshold);
    map['barcode'] = Variable<String>(barcode);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      sku: Value(sku),
      category: Value(category),
      purchasePrice: Value(purchasePrice),
      sellingPrice: Value(sellingPrice),
      stockQuantity: Value(stockQuantity),
      lowStockThreshold: Value(lowStockThreshold),
      barcode: Value(barcode),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sku: serializer.fromJson<String>(json['sku']),
      category: serializer.fromJson<String>(json['category']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      sellingPrice: serializer.fromJson<double>(json['sellingPrice']),
      stockQuantity: serializer.fromJson<int>(json['stockQuantity']),
      lowStockThreshold: serializer.fromJson<int>(json['lowStockThreshold']),
      barcode: serializer.fromJson<String>(json['barcode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sku': serializer.toJson<String>(sku),
      'category': serializer.toJson<String>(category),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'sellingPrice': serializer.toJson<double>(sellingPrice),
      'stockQuantity': serializer.toJson<int>(stockQuantity),
      'lowStockThreshold': serializer.toJson<int>(lowStockThreshold),
      'barcode': serializer.toJson<String>(barcode),
    };
  }

  ProductRow copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    double? purchasePrice,
    double? sellingPrice,
    int? stockQuantity,
    int? lowStockThreshold,
    String? barcode,
  }) => ProductRow(
    id: id ?? this.id,
    name: name ?? this.name,
    sku: sku ?? this.sku,
    category: category ?? this.category,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    sellingPrice: sellingPrice ?? this.sellingPrice,
    stockQuantity: stockQuantity ?? this.stockQuantity,
    lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    barcode: barcode ?? this.barcode,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sku: data.sku.present ? data.sku.value : this.sku,
      category: data.category.present ? data.category.value : this.category,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      sellingPrice: data.sellingPrice.present
          ? data.sellingPrice.value
          : this.sellingPrice,
      stockQuantity: data.stockQuantity.present
          ? data.stockQuantity.value
          : this.stockQuantity,
      lowStockThreshold: data.lowStockThreshold.present
          ? data.lowStockThreshold.value
          : this.lowStockThreshold,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('category: $category, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('barcode: $barcode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sku,
    category,
    purchasePrice,
    sellingPrice,
    stockQuantity,
    lowStockThreshold,
    barcode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.sku == this.sku &&
          other.category == this.category &&
          other.purchasePrice == this.purchasePrice &&
          other.sellingPrice == this.sellingPrice &&
          other.stockQuantity == this.stockQuantity &&
          other.lowStockThreshold == this.lowStockThreshold &&
          other.barcode == this.barcode);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> sku;
  final Value<String> category;
  final Value<double> purchasePrice;
  final Value<double> sellingPrice;
  final Value<int> stockQuantity;
  final Value<int> lowStockThreshold;
  final Value<String> barcode;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sku = const Value.absent(),
    this.category = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.sellingPrice = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.barcode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String name,
    required String sku,
    required String category,
    required double purchasePrice,
    required double sellingPrice,
    required int stockQuantity,
    required int lowStockThreshold,
    this.barcode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sku = Value(sku),
       category = Value(category),
       purchasePrice = Value(purchasePrice),
       sellingPrice = Value(sellingPrice),
       stockQuantity = Value(stockQuantity),
       lowStockThreshold = Value(lowStockThreshold);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? sku,
    Expression<String>? category,
    Expression<double>? purchasePrice,
    Expression<double>? sellingPrice,
    Expression<int>? stockQuantity,
    Expression<int>? lowStockThreshold,
    Expression<String>? barcode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (category != null) 'category': category,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (sellingPrice != null) 'selling_price': sellingPrice,
      if (stockQuantity != null) 'stock_quantity': stockQuantity,
      if (lowStockThreshold != null) 'low_stock_threshold': lowStockThreshold,
      if (barcode != null) 'barcode': barcode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? sku,
    Value<String>? category,
    Value<double>? purchasePrice,
    Value<double>? sellingPrice,
    Value<int>? stockQuantity,
    Value<int>? lowStockThreshold,
    Value<String>? barcode,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      barcode: barcode ?? this.barcode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (sellingPrice.present) {
      map['selling_price'] = Variable<double>(sellingPrice.value);
    }
    if (stockQuantity.present) {
      map['stock_quantity'] = Variable<int>(stockQuantity.value);
    }
    if (lowStockThreshold.present) {
      map['low_stock_threshold'] = Variable<int>(lowStockThreshold.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('category: $category, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('barcode: $barcode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  const Category({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(id: Value(id), name: Value(name));
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Category copyWith({String? id, String? name}) =>
      Category(id: id ?? this.id, name: name ?? this.name);
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category && other.id == this.id && other.name == this.name);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, Sale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountMeta = const VerificationMeta(
    'discount',
  );
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
    'discount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAmountMeta = const VerificationMeta(
    'paidAmount',
  );
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
    'paid_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cash'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('completed'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    subtotal,
    discount,
    total,
    paidAmount,
    paymentMethod,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('discount')) {
      context.handle(
        _discountMeta,
        discount.isAcceptableOrUnknown(data['discount']!, _discountMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
        _paidAmountMeta,
        paidAmount.isAcceptableOrUnknown(data['paid_amount']!, _paidAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAmountMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      discount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      paidAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}paid_amount'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class Sale extends DataClass implements Insertable<Sale> {
  final String id;
  final String? customerId;
  final double subtotal;
  final double discount;
  final double total;
  final double paidAmount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  const Sale({
    required this.id,
    this.customerId,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paidAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['subtotal'] = Variable<double>(subtotal);
    map['discount'] = Variable<double>(discount);
    map['total'] = Variable<double>(total);
    map['paid_amount'] = Variable<double>(paidAmount);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      subtotal: Value(subtotal),
      discount: Value(discount),
      total: Value(total),
      paidAmount: Value(paidAmount),
      paymentMethod: Value(paymentMethod),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Sale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      discount: serializer.fromJson<double>(json['discount']),
      total: serializer.fromJson<double>(json['total']),
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String?>(customerId),
      'subtotal': serializer.toJson<double>(subtotal),
      'discount': serializer.toJson<double>(discount),
      'total': serializer.toJson<double>(total),
      'paidAmount': serializer.toJson<double>(paidAmount),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Sale copyWith({
    String? id,
    Value<String?> customerId = const Value.absent(),
    double? subtotal,
    double? discount,
    double? total,
    double? paidAmount,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
  }) => Sale(
    id: id ?? this.id,
    customerId: customerId.present ? customerId.value : this.customerId,
    subtotal: subtotal ?? this.subtotal,
    discount: discount ?? this.discount,
    total: total ?? this.total,
    paidAmount: paidAmount ?? this.paidAmount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  Sale copyWithCompanion(SalesCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discount: data.discount.present ? data.discount.value : this.discount,
      total: data.total.present ? data.total.value : this.total,
      paidAmount: data.paidAmount.present
          ? data.paidAmount.value
          : this.paidAmount,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('total: $total, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    subtotal,
    discount,
    total,
    paidAmount,
    paymentMethod,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.subtotal == this.subtotal &&
          other.discount == this.discount &&
          other.total == this.total &&
          other.paidAmount == this.paidAmount &&
          other.paymentMethod == this.paymentMethod &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class SalesCompanion extends UpdateCompanion<Sale> {
  final Value<String> id;
  final Value<String?> customerId;
  final Value<double> subtotal;
  final Value<double> discount;
  final Value<double> total;
  final Value<double> paidAmount;
  final Value<String> paymentMethod;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discount = const Value.absent(),
    this.total = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    this.customerId = const Value.absent(),
    required double subtotal,
    this.discount = const Value.absent(),
    required double total,
    required double paidAmount,
    this.paymentMethod = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       subtotal = Value(subtotal),
       total = Value(total),
       paidAmount = Value(paidAmount),
       createdAt = Value(createdAt);
  static Insertable<Sale> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<double>? subtotal,
    Expression<double>? discount,
    Expression<double>? total,
    Expression<double>? paidAmount,
    Expression<String>? paymentMethod,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (subtotal != null) 'subtotal': subtotal,
      if (discount != null) 'discount': discount,
      if (total != null) 'total': total,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith({
    Value<String>? id,
    Value<String?>? customerId,
    Value<double>? subtotal,
    Value<double>? discount,
    Value<double>? total,
    Value<double>? paidAmount,
    Value<String>? paymentMethod,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('total: $total, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleItemsTable extends SaleItems
    with TableInfo<$SaleItemsTable, SaleItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleId,
    productId,
    productName,
    quantity,
    unitPrice,
    purchasePrice,
    total,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
    );
  }

  @override
  $SaleItemsTable createAlias(String alias) {
    return $SaleItemsTable(attachedDatabase, alias);
  }
}

class SaleItem extends DataClass implements Insertable<SaleItem> {
  final String id;
  final String saleId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double purchasePrice;
  final double total;
  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.purchasePrice,
    required this.total,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['total'] = Variable<double>(total);
    return map;
  }

  SaleItemsCompanion toCompanion(bool nullToAbsent) {
    return SaleItemsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      productId: Value(productId),
      productName: Value(productName),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      purchasePrice: Value(purchasePrice),
      total: Value(total),
    );
  }

  factory SaleItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleItem(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      total: serializer.fromJson<double>(json['total']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'total': serializer.toJson<double>(total),
    };
  }

  SaleItem copyWith({
    String? id,
    String? saleId,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? purchasePrice,
    double? total,
  }) => SaleItem(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    total: total ?? this.total,
  );
  SaleItem copyWithCompanion(SaleItemsCompanion data) {
    return SaleItem(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      total: data.total.present ? data.total.value : this.total,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleItem(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('total: $total')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saleId,
    productId,
    productName,
    quantity,
    unitPrice,
    purchasePrice,
    total,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleItem &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.purchasePrice == this.purchasePrice &&
          other.total == this.total);
}

class SaleItemsCompanion extends UpdateCompanion<SaleItem> {
  final Value<String> id;
  final Value<String> saleId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<int> quantity;
  final Value<double> unitPrice;
  final Value<double> purchasePrice;
  final Value<double> total;
  final Value<int> rowid;
  const SaleItemsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.total = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleItemsCompanion.insert({
    required String id,
    required String saleId,
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required double purchasePrice,
    required double total,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleId = Value(saleId),
       productId = Value(productId),
       productName = Value(productName),
       quantity = Value(quantity),
       unitPrice = Value(unitPrice),
       purchasePrice = Value(purchasePrice),
       total = Value(total);
  static Insertable<SaleItem> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<int>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? purchasePrice,
    Expression<double>? total,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (total != null) 'total': total,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? saleId,
    Value<String>? productId,
    Value<String>? productName,
    Value<int>? quantity,
    Value<double>? unitPrice,
    Value<double>? purchasePrice,
    Value<double>? total,
    Value<int>? rowid,
  }) {
    return SaleItemsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      total: total ?? this.total,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('total: $total, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _outstandingBalanceMeta =
      const VerificationMeta('outstandingBalance');
  @override
  late final GeneratedColumn<double> outstandingBalance =
      GeneratedColumn<double>(
        'outstanding_balance',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _loyaltyPointsMeta = const VerificationMeta(
    'loyaltyPoints',
  );
  @override
  late final GeneratedColumn<int> loyaltyPoints = GeneratedColumn<int>(
    'loyalty_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pointsBalanceMeta = const VerificationMeta(
    'pointsBalance',
  );
  @override
  late final GeneratedColumn<int> pointsBalance = GeneratedColumn<int>(
    'points_balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _loyaltyTierMeta = const VerificationMeta(
    'loyaltyTier',
  );
  @override
  late final GeneratedColumn<String> loyaltyTier = GeneratedColumn<String>(
    'loyalty_tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Bronze'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    email,
    address,
    outstandingBalance,
    loyaltyPoints,
    pointsBalance,
    loyaltyTier,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('outstanding_balance')) {
      context.handle(
        _outstandingBalanceMeta,
        outstandingBalance.isAcceptableOrUnknown(
          data['outstanding_balance']!,
          _outstandingBalanceMeta,
        ),
      );
    }
    if (data.containsKey('loyalty_points')) {
      context.handle(
        _loyaltyPointsMeta,
        loyaltyPoints.isAcceptableOrUnknown(
          data['loyalty_points']!,
          _loyaltyPointsMeta,
        ),
      );
    }
    if (data.containsKey('points_balance')) {
      context.handle(
        _pointsBalanceMeta,
        pointsBalance.isAcceptableOrUnknown(
          data['points_balance']!,
          _pointsBalanceMeta,
        ),
      );
    }
    if (data.containsKey('loyalty_tier')) {
      context.handle(
        _loyaltyTierMeta,
        loyaltyTier.isAcceptableOrUnknown(
          data['loyalty_tier']!,
          _loyaltyTierMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      outstandingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}outstanding_balance'],
      )!,
      loyaltyPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}loyalty_points'],
      )!,
      pointsBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points_balance'],
      )!,
      loyaltyTier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loyalty_tier'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final double outstandingBalance;

  /// Loyalty programme — lifetime points EARNED by this customer.
  /// This value is monotonic (only ever grows) and is the sole source
  /// for tier calculation, so redeeming points never demotes a tier.
  final int loyaltyPoints;

  /// Loyalty programme — spendable (redeemable) point balance.
  /// Earned points raise this; redeeming points lowers it. It never
  /// affects [loyaltyTier].
  final int pointsBalance;

  /// Cached tier name derived from [loyaltyPoints] (kept for fast display).
  final String loyaltyTier;
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.outstandingBalance,
    required this.loyaltyPoints,
    required this.pointsBalance,
    required this.loyaltyTier,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    map['address'] = Variable<String>(address);
    map['outstanding_balance'] = Variable<double>(outstandingBalance);
    map['loyalty_points'] = Variable<int>(loyaltyPoints);
    map['points_balance'] = Variable<int>(pointsBalance);
    map['loyalty_tier'] = Variable<String>(loyaltyTier);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      email: Value(email),
      address: Value(address),
      outstandingBalance: Value(outstandingBalance),
      loyaltyPoints: Value(loyaltyPoints),
      pointsBalance: Value(pointsBalance),
      loyaltyTier: Value(loyaltyTier),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      address: serializer.fromJson<String>(json['address']),
      outstandingBalance: serializer.fromJson<double>(
        json['outstandingBalance'],
      ),
      loyaltyPoints: serializer.fromJson<int>(json['loyaltyPoints']),
      pointsBalance: serializer.fromJson<int>(json['pointsBalance']),
      loyaltyTier: serializer.fromJson<String>(json['loyaltyTier']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'address': serializer.toJson<String>(address),
      'outstandingBalance': serializer.toJson<double>(outstandingBalance),
      'loyaltyPoints': serializer.toJson<int>(loyaltyPoints),
      'pointsBalance': serializer.toJson<int>(pointsBalance),
      'loyaltyTier': serializer.toJson<String>(loyaltyTier),
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? outstandingBalance,
    int? loyaltyPoints,
    int? pointsBalance,
    String? loyaltyTier,
  }) => Customer(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    address: address ?? this.address,
    outstandingBalance: outstandingBalance ?? this.outstandingBalance,
    loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
    pointsBalance: pointsBalance ?? this.pointsBalance,
    loyaltyTier: loyaltyTier ?? this.loyaltyTier,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      outstandingBalance: data.outstandingBalance.present
          ? data.outstandingBalance.value
          : this.outstandingBalance,
      loyaltyPoints: data.loyaltyPoints.present
          ? data.loyaltyPoints.value
          : this.loyaltyPoints,
      pointsBalance: data.pointsBalance.present
          ? data.pointsBalance.value
          : this.pointsBalance,
      loyaltyTier: data.loyaltyTier.present
          ? data.loyaltyTier.value
          : this.loyaltyTier,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('outstandingBalance: $outstandingBalance, ')
          ..write('loyaltyPoints: $loyaltyPoints, ')
          ..write('pointsBalance: $pointsBalance, ')
          ..write('loyaltyTier: $loyaltyTier')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phone,
    email,
    address,
    outstandingBalance,
    loyaltyPoints,
    pointsBalance,
    loyaltyTier,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.outstandingBalance == this.outstandingBalance &&
          other.loyaltyPoints == this.loyaltyPoints &&
          other.pointsBalance == this.pointsBalance &&
          other.loyaltyTier == this.loyaltyTier);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String> email;
  final Value<String> address;
  final Value<double> outstandingBalance;
  final Value<int> loyaltyPoints;
  final Value<int> pointsBalance;
  final Value<String> loyaltyTier;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.outstandingBalance = const Value.absent(),
    this.loyaltyPoints = const Value.absent(),
    this.pointsBalance = const Value.absent(),
    this.loyaltyTier = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.outstandingBalance = const Value.absent(),
    this.loyaltyPoints = const Value.absent(),
    this.pointsBalance = const Value.absent(),
    this.loyaltyTier = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<double>? outstandingBalance,
    Expression<int>? loyaltyPoints,
    Expression<int>? pointsBalance,
    Expression<String>? loyaltyTier,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (outstandingBalance != null) 'outstanding_balance': outstandingBalance,
      if (loyaltyPoints != null) 'loyalty_points': loyaltyPoints,
      if (pointsBalance != null) 'points_balance': pointsBalance,
      if (loyaltyTier != null) 'loyalty_tier': loyaltyTier,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<String>? email,
    Value<String>? address,
    Value<double>? outstandingBalance,
    Value<int>? loyaltyPoints,
    Value<int>? pointsBalance,
    Value<String>? loyaltyTier,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      loyaltyTier: loyaltyTier ?? this.loyaltyTier,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (outstandingBalance.present) {
      map['outstanding_balance'] = Variable<double>(outstandingBalance.value);
    }
    if (loyaltyPoints.present) {
      map['loyalty_points'] = Variable<int>(loyaltyPoints.value);
    }
    if (pointsBalance.present) {
      map['points_balance'] = Variable<int>(pointsBalance.value);
    }
    if (loyaltyTier.present) {
      map['loyalty_tier'] = Variable<String>(loyaltyTier.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('outstandingBalance: $outstandingBalance, ')
          ..write('loyaltyPoints: $loyaltyPoints, ')
          ..write('pointsBalance: $pointsBalance, ')
          ..write('loyaltyTier: $loyaltyTier, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    category,
    amount,
    date,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String note;
  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    map['note'] = Variable<String>(note);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      title: Value(title),
      category: Value(category),
      amount: Value(amount),
      date: Value(date),
      note: Value(note),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String>(note),
    };
  }

  Expense copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    DateTime? date,
    String? note,
  }) => Expense(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    note: note ?? this.note,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, category, amount, date, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.note == this.note);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> category;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String> note;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String title,
    required String category,
    required double amount,
    required DateTime date,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       category = Value(category),
       amount = Value(amount),
       date = Value(date);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? category,
    Value<double>? amount,
    Value<DateTime>? date,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousStockMeta = const VerificationMeta(
    'previousStock',
  );
  @override
  late final GeneratedColumn<int> previousStock = GeneratedColumn<int>(
    'previous_stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newStockMeta = const VerificationMeta(
    'newStock',
  );
  @override
  late final GeneratedColumn<int> newStock = GeneratedColumn<int>(
    'new_stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    type,
    quantity,
    previousStock,
    newStock,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('previous_stock')) {
      context.handle(
        _previousStockMeta,
        previousStock.isAcceptableOrUnknown(
          data['previous_stock']!,
          _previousStockMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousStockMeta);
    }
    if (data.containsKey('new_stock')) {
      context.handle(
        _newStockMeta,
        newStock.isAcceptableOrUnknown(data['new_stock']!, _newStockMeta),
      );
    } else if (isInserting) {
      context.missing(_newStockMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      previousStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}previous_stock'],
      )!,
      newStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_stock'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovement extends DataClass implements Insertable<StockMovement> {
  final String id;
  final String productId;
  final String type;
  final int quantity;
  final int previousStock;
  final int newStock;
  final String note;
  final DateTime createdAt;
  const StockMovement({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    required this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['type'] = Variable<String>(type);
    map['quantity'] = Variable<int>(quantity);
    map['previous_stock'] = Variable<int>(previousStock);
    map['new_stock'] = Variable<int>(newStock);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      type: Value(type),
      quantity: Value(quantity),
      previousStock: Value(previousStock),
      newStock: Value(newStock),
      note: Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory StockMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovement(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      type: serializer.fromJson<String>(json['type']),
      quantity: serializer.fromJson<int>(json['quantity']),
      previousStock: serializer.fromJson<int>(json['previousStock']),
      newStock: serializer.fromJson<int>(json['newStock']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'type': serializer.toJson<String>(type),
      'quantity': serializer.toJson<int>(quantity),
      'previousStock': serializer.toJson<int>(previousStock),
      'newStock': serializer.toJson<int>(newStock),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StockMovement copyWith({
    String? id,
    String? productId,
    String? type,
    int? quantity,
    int? previousStock,
    int? newStock,
    String? note,
    DateTime? createdAt,
  }) => StockMovement(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    type: type ?? this.type,
    quantity: quantity ?? this.quantity,
    previousStock: previousStock ?? this.previousStock,
    newStock: newStock ?? this.newStock,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  StockMovement copyWithCompanion(StockMovementsCompanion data) {
    return StockMovement(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      type: data.type.present ? data.type.value : this.type,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      previousStock: data.previousStock.present
          ? data.previousStock.value
          : this.previousStock,
      newStock: data.newStock.present ? data.newStock.value : this.newStock,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovement(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('previousStock: $previousStock, ')
          ..write('newStock: $newStock, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    type,
    quantity,
    previousStock,
    newStock,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovement &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.type == this.type &&
          other.quantity == this.quantity &&
          other.previousStock == this.previousStock &&
          other.newStock == this.newStock &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovement> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> type;
  final Value<int> quantity;
  final Value<int> previousStock;
  final Value<int> newStock;
  final Value<String> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.type = const Value.absent(),
    this.quantity = const Value.absent(),
    this.previousStock = const Value.absent(),
    this.newStock = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    required String id,
    required String productId,
    required String type,
    required int quantity,
    required int previousStock,
    required int newStock,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       type = Value(type),
       quantity = Value(quantity),
       previousStock = Value(previousStock),
       newStock = Value(newStock),
       createdAt = Value(createdAt);
  static Insertable<StockMovement> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? type,
    Expression<int>? quantity,
    Expression<int>? previousStock,
    Expression<int>? newStock,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (type != null) 'type': type,
      if (quantity != null) 'quantity': quantity,
      if (previousStock != null) 'previous_stock': previousStock,
      if (newStock != null) 'new_stock': newStock,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? type,
    Value<int>? quantity,
    Value<int>? previousStock,
    Value<int>? newStock,
    Value<String>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      previousStock: previousStock ?? this.previousStock,
      newStock: newStock ?? this.newStock,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (previousStock.present) {
      map['previous_stock'] = Variable<int>(previousStock.value);
    }
    if (newStock.present) {
      map['new_stock'] = Variable<int>(newStock.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('previousStock: $previousStock, ')
          ..write('newStock: $newStock, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BusinessSettingsTable extends BusinessSettings
    with TableInfo<$BusinessSettingsTable, BusinessSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BusinessSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessNameMeta = const VerificationMeta(
    'businessName',
  );
  @override
  late final GeneratedColumn<String> businessName = GeneratedColumn<String>(
    'business_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('My Business'),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _loyaltyEnabledMeta = const VerificationMeta(
    'loyaltyEnabled',
  );
  @override
  late final GeneratedColumn<bool> loyaltyEnabled = GeneratedColumn<bool>(
    'loyalty_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("loyalty_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _loyaltyEarnRateMeta = const VerificationMeta(
    'loyaltyEarnRate',
  );
  @override
  late final GeneratedColumn<double> loyaltyEarnRate = GeneratedColumn<double>(
    'loyalty_earn_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _loyaltyRedeemValueMeta =
      const VerificationMeta('loyaltyRedeemValue');
  @override
  late final GeneratedColumn<double> loyaltyRedeemValue =
      GeneratedColumn<double>(
        'loyalty_redeem_value',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.01),
      );
  static const VerificationMeta _receiptHeaderMeta = const VerificationMeta(
    'receiptHeader',
  );
  @override
  late final GeneratedColumn<String> receiptHeader = GeneratedColumn<String>(
    'receipt_header',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Thank you for your purchase!'),
  );
  static const VerificationMeta _receiptFooterMeta = const VerificationMeta(
    'receiptFooter',
  );
  @override
  late final GeneratedColumn<String> receiptFooter = GeneratedColumn<String>(
    'receipt_footer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _receiptShowPhoneMeta = const VerificationMeta(
    'receiptShowPhone',
  );
  @override
  late final GeneratedColumn<bool> receiptShowPhone = GeneratedColumn<bool>(
    'receipt_show_phone',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("receipt_show_phone" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _receiptShowAddressMeta =
      const VerificationMeta('receiptShowAddress');
  @override
  late final GeneratedColumn<bool> receiptShowAddress = GeneratedColumn<bool>(
    'receipt_show_address',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("receipt_show_address" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _receiptNoteMeta = const VerificationMeta(
    'receiptNote',
  );
  @override
  late final GeneratedColumn<String> receiptNote = GeneratedColumn<String>(
    'receipt_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessName,
    address,
    phone,
    email,
    currency,
    loyaltyEnabled,
    loyaltyEarnRate,
    loyaltyRedeemValue,
    receiptHeader,
    receiptFooter,
    receiptShowPhone,
    receiptShowAddress,
    receiptNote,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'business_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<BusinessSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_name')) {
      context.handle(
        _businessNameMeta,
        businessName.isAcceptableOrUnknown(
          data['business_name']!,
          _businessNameMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('loyalty_enabled')) {
      context.handle(
        _loyaltyEnabledMeta,
        loyaltyEnabled.isAcceptableOrUnknown(
          data['loyalty_enabled']!,
          _loyaltyEnabledMeta,
        ),
      );
    }
    if (data.containsKey('loyalty_earn_rate')) {
      context.handle(
        _loyaltyEarnRateMeta,
        loyaltyEarnRate.isAcceptableOrUnknown(
          data['loyalty_earn_rate']!,
          _loyaltyEarnRateMeta,
        ),
      );
    }
    if (data.containsKey('loyalty_redeem_value')) {
      context.handle(
        _loyaltyRedeemValueMeta,
        loyaltyRedeemValue.isAcceptableOrUnknown(
          data['loyalty_redeem_value']!,
          _loyaltyRedeemValueMeta,
        ),
      );
    }
    if (data.containsKey('receipt_header')) {
      context.handle(
        _receiptHeaderMeta,
        receiptHeader.isAcceptableOrUnknown(
          data['receipt_header']!,
          _receiptHeaderMeta,
        ),
      );
    }
    if (data.containsKey('receipt_footer')) {
      context.handle(
        _receiptFooterMeta,
        receiptFooter.isAcceptableOrUnknown(
          data['receipt_footer']!,
          _receiptFooterMeta,
        ),
      );
    }
    if (data.containsKey('receipt_show_phone')) {
      context.handle(
        _receiptShowPhoneMeta,
        receiptShowPhone.isAcceptableOrUnknown(
          data['receipt_show_phone']!,
          _receiptShowPhoneMeta,
        ),
      );
    }
    if (data.containsKey('receipt_show_address')) {
      context.handle(
        _receiptShowAddressMeta,
        receiptShowAddress.isAcceptableOrUnknown(
          data['receipt_show_address']!,
          _receiptShowAddressMeta,
        ),
      );
    }
    if (data.containsKey('receipt_note')) {
      context.handle(
        _receiptNoteMeta,
        receiptNote.isAcceptableOrUnknown(
          data['receipt_note']!,
          _receiptNoteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BusinessSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BusinessSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      loyaltyEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}loyalty_enabled'],
      )!,
      loyaltyEarnRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}loyalty_earn_rate'],
      )!,
      loyaltyRedeemValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}loyalty_redeem_value'],
      )!,
      receiptHeader: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_header'],
      )!,
      receiptFooter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_footer'],
      )!,
      receiptShowPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}receipt_show_phone'],
      )!,
      receiptShowAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}receipt_show_address'],
      )!,
      receiptNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_note'],
      )!,
    );
  }

  @override
  $BusinessSettingsTable createAlias(String alias) {
    return $BusinessSettingsTable(attachedDatabase, alias);
  }
}

class BusinessSetting extends DataClass implements Insertable<BusinessSetting> {
  final String id;
  final String businessName;
  final String address;
  final String phone;
  final String email;
  final String currency;

  /// Loyalty programme settings.
  final bool loyaltyEnabled;

  /// Points earned per unit of currency spent (e.g. 1 point per 1.0).
  final double loyaltyEarnRate;

  /// Currency value of a single point when redeemed.
  final double loyaltyRedeemValue;

  /// Receipt branding: text shown as the receipt header line.
  final String receiptHeader;

  /// Receipt branding: footer note (returns policy, contact, etc.).
  final String receiptFooter;

  /// Whether to print the business phone on the receipt.
  final bool receiptShowPhone;

  /// Whether to print the business address on the receipt.
  final bool receiptShowAddress;

  /// Optional note printed under the receipt total (e.g. tax info).
  final String receiptNote;
  const BusinessSetting({
    required this.id,
    required this.businessName,
    required this.address,
    required this.phone,
    required this.email,
    required this.currency,
    required this.loyaltyEnabled,
    required this.loyaltyEarnRate,
    required this.loyaltyRedeemValue,
    required this.receiptHeader,
    required this.receiptFooter,
    required this.receiptShowPhone,
    required this.receiptShowAddress,
    required this.receiptNote,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_name'] = Variable<String>(businessName);
    map['address'] = Variable<String>(address);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    map['currency'] = Variable<String>(currency);
    map['loyalty_enabled'] = Variable<bool>(loyaltyEnabled);
    map['loyalty_earn_rate'] = Variable<double>(loyaltyEarnRate);
    map['loyalty_redeem_value'] = Variable<double>(loyaltyRedeemValue);
    map['receipt_header'] = Variable<String>(receiptHeader);
    map['receipt_footer'] = Variable<String>(receiptFooter);
    map['receipt_show_phone'] = Variable<bool>(receiptShowPhone);
    map['receipt_show_address'] = Variable<bool>(receiptShowAddress);
    map['receipt_note'] = Variable<String>(receiptNote);
    return map;
  }

  BusinessSettingsCompanion toCompanion(bool nullToAbsent) {
    return BusinessSettingsCompanion(
      id: Value(id),
      businessName: Value(businessName),
      address: Value(address),
      phone: Value(phone),
      email: Value(email),
      currency: Value(currency),
      loyaltyEnabled: Value(loyaltyEnabled),
      loyaltyEarnRate: Value(loyaltyEarnRate),
      loyaltyRedeemValue: Value(loyaltyRedeemValue),
      receiptHeader: Value(receiptHeader),
      receiptFooter: Value(receiptFooter),
      receiptShowPhone: Value(receiptShowPhone),
      receiptShowAddress: Value(receiptShowAddress),
      receiptNote: Value(receiptNote),
    );
  }

  factory BusinessSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BusinessSetting(
      id: serializer.fromJson<String>(json['id']),
      businessName: serializer.fromJson<String>(json['businessName']),
      address: serializer.fromJson<String>(json['address']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      currency: serializer.fromJson<String>(json['currency']),
      loyaltyEnabled: serializer.fromJson<bool>(json['loyaltyEnabled']),
      loyaltyEarnRate: serializer.fromJson<double>(json['loyaltyEarnRate']),
      loyaltyRedeemValue: serializer.fromJson<double>(
        json['loyaltyRedeemValue'],
      ),
      receiptHeader: serializer.fromJson<String>(json['receiptHeader']),
      receiptFooter: serializer.fromJson<String>(json['receiptFooter']),
      receiptShowPhone: serializer.fromJson<bool>(json['receiptShowPhone']),
      receiptShowAddress: serializer.fromJson<bool>(json['receiptShowAddress']),
      receiptNote: serializer.fromJson<String>(json['receiptNote']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessName': serializer.toJson<String>(businessName),
      'address': serializer.toJson<String>(address),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'currency': serializer.toJson<String>(currency),
      'loyaltyEnabled': serializer.toJson<bool>(loyaltyEnabled),
      'loyaltyEarnRate': serializer.toJson<double>(loyaltyEarnRate),
      'loyaltyRedeemValue': serializer.toJson<double>(loyaltyRedeemValue),
      'receiptHeader': serializer.toJson<String>(receiptHeader),
      'receiptFooter': serializer.toJson<String>(receiptFooter),
      'receiptShowPhone': serializer.toJson<bool>(receiptShowPhone),
      'receiptShowAddress': serializer.toJson<bool>(receiptShowAddress),
      'receiptNote': serializer.toJson<String>(receiptNote),
    };
  }

  BusinessSetting copyWith({
    String? id,
    String? businessName,
    String? address,
    String? phone,
    String? email,
    String? currency,
    bool? loyaltyEnabled,
    double? loyaltyEarnRate,
    double? loyaltyRedeemValue,
    String? receiptHeader,
    String? receiptFooter,
    bool? receiptShowPhone,
    bool? receiptShowAddress,
    String? receiptNote,
  }) => BusinessSetting(
    id: id ?? this.id,
    businessName: businessName ?? this.businessName,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    currency: currency ?? this.currency,
    loyaltyEnabled: loyaltyEnabled ?? this.loyaltyEnabled,
    loyaltyEarnRate: loyaltyEarnRate ?? this.loyaltyEarnRate,
    loyaltyRedeemValue: loyaltyRedeemValue ?? this.loyaltyRedeemValue,
    receiptHeader: receiptHeader ?? this.receiptHeader,
    receiptFooter: receiptFooter ?? this.receiptFooter,
    receiptShowPhone: receiptShowPhone ?? this.receiptShowPhone,
    receiptShowAddress: receiptShowAddress ?? this.receiptShowAddress,
    receiptNote: receiptNote ?? this.receiptNote,
  );
  BusinessSetting copyWithCompanion(BusinessSettingsCompanion data) {
    return BusinessSetting(
      id: data.id.present ? data.id.value : this.id,
      businessName: data.businessName.present
          ? data.businessName.value
          : this.businessName,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      currency: data.currency.present ? data.currency.value : this.currency,
      loyaltyEnabled: data.loyaltyEnabled.present
          ? data.loyaltyEnabled.value
          : this.loyaltyEnabled,
      loyaltyEarnRate: data.loyaltyEarnRate.present
          ? data.loyaltyEarnRate.value
          : this.loyaltyEarnRate,
      loyaltyRedeemValue: data.loyaltyRedeemValue.present
          ? data.loyaltyRedeemValue.value
          : this.loyaltyRedeemValue,
      receiptHeader: data.receiptHeader.present
          ? data.receiptHeader.value
          : this.receiptHeader,
      receiptFooter: data.receiptFooter.present
          ? data.receiptFooter.value
          : this.receiptFooter,
      receiptShowPhone: data.receiptShowPhone.present
          ? data.receiptShowPhone.value
          : this.receiptShowPhone,
      receiptShowAddress: data.receiptShowAddress.present
          ? data.receiptShowAddress.value
          : this.receiptShowAddress,
      receiptNote: data.receiptNote.present
          ? data.receiptNote.value
          : this.receiptNote,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BusinessSetting(')
          ..write('id: $id, ')
          ..write('businessName: $businessName, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('currency: $currency, ')
          ..write('loyaltyEnabled: $loyaltyEnabled, ')
          ..write('loyaltyEarnRate: $loyaltyEarnRate, ')
          ..write('loyaltyRedeemValue: $loyaltyRedeemValue, ')
          ..write('receiptHeader: $receiptHeader, ')
          ..write('receiptFooter: $receiptFooter, ')
          ..write('receiptShowPhone: $receiptShowPhone, ')
          ..write('receiptShowAddress: $receiptShowAddress, ')
          ..write('receiptNote: $receiptNote')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessName,
    address,
    phone,
    email,
    currency,
    loyaltyEnabled,
    loyaltyEarnRate,
    loyaltyRedeemValue,
    receiptHeader,
    receiptFooter,
    receiptShowPhone,
    receiptShowAddress,
    receiptNote,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BusinessSetting &&
          other.id == this.id &&
          other.businessName == this.businessName &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.currency == this.currency &&
          other.loyaltyEnabled == this.loyaltyEnabled &&
          other.loyaltyEarnRate == this.loyaltyEarnRate &&
          other.loyaltyRedeemValue == this.loyaltyRedeemValue &&
          other.receiptHeader == this.receiptHeader &&
          other.receiptFooter == this.receiptFooter &&
          other.receiptShowPhone == this.receiptShowPhone &&
          other.receiptShowAddress == this.receiptShowAddress &&
          other.receiptNote == this.receiptNote);
}

class BusinessSettingsCompanion extends UpdateCompanion<BusinessSetting> {
  final Value<String> id;
  final Value<String> businessName;
  final Value<String> address;
  final Value<String> phone;
  final Value<String> email;
  final Value<String> currency;
  final Value<bool> loyaltyEnabled;
  final Value<double> loyaltyEarnRate;
  final Value<double> loyaltyRedeemValue;
  final Value<String> receiptHeader;
  final Value<String> receiptFooter;
  final Value<bool> receiptShowPhone;
  final Value<bool> receiptShowAddress;
  final Value<String> receiptNote;
  final Value<int> rowid;
  const BusinessSettingsCompanion({
    this.id = const Value.absent(),
    this.businessName = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.currency = const Value.absent(),
    this.loyaltyEnabled = const Value.absent(),
    this.loyaltyEarnRate = const Value.absent(),
    this.loyaltyRedeemValue = const Value.absent(),
    this.receiptHeader = const Value.absent(),
    this.receiptFooter = const Value.absent(),
    this.receiptShowPhone = const Value.absent(),
    this.receiptShowAddress = const Value.absent(),
    this.receiptNote = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BusinessSettingsCompanion.insert({
    required String id,
    this.businessName = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.currency = const Value.absent(),
    this.loyaltyEnabled = const Value.absent(),
    this.loyaltyEarnRate = const Value.absent(),
    this.loyaltyRedeemValue = const Value.absent(),
    this.receiptHeader = const Value.absent(),
    this.receiptFooter = const Value.absent(),
    this.receiptShowPhone = const Value.absent(),
    this.receiptShowAddress = const Value.absent(),
    this.receiptNote = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<BusinessSetting> custom({
    Expression<String>? id,
    Expression<String>? businessName,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? currency,
    Expression<bool>? loyaltyEnabled,
    Expression<double>? loyaltyEarnRate,
    Expression<double>? loyaltyRedeemValue,
    Expression<String>? receiptHeader,
    Expression<String>? receiptFooter,
    Expression<bool>? receiptShowPhone,
    Expression<bool>? receiptShowAddress,
    Expression<String>? receiptNote,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessName != null) 'business_name': businessName,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (currency != null) 'currency': currency,
      if (loyaltyEnabled != null) 'loyalty_enabled': loyaltyEnabled,
      if (loyaltyEarnRate != null) 'loyalty_earn_rate': loyaltyEarnRate,
      if (loyaltyRedeemValue != null)
        'loyalty_redeem_value': loyaltyRedeemValue,
      if (receiptHeader != null) 'receipt_header': receiptHeader,
      if (receiptFooter != null) 'receipt_footer': receiptFooter,
      if (receiptShowPhone != null) 'receipt_show_phone': receiptShowPhone,
      if (receiptShowAddress != null)
        'receipt_show_address': receiptShowAddress,
      if (receiptNote != null) 'receipt_note': receiptNote,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BusinessSettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? businessName,
    Value<String>? address,
    Value<String>? phone,
    Value<String>? email,
    Value<String>? currency,
    Value<bool>? loyaltyEnabled,
    Value<double>? loyaltyEarnRate,
    Value<double>? loyaltyRedeemValue,
    Value<String>? receiptHeader,
    Value<String>? receiptFooter,
    Value<bool>? receiptShowPhone,
    Value<bool>? receiptShowAddress,
    Value<String>? receiptNote,
    Value<int>? rowid,
  }) {
    return BusinessSettingsCompanion(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      loyaltyEnabled: loyaltyEnabled ?? this.loyaltyEnabled,
      loyaltyEarnRate: loyaltyEarnRate ?? this.loyaltyEarnRate,
      loyaltyRedeemValue: loyaltyRedeemValue ?? this.loyaltyRedeemValue,
      receiptHeader: receiptHeader ?? this.receiptHeader,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      receiptShowPhone: receiptShowPhone ?? this.receiptShowPhone,
      receiptShowAddress: receiptShowAddress ?? this.receiptShowAddress,
      receiptNote: receiptNote ?? this.receiptNote,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessName.present) {
      map['business_name'] = Variable<String>(businessName.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (loyaltyEnabled.present) {
      map['loyalty_enabled'] = Variable<bool>(loyaltyEnabled.value);
    }
    if (loyaltyEarnRate.present) {
      map['loyalty_earn_rate'] = Variable<double>(loyaltyEarnRate.value);
    }
    if (loyaltyRedeemValue.present) {
      map['loyalty_redeem_value'] = Variable<double>(loyaltyRedeemValue.value);
    }
    if (receiptHeader.present) {
      map['receipt_header'] = Variable<String>(receiptHeader.value);
    }
    if (receiptFooter.present) {
      map['receipt_footer'] = Variable<String>(receiptFooter.value);
    }
    if (receiptShowPhone.present) {
      map['receipt_show_phone'] = Variable<bool>(receiptShowPhone.value);
    }
    if (receiptShowAddress.present) {
      map['receipt_show_address'] = Variable<bool>(receiptShowAddress.value);
    }
    if (receiptNote.present) {
      map['receipt_note'] = Variable<String>(receiptNote.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BusinessSettingsCompanion(')
          ..write('id: $id, ')
          ..write('businessName: $businessName, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('currency: $currency, ')
          ..write('loyaltyEnabled: $loyaltyEnabled, ')
          ..write('loyaltyEarnRate: $loyaltyEarnRate, ')
          ..write('loyaltyRedeemValue: $loyaltyRedeemValue, ')
          ..write('receiptHeader: $receiptHeader, ')
          ..write('receiptFooter: $receiptFooter, ')
          ..write('receiptShowPhone: $receiptShowPhone, ')
          ..write('receiptShowAddress: $receiptShowAddress, ')
          ..write('receiptNote: $receiptNote, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleReturnsTable extends SaleReturns
    with TableInfo<$SaleReturnsTable, SaleReturn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleReturnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refundAmountMeta = const VerificationMeta(
    'refundAmount',
  );
  @override
  late final GeneratedColumn<double> refundAmount = GeneratedColumn<double>(
    'refund_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refundMethodMeta = const VerificationMeta(
    'refundMethod',
  );
  @override
  late final GeneratedColumn<String> refundMethod = GeneratedColumn<String>(
    'refund_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cash'),
  );
  static const VerificationMeta _restockedMeta = const VerificationMeta(
    'restocked',
  );
  @override
  late final GeneratedColumn<bool> restocked = GeneratedColumn<bool>(
    'restocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("restocked" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleId,
    customerId,
    refundAmount,
    refundMethod,
    restocked,
    reason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_returns';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleReturn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('refund_amount')) {
      context.handle(
        _refundAmountMeta,
        refundAmount.isAcceptableOrUnknown(
          data['refund_amount']!,
          _refundAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refundAmountMeta);
    }
    if (data.containsKey('refund_method')) {
      context.handle(
        _refundMethodMeta,
        refundMethod.isAcceptableOrUnknown(
          data['refund_method']!,
          _refundMethodMeta,
        ),
      );
    }
    if (data.containsKey('restocked')) {
      context.handle(
        _restockedMeta,
        restocked.isAcceptableOrUnknown(data['restocked']!, _restockedMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleReturn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleReturn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      refundAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}refund_amount'],
      )!,
      refundMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refund_method'],
      )!,
      restocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}restocked'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SaleReturnsTable createAlias(String alias) {
    return $SaleReturnsTable(attachedDatabase, alias);
  }
}

class SaleReturn extends DataClass implements Insertable<SaleReturn> {
  final String id;

  /// The sale being returned against.
  final String saleId;

  /// Optional customer on the original sale.
  final String? customerId;

  /// Total value refunded for this return.
  final double refundAmount;

  /// How the money was returned: cash, card, credit, etc.
  final String refundMethod;

  /// Whether restocked items were put back into inventory.
  final bool restocked;

  /// Free-form reason (e.g. "damaged", "wrong item").
  final String reason;
  final DateTime createdAt;
  const SaleReturn({
    required this.id,
    required this.saleId,
    this.customerId,
    required this.refundAmount,
    required this.refundMethod,
    required this.restocked,
    required this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['refund_amount'] = Variable<double>(refundAmount);
    map['refund_method'] = Variable<String>(refundMethod);
    map['restocked'] = Variable<bool>(restocked);
    map['reason'] = Variable<String>(reason);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SaleReturnsCompanion toCompanion(bool nullToAbsent) {
    return SaleReturnsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      refundAmount: Value(refundAmount),
      refundMethod: Value(refundMethod),
      restocked: Value(restocked),
      reason: Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory SaleReturn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleReturn(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      refundAmount: serializer.fromJson<double>(json['refundAmount']),
      refundMethod: serializer.fromJson<String>(json['refundMethod']),
      restocked: serializer.fromJson<bool>(json['restocked']),
      reason: serializer.fromJson<String>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'customerId': serializer.toJson<String?>(customerId),
      'refundAmount': serializer.toJson<double>(refundAmount),
      'refundMethod': serializer.toJson<String>(refundMethod),
      'restocked': serializer.toJson<bool>(restocked),
      'reason': serializer.toJson<String>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SaleReturn copyWith({
    String? id,
    String? saleId,
    Value<String?> customerId = const Value.absent(),
    double? refundAmount,
    String? refundMethod,
    bool? restocked,
    String? reason,
    DateTime? createdAt,
  }) => SaleReturn(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    customerId: customerId.present ? customerId.value : this.customerId,
    refundAmount: refundAmount ?? this.refundAmount,
    refundMethod: refundMethod ?? this.refundMethod,
    restocked: restocked ?? this.restocked,
    reason: reason ?? this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  SaleReturn copyWithCompanion(SaleReturnsCompanion data) {
    return SaleReturn(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      refundAmount: data.refundAmount.present
          ? data.refundAmount.value
          : this.refundAmount,
      refundMethod: data.refundMethod.present
          ? data.refundMethod.value
          : this.refundMethod,
      restocked: data.restocked.present ? data.restocked.value : this.restocked,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleReturn(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('customerId: $customerId, ')
          ..write('refundAmount: $refundAmount, ')
          ..write('refundMethod: $refundMethod, ')
          ..write('restocked: $restocked, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saleId,
    customerId,
    refundAmount,
    refundMethod,
    restocked,
    reason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleReturn &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.customerId == this.customerId &&
          other.refundAmount == this.refundAmount &&
          other.refundMethod == this.refundMethod &&
          other.restocked == this.restocked &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class SaleReturnsCompanion extends UpdateCompanion<SaleReturn> {
  final Value<String> id;
  final Value<String> saleId;
  final Value<String?> customerId;
  final Value<double> refundAmount;
  final Value<String> refundMethod;
  final Value<bool> restocked;
  final Value<String> reason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SaleReturnsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.refundAmount = const Value.absent(),
    this.refundMethod = const Value.absent(),
    this.restocked = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleReturnsCompanion.insert({
    required String id,
    required String saleId,
    this.customerId = const Value.absent(),
    required double refundAmount,
    this.refundMethod = const Value.absent(),
    this.restocked = const Value.absent(),
    this.reason = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleId = Value(saleId),
       refundAmount = Value(refundAmount),
       createdAt = Value(createdAt);
  static Insertable<SaleReturn> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? customerId,
    Expression<double>? refundAmount,
    Expression<String>? refundMethod,
    Expression<bool>? restocked,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (customerId != null) 'customer_id': customerId,
      if (refundAmount != null) 'refund_amount': refundAmount,
      if (refundMethod != null) 'refund_method': refundMethod,
      if (restocked != null) 'restocked': restocked,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleReturnsCompanion copyWith({
    Value<String>? id,
    Value<String>? saleId,
    Value<String?>? customerId,
    Value<double>? refundAmount,
    Value<String>? refundMethod,
    Value<bool>? restocked,
    Value<String>? reason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SaleReturnsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      customerId: customerId ?? this.customerId,
      refundAmount: refundAmount ?? this.refundAmount,
      refundMethod: refundMethod ?? this.refundMethod,
      restocked: restocked ?? this.restocked,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (refundAmount.present) {
      map['refund_amount'] = Variable<double>(refundAmount.value);
    }
    if (refundMethod.present) {
      map['refund_method'] = Variable<String>(refundMethod.value);
    }
    if (restocked.present) {
      map['restocked'] = Variable<bool>(restocked.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleReturnsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('customerId: $customerId, ')
          ..write('refundAmount: $refundAmount, ')
          ..write('refundMethod: $refundMethod, ')
          ..write('restocked: $restocked, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleReturnItemsTable extends SaleReturnItems
    with TableInfo<$SaleReturnItemsTable, SaleReturnItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleReturnItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _returnIdMeta = const VerificationMeta(
    'returnId',
  );
  @override
  late final GeneratedColumn<String> returnId = GeneratedColumn<String>(
    'return_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    returnId,
    saleId,
    productId,
    productName,
    quantity,
    unitPrice,
    purchasePrice,
    total,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_return_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleReturnItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('return_id')) {
      context.handle(
        _returnIdMeta,
        returnId.isAcceptableOrUnknown(data['return_id']!, _returnIdMeta),
      );
    } else if (isInserting) {
      context.missing(_returnIdMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleReturnItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleReturnItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      returnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}return_id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
    );
  }

  @override
  $SaleReturnItemsTable createAlias(String alias) {
    return $SaleReturnItemsTable(attachedDatabase, alias);
  }
}

class SaleReturnItem extends DataClass implements Insertable<SaleReturnItem> {
  final String id;
  final String returnId;
  final String saleId;
  final String productId;
  final String productName;

  /// Quantity returned on this line.
  final int quantity;

  /// Unit price refunded per item.
  final double unitPrice;

  /// Unit cost, captured so profit impact can be computed at return time.
  final double purchasePrice;

  /// Line total refunded (quantity × unitPrice).
  final double total;
  const SaleReturnItem({
    required this.id,
    required this.returnId,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.purchasePrice,
    required this.total,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['return_id'] = Variable<String>(returnId);
    map['sale_id'] = Variable<String>(saleId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['total'] = Variable<double>(total);
    return map;
  }

  SaleReturnItemsCompanion toCompanion(bool nullToAbsent) {
    return SaleReturnItemsCompanion(
      id: Value(id),
      returnId: Value(returnId),
      saleId: Value(saleId),
      productId: Value(productId),
      productName: Value(productName),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      purchasePrice: Value(purchasePrice),
      total: Value(total),
    );
  }

  factory SaleReturnItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleReturnItem(
      id: serializer.fromJson<String>(json['id']),
      returnId: serializer.fromJson<String>(json['returnId']),
      saleId: serializer.fromJson<String>(json['saleId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      total: serializer.fromJson<double>(json['total']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'returnId': serializer.toJson<String>(returnId),
      'saleId': serializer.toJson<String>(saleId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'total': serializer.toJson<double>(total),
    };
  }

  SaleReturnItem copyWith({
    String? id,
    String? returnId,
    String? saleId,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? purchasePrice,
    double? total,
  }) => SaleReturnItem(
    id: id ?? this.id,
    returnId: returnId ?? this.returnId,
    saleId: saleId ?? this.saleId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    total: total ?? this.total,
  );
  SaleReturnItem copyWithCompanion(SaleReturnItemsCompanion data) {
    return SaleReturnItem(
      id: data.id.present ? data.id.value : this.id,
      returnId: data.returnId.present ? data.returnId.value : this.returnId,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      total: data.total.present ? data.total.value : this.total,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleReturnItem(')
          ..write('id: $id, ')
          ..write('returnId: $returnId, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('total: $total')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    returnId,
    saleId,
    productId,
    productName,
    quantity,
    unitPrice,
    purchasePrice,
    total,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleReturnItem &&
          other.id == this.id &&
          other.returnId == this.returnId &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.purchasePrice == this.purchasePrice &&
          other.total == this.total);
}

class SaleReturnItemsCompanion extends UpdateCompanion<SaleReturnItem> {
  final Value<String> id;
  final Value<String> returnId;
  final Value<String> saleId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<int> quantity;
  final Value<double> unitPrice;
  final Value<double> purchasePrice;
  final Value<double> total;
  final Value<int> rowid;
  const SaleReturnItemsCompanion({
    this.id = const Value.absent(),
    this.returnId = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.total = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleReturnItemsCompanion.insert({
    required String id,
    required String returnId,
    required String saleId,
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required double purchasePrice,
    required double total,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       returnId = Value(returnId),
       saleId = Value(saleId),
       productId = Value(productId),
       productName = Value(productName),
       quantity = Value(quantity),
       unitPrice = Value(unitPrice),
       purchasePrice = Value(purchasePrice),
       total = Value(total);
  static Insertable<SaleReturnItem> custom({
    Expression<String>? id,
    Expression<String>? returnId,
    Expression<String>? saleId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<int>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? purchasePrice,
    Expression<double>? total,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (returnId != null) 'return_id': returnId,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (total != null) 'total': total,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleReturnItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? returnId,
    Value<String>? saleId,
    Value<String>? productId,
    Value<String>? productName,
    Value<int>? quantity,
    Value<double>? unitPrice,
    Value<double>? purchasePrice,
    Value<double>? total,
    Value<int>? rowid,
  }) {
    return SaleReturnItemsCompanion(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      total: total ?? this.total,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (returnId.present) {
      map['return_id'] = Variable<String>(returnId.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleReturnItemsCompanion(')
          ..write('id: $id, ')
          ..write('returnId: $returnId, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('total: $total, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorMeta = const VerificationMeta('actor');
  @override
  late final GeneratedColumn<String> actor = GeneratedColumn<String>(
    'actor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Owner'),
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _beforeJsonMeta = const VerificationMeta(
    'beforeJson',
  );
  @override
  late final GeneratedColumn<String> beforeJson = GeneratedColumn<String>(
    'before_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _afterJsonMeta = const VerificationMeta(
    'afterJson',
  );
  @override
  late final GeneratedColumn<String> afterJson = GeneratedColumn<String>(
    'after_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    actor,
    action,
    summary,
    entityType,
    entityId,
    beforeJson,
    afterJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('actor')) {
      context.handle(
        _actorMeta,
        actor.isAcceptableOrUnknown(data['actor']!, _actorMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('before_json')) {
      context.handle(
        _beforeJsonMeta,
        beforeJson.isAcceptableOrUnknown(data['before_json']!, _beforeJsonMeta),
      );
    }
    if (data.containsKey('after_json')) {
      context.handle(
        _afterJsonMeta,
        afterJson.isAcceptableOrUnknown(data['after_json']!, _afterJsonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      actor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      beforeJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}before_json'],
      )!,
      afterJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;

  /// Who performed the action. A single-operator build uses "Owner" by
  /// default; staff profiles can populate this later.
  final String actor;

  /// Action category, e.g. 'stock.change', 'sale.cancel', 'refund.create'.
  final String action;

  /// Human-readable summary of what happened.
  final String summary;

  /// The kind of record affected, e.g. 'product', 'sale', 'customer'.
  final String entityType;

  /// Identifier of the affected record.
  final String entityId;

  /// Optional JSON-encoded before/after values.
  final String beforeJson;
  final String afterJson;
  final DateTime createdAt;
  const AuditLog({
    required this.id,
    required this.actor,
    required this.action,
    required this.summary,
    required this.entityType,
    required this.entityId,
    required this.beforeJson,
    required this.afterJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['actor'] = Variable<String>(actor);
    map['action'] = Variable<String>(action);
    map['summary'] = Variable<String>(summary);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['before_json'] = Variable<String>(beforeJson);
    map['after_json'] = Variable<String>(afterJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      actor: Value(actor),
      action: Value(action),
      summary: Value(summary),
      entityType: Value(entityType),
      entityId: Value(entityId),
      beforeJson: Value(beforeJson),
      afterJson: Value(afterJson),
      createdAt: Value(createdAt),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      actor: serializer.fromJson<String>(json['actor']),
      action: serializer.fromJson<String>(json['action']),
      summary: serializer.fromJson<String>(json['summary']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      beforeJson: serializer.fromJson<String>(json['beforeJson']),
      afterJson: serializer.fromJson<String>(json['afterJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'actor': serializer.toJson<String>(actor),
      'action': serializer.toJson<String>(action),
      'summary': serializer.toJson<String>(summary),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'beforeJson': serializer.toJson<String>(beforeJson),
      'afterJson': serializer.toJson<String>(afterJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AuditLog copyWith({
    String? id,
    String? actor,
    String? action,
    String? summary,
    String? entityType,
    String? entityId,
    String? beforeJson,
    String? afterJson,
    DateTime? createdAt,
  }) => AuditLog(
    id: id ?? this.id,
    actor: actor ?? this.actor,
    action: action ?? this.action,
    summary: summary ?? this.summary,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    beforeJson: beforeJson ?? this.beforeJson,
    afterJson: afterJson ?? this.afterJson,
    createdAt: createdAt ?? this.createdAt,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      actor: data.actor.present ? data.actor.value : this.actor,
      action: data.action.present ? data.action.value : this.action,
      summary: data.summary.present ? data.summary.value : this.summary,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      beforeJson: data.beforeJson.present
          ? data.beforeJson.value
          : this.beforeJson,
      afterJson: data.afterJson.present ? data.afterJson.value : this.afterJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('actor: $actor, ')
          ..write('action: $action, ')
          ..write('summary: $summary, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('beforeJson: $beforeJson, ')
          ..write('afterJson: $afterJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    actor,
    action,
    summary,
    entityType,
    entityId,
    beforeJson,
    afterJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.actor == this.actor &&
          other.action == this.action &&
          other.summary == this.summary &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.beforeJson == this.beforeJson &&
          other.afterJson == this.afterJson &&
          other.createdAt == this.createdAt);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<String> actor;
  final Value<String> action;
  final Value<String> summary;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> beforeJson;
  final Value<String> afterJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.actor = const Value.absent(),
    this.action = const Value.absent(),
    this.summary = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.beforeJson = const Value.absent(),
    this.afterJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    this.actor = const Value.absent(),
    required String action,
    this.summary = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.beforeJson = const Value.absent(),
    this.afterJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       action = Value(action),
       createdAt = Value(createdAt);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<String>? actor,
    Expression<String>? action,
    Expression<String>? summary,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? beforeJson,
    Expression<String>? afterJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actor != null) 'actor': actor,
      if (action != null) 'action': action,
      if (summary != null) 'summary': summary,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (beforeJson != null) 'before_json': beforeJson,
      if (afterJson != null) 'after_json': afterJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? actor,
    Value<String>? action,
    Value<String>? summary,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? beforeJson,
    Value<String>? afterJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      actor: actor ?? this.actor,
      action: action ?? this.action,
      summary: summary ?? this.summary,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      beforeJson: beforeJson ?? this.beforeJson,
      afterJson: afterJson ?? this.afterJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (actor.present) {
      map['actor'] = Variable<String>(actor.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (beforeJson.present) {
      map['before_json'] = Variable<String>(beforeJson.value);
    }
    if (afterJson.present) {
      map['after_json'] = Variable<String>(afterJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('actor: $actor, ')
          ..write('action: $action, ')
          ..write('summary: $summary, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('beforeJson: $beforeJson, ')
          ..write('afterJson: $afterJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashShiftsTable extends CashShifts
    with TableInfo<$CashShiftsTable, CashShift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashShiftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftNumberMeta = const VerificationMeta(
    'shiftNumber',
  );
  @override
  late final GeneratedColumn<int> shiftNumber = GeneratedColumn<int>(
    'shift_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingFloatMeta = const VerificationMeta(
    'openingFloat',
  );
  @override
  late final GeneratedColumn<double> openingFloat = GeneratedColumn<double>(
    'opening_float',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _closingCountMeta = const VerificationMeta(
    'closingCount',
  );
  @override
  late final GeneratedColumn<double> closingCount = GeneratedColumn<double>(
    'closing_count',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discrepancyReasonMeta = const VerificationMeta(
    'discrepancyReason',
  );
  @override
  late final GeneratedColumn<String> discrepancyReason =
      GeneratedColumn<String>(
        'discrepancy_reason',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isOpenMeta = const VerificationMeta('isOpen');
  @override
  late final GeneratedColumn<bool> isOpen = GeneratedColumn<bool>(
    'is_open',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_open" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shiftNumber,
    openingFloat,
    closingCount,
    discrepancyReason,
    openedAt,
    closedAt,
    isOpen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_shifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashShift> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shift_number')) {
      context.handle(
        _shiftNumberMeta,
        shiftNumber.isAcceptableOrUnknown(
          data['shift_number']!,
          _shiftNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shiftNumberMeta);
    }
    if (data.containsKey('opening_float')) {
      context.handle(
        _openingFloatMeta,
        openingFloat.isAcceptableOrUnknown(
          data['opening_float']!,
          _openingFloatMeta,
        ),
      );
    }
    if (data.containsKey('closing_count')) {
      context.handle(
        _closingCountMeta,
        closingCount.isAcceptableOrUnknown(
          data['closing_count']!,
          _closingCountMeta,
        ),
      );
    }
    if (data.containsKey('discrepancy_reason')) {
      context.handle(
        _discrepancyReasonMeta,
        discrepancyReason.isAcceptableOrUnknown(
          data['discrepancy_reason']!,
          _discrepancyReasonMeta,
        ),
      );
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('is_open')) {
      context.handle(
        _isOpenMeta,
        isOpen.isAcceptableOrUnknown(data['is_open']!, _isOpenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashShift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashShift(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shiftNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shift_number'],
      )!,
      openingFloat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}opening_float'],
      )!,
      closingCount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}closing_count'],
      ),
      discrepancyReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discrepancy_reason'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
      isOpen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_open'],
      )!,
    );
  }

  @override
  $CashShiftsTable createAlias(String alias) {
    return $CashShiftsTable(attachedDatabase, alias);
  }
}

class CashShift extends DataClass implements Insertable<CashShift> {
  final String id;
  final int shiftNumber;

  /// Cash in the drawer when the shift opened.
  final double openingFloat;

  /// Cash counted by the operator when closing (null while the shift is open).
  final double? closingCount;

  /// Operator's explanation for any discrepancy.
  final String discrepancyReason;
  final DateTime openedAt;
  final DateTime? closedAt;
  final bool isOpen;
  const CashShift({
    required this.id,
    required this.shiftNumber,
    required this.openingFloat,
    this.closingCount,
    required this.discrepancyReason,
    required this.openedAt,
    this.closedAt,
    required this.isOpen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shift_number'] = Variable<int>(shiftNumber);
    map['opening_float'] = Variable<double>(openingFloat);
    if (!nullToAbsent || closingCount != null) {
      map['closing_count'] = Variable<double>(closingCount);
    }
    map['discrepancy_reason'] = Variable<String>(discrepancyReason);
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    map['is_open'] = Variable<bool>(isOpen);
    return map;
  }

  CashShiftsCompanion toCompanion(bool nullToAbsent) {
    return CashShiftsCompanion(
      id: Value(id),
      shiftNumber: Value(shiftNumber),
      openingFloat: Value(openingFloat),
      closingCount: closingCount == null && nullToAbsent
          ? const Value.absent()
          : Value(closingCount),
      discrepancyReason: Value(discrepancyReason),
      openedAt: Value(openedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      isOpen: Value(isOpen),
    );
  }

  factory CashShift.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashShift(
      id: serializer.fromJson<String>(json['id']),
      shiftNumber: serializer.fromJson<int>(json['shiftNumber']),
      openingFloat: serializer.fromJson<double>(json['openingFloat']),
      closingCount: serializer.fromJson<double?>(json['closingCount']),
      discrepancyReason: serializer.fromJson<String>(json['discrepancyReason']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      isOpen: serializer.fromJson<bool>(json['isOpen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shiftNumber': serializer.toJson<int>(shiftNumber),
      'openingFloat': serializer.toJson<double>(openingFloat),
      'closingCount': serializer.toJson<double?>(closingCount),
      'discrepancyReason': serializer.toJson<String>(discrepancyReason),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'isOpen': serializer.toJson<bool>(isOpen),
    };
  }

  CashShift copyWith({
    String? id,
    int? shiftNumber,
    double? openingFloat,
    Value<double?> closingCount = const Value.absent(),
    String? discrepancyReason,
    DateTime? openedAt,
    Value<DateTime?> closedAt = const Value.absent(),
    bool? isOpen,
  }) => CashShift(
    id: id ?? this.id,
    shiftNumber: shiftNumber ?? this.shiftNumber,
    openingFloat: openingFloat ?? this.openingFloat,
    closingCount: closingCount.present ? closingCount.value : this.closingCount,
    discrepancyReason: discrepancyReason ?? this.discrepancyReason,
    openedAt: openedAt ?? this.openedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    isOpen: isOpen ?? this.isOpen,
  );
  CashShift copyWithCompanion(CashShiftsCompanion data) {
    return CashShift(
      id: data.id.present ? data.id.value : this.id,
      shiftNumber: data.shiftNumber.present
          ? data.shiftNumber.value
          : this.shiftNumber,
      openingFloat: data.openingFloat.present
          ? data.openingFloat.value
          : this.openingFloat,
      closingCount: data.closingCount.present
          ? data.closingCount.value
          : this.closingCount,
      discrepancyReason: data.discrepancyReason.present
          ? data.discrepancyReason.value
          : this.discrepancyReason,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      isOpen: data.isOpen.present ? data.isOpen.value : this.isOpen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashShift(')
          ..write('id: $id, ')
          ..write('shiftNumber: $shiftNumber, ')
          ..write('openingFloat: $openingFloat, ')
          ..write('closingCount: $closingCount, ')
          ..write('discrepancyReason: $discrepancyReason, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('isOpen: $isOpen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shiftNumber,
    openingFloat,
    closingCount,
    discrepancyReason,
    openedAt,
    closedAt,
    isOpen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashShift &&
          other.id == this.id &&
          other.shiftNumber == this.shiftNumber &&
          other.openingFloat == this.openingFloat &&
          other.closingCount == this.closingCount &&
          other.discrepancyReason == this.discrepancyReason &&
          other.openedAt == this.openedAt &&
          other.closedAt == this.closedAt &&
          other.isOpen == this.isOpen);
}

class CashShiftsCompanion extends UpdateCompanion<CashShift> {
  final Value<String> id;
  final Value<int> shiftNumber;
  final Value<double> openingFloat;
  final Value<double?> closingCount;
  final Value<String> discrepancyReason;
  final Value<DateTime> openedAt;
  final Value<DateTime?> closedAt;
  final Value<bool> isOpen;
  final Value<int> rowid;
  const CashShiftsCompanion({
    this.id = const Value.absent(),
    this.shiftNumber = const Value.absent(),
    this.openingFloat = const Value.absent(),
    this.closingCount = const Value.absent(),
    this.discrepancyReason = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.isOpen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashShiftsCompanion.insert({
    required String id,
    required int shiftNumber,
    this.openingFloat = const Value.absent(),
    this.closingCount = const Value.absent(),
    this.discrepancyReason = const Value.absent(),
    required DateTime openedAt,
    this.closedAt = const Value.absent(),
    this.isOpen = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shiftNumber = Value(shiftNumber),
       openedAt = Value(openedAt);
  static Insertable<CashShift> custom({
    Expression<String>? id,
    Expression<int>? shiftNumber,
    Expression<double>? openingFloat,
    Expression<double>? closingCount,
    Expression<String>? discrepancyReason,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closedAt,
    Expression<bool>? isOpen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shiftNumber != null) 'shift_number': shiftNumber,
      if (openingFloat != null) 'opening_float': openingFloat,
      if (closingCount != null) 'closing_count': closingCount,
      if (discrepancyReason != null) 'discrepancy_reason': discrepancyReason,
      if (openedAt != null) 'opened_at': openedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (isOpen != null) 'is_open': isOpen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashShiftsCompanion copyWith({
    Value<String>? id,
    Value<int>? shiftNumber,
    Value<double>? openingFloat,
    Value<double?>? closingCount,
    Value<String>? discrepancyReason,
    Value<DateTime>? openedAt,
    Value<DateTime?>? closedAt,
    Value<bool>? isOpen,
    Value<int>? rowid,
  }) {
    return CashShiftsCompanion(
      id: id ?? this.id,
      shiftNumber: shiftNumber ?? this.shiftNumber,
      openingFloat: openingFloat ?? this.openingFloat,
      closingCount: closingCount ?? this.closingCount,
      discrepancyReason: discrepancyReason ?? this.discrepancyReason,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      isOpen: isOpen ?? this.isOpen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shiftNumber.present) {
      map['shift_number'] = Variable<int>(shiftNumber.value);
    }
    if (openingFloat.present) {
      map['opening_float'] = Variable<double>(openingFloat.value);
    }
    if (closingCount.present) {
      map['closing_count'] = Variable<double>(closingCount.value);
    }
    if (discrepancyReason.present) {
      map['discrepancy_reason'] = Variable<String>(discrepancyReason.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (isOpen.present) {
      map['is_open'] = Variable<bool>(isOpen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashShiftsCompanion(')
          ..write('id: $id, ')
          ..write('shiftNumber: $shiftNumber, ')
          ..write('openingFloat: $openingFloat, ')
          ..write('closingCount: $closingCount, ')
          ..write('discrepancyReason: $discrepancyReason, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('isOpen: $isOpen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashMovementsTable extends CashMovements
    with TableInfo<$CashMovementsTable, CashMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shiftId,
    direction,
    amount,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CashMovementsTable createAlias(String alias) {
    return $CashMovementsTable(attachedDatabase, alias);
  }
}

class CashMovement extends DataClass implements Insertable<CashMovement> {
  final String id;
  final String shiftId;

  /// 'in' adds cash to the drawer, 'out' removes it.
  final String direction;
  final double amount;
  final String note;
  final DateTime createdAt;
  const CashMovement({
    required this.id,
    required this.shiftId,
    required this.direction,
    required this.amount,
    required this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shift_id'] = Variable<String>(shiftId);
    map['direction'] = Variable<String>(direction);
    map['amount'] = Variable<double>(amount);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CashMovementsCompanion toCompanion(bool nullToAbsent) {
    return CashMovementsCompanion(
      id: Value(id),
      shiftId: Value(shiftId),
      direction: Value(direction),
      amount: Value(amount),
      note: Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory CashMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashMovement(
      id: serializer.fromJson<String>(json['id']),
      shiftId: serializer.fromJson<String>(json['shiftId']),
      direction: serializer.fromJson<String>(json['direction']),
      amount: serializer.fromJson<double>(json['amount']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shiftId': serializer.toJson<String>(shiftId),
      'direction': serializer.toJson<String>(direction),
      'amount': serializer.toJson<double>(amount),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CashMovement copyWith({
    String? id,
    String? shiftId,
    String? direction,
    double? amount,
    String? note,
    DateTime? createdAt,
  }) => CashMovement(
    id: id ?? this.id,
    shiftId: shiftId ?? this.shiftId,
    direction: direction ?? this.direction,
    amount: amount ?? this.amount,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  CashMovement copyWithCompanion(CashMovementsCompanion data) {
    return CashMovement(
      id: data.id.present ? data.id.value : this.id,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      direction: data.direction.present ? data.direction.value : this.direction,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashMovement(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('direction: $direction, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, shiftId, direction, amount, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashMovement &&
          other.id == this.id &&
          other.shiftId == this.shiftId &&
          other.direction == this.direction &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class CashMovementsCompanion extends UpdateCompanion<CashMovement> {
  final Value<String> id;
  final Value<String> shiftId;
  final Value<String> direction;
  final Value<double> amount;
  final Value<String> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CashMovementsCompanion({
    this.id = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.direction = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashMovementsCompanion.insert({
    required String id,
    required String shiftId,
    required String direction,
    required double amount,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shiftId = Value(shiftId),
       direction = Value(direction),
       amount = Value(amount),
       createdAt = Value(createdAt);
  static Insertable<CashMovement> custom({
    Expression<String>? id,
    Expression<String>? shiftId,
    Expression<String>? direction,
    Expression<double>? amount,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shiftId != null) 'shift_id': shiftId,
      if (direction != null) 'direction': direction,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? shiftId,
    Value<String>? direction,
    Value<double>? amount,
    Value<String>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CashMovementsCompanion(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashMovementsCompanion(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('direction: $direction, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $SaleItemsTable saleItems = $SaleItemsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $BusinessSettingsTable businessSettings = $BusinessSettingsTable(
    this,
  );
  late final $SaleReturnsTable saleReturns = $SaleReturnsTable(this);
  late final $SaleReturnItemsTable saleReturnItems = $SaleReturnItemsTable(
    this,
  );
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $CashShiftsTable cashShifts = $CashShiftsTable(this);
  late final $CashMovementsTable cashMovements = $CashMovementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    products,
    categories,
    sales,
    saleItems,
    customers,
    expenses,
    stockMovements,
    businessSettings,
    saleReturns,
    saleReturnItems,
    auditLogs,
    cashShifts,
    cashMovements,
  ];
}

typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required String name,
  required String sku,
  required String category,
  required double purchasePrice,
  required double sellingPrice,
  required int stockQuantity,
  required int lowStockThreshold,
  Value<String> barcode,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> sku,
  Value<String> category,
  Value<double> purchasePrice,
  Value<double> sellingPrice,
  Value<int> stockQuantity,
  Value<int> lowStockThreshold,
  Value<String> barcode,
  Value<int> rowid,
});

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductRow,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (
            ProductRow,
            BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>,
          ),
          ProductRow,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sku = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<double> sellingPrice = const Value.absent(),
                Value<int> stockQuantity = const Value.absent(),
                Value<int> lowStockThreshold = const Value.absent(),
                Value<String> barcode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                name: name,
                sku: sku,
                category: category,
                purchasePrice: purchasePrice,
                sellingPrice: sellingPrice,
                stockQuantity: stockQuantity,
                lowStockThreshold: lowStockThreshold,
                barcode: barcode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String sku,
                required String category,
                required double purchasePrice,
                required double sellingPrice,
                required int stockQuantity,
                required int lowStockThreshold,
                Value<String> barcode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                name: name,
                sku: sku,
                category: category,
                purchasePrice: purchasePrice,
                sellingPrice: sellingPrice,
                stockQuantity: stockQuantity,
                lowStockThreshold: lowStockThreshold,
                barcode: barcode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductsTable, ProductRow>(table),
                  BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductRow,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRow, BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>),
      ProductRow,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => CategoriesCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) => CategoriesCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, Category>(table),
                  BaseReferences<_$AppDatabase, $CategoriesTable, Category>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$SalesTableCreateCompanionBuilder = SalesCompanion Function({
  required String id,
  Value<String?> customerId,
  required double subtotal,
  Value<double> discount,
  required double total,
  required double paidAmount,
  Value<String> paymentMethod,
  Value<String> status,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SalesTableUpdateCompanionBuilder = SalesCompanion Function({
  Value<String> id,
  Value<String?> customerId,
  Value<double> subtotal,
  Value<double> discount,
  Value<double> total,
  Value<double> paidAmount,
  Value<String> paymentMethod,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          Sale,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
          Sale,
          PrefetchHooks Function()
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> discount = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<double> paidAmount = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                customerId: customerId,
                subtotal: subtotal,
                discount: discount,
                total: total,
                paidAmount: paidAmount,
                paymentMethod: paymentMethod,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> customerId = const Value.absent(),
                required double subtotal,
                Value<double> discount = const Value.absent(),
                required double total,
                required double paidAmount,
                Value<String> paymentMethod = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                customerId: customerId,
                subtotal: subtotal,
                discount: discount,
                total: total,
                paidAmount: paidAmount,
                paymentMethod: paymentMethod,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SalesTable, Sale>(table),
                  BaseReferences<_$AppDatabase, $SalesTable, Sale>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      Sale,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
      Sale,
      PrefetchHooks Function()
    >;
typedef $$SaleItemsTableCreateCompanionBuilder = SaleItemsCompanion Function({
  required String id,
  required String saleId,
  required String productId,
  required String productName,
  required int quantity,
  required double unitPrice,
  required double purchasePrice,
  required double total,
  Value<int> rowid,
});
typedef $$SaleItemsTableUpdateCompanionBuilder = SaleItemsCompanion Function({
  Value<String> id,
  Value<String> saleId,
  Value<String> productId,
  Value<String> productName,
  Value<int> quantity,
  Value<double> unitPrice,
  Value<double> purchasePrice,
  Value<double> total,
  Value<int> rowid,
});

class $$SaleItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SaleItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaleItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);
}

class $$SaleItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleItemsTable,
          SaleItem,
          $$SaleItemsTableFilterComposer,
          $$SaleItemsTableOrderingComposer,
          $$SaleItemsTableAnnotationComposer,
          $$SaleItemsTableCreateCompanionBuilder,
          $$SaleItemsTableUpdateCompanionBuilder,
          (SaleItem, BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItem>),
          SaleItem,
          PrefetchHooks Function()
        > {
  $$SaleItemsTableTableManager(_$AppDatabase db, $SaleItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleItemsCompanion(
                id: id,
                saleId: saleId,
                productId: productId,
                productName: productName,
                quantity: quantity,
                unitPrice: unitPrice,
                purchasePrice: purchasePrice,
                total: total,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saleId,
                required String productId,
                required String productName,
                required int quantity,
                required double unitPrice,
                required double purchasePrice,
                required double total,
                Value<int> rowid = const Value.absent(),
              }) => SaleItemsCompanion.insert(
                id: id,
                saleId: saleId,
                productId: productId,
                productName: productName,
                quantity: quantity,
                unitPrice: unitPrice,
                purchasePrice: purchasePrice,
                total: total,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleItemsTable, SaleItem>(table),
                  BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItem>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SaleItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleItemsTable,
      SaleItem,
      $$SaleItemsTableFilterComposer,
      $$SaleItemsTableOrderingComposer,
      $$SaleItemsTableAnnotationComposer,
      $$SaleItemsTableCreateCompanionBuilder,
      $$SaleItemsTableUpdateCompanionBuilder,
      (SaleItem, BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItem>),
      SaleItem,
      PrefetchHooks Function()
    >;
typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  required String name,
  Value<String> phone,
  Value<String> email,
  Value<String> address,
  Value<double> outstandingBalance,
  Value<int> loyaltyPoints,
  Value<int> pointsBalance,
  Value<String> loyaltyTier,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> phone,
  Value<String> email,
  Value<String> address,
  Value<double> outstandingBalance,
  Value<int> loyaltyPoints,
  Value<int> pointsBalance,
  Value<String> loyaltyTier,
  Value<int> rowid,
});

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get outstandingBalance => $composableBuilder(
    column: $table.outstandingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loyaltyPoints => $composableBuilder(
    column: $table.loyaltyPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointsBalance => $composableBuilder(
    column: $table.pointsBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loyaltyTier => $composableBuilder(
    column: $table.loyaltyTier,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get outstandingBalance => $composableBuilder(
    column: $table.outstandingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loyaltyPoints => $composableBuilder(
    column: $table.loyaltyPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointsBalance => $composableBuilder(
    column: $table.pointsBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loyaltyTier => $composableBuilder(
    column: $table.loyaltyTier,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get outstandingBalance => $composableBuilder(
    column: $table.outstandingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get loyaltyPoints => $composableBuilder(
    column: $table.loyaltyPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pointsBalance => $composableBuilder(
    column: $table.pointsBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get loyaltyTier => $composableBuilder(
    column: $table.loyaltyTier,
    builder: (column) => column,
  );
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
          Customer,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<double> outstandingBalance = const Value.absent(),
                Value<int> loyaltyPoints = const Value.absent(),
                Value<int> pointsBalance = const Value.absent(),
                Value<String> loyaltyTier = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                phone: phone,
                email: email,
                address: address,
                outstandingBalance: outstandingBalance,
                loyaltyPoints: loyaltyPoints,
                pointsBalance: pointsBalance,
                loyaltyTier: loyaltyTier,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<double> outstandingBalance = const Value.absent(),
                Value<int> loyaltyPoints = const Value.absent(),
                Value<int> pointsBalance = const Value.absent(),
                Value<String> loyaltyTier = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                email: email,
                address: address,
                outstandingBalance: outstandingBalance,
                loyaltyPoints: loyaltyPoints,
                pointsBalance: pointsBalance,
                loyaltyTier: loyaltyTier,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomersTable, Customer>(table),
                  BaseReferences<_$AppDatabase, $CustomersTable, Customer>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
      Customer,
      PrefetchHooks Function()
    >;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  required String id,
  required String title,
  required String category,
  required double amount,
  required DateTime date,
  Value<String> note,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> category,
  Value<double> amount,
  Value<DateTime> date,
  Value<String> note,
  Value<int> rowid,
});

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
          Expense,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                title: title,
                category: category,
                amount: amount,
                date: date,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String category,
                required double amount,
                required DateTime date,
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                title: title,
                category: category,
                amount: amount,
                date: date,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTable, Expense>(table),
                  BaseReferences<_$AppDatabase, $ExpensesTable, Expense>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
      Expense,
      PrefetchHooks Function()
    >;
typedef $$StockMovementsTableCreateCompanionBuilder =
    StockMovementsCompanion Function({
      required String id,
      required String productId,
      required String type,
      required int quantity,
      required int previousStock,
      required int newStock,
      Value<String> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StockMovementsTableUpdateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> type,
      Value<int> quantity,
      Value<int> previousStock,
      Value<int> newStock,
      Value<String> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previousStock => $composableBuilder(
    column: $table.previousStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newStock => $composableBuilder(
    column: $table.newStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previousStock => $composableBuilder(
    column: $table.previousStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newStock => $composableBuilder(
    column: $table.newStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get previousStock => $composableBuilder(
    column: $table.previousStock,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newStock =>
      $composableBuilder(column: $table.newStock, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StockMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockMovementsTable,
          StockMovement,
          $$StockMovementsTableFilterComposer,
          $$StockMovementsTableOrderingComposer,
          $$StockMovementsTableAnnotationComposer,
          $$StockMovementsTableCreateCompanionBuilder,
          $$StockMovementsTableUpdateCompanionBuilder,
          (
            StockMovement,
            BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>,
          ),
          StockMovement,
          PrefetchHooks Function()
        > {
  $$StockMovementsTableTableManager(
    _$AppDatabase db,
    $StockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> previousStock = const Value.absent(),
                Value<int> newStock = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion(
                id: id,
                productId: productId,
                type: type,
                quantity: quantity,
                previousStock: previousStock,
                newStock: newStock,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String type,
                required int quantity,
                required int previousStock,
                required int newStock,
                Value<String> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion.insert(
                id: id,
                productId: productId,
                type: type,
                quantity: quantity,
                previousStock: previousStock,
                newStock: newStock,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StockMovementsTable, StockMovement>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $StockMovementsTable,
                    StockMovement
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockMovementsTable,
      StockMovement,
      $$StockMovementsTableFilterComposer,
      $$StockMovementsTableOrderingComposer,
      $$StockMovementsTableAnnotationComposer,
      $$StockMovementsTableCreateCompanionBuilder,
      $$StockMovementsTableUpdateCompanionBuilder,
      (
        StockMovement,
        BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>,
      ),
      StockMovement,
      PrefetchHooks Function()
    >;
typedef $$BusinessSettingsTableCreateCompanionBuilder =
    BusinessSettingsCompanion Function({
      required String id,
      Value<String> businessName,
      Value<String> address,
      Value<String> phone,
      Value<String> email,
      Value<String> currency,
      Value<bool> loyaltyEnabled,
      Value<double> loyaltyEarnRate,
      Value<double> loyaltyRedeemValue,
      Value<String> receiptHeader,
      Value<String> receiptFooter,
      Value<bool> receiptShowPhone,
      Value<bool> receiptShowAddress,
      Value<String> receiptNote,
      Value<int> rowid,
    });
typedef $$BusinessSettingsTableUpdateCompanionBuilder =
    BusinessSettingsCompanion Function({
      Value<String> id,
      Value<String> businessName,
      Value<String> address,
      Value<String> phone,
      Value<String> email,
      Value<String> currency,
      Value<bool> loyaltyEnabled,
      Value<double> loyaltyEarnRate,
      Value<double> loyaltyRedeemValue,
      Value<String> receiptHeader,
      Value<String> receiptFooter,
      Value<bool> receiptShowPhone,
      Value<bool> receiptShowAddress,
      Value<String> receiptNote,
      Value<int> rowid,
    });

class $$BusinessSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $BusinessSettingsTable> {
  $$BusinessSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get loyaltyEnabled => $composableBuilder(
    column: $table.loyaltyEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get loyaltyEarnRate => $composableBuilder(
    column: $table.loyaltyEarnRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get loyaltyRedeemValue => $composableBuilder(
    column: $table.loyaltyRedeemValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptHeader => $composableBuilder(
    column: $table.receiptHeader,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptFooter => $composableBuilder(
    column: $table.receiptFooter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get receiptShowPhone => $composableBuilder(
    column: $table.receiptShowPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get receiptShowAddress => $composableBuilder(
    column: $table.receiptShowAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptNote => $composableBuilder(
    column: $table.receiptNote,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BusinessSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BusinessSettingsTable> {
  $$BusinessSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get loyaltyEnabled => $composableBuilder(
    column: $table.loyaltyEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get loyaltyEarnRate => $composableBuilder(
    column: $table.loyaltyEarnRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get loyaltyRedeemValue => $composableBuilder(
    column: $table.loyaltyRedeemValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptHeader => $composableBuilder(
    column: $table.receiptHeader,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptFooter => $composableBuilder(
    column: $table.receiptFooter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get receiptShowPhone => $composableBuilder(
    column: $table.receiptShowPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get receiptShowAddress => $composableBuilder(
    column: $table.receiptShowAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptNote => $composableBuilder(
    column: $table.receiptNote,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BusinessSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BusinessSettingsTable> {
  $$BusinessSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get loyaltyEnabled => $composableBuilder(
    column: $table.loyaltyEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<double> get loyaltyEarnRate => $composableBuilder(
    column: $table.loyaltyEarnRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get loyaltyRedeemValue => $composableBuilder(
    column: $table.loyaltyRedeemValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptHeader => $composableBuilder(
    column: $table.receiptHeader,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptFooter => $composableBuilder(
    column: $table.receiptFooter,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get receiptShowPhone => $composableBuilder(
    column: $table.receiptShowPhone,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get receiptShowAddress => $composableBuilder(
    column: $table.receiptShowAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptNote => $composableBuilder(
    column: $table.receiptNote,
    builder: (column) => column,
  );
}

class $$BusinessSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BusinessSettingsTable,
          BusinessSetting,
          $$BusinessSettingsTableFilterComposer,
          $$BusinessSettingsTableOrderingComposer,
          $$BusinessSettingsTableAnnotationComposer,
          $$BusinessSettingsTableCreateCompanionBuilder,
          $$BusinessSettingsTableUpdateCompanionBuilder,
          (
            BusinessSetting,
            BaseReferences<
              _$AppDatabase,
              $BusinessSettingsTable,
              BusinessSetting
            >,
          ),
          BusinessSetting,
          PrefetchHooks Function()
        > {
  $$BusinessSettingsTableTableManager(
    _$AppDatabase db,
    $BusinessSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BusinessSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BusinessSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BusinessSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessName = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<bool> loyaltyEnabled = const Value.absent(),
                Value<double> loyaltyEarnRate = const Value.absent(),
                Value<double> loyaltyRedeemValue = const Value.absent(),
                Value<String> receiptHeader = const Value.absent(),
                Value<String> receiptFooter = const Value.absent(),
                Value<bool> receiptShowPhone = const Value.absent(),
                Value<bool> receiptShowAddress = const Value.absent(),
                Value<String> receiptNote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BusinessSettingsCompanion(
                id: id,
                businessName: businessName,
                address: address,
                phone: phone,
                email: email,
                currency: currency,
                loyaltyEnabled: loyaltyEnabled,
                loyaltyEarnRate: loyaltyEarnRate,
                loyaltyRedeemValue: loyaltyRedeemValue,
                receiptHeader: receiptHeader,
                receiptFooter: receiptFooter,
                receiptShowPhone: receiptShowPhone,
                receiptShowAddress: receiptShowAddress,
                receiptNote: receiptNote,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> businessName = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<bool> loyaltyEnabled = const Value.absent(),
                Value<double> loyaltyEarnRate = const Value.absent(),
                Value<double> loyaltyRedeemValue = const Value.absent(),
                Value<String> receiptHeader = const Value.absent(),
                Value<String> receiptFooter = const Value.absent(),
                Value<bool> receiptShowPhone = const Value.absent(),
                Value<bool> receiptShowAddress = const Value.absent(),
                Value<String> receiptNote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BusinessSettingsCompanion.insert(
                id: id,
                businessName: businessName,
                address: address,
                phone: phone,
                email: email,
                currency: currency,
                loyaltyEnabled: loyaltyEnabled,
                loyaltyEarnRate: loyaltyEarnRate,
                loyaltyRedeemValue: loyaltyRedeemValue,
                receiptHeader: receiptHeader,
                receiptFooter: receiptFooter,
                receiptShowPhone: receiptShowPhone,
                receiptShowAddress: receiptShowAddress,
                receiptNote: receiptNote,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BusinessSettingsTable, BusinessSetting>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BusinessSettingsTable,
                    BusinessSetting
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BusinessSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BusinessSettingsTable,
      BusinessSetting,
      $$BusinessSettingsTableFilterComposer,
      $$BusinessSettingsTableOrderingComposer,
      $$BusinessSettingsTableAnnotationComposer,
      $$BusinessSettingsTableCreateCompanionBuilder,
      $$BusinessSettingsTableUpdateCompanionBuilder,
      (
        BusinessSetting,
        BaseReferences<_$AppDatabase, $BusinessSettingsTable, BusinessSetting>,
      ),
      BusinessSetting,
      PrefetchHooks Function()
    >;
typedef $$SaleReturnsTableCreateCompanionBuilder =
    SaleReturnsCompanion Function({
      required String id,
      required String saleId,
      Value<String?> customerId,
      required double refundAmount,
      Value<String> refundMethod,
      Value<bool> restocked,
      Value<String> reason,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SaleReturnsTableUpdateCompanionBuilder =
    SaleReturnsCompanion Function({
      Value<String> id,
      Value<String> saleId,
      Value<String?> customerId,
      Value<double> refundAmount,
      Value<String> refundMethod,
      Value<bool> restocked,
      Value<String> reason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SaleReturnsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleReturnsTable> {
  $$SaleReturnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get refundAmount => $composableBuilder(
    column: $table.refundAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refundMethod => $composableBuilder(
    column: $table.refundMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get restocked => $composableBuilder(
    column: $table.restocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SaleReturnsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleReturnsTable> {
  $$SaleReturnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get refundAmount => $composableBuilder(
    column: $table.refundAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refundMethod => $composableBuilder(
    column: $table.refundMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get restocked => $composableBuilder(
    column: $table.restocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaleReturnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleReturnsTable> {
  $$SaleReturnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get refundAmount => $composableBuilder(
    column: $table.refundAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refundMethod => $composableBuilder(
    column: $table.refundMethod,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get restocked =>
      $composableBuilder(column: $table.restocked, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SaleReturnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleReturnsTable,
          SaleReturn,
          $$SaleReturnsTableFilterComposer,
          $$SaleReturnsTableOrderingComposer,
          $$SaleReturnsTableAnnotationComposer,
          $$SaleReturnsTableCreateCompanionBuilder,
          $$SaleReturnsTableUpdateCompanionBuilder,
          (
            SaleReturn,
            BaseReferences<_$AppDatabase, $SaleReturnsTable, SaleReturn>,
          ),
          SaleReturn,
          PrefetchHooks Function()
        > {
  $$SaleReturnsTableTableManager(_$AppDatabase db, $SaleReturnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleReturnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleReturnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleReturnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<double> refundAmount = const Value.absent(),
                Value<String> refundMethod = const Value.absent(),
                Value<bool> restocked = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleReturnsCompanion(
                id: id,
                saleId: saleId,
                customerId: customerId,
                refundAmount: refundAmount,
                refundMethod: refundMethod,
                restocked: restocked,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saleId,
                Value<String?> customerId = const Value.absent(),
                required double refundAmount,
                Value<String> refundMethod = const Value.absent(),
                Value<bool> restocked = const Value.absent(),
                Value<String> reason = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SaleReturnsCompanion.insert(
                id: id,
                saleId: saleId,
                customerId: customerId,
                refundAmount: refundAmount,
                refundMethod: refundMethod,
                restocked: restocked,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleReturnsTable, SaleReturn>(table),
                  BaseReferences<_$AppDatabase, $SaleReturnsTable, SaleReturn>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SaleReturnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleReturnsTable,
      SaleReturn,
      $$SaleReturnsTableFilterComposer,
      $$SaleReturnsTableOrderingComposer,
      $$SaleReturnsTableAnnotationComposer,
      $$SaleReturnsTableCreateCompanionBuilder,
      $$SaleReturnsTableUpdateCompanionBuilder,
      (
        SaleReturn,
        BaseReferences<_$AppDatabase, $SaleReturnsTable, SaleReturn>,
      ),
      SaleReturn,
      PrefetchHooks Function()
    >;
typedef $$SaleReturnItemsTableCreateCompanionBuilder =
    SaleReturnItemsCompanion Function({
      required String id,
      required String returnId,
      required String saleId,
      required String productId,
      required String productName,
      required int quantity,
      required double unitPrice,
      required double purchasePrice,
      required double total,
      Value<int> rowid,
    });
typedef $$SaleReturnItemsTableUpdateCompanionBuilder =
    SaleReturnItemsCompanion Function({
      Value<String> id,
      Value<String> returnId,
      Value<String> saleId,
      Value<String> productId,
      Value<String> productName,
      Value<int> quantity,
      Value<double> unitPrice,
      Value<double> purchasePrice,
      Value<double> total,
      Value<int> rowid,
    });

class $$SaleReturnItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleReturnItemsTable> {
  $$SaleReturnItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get returnId => $composableBuilder(
    column: $table.returnId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SaleReturnItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleReturnItemsTable> {
  $$SaleReturnItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get returnId => $composableBuilder(
    column: $table.returnId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaleReturnItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleReturnItemsTable> {
  $$SaleReturnItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get returnId =>
      $composableBuilder(column: $table.returnId, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);
}

class $$SaleReturnItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleReturnItemsTable,
          SaleReturnItem,
          $$SaleReturnItemsTableFilterComposer,
          $$SaleReturnItemsTableOrderingComposer,
          $$SaleReturnItemsTableAnnotationComposer,
          $$SaleReturnItemsTableCreateCompanionBuilder,
          $$SaleReturnItemsTableUpdateCompanionBuilder,
          (
            SaleReturnItem,
            BaseReferences<
              _$AppDatabase,
              $SaleReturnItemsTable,
              SaleReturnItem
            >,
          ),
          SaleReturnItem,
          PrefetchHooks Function()
        > {
  $$SaleReturnItemsTableTableManager(
    _$AppDatabase db,
    $SaleReturnItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleReturnItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleReturnItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleReturnItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> returnId = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleReturnItemsCompanion(
                id: id,
                returnId: returnId,
                saleId: saleId,
                productId: productId,
                productName: productName,
                quantity: quantity,
                unitPrice: unitPrice,
                purchasePrice: purchasePrice,
                total: total,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String returnId,
                required String saleId,
                required String productId,
                required String productName,
                required int quantity,
                required double unitPrice,
                required double purchasePrice,
                required double total,
                Value<int> rowid = const Value.absent(),
              }) => SaleReturnItemsCompanion.insert(
                id: id,
                returnId: returnId,
                saleId: saleId,
                productId: productId,
                productName: productName,
                quantity: quantity,
                unitPrice: unitPrice,
                purchasePrice: purchasePrice,
                total: total,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleReturnItemsTable, SaleReturnItem>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SaleReturnItemsTable,
                    SaleReturnItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SaleReturnItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleReturnItemsTable,
      SaleReturnItem,
      $$SaleReturnItemsTableFilterComposer,
      $$SaleReturnItemsTableOrderingComposer,
      $$SaleReturnItemsTableAnnotationComposer,
      $$SaleReturnItemsTableCreateCompanionBuilder,
      $$SaleReturnItemsTableUpdateCompanionBuilder,
      (
        SaleReturnItem,
        BaseReferences<_$AppDatabase, $SaleReturnItemsTable, SaleReturnItem>,
      ),
      SaleReturnItem,
      PrefetchHooks Function()
    >;
typedef $$AuditLogsTableCreateCompanionBuilder = AuditLogsCompanion Function({
  required String id,
  Value<String> actor,
  required String action,
  Value<String> summary,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> beforeJson,
  Value<String> afterJson,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$AuditLogsTableUpdateCompanionBuilder = AuditLogsCompanion Function({
  Value<String> id,
  Value<String> actor,
  Value<String> action,
  Value<String> summary,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> beforeJson,
  Value<String> afterJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actor => $composableBuilder(
    column: $table.actor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beforeJson => $composableBuilder(
    column: $table.beforeJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get afterJson => $composableBuilder(
    column: $table.afterJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actor => $composableBuilder(
    column: $table.actor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beforeJson => $composableBuilder(
    column: $table.beforeJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get afterJson => $composableBuilder(
    column: $table.afterJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actor =>
      $composableBuilder(column: $table.actor, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get beforeJson => $composableBuilder(
    column: $table.beforeJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get afterJson =>
      $composableBuilder(column: $table.afterJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> actor = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> beforeJson = const Value.absent(),
                Value<String> afterJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                actor: actor,
                action: action,
                summary: summary,
                entityType: entityType,
                entityId: entityId,
                beforeJson: beforeJson,
                afterJson: afterJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> actor = const Value.absent(),
                required String action,
                Value<String> summary = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> beforeJson = const Value.absent(),
                Value<String> afterJson = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                actor: actor,
                action: action,
                summary: summary,
                entityType: entityType,
                entityId: entityId,
                beforeJson: beforeJson,
                afterJson: afterJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditLogsTable, AuditLog>(table),
                  BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;
typedef $$CashShiftsTableCreateCompanionBuilder = CashShiftsCompanion Function({
  required String id,
  required int shiftNumber,
  Value<double> openingFloat,
  Value<double?> closingCount,
  Value<String> discrepancyReason,
  required DateTime openedAt,
  Value<DateTime?> closedAt,
  Value<bool> isOpen,
  Value<int> rowid,
});
typedef $$CashShiftsTableUpdateCompanionBuilder = CashShiftsCompanion Function({
  Value<String> id,
  Value<int> shiftNumber,
  Value<double> openingFloat,
  Value<double?> closingCount,
  Value<String> discrepancyReason,
  Value<DateTime> openedAt,
  Value<DateTime?> closedAt,
  Value<bool> isOpen,
  Value<int> rowid,
});

class $$CashShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $CashShiftsTable> {
  $$CashShiftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shiftNumber => $composableBuilder(
    column: $table.shiftNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get openingFloat => $composableBuilder(
    column: $table.openingFloat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get closingCount => $composableBuilder(
    column: $table.closingCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discrepancyReason => $composableBuilder(
    column: $table.discrepancyReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOpen => $composableBuilder(
    column: $table.isOpen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashShiftsTable> {
  $$CashShiftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shiftNumber => $composableBuilder(
    column: $table.shiftNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get openingFloat => $composableBuilder(
    column: $table.openingFloat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get closingCount => $composableBuilder(
    column: $table.closingCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discrepancyReason => $composableBuilder(
    column: $table.discrepancyReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOpen => $composableBuilder(
    column: $table.isOpen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashShiftsTable> {
  $$CashShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get shiftNumber => $composableBuilder(
    column: $table.shiftNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get openingFloat => $composableBuilder(
    column: $table.openingFloat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get closingCount => $composableBuilder(
    column: $table.closingCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discrepancyReason => $composableBuilder(
    column: $table.discrepancyReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<bool> get isOpen =>
      $composableBuilder(column: $table.isOpen, builder: (column) => column);
}

class $$CashShiftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashShiftsTable,
          CashShift,
          $$CashShiftsTableFilterComposer,
          $$CashShiftsTableOrderingComposer,
          $$CashShiftsTableAnnotationComposer,
          $$CashShiftsTableCreateCompanionBuilder,
          $$CashShiftsTableUpdateCompanionBuilder,
          (
            CashShift,
            BaseReferences<_$AppDatabase, $CashShiftsTable, CashShift>,
          ),
          CashShift,
          PrefetchHooks Function()
        > {
  $$CashShiftsTableTableManager(_$AppDatabase db, $CashShiftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> shiftNumber = const Value.absent(),
                Value<double> openingFloat = const Value.absent(),
                Value<double?> closingCount = const Value.absent(),
                Value<String> discrepancyReason = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<bool> isOpen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashShiftsCompanion(
                id: id,
                shiftNumber: shiftNumber,
                openingFloat: openingFloat,
                closingCount: closingCount,
                discrepancyReason: discrepancyReason,
                openedAt: openedAt,
                closedAt: closedAt,
                isOpen: isOpen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int shiftNumber,
                Value<double> openingFloat = const Value.absent(),
                Value<double?> closingCount = const Value.absent(),
                Value<String> discrepancyReason = const Value.absent(),
                required DateTime openedAt,
                Value<DateTime?> closedAt = const Value.absent(),
                Value<bool> isOpen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashShiftsCompanion.insert(
                id: id,
                shiftNumber: shiftNumber,
                openingFloat: openingFloat,
                closingCount: closingCount,
                discrepancyReason: discrepancyReason,
                openedAt: openedAt,
                closedAt: closedAt,
                isOpen: isOpen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CashShiftsTable, CashShift>(table),
                  BaseReferences<_$AppDatabase, $CashShiftsTable, CashShift>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashShiftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashShiftsTable,
      CashShift,
      $$CashShiftsTableFilterComposer,
      $$CashShiftsTableOrderingComposer,
      $$CashShiftsTableAnnotationComposer,
      $$CashShiftsTableCreateCompanionBuilder,
      $$CashShiftsTableUpdateCompanionBuilder,
      (CashShift, BaseReferences<_$AppDatabase, $CashShiftsTable, CashShift>),
      CashShift,
      PrefetchHooks Function()
    >;
typedef $$CashMovementsTableCreateCompanionBuilder =
    CashMovementsCompanion Function({
      required String id,
      required String shiftId,
      required String direction,
      required double amount,
      Value<String> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CashMovementsTableUpdateCompanionBuilder =
    CashMovementsCompanion Function({
      Value<String> id,
      Value<String> shiftId,
      Value<String> direction,
      Value<double> amount,
      Value<String> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CashMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $CashMovementsTable> {
  $$CashMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashMovementsTable> {
  $$CashMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashMovementsTable> {
  $$CashMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CashMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashMovementsTable,
          CashMovement,
          $$CashMovementsTableFilterComposer,
          $$CashMovementsTableOrderingComposer,
          $$CashMovementsTableAnnotationComposer,
          $$CashMovementsTableCreateCompanionBuilder,
          $$CashMovementsTableUpdateCompanionBuilder,
          (
            CashMovement,
            BaseReferences<_$AppDatabase, $CashMovementsTable, CashMovement>,
          ),
          CashMovement,
          PrefetchHooks Function()
        > {
  $$CashMovementsTableTableManager(_$AppDatabase db, $CashMovementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shiftId = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashMovementsCompanion(
                id: id,
                shiftId: shiftId,
                direction: direction,
                amount: amount,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shiftId,
                required String direction,
                required double amount,
                Value<String> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CashMovementsCompanion.insert(
                id: id,
                shiftId: shiftId,
                direction: direction,
                amount: amount,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CashMovementsTable, CashMovement>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CashMovementsTable,
                    CashMovement
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashMovementsTable,
      CashMovement,
      $$CashMovementsTableFilterComposer,
      $$CashMovementsTableOrderingComposer,
      $$CashMovementsTableAnnotationComposer,
      $$CashMovementsTableCreateCompanionBuilder,
      $$CashMovementsTableUpdateCompanionBuilder,
      (
        CashMovement,
        BaseReferences<_$AppDatabase, $CashMovementsTable, CashMovement>,
      ),
      CashMovement,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SaleItemsTableTableManager get saleItems =>
      $$SaleItemsTableTableManager(_db, _db.saleItems);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$BusinessSettingsTableTableManager get businessSettings =>
      $$BusinessSettingsTableTableManager(_db, _db.businessSettings);
  $$SaleReturnsTableTableManager get saleReturns =>
      $$SaleReturnsTableTableManager(_db, _db.saleReturns);
  $$SaleReturnItemsTableTableManager get saleReturnItems =>
      $$SaleReturnItemsTableTableManager(_db, _db.saleReturnItems);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$CashShiftsTableTableManager get cashShifts =>
      $$CashShiftsTableTableManager(_db, _db.cashShifts);
  $$CashMovementsTableTableManager get cashMovements =>
      $$CashMovementsTableTableManager(_db, _db.cashMovements);
}
