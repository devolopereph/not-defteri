import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../bloc/folders_bloc.dart';

/// Klasör oluşturma/düzenleme sayfası
class FolderEditorPage extends StatefulWidget {
  final String? folderId;
  final String? initialName;
  final int? initialColor;

  const FolderEditorPage({
    super.key,
    this.folderId,
    this.initialName,
    this.initialColor,
  });

  @override
  State<FolderEditorPage> createState() => _FolderEditorPageState();
}

class _FolderEditorPageState extends State<FolderEditorPage> {
  late TextEditingController _nameController;
  late int _selectedColor;
  bool get _isEditing => widget.folderId != null;

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
    0xFF845EC2, // Koyu mor
    0xFFD65DB1, // Magenta
    0xFFFFC75F, // Altın
    0xFF00C9A7, // Teal
    0xFFC34A36, // Kiremit
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _selectedColor = widget.initialColor ?? _folderColors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveFolder() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen klasör adı girin'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isEditing) {
      // Düzenleme modunda FoldersBloc'u kullanarak güncelle
      // Bu durumda folders_page'den gelen folder objesini güncellemek gerekir
      // Şimdilik sadece yeni klasör oluşturma destekleniyor
    } else {
      context.read<FoldersBloc>().add(AddFolder(name, _selectedColor));
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Klasörü Düzenle' : 'Yeni Klasör'),
        actions: [
          TextButton(
            onPressed: _saveFolder,
            child: Text(
              'Kaydet',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Klasör önizleme
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(_selectedColor).withAlpha(30),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Color(_selectedColor).withAlpha(100),
                    width: 2,
                  ),
                ),
                child: Icon(
                  CupertinoIcons.folder_fill,
                  size: 50,
                  color: Color(_selectedColor),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Klasör adı
            Text(
              'Klasör Adı',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Klasör adını girin',
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurface
                    : AppColors.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                prefixIcon: Icon(
                  CupertinoIcons.folder,
                  color: Color(_selectedColor),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 32),

            // Renk seçimi
            Text(
              'Renk Seçin',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _buildColorGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildColorGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _folderColors.length,
      itemBuilder: (context, index) {
        final color = _folderColors[index];
        final isSelected = _selectedColor == color;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Color(color),
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color(color).withAlpha(150),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(
                    CupertinoIcons.checkmark,
                    color: Colors.white,
                    size: 24,
                  )
                : null,
          ),
        );
      },
    );
  }
}
