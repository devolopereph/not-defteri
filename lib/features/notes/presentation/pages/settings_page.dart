import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';

/// Ayarlar sayfası
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDark;
    final themeCubit = context.read<ThemeCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tema ayarları bölümü
          _buildSectionTitle(context, 'Görünüm'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            isDark,
            children: [
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.moon_fill,
                iconColor: AppColors.primary,
                title: 'Karanlık Tema',
                subtitle: 'Karanlık tema kullan',
                trailing: CupertinoSwitch(
                  value: isDark,
                  activeTrackColor: AppColors.primary,
                  onChanged: (_) => themeCubit.toggleTheme(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Hakkında bölümü
          _buildSectionTitle(context, 'Hakkında'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            isDark,
            children: [
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.info_circle_fill,
                iconColor: AppColors.info,
                title: 'Sürüm',
                subtitle: '1.0.0',
              ),
              _buildDivider(isDark),
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.heart_fill,
                iconColor: AppColors.accent,
                title: 'Stitch Notes',
                subtitle: 'Zengin metin destekli not uygulaması',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // İpuçları bölümü
          _buildSectionTitle(context, 'İpuçları'),
          const SizedBox(height: 12),
          _buildTipsCard(context, isDark),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    bool isDark, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 72,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }

  Widget _buildTipsCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withAlpha(40),
            AppColors.accent.withAlpha(40),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.lightbulb_fill,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Kullanım İpuçları',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem(
            context,
            '✨ Zengin metin düzenleme için araç çubuğunu kullanın',
          ),
          _buildTipItem(context, '📸 Notlarınıza fotoğraf ekleyebilirsiniz'),
          _buildTipItem(
            context,
            '📊 Graf görünümünde notlarınızı görselleştirin',
          ),
          _buildTipItem(
            context,
            '🔍 Arama özelliği ile notlarınızı hızlıca bulun',
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
