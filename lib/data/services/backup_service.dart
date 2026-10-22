import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:file_saver/file_saver.dart';

import '../../core/session/session_authorization.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../repositories/audit_repository.dart';

class BackupService {
  final AppDatabase _database;
  final AuditRepository _audit;

  BackupService([AppDatabase? database, AuditRepository? audit])
    : _database = database ?? appDatabase,
      _audit = audit ?? AuditRepository(database ?? appDatabase);

  /// Keep in sync with `AppDatabase.schemaVersion`.
  ///
  /// Bumped to 15 in Phase F: the payload now carries the inactivity
  /// timeout setting (`businessSettings.inactivityTimeoutMinutes`).
  static const int _currentSchemaVersion = 15;

  /// The oldest schema version this build can still restore from.
  static const int _oldestSupportedSchemaVersion = 4;

  /// Resolves the acting staff and enforces owner-only authorization for
  /// backup export, restore, and database reset (all expose or destroy the
  /// entire business dataset, including sensitive financial records).
  ///
  /// In login-disabled mode this is a no-op, preserving Phase D behavior.
  Future<StaffAccountSummary?> _authorizeOwner(String operation) async {
    return requireOwner(_database, operation);
  }

  Future<String> createBackupJson() async {
    await _authorizeOwner('backup export');

    final products = await _database.select(_database.products).get();
    final categories = await _database.select(_database.categories).get();
    final sales = await _database.select(_database.sales).get();
    final saleItems = await _database.select(_database.saleItems).get();
    final customers = await _database.select(_database.customers).get();
    final expenses = await _database.select(_database.expenses).get();
    final stockMovements = await _database
        .select(_database.stockMovements)
        .get();
    final businessSettings = await _database
        .select(_database.businessSettings)
        .get();

    final backup = <String, dynamic>{
      'backupFormatVersion': 1,
      'application': 'BizFlow',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'databaseSchemaVersion': _currentSchemaVersion,
      'data': {
        'products': products.map((product) {
          return {
            'id': product.id,
            'name': product.name,
            'sku': product.sku,
            'category': product.category,
            'purchasePrice': product.purchasePrice,
            'sellingPrice': product.sellingPrice,
            'stockQuantity': product.stockQuantity,
            'lowStockThreshold': product.lowStockThreshold,
            'barcode': product.barcode,
          };
        }).toList(),
        'categories': categories.map((category) {
          return {'id': category.id, 'name': category.name};
        }).toList(),
        'sales': sales.map((sale) {
          return {
            'id': sale.id,
            'customerId': sale.customerId,
            'subtotal': sale.subtotal,
            'discount': sale.discount,
            'total': sale.total,
            'paidAmount': sale.paidAmount,
            'paymentMethod': sale.paymentMethod,
            'status': sale.status,
            'staffId': sale.staffId,
            'createdAt': sale.createdAt.toUtc().toIso8601String(),
          };
        }).toList(),
        'saleItems': saleItems.map((item) {
          return {
            'id': item.id,
            'saleId': item.saleId,
            'productId': item.productId,
            'productName': item.productName,
            'quantity': item.quantity,
            'unitPrice': item.unitPrice,
            'purchasePrice': item.purchasePrice,
            'total': item.total,
          };
        }).toList(),
        'customers': customers.map((customer) {
          return {
            'id': customer.id,
            'name': customer.name,
            'phone': customer.phone,
            'email': customer.email,
            'address': customer.address,
            'outstandingBalance': customer.outstandingBalance,
            'loyaltyPoints': customer.loyaltyPoints,
            'pointsBalance': customer.pointsBalance,
          };
        }).toList(),
        'expenses': expenses.map((expense) {
          return {
            'id': expense.id,
            'title': expense.title,
            'category': expense.category,
            'amount': expense.amount,
            'date': expense.date.toUtc().toIso8601String(),
            'note': expense.note,
          };
        }).toList(),
        'stockMovements': stockMovements.map((movement) {
          return {
            'id': movement.id,
            'productId': movement.productId,
            'type': movement.type,
            'quantity': movement.quantity,
            'previousStock': movement.previousStock,
            'newStock': movement.newStock,
            'note': movement.note,
            'staffId': movement.staffId,
            'createdAt': movement.createdAt.toUtc().toIso8601String(),
          };
        }).toList(),
        'businessSettings': businessSettings.map((settings) {
          return {
            'id': settings.id,
            'businessName': settings.businessName,
            'address': settings.address,
            'phone': settings.phone,
            'email': settings.email,
            'currency': settings.currency,
            'loyaltyEnabled': settings.loyaltyEnabled,
            'loyaltyEarnRate': settings.loyaltyEarnRate,
            'loyaltyRedeemValue': settings.loyaltyRedeemValue,
            'receiptHeader': settings.receiptHeader,
            'receiptFooter': settings.receiptFooter,
            'receiptShowPhone': settings.receiptShowPhone,
            'receiptShowAddress': settings.receiptShowAddress,
            'receiptNote': settings.receiptNote,
            'inactivityTimeoutMinutes': settings.inactivityTimeoutMinutes,
          };
        }).toList(),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  Future<String> saveBackup() async {
    final actor = await _authorizeOwner('backup export');
    final json = await createBackupJson();
    final bytes = Uint8List.fromList(utf8.encode(json));

    final timestamp = _backupTimestamp(DateTime.now());

    final savedPath = await FileSaver.instance.saveFile(
      name: 'bizflow_backup_$timestamp',
      bytes: bytes,
      fileExtension: 'json',
      mimeType: MimeType.json,
    );

    await _audit.log(
      action: 'backup.save',
      actor: actor?.username ?? 'Owner',
      summary: 'Exported a database backup to "$savedPath"',
      entityType: 'backup',
      entityId: timestamp,
    );

    return savedPath;
  }

  Future<Map<String, dynamic>> validateBackupJson(Uint8List bytes) async {
    final String jsonString;

    try {
      jsonString = utf8.decode(bytes);
    } on FormatException {
      throw const FormatException('The selected file is not valid UTF-8 text.');
    }

    final dynamic decoded;

    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      throw const FormatException('The selected file is not valid JSON.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The backup file has an invalid structure.');
    }

    if (decoded['application'] != 'BizFlow') {
      throw const FormatException('This file is not a BizFlow backup.');
    }

    if (decoded['backupFormatVersion'] is! int ||
        decoded['backupFormatVersion'] != 1) {
      throw const FormatException('This backup format is not supported.');
    }

    if (decoded['databaseSchemaVersion'] is! int) {
      throw const FormatException(
        'This backup is missing its database version.',
      );
    }

    final backupSchemaVersion = decoded['databaseSchemaVersion'] as int;

    // Accept any backup from a supported earlier schema version. Restore logic
    // uses safe defaults for fields that did not exist in older backups.
    if (backupSchemaVersion > _currentSchemaVersion ||
        backupSchemaVersion < _oldestSupportedSchemaVersion) {
      throw const FormatException(
        'This backup was created with an unsupported database version.',
      );
    }

    final data = decoded['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'The backup data section is missing or invalid.',
      );
    }

    const requiredSections = [
      'products',
      'categories',
      'sales',
      'saleItems',
      'customers',
      'expenses',
      'stockMovements',
      'businessSettings',
    ];

    for (final section in requiredSections) {
      final records = data[section];

      if (records is! List) {
        throw FormatException(
          'The backup section "$section" is missing or invalid.',
        );
      }

      for (var index = 0; index < records.length; index++) {
        final record = records[index];

        if (record is! Map) {
          throw FormatException(
            'Record $index in "$section" must be a JSON object.',
          );
        }

        final item = Map<String, dynamic>.from(record);

        void requireString(String field) {
          if (item[field] is! String) {
            throw FormatException(
              'Field "$field" in "$section" record $index '
              'must be a string.',
            );
          }
        }

        void requireNullableString(String field) {
          if (item[field] != null && item[field] is! String) {
            throw FormatException(
              'Field "$field" in "$section" record $index '
              'must be a string or null.',
            );
          }
        }

        void requireNumber(String field) {
          final value = item[field];

          if (value is! num || !value.isFinite) {
            throw FormatException(
              'Field "$field" in "$section" record $index '
              'must be a finite number.',
            );
          }
        }

        void requireInt(String field) {
          if (item[field] is! int) {
            throw FormatException(
              'Field "$field" in "$section" record $index '
              'must be an integer.',
            );
          }
        }

        void requireBool(String field) {
          if (item[field] is! bool) {
            throw FormatException(
              'Field "$field" in "$section" record $index '
              'must be a boolean.',
            );
          }
        }

        void requireDate(String field) {
          final value = item[field];

          if (value is! String || DateTime.tryParse(value) == null) {
            throw FormatException(
              'Field "$field" in "$section" record $index '
              'must be a valid date-time string.',
            );
          }
        }

        switch (section) {
          case 'products':
            for (final field in ['id', 'name', 'sku', 'category', 'barcode']) {
              requireString(field);
            }
            for (final field in ['purchasePrice', 'sellingPrice']) {
              requireNumber(field);
            }
            for (final field in ['stockQuantity', 'lowStockThreshold']) {
              requireInt(field);
            }

          case 'categories':
            requireString('id');
            requireString('name');

          case 'sales':
            requireString('id');
            requireNullableString('customerId');
            for (final field in [
              'subtotal',
              'discount',
              'total',
              'paidAmount',
            ]) {
              requireNumber(field);
            }
            requireString('paymentMethod');
            requireString('status');
            requireDate('createdAt');
            // Staff attribution was added in schema v14, so it is optional:
            // backups taken before that version must still validate.
            if (item.containsKey('staffId')) {
              requireNullableString('staffId');
            }

          case 'saleItems':
            for (final field in ['id', 'saleId', 'productId', 'productName']) {
              requireString(field);
            }
            requireInt('quantity');
            for (final field in ['unitPrice', 'purchasePrice', 'total']) {
              requireNumber(field);
            }

          case 'customers':
            for (final field in ['id', 'name', 'phone', 'email', 'address']) {
              requireString(field);
            }
            requireNumber('outstandingBalance');

          case 'expenses':
            for (final field in ['id', 'title', 'category', 'note']) {
              requireString(field);
            }
            requireNumber('amount');
            requireDate('date');

          case 'stockMovements':
            for (final field in ['id', 'productId', 'type', 'note']) {
              requireString(field);
            }
            for (final field in ['quantity', 'previousStock', 'newStock']) {
              requireInt(field);
            }
            requireDate('createdAt');
            // Optional for the same reason as `sales.staffId` (schema v14).
            if (item.containsKey('staffId')) {
              requireNullableString('staffId');
            }

          case 'businessSettings':
            for (final field in [
              'id',
              'businessName',
              'address',
              'phone',
              'email',
              'currency',
            ]) {
              requireString(field);
            }
            // Loyalty fields are optional so pre-v5 backups still validate.
            if (item.containsKey('loyaltyEnabled')) {
              requireBool('loyaltyEnabled');
            }
            if (item.containsKey('loyaltyEarnRate')) {
              requireNumber('loyaltyEarnRate');
            }
            if (item.containsKey('loyaltyRedeemValue')) {
              requireNumber('loyaltyRedeemValue');
            }
            // Phase F: the inactivity auto-lock timeout is optional so
            // pre-v15 backups (which never carried it) still validate and
            // restore with the default of 0 (auto-lock disabled).
            if (item.containsKey('inactivityTimeoutMinutes')) {
              requireNumber('inactivityTimeoutMinutes');
            }
        }
      }
    }

    return decoded;
  }

  Future<void> resetAllData() async {
    final actor = await _authorizeOwner('database reset');
    await _database.transaction(() async {
      await _database.delete(_database.saleItems).go();
      await _database.delete(_database.sales).go();
      await _database.delete(_database.stockMovements).go();
      await _database.delete(_database.expenses).go();
      await _database.delete(_database.customers).go();
      await _database.delete(_database.products).go();
      await _database.delete(_database.categories).go();
      await _database.delete(_database.businessSettings).go();
      await _database.delete(_database.staffAccounts).go();
    });

    await _audit.log(
      action: 'backup.reset',
      actor: actor?.username ?? 'Owner',
      summary: 'Reset all business data (database cleared)',
      entityType: 'backup',
      entityId: 'reset',
    );
  }

  Future<void> restoreBackup(Uint8List bytes) async {
    final actor = await _authorizeOwner('backup restore');

    // Validate before opening a transaction or modifying existing data.
    final backup = await validateBackupJson(bytes);
    final data = backup['data'] as Map<String, dynamic>;

    final products = data['products'] as List;
    final categories = data['categories'] as List;
    final sales = data['sales'] as List;
    final saleItems = data['saleItems'] as List;
    final customers = data['customers'] as List;
    final expenses = data['expenses'] as List;
    final stockMovements = data['stockMovements'] as List;
    final businessSettings = data['businessSettings'] as List;

    // Keep deletion and every insertion in one transaction.
    // A database error should roll back the complete restore.
    await _database.transaction(() async {
      await _database.delete(_database.saleItems).go();
      await _database.delete(_database.sales).go();
      await _database.delete(_database.stockMovements).go();
      await _database.delete(_database.expenses).go();
      await _database.delete(_database.customers).go();
      await _database.delete(_database.products).go();
      await _database.delete(_database.categories).go();
      await _database.delete(_database.businessSettings).go();

      // Restore categories.
      await _database.batch((batch) {
        batch.insertAll(
          _database.categories,
          categories.map((category) {
            final item = Map<String, dynamic>.from(category as Map);

            return CategoriesCompanion.insert(
              id: item['id'] as String,
              name: item['name'] as String,
            );
          }).toList(),
        );
      });

      // Restore products.
      await _database.batch((batch) {
        batch.insertAll(
          _database.products,
          products.map((product) {
            final item = Map<String, dynamic>.from(product as Map);

            return ProductsCompanion.insert(
              id: item['id'] as String,
              name: item['name'] as String,
              sku: item['sku'] as String,
              category: item['category'] as String,
              purchasePrice: (item['purchasePrice'] as num).toDouble(),
              sellingPrice: (item['sellingPrice'] as num).toDouble(),
              stockQuantity: item['stockQuantity'] as int,
              lowStockThreshold: item['lowStockThreshold'] as int,
              barcode: Value(item['barcode'] as String),
            );
          }).toList(),
        );
      });

      // Restore customers.
      await _database.batch((batch) {
        batch.insertAll(
          _database.customers,
          customers.map((customer) {
            final item = Map<String, dynamic>.from(customer as Map);

            return CustomersCompanion.insert(
              id: item['id'] as String,
              name: item['name'] as String,
              phone: Value(item['phone'] as String),
              email: Value(item['email'] as String),
              address: Value(item['address'] as String),
              outstandingBalance: Value(
                (item['outstandingBalance'] as num).toDouble(),
              ),
              loyaltyPoints: Value(
                (item['loyaltyPoints'] as num?)?.toInt() ?? 0,
              ),
              pointsBalance: Value(
                (item['pointsBalance'] as num?)?.toInt() ??
                    (item['loyaltyPoints'] as num?)?.toInt() ??
                    0,
              ),
              loyaltyTier: Value(
                (item['loyaltyTier'] as String?) ??
                    _tierForLifetime(
                      (item['loyaltyPoints'] as num?)?.toInt() ?? 0,
                    ),
              ),
            );
          }).toList(),
        );
      });

      // Restore sales.
      await _database.batch((batch) {
        batch.insertAll(
          _database.sales,
          sales.map((sale) {
            final item = Map<String, dynamic>.from(sale as Map);
            final customerId = item['customerId'];

            return SalesCompanion.insert(
              id: item['id'] as String,
              customerId: customerId == null
                  ? const Value.absent()
                  : Value(customerId as String),
              subtotal: (item['subtotal'] as num).toDouble(),
              discount: Value((item['discount'] as num).toDouble()),
              total: (item['total'] as num).toDouble(),
              paidAmount: (item['paidAmount'] as num).toDouble(),
              paymentMethod: Value(item['paymentMethod'] as String),
              status: Value(item['status'] as String),
              staffId: Value(item['staffId'] as String?),
              createdAt: DateTime.parse(item['createdAt'] as String),
            );
          }).toList(),
        );
      });

      // Restore sale items.
      await _database.batch((batch) {
        batch.insertAll(
          _database.saleItems,
          saleItems.map((saleItem) {
            final item = Map<String, dynamic>.from(saleItem as Map);

            return SaleItemsCompanion.insert(
              id: item['id'] as String,
              saleId: item['saleId'] as String,
              productId: item['productId'] as String,
              productName: item['productName'] as String,
              quantity: item['quantity'] as int,
              unitPrice: (item['unitPrice'] as num).toDouble(),
              purchasePrice: (item['purchasePrice'] as num).toDouble(),
              total: (item['total'] as num).toDouble(),
            );
          }).toList(),
        );
      });

      // Restore expenses.
      await _database.batch((batch) {
        batch.insertAll(
          _database.expenses,
          expenses.map((expense) {
            final item = Map<String, dynamic>.from(expense as Map);

            return ExpensesCompanion.insert(
              id: item['id'] as String,
              title: item['title'] as String,
              category: item['category'] as String,
              amount: (item['amount'] as num).toDouble(),
              date: DateTime.parse(item['date'] as String),
              note: Value(item['note'] as String),
            );
          }).toList(),
        );
      });

      // Restore stock movements.
      await _database.batch((batch) {
        batch.insertAll(
          _database.stockMovements,
          stockMovements.map((movement) {
            final item = Map<String, dynamic>.from(movement as Map);

            return StockMovementsCompanion.insert(
              id: item['id'] as String,
              productId: item['productId'] as String,
              type: item['type'] as String,
              quantity: item['quantity'] as int,
              previousStock: item['previousStock'] as int,
              newStock: item['newStock'] as int,
              note: Value(item['note'] as String),
              staffId: Value(item['staffId'] as String?),
              createdAt: DateTime.parse(item['createdAt'] as String),
            );
          }).toList(),
        );
      });

      // Restore business settings.
      await _database.batch((batch) {
        batch.insertAll(
          _database.businessSettings,
          businessSettings.map((settings) {
            final item = Map<String, dynamic>.from(settings as Map);

            return BusinessSettingsCompanion.insert(
              id: item['id'] as String,
              businessName: Value(item['businessName'] as String),
              address: Value(item['address'] as String),
              phone: Value(item['phone'] as String),
              email: Value(item['email'] as String),
              currency: Value(item['currency'] as String),
              loyaltyEnabled: Value((item['loyaltyEnabled'] as bool?) ?? true),
              loyaltyEarnRate: Value(
                (item['loyaltyEarnRate'] as num?)?.toDouble() ?? 1.0,
              ),
              loyaltyRedeemValue: Value(
                (item['loyaltyRedeemValue'] as num?)?.toDouble() ?? 0.01,
              ),
              receiptHeader: Value(
                (item['receiptHeader'] as String?) ??
                    'Thank you for your purchase!',
              ),
              receiptFooter: Value((item['receiptFooter'] as String?) ?? ''),
              receiptShowPhone: Value(
                (item['receiptShowPhone'] as bool?) ?? true,
              ),
              receiptShowAddress: Value(
                (item['receiptShowAddress'] as bool?) ?? true,
              ),
              receiptNote: Value((item['receiptNote'] as String?) ?? ''),
              // Phase F: absent in pre-v15 backups → 0 (auto-lock disabled).
              inactivityTimeoutMinutes: Value(
                (item['inactivityTimeoutMinutes'] as num?)?.toInt() ?? 0,
              ),
            );
          }).toList(),
        );
      });
    });

    await _audit.log(
      action: 'backup.restore',
      actor: actor?.username ?? 'Owner',
      summary: 'Restored the database from a backup file',
      entityType: 'backup',
      entityId: 'restore',
    );
  }

  /// Derives the tier name from lifetime points. Mirrors LoyaltyService so a
  /// backup restore never downgrades a customer whose tier column is absent
  /// (older backups) or inconsistent.
  String _tierForLifetime(int points) {
    if (points >= 5000) return 'Platinum';
    if (points >= 2000) return 'Gold';
    if (points >= 500) return 'Silver';
    return 'Bronze';
  }

  String _backupTimestamp(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return '$year$month${day}_$hour$minute$second';
  }
}
