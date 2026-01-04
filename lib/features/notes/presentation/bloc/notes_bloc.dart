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
/// - Silme (çöp kutusuna taşıma)
/// - Kalıcı silme
/// - Geri getirme
/// - Sabitleme
/// - Arama
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteRepository _repository;
  final Uuid _uuid = const Uuid();

  NotesBloc(this._repository) : super(NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<MoveNoteToTrash>(_onMoveNoteToTrash);
    on<RestoreNoteFromTrash>(_onRestoreNoteFromTrash);
    on<DeleteNote>(_onDeleteNote);
    on<DeleteMultipleNotes>(_onDeleteMultipleNotes);
    on<MoveMultipleNotesToTrash>(_onMoveMultipleNotesToTrash);
    on<EmptyTrash>(_onEmptyTrash);
    on<ToggleNotePin>(_onToggleNotePin);
    on<LoadDeletedNotes>(_onLoadDeletedNotes);
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

        // Pinlenmiş olanlar önce, sonra güncellenme tarihine göre sırala
        updatedNotes.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        emit(NotesLoaded(updatedNotes));
      }
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  /// Notu çöp kutusuna taşı
  Future<void> _onMoveNoteToTrash(
    MoveNoteToTrash event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _repository.moveToTrash(event.id);

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

  /// Notu çöp kutusundan geri getir
  Future<void> _onRestoreNoteFromTrash(
    RestoreNoteFromTrash event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _repository.restoreFromTrash(event.id);

      // Çöp kutusu listesini güncelle
      if (state is TrashLoaded) {
        final currentNotes = (state as TrashLoaded).deletedNotes;
        final updatedNotes = currentNotes
            .where((n) => n.id != event.id)
            .toList();
        emit(TrashLoaded(updatedNotes));
      }
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  /// Notu kalıcı olarak sil
  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      await _repository.deleteNote(event.id);

      // Mevcut state'e göre güncelle
      if (state is NotesLoaded) {
        final currentNotes = (state as NotesLoaded).notes;
        final updatedNotes = currentNotes
            .where((n) => n.id != event.id)
            .toList();
        emit(NotesLoaded(updatedNotes));
      } else if (state is TrashLoaded) {
        final currentNotes = (state as TrashLoaded).deletedNotes;
        final updatedNotes = currentNotes
            .where((n) => n.id != event.id)
            .toList();
        emit(TrashLoaded(updatedNotes));
      }
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  /// Birden fazla notu kalıcı olarak sil
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
      } else if (state is TrashLoaded) {
        final currentNotes = (state as TrashLoaded).deletedNotes;
        final updatedNotes = currentNotes
            .where((n) => !event.ids.contains(n.id))
            .toList();
        emit(TrashLoaded(updatedNotes));
      }
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  /// Birden fazla notu çöp kutusuna taşı
  Future<void> _onMoveMultipleNotesToTrash(
    MoveMultipleNotesToTrash event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _repository.moveMultipleToTrash(event.ids);

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

  /// Çöp kutusunu tamamen boşalt
  Future<void> _onEmptyTrash(EmptyTrash event, Emitter<NotesState> emit) async {
    try {
      await _repository.emptyTrash();
      emit(const TrashLoaded([]));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  /// Not sabitleme durumunu değiştir
  Future<void> _onToggleNotePin(
    ToggleNotePin event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _repository.togglePin(event.id, event.isPinned);

      // Mevcut listeyi güncelle
      if (state is NotesLoaded) {
        final currentNotes = (state as NotesLoaded).notes;
        final updatedNotes = currentNotes.map((n) {
          return n.id == event.id ? n.copyWith(isPinned: event.isPinned) : n;
        }).toList();

        // Pinlenmiş olanlar önce, sonra güncellenme tarihine göre sırala
        updatedNotes.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        emit(NotesLoaded(updatedNotes));
      }
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  /// Silinen notları yükle
  Future<void> _onLoadDeletedNotes(
    LoadDeletedNotes event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    try {
      final notes = await _repository.getDeletedNotes();
      emit(TrashLoaded(notes));
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
