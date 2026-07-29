import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/auth/application/auth_controller.dart';
import 'package:saveapenny/features/auth/presentation/widgets/auth_email_field.dart';
import 'package:saveapenny/features/auth/presentation/widgets/auth_form_shell.dart';
import 'package:saveapenny/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:saveapenny/features/auth/presentation/widgets/auth_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    final isSubmitting = authState.isLoading;
    final failure = authState.hasError ? authState.error as Failure : null;

    return AuthFormShell(
      title: l10n.loginHeading,
      subtitle: l10n.loginSubtitle,
      failure: failure,
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AuthEmailField(
              controller: _emailController,
              enabled: !isSubmitting,
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthPasswordField(
              controller: _passwordController,
              enabled: !isSubmitting,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton(
              onPressed: isSubmitting ? null : _submit,
              child: Text(isSubmitting ? l10n.commonLoading : l10n.loginSubmit),
            ),
          ],
        ),
      ),
      footer: AuthFooterPrompt(
        prompt: l10n.loginNoAccountPrompt,
        actionLabel: l10n.loginCreateAccount,
        onPressed: isSubmitting
            ? null
            : () {
                ref.read(authControllerProvider.notifier).clearFeedback();
                context.go('/register');
              },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    final state = ref.read(authControllerProvider);
    if (!mounted || state.hasError) {
      return;
    }
  }
}
