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

/// Not sil
class DeleteNote extends NotesEvent {
  final String id;

  const DeleteNote(this.id);

  @override
  List<Object?> get props => [id];
}

/// Birden fazla not sil
class DeleteMultipleNotes extends NotesEvent {
  final List<String> ids;

  const DeleteMultipleNotes(this.ids);

  @override
  List<Object?> get props => [ids];
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
