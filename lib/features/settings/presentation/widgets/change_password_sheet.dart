import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/config/env.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Validates current password is non-empty and the new password is 6+
/// characters and matches its confirmation (same rule as Login/Forgot
/// password's demo validation), then calls `AuthService.changePassword`
/// for a real Supabase Auth update.
class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChangePasswordSheet(),
    );
  }

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_currentController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'changePassword.errors.currentRequired'.tr());
      return;
    }
    if (_newController.text.length < 6) {
      setState(() => _errorMessage = 'changePassword.errors.tooShort'.tr());
      return;
    }
    if (_newController.text != _confirmController.text) {
      setState(() => _errorMessage = 'changePassword.errors.mismatch'.tr());
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSaving = true;
    });

    try {
      if (Env.isConfigured) {
        await getIt<AuthService>().changePassword(
          currentPassword: _currentController.text,
          newPassword: _newController.text,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('changePassword.passwordChanged'.tr())));
    } on AuthException {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'changePassword.errors.currentIncorrect'.tr();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'changePassword.errors.generic'.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('changePassword.title'.tr(), style: AppTextStyles.sectionHeader(colors.textPrimary)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close_rounded, color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _field(colors, label: 'changePassword.currentPassword'.tr(), controller: _currentController),
              const SizedBox(height: AppSpacing.md),
              _field(colors, label: 'changePassword.newPassword'.tr(), controller: _newController),
              const SizedBox(height: AppSpacing.md),
              _field(colors, label: 'changePassword.confirmNewPassword'.tr(), controller: _confirmController),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_errorMessage!, style: AppTextStyles.body(colors.danger)),
              ],
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryAction,
                    foregroundColor: colors.onPrimaryAction,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimaryAction))
                      : Text('changePassword.save'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(AppColors colors, {required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body(colors.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          obscureText: true,
          style: AppTextStyles.cardTitle(colors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
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
