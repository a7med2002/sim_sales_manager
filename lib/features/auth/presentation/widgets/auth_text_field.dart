import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Labeled text input used on the Login/Reset password screens: small label
/// above a rounded outlined field, optional leading icon and helper text
/// below, border + icon both pick up `primaryAction` on focus so the field
/// visibly responds to interaction. Password fields (`obscureText: true`)
/// get a show/hide toggle instead of always hiding the value.
class AuthTextField extends StatefulWidget {
  final String label;
  final String? placeholder;
  final String? helperText;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  const AuthTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.placeholder,
    this.helperText,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  final _focusNode = FocusNode();
  bool _isFocused = false;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeColor = _isFocused ? colors.primaryAction : colors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.body(colors.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          style: AppTextStyles.cardTitle(colors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: AppTextStyles.hint(colors.textSecondary),
            filled: true,
            fillColor: colors.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: widget.icon == null ? AppSpacing.md : 0, vertical: 14),
            prefixIcon: widget.icon == null
                ? null
                : Icon(widget.icon, size: 20, color: activeColor),
            prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 0),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
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
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(widget.helperText!, style: AppTextStyles.body(colors.textSecondary).copyWith(fontSize: 12)),
          ),
        ],
      ],
    );
  }
}
