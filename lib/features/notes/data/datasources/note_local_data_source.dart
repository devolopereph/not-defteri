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
      version: AppConstants.databaseVersion,
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
        images TEXT NOT NULL DEFAULT '[]'
      )
    ''');

    // Arama için indeks oluştur
    await db.execute('''
      CREATE INDEX idx_notes_updated ON ${AppConstants.notesTable} (updatedAt DESC)
    ''');
  }

  /// Veritabanı güncellemesi
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // İleride veritabanı şeması değişirse burada migration yapılır
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

  /// Tüm notları getir (güncellenme tarihine göre sıralı)
  Future<List<Note>> getAllNotes() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.notesTable,
      orderBy: 'updatedAt DESC',
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

  /// Not sil
  Future<void> deleteNote(String id) async {
    final db = await _dbHelper.database;
    await db.delete(AppConstants.notesTable, where: 'id = ?', whereArgs: [id]);
  }

  /// Birden fazla not sil
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

  /// Not ara (başlık ve içerikte)
  Future<List<Note>> searchNotes(String query) async {
    if (query.isEmpty) return getAllNotes();

    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.notesTable,
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }
}
