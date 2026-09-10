import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/navigation/logout.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/language_switch.dart';
import '../../../../core/widgets/list_row.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../widgets/change_password_sheet.dart';

/// Settings sub-page: profile edit, dark mode + currency preferences,
/// change password, app version, logout. Per APP_CONTEXT.md's "Spec:
/// More Sub-Pages" (no reference screenshot for this one).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<ProfileCubit>()),
        BlocProvider.value(value: getIt<SettingsCubit>()),
      ],
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _currencyController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileCubit>().state;
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _currencyController = TextEditingController(
      text: context.read<SettingsCubit>().state.currencySymbol,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _showSavedSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty || email.isEmpty) return;
    context.read<ProfileCubit>().update(name: name, email: email);
    _showSavedSnackBar('settings.profileUpdated'.tr());
  }

  void _saveCurrencySymbol() {
    context.read<SettingsCubit>().updateCurrencySymbol(
      _currencyController.text,
    );
    _showSavedSnackBar('settings.currencyUpdated'.tr());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ).copyWith(top: AppSpacing.md, bottom: AppSpacing.xl),
          children: [
            AppTopBar(
              title: 'settings.title'.tr(),
              showBack: true,
              isDarkMode: Theme.of(context).brightness == Brightness.dark,
              onThemeToggle: () => context.read<ThemeCubit>().toggle(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'settings.profileSectionTitle'.tr(),
              style: AppTextStyles.overline(colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: BlocBuilder<ProfileCubit, Profile>(
                      builder: (context, profile) => Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colors.background,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.border),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _initialsFor(profile.name),
                          style: AppTextStyles.pageTitle(colors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'settings.name'.tr(),
                    style: AppTextStyles.body(colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _nameController,
                    style: AppTextStyles.cardTitle(colors.textPrimary),
                    decoration: _fieldDecoration(colors),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'settings.email'.tr(),
                    style: AppTextStyles.body(colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.cardTitle(colors.textPrimary),
                    decoration: _fieldDecoration(colors),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _saveProfile,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(color: colors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.button),
                        ),
                      ),
                      child: Text(
                        'settings.saveChanges'.tr(),
                        style: AppTextStyles.cardTitle(colors.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'settings.appPreferencesSectionTitle'.tr(),
              style: AppTextStyles.overline(colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SectionCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'settings.darkMode'.tr(),
                        style: AppTextStyles.cardTitle(colors.textPrimary),
                      ),
                      BlocBuilder<ThemeCubit, ThemeMode>(
                        builder: (context, mode) => Switch(
                          value: mode == ThemeMode.dark,
                          onChanged: (_) => context.read<ThemeCubit>().toggle(),
                          activeTrackColor: colors.primaryAction,
                          thumbColor: WidgetStateProperty.all(
                            colors.onPrimaryAction,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(height: 1, color: colors.border),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'settings.language'.tr(),
                        style: AppTextStyles.cardTitle(colors.textPrimary),
                      ),
                      const LanguageSwitch(),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(height: 1, color: colors.border),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'settings.currencySymbol'.tr(),
                    style: AppTextStyles.cardTitle(colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _currencyController,
                          style: AppTextStyles.cardTitle(colors.textPrimary),
                          decoration: _fieldDecoration(colors),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      OutlinedButton(
                        onPressed: _saveCurrencySymbol,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadii.button,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'settings.save'.tr(),
                          style: AppTextStyles.body(colors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'settings.accountSectionTitle'.tr(),
              style: AppTextStyles.overline(colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SectionCard(
              padding: EdgeInsets.zero,
              child: ListRow(
                icon: Icons.lock_outline_rounded,
                title: 'settings.changePassword'.tr(),
                onTap: () => ChangePasswordSheet.show(context),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                '${AppConstants.appName} ${AppConstants.appVersion}',
                style: AppTextStyles.body(colors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => confirmLogout(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.danger,
                  side: BorderSide(color: colors.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.button),
                  ),
                ),
                child: Text(
                  'settings.logout'.tr(),
                  style: AppTextStyles.cardTitle(colors.danger),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(AppColors colors) {
    return InputDecoration(
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.button),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.button),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.button),
        borderSide: BorderSide(color: colors.primaryAction, width: 1.5),
      ),
    );
  }

  String _initialsFor(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words[1].substring(0, 1))
        .toUpperCase();
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colors.border),
      ),
      child: child,
    );
  }
}
