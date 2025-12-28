import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';

/// Not düzenleme sayfası
///
/// AppFlowy Editor ile zengin metin düzenleme.
/// Otomatik kaydetme özelliği.
class NoteEditorPage extends StatefulWidget {
  final Note note;

  const NoteEditorPage({super.key, required this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late EditorState _editorState;
  late EditorScrollController _scrollController;

  Timer? _debounceTimer;
  bool _hasChanges = false;
  List<String> _images = [];

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _images = List.from(widget.note.images);

    // Editor state'i başlat
    _editorState = _createEditorState();
    _scrollController = EditorScrollController(
      editorState: _editorState,
      shrinkWrap: false,
    );

    // Değişiklikleri dinle
    _titleController.addListener(_onContentChanged);
    _editorState.transactionStream.listen((_) => _onContentChanged());
  }

  EditorState _createEditorState() {
    if (widget.note.content.isEmpty) {
      return EditorState.blank();
    }

    try {
      final json = jsonDecode(widget.note.content);
      if (json is Map<String, dynamic>) {
        final document = Document.fromJson(json);
        return EditorState(document: document);
      }
    } catch (e) {
      debugPrint('JSON parse hatası: $e');
    }

    return EditorState.blank();
  }

  @override
  void dispose() {
    _saveNote(); // Son değişiklikleri kaydet
    _debounceTimer?.cancel();
    _titleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    _hasChanges = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppConstants.autoSaveDebounce, _saveNote);
  }

  void _saveNote() {
    if (!_hasChanges) return;

    final content = jsonEncode(_editorState.document.toJson());
    final updatedNote = widget.note.copyWith(
      title: _titleController.text,
      content: content,
      updatedAt: DateTime.now(),
      images: _images,
    );

    context.read<NotesBloc>().add(UpdateNote(updatedNote));
    _hasChanges = false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDark;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _saveNote();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () {
              _saveNote();
              Navigator.of(context).pop();
            },
          ),
          title: const Text('Not Düzenle'),
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.photo),
              tooltip: 'Fotoğraf Ekle',
              onPressed: _pickImage,
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.checkmark),
              tooltip: 'Kaydet',
              onPressed: () {
                _saveNote();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Not kaydedildi'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Başlık alanı
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _titleController,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Başlık',
                  hintStyle: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
              ),
            ),

            // Görsel ekleri göster
            if (_images.isNotEmpty) _buildImagesSection(isDark),

            const Divider(height: 1),

            // Editor
            Expanded(child: _buildEditor(isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection(bool isDark) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          final imagePath = _images[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagePath),
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          CupertinoIcons.photo,
                          color: AppColors.lightTextSecondary,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.xmark,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditor(bool isDark) {
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    // AppFlowy Editor tema ayarları
    final editorStyle = EditorStyle(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primary.withAlpha(60),
      dragHandleColor: AppColors.primary,
      textStyleConfiguration: TextStyleConfiguration(
        text: TextStyle(fontSize: 16, color: textColor, height: 1.6),
      ),
      textSpanDecorator: (context, node, index, text, textSpan, previousSpan) {
        return textSpan;
      },
    );

    return AppFlowyEditor(
      editorState: _editorState,
      editorScrollController: _scrollController,
      editorStyle: editorStyle,
      header: const SizedBox(height: 8),
      footer: const SizedBox(height: 100),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Dosyayı uygulama dizinine kopyala
        final appDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${appDir.path}/note_images');
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }

        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${p.basename(pickedFile.path)}';
        final newPath = '${imagesDir.path}/$fileName';

        await File(pickedFile.path).copy(newPath);

        setState(() {
          _images.add(newPath);
        });
        _onContentChanged();
      }
    } catch (e) {
      debugPrint('Görsel seçme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görsel eklenirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    _onContentChanged();
  }
}
