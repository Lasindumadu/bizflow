import 'package:drift/drift.dart';

import '../../core/session/session_authorization.dart';
import '../database/app_database.dart';

class CategoryRepository {
  final AppDatabase database;

  CategoryRepository(this.database);

  /// Resolves the acting staff and enforces owner-or-manager authorization
  /// for category management (catalog schema affects products, reporting,
  /// and inventory).
  Future<ResolvedActor> _authorizeCategories() async {
    final actor = await resolveActor(database);
    requireRole(
      actor.staff,
      {StaffRole.owner, StaffRole.manager},
      'category management',
    );
    return actor;
  }

  /// Resolves the acting staff and enforces owner-only authorization
  /// for category deletion (destructive: orphans products and reporting).
  Future<ResolvedActor> _authorizeCategoryDeletion() async {
    final actor = await resolveActor(database);
    requireRole(
      actor.staff,
      {StaffRole.owner},
      'category deletion',
    );
    return actor;
  }

  Stream<List<Category>> watchCategories() {
    final query = database.select(database.categories)
      ..orderBy([(table) => OrderingTerm.asc(table.name)]);

    return query.watch();
  }

  Future<List<Category>> getCategories() {
    final query = database.select(database.categories)
      ..orderBy([(table) => OrderingTerm.asc(table.name)]);

    return query.get();
  }

  Future<void> addCategory({required String id, required String name}) async {
    await _authorizeCategories();
    await database
        .into(database.categories)
        .insert(CategoriesCompanion.insert(id: id, name: name));
  }

  Future<void> updateCategory({
    required String id,
    required String name,
  }) async {
    await _authorizeCategories();
    await (database.update(database.categories)
          ..where((table) => table.id.equals(id)))
        .write(CategoriesCompanion(name: Value(name)));
  }

  Future<void> deleteCategory(String id) async {
    await _authorizeCategoryDeletion();
    await (database.delete(
      database.categories,
    )..where((table) => table.id.equals(id))).go();
  }
}
