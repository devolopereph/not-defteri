import 'package:epheproject/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/folder.dart';
import '../bloc/folders_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../widgets/empty_state.dart';
import 'folder_notes_page.dart';
import 'folder_editor_page.dart';

/// Klasörler sayfası
class FoldersPage extends StatefulWidget {
  const FoldersPage({super.key});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    context.read<FoldersBloc>().add(const LoadFolders());
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
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField(isDark, l10n)
            : Text(l10n.folders),
        actions: [
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
                  context.read<FoldersBloc>().add(const RefreshFolders());
                }
              });
            },
          ),
        ],
      ),
      body: BlocListener<NotesBloc, NotesState>(
        listener: (context, state) {
          // Notlar değiştiğinde klasörleri yenile (not sayılarını güncellemek için)
          if (state is NotesLoaded) {
            context.read<FoldersBloc>().add(const RefreshFolders());
          }
        },
        child: BlocBuilder<FoldersBloc, FoldersState>(
          builder: (context, state) {
            if (state is FoldersLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (state is FoldersError) {
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
                        context.read<FoldersBloc>().add(const LoadFolders());
                      },
                      icon: const Icon(CupertinoIcons.refresh),
                      label: Text(l10n.tryAgain),
                    ),
                  ],
                ),
              );
            }

            if (state is FoldersLoaded) {
              if (state.folders.isEmpty) {
                return EmptyState(
                  icon: CupertinoIcons.folder,
                  title:
                      state.searchQuery != null && state.searchQuery!.isNotEmpty
                      ? l10n.noResults
                      : l10n.noFoldersYet,
                  subtitle:
                      state.searchQuery != null && state.searchQuery!.isNotEmpty
                      ? l10n.noResultsFor(state.searchQuery!)
                      : l10n.tapToCreateFolder,
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FoldersBloc>().add(const RefreshFolders());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.folders.length,
                  itemBuilder: (context, index) {
                    final folder = state.folders[index];
                    final noteCount = state.folderNoteCounts[folder] ?? 0;
                    return _FolderCard(
                      folder: folder,
                      noteCount: noteCount,
                      onTap: () => _navigateToFolderNotes(context, folder),
                      onLongPress: () =>
                          _showFolderOptionsSheet(context, folder),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'folders_fab',
        onPressed: () => _navigateToCreateFolder(context),
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }

  Widget _buildSearchField(bool isDark, AppLocalizations l10n) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: l10n.searchFolders,
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
        context.read<FoldersBloc>().add(SearchFolders(query));
      },
    );
  }

  void _navigateToFolderNotes(BuildContext context, Folder folder) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => FolderNotesPage(folder: folder)),
    );
  }

  /// Klasör seçenekleri bottom sheet
  void _showFolderOptionsSheet(BuildContext context, Folder folder) {
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

                // Klasör adı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          folder.name.isNotEmpty
                              ? folder.name
                              : l10n.untitledFolder,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Düzenle
                ListTile(
                  leading: Icon(
                    CupertinoIcons.pencil,
                    color: AppColors.primary,
                  ),
                  title: Text(l10n.edit),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showEditFolderDialog(context, folder);
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
                    _showDeleteConfirmDialog(context, folder);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Yeni klasör oluşturma sayfasına git
  void _navigateToCreateFolder(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(builder: (context) => const FolderEditorPage()),
    );

    // Eğer klasör oluşturulduysa listeyi yenile
    if (result == true && mounted) {
      if (!context.mounted) return;
      context.read<FoldersBloc>().add(const RefreshFolders());
    }
  }

  /// Klasör düzenle dialog
  void _showEditFolderDialog(BuildContext context, Folder folder) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: folder.name);
    int selectedColor = folder.color;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.editFolder),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.folderName,
                  hintText: l10n.enterFolderName,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${l10n.selectColor}:',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _folderColors.map((color) {
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(color),
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(color).withAlpha(150),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              CupertinoIcons.checkmark,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  context.read<FoldersBloc>().add(
                    UpdateFolder(
                      folder.copyWith(
                        name: nameController.text.trim(),
                        color: selectedColor,
                      ),
                    ),
                  );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  /// Silme onay dialogu
  void _showDeleteConfirmDialog(BuildContext context, Folder folder) {
    final l10n = AppLocalizations.of(context)!;

    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(l10n.deleteFolder),
        content: Text(
          folder.name.isNotEmpty
              ? l10n.deleteFolderConfirm(folder.name)
              : l10n.deleteFolderConfirmUntitled,
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
              context.read<FoldersBloc>().add(DeleteFolder(folder.id));
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }

  // Klasör renkleri
  static const List<int> _folderColors = [
    0xFF6C63FF, // Primary
    0xFFFF6B6B, // Kırmızı
    0xFF4ECDC4, // Turkuaz
    0xFFFFE66D, // Sarı
    0xFF95E1D3, // Yeşil
    0xFFDDA0DD, // Mor
    0xFFFF8C42, // Turuncu
    0xFF6BCB77, // Açık yeşil
    0xFF4D96FF, // Mavi
    0xFFFF69B4, // Pembe
  ];
}

/// Klasör kartı
class _FolderCard extends StatelessWidget {
  final Folder folder;
  final int noteCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _FolderCard({
    required this.folder,
    required this.noteCount,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = context.watch<ThemeCubit>().isDark;
    final folderColor = Color(folder.color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 20 : 10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Klasör ikonu
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: folderColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.folder_fill,
                    color: folderColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Klasör bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.name.isNotEmpty
                            ? folder.name
                            : l10n.untitledFolder,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.noteCount(noteCount),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Ok ikonu
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 20,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
