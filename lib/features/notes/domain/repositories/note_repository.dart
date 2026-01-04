import '../entities/note.dart';

/// Not repository arayüzü (Domain Layer)
///
/// Data layer'dan bağımsız soyut tanım.
/// CRUD işlemlerini tanımlar.
abstract class NoteRepository {
  /// Tüm aktif notları getir
  Future<List<Note>> getAllNotes();

  /// Silinen notları getir (çöp kutusu)
  Future<List<Note>> getDeletedNotes();

  /// ID'ye göre not getir
  Future<Note?> getNoteById(String id);

  /// Yeni not ekle
  Future<void> insertNote(Note note);

  /// Not güncelle
  Future<void> updateNote(Note note);

  /// Notu çöp kutusuna taşı
  Future<void> moveToTrash(String id);

  /// Notu çöp kutusundan geri getir
  Future<void> restoreFromTrash(String id);

  /// Notu kalıcı olarak sil
  Future<void> deleteNote(String id);

  /// Birden fazla notu kalıcı olarak sil
  Future<void> deleteNotes(List<String> ids);

  /// Birden fazla notu çöp kutusuna taşı
  Future<void> moveMultipleToTrash(List<String> ids);

  /// Çöp kutusunu tamamen boşalt
  Future<void> emptyTrash();

  /// Not sabitleme durumunu değiştir
  Future<void> togglePin(String id, bool isPinned);

  /// Arama yap
  Future<List<Note>> searchNotes(String query);
}
