part of 'notes_bloc.dart';

/// Notes BLoC durumları
sealed class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

/// Başlangıç durumu
class NotesInitial extends NotesState {}

/// Yükleniyor durumu
class NotesLoading extends NotesState {}

/// Notlar yüklendi durumu
class NotesLoaded extends NotesState {
  final List<Note> notes;
  final String? searchQuery;
  final String? lastAddedNoteId;

  const NotesLoaded(this.notes, {this.searchQuery, this.lastAddedNoteId});

  @override
  List<Object?> get props => [notes, searchQuery, lastAddedNoteId];
}

/// Hata durumu
class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object?> get props => [message];
}
