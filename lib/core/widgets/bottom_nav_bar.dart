import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum AppNavTab { home, companies, newSale, customers, more }

/// Fixed bottom nav with 5 items. "New Sale" is visually distinct — an
/// elevated filled circle with a + icon. See design/DESIGN_SYSTEM.md.
class BottomNavBar extends StatelessWidget {
  final AppNavTab current;
  final ValueChanged<AppNavTab> onTabSelected;

  const BottomNavBar({super.key, required this.current, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'nav.home'.tr(),
              isActive: current == AppNavTab.home,
              onTap: () => onTabSelected(AppNavTab.home),
            ),
            _NavItem(
              icon: Icons.apartment_rounded,
              label: 'nav.companies'.tr(),
              isActive: current == AppNavTab.companies,
              onTap: () => onTabSelected(AppNavTab.companies),
            ),
            _NewSaleNavItem(
              isActive: current == AppNavTab.newSale,
              onTap: () => onTabSelected(AppNavTab.newSale),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'nav.customers'.tr(),
              isActive: current == AppNavTab.customers,
              onTap: () => onTabSelected(AppNavTab.customers),
            ),
            _NavItem(
              icon: Icons.menu_rounded,
              label: 'nav.more'.tr(),
              isActive: current == AppNavTab.more,
              onTap: () => onTabSelected(AppNavTab.more),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isActive ? colors.textPrimary : colors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.badge(color)),
          ],
        ),
      ),
    );
  }
}

class _NewSaleNavItem extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _NewSaleNavItem({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0, -14),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.primaryAction,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.primaryAction.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.add_rounded, color: colors.onPrimaryAction, size: 26),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -8),
            child: Text('nav.newSale'.tr(), style: AppTextStyles.badge(colors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
