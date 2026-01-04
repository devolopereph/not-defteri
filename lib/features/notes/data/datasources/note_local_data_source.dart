import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/note.dart';

/// SQLite veritabanı yöneticisi
///
/// Singleton pattern ile tek bir veritabanı bağlantısı sağlar.
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  /// Singleton instance
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  /// Veritabanı bağlantısı
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Veritabanını başlat
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: 2, // Versiyon 2'ye yükseltildi
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Tabloları oluştur
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.notesTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL DEFAULT '',
        content TEXT NOT NULL DEFAULT '',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        images TEXT NOT NULL DEFAULT '[]',
        isPinned INTEGER NOT NULL DEFAULT 0,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        deletedAt TEXT
      )
    ''');

    // Arama için indeks oluştur
    await db.execute('''
      CREATE INDEX idx_notes_updated ON ${AppConstants.notesTable} (updatedAt DESC)
    ''');

    // Silinmiş notlar için indeks
    await db.execute('''
      CREATE INDEX idx_notes_deleted ON ${AppConstants.notesTable} (isDeleted, deletedAt DESC)
    ''');
  }

  /// Veritabanı güncellemesi
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Versiyon 1'den 2'ye güncelleme: isPinned, isDeleted, deletedAt alanları eklendi
    if (oldVersion < 2) {
      // Yeni alanları mevcut tabloya ekle
      await db.execute('''
        ALTER TABLE ${AppConstants.notesTable} ADD COLUMN isPinned INTEGER NOT NULL DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE ${AppConstants.notesTable} ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE ${AppConstants.notesTable} ADD COLUMN deletedAt TEXT
      ''');

      // Silinmiş notlar için indeks
      await db.execute('''
        CREATE INDEX idx_notes_deleted ON ${AppConstants.notesTable} (isDeleted, deletedAt DESC)
      ''');
    }
  }

  /// Veritabanını kapat
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

/// Not veritabanı işlemleri
class NoteLocalDataSource {
  final DatabaseHelper _dbHelper;

  NoteLocalDataSource(this._dbHelper);

  /// Tüm aktif notları getir (silinmemiş, güncellenme tarihine göre sıralı, pinlenmiş olanlar önce)
  Future<List<Note>> getAllNotes() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.notesTable,
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  /// Silinen notları getir (çöp kutusu)
  Future<List<Note>> getDeletedNotes() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.notesTable,
      where: 'isDeleted = ?',
      whereArgs: [1],
      orderBy: 'deletedAt DESC',
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  /// ID'ye göre not getir
  Future<Note?> getNoteById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.notesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  /// Not ekle
  Future<void> insertNote(Note note) async {
    final db = await _dbHelper.database;
    await db.insert(
      AppConstants.notesTable,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Not güncelle
  Future<void> updateNote(Note note) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.notesTable,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// Notu çöp kutusuna taşı (soft delete)
  Future<void> moveToTrash(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.notesTable,
      {'isDeleted': 1, 'deletedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Notu çöp kutusundan geri getir
  Future<void> restoreFromTrash(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.notesTable,
      {'isDeleted': 0, 'deletedAt': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Notu kalıcı olarak sil
  Future<void> deleteNote(String id) async {
    final db = await _dbHelper.database;
    await db.delete(AppConstants.notesTable, where: 'id = ?', whereArgs: [id]);
  }

  /// Birden fazla notu kalıcı olarak sil
  Future<void> deleteNotes(List<String> ids) async {
    if (ids.isEmpty) return;

    final db = await _dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.delete(
      AppConstants.notesTable,
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  /// Birden fazla notu çöp kutusuna taşı
  Future<void> moveMultipleToTrash(List<String> ids) async {
    if (ids.isEmpty) return;

    final db = await _dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.update(
      AppConstants.notesTable,
      {'isDeleted': 1, 'deletedAt': DateTime.now().toIso8601String()},
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  /// Çöp kutusunu tamamen boşalt
  Future<void> emptyTrash() async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.notesTable,
      where: 'isDeleted = ?',
      whereArgs: [1],
    );
  }

  /// Not sabitleme durumunu güncelle
  Future<void> togglePin(String id, bool isPinned) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.notesTable,
      {'isPinned': isPinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Not ara (başlık ve içerikte, sadece aktif notlarda)
  Future<List<Note>> searchNotes(String query) async {
    if (query.isEmpty) return getAllNotes();

    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.notesTable,
      where: 'isDeleted = ? AND (title LIKE ? OR content LIKE ?)',
      whereArgs: [0, '%$query%', '%$query%'],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }
}
