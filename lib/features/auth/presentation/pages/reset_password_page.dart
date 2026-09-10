import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/language_switch.dart';
import '../cubit/reset_password_cubit.dart';
import '../cubit/reset_password_state.dart';
import '../widgets/auth_text_field.dart';

/// Reached only via the deep link from a Supabase "reset password" email
/// (see `main.dart`'s `AuthChangeEvent.passwordRecovery` listener) — the
/// temporary recovery session that link establishes is what authorizes
/// `ResetPasswordCubit.submit` to set a new password, no re-entry of the
/// old one needed.
class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResetPasswordCubit(),
      child: const _ResetPasswordView(),
    );
  }
}

class _ResetPasswordView extends StatelessWidget {
  const _ResetPasswordView();

  Future<void> _backToSignIn(BuildContext context) async {
    // The recovery session is single-purpose — sign out so the user
    // authenticates fresh with the password they just set.
    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
            listener: (context, state) {
              if (state.status == ResetPasswordStatus.failure && state.errorMessage != null) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(state.errorMessage!.tr())));
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal, vertical: AppSpacing.md),
                    child: AppTopBar(
                      title: 'resetPassword.title'.tr(),
                      showBack: false,
                      showSyncStatus: false,
                      actions: const [LanguageSwitch()],
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (state.status == ResetPasswordStatus.success)
                                  _SuccessCard(onBackToSignIn: () => _backToSignIn(context))
                                else
                                  _ResetForm(state: state),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ResetForm extends StatelessWidget {
  final ResetPasswordState state;

  const _ResetForm({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<ResetPasswordCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('resetPassword.description'.tr(), style: AppTextStyles.body(colors.textSecondary)),
        const SizedBox(height: AppSpacing.lg),
        AuthTextField(
          label: 'resetPassword.newPasswordLabel'.tr(),
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          onChanged: cubit.newPasswordChanged,
          keyboardType: TextInputType.visiblePassword,
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          label: 'resetPassword.confirmNewPasswordLabel'.tr(),
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          onChanged: cubit.confirmPasswordChanged,
          keyboardType: TextInputType.visiblePassword,
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: state.status == ResetPasswordStatus.submitting ? null : cubit.submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primaryAction,
              foregroundColor: colors.onPrimaryAction,
              disabledBackgroundColor: colors.primaryAction.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
              elevation: 0,
            ),
            child: state.status == ResetPasswordStatus.submitting
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimaryAction))
                : Text('resetPassword.save'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
          ),
        ),
      ],
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final VoidCallback onBackToSignIn;

  const _SuccessCard({required this.onBackToSignIn});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: colors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(Icons.check_circle_outline_rounded, color: colors.success, size: 24),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('resetPassword.successTitle'.tr(), style: AppTextStyles.sectionHeader(colors.textPrimary)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'resetPassword.successDescription'.tr(),
                style: AppTextStyles.body(colors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onBackToSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primaryAction,
              foregroundColor: colors.onPrimaryAction,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
              elevation: 0,
            ),
            child: Text('resetPassword.backToSignIn'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
          ),
        ),
      ],
    );
  }
}
