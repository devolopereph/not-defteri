import '../entities/note.dart';

/// Not repository arayüzü (Domain Layer)
///
/// Data layer'dan bağımsız soyut tanım.
/// CRUD işlemlerini tanımlar.
abstract class NoteRepository {
  /// Tüm notları getir
  Future<List<Note>> getAllNotes();

  /// ID'ye göre not getir
  Future<Note?> getNoteById(String id);

  /// Yeni not ekle
  Future<void> insertNote(Note note);

  /// Not güncelle
  Future<void> updateNote(Note note);

  /// Not sil
  Future<void> deleteNote(String id);

  /// Birden fazla not sil
  Future<void> deleteNotes(List<String> ids);

  /// Arama yap
  Future<List<Note>> searchNotes(String query);
}
