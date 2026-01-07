import 'package:epheproject/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';
import 'note_editor_page.dart';

/// Graf görünümü sayfası - Soy Ağacı Tasarımı
///
/// Notları tarihe göre sıralı şekilde dikey bir soy ağacı yapısında görselleştirir.
/// En yeni not en yukarıda, en eski not en aşağıda konumlanır.
class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = context.watch<ThemeCubit>().isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.familyTreeView),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_counterclockwise),
            tooltip: l10n.reset,
            onPressed: () {
              _transformationController.value = Matrix4.identity();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (state is NotesLoaded) {
            if (state.notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.tree,
                      size: 80,
                      color:
                          (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary)
                              .withAlpha(100),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.noNotesYet,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.addNoteToUseFamilyTree,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            // Notları tarihe göre sırala (en yeni en yukarıda)
            final sortedNotes = List<Note>.from(state.notes)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.3,
              maxScale: 3.0,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              constrained: false,
              child: _FamilyTreeView(
                notes: sortedNotes,
                isDark: isDark,
                animationController: _animationController,
                onNoteTap: (note) => _navigateToEditor(context, note),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _navigateToEditor(BuildContext context, Note note) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => NoteEditorPage(note: note)),
    );
  }
}

/// Soy ağacı görünümü widget'ı
class _FamilyTreeView extends StatelessWidget {
  final List<Note> notes;
  final bool isDark;
  final AnimationController animationController;
  final Function(Note) onNoteTap;

  const _FamilyTreeView({
    required this.notes,
    required this.isDark,
    required this.animationController,
    required this.onNoteTap,
  });

  // Düğüm boyutları ve aralıkları
  static const double nodeWidth = 160.0;
  static const double nodeHeight = 100.0;
  static const double verticalSpacing = 80.0;
  static const double horizontalPadding = 40.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalHeight =
        notes.length * (nodeHeight + verticalSpacing) + verticalSpacing + 100;
    final totalWidth = nodeWidth + horizontalPadding * 2 + 100;

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: CustomPaint(
        painter: _FamilyTreePainter(
          notes: notes,
          isDark: isDark,
          nodeWidth: nodeWidth,
          nodeHeight: nodeHeight,
          verticalSpacing: verticalSpacing,
          horizontalPadding: horizontalPadding,
        ),
        child: Stack(children: _buildTreeNodes(context, l10n)),
      ),
    );
  }

  List<Widget> _buildTreeNodes(BuildContext context, AppLocalizations l10n) {
    final nodes = <Widget>[];
    final nodeCount = notes.length;

    for (int i = 0; i < nodeCount; i++) {
      final note = notes[i];
      final y = verticalSpacing + i * (nodeHeight + verticalSpacing);
      final x = horizontalPadding + 50;

      nodes.add(
        AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            final delay = i / nodeCount * 0.6;
            // Scale için easeOutBack kullan (overshoot destekler)
            final scaleAnimation = CurvedAnimation(
              parent: animationController,
              curve: Interval(delay, delay + 0.4, curve: Curves.easeOutBack),
            );
            // Opacity için easeOut kullan (0-1 arasında kalır)
            final opacityAnimation = CurvedAnimation(
              parent: animationController,
              curve: Interval(delay, delay + 0.3, curve: Curves.easeOut),
            );

            return Positioned(
              left: x,
              top: y,
              child: Transform.scale(
                scale: scaleAnimation.value,
                child: Opacity(
                  opacity: opacityAnimation.value.clamp(0.0, 1.0),
                  child: child,
                ),
              ),
            );
          },
          child: _FamilyTreeNode(
            note: note,
            index: i,
            totalCount: nodeCount,
            isDark: isDark,
            emptyNoteLabel: l10n.emptyNote,
            isNewest: i == 0,
            isOldest: i == nodeCount - 1,
            onTap: () => onNoteTap(note),
          ),
        ),
      );
    }

    return nodes;
  }
}

/// Soy ağacı düğümü widget'ı
class _FamilyTreeNode extends StatelessWidget {
  final Note note;
  final int index;
  final int totalCount;
  final bool isDark;
  final String emptyNoteLabel;
  final bool isNewest;
  final bool isOldest;
  final VoidCallback onTap;

  const _FamilyTreeNode({
    required this.note,
    required this.index,
    required this.totalCount,
    required this.isDark,
    required this.emptyNoteLabel,
    required this.isNewest,
    required this.isOldest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.nodeColors[index % AppColors.nodeColors.length];
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _FamilyTreeView.nodeWidth,
        height: _FamilyTreeView.nodeHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withAlpha(180)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(60),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withAlpha(30),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
          border: isNewest
              ? Border.all(color: Colors.white.withAlpha(100), width: 2)
              : null,
        ),
        child: Stack(
          children: [
            // Düğüm içeriği
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık ve ikon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.doc_text_fill,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note.title.isEmpty ? emptyNoteLabel : note.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Tarih
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.time,
                        color: Colors.white.withAlpha(180),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(note.createdAt),
                        style: TextStyle(
                          color: Colors.white.withAlpha(180),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // En yeni veya en eski etiketi
            if (isNewest || isOldest)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isNewest
                        ? Colors.green.withAlpha(200)
                        : Colors.orange.withAlpha(200),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    isNewest ? l10n.newest : l10n.oldest,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Soy ağacı bağlantı çizgileri için painter
class _FamilyTreePainter extends CustomPainter {
  final List<Note> notes;
  final bool isDark;
  final double nodeWidth;
  final double nodeHeight;
  final double verticalSpacing;
  final double horizontalPadding;

  _FamilyTreePainter({
    required this.notes,
    required this.isDark,
    required this.nodeWidth,
    required this.nodeHeight,
    required this.verticalSpacing,
    required this.horizontalPadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (notes.isEmpty || notes.length < 2) return;

    // Ana bağlantı çizgisi için paint
    final linePaint = Paint()
      ..color = (isDark
          ? AppColors.primary.withAlpha(150)
          : AppColors.primary.withAlpha(120))
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Noktalı efekt için paint
    final dotPaint = Paint()
      ..color = AppColors.primary.withAlpha(100)
      ..style = PaintingStyle.fill;

    // Glow efekti paint
    final glowPaint = Paint()
      ..color = AppColors.primary.withAlpha(30)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = horizontalPadding + 50 + nodeWidth / 2;

    // Her düğüm arasına dikey bağlantı çizgisi çiz
    for (int i = 0; i < notes.length - 1; i++) {
      final y1 =
          verticalSpacing + i * (nodeHeight + verticalSpacing) + nodeHeight;
      final y2 = verticalSpacing + (i + 1) * (nodeHeight + verticalSpacing);

      // Glow efekti
      canvas.drawLine(Offset(centerX, y1), Offset(centerX, y2), glowPaint);

      // Ana çizgi
      canvas.drawLine(Offset(centerX, y1), Offset(centerX, y2), linePaint);

      // Ara noktalar (bağlantı noktaları)
      final midY = (y1 + y2) / 2;
      canvas.drawCircle(Offset(centerX, midY), 4, dotPaint);
    }

    // Düğüm bağlantı noktaları (üst ve alt)
    for (int i = 0; i < notes.length; i++) {
      final y = verticalSpacing + i * (nodeHeight + verticalSpacing);

      // Üst bağlantı noktası (ilk düğüm hariç)
      if (i > 0) {
        canvas.drawCircle(
          Offset(centerX, y),
          5,
          Paint()
            ..color = AppColors.primary
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          Offset(centerX, y),
          8,
          Paint()
            ..color = AppColors.primary.withAlpha(50)
            ..style = PaintingStyle.fill,
        );
      }

      // Alt bağlantı noktası (son düğüm hariç)
      if (i < notes.length - 1) {
        final bottomY = y + nodeHeight;
        canvas.drawCircle(
          Offset(centerX, bottomY),
          5,
          Paint()
            ..color = AppColors.primary
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          Offset(centerX, bottomY),
          8,
          Paint()
            ..color = AppColors.primary.withAlpha(50)
            ..style = PaintingStyle.fill,
        );
      }
    }

    // Başlangıç noktası (en yeni not için özel gösterge)
    if (notes.isNotEmpty) {
      final topY = verticalSpacing - 20;

      // Yukarı ok göstergesi
      final arrowPaint = Paint()
        ..color = Colors.green.withAlpha(200)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path()
        ..moveTo(centerX, topY)
        ..lineTo(centerX - 8, topY + 10)
        ..moveTo(centerX, topY)
        ..lineTo(centerX + 8, topY + 10);

      canvas.drawPath(path, arrowPaint);
      canvas.drawLine(
        Offset(centerX, topY),
        Offset(centerX, topY + 20),
        arrowPaint,
      );
    }

    // Bitiş noktası (en eski not için özel gösterge)
    if (notes.length > 1) {
      final bottomY =
          verticalSpacing +
          (notes.length - 1) * (nodeHeight + verticalSpacing) +
          nodeHeight +
          20;

      // Aşağı ok göstergesi
      final arrowPaint = Paint()
        ..color = Colors.orange.withAlpha(200)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(centerX, bottomY - 20),
        Offset(centerX, bottomY),
        arrowPaint,
      );

      final path = Path()
        ..moveTo(centerX, bottomY)
        ..lineTo(centerX - 8, bottomY - 10)
        ..moveTo(centerX, bottomY)
        ..lineTo(centerX + 8, bottomY - 10);

      canvas.drawPath(path, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FamilyTreePainter oldDelegate) {
    return oldDelegate.notes != notes || oldDelegate.isDark != isDark;
  }
}
