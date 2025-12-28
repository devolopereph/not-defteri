import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';

part 'notes_event.dart';
part 'notes_state.dart';

/// Notlar için BLoC
///
/// Not listesi işlemlerini yönetir:
/// - Yükleme
/// - Ekleme
/// - Güncelleme
/// - Silme
/// - Arama
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteRepository _repository;
  final Uuid _uuid = const Uuid();

  NotesBloc(this._repository) : super(NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<DeleteMultipleNotes>(_onDeleteMultipleNotes);
    on<SearchNotes>(_onSearchNotes);
    on<RefreshNotes>(_onRefreshNotes);
  }

  /// Notları yükle
  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final notes = await _repository.getAllNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  /// Yeni not ekle
  Future<void> _onAddNote(AddNote event, Emitter<NotesState> emit) async {
    try {
      final note = Note.empty(_uuid.v4());
      await _repository.insertNote(note);

      // Mevcut listeyi güncelle
      if (state is NotesLoaded) {
        final currentNotes = (state as NotesLoaded).notes;
        emit(NotesLoaded([note, ...currentNotes], lastAddedNoteId: note.id));
      } else {
        emit(NotesLoaded([note], lastAddedNoteId: note.id));
      }
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  /// Not güncelle
  Future<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    try {
      final updatedNote = event.note.copyWith(updatedAt: DateTime.now());
      await _repository.updateNote(updatedNote);

      // Mevcut listeyi güncelle
      if (state is NotesLoaded) {
        final currentNotes = (state as NotesLoaded).notes;
        final updatedNotes = currentNotes.map((n) {
          return n.id == updatedNote.id ? updatedNote : n;
        }).toList();

        // Güncellenme tarihine göre sırala
        updatedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        emit(NotesLoaded(updatedNotes));
      }
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  /// Not sil
  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      await _repository.deleteNote(event.id);

      // Mevcut listeyi güncelle
      if (state is NotesLoaded) {
        final currentNotes = (state as NotesLoaded).notes;
        final updatedNotes = currentNotes
            .where((n) => n.id != event.id)
            .toList();
        emit(NotesLoaded(updatedNotes));
      }
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  /// Birden fazla not sil
  Future<void> _onDeleteMultipleNotes(
    DeleteMultipleNotes event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _repository.deleteNotes(event.ids);

      // Mevcut listeyi güncelle
      if (state is NotesLoaded) {
        final currentNotes = (state as NotesLoaded).notes;
        final updatedNotes = currentNotes
            .where((n) => !event.ids.contains(n.id))
            .toList();
        emit(NotesLoaded(updatedNotes));
      }
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  /// Notlarda ara
  Future<void> _onSearchNotes(
    SearchNotes event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final notes = await _repository.searchNotes(event.query);
      emit(NotesLoaded(notes, searchQuery: event.query));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  /// Notları yenile
  Future<void> _onRefreshNotes(
    RefreshNotes event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final notes = await _repository.getAllNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }
}
