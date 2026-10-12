import 'package:drift/drift.dart';

/// An append-only record of important business actions.
///
/// Written by stock changes, sale cancellations, refunds and loyalty
/// adjustments so shop owners have an accountability trail.
class AuditLogs extends Table {
  TextColumn get id => text()();

  /// Who performed the action. A single-operator build uses "Owner" by
  /// default; staff profiles can populate this later.
  TextColumn get actor => text().withDefault(const Constant('Owner'))();

  /// Action category, e.g. 'stock.change', 'sale.cancel', 'refund.create'.
  TextColumn get action => text()();

  /// Human-readable summary of what happened.
  TextColumn get summary => text().withDefault(const Constant(''))();

  /// The kind of record affected, e.g. 'product', 'sale', 'customer'.
  TextColumn get entityType => text().withDefault(const Constant(''))();

  /// Identifier of the affected record.
  TextColumn get entityId => text().withDefault(const Constant(''))();

  /// Optional JSON-encoded before/after values.
  TextColumn get beforeJson => text().withDefault(const Constant(''))();

  TextColumn get afterJson => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
