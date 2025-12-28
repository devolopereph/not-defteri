import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';
import '../widgets/note_card.dart';
import '../widgets/empty_state.dart';
import 'note_editor_page.dart';

/// Not listesi sayfası
class NotesListPage extends StatefulWidget {
  const NotesListPage({super.key});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField(isDark)
            : const Text('Notlarım'),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? CupertinoIcons.xmark : CupertinoIcons.search,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<NotesBloc>().add(const RefreshNotes());
                }
              });
            },
          ),
        ],
      ),
      body: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          // Yeni not eklendiyse düzenleme sayfasına git
          if (state is NotesLoaded && state.lastAddedNoteId != null) {
            final note = state.notes.firstWhere(
              (n) => n.id == state.lastAddedNoteId,
              orElse: () => Note.empty(state.lastAddedNoteId!),
            );
            _navigateToEditor(context, note);
          }
        },
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (state is NotesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_circle,
                    size: 64,
                    color: AppColors.error.withAlpha(150),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bir hata oluştu',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<NotesBloc>().add(const LoadNotes());
                    },
                    icon: const Icon(CupertinoIcons.refresh),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (state is NotesLoaded) {
            if (state.notes.isEmpty) {
              return EmptyState(
                icon: CupertinoIcons.doc_text,
                title:
                    state.searchQuery != null && state.searchQuery!.isNotEmpty
                    ? 'Sonuç bulunamadı'
                    : 'Henüz not yok',
                subtitle:
                    state.searchQuery != null && state.searchQuery!.isNotEmpty
                    ? '"${state.searchQuery}" için sonuç bulunamadı'
                    : 'İlk notunuzu oluşturmak için + butonuna tıklayın',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotesBloc>().add(const RefreshNotes());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];
                  return NoteCard(
                    note: note,
                    onTap: () => _navigateToEditor(context, note),
                    onDelete: () => _showDeleteDialog(context, note),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<NotesBloc>().add(const AddNote());
        },
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Not ara...',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
      style: TextStyle(
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
      onChanged: (query) {
        context.read<NotesBloc>().add(SearchNotes(query));
      },
    );
  }

  void _navigateToEditor(BuildContext context, Note note) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => NoteEditorPage(note: note)),
    );
  }

  void _showDeleteDialog(BuildContext context, Note note) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Notu Sil'),
        content: Text(
          note.title.isNotEmpty
              ? '"${note.title}" notunu silmek istediğinize emin misiniz?'
              : 'Bu notu silmek istediğinize emin misiniz?',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Sil'),
            onPressed: () {
              context.read<NotesBloc>().add(DeleteNote(note.id));
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }
}
