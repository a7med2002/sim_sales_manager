import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/language_switch.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordCubit(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
          listener: (context, state) {
            if (state.status == ForgotPasswordStatus.failure && state.errorMessage != null) {
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
                    title: 'forgotPassword.title'.tr(),
                    showBack: true,
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
                              Image.asset('assets/images/logo_full.png', height: 56, fit: BoxFit.contain),
                              const SizedBox(height: AppSpacing.xl),
                              if (state.status == ForgotPasswordStatus.success)
                                _SuccessCard(email: state.email)
                              else
                                _RequestForm(state: state),
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
    );
  }
}

class _RequestForm extends StatelessWidget {
  final ForgotPasswordState state;

  const _RequestForm({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'forgotPassword.description'.tr(),
          style: AppTextStyles.body(colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        AuthTextField(
          label: 'forgotPassword.emailLabel'.tr(),
          placeholder: 'forgotPassword.emailPlaceholder'.tr(),
          helperText: 'forgotPassword.emailHelper'.tr(),
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          onChanged: context.read<ForgotPasswordCubit>().emailChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: state.status == ForgotPasswordStatus.submitting
                ? null
                : () => context.read<ForgotPasswordCubit>().submit(),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primaryAction,
              foregroundColor: colors.onPrimaryAction,
              disabledBackgroundColor: colors.primaryAction.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
              elevation: 0,
            ),
            child: state.status == ForgotPasswordStatus.submitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimaryAction),
                  )
                : Text('forgotPassword.sendResetLink'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
          ),
        ),
      ],
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final String email;

  const _SuccessCard({required this.email});

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
                child: Icon(Icons.mark_email_read_outlined, color: colors.success, size: 24),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('forgotPassword.checkEmailTitle'.tr(), style: AppTextStyles.sectionHeader(colors.textPrimary)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'forgotPassword.checkEmailDescription'.tr(namedArgs: {'email': email}),
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
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.textPrimary,
              side: BorderSide(color: colors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
            ),
            child: Text('forgotPassword.backToSignIn'.tr(), style: AppTextStyles.cardTitle(colors.textPrimary)),
          ),
        ),
      ],
    );
  }
}
