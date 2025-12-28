import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';
import 'note_editor_page.dart';

/// Graf görünümü sayfası
///
/// Notları node şeklinde görselleştirir.
/// İleride notlar arası bağlantılar eklenebilir.
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
      duration: const Duration(milliseconds: 800),
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
    final isDark = context.watch<ThemeCubit>().isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Graf Görünümü'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_counterclockwise),
            tooltip: 'Sıfırla',
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
                      CupertinoIcons.graph_circle,
                      size: 80,
                      color:
                          (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary)
                              .withAlpha(100),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Henüz not yok',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Not ekleyerek graf görünümünü kullanın',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 3.0,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              child: Center(
                child: CustomPaint(
                  painter: _GraphPainter(notes: state.notes, isDark: isDark),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 200,
                    child: Stack(
                      children: _buildNodes(context, state.notes, isDark),
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<Widget> _buildNodes(
    BuildContext context,
    List<Note> notes,
    bool isDark,
  ) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height - 200;
    final centerX = width / 2;
    final centerY = height / 2;

    // Node pozisyonlarını hesapla (dairesel yerleşim)
    final nodes = <Widget>[];
    final nodeCount = notes.length;
    final radius = math.min(width, height) * 0.35;

    for (int i = 0; i < nodeCount; i++) {
      final note = notes[i];
      final angle = (2 * math.pi * i / nodeCount) - (math.pi / 2);
      final x = centerX + radius * math.cos(angle) - 40;
      final y = centerY + radius * math.sin(angle) - 40;

      nodes.add(
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final animation = CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                i / nodeCount * 0.5,
                0.5 + i / nodeCount * 0.5,
                curve: Curves.elasticOut,
              ),
            );

            return Positioned(
              left: x,
              top: y,
              child: Transform.scale(scale: animation.value, child: child),
            );
          },
          child: _GraphNode(
            note: note,
            color: AppColors.nodeColors[i % AppColors.nodeColors.length],
            isDark: isDark,
            onTap: () => _navigateToEditor(context, note),
          ),
        ),
      );
    }

    return nodes;
  }

  void _navigateToEditor(BuildContext context, Note note) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => NoteEditorPage(note: note)),
    );
  }
}

/// Graf node widget'ı
class _GraphNode extends StatelessWidget {
  final Note note;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _GraphNode({
    required this.note,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withAlpha(200)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(80),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.doc_text_fill, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                note.title.isEmpty ? 'Boş not' : note.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Graf çizgileri için painter
class _GraphPainter extends CustomPainter {
  final List<Note> notes;
  final bool isDark;

  _GraphPainter({required this.notes, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // İleride notlar arası bağlantılar burada çizilecek
    // Şu an için sadece merkez noktası çiziliyor

    if (notes.isEmpty) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final paint = Paint()
      ..color = (isDark ? AppColors.darkBorder : AppColors.lightBorder)
          .withAlpha(100)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final nodeCount = notes.length;
    final radius = math.min(size.width, size.height) * 0.35;

    // Her node'dan merkeze çizgi
    for (int i = 0; i < nodeCount; i++) {
      final angle = (2 * math.pi * i / nodeCount) - (math.pi / 2);
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      canvas.drawLine(Offset(centerX, centerY), Offset(x, y), paint);
    }

    // Merkez nokta
    final centerPaint = Paint()
      ..color = AppColors.primary.withAlpha(100)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), 8, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.notes != notes || oldDelegate.isDark != isDark;
  }
}
