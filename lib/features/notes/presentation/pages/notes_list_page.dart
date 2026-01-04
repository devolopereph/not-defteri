import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
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
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadViewMode();
  }

  /// Kayıtlı görünüm modunu yükle
  Future<void> _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isGrid = prefs.getBool(AppConstants.viewModeKey) ?? false;
    if (mounted) {
      setState(() {
        _isGridView = isGrid;
      });
    }
  }

  /// Görünüm modunu kaydet
  Future<void> _saveViewMode(bool isGrid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.viewModeKey, isGrid);
  }

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
          // Grid/List toggle butonu
          IconButton(
            icon: Icon(
              _isGridView
                  ? CupertinoIcons.list_bullet
                  : CupertinoIcons.square_grid_2x2,
            ),
            tooltip: _isGridView ? 'Liste Görünümü' : 'Izgara Görünümü',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
              _saveViewMode(_isGridView);
            },
          ),
          // Arama butonu
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
              child: _isGridView
                  ? _buildGridView(state.notes)
                  : _buildListView(state.notes),
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

  /// Liste görünümü
  Widget _buildListView(List<Note> notes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () => _navigateToEditor(context, note),
          onLongPress: () => _showNoteOptionsSheet(context, note),
          isGridView: false,
        );
      },
    );
  }

  /// Izgara görünümü
  Widget _buildGridView(List<Note> notes) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () => _navigateToEditor(context, note),
          onLongPress: () => _showNoteOptionsSheet(context, note),
          isGridView: true,
        );
      },
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

  /// Not seçenekleri bottom sheet
  void _showNoteOptionsSheet(BuildContext context, Note note) {
    final isDark = context.read<ThemeCubit>().isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Üst çizgi
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Not başlığı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    note.title.isNotEmpty ? note.title : 'Başlıksız not',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 20),

                // Sabitle / Sabitlemeyi Kaldır
                ListTile(
                  leading: Icon(
                    note.isPinned
                        ? CupertinoIcons.pin_slash
                        : CupertinoIcons.pin,
                    color: AppColors.primary,
                  ),
                  title: Text(note.isPinned ? 'Sabitlemeyi Kaldır' : 'Sabitle'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.read<NotesBloc>().add(
                      ToggleNotePin(note.id, !note.isPinned),
                    );
                  },
                ),

                // Sil
                ListTile(
                  leading: Icon(CupertinoIcons.trash, color: AppColors.error),
                  title: Text('Sil', style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showDeleteConfirmDialog(context, note);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Silme onay dialogu
  void _showDeleteConfirmDialog(BuildContext context, Note note) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Notu Sil'),
        content: Text(
          note.title.isNotEmpty
              ? '"${note.title}" notunu silmek istediğinize emin misiniz?\n\nNot çöp kutusuna taşınacak.'
              : 'Bu notu silmek istediğinize emin misiniz?\n\nNot çöp kutusuna taşınacak.',
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
              context.read<NotesBloc>().add(MoveNoteToTrash(note.id));
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }
}
