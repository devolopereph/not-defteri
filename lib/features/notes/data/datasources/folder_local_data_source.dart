import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/folder.dart';

/// Klasör veritabanı işlemleri
class FolderLocalDataSource {
  final dynamic _dbHelper;

  FolderLocalDataSource(this._dbHelper);

  /// Tüm klasörleri getir (güncellenme tarihine göre sıralı)
  Future<List<Folder>> getAllFolders() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.foldersTable,
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => Folder.fromMap(map)).toList();
  }

  /// ID'ye göre klasör getir
  Future<Folder?> getFolderById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.foldersTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Folder.fromMap(maps.first);
  }

  /// Klasör ekle
  Future<void> insertFolder(Folder folder) async {
    final db = await _dbHelper.database;
    await db.insert(
      AppConstants.foldersTable,
      folder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Klasör güncelle
  Future<void> updateFolder(Folder folder) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.foldersTable,
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  /// Klasör sil (içindeki notların folderId'si null yapılır)
  Future<void> deleteFolder(String id) async {
    final db = await _dbHelper.database;

    // Önce bu klasördeki notların folderId'sini null yap
    await db.update(
      AppConstants.notesTable,
      {'folderId': null},
      where: 'folderId = ?',
      whereArgs: [id],
    );

    // Sonra klasörü sil
    await db.delete(
      AppConstants.foldersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Klasör ara
  Future<List<Folder>> searchFolders(String query) async {
    if (query.isEmpty) return getAllFolders();

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.foldersTable,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => Folder.fromMap(map)).toList();
  }

  /// Klasördeki not sayısını getir
  Future<int> getNoteCountInFolder(String folderId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.notesTable} WHERE folderId = ? AND isDeleted = 0',
      [folderId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
