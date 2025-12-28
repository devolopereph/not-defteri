import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_local_data_source.dart';

/// Not repository implementasyonu
///
/// Domain layer'daki abstract repository'nin gerçek implementasyonu.
/// Local data source ile çalışır.
class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource _localDataSource;

  NoteRepositoryImpl(this._localDataSource);

  @override
  Future<List<Note>> getAllNotes() async {
    try {
      return await _localDataSource.getAllNotes();
    } catch (e) {
      throw Exception('Notlar yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<Note?> getNoteById(String id) async {
    try {
      return await _localDataSource.getNoteById(id);
    } catch (e) {
      throw Exception('Not yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<void> insertNote(Note note) async {
    try {
      await _localDataSource.insertNote(note);
    } catch (e) {
      throw Exception('Not eklenirken hata oluştu: $e');
    }
  }

  @override
  Future<void> updateNote(Note note) async {
    try {
      await _localDataSource.updateNote(note);
    } catch (e) {
      throw Exception('Not güncellenirken hata oluştu: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await _localDataSource.deleteNote(id);
    } catch (e) {
      throw Exception('Not silinirken hata oluştu: $e');
    }
  }

  @override
  Future<void> deleteNotes(List<String> ids) async {
    try {
      await _localDataSource.deleteNotes(ids);
    } catch (e) {
      throw Exception('Notlar silinirken hata oluştu: $e');
    }
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    try {
      return await _localDataSource.searchNotes(query);
    } catch (e) {
      throw Exception('Arama yapılırken hata oluştu: $e');
    }
  }
}
