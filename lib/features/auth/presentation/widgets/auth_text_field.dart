import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Labeled text input used on the Login/Create account screens: small label
/// above a rounded outlined field, border darkens on focus.
class AuthTextField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  const AuthTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body(colors.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTextStyles.cardTitle(colors.textPrimary),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTextStyles.cardTitle(colors.textSecondary),
            filled: true,
            fillColor: colors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
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
          ),
        ),
      ],
    );
  }
}
