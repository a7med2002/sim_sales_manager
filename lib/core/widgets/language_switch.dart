import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// EN / AR segmented toggle — sets the app-wide locale directly via
/// easy_localization's `context.setLocale`, which also persists the choice
/// (shared_preferences, handled internally by the package) so it survives
/// app restarts without needing its own field on `AppSettings`. Shared
/// between Settings and the pre-login pages (Login/Forgot/Reset Password)
/// — a first-time user needs to be able to switch to Arabic before ever
/// signing in, not just after.
class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isArabic = context.locale.languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadii.button),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageOption(
            label: 'EN',
            isSelected: !isArabic,
            onTap: () => context.setLocale(const Locale('en')),
          ),
          _LanguageOption(
            label: 'AR',
            isSelected: isArabic,
            onTap: () => context.setLocale(const Locale('ar')),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryAction : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        child: Text(
          label,
          style: AppTextStyles.badge(
            isSelected ? colors.onPrimaryAction : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
