import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/note.dart';

/// Not kartı widget'ı
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isGridView;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDark;
    final preview = note.contentPreview;

    return Padding(
      padding: EdgeInsets.only(bottom: isGridView ? 0 : 12),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: note.isPinned
                  ? AppColors.primary.withAlpha(100)
                  : (isDark ? Colors.transparent : AppColors.lightBorder),
              width: note.isPinned ? 2 : 1,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isGridView
                ? _buildGridContent(context, isDark, preview)
                : _buildListContent(context, isDark, preview),
          ),
        ),
      ),
    );
  }

  /// Grid görünümü için içerik
  Widget _buildGridContent(BuildContext context, bool isDark, String preview) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pin ikonu ve başlık
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                note.title.isNotEmpty ? note.title : 'Başlıksız not',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (note.isPinned) ...[
              const SizedBox(width: 4),
              Icon(CupertinoIcons.pin_fill, size: 14, color: AppColors.primary),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (preview.isNotEmpty) ...[
          Expanded(
            child: Text(
              preview,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                height: 1.4,
              ),
              maxLines: 8,
              overflow: TextOverflow.fade,
            ),
          ),
        ] else
          const Spacer(),

        const SizedBox(height: 12),
        // Alt bilgi
        Row(
          children: [
            Text(
              _formatDate(note.updatedAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextSecondary.withAlpha(150)
                    : AppColors.lightTextSecondary.withAlpha(150),
              ),
            ),
            const Spacer(),
            if (note.images.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.photo,
                      size: 10,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${note.images.length}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Liste görünümü için içerik
  Widget _buildListContent(BuildContext context, bool isDark, String preview) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve önizleme
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.title.isNotEmpty ? note.title : 'Başlıksız not',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (note.isPinned) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.pin_fill,
                            size: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (preview.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      preview,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Görsel göstergesi (Large thumbnail if list view?)
            // Keeping it simple for now to match requested "clean" style
            if (note.images.isNotEmpty) ...[
              const SizedBox(width: 16),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                  image: note.images.isNotEmpty
                      ? null // TODO: Add actual image preview here if path is valid
                      : null,
                ),
                // Placeholder for now, simplified
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.photo,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      Text(
                        '${note.images.length}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 12),

        // Alt bilgi
        Row(
          children: [
            Text(
              _formatDate(note.updatedAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary.withAlpha(150)
                    : AppColors.lightTextSecondary.withAlpha(150),
                fontSize: 12,
              ),
            ),
            if (note.folderId != null) ...[
              // Assuming we can't get folder name easily here without passing it, leaving placeholder logic or simplicity
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              // Since Note entity only has folderId, we can't show folder name easily in card without join or passed data.
              // Keeping it simple.
            ],
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    // Daha modern tarih formatı
    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}d önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}sa önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}
