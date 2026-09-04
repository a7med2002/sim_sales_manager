import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/navigation/route_names.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../widgets/auth_text_field.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => LoginCubit(), child: const _LoginView());
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.success) {
              Navigator.of(context).pushReplacementNamed(state.isAdmin ? RouteNames.adminHub : RouteNames.home);
            } else if (state.status == LoginStatus.failure &&
                state.errorMessage != null) {
              _showCredentialsError(context, state.errorMessage!.tr());
            }
          },
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                    vertical: AppSpacing.md,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _BrandHeader(),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'login.title'.tr(),
                          style: AppTextStyles.pageTitle(colors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'login.subtitle'.tr(),
                          style: AppTextStyles.body(colors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AuthTextField(
                          label: 'login.usernameLabel'.tr(),
                          placeholder: 'login.usernamePlaceholder'.tr(),
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: context.read<LoginCubit>().usernameChanged,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AuthTextField(
                          label: 'login.passwordLabel'.tr(),
                          placeholder: '********'.tr(),
                          icon: Icons.lock_outline_rounded,
                          obscureText: true,
                          onChanged: context.read<LoginCubit>().passwordChanged,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () => context
                                    .read<LoginCubit>()
                                    .toggleRememberMe(),
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _RememberMeCheckbox(
                                      checked: state.rememberMe,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Flexible(
                                      child: Text(
                                        'login.rememberMe'.tr(),
                                        style: AppTextStyles.body(
                                          colors.textSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'login.forgotPassword'.tr(),
                                style: AppTextStyles.cardTitle(
                                  colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: state.status == LoginStatus.submitting
                                ? null
                                : () => context.read<LoginCubit>().submit(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primaryAction,
                              foregroundColor: colors.onPrimaryAction,
                              disabledBackgroundColor: colors.primaryAction
                                  .withValues(alpha: 0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.button,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: state.status == LoginStatus.submitting
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.onPrimaryAction,
                                    ),
                                  )
                                : Text(
                                    'login.signIn'.tr(),
                                    style: AppTextStyles.cardTitle(
                                      colors.onPrimaryAction,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Shows the "enter your credentials" notice as a transient snackbar (same
/// visual style the reference design used for a persistent banner) — it
/// only appears when the submitted credentials are actually invalid.
void _showCredentialsError(BuildContext context, String message) {
  final colors = context.colors;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: colors.border),
        ),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colors.primaryAction,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.priority_high_rounded,
                color: colors.onPrimaryAction,
                size: 14,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'login.credentialsErrorTitle'.tr(),
                    style: AppTextStyles.cardTitle(colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(message, style: AppTextStyles.body(colors.warning)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colors.primaryAction,
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.signal_cellular_alt_rounded,
            color: colors.onPrimaryAction,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'login.brandName'.tr(),
                style: AppTextStyles.cardTitle(
                  colors.textPrimary,
                ).copyWith(fontSize: 17),
              ),
              Text(
                'login.brandTagline'.tr(),
                style: AppTextStyles.body(colors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RememberMeCheckbox extends StatelessWidget {
  final bool checked;

  const _RememberMeCheckbox({required this.checked});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: checked ? colors.primaryAction : Colors.transparent,
        border: Border.all(
          color: checked ? colors.primaryAction : colors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: checked
          ? Icon(Icons.check_rounded, color: colors.onPrimaryAction, size: 14)
          : null,
    );
  }
}
