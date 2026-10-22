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
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    staffId,
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
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
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
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      ),
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

  /// The authenticated staff member who completed the sale. Null for legacy
  /// records and for operations performed while login enforcement is disabled.
  final String? staffId;
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
    this.staffId,
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
    if (!nullToAbsent || staffId != null) {
      map['staff_id'] = Variable<String>(staffId);
    }
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
      staffId: staffId == null && nullToAbsent
          ? const Value.absent()
          : Value(staffId),
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
      staffId: serializer.fromJson<String?>(json['staffId']),
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
      'staffId': serializer.toJson<String?>(staffId),
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
    Value<String?> staffId = const Value.absent(),
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
    staffId: staffId.present ? staffId.value : this.staffId,
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
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
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
          ..write('createdAt: $createdAt, ')
          ..write('staffId: $staffId')
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
    staffId,
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
          other.createdAt == this.createdAt &&
          other.staffId == this.staffId);
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
  final Value<String?> staffId;
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
    this.staffId = const Value.absent(),
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
    this.staffId = const Value.absent(),
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
    Expression<String>? staffId,
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
      if (staffId != null) 'staff_id': staffId,
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
    Value<String?>? staffId,
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
      staffId: staffId ?? this.staffId,
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
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
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
          ..write('staffId: $staffId, ')
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
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    staffId,
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
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
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
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      ),
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

  /// The staff member who recorded this stock movement.
  final String? staffId;
  const StockMovement({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    required this.note,
    required this.createdAt,
    this.staffId,
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
    if (!nullToAbsent || staffId != null) {
      map['staff_id'] = Variable<String>(staffId);
    }
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
      staffId: staffId == null && nullToAbsent
          ? const Value.absent()
          : Value(staffId),
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
      staffId: serializer.fromJson<String?>(json['staffId']),
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
      'staffId': serializer.toJson<String?>(staffId),
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
    Value<String?> staffId = const Value.absent(),
  }) => StockMovement(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    type: type ?? this.type,
    quantity: quantity ?? this.quantity,
    previousStock: previousStock ?? this.previousStock,
    newStock: newStock ?? this.newStock,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
    staffId: staffId.present ? staffId.value : this.staffId,
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
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
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
          ..write('createdAt: $createdAt, ')
          ..write('staffId: $staffId')
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
    staffId,
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
          other.createdAt == this.createdAt &&
          other.staffId == this.staffId);
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
  final Value<String?> staffId;
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
    this.staffId = const Value.absent(),
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
    this.staffId = const Value.absent(),
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
    Expression<String>? staffId,
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
      if (staffId != null) 'staff_id': staffId,
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
    Value<String?>? staffId,
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
      staffId: staffId ?? this.staffId,
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
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
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
          ..write('staffId: $staffId, ')
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
  static const VerificationMeta _loginRequiredMeta = const VerificationMeta(
    'loginRequired',
  );
  @override
  late final GeneratedColumn<bool> loginRequired = GeneratedColumn<bool>(
    'login_required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("login_required" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _inactivityTimeoutMinutesMeta =
      const VerificationMeta('inactivityTimeoutMinutes');
  @override
  late final GeneratedColumn<int> inactivityTimeoutMinutes =
      GeneratedColumn<int>(
        'inactivity_timeout_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
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
    loginRequired,
    inactivityTimeoutMinutes,
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
    if (data.containsKey('login_required')) {
      context.handle(
        _loginRequiredMeta,
        loginRequired.isAcceptableOrUnknown(
          data['login_required']!,
          _loginRequiredMeta,
        ),
      );
    }
    if (data.containsKey('inactivity_timeout_minutes')) {
      context.handle(
        _inactivityTimeoutMinutesMeta,
        inactivityTimeoutMinutes.isAcceptableOrUnknown(
          data['inactivity_timeout_minutes']!,
          _inactivityTimeoutMinutesMeta,
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
      loginRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}login_required'],
      )!,
      inactivityTimeoutMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inactivity_timeout_minutes'],
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

  /// Phase D: when true, the startup gate requires staff PIN login before
  /// the app shell is shown. Defaults to false so existing installations
  /// keep today's no-login behavior after the v13 migration.
  final bool loginRequired;

  /// Phase F: inactivity auto-lock timeout in minutes. `0` means the
  /// inactivity lock is disabled. When non-zero and the session is
  /// authenticated, the app shell locks the session after this many minutes
  /// of no user activity, requiring PIN re-entry via [SessionController.unlock].
  /// Defaults to 0 (off) so existing installations keep today's behavior.
  final int inactivityTimeoutMinutes;
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
    required this.loginRequired,
    required this.inactivityTimeoutMinutes,
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
    map['login_required'] = Variable<bool>(loginRequired);
    map['inactivity_timeout_minutes'] = Variable<int>(inactivityTimeoutMinutes);
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
      loginRequired: Value(loginRequired),
      inactivityTimeoutMinutes: Value(inactivityTimeoutMinutes),
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
      loginRequired: serializer.fromJson<bool>(json['loginRequired']),
      inactivityTimeoutMinutes: serializer.fromJson<int>(
        json['inactivityTimeoutMinutes'],
      ),
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
      'loginRequired': serializer.toJson<bool>(loginRequired),
      'inactivityTimeoutMinutes': serializer.toJson<int>(
        inactivityTimeoutMinutes,
      ),
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
    bool? loginRequired,
    int? inactivityTimeoutMinutes,
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
    loginRequired: loginRequired ?? this.loginRequired,
    inactivityTimeoutMinutes:
        inactivityTimeoutMinutes ?? this.inactivityTimeoutMinutes,
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
      loginRequired: data.loginRequired.present
          ? data.loginRequired.value
          : this.loginRequired,
      inactivityTimeoutMinutes: data.inactivityTimeoutMinutes.present
          ? data.inactivityTimeoutMinutes.value
          : this.inactivityTimeoutMinutes,
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
          ..write('receiptNote: $receiptNote, ')
          ..write('loginRequired: $loginRequired, ')
          ..write('inactivityTimeoutMinutes: $inactivityTimeoutMinutes')
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
    loginRequired,
    inactivityTimeoutMinutes,
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
          other.receiptNote == this.receiptNote &&
          other.loginRequired == this.loginRequired &&
          other.inactivityTimeoutMinutes == this.inactivityTimeoutMinutes);
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
  final Value<bool> loginRequired;
  final Value<int> inactivityTimeoutMinutes;
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
    this.loginRequired = const Value.absent(),
    this.inactivityTimeoutMinutes = const Value.absent(),
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
    this.loginRequired = const Value.absent(),
    this.inactivityTimeoutMinutes = const Value.absent(),
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
    Expression<bool>? loginRequired,
    Expression<int>? inactivityTimeoutMinutes,
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
      if (loginRequired != null) 'login_required': loginRequired,
      if (inactivityTimeoutMinutes != null)
        'inactivity_timeout_minutes': inactivityTimeoutMinutes,
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
    Value<bool>? loginRequired,
    Value<int>? inactivityTimeoutMinutes,
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
      loginRequired: loginRequired ?? this.loginRequired,
      inactivityTimeoutMinutes:
          inactivityTimeoutMinutes ?? this.inactivityTimeoutMinutes,
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
    if (loginRequired.present) {
      map['login_required'] = Variable<bool>(loginRequired.value);
    }
    if (inactivityTimeoutMinutes.present) {
      map['inactivity_timeout_minutes'] = Variable<int>(
        inactivityTimeoutMinutes.value,
      );
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
          ..write('loginRequired: $loginRequired, ')
          ..write('inactivityTimeoutMinutes: $inactivityTimeoutMinutes, ')
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
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    staffId,
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
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
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
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      ),
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

  /// The authenticated staff member who processed the return. Null for legacy
  /// records and for operations performed while login enforcement is disabled.
  final String? staffId;
  const SaleReturn({
    required this.id,
    required this.saleId,
    this.customerId,
    required this.refundAmount,
    required this.refundMethod,
    required this.restocked,
    required this.reason,
    required this.createdAt,
    this.staffId,
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
    if (!nullToAbsent || staffId != null) {
      map['staff_id'] = Variable<String>(staffId);
    }
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
      staffId: staffId == null && nullToAbsent
          ? const Value.absent()
          : Value(staffId),
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
      staffId: serializer.fromJson<String?>(json['staffId']),
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
      'staffId': serializer.toJson<String?>(staffId),
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
    Value<String?> staffId = const Value.absent(),
  }) => SaleReturn(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    customerId: customerId.present ? customerId.value : this.customerId,
    refundAmount: refundAmount ?? this.refundAmount,
    refundMethod: refundMethod ?? this.refundMethod,
    restocked: restocked ?? this.restocked,
    reason: reason ?? this.reason,
    createdAt: createdAt ?? this.createdAt,
    staffId: staffId.present ? staffId.value : this.staffId,
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
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
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
          ..write('createdAt: $createdAt, ')
          ..write('staffId: $staffId')
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
    staffId,
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
          other.createdAt == this.createdAt &&
          other.staffId == this.staffId);
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
  final Value<String?> staffId;
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
    this.staffId = const Value.absent(),
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
    this.staffId = const Value.absent(),
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
    Expression<String>? staffId,
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
      if (staffId != null) 'staff_id': staffId,
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
    Value<String?>? staffId,
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
      staffId: staffId ?? this.staffId,
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
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
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
          ..write('staffId: $staffId, ')
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
  static const VerificationMeta _openedByIdMeta = const VerificationMeta(
    'openedById',
  );
  @override
  late final GeneratedColumn<String> openedById = GeneratedColumn<String>(
    'opened_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedByIdMeta = const VerificationMeta(
    'closedById',
  );
  @override
  late final GeneratedColumn<String> closedById = GeneratedColumn<String>(
    'closed_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    openedById,
    closedById,
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
    if (data.containsKey('opened_by_id')) {
      context.handle(
        _openedByIdMeta,
        openedById.isAcceptableOrUnknown(
          data['opened_by_id']!,
          _openedByIdMeta,
        ),
      );
    }
    if (data.containsKey('closed_by_id')) {
      context.handle(
        _closedByIdMeta,
        closedById.isAcceptableOrUnknown(
          data['closed_by_id']!,
          _closedByIdMeta,
        ),
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
      openedById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opened_by_id'],
      ),
      closedById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by_id'],
      ),
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

  /// The staff member who opened this shift.
  final String? openedById;

  /// The staff member who closed this shift (null while open).
  final String? closedById;
  const CashShift({
    required this.id,
    required this.shiftNumber,
    required this.openingFloat,
    this.closingCount,
    required this.discrepancyReason,
    required this.openedAt,
    this.closedAt,
    required this.isOpen,
    this.openedById,
    this.closedById,
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
    if (!nullToAbsent || openedById != null) {
      map['opened_by_id'] = Variable<String>(openedById);
    }
    if (!nullToAbsent || closedById != null) {
      map['closed_by_id'] = Variable<String>(closedById);
    }
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
      openedById: openedById == null && nullToAbsent
          ? const Value.absent()
          : Value(openedById),
      closedById: closedById == null && nullToAbsent
          ? const Value.absent()
          : Value(closedById),
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
      openedById: serializer.fromJson<String?>(json['openedById']),
      closedById: serializer.fromJson<String?>(json['closedById']),
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
      'openedById': serializer.toJson<String?>(openedById),
      'closedById': serializer.toJson<String?>(closedById),
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
    Value<String?> openedById = const Value.absent(),
    Value<String?> closedById = const Value.absent(),
  }) => CashShift(
    id: id ?? this.id,
    shiftNumber: shiftNumber ?? this.shiftNumber,
    openingFloat: openingFloat ?? this.openingFloat,
    closingCount: closingCount.present ? closingCount.value : this.closingCount,
    discrepancyReason: discrepancyReason ?? this.discrepancyReason,
    openedAt: openedAt ?? this.openedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    isOpen: isOpen ?? this.isOpen,
    openedById: openedById.present ? openedById.value : this.openedById,
    closedById: closedById.present ? closedById.value : this.closedById,
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
      openedById: data.openedById.present
          ? data.openedById.value
          : this.openedById,
      closedById: data.closedById.present
          ? data.closedById.value
          : this.closedById,
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
          ..write('isOpen: $isOpen, ')
          ..write('openedById: $openedById, ')
          ..write('closedById: $closedById')
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
    openedById,
    closedById,
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
          other.isOpen == this.isOpen &&
          other.openedById == this.openedById &&
          other.closedById == this.closedById);
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
  final Value<String?> openedById;
  final Value<String?> closedById;
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
    this.openedById = const Value.absent(),
    this.closedById = const Value.absent(),
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
    this.openedById = const Value.absent(),
    this.closedById = const Value.absent(),
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
    Expression<String>? openedById,
    Expression<String>? closedById,
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
      if (openedById != null) 'opened_by_id': openedById,
      if (closedById != null) 'closed_by_id': closedById,
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
    Value<String?>? openedById,
    Value<String?>? closedById,
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
      openedById: openedById ?? this.openedById,
      closedById: closedById ?? this.closedById,
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
    if (openedById.present) {
      map['opened_by_id'] = Variable<String>(openedById.value);
    }
    if (closedById.present) {
      map['closed_by_id'] = Variable<String>(closedById.value);
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
          ..write('openedById: $openedById, ')
          ..write('closedById: $closedById, ')
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
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shiftId,
    direction,
    amount,
    note,
    createdAt,
    staffId,
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
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
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
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      ),
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

  /// The staff member who recorded this cash movement.
  final String? staffId;
  const CashMovement({
    required this.id,
    required this.shiftId,
    required this.direction,
    required this.amount,
    required this.note,
    required this.createdAt,
    this.staffId,
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
    if (!nullToAbsent || staffId != null) {
      map['staff_id'] = Variable<String>(staffId);
    }
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
      staffId: staffId == null && nullToAbsent
          ? const Value.absent()
          : Value(staffId),
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
      staffId: serializer.fromJson<String?>(json['staffId']),
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
      'staffId': serializer.toJson<String?>(staffId),
    };
  }

  CashMovement copyWith({
    String? id,
    String? shiftId,
    String? direction,
    double? amount,
    String? note,
    DateTime? createdAt,
    Value<String?> staffId = const Value.absent(),
  }) => CashMovement(
    id: id ?? this.id,
    shiftId: shiftId ?? this.shiftId,
    direction: direction ?? this.direction,
    amount: amount ?? this.amount,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
    staffId: staffId.present ? staffId.value : this.staffId,
  );
  CashMovement copyWithCompanion(CashMovementsCompanion data) {
    return CashMovement(
      id: data.id.present ? data.id.value : this.id,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      direction: data.direction.present ? data.direction.value : this.direction,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
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
          ..write('createdAt: $createdAt, ')
          ..write('staffId: $staffId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, shiftId, direction, amount, note, createdAt, staffId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashMovement &&
          other.id == this.id &&
          other.shiftId == this.shiftId &&
          other.direction == this.direction &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.staffId == this.staffId);
}

class CashMovementsCompanion extends UpdateCompanion<CashMovement> {
  final Value<String> id;
  final Value<String> shiftId;
  final Value<String> direction;
  final Value<double> amount;
  final Value<String> note;
  final Value<DateTime> createdAt;
  final Value<String?> staffId;
  final Value<int> rowid;
  const CashMovementsCompanion({
    this.id = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.direction = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.staffId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashMovementsCompanion.insert({
    required String id,
    required String shiftId,
    required String direction,
    required double amount,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.staffId = const Value.absent(),
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
    Expression<String>? staffId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shiftId != null) 'shift_id': shiftId,
      if (direction != null) 'direction': direction,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (staffId != null) 'staff_id': staffId,
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
    Value<String?>? staffId,
    Value<int>? rowid,
  }) {
    return CashMovementsCompanion(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      staffId: staffId ?? this.staffId,
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
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
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
          ..write('staffId: $staffId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, Supplier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _contactPersonMeta = const VerificationMeta(
    'contactPerson',
  );
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
    'contact_person',
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
  static const VerificationMeta _taxNumberMeta = const VerificationMeta(
    'taxNumber',
  );
  @override
  late final GeneratedColumn<String> taxNumber = GeneratedColumn<String>(
    'tax_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _paymentTermsDaysMeta = const VerificationMeta(
    'paymentTermsDays',
  );
  @override
  late final GeneratedColumn<int> paymentTermsDays = GeneratedColumn<int>(
    'payment_terms_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    contactPerson,
    phone,
    email,
    address,
    taxNumber,
    paymentTermsDays,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Supplier> instance, {
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
    if (data.containsKey('contact_person')) {
      context.handle(
        _contactPersonMeta,
        contactPerson.isAcceptableOrUnknown(
          data['contact_person']!,
          _contactPersonMeta,
        ),
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
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('tax_number')) {
      context.handle(
        _taxNumberMeta,
        taxNumber.isAcceptableOrUnknown(data['tax_number']!, _taxNumberMeta),
      );
    }
    if (data.containsKey('payment_terms_days')) {
      context.handle(
        _paymentTermsDaysMeta,
        paymentTermsDays.isAcceptableOrUnknown(
          data['payment_terms_days']!,
          _paymentTermsDaysMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supplier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supplier(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contactPerson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_person'],
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
      taxNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_number'],
      )!,
      paymentTermsDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_terms_days'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class Supplier extends DataClass implements Insertable<Supplier> {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;

  /// Optional tax/VAT number for the supplier.
  final String taxNumber;

  /// Payment terms in days (e.g., 30 for net-30).
  final int paymentTermsDays;

  /// Notes about the supplier.
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.taxNumber,
    required this.paymentTermsDays,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['contact_person'] = Variable<String>(contactPerson);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    map['address'] = Variable<String>(address);
    map['tax_number'] = Variable<String>(taxNumber);
    map['payment_terms_days'] = Variable<int>(paymentTermsDays);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      name: Value(name),
      contactPerson: Value(contactPerson),
      phone: Value(phone),
      email: Value(email),
      address: Value(address),
      taxNumber: Value(taxNumber),
      paymentTermsDays: Value(paymentTermsDays),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Supplier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supplier(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contactPerson: serializer.fromJson<String>(json['contactPerson']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      address: serializer.fromJson<String>(json['address']),
      taxNumber: serializer.fromJson<String>(json['taxNumber']),
      paymentTermsDays: serializer.fromJson<int>(json['paymentTermsDays']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'contactPerson': serializer.toJson<String>(contactPerson),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'address': serializer.toJson<String>(address),
      'taxNumber': serializer.toJson<String>(taxNumber),
      'paymentTermsDays': serializer.toJson<int>(paymentTermsDays),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Supplier copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? taxNumber,
    int? paymentTermsDays,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Supplier(
    id: id ?? this.id,
    name: name ?? this.name,
    contactPerson: contactPerson ?? this.contactPerson,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    address: address ?? this.address,
    taxNumber: taxNumber ?? this.taxNumber,
    paymentTermsDays: paymentTermsDays ?? this.paymentTermsDays,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Supplier copyWithCompanion(SuppliersCompanion data) {
    return Supplier(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      taxNumber: data.taxNumber.present ? data.taxNumber.value : this.taxNumber,
      paymentTermsDays: data.paymentTermsDays.present
          ? data.paymentTermsDays.value
          : this.paymentTermsDays,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supplier(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('taxNumber: $taxNumber, ')
          ..write('paymentTermsDays: $paymentTermsDays, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    contactPerson,
    phone,
    email,
    address,
    taxNumber,
    paymentTermsDays,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supplier &&
          other.id == this.id &&
          other.name == this.name &&
          other.contactPerson == this.contactPerson &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.taxNumber == this.taxNumber &&
          other.paymentTermsDays == this.paymentTermsDays &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SuppliersCompanion extends UpdateCompanion<Supplier> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> contactPerson;
  final Value<String> phone;
  final Value<String> email;
  final Value<String> address;
  final Value<String> taxNumber;
  final Value<int> paymentTermsDays;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.taxNumber = const Value.absent(),
    this.paymentTermsDays = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersCompanion.insert({
    required String id,
    required String name,
    this.contactPerson = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.taxNumber = const Value.absent(),
    this.paymentTermsDays = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Supplier> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? contactPerson,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? taxNumber,
    Expression<int>? paymentTermsDays,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (taxNumber != null) 'tax_number': taxNumber,
      if (paymentTermsDays != null) 'payment_terms_days': paymentTermsDays,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? contactPerson,
    Value<String>? phone,
    Value<String>? email,
    Value<String>? address,
    Value<String>? taxNumber,
    Value<int>? paymentTermsDays,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      paymentTermsDays: paymentTermsDays ?? this.paymentTermsDays,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
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
    if (taxNumber.present) {
      map['tax_number'] = Variable<String>(taxNumber.value);
    }
    if (paymentTermsDays.present) {
      map['payment_terms_days'] = Variable<int>(paymentTermsDays.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('taxNumber: $taxNumber, ')
          ..write('paymentTermsDays: $paymentTermsDays, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseOrdersTable extends PurchaseOrders
    with TableInfo<$PurchaseOrdersTable, PurchaseOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierReferenceMeta = const VerificationMeta(
    'supplierReference',
  );
  @override
  late final GeneratedColumn<String> supplierReference =
      GeneratedColumn<String>(
        'supplier_reference',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _taxAmountMeta = const VerificationMeta(
    'taxAmount',
  );
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
    'tax_amount',
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedDateMeta = const VerificationMeta(
    'expectedDate',
  );
  @override
  late final GeneratedColumn<DateTime> expectedDate = GeneratedColumn<DateTime>(
    'expected_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    supplierId,
    supplierReference,
    status,
    subtotal,
    taxAmount,
    total,
    notes,
    createdAt,
    updatedAt,
    expectedDate,
    receivedAt,
    staffId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseOrder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('supplier_reference')) {
      context.handle(
        _supplierReferenceMeta,
        supplierReference.isAcceptableOrUnknown(
          data['supplier_reference']!,
          _supplierReferenceMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    }
    if (data.containsKey('tax_amount')) {
      context.handle(
        _taxAmountMeta,
        taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('expected_date')) {
      context.handle(
        _expectedDateMeta,
        expectedDate.isAcceptableOrUnknown(
          data['expected_date']!,
          _expectedDateMeta,
        ),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    }
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseOrder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      supplierReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_reference'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      taxAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_amount'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      expectedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expected_date'],
      ),
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      ),
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      ),
    );
  }

  @override
  $PurchaseOrdersTable createAlias(String alias) {
    return $PurchaseOrdersTable(attachedDatabase, alias);
  }
}

class PurchaseOrder extends DataClass implements Insertable<PurchaseOrder> {
  final String id;

  /// The supplier this PO is for.
  final String supplierId;

  /// Optional reference number from the supplier.
  final String supplierReference;

  /// PO status.
  final String status;

  /// Subtotal before tax.
  final double subtotal;

  /// Tax amount.
  final double taxAmount;

  /// Total amount including tax.
  final double total;

  /// Notes for the supplier.
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Expected delivery date.
  final DateTime? expectedDate;

  /// Actual received date (when fully received).
  final DateTime? receivedAt;

  /// The staff member who created this purchase order.
  final String? staffId;
  const PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.supplierReference,
    required this.status,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.expectedDate,
    this.receivedAt,
    this.staffId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['supplier_id'] = Variable<String>(supplierId);
    map['supplier_reference'] = Variable<String>(supplierReference);
    map['status'] = Variable<String>(status);
    map['subtotal'] = Variable<double>(subtotal);
    map['tax_amount'] = Variable<double>(taxAmount);
    map['total'] = Variable<double>(total);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || expectedDate != null) {
      map['expected_date'] = Variable<DateTime>(expectedDate);
    }
    if (!nullToAbsent || receivedAt != null) {
      map['received_at'] = Variable<DateTime>(receivedAt);
    }
    if (!nullToAbsent || staffId != null) {
      map['staff_id'] = Variable<String>(staffId);
    }
    return map;
  }

  PurchaseOrdersCompanion toCompanion(bool nullToAbsent) {
    return PurchaseOrdersCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      supplierReference: Value(supplierReference),
      status: Value(status),
      subtotal: Value(subtotal),
      taxAmount: Value(taxAmount),
      total: Value(total),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      expectedDate: expectedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedDate),
      receivedAt: receivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAt),
      staffId: staffId == null && nullToAbsent
          ? const Value.absent()
          : Value(staffId),
    );
  }

  factory PurchaseOrder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseOrder(
      id: serializer.fromJson<String>(json['id']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      supplierReference: serializer.fromJson<String>(json['supplierReference']),
      status: serializer.fromJson<String>(json['status']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
      total: serializer.fromJson<double>(json['total']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      expectedDate: serializer.fromJson<DateTime?>(json['expectedDate']),
      receivedAt: serializer.fromJson<DateTime?>(json['receivedAt']),
      staffId: serializer.fromJson<String?>(json['staffId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'supplierId': serializer.toJson<String>(supplierId),
      'supplierReference': serializer.toJson<String>(supplierReference),
      'status': serializer.toJson<String>(status),
      'subtotal': serializer.toJson<double>(subtotal),
      'taxAmount': serializer.toJson<double>(taxAmount),
      'total': serializer.toJson<double>(total),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'expectedDate': serializer.toJson<DateTime?>(expectedDate),
      'receivedAt': serializer.toJson<DateTime?>(receivedAt),
      'staffId': serializer.toJson<String?>(staffId),
    };
  }

  PurchaseOrder copyWith({
    String? id,
    String? supplierId,
    String? supplierReference,
    String? status,
    double? subtotal,
    double? taxAmount,
    double? total,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> expectedDate = const Value.absent(),
    Value<DateTime?> receivedAt = const Value.absent(),
    Value<String?> staffId = const Value.absent(),
  }) => PurchaseOrder(
    id: id ?? this.id,
    supplierId: supplierId ?? this.supplierId,
    supplierReference: supplierReference ?? this.supplierReference,
    status: status ?? this.status,
    subtotal: subtotal ?? this.subtotal,
    taxAmount: taxAmount ?? this.taxAmount,
    total: total ?? this.total,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    expectedDate: expectedDate.present ? expectedDate.value : this.expectedDate,
    receivedAt: receivedAt.present ? receivedAt.value : this.receivedAt,
    staffId: staffId.present ? staffId.value : this.staffId,
  );
  PurchaseOrder copyWithCompanion(PurchaseOrdersCompanion data) {
    return PurchaseOrder(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      supplierReference: data.supplierReference.present
          ? data.supplierReference.value
          : this.supplierReference,
      status: data.status.present ? data.status.value : this.status,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      total: data.total.present ? data.total.value : this.total,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      expectedDate: data.expectedDate.present
          ? data.expectedDate.value
          : this.expectedDate,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrder(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplierReference: $supplierReference, ')
          ..write('status: $status, ')
          ..write('subtotal: $subtotal, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('total: $total, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('staffId: $staffId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    supplierId,
    supplierReference,
    status,
    subtotal,
    taxAmount,
    total,
    notes,
    createdAt,
    updatedAt,
    expectedDate,
    receivedAt,
    staffId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseOrder &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.supplierReference == this.supplierReference &&
          other.status == this.status &&
          other.subtotal == this.subtotal &&
          other.taxAmount == this.taxAmount &&
          other.total == this.total &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.expectedDate == this.expectedDate &&
          other.receivedAt == this.receivedAt &&
          other.staffId == this.staffId);
}

class PurchaseOrdersCompanion extends UpdateCompanion<PurchaseOrder> {
  final Value<String> id;
  final Value<String> supplierId;
  final Value<String> supplierReference;
  final Value<String> status;
  final Value<double> subtotal;
  final Value<double> taxAmount;
  final Value<double> total;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> expectedDate;
  final Value<DateTime?> receivedAt;
  final Value<String?> staffId;
  final Value<int> rowid;
  const PurchaseOrdersCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.supplierReference = const Value.absent(),
    this.status = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.total = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.expectedDate = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.staffId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseOrdersCompanion.insert({
    required String id,
    required String supplierId,
    this.supplierReference = const Value.absent(),
    this.status = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.total = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.expectedDate = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.staffId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       supplierId = Value(supplierId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PurchaseOrder> custom({
    Expression<String>? id,
    Expression<String>? supplierId,
    Expression<String>? supplierReference,
    Expression<String>? status,
    Expression<double>? subtotal,
    Expression<double>? taxAmount,
    Expression<double>? total,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? expectedDate,
    Expression<DateTime>? receivedAt,
    Expression<String>? staffId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (supplierReference != null) 'supplier_reference': supplierReference,
      if (status != null) 'status': status,
      if (subtotal != null) 'subtotal': subtotal,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (total != null) 'total': total,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (expectedDate != null) 'expected_date': expectedDate,
      if (receivedAt != null) 'received_at': receivedAt,
      if (staffId != null) 'staff_id': staffId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseOrdersCompanion copyWith({
    Value<String>? id,
    Value<String>? supplierId,
    Value<String>? supplierReference,
    Value<String>? status,
    Value<double>? subtotal,
    Value<double>? taxAmount,
    Value<double>? total,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? expectedDate,
    Value<DateTime?>? receivedAt,
    Value<String?>? staffId,
    Value<int>? rowid,
  }) {
    return PurchaseOrdersCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierReference: supplierReference ?? this.supplierReference,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expectedDate: expectedDate ?? this.expectedDate,
      receivedAt: receivedAt ?? this.receivedAt,
      staffId: staffId ?? this.staffId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (supplierReference.present) {
      map['supplier_reference'] = Variable<String>(supplierReference.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (expectedDate.present) {
      map['expected_date'] = Variable<DateTime>(expectedDate.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrdersCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplierReference: $supplierReference, ')
          ..write('status: $status, ')
          ..write('subtotal: $subtotal, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('total: $total, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('staffId: $staffId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseOrderItemsTable extends PurchaseOrderItems
    with TableInfo<$PurchaseOrderItemsTable, PurchaseOrderItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseOrderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseOrderIdMeta = const VerificationMeta(
    'purchaseOrderId',
  );
  @override
  late final GeneratedColumn<String> purchaseOrderId = GeneratedColumn<String>(
    'purchase_order_id',
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
  static const VerificationMeta _productSkuMeta = const VerificationMeta(
    'productSku',
  );
  @override
  late final GeneratedColumn<String> productSku = GeneratedColumn<String>(
    'product_sku',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _quantityOrderedMeta = const VerificationMeta(
    'quantityOrdered',
  );
  @override
  late final GeneratedColumn<int> quantityOrdered = GeneratedColumn<int>(
    'quantity_ordered',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityReceivedMeta = const VerificationMeta(
    'quantityReceived',
  );
  @override
  late final GeneratedColumn<int> quantityReceived = GeneratedColumn<int>(
    'quantity_received',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unitCostMeta = const VerificationMeta(
    'unitCost',
  );
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
    'unit_cost',
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    purchaseOrderId,
    productId,
    productName,
    productSku,
    quantityOrdered,
    quantityReceived,
    unitCost,
    total,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_order_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseOrderItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_order_id')) {
      context.handle(
        _purchaseOrderIdMeta,
        purchaseOrderId.isAcceptableOrUnknown(
          data['purchase_order_id']!,
          _purchaseOrderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseOrderIdMeta);
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
    if (data.containsKey('product_sku')) {
      context.handle(
        _productSkuMeta,
        productSku.isAcceptableOrUnknown(data['product_sku']!, _productSkuMeta),
      );
    }
    if (data.containsKey('quantity_ordered')) {
      context.handle(
        _quantityOrderedMeta,
        quantityOrdered.isAcceptableOrUnknown(
          data['quantity_ordered']!,
          _quantityOrderedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityOrderedMeta);
    }
    if (data.containsKey('quantity_received')) {
      context.handle(
        _quantityReceivedMeta,
        quantityReceived.isAcceptableOrUnknown(
          data['quantity_received']!,
          _quantityReceivedMeta,
        ),
      );
    }
    if (data.containsKey('unit_cost')) {
      context.handle(
        _unitCostMeta,
        unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta),
      );
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseOrderItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseOrderItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      purchaseOrderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_order_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      productSku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_sku'],
      )!,
      quantityOrdered: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_ordered'],
      )!,
      quantityReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_received'],
      )!,
      unitCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_cost'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $PurchaseOrderItemsTable createAlias(String alias) {
    return $PurchaseOrderItemsTable(attachedDatabase, alias);
  }
}

class PurchaseOrderItem extends DataClass
    implements Insertable<PurchaseOrderItem> {
  final String id;
  final String purchaseOrderId;
  final String productId;
  final String productName;
  final String productSku;

  /// Quantity ordered.
  final int quantityOrdered;

  /// Quantity received so far.
  final int quantityReceived;

  /// Unit cost from supplier.
  final double unitCost;

  /// Line total (quantityOrdered × unitCost).
  final double total;

  /// Optional notes for this line.
  final String notes;
  const PurchaseOrderItem({
    required this.id,
    required this.purchaseOrderId,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.quantityOrdered,
    required this.quantityReceived,
    required this.unitCost,
    required this.total,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_order_id'] = Variable<String>(purchaseOrderId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['product_sku'] = Variable<String>(productSku);
    map['quantity_ordered'] = Variable<int>(quantityOrdered);
    map['quantity_received'] = Variable<int>(quantityReceived);
    map['unit_cost'] = Variable<double>(unitCost);
    map['total'] = Variable<double>(total);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  PurchaseOrderItemsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseOrderItemsCompanion(
      id: Value(id),
      purchaseOrderId: Value(purchaseOrderId),
      productId: Value(productId),
      productName: Value(productName),
      productSku: Value(productSku),
      quantityOrdered: Value(quantityOrdered),
      quantityReceived: Value(quantityReceived),
      unitCost: Value(unitCost),
      total: Value(total),
      notes: Value(notes),
    );
  }

  factory PurchaseOrderItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseOrderItem(
      id: serializer.fromJson<String>(json['id']),
      purchaseOrderId: serializer.fromJson<String>(json['purchaseOrderId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      productSku: serializer.fromJson<String>(json['productSku']),
      quantityOrdered: serializer.fromJson<int>(json['quantityOrdered']),
      quantityReceived: serializer.fromJson<int>(json['quantityReceived']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      total: serializer.fromJson<double>(json['total']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseOrderId': serializer.toJson<String>(purchaseOrderId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'productSku': serializer.toJson<String>(productSku),
      'quantityOrdered': serializer.toJson<int>(quantityOrdered),
      'quantityReceived': serializer.toJson<int>(quantityReceived),
      'unitCost': serializer.toJson<double>(unitCost),
      'total': serializer.toJson<double>(total),
      'notes': serializer.toJson<String>(notes),
    };
  }

  PurchaseOrderItem copyWith({
    String? id,
    String? purchaseOrderId,
    String? productId,
    String? productName,
    String? productSku,
    int? quantityOrdered,
    int? quantityReceived,
    double? unitCost,
    double? total,
    String? notes,
  }) => PurchaseOrderItem(
    id: id ?? this.id,
    purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    productSku: productSku ?? this.productSku,
    quantityOrdered: quantityOrdered ?? this.quantityOrdered,
    quantityReceived: quantityReceived ?? this.quantityReceived,
    unitCost: unitCost ?? this.unitCost,
    total: total ?? this.total,
    notes: notes ?? this.notes,
  );
  PurchaseOrderItem copyWithCompanion(PurchaseOrderItemsCompanion data) {
    return PurchaseOrderItem(
      id: data.id.present ? data.id.value : this.id,
      purchaseOrderId: data.purchaseOrderId.present
          ? data.purchaseOrderId.value
          : this.purchaseOrderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      productSku: data.productSku.present
          ? data.productSku.value
          : this.productSku,
      quantityOrdered: data.quantityOrdered.present
          ? data.quantityOrdered.value
          : this.quantityOrdered,
      quantityReceived: data.quantityReceived.present
          ? data.quantityReceived.value
          : this.quantityReceived,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      total: data.total.present ? data.total.value : this.total,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrderItem(')
          ..write('id: $id, ')
          ..write('purchaseOrderId: $purchaseOrderId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('productSku: $productSku, ')
          ..write('quantityOrdered: $quantityOrdered, ')
          ..write('quantityReceived: $quantityReceived, ')
          ..write('unitCost: $unitCost, ')
          ..write('total: $total, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    purchaseOrderId,
    productId,
    productName,
    productSku,
    quantityOrdered,
    quantityReceived,
    unitCost,
    total,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseOrderItem &&
          other.id == this.id &&
          other.purchaseOrderId == this.purchaseOrderId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.productSku == this.productSku &&
          other.quantityOrdered == this.quantityOrdered &&
          other.quantityReceived == this.quantityReceived &&
          other.unitCost == this.unitCost &&
          other.total == this.total &&
          other.notes == this.notes);
}

class PurchaseOrderItemsCompanion extends UpdateCompanion<PurchaseOrderItem> {
  final Value<String> id;
  final Value<String> purchaseOrderId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<String> productSku;
  final Value<int> quantityOrdered;
  final Value<int> quantityReceived;
  final Value<double> unitCost;
  final Value<double> total;
  final Value<String> notes;
  final Value<int> rowid;
  const PurchaseOrderItemsCompanion({
    this.id = const Value.absent(),
    this.purchaseOrderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.productSku = const Value.absent(),
    this.quantityOrdered = const Value.absent(),
    this.quantityReceived = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.total = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseOrderItemsCompanion.insert({
    required String id,
    required String purchaseOrderId,
    required String productId,
    required String productName,
    this.productSku = const Value.absent(),
    required int quantityOrdered,
    this.quantityReceived = const Value.absent(),
    required double unitCost,
    required double total,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       purchaseOrderId = Value(purchaseOrderId),
       productId = Value(productId),
       productName = Value(productName),
       quantityOrdered = Value(quantityOrdered),
       unitCost = Value(unitCost),
       total = Value(total);
  static Insertable<PurchaseOrderItem> custom({
    Expression<String>? id,
    Expression<String>? purchaseOrderId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<String>? productSku,
    Expression<int>? quantityOrdered,
    Expression<int>? quantityReceived,
    Expression<double>? unitCost,
    Expression<double>? total,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseOrderId != null) 'purchase_order_id': purchaseOrderId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (productSku != null) 'product_sku': productSku,
      if (quantityOrdered != null) 'quantity_ordered': quantityOrdered,
      if (quantityReceived != null) 'quantity_received': quantityReceived,
      if (unitCost != null) 'unit_cost': unitCost,
      if (total != null) 'total': total,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseOrderItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? purchaseOrderId,
    Value<String>? productId,
    Value<String>? productName,
    Value<String>? productSku,
    Value<int>? quantityOrdered,
    Value<int>? quantityReceived,
    Value<double>? unitCost,
    Value<double>? total,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return PurchaseOrderItemsCompanion(
      id: id ?? this.id,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      quantityOrdered: quantityOrdered ?? this.quantityOrdered,
      quantityReceived: quantityReceived ?? this.quantityReceived,
      unitCost: unitCost ?? this.unitCost,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseOrderId.present) {
      map['purchase_order_id'] = Variable<String>(purchaseOrderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (productSku.present) {
      map['product_sku'] = Variable<String>(productSku.value);
    }
    if (quantityOrdered.present) {
      map['quantity_ordered'] = Variable<int>(quantityOrdered.value);
    }
    if (quantityReceived.present) {
      map['quantity_received'] = Variable<int>(quantityReceived.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrderItemsCompanion(')
          ..write('id: $id, ')
          ..write('purchaseOrderId: $purchaseOrderId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('productSku: $productSku, ')
          ..write('quantityOrdered: $quantityOrdered, ')
          ..write('quantityReceived: $quantityReceived, ')
          ..write('unitCost: $unitCost, ')
          ..write('total: $total, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomerCreditAccountsTable extends CustomerCreditAccounts
    with TableInfo<$CustomerCreditAccountsTable, CustomerCreditAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerCreditAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _creditLimitMeta = const VerificationMeta(
    'creditLimit',
  );
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
    'credit_limit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _currentBalanceMeta = const VerificationMeta(
    'currentBalance',
  );
  @override
  late final GeneratedColumn<double> currentBalance = GeneratedColumn<double>(
    'current_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _paymentTermsMeta = const VerificationMeta(
    'paymentTerms',
  );
  @override
  late final GeneratedColumn<String> paymentTerms = GeneratedColumn<String>(
    'payment_terms',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Net 30'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    creditLimit,
    currentBalance,
    paymentTerms,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_credit_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerCreditAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
        _creditLimitMeta,
        creditLimit.isAcceptableOrUnknown(
          data['credit_limit']!,
          _creditLimitMeta,
        ),
      );
    }
    if (data.containsKey('current_balance')) {
      context.handle(
        _currentBalanceMeta,
        currentBalance.isAcceptableOrUnknown(
          data['current_balance']!,
          _currentBalanceMeta,
        ),
      );
    }
    if (data.containsKey('payment_terms')) {
      context.handle(
        _paymentTermsMeta,
        paymentTerms.isAcceptableOrUnknown(
          data['payment_terms']!,
          _paymentTermsMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerCreditAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerCreditAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      creditLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit_limit'],
      )!,
      currentBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_balance'],
      )!,
      paymentTerms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_terms'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CustomerCreditAccountsTable createAlias(String alias) {
    return $CustomerCreditAccountsTable(attachedDatabase, alias);
  }
}

class CustomerCreditAccount extends DataClass
    implements Insertable<CustomerCreditAccount> {
  final int id;
  final String customerId;
  final double creditLimit;
  final double currentBalance;
  final String paymentTerms;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CustomerCreditAccount({
    required this.id,
    required this.customerId,
    required this.creditLimit,
    required this.currentBalance,
    required this.paymentTerms,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<String>(customerId);
    map['credit_limit'] = Variable<double>(creditLimit);
    map['current_balance'] = Variable<double>(currentBalance);
    map['payment_terms'] = Variable<String>(paymentTerms);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomerCreditAccountsCompanion toCompanion(bool nullToAbsent) {
    return CustomerCreditAccountsCompanion(
      id: Value(id),
      customerId: Value(customerId),
      creditLimit: Value(creditLimit),
      currentBalance: Value(currentBalance),
      paymentTerms: Value(paymentTerms),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomerCreditAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerCreditAccount(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      creditLimit: serializer.fromJson<double>(json['creditLimit']),
      currentBalance: serializer.fromJson<double>(json['currentBalance']),
      paymentTerms: serializer.fromJson<String>(json['paymentTerms']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<String>(customerId),
      'creditLimit': serializer.toJson<double>(creditLimit),
      'currentBalance': serializer.toJson<double>(currentBalance),
      'paymentTerms': serializer.toJson<String>(paymentTerms),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CustomerCreditAccount copyWith({
    int? id,
    String? customerId,
    double? creditLimit,
    double? currentBalance,
    String? paymentTerms,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CustomerCreditAccount(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    creditLimit: creditLimit ?? this.creditLimit,
    currentBalance: currentBalance ?? this.currentBalance,
    paymentTerms: paymentTerms ?? this.paymentTerms,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CustomerCreditAccount copyWithCompanion(
    CustomerCreditAccountsCompanion data,
  ) {
    return CustomerCreditAccount(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      creditLimit: data.creditLimit.present
          ? data.creditLimit.value
          : this.creditLimit,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      paymentTerms: data.paymentTerms.present
          ? data.paymentTerms.value
          : this.paymentTerms,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerCreditAccount(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('paymentTerms: $paymentTerms, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    creditLimit,
    currentBalance,
    paymentTerms,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerCreditAccount &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.creditLimit == this.creditLimit &&
          other.currentBalance == this.currentBalance &&
          other.paymentTerms == this.paymentTerms &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomerCreditAccountsCompanion
    extends UpdateCompanion<CustomerCreditAccount> {
  final Value<int> id;
  final Value<String> customerId;
  final Value<double> creditLimit;
  final Value<double> currentBalance;
  final Value<String> paymentTerms;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CustomerCreditAccountsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.paymentTerms = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CustomerCreditAccountsCompanion.insert({
    this.id = const Value.absent(),
    required String customerId,
    this.creditLimit = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.paymentTerms = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : customerId = Value(customerId);
  static Insertable<CustomerCreditAccount> custom({
    Expression<int>? id,
    Expression<String>? customerId,
    Expression<double>? creditLimit,
    Expression<double>? currentBalance,
    Expression<String>? paymentTerms,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (paymentTerms != null) 'payment_terms': paymentTerms,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CustomerCreditAccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? customerId,
    Value<double>? creditLimit,
    Value<double>? currentBalance,
    Value<String>? paymentTerms,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CustomerCreditAccountsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<double>(currentBalance.value);
    }
    if (paymentTerms.present) {
      map['payment_terms'] = Variable<String>(paymentTerms.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerCreditAccountsCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('paymentTerms: $paymentTerms, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CustomerCreditTransactionsTable extends CustomerCreditTransactions
    with
        TableInfo<$CustomerCreditTransactionsTable, CustomerCreditTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerCreditTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customer_credit_accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _balanceAfterMeta = const VerificationMeta(
    'balanceAfter',
  );
  @override
  late final GeneratedColumn<double> balanceAfter = GeneratedColumn<double>(
    'balance_after',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<int> createdBy = GeneratedColumn<int>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    type,
    reference,
    amount,
    balanceAfter,
    description,
    createdAt,
    createdBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_credit_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerCreditTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('balance_after')) {
      context.handle(
        _balanceAfterMeta,
        balanceAfter.isAcceptableOrUnknown(
          data['balance_after']!,
          _balanceAfterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balanceAfterMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerCreditTransaction map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerCreditTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      balanceAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance_after'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_by'],
      ),
    );
  }

  @override
  $CustomerCreditTransactionsTable createAlias(String alias) {
    return $CustomerCreditTransactionsTable(attachedDatabase, alias);
  }
}

class CustomerCreditTransaction extends DataClass
    implements Insertable<CustomerCreditTransaction> {
  final int id;
  final int accountId;
  final String type;
  final String? reference;
  final double amount;
  final double balanceAfter;
  final String? description;
  final DateTime createdAt;
  final int? createdBy;
  const CustomerCreditTransaction({
    required this.id,
    required this.accountId,
    required this.type,
    this.reference,
    required this.amount,
    required this.balanceAfter,
    this.description,
    required this.createdAt,
    this.createdBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['amount'] = Variable<double>(amount);
    map['balance_after'] = Variable<double>(balanceAfter);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<int>(createdBy);
    }
    return map;
  }

  CustomerCreditTransactionsCompanion toCompanion(bool nullToAbsent) {
    return CustomerCreditTransactionsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      type: Value(type),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      amount: Value(amount),
      balanceAfter: Value(balanceAfter),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
    );
  }

  factory CustomerCreditTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerCreditTransaction(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      type: serializer.fromJson<String>(json['type']),
      reference: serializer.fromJson<String?>(json['reference']),
      amount: serializer.fromJson<double>(json['amount']),
      balanceAfter: serializer.fromJson<double>(json['balanceAfter']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdBy: serializer.fromJson<int?>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'type': serializer.toJson<String>(type),
      'reference': serializer.toJson<String?>(reference),
      'amount': serializer.toJson<double>(amount),
      'balanceAfter': serializer.toJson<double>(balanceAfter),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdBy': serializer.toJson<int?>(createdBy),
    };
  }

  CustomerCreditTransaction copyWith({
    int? id,
    int? accountId,
    String? type,
    Value<String?> reference = const Value.absent(),
    double? amount,
    double? balanceAfter,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    Value<int?> createdBy = const Value.absent(),
  }) => CustomerCreditTransaction(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    type: type ?? this.type,
    reference: reference.present ? reference.value : this.reference,
    amount: amount ?? this.amount,
    balanceAfter: balanceAfter ?? this.balanceAfter,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
  );
  CustomerCreditTransaction copyWithCompanion(
    CustomerCreditTransactionsCompanion data,
  ) {
    return CustomerCreditTransaction(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      type: data.type.present ? data.type.value : this.type,
      reference: data.reference.present ? data.reference.value : this.reference,
      amount: data.amount.present ? data.amount.value : this.amount,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerCreditTransaction(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('type: $type, ')
          ..write('reference: $reference, ')
          ..write('amount: $amount, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    type,
    reference,
    amount,
    balanceAfter,
    description,
    createdAt,
    createdBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerCreditTransaction &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.type == this.type &&
          other.reference == this.reference &&
          other.amount == this.amount &&
          other.balanceAfter == this.balanceAfter &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy);
}

class CustomerCreditTransactionsCompanion
    extends UpdateCompanion<CustomerCreditTransaction> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<String> type;
  final Value<String?> reference;
  final Value<double> amount;
  final Value<double> balanceAfter;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<int?> createdBy;
  const CustomerCreditTransactionsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.type = const Value.absent(),
    this.reference = const Value.absent(),
    this.amount = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
  });
  CustomerCreditTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    required String type,
    this.reference = const Value.absent(),
    required double amount,
    required double balanceAfter,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
  }) : accountId = Value(accountId),
       type = Value(type),
       amount = Value(amount),
       balanceAfter = Value(balanceAfter);
  static Insertable<CustomerCreditTransaction> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<String>? type,
    Expression<String>? reference,
    Expression<double>? amount,
    Expression<double>? balanceAfter,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<int>? createdBy,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (type != null) 'type': type,
      if (reference != null) 'reference': reference,
      if (amount != null) 'amount': amount,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
    });
  }

  CustomerCreditTransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? accountId,
    Value<String>? type,
    Value<String?>? reference,
    Value<double>? amount,
    Value<double>? balanceAfter,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<int?>? createdBy,
  }) {
    return CustomerCreditTransactionsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      reference: reference ?? this.reference,
      amount: amount ?? this.amount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<double>(balanceAfter.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<int>(createdBy.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerCreditTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('type: $type, ')
          ..write('reference: $reference, ')
          ..write('amount: $amount, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }
}

class $StaffAccountsTable extends StaffAccounts
    with TableInfo<$StaffAccountsTable, StaffAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _pinVerifierMeta = const VerificationMeta(
    'pinVerifier',
  );
  @override
  late final GeneratedColumn<String> pinVerifier = GeneratedColumn<String>(
    'pin_verifier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recoveryCodeVerifierMeta =
      const VerificationMeta('recoveryCodeVerifier');
  @override
  late final GeneratedColumn<String> recoveryCodeVerifier =
      GeneratedColumn<String>(
        'recovery_code_verifier',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _failedPinAttemptsMeta = const VerificationMeta(
    'failedPinAttempts',
  );
  @override
  late final GeneratedColumn<int> failedPinAttempts = GeneratedColumn<int>(
    'failed_pin_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pinLockedUntilMeta = const VerificationMeta(
    'pinLockedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> pinLockedUntil =
      GeneratedColumn<DateTime>(
        'pin_locked_until',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pinChangedAtMeta = const VerificationMeta(
    'pinChangedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pinChangedAt = GeneratedColumn<DateTime>(
    'pin_changed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    username,
    displayName,
    role,
    isActive,
    pinVerifier,
    recoveryCodeVerifier,
    failedPinAttempts,
    pinLockedUntil,
    pinChangedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<StaffAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('pin_verifier')) {
      context.handle(
        _pinVerifierMeta,
        pinVerifier.isAcceptableOrUnknown(
          data['pin_verifier']!,
          _pinVerifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pinVerifierMeta);
    }
    if (data.containsKey('recovery_code_verifier')) {
      context.handle(
        _recoveryCodeVerifierMeta,
        recoveryCodeVerifier.isAcceptableOrUnknown(
          data['recovery_code_verifier']!,
          _recoveryCodeVerifierMeta,
        ),
      );
    }
    if (data.containsKey('failed_pin_attempts')) {
      context.handle(
        _failedPinAttemptsMeta,
        failedPinAttempts.isAcceptableOrUnknown(
          data['failed_pin_attempts']!,
          _failedPinAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('pin_locked_until')) {
      context.handle(
        _pinLockedUntilMeta,
        pinLockedUntil.isAcceptableOrUnknown(
          data['pin_locked_until']!,
          _pinLockedUntilMeta,
        ),
      );
    }
    if (data.containsKey('pin_changed_at')) {
      context.handle(
        _pinChangedAtMeta,
        pinChangedAt.isAcceptableOrUnknown(
          data['pin_changed_at']!,
          _pinChangedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pinChangedAtMeta);
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
  StaffAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      pinVerifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_verifier'],
      )!,
      recoveryCodeVerifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recovery_code_verifier'],
      ),
      failedPinAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_pin_attempts'],
      )!,
      pinLockedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pin_locked_until'],
      ),
      pinChangedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pin_changed_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StaffAccountsTable createAlias(String alias) {
    return $StaffAccountsTable(attachedDatabase, alias);
  }
}

class StaffAccount extends DataClass implements Insertable<StaffAccount> {
  final String id;

  /// Normalized (trimmed, lowercased) unique login identifier.
  final String username;

  /// Optional display label shown in future UIs.
  final String displayName;

  /// 'owner' | 'manager' | 'cashier' — validated by the repository.
  final String role;

  /// Deactivated accounts cannot verify PINs (login) but keep their data.
  final bool isActive;

  /// bcrypt verifier of the staff PIN. Never exposed outside the
  /// repository's private verification path.
  final String pinVerifier;

  /// bcrypt verifier of the owner's one-time recovery code. Set (only) on
  /// the owner row at creation and rotated on each recovery.
  final String? recoveryCodeVerifier;

  /// Consecutive failed PIN attempts; reset on success and when a lock
  /// begins. Persisted so restarts and web refreshes cannot bypass it.
  final int failedPinAttempts;

  /// While in the future, the account is locked and no PIN verification is
  /// attempted. Null when not locked.
  final DateTime? pinLockedUntil;
  final DateTime pinChangedAt;
  final DateTime createdAt;
  const StaffAccount({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    required this.isActive,
    required this.pinVerifier,
    this.recoveryCodeVerifier,
    required this.failedPinAttempts,
    this.pinLockedUntil,
    required this.pinChangedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['username'] = Variable<String>(username);
    map['display_name'] = Variable<String>(displayName);
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    map['pin_verifier'] = Variable<String>(pinVerifier);
    if (!nullToAbsent || recoveryCodeVerifier != null) {
      map['recovery_code_verifier'] = Variable<String>(recoveryCodeVerifier);
    }
    map['failed_pin_attempts'] = Variable<int>(failedPinAttempts);
    if (!nullToAbsent || pinLockedUntil != null) {
      map['pin_locked_until'] = Variable<DateTime>(pinLockedUntil);
    }
    map['pin_changed_at'] = Variable<DateTime>(pinChangedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StaffAccountsCompanion toCompanion(bool nullToAbsent) {
    return StaffAccountsCompanion(
      id: Value(id),
      username: Value(username),
      displayName: Value(displayName),
      role: Value(role),
      isActive: Value(isActive),
      pinVerifier: Value(pinVerifier),
      recoveryCodeVerifier: recoveryCodeVerifier == null && nullToAbsent
          ? const Value.absent()
          : Value(recoveryCodeVerifier),
      failedPinAttempts: Value(failedPinAttempts),
      pinLockedUntil: pinLockedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(pinLockedUntil),
      pinChangedAt: Value(pinChangedAt),
      createdAt: Value(createdAt),
    );
  }

  factory StaffAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffAccount(
      id: serializer.fromJson<String>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      displayName: serializer.fromJson<String>(json['displayName']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      pinVerifier: serializer.fromJson<String>(json['pinVerifier']),
      recoveryCodeVerifier: serializer.fromJson<String?>(
        json['recoveryCodeVerifier'],
      ),
      failedPinAttempts: serializer.fromJson<int>(json['failedPinAttempts']),
      pinLockedUntil: serializer.fromJson<DateTime?>(json['pinLockedUntil']),
      pinChangedAt: serializer.fromJson<DateTime>(json['pinChangedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'username': serializer.toJson<String>(username),
      'displayName': serializer.toJson<String>(displayName),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'pinVerifier': serializer.toJson<String>(pinVerifier),
      'recoveryCodeVerifier': serializer.toJson<String?>(recoveryCodeVerifier),
      'failedPinAttempts': serializer.toJson<int>(failedPinAttempts),
      'pinLockedUntil': serializer.toJson<DateTime?>(pinLockedUntil),
      'pinChangedAt': serializer.toJson<DateTime>(pinChangedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StaffAccount copyWith({
    String? id,
    String? username,
    String? displayName,
    String? role,
    bool? isActive,
    String? pinVerifier,
    Value<String?> recoveryCodeVerifier = const Value.absent(),
    int? failedPinAttempts,
    Value<DateTime?> pinLockedUntil = const Value.absent(),
    DateTime? pinChangedAt,
    DateTime? createdAt,
  }) => StaffAccount(
    id: id ?? this.id,
    username: username ?? this.username,
    displayName: displayName ?? this.displayName,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
    pinVerifier: pinVerifier ?? this.pinVerifier,
    recoveryCodeVerifier: recoveryCodeVerifier.present
        ? recoveryCodeVerifier.value
        : this.recoveryCodeVerifier,
    failedPinAttempts: failedPinAttempts ?? this.failedPinAttempts,
    pinLockedUntil: pinLockedUntil.present
        ? pinLockedUntil.value
        : this.pinLockedUntil,
    pinChangedAt: pinChangedAt ?? this.pinChangedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  StaffAccount copyWithCompanion(StaffAccountsCompanion data) {
    return StaffAccount(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      pinVerifier: data.pinVerifier.present
          ? data.pinVerifier.value
          : this.pinVerifier,
      recoveryCodeVerifier: data.recoveryCodeVerifier.present
          ? data.recoveryCodeVerifier.value
          : this.recoveryCodeVerifier,
      failedPinAttempts: data.failedPinAttempts.present
          ? data.failedPinAttempts.value
          : this.failedPinAttempts,
      pinLockedUntil: data.pinLockedUntil.present
          ? data.pinLockedUntil.value
          : this.pinLockedUntil,
      pinChangedAt: data.pinChangedAt.present
          ? data.pinChangedAt.value
          : this.pinChangedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffAccount(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('pinVerifier: $pinVerifier, ')
          ..write('recoveryCodeVerifier: $recoveryCodeVerifier, ')
          ..write('failedPinAttempts: $failedPinAttempts, ')
          ..write('pinLockedUntil: $pinLockedUntil, ')
          ..write('pinChangedAt: $pinChangedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    displayName,
    role,
    isActive,
    pinVerifier,
    recoveryCodeVerifier,
    failedPinAttempts,
    pinLockedUntil,
    pinChangedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffAccount &&
          other.id == this.id &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.pinVerifier == this.pinVerifier &&
          other.recoveryCodeVerifier == this.recoveryCodeVerifier &&
          other.failedPinAttempts == this.failedPinAttempts &&
          other.pinLockedUntil == this.pinLockedUntil &&
          other.pinChangedAt == this.pinChangedAt &&
          other.createdAt == this.createdAt);
}

class StaffAccountsCompanion extends UpdateCompanion<StaffAccount> {
  final Value<String> id;
  final Value<String> username;
  final Value<String> displayName;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<String> pinVerifier;
  final Value<String?> recoveryCodeVerifier;
  final Value<int> failedPinAttempts;
  final Value<DateTime?> pinLockedUntil;
  final Value<DateTime> pinChangedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StaffAccountsCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.pinVerifier = const Value.absent(),
    this.recoveryCodeVerifier = const Value.absent(),
    this.failedPinAttempts = const Value.absent(),
    this.pinLockedUntil = const Value.absent(),
    this.pinChangedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaffAccountsCompanion.insert({
    required String id,
    required String username,
    this.displayName = const Value.absent(),
    required String role,
    this.isActive = const Value.absent(),
    required String pinVerifier,
    this.recoveryCodeVerifier = const Value.absent(),
    this.failedPinAttempts = const Value.absent(),
    this.pinLockedUntil = const Value.absent(),
    required DateTime pinChangedAt,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       username = Value(username),
       role = Value(role),
       pinVerifier = Value(pinVerifier),
       pinChangedAt = Value(pinChangedAt),
       createdAt = Value(createdAt);
  static Insertable<StaffAccount> custom({
    Expression<String>? id,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<String>? pinVerifier,
    Expression<String>? recoveryCodeVerifier,
    Expression<int>? failedPinAttempts,
    Expression<DateTime>? pinLockedUntil,
    Expression<DateTime>? pinChangedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (pinVerifier != null) 'pin_verifier': pinVerifier,
      if (recoveryCodeVerifier != null)
        'recovery_code_verifier': recoveryCodeVerifier,
      if (failedPinAttempts != null) 'failed_pin_attempts': failedPinAttempts,
      if (pinLockedUntil != null) 'pin_locked_until': pinLockedUntil,
      if (pinChangedAt != null) 'pin_changed_at': pinChangedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaffAccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? username,
    Value<String>? displayName,
    Value<String>? role,
    Value<bool>? isActive,
    Value<String>? pinVerifier,
    Value<String?>? recoveryCodeVerifier,
    Value<int>? failedPinAttempts,
    Value<DateTime?>? pinLockedUntil,
    Value<DateTime>? pinChangedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StaffAccountsCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      pinVerifier: pinVerifier ?? this.pinVerifier,
      recoveryCodeVerifier: recoveryCodeVerifier ?? this.recoveryCodeVerifier,
      failedPinAttempts: failedPinAttempts ?? this.failedPinAttempts,
      pinLockedUntil: pinLockedUntil ?? this.pinLockedUntil,
      pinChangedAt: pinChangedAt ?? this.pinChangedAt,
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
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (pinVerifier.present) {
      map['pin_verifier'] = Variable<String>(pinVerifier.value);
    }
    if (recoveryCodeVerifier.present) {
      map['recovery_code_verifier'] = Variable<String>(
        recoveryCodeVerifier.value,
      );
    }
    if (failedPinAttempts.present) {
      map['failed_pin_attempts'] = Variable<int>(failedPinAttempts.value);
    }
    if (pinLockedUntil.present) {
      map['pin_locked_until'] = Variable<DateTime>(pinLockedUntil.value);
    }
    if (pinChangedAt.present) {
      map['pin_changed_at'] = Variable<DateTime>(pinChangedAt.value);
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
    return (StringBuffer('StaffAccountsCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('pinVerifier: $pinVerifier, ')
          ..write('recoveryCodeVerifier: $recoveryCodeVerifier, ')
          ..write('failedPinAttempts: $failedPinAttempts, ')
          ..write('pinLockedUntil: $pinLockedUntil, ')
          ..write('pinChangedAt: $pinChangedAt, ')
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
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $PurchaseOrdersTable purchaseOrders = $PurchaseOrdersTable(this);
  late final $PurchaseOrderItemsTable purchaseOrderItems =
      $PurchaseOrderItemsTable(this);
  late final $CustomerCreditAccountsTable customerCreditAccounts =
      $CustomerCreditAccountsTable(this);
  late final $CustomerCreditTransactionsTable customerCreditTransactions =
      $CustomerCreditTransactionsTable(this);
  late final $StaffAccountsTable staffAccounts = $StaffAccountsTable(this);
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
    suppliers,
    purchaseOrders,
    purchaseOrderItems,
    customerCreditAccounts,
    customerCreditTransactions,
    staffAccounts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('customer_credit_accounts', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'customer_credit_accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('customer_credit_transactions', kind: UpdateKind.delete),
      ],
    ),
  ]);
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
  Value<String?> staffId,
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
  Value<String?> staffId,
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

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
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

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
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

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);
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
                Value<String?> staffId = const Value.absent(),
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
                staffId: staffId,
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
                Value<String?> staffId = const Value.absent(),
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
                staffId: staffId,
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

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, Customer> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $CustomerCreditAccountsTable,
    List<CustomerCreditAccount>
  >
  _customerCreditAccountsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customerCreditAccounts,
        aliasName: 'customers__id__customer_credit_accounts__customer_id',
      );

  $$CustomerCreditAccountsTableProcessedTableManager
  get customerCreditAccountsRefs {
    final manager = $$CustomerCreditAccountsTableTableManager(
      $_db,
      $_db.customerCreditAccounts,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customerCreditAccountsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  Expression<bool> customerCreditAccountsRefs(
    Expression<bool> Function($$CustomerCreditAccountsTableFilterComposer f) f,
  ) {
    final $$CustomerCreditAccountsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customerCreditAccounts,
          getReferencedColumn: (t) => t.customerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerCreditAccountsTableFilterComposer(
                $db: $db,
                $table: $db.customerCreditAccounts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
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

  Expression<T> customerCreditAccountsRefs<T extends Object>(
    Expression<T> Function($$CustomerCreditAccountsTableAnnotationComposer a) f,
  ) {
    final $$CustomerCreditAccountsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customerCreditAccounts,
          getReferencedColumn: (t) => t.customerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerCreditAccountsTableAnnotationComposer(
                $db: $db,
                $table: $db.customerCreditAccounts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
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
          (Customer, $$CustomersTableReferences),
          Customer,
          PrefetchHooks Function({bool customerCreditAccountsRefs})
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
                  $$CustomersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customerCreditAccountsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (customerCreditAccountsRefs) db.customerCreditAccounts,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (customerCreditAccountsRefs)
                    await $_getPrefetchedData<
                      Customer,
                      $CustomersTable,
                      CustomerCreditAccount
                    >(
                      currentTable: table,
                      referencedTable: $$CustomersTableReferences
                          ._customerCreditAccountsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomersTableReferences(
                            db,
                            table,
                            p0,
                          ).customerCreditAccountsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.customerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
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
      (Customer, $$CustomersTableReferences),
      Customer,
      PrefetchHooks Function({bool customerCreditAccountsRefs})
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
      Value<String?> staffId,
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
      Value<String?> staffId,
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

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
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

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
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

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);
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
                Value<String?> staffId = const Value.absent(),
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
                staffId: staffId,
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
                Value<String?> staffId = const Value.absent(),
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
                staffId: staffId,
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
      Value<bool> loginRequired,
      Value<int> inactivityTimeoutMinutes,
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
      Value<bool> loginRequired,
      Value<int> inactivityTimeoutMinutes,
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

  ColumnFilters<bool> get loginRequired => $composableBuilder(
    column: $table.loginRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inactivityTimeoutMinutes => $composableBuilder(
    column: $table.inactivityTimeoutMinutes,
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

  ColumnOrderings<bool> get loginRequired => $composableBuilder(
    column: $table.loginRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inactivityTimeoutMinutes => $composableBuilder(
    column: $table.inactivityTimeoutMinutes,
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

  GeneratedColumn<bool> get loginRequired => $composableBuilder(
    column: $table.loginRequired,
    builder: (column) => column,
  );

  GeneratedColumn<int> get inactivityTimeoutMinutes => $composableBuilder(
    column: $table.inactivityTimeoutMinutes,
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
                Value<bool> loginRequired = const Value.absent(),
                Value<int> inactivityTimeoutMinutes = const Value.absent(),
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
                loginRequired: loginRequired,
                inactivityTimeoutMinutes: inactivityTimeoutMinutes,
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
                Value<bool> loginRequired = const Value.absent(),
                Value<int> inactivityTimeoutMinutes = const Value.absent(),
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
                loginRequired: loginRequired,
                inactivityTimeoutMinutes: inactivityTimeoutMinutes,
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
      Value<String?> staffId,
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
      Value<String?> staffId,
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

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
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

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
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

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);
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
                Value<String?> staffId = const Value.absent(),
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
                staffId: staffId,
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
                Value<String?> staffId = const Value.absent(),
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
                staffId: staffId,
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
  Value<String?> openedById,
  Value<String?> closedById,
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
  Value<String?> openedById,
  Value<String?> closedById,
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

  ColumnFilters<String> get openedById => $composableBuilder(
    column: $table.openedById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedById => $composableBuilder(
    column: $table.closedById,
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

  ColumnOrderings<String> get openedById => $composableBuilder(
    column: $table.openedById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedById => $composableBuilder(
    column: $table.closedById,
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

  GeneratedColumn<String> get openedById => $composableBuilder(
    column: $table.openedById,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closedById => $composableBuilder(
    column: $table.closedById,
    builder: (column) => column,
  );
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
                Value<String?> openedById = const Value.absent(),
                Value<String?> closedById = const Value.absent(),
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
                openedById: openedById,
                closedById: closedById,
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
                Value<String?> openedById = const Value.absent(),
                Value<String?> closedById = const Value.absent(),
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
                openedById: openedById,
                closedById: closedById,
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
      Value<String?> staffId,
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
      Value<String?> staffId,
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

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
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

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
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

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);
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
                Value<String?> staffId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashMovementsCompanion(
                id: id,
                shiftId: shiftId,
                direction: direction,
                amount: amount,
                note: note,
                createdAt: createdAt,
                staffId: staffId,
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
                Value<String?> staffId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashMovementsCompanion.insert(
                id: id,
                shiftId: shiftId,
                direction: direction,
                amount: amount,
                note: note,
                createdAt: createdAt,
                staffId: staffId,
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
typedef $$SuppliersTableCreateCompanionBuilder = SuppliersCompanion Function({
  required String id,
  required String name,
  Value<String> contactPerson,
  Value<String> phone,
  Value<String> email,
  Value<String> address,
  Value<String> taxNumber,
  Value<int> paymentTermsDays,
  Value<String> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SuppliersTableUpdateCompanionBuilder = SuppliersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> contactPerson,
  Value<String> phone,
  Value<String> email,
  Value<String> address,
  Value<String> taxNumber,
  Value<int> paymentTermsDays,
  Value<String> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
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

  ColumnFilters<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
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

  ColumnFilters<String> get taxNumber => $composableBuilder(
    column: $table.taxNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentTermsDays => $composableBuilder(
    column: $table.paymentTermsDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
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

  ColumnOrderings<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
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

  ColumnOrderings<String> get taxNumber => $composableBuilder(
    column: $table.taxNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentTermsDays => $composableBuilder(
    column: $table.paymentTermsDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
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

  GeneratedColumn<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get taxNumber =>
      $composableBuilder(column: $table.taxNumber, builder: (column) => column);

  GeneratedColumn<int> get paymentTermsDays => $composableBuilder(
    column: $table.paymentTermsDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SuppliersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppliersTable,
          Supplier,
          $$SuppliersTableFilterComposer,
          $$SuppliersTableOrderingComposer,
          $$SuppliersTableAnnotationComposer,
          $$SuppliersTableCreateCompanionBuilder,
          $$SuppliersTableUpdateCompanionBuilder,
          (Supplier, BaseReferences<_$AppDatabase, $SuppliersTable, Supplier>),
          Supplier,
          PrefetchHooks Function()
        > {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> contactPerson = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> taxNumber = const Value.absent(),
                Value<int> paymentTermsDays = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion(
                id: id,
                name: name,
                contactPerson: contactPerson,
                phone: phone,
                email: email,
                address: address,
                taxNumber: taxNumber,
                paymentTermsDays: paymentTermsDays,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> contactPerson = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> taxNumber = const Value.absent(),
                Value<int> paymentTermsDays = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion.insert(
                id: id,
                name: name,
                contactPerson: contactPerson,
                phone: phone,
                email: email,
                address: address,
                taxNumber: taxNumber,
                paymentTermsDays: paymentTermsDays,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SuppliersTable, Supplier>(table),
                  BaseReferences<_$AppDatabase, $SuppliersTable, Supplier>(
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

typedef $$SuppliersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppliersTable,
      Supplier,
      $$SuppliersTableFilterComposer,
      $$SuppliersTableOrderingComposer,
      $$SuppliersTableAnnotationComposer,
      $$SuppliersTableCreateCompanionBuilder,
      $$SuppliersTableUpdateCompanionBuilder,
      (Supplier, BaseReferences<_$AppDatabase, $SuppliersTable, Supplier>),
      Supplier,
      PrefetchHooks Function()
    >;
typedef $$PurchaseOrdersTableCreateCompanionBuilder =
    PurchaseOrdersCompanion Function({
      required String id,
      required String supplierId,
      Value<String> supplierReference,
      Value<String> status,
      Value<double> subtotal,
      Value<double> taxAmount,
      Value<double> total,
      Value<String> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> expectedDate,
      Value<DateTime?> receivedAt,
      Value<String?> staffId,
      Value<int> rowid,
    });
typedef $$PurchaseOrdersTableUpdateCompanionBuilder =
    PurchaseOrdersCompanion Function({
      Value<String> id,
      Value<String> supplierId,
      Value<String> supplierReference,
      Value<String> status,
      Value<double> subtotal,
      Value<double> taxAmount,
      Value<double> total,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> expectedDate,
      Value<DateTime?> receivedAt,
      Value<String?> staffId,
      Value<int> rowid,
    });

class $$PurchaseOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseOrdersTable> {
  $$PurchaseOrdersTableFilterComposer({
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

  ColumnFilters<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierReference => $composableBuilder(
    column: $table.supplierReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expectedDate => $composableBuilder(
    column: $table.expectedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PurchaseOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseOrdersTable> {
  $$PurchaseOrdersTableOrderingComposer({
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

  ColumnOrderings<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierReference => $composableBuilder(
    column: $table.supplierReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expectedDate => $composableBuilder(
    column: $table.expectedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PurchaseOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseOrdersTable> {
  $$PurchaseOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplierReference => $composableBuilder(
    column: $table.supplierReference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expectedDate => $composableBuilder(
    column: $table.expectedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);
}

class $$PurchaseOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseOrdersTable,
          PurchaseOrder,
          $$PurchaseOrdersTableFilterComposer,
          $$PurchaseOrdersTableOrderingComposer,
          $$PurchaseOrdersTableAnnotationComposer,
          $$PurchaseOrdersTableCreateCompanionBuilder,
          $$PurchaseOrdersTableUpdateCompanionBuilder,
          (
            PurchaseOrder,
            BaseReferences<_$AppDatabase, $PurchaseOrdersTable, PurchaseOrder>,
          ),
          PurchaseOrder,
          PrefetchHooks Function()
        > {
  $$PurchaseOrdersTableTableManager(
    _$AppDatabase db,
    $PurchaseOrdersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<String> supplierReference = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> expectedDate = const Value.absent(),
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<String?> staffId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrdersCompanion(
                id: id,
                supplierId: supplierId,
                supplierReference: supplierReference,
                status: status,
                subtotal: subtotal,
                taxAmount: taxAmount,
                total: total,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                expectedDate: expectedDate,
                receivedAt: receivedAt,
                staffId: staffId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String supplierId,
                Value<String> supplierReference = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> expectedDate = const Value.absent(),
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<String?> staffId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrdersCompanion.insert(
                id: id,
                supplierId: supplierId,
                supplierReference: supplierReference,
                status: status,
                subtotal: subtotal,
                taxAmount: taxAmount,
                total: total,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                expectedDate: expectedDate,
                receivedAt: receivedAt,
                staffId: staffId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchaseOrdersTable, PurchaseOrder>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PurchaseOrdersTable,
                    PurchaseOrder
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PurchaseOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseOrdersTable,
      PurchaseOrder,
      $$PurchaseOrdersTableFilterComposer,
      $$PurchaseOrdersTableOrderingComposer,
      $$PurchaseOrdersTableAnnotationComposer,
      $$PurchaseOrdersTableCreateCompanionBuilder,
      $$PurchaseOrdersTableUpdateCompanionBuilder,
      (
        PurchaseOrder,
        BaseReferences<_$AppDatabase, $PurchaseOrdersTable, PurchaseOrder>,
      ),
      PurchaseOrder,
      PrefetchHooks Function()
    >;
typedef $$PurchaseOrderItemsTableCreateCompanionBuilder =
    PurchaseOrderItemsCompanion Function({
      required String id,
      required String purchaseOrderId,
      required String productId,
      required String productName,
      Value<String> productSku,
      required int quantityOrdered,
      Value<int> quantityReceived,
      required double unitCost,
      required double total,
      Value<String> notes,
      Value<int> rowid,
    });
typedef $$PurchaseOrderItemsTableUpdateCompanionBuilder =
    PurchaseOrderItemsCompanion Function({
      Value<String> id,
      Value<String> purchaseOrderId,
      Value<String> productId,
      Value<String> productName,
      Value<String> productSku,
      Value<int> quantityOrdered,
      Value<int> quantityReceived,
      Value<double> unitCost,
      Value<double> total,
      Value<String> notes,
      Value<int> rowid,
    });

class $$PurchaseOrderItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseOrderItemsTable> {
  $$PurchaseOrderItemsTableFilterComposer({
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

  ColumnFilters<String> get purchaseOrderId => $composableBuilder(
    column: $table.purchaseOrderId,
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

  ColumnFilters<String> get productSku => $composableBuilder(
    column: $table.productSku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityOrdered => $composableBuilder(
    column: $table.quantityOrdered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityReceived => $composableBuilder(
    column: $table.quantityReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PurchaseOrderItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseOrderItemsTable> {
  $$PurchaseOrderItemsTableOrderingComposer({
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

  ColumnOrderings<String> get purchaseOrderId => $composableBuilder(
    column: $table.purchaseOrderId,
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

  ColumnOrderings<String> get productSku => $composableBuilder(
    column: $table.productSku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityOrdered => $composableBuilder(
    column: $table.quantityOrdered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityReceived => $composableBuilder(
    column: $table.quantityReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PurchaseOrderItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseOrderItemsTable> {
  $$PurchaseOrderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get purchaseOrderId => $composableBuilder(
    column: $table.purchaseOrderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productSku => $composableBuilder(
    column: $table.productSku,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityOrdered => $composableBuilder(
    column: $table.quantityOrdered,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityReceived => $composableBuilder(
    column: $table.quantityReceived,
    builder: (column) => column,
  );

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$PurchaseOrderItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseOrderItemsTable,
          PurchaseOrderItem,
          $$PurchaseOrderItemsTableFilterComposer,
          $$PurchaseOrderItemsTableOrderingComposer,
          $$PurchaseOrderItemsTableAnnotationComposer,
          $$PurchaseOrderItemsTableCreateCompanionBuilder,
          $$PurchaseOrderItemsTableUpdateCompanionBuilder,
          (
            PurchaseOrderItem,
            BaseReferences<
              _$AppDatabase,
              $PurchaseOrderItemsTable,
              PurchaseOrderItem
            >,
          ),
          PurchaseOrderItem,
          PrefetchHooks Function()
        > {
  $$PurchaseOrderItemsTableTableManager(
    _$AppDatabase db,
    $PurchaseOrderItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseOrderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseOrderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseOrderItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> purchaseOrderId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String> productSku = const Value.absent(),
                Value<int> quantityOrdered = const Value.absent(),
                Value<int> quantityReceived = const Value.absent(),
                Value<double> unitCost = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrderItemsCompanion(
                id: id,
                purchaseOrderId: purchaseOrderId,
                productId: productId,
                productName: productName,
                productSku: productSku,
                quantityOrdered: quantityOrdered,
                quantityReceived: quantityReceived,
                unitCost: unitCost,
                total: total,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String purchaseOrderId,
                required String productId,
                required String productName,
                Value<String> productSku = const Value.absent(),
                required int quantityOrdered,
                Value<int> quantityReceived = const Value.absent(),
                required double unitCost,
                required double total,
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrderItemsCompanion.insert(
                id: id,
                purchaseOrderId: purchaseOrderId,
                productId: productId,
                productName: productName,
                productSku: productSku,
                quantityOrdered: quantityOrdered,
                quantityReceived: quantityReceived,
                unitCost: unitCost,
                total: total,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchaseOrderItemsTable, PurchaseOrderItem>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $PurchaseOrderItemsTable,
                    PurchaseOrderItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PurchaseOrderItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseOrderItemsTable,
      PurchaseOrderItem,
      $$PurchaseOrderItemsTableFilterComposer,
      $$PurchaseOrderItemsTableOrderingComposer,
      $$PurchaseOrderItemsTableAnnotationComposer,
      $$PurchaseOrderItemsTableCreateCompanionBuilder,
      $$PurchaseOrderItemsTableUpdateCompanionBuilder,
      (
        PurchaseOrderItem,
        BaseReferences<
          _$AppDatabase,
          $PurchaseOrderItemsTable,
          PurchaseOrderItem
        >,
      ),
      PurchaseOrderItem,
      PrefetchHooks Function()
    >;
typedef $$CustomerCreditAccountsTableCreateCompanionBuilder =
    CustomerCreditAccountsCompanion Function({
      Value<int> id,
      required String customerId,
      Value<double> creditLimit,
      Value<double> currentBalance,
      Value<String> paymentTerms,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$CustomerCreditAccountsTableUpdateCompanionBuilder =
    CustomerCreditAccountsCompanion Function({
      Value<int> id,
      Value<String> customerId,
      Value<double> creditLimit,
      Value<double> currentBalance,
      Value<String> paymentTerms,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$CustomerCreditAccountsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CustomerCreditAccountsTable,
          CustomerCreditAccount
        > {
  $$CustomerCreditAccountsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomersTable _customerIdTable(_$AppDatabase db) => db.customers
      .createAlias('customer_credit_accounts__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $CustomerCreditTransactionsTable,
    List<CustomerCreditTransaction>
  >
  _customerCreditTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customerCreditTransactions,
        aliasName: 'customer_credit_accounts__id__customer_credit_transactions__account_id',
      );

  $$CustomerCreditTransactionsTableProcessedTableManager
  get customerCreditTransactionsRefs {
    final manager = $$CustomerCreditTransactionsTableTableManager(
      $_db,
      $_db.customerCreditTransactions,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customerCreditTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomerCreditAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerCreditAccountsTable> {
  $$CustomerCreditAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentTerms => $composableBuilder(
    column: $table.paymentTerms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> customerCreditTransactionsRefs(
    Expression<bool> Function($$CustomerCreditTransactionsTableFilterComposer f)
    f,
  ) {
    final $$CustomerCreditTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customerCreditTransactions,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerCreditTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.customerCreditTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CustomerCreditAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerCreditAccountsTable> {
  $$CustomerCreditAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentTerms => $composableBuilder(
    column: $table.paymentTerms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerCreditAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerCreditAccountsTable> {
  $$CustomerCreditAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentTerms => $composableBuilder(
    column: $table.paymentTerms,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> customerCreditTransactionsRefs<T extends Object>(
    Expression<T> Function(
      $$CustomerCreditTransactionsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$CustomerCreditTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customerCreditTransactions,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerCreditTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.customerCreditTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CustomerCreditAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerCreditAccountsTable,
          CustomerCreditAccount,
          $$CustomerCreditAccountsTableFilterComposer,
          $$CustomerCreditAccountsTableOrderingComposer,
          $$CustomerCreditAccountsTableAnnotationComposer,
          $$CustomerCreditAccountsTableCreateCompanionBuilder,
          $$CustomerCreditAccountsTableUpdateCompanionBuilder,
          (CustomerCreditAccount, $$CustomerCreditAccountsTableReferences),
          CustomerCreditAccount,
          PrefetchHooks Function({
            bool customerId,
            bool customerCreditTransactionsRefs,
          })
        > {
  $$CustomerCreditAccountsTableTableManager(
    _$AppDatabase db,
    $CustomerCreditAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerCreditAccountsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CustomerCreditAccountsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomerCreditAccountsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<double> creditLimit = const Value.absent(),
                Value<double> currentBalance = const Value.absent(),
                Value<String> paymentTerms = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CustomerCreditAccountsCompanion(
                id: id,
                customerId: customerId,
                creditLimit: creditLimit,
                currentBalance: currentBalance,
                paymentTerms: paymentTerms,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String customerId,
                Value<double> creditLimit = const Value.absent(),
                Value<double> currentBalance = const Value.absent(),
                Value<String> paymentTerms = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CustomerCreditAccountsCompanion.insert(
                id: id,
                customerId: customerId,
                creditLimit: creditLimit,
                currentBalance: currentBalance,
                paymentTerms: paymentTerms,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CustomerCreditAccountsTable,
                    CustomerCreditAccount
                  >(table),
                  $$CustomerCreditAccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({customerId = false, customerCreditTransactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (customerCreditTransactionsRefs)
                      db.customerCreditTransactions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (customerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.customerId,
                            referencedTable:
                                $$CustomerCreditAccountsTableReferences
                                    ._customerIdTable(db),
                            referencedColumn:
                                $$CustomerCreditAccountsTableReferences
                                    ._customerIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (customerCreditTransactionsRefs)
                        await $_getPrefetchedData<
                          CustomerCreditAccount,
                          $CustomerCreditAccountsTable,
                          CustomerCreditTransaction
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CustomerCreditAccountsTableReferences
                                  ._customerCreditTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomerCreditAccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).customerCreditTransactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CustomerCreditAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerCreditAccountsTable,
      CustomerCreditAccount,
      $$CustomerCreditAccountsTableFilterComposer,
      $$CustomerCreditAccountsTableOrderingComposer,
      $$CustomerCreditAccountsTableAnnotationComposer,
      $$CustomerCreditAccountsTableCreateCompanionBuilder,
      $$CustomerCreditAccountsTableUpdateCompanionBuilder,
      (CustomerCreditAccount, $$CustomerCreditAccountsTableReferences),
      CustomerCreditAccount,
      PrefetchHooks Function({
        bool customerId,
        bool customerCreditTransactionsRefs,
      })
    >;
typedef $$CustomerCreditTransactionsTableCreateCompanionBuilder =
    CustomerCreditTransactionsCompanion Function({
      Value<int> id,
      required int accountId,
      required String type,
      Value<String?> reference,
      required double amount,
      required double balanceAfter,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<int?> createdBy,
    });
typedef $$CustomerCreditTransactionsTableUpdateCompanionBuilder =
    CustomerCreditTransactionsCompanion Function({
      Value<int> id,
      Value<int> accountId,
      Value<String> type,
      Value<String?> reference,
      Value<double> amount,
      Value<double> balanceAfter,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<int?> createdBy,
    });

final class $$CustomerCreditTransactionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CustomerCreditTransactionsTable,
          CustomerCreditTransaction
        > {
  $$CustomerCreditTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomerCreditAccountsTable _accountIdTable(
    _$AppDatabase db,
  ) => db.customerCreditAccounts.createAlias(
    'customer_credit_transactions__account_id__customer_credit_accounts__id',
  );

  $$CustomerCreditAccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$CustomerCreditAccountsTableTableManager(
      $_db,
      $_db.customerCreditAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomerCreditTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerCreditTransactionsTable> {
  $$CustomerCreditTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomerCreditAccountsTableFilterComposer get accountId {
    final $$CustomerCreditAccountsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.accountId,
          referencedTable: $db.customerCreditAccounts,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerCreditAccountsTableFilterComposer(
                $db: $db,
                $table: $db.customerCreditAccounts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CustomerCreditTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerCreditTransactionsTable> {
  $$CustomerCreditTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomerCreditAccountsTableOrderingComposer get accountId {
    final $$CustomerCreditAccountsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.accountId,
          referencedTable: $db.customerCreditAccounts,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerCreditAccountsTableOrderingComposer(
                $db: $db,
                $table: $db.customerCreditAccounts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CustomerCreditTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerCreditTransactionsTable> {
  $$CustomerCreditTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  $$CustomerCreditAccountsTableAnnotationComposer get accountId {
    final $$CustomerCreditAccountsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.accountId,
          referencedTable: $db.customerCreditAccounts,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerCreditAccountsTableAnnotationComposer(
                $db: $db,
                $table: $db.customerCreditAccounts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CustomerCreditTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerCreditTransactionsTable,
          CustomerCreditTransaction,
          $$CustomerCreditTransactionsTableFilterComposer,
          $$CustomerCreditTransactionsTableOrderingComposer,
          $$CustomerCreditTransactionsTableAnnotationComposer,
          $$CustomerCreditTransactionsTableCreateCompanionBuilder,
          $$CustomerCreditTransactionsTableUpdateCompanionBuilder,
          (
            CustomerCreditTransaction,
            $$CustomerCreditTransactionsTableReferences,
          ),
          CustomerCreditTransaction,
          PrefetchHooks Function({bool accountId})
        > {
  $$CustomerCreditTransactionsTableTableManager(
    _$AppDatabase db,
    $CustomerCreditTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerCreditTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CustomerCreditTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomerCreditTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> balanceAfter = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> createdBy = const Value.absent(),
              }) => CustomerCreditTransactionsCompanion(
                id: id,
                accountId: accountId,
                type: type,
                reference: reference,
                amount: amount,
                balanceAfter: balanceAfter,
                description: description,
                createdAt: createdAt,
                createdBy: createdBy,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int accountId,
                required String type,
                Value<String?> reference = const Value.absent(),
                required double amount,
                required double balanceAfter,
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> createdBy = const Value.absent(),
              }) => CustomerCreditTransactionsCompanion.insert(
                id: id,
                accountId: accountId,
                type: type,
                reference: reference,
                amount: amount,
                balanceAfter: balanceAfter,
                description: description,
                createdAt: createdAt,
                createdBy: createdBy,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CustomerCreditTransactionsTable,
                    CustomerCreditTransaction
                  >(table),
                  $$CustomerCreditTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable:
                            $$CustomerCreditTransactionsTableReferences
                                ._accountIdTable(db),
                        referencedColumn:
                            $$CustomerCreditTransactionsTableReferences
                                ._accountIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CustomerCreditTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerCreditTransactionsTable,
      CustomerCreditTransaction,
      $$CustomerCreditTransactionsTableFilterComposer,
      $$CustomerCreditTransactionsTableOrderingComposer,
      $$CustomerCreditTransactionsTableAnnotationComposer,
      $$CustomerCreditTransactionsTableCreateCompanionBuilder,
      $$CustomerCreditTransactionsTableUpdateCompanionBuilder,
      (CustomerCreditTransaction, $$CustomerCreditTransactionsTableReferences),
      CustomerCreditTransaction,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$StaffAccountsTableCreateCompanionBuilder =
    StaffAccountsCompanion Function({
      required String id,
      required String username,
      Value<String> displayName,
      required String role,
      Value<bool> isActive,
      required String pinVerifier,
      Value<String?> recoveryCodeVerifier,
      Value<int> failedPinAttempts,
      Value<DateTime?> pinLockedUntil,
      required DateTime pinChangedAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StaffAccountsTableUpdateCompanionBuilder =
    StaffAccountsCompanion Function({
      Value<String> id,
      Value<String> username,
      Value<String> displayName,
      Value<String> role,
      Value<bool> isActive,
      Value<String> pinVerifier,
      Value<String?> recoveryCodeVerifier,
      Value<int> failedPinAttempts,
      Value<DateTime?> pinLockedUntil,
      Value<DateTime> pinChangedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$StaffAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $StaffAccountsTable> {
  $$StaffAccountsTableFilterComposer({
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

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinVerifier => $composableBuilder(
    column: $table.pinVerifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recoveryCodeVerifier => $composableBuilder(
    column: $table.recoveryCodeVerifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedPinAttempts => $composableBuilder(
    column: $table.failedPinAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pinLockedUntil => $composableBuilder(
    column: $table.pinLockedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pinChangedAt => $composableBuilder(
    column: $table.pinChangedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StaffAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffAccountsTable> {
  $$StaffAccountsTableOrderingComposer({
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

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinVerifier => $composableBuilder(
    column: $table.pinVerifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recoveryCodeVerifier => $composableBuilder(
    column: $table.recoveryCodeVerifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedPinAttempts => $composableBuilder(
    column: $table.failedPinAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pinLockedUntil => $composableBuilder(
    column: $table.pinLockedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pinChangedAt => $composableBuilder(
    column: $table.pinChangedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StaffAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffAccountsTable> {
  $$StaffAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get pinVerifier => $composableBuilder(
    column: $table.pinVerifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recoveryCodeVerifier => $composableBuilder(
    column: $table.recoveryCodeVerifier,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failedPinAttempts => $composableBuilder(
    column: $table.failedPinAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pinLockedUntil => $composableBuilder(
    column: $table.pinLockedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pinChangedAt => $composableBuilder(
    column: $table.pinChangedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StaffAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StaffAccountsTable,
          StaffAccount,
          $$StaffAccountsTableFilterComposer,
          $$StaffAccountsTableOrderingComposer,
          $$StaffAccountsTableAnnotationComposer,
          $$StaffAccountsTableCreateCompanionBuilder,
          $$StaffAccountsTableUpdateCompanionBuilder,
          (
            StaffAccount,
            BaseReferences<_$AppDatabase, $StaffAccountsTable, StaffAccount>,
          ),
          StaffAccount,
          PrefetchHooks Function()
        > {
  $$StaffAccountsTableTableManager(_$AppDatabase db, $StaffAccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> pinVerifier = const Value.absent(),
                Value<String?> recoveryCodeVerifier = const Value.absent(),
                Value<int> failedPinAttempts = const Value.absent(),
                Value<DateTime?> pinLockedUntil = const Value.absent(),
                Value<DateTime> pinChangedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StaffAccountsCompanion(
                id: id,
                username: username,
                displayName: displayName,
                role: role,
                isActive: isActive,
                pinVerifier: pinVerifier,
                recoveryCodeVerifier: recoveryCodeVerifier,
                failedPinAttempts: failedPinAttempts,
                pinLockedUntil: pinLockedUntil,
                pinChangedAt: pinChangedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String username,
                Value<String> displayName = const Value.absent(),
                required String role,
                Value<bool> isActive = const Value.absent(),
                required String pinVerifier,
                Value<String?> recoveryCodeVerifier = const Value.absent(),
                Value<int> failedPinAttempts = const Value.absent(),
                Value<DateTime?> pinLockedUntil = const Value.absent(),
                required DateTime pinChangedAt,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StaffAccountsCompanion.insert(
                id: id,
                username: username,
                displayName: displayName,
                role: role,
                isActive: isActive,
                pinVerifier: pinVerifier,
                recoveryCodeVerifier: recoveryCodeVerifier,
                failedPinAttempts: failedPinAttempts,
                pinLockedUntil: pinLockedUntil,
                pinChangedAt: pinChangedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StaffAccountsTable, StaffAccount>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $StaffAccountsTable,
                    StaffAccount
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StaffAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StaffAccountsTable,
      StaffAccount,
      $$StaffAccountsTableFilterComposer,
      $$StaffAccountsTableOrderingComposer,
      $$StaffAccountsTableAnnotationComposer,
      $$StaffAccountsTableCreateCompanionBuilder,
      $$StaffAccountsTableUpdateCompanionBuilder,
      (
        StaffAccount,
        BaseReferences<_$AppDatabase, $StaffAccountsTable, StaffAccount>,
      ),
      StaffAccount,
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
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$PurchaseOrdersTableTableManager get purchaseOrders =>
      $$PurchaseOrdersTableTableManager(_db, _db.purchaseOrders);
  $$PurchaseOrderItemsTableTableManager get purchaseOrderItems =>
      $$PurchaseOrderItemsTableTableManager(_db, _db.purchaseOrderItems);
  $$CustomerCreditAccountsTableTableManager get customerCreditAccounts =>
      $$CustomerCreditAccountsTableTableManager(
        _db,
        _db.customerCreditAccounts,
      );
  $$CustomerCreditTransactionsTableTableManager
  get customerCreditTransactions =>
      $$CustomerCreditTransactionsTableTableManager(
        _db,
        _db.customerCreditTransactions,
      );
  $$StaffAccountsTableTableManager get staffAccounts =>
      $$StaffAccountsTableTableManager(_db, _db.staffAccounts);
}
