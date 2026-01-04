import 'package:epheproject/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/folder.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/folders_bloc.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final isDark = context.watch<ThemeCubit>().isDark;

    return Scaffold(
      body: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NotesLoaded && state.lastAddedNoteId != null) {
            final note = state.notes.firstWhere(
              (n) => n.id == state.lastAddedNoteId,
              orElse: () => Note.empty(state.lastAddedNoteId!),
            );
            _navigateToEditor(context, note);
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar.medium(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                surfaceTintColor: Colors.transparent,
                title: _isSearching
                    ? _buildSearchField(isDark, l10n)
                    : Text(
                        l10n.myNotes,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isGridView
                          ? CupertinoIcons.list_bullet
                          : CupertinoIcons.square_grid_2x2,
                    ),
                    tooltip: _isGridView ? l10n.listView : l10n.gridView,
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                      _saveViewMode(_isGridView);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _isSearching
                          ? CupertinoIcons.xmark
                          : CupertinoIcons.search,
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

              if (state is NotesLoading)
                const SliverFillRemaining(
                  child: Center(child: CupertinoActivityIndicator()),
                )
              else if (state is NotesError)
                SliverFillRemaining(
                  child: Center(
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
                          l10n.errorOccurred,
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
                          label: Text(l10n.tryAgain),
                        ),
                      ],
                    ),
                  ),
                )
              else if (state is NotesLoaded)
                if (state.notes.isEmpty)
                  SliverFillRemaining(
                    child: EmptyState(
                      icon: CupertinoIcons.doc_text,
                      title:
                          state.searchQuery != null &&
                              state.searchQuery!.isNotEmpty
                          ? l10n.noResults
                          : l10n.noNotesYet,
                      subtitle:
                          state.searchQuery != null &&
                              state.searchQuery!.isNotEmpty
                          ? l10n.noResultsFor(state.searchQuery!)
                          : l10n.tapToCreate,
                    ),
                  )
                else
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      context.read<NotesBloc>().add(const RefreshNotes());
                    },
                  ),

              if (state is NotesLoaded && state.notes.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: _isGridView
                      ? _buildSliverGrid(state.notes)
                      : _buildSliverList(state.notes),
                ),
            ],
          );
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

  /// Liste görünümü (Sliver)
  Widget _buildSliverList(List<Note> notes) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () => _navigateToEditor(context, note),
          onLongPress: () => _showNoteOptionsSheet(context, note),
          isGridView: false,
        );
      }, childCount: notes.length),
    );
  }

  /// Izgara görünümü (Sliver)
  Widget _buildSliverGrid(List<Note> notes) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () => _navigateToEditor(context, note),
          onLongPress: () => _showNoteOptionsSheet(context, note),
          isGridView: true,
        );
      }, childCount: notes.length),
    );
  }

  Widget _buildSearchField(bool isDark, AppLocalizations l10n) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: l10n.searchNotes,
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
    final l10n = AppLocalizations.of(context)!;
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
                    note.title.isNotEmpty ? note.title : l10n.untitledNote,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 20),

                // Klasöre Taşı
                ListTile(
                  leading: Icon(CupertinoIcons.folder, color: AppColors.accent),
                  title: Text(l10n.moveToFolder),
                  trailing: note.folderId != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.inFolder,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showFolderSelectionSheet(context, note);
                  },
                ),

                // Sabitle / Sabitlemeyi Kaldır
                ListTile(
                  leading: Icon(
                    note.isPinned
                        ? CupertinoIcons.pin_slash
                        : CupertinoIcons.pin,
                    color: AppColors.primary,
                  ),
                  title: Text(note.isPinned ? l10n.unpin : l10n.pin),
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
                  title: Text(
                    l10n.delete,
                    style: TextStyle(color: AppColors.error),
                  ),
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

  /// Klasör seçim sheet
  void _showFolderSelectionSheet(BuildContext context, Note note) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = context.read<ThemeCubit>().isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocBuilder<FoldersBloc, FoldersState>(
          builder: (context, state) {
            List<Folder> folders = [];
            if (state is FoldersLoaded) {
              folders = state.folders;
            }

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

                    // Başlık
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        l10n.selectFolder,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Klasörden Çıkar
                    if (note.folderId != null)
                      ListTile(
                        leading: Icon(
                          CupertinoIcons.folder_badge_minus,
                          color: AppColors.warning,
                        ),
                        title: Text(l10n.removeFromFolder),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          context.read<NotesBloc>().add(
                            UpdateNoteFolder(note.id, null),
                          );
                        },
                      ),

                    // Klasör listesi
                    if (folders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              CupertinoIcons.folder,
                              size: 48,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.noFoldersYetCreateInSettings,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.createFolderInSettings,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: folders.length,
                          itemBuilder: (context, index) {
                            final folder = folders[index];
                            final isSelected = note.folderId == folder.id;
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(folder.color).withAlpha(30),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  CupertinoIcons.folder_fill,
                                  color: Color(folder.color),
                                ),
                              ),
                              title: Text(
                                folder.name.isNotEmpty
                                    ? folder.name
                                    : l10n.untitledFolder,
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      CupertinoIcons.checkmark_circle_fill,
                                      color: AppColors.primary,
                                    )
                                  : null,
                              onTap: () {
                                Navigator.pop(sheetContext);
                                context.read<NotesBloc>().add(
                                  UpdateNoteFolder(note.id, folder.id),
                                );
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Silme onay dialogu
  void _showDeleteConfirmDialog(BuildContext context, Note note) {
    final l10n = AppLocalizations.of(context)!;

    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(l10n.deleteNote),
        content: Text(
          note.title.isNotEmpty
              ? l10n.deleteNoteConfirm(note.title)
              : l10n.deleteNoteConfirmUntitled,
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(l10n.delete),
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
