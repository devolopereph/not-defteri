import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';
import '../widgets/empty_state.dart';

/// Çöp kutusu sayfası
class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  @override
  void initState() {
    super.initState();
    // Silinen notları yükle
    context.read<NotesBloc>().add(const LoadDeletedNotes());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDark;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Çöp kutusundan çıkarken notları yeniden yükle
          context.read<NotesBloc>().add(const LoadNotes());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Çöp Kutusu'),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () {
              context.read<NotesBloc>().add(const LoadNotes());
              Navigator.of(context).pop();
            },
          ),
          actions: [
            BlocBuilder<NotesBloc, NotesState>(
              builder: (context, state) {
                if (state is TrashLoaded && state.deletedNotes.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(CupertinoIcons.trash),
                    tooltip: 'Çöp Kutusunu Boşalt',
                    onPressed: () => _showEmptyTrashDialog(context),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<NotesBloc, NotesState>(
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
                        context.read<NotesBloc>().add(const LoadDeletedNotes());
                      },
                      icon: const Icon(CupertinoIcons.refresh),
                      label: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            }

            if (state is TrashLoaded) {
              if (state.deletedNotes.isEmpty) {
                return const EmptyState(
                  icon: CupertinoIcons.trash,
                  title: 'Çöp kutusu boş',
                  subtitle: 'Silinen notlar burada görünecek',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.deletedNotes.length,
                itemBuilder: (context, index) {
                  final note = state.deletedNotes[index];
                  return _buildTrashNoteCard(context, note, isDark);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTrashNoteCard(BuildContext context, Note note, bool isDark) {
    final preview = note.contentPreview;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showNoteOptionsSheet(context, note),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.trash,
                      size: 16,
                      color: AppColors.error.withAlpha(150),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.title.isNotEmpty ? note.title : 'Başlıksız not',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    preview,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      size: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDeletedDate(note.deletedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDeletedDate(DateTime? date) {
    if (date == null) return 'Bilinmeyen tarih';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Az önce silindi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce silindi';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce silindi';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce silindi';
    } else {
      return '${date.day}.${date.month}.${date.year} tarihinde silindi';
    }
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

                // Geri Getir
                ListTile(
                  leading: Icon(
                    CupertinoIcons.arrow_counterclockwise,
                    color: AppColors.success,
                  ),
                  title: const Text('Geri Getir'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.read<NotesBloc>().add(
                      RestoreNoteFromTrash(note.id),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Not geri getirildi'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),

                // Kalıcı Olarak Sil
                ListTile(
                  leading: Icon(CupertinoIcons.delete, color: AppColors.error),
                  title: Text(
                    'Kalıcı Olarak Sil',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showPermanentDeleteDialog(context, note);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Kalıcı silme onay dialogu
  void _showPermanentDeleteDialog(BuildContext context, Note note) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Kalıcı Olarak Sil'),
        content: Text(
          note.title.isNotEmpty
              ? '"${note.title}" notunu kalıcı olarak silmek istediğinize emin misiniz?\n\nBu işlem geri alınamaz.'
              : 'Bu notu kalıcı olarak silmek istediğinize emin misiniz?\n\nBu işlem geri alınamaz.',
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

  /// Çöp kutusunu boşaltma dialogu
  void _showEmptyTrashDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Çöp Kutusunu Boşalt'),
        content: const Text(
          'Çöp kutusundaki tüm notları kalıcı olarak silmek istediğinize emin misiniz?\n\nBu işlem geri alınamaz.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Boşalt'),
            onPressed: () {
              context.read<NotesBloc>().add(const EmptyTrash());
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }
}
