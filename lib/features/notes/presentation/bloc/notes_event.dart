part of 'notes_bloc.dart';

/// Notes BLoC olayları
sealed class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

/// Notları yükle
class LoadNotes extends NotesEvent {
  const LoadNotes();
}

/// Yeni not ekle
class AddNote extends NotesEvent {
  const AddNote();
}

/// Not güncelle
class UpdateNote extends NotesEvent {
  final Note note;

  const UpdateNote(this.note);

  @override
  List<Object?> get props => [note];
}

/// Notu çöp kutusuna taşı
class MoveNoteToTrash extends NotesEvent {
  final String id;

  const MoveNoteToTrash(this.id);

  @override
  List<Object?> get props => [id];
}

/// Notu çöp kutusundan geri getir
class RestoreNoteFromTrash extends NotesEvent {
  final String id;

  const RestoreNoteFromTrash(this.id);

  @override
  List<Object?> get props => [id];
}

/// Notu kalıcı olarak sil
class DeleteNote extends NotesEvent {
  final String id;

  const DeleteNote(this.id);

  @override
  List<Object?> get props => [id];
}

/// Birden fazla notu kalıcı olarak sil
class DeleteMultipleNotes extends NotesEvent {
  final List<String> ids;

  const DeleteMultipleNotes(this.ids);

  @override
  List<Object?> get props => [ids];
}

/// Birden fazla notu çöp kutusuna taşı
class MoveMultipleNotesToTrash extends NotesEvent {
  final List<String> ids;

  const MoveMultipleNotesToTrash(this.ids);

  @override
  List<Object?> get props => [ids];
}

/// Çöp kutusunu tamamen boşalt
class EmptyTrash extends NotesEvent {
  const EmptyTrash();
}

/// Not sabitleme durumunu değiştir
class ToggleNotePin extends NotesEvent {
  final String id;
  final bool isPinned;

  const ToggleNotePin(this.id, this.isPinned);

  @override
  List<Object?> get props => [id, isPinned];
}

/// Silinen notları yükle
class LoadDeletedNotes extends NotesEvent {
  const LoadDeletedNotes();
}

/// Notlarda ara
class SearchNotes extends NotesEvent {
  final String query;

  const SearchNotes(this.query);

  @override
  List<Object?> get props => [query];
}

/// Notları yenile
class RefreshNotes extends NotesEvent {
  const RefreshNotes();
}
