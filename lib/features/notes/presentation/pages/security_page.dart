import 'package:epheproject/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/security/security_cubit.dart';

/// Güvenlik ayarları sayfası
class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = context.watch<ThemeCubit>().isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.security),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<SecurityCubit, SecurityState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Güvenlik açıklaması
              _buildInfoCard(context, isDark, l10n),
              const SizedBox(height: 24),

              // Şifre ayarları
              _buildSectionTitle(context, l10n.pinSettings),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context,
                isDark,
                children: [
                  if (state.hasPin) ...[
                    // Şifre koruma açık/kapalı
                    _buildSettingsItem(
                      context,
                      icon: CupertinoIcons.lock_shield_fill,
                      iconColor: AppColors.primary,
                      title: l10n.pinLock,
                      subtitle: l10n.pinLockDescription,
                      trailing: CupertinoSwitch(
                        value: state.isEnabled,
                        activeTrackColor: AppColors.primary,
                        onChanged: (value) {
                          context.read<SecurityCubit>().toggleSecurity(value);
                        },
                      ),
                    ),
                    _buildDivider(isDark),
                    // Şifre değiştir
                    _buildSettingsItem(
                      context,
                      icon: CupertinoIcons.pencil_circle_fill,
                      iconColor: AppColors.warning,
                      title: l10n.changePin,
                      subtitle: l10n.changePinDescription,
                      trailing: const Icon(
                        CupertinoIcons.chevron_right,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onTap: () => _showChangePinDialog(context),
                    ),
                    _buildDivider(isDark),
                    // Şifreyi kaldır
                    _buildSettingsItem(
                      context,
                      icon: CupertinoIcons.trash_circle_fill,
                      iconColor: AppColors.error,
                      title: l10n.removePin,
                      subtitle: l10n.removePinDescription,
                      trailing: const Icon(
                        CupertinoIcons.chevron_right,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onTap: () => _showRemovePinDialog(context),
                    ),
                  ] else ...[
                    // Şifre oluştur
                    _buildSettingsItem(
                      context,
                      icon: CupertinoIcons.lock_circle_fill,
                      iconColor: AppColors.primary,
                      title: l10n.createPin,
                      subtitle: l10n.createPinDescription,
                      trailing: const Icon(
                        CupertinoIcons.chevron_right,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onTap: () => _showCreatePinDialog(context),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.shield_lefthalf_fill,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.securityInfo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.securityInfoDescription,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 72,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
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
      ),
    );
  }

  /// Şifre oluşturma dialog
  void _showCreatePinDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PinInputSheet(
        title: l10n.createPin,
        subtitle: l10n.enterNewPin,
        onComplete: (pin) async {
          Navigator.pop(sheetContext);
          // Şifreyi onayla
          await Future.delayed(const Duration(milliseconds: 200));
          if (mounted) {
            _showConfirmPinDialog(context, pin);
          }
        },
      ),
    );
  }

  /// Şifre onaylama dialog
  void _showConfirmPinDialog(BuildContext context, String originalPin) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PinInputSheet(
        title: l10n.confirmPin,
        subtitle: l10n.reenterPin,
        onComplete: (pin) {
          if (pin == originalPin) {
            context.read<SecurityCubit>().createPin(pin);
            Navigator.pop(sheetContext);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.pinCreated),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else {
            Navigator.pop(sheetContext);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.pinMismatch),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  /// Şifre değiştirme dialog
  void _showChangePinDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PinInputSheet(
        title: l10n.changePin,
        subtitle: l10n.enterCurrentPin,
        onComplete: (pin) {
          final securityCubit = context.read<SecurityCubit>();
          if (securityCubit.verifyPin(pin)) {
            Navigator.pop(sheetContext);
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                _showNewPinAfterVerifyDialog(context);
              }
            });
          } else {
            Navigator.pop(sheetContext);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.wrongPin),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  /// Doğrulama sonrası yeni şifre dialog
  void _showNewPinAfterVerifyDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PinInputSheet(
        title: l10n.newPin,
        subtitle: l10n.enterNewPin,
        onComplete: (pin) {
          Navigator.pop(sheetContext);
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              _showConfirmNewPinDialog(context, pin);
            }
          });
        },
      ),
    );
  }

  /// Yeni şifre onaylama dialog
  void _showConfirmNewPinDialog(BuildContext context, String originalPin) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PinInputSheet(
        title: l10n.confirmPin,
        subtitle: l10n.reenterPin,
        onComplete: (pin) async {
          if (pin == originalPin) {
            // Eski şifreyi al ve yenisiyle değiştir
            final storedPin = context.read<SecurityCubit>();
            await storedPin.createPin(pin);
            if (sheetContext.mounted) {
              Navigator.pop(sheetContext);
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.pinChanged),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          } else {
            Navigator.pop(sheetContext);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.pinMismatch),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  /// Şifre kaldırma dialog
  void _showRemovePinDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PinInputSheet(
        title: l10n.removePin,
        subtitle: l10n.enterCurrentPin,
        onComplete: (pin) async {
          final securityCubit = context.read<SecurityCubit>();
          if (securityCubit.verifyPin(pin)) {
            await securityCubit.removePin();
            if (sheetContext.mounted) {
              Navigator.pop(sheetContext);
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.pinRemoved),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          } else {
            Navigator.pop(sheetContext);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.wrongPin),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

/// PIN giriş bottom sheet
class _PinInputSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final Function(String) onComplete;

  const _PinInputSheet({
    required this.title,
    required this.subtitle,
    required this.onComplete,
  });

  @override
  State<_PinInputSheet> createState() => _PinInputSheetState();
}

class _PinInputSheetState extends State<_PinInputSheet> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDark;
    final l10n = AppLocalizations.of(context)!;

    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 2,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Üst çizgi
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Başlık
          Text(
            widget.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // PIN girişi
          Pinput(
            length: 4,
            controller: _pinController,
            focusNode: _focusNode,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            obscureText: true,
            obscuringCharacter: '●',
            onCompleted: widget.onComplete,
            hapticFeedbackType: HapticFeedbackType.lightImpact,
          ),
          const SizedBox(height: 24),

          // İptal butonu
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
