import 'package:drift/drift.dart';

import '../database/app_database.dart';

class CategoryRepository {
  final AppDatabase database;

  CategoryRepository(this.database);

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
    await database
        .into(database.categories)
        .insert(CategoriesCompanion.insert(id: id, name: name));
  }

  Future<void> updateCategory({
    required String id,
    required String name,
  }) async {
    await (database.update(database.categories)
          ..where((table) => table.id.equals(id)))
        .write(CategoriesCompanion(name: Value(name)));
  }

  Future<void> deleteCategory(String id) async {
    await (database.delete(
      database.categories,
    )..where((table) => table.id.equals(id))).go();
  }
}
