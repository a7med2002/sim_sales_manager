import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/language_switch.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_auth_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String _displayName = '';
  String _email = '';
  String _password = '';
  String _confirmation = '';

  void _showError(String key) {
    final colors = context.colors;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.surface,
          content: Text(key.tr(), style: AppTextStyles.body(colors.danger)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (ModalRoute.of(context)?.isCurrent != true) return;
            if (state.status == LoginStatus.failure &&
                state.errorMessage != null) {
              _showError(state.errorMessage!);
            } else if (state.status == LoginStatus.success) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                state.isAdmin ? RouteNames.adminHub : RouteNames.home,
                (route) => false,
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                    vertical: AppSpacing.md,
                  ),
                  child: AppTopBar(
                    title: 'signUp.title'.tr(),
                    showBack: true,
                    showSyncStatus: false,
                    actions: const [LanguageSwitch()],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 480),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.lg,
                                ),
                                child:
                                    state.status ==
                                        LoginStatus.emailConfirmationRequired
                                    ? _EmailConfirmation(
                                        email:
                                            state.confirmationEmail ?? _email,
                                        onBack: () {
                                          context
                                              .read<LoginCubit>()
                                              .resetStatus();
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    : _SignUpForm(
                                        displayName: _displayName,
                                        email: _email,
                                        password: _password,
                                        confirmation: _confirmation,
                                        state: state,
                                        onNameChanged: (value) => setState(
                                          () => _displayName = value,
                                        ),
                                        onEmailChanged: (value) =>
                                            setState(() => _email = value),
                                        onPasswordChanged: (value) =>
                                            setState(() => _password = value),
                                        onConfirmationChanged: (value) =>
                                            setState(
                                              () => _confirmation = value,
                                            ),
                                      ),
                              ),
                            ),
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

class _SignUpForm extends StatelessWidget {
  final String displayName;
  final String email;
  final String password;
  final String confirmation;
  final LoginState state;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmationChanged;

  const _SignUpForm({
    required this.displayName,
    required this.email,
    required this.password,
    required this.confirmation,
    required this.state,
    required this.onNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<LoginCubit>();
    final isSubmitting = state.status == LoginStatus.submitting;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(
          'assets/images/logo_full.png',
          height: 64,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'signUp.title'.tr(),
          style: AppTextStyles.pageTitle(colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'signUp.subtitle'.tr(),
          style: AppTextStyles.body(colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        AuthTextField(
          label: 'signUp.nameLabel'.tr(),
          placeholder: 'signUp.namePlaceholder'.tr(),
          icon: Icons.person_outline_rounded,
          onChanged: onNameChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          label: 'login.usernameLabel'.tr(),
          placeholder: 'login.usernamePlaceholder'.tr(),
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          label: 'login.passwordLabel'.tr(),
          placeholder: '********',
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          onChanged: onPasswordChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          label: 'signUp.confirmPasswordLabel'.tr(),
          placeholder: '********',
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          onChanged: onConfirmationChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: isSubmitting
                ? null
                : () => cubit.signUp(
                    displayName: displayName,
                    email: email,
                    password: password,
                    confirmation: confirmation,
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primaryAction,
              foregroundColor: colors.onPrimaryAction,
              disabledBackgroundColor: colors.primaryAction.withValues(
                alpha: 0.6,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.button),
              ),
              elevation: 0,
            ),
            child: isSubmitting && !state.isGoogleSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onPrimaryAction,
                    ),
                  )
                : Text(
                    'signUp.createAccount'.tr(),
                    style: AppTextStyles.cardTitle(colors.onPrimaryAction),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AuthDivider(label: 'login.or'.tr()),
        const SizedBox(height: AppSpacing.md),
        GoogleAuthButton(
          isLoading: state.isGoogleSubmitting,
          isDisabled: isSubmitting,
          onPressed: cubit.signInWithGoogle,
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'signUp.haveAccount'.tr(),
                style: AppTextStyles.body(colors.textSecondary),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'signUp.signIn'.tr(),
                  style: AppTextStyles.cardTitle(colors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmailConfirmation extends StatelessWidget {
  final String email;
  final VoidCallback onBack;

  const _EmailConfirmation({required this.email, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mark_email_read_outlined, color: colors.success, size: 42),
          const SizedBox(height: AppSpacing.md),
          Text(
            'signUp.confirmationTitle'.tr(),
            style: AppTextStyles.sectionHeader(colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'signUp.confirmationDescription'.tr(namedArgs: {'email': email}),
            style: AppTextStyles.body(colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryAction,
                foregroundColor: colors.onPrimaryAction,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.button),
                ),
                elevation: 0,
              ),
              child: Text(
                'signUp.backToSignIn'.tr(),
                style: AppTextStyles.cardTitle(colors.onPrimaryAction),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
