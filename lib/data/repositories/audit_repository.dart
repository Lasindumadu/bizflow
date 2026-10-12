import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// A single audit trail entry for display.
class AuditEntry {
  final String id;
  final String actor;
  final String action;
  final String summary;
  final String entityType;
  final String entityId;
  final DateTime createdAt;

  const AuditEntry({
    required this.id,
    required this.actor,
    required this.action,
    required this.summary,
    required this.entityType,
    required this.entityId,
    required this.createdAt,
  });

  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }
}

/// Writes and reads the append-only audit trail.
///
/// Logging is intentionally best-effort: a failure to write an audit row must
/// never break the business action that triggered it.
class AuditRepository {
  final AppDatabase database;

  AuditRepository(this.database);

  Future<void> log({
    required String action,
    String actor = 'Owner',
    String summary = '',
    String entityType = '',
    String entityId = '',
    Map<String, dynamic>? before,
    Map<String, dynamic>? after,
  }) async {
    try {
      await database
          .into(database.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              id: 'aud_${DateTime.now().microsecondsSinceEpoch}',
              actor: Value(actor),
              action: action,
              summary: Value(summary),
              entityType: Value(entityType),
              entityId: Value(entityId),
              beforeJson: Value(before == null ? '' : jsonEncode(before)),
              afterJson: Value(after == null ? '' : jsonEncode(after)),
              createdAt: DateTime.now(),
            ),
          );
    } catch (_) {
      // Never let auditing break a business operation.
    }
  }

  Stream<List<AuditEntry>> watchEntries({int limit = 200}) {
    final query = database.select(database.auditLogs)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);

    return query.watch().map(
      (rows) => rows
          .map(
            (r) => AuditEntry(
              id: r.id,
              actor: r.actor,
              action: r.action,
              summary: r.summary,
              entityType: r.entityType,
              entityId: r.entityId,
              createdAt: r.createdAt,
            ),
          )
          .toList(),
    );
  }

  Future<List<AuditEntry>> getEntries({int limit = 200}) async {
    final query = database.select(database.auditLogs)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);
    final rows = await query.get();
    return rows
        .map(
          (r) => AuditEntry(
            id: r.id,
            actor: r.actor,
            action: r.action,
            summary: r.summary,
            entityType: r.entityType,
            entityId: r.entityId,
            createdAt: r.createdAt,
          ),
        )
        .toList();
  }
}
