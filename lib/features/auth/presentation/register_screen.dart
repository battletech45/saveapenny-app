import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/auth/application/auth_controller.dart';
import 'package:saveapenny/features/auth/presentation/widgets/auth_form_shell.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _isPasswordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
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
      title: l10n.registerHeading,
      subtitle: l10n.registerSubtitle,
      failure: failure,
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _fullNameController,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.commonFullName,
                hintText: l10n.authFullNameHint,
              ),
              validator: (value) => _validateRequired(l10n, value),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _emailController,
              enabled: !isSubmitting,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.commonEmail,
                hintText: l10n.authEmailHint,
              ),
              validator: (value) => _validateEmail(l10n, value),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _passwordController,
              enabled: !isSubmitting,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.commonPassword,
                hintText: l10n.authPasswordHint,
                suffixIcon: IconButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (value) => _validateRequired(l10n, value),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton(
              onPressed: isSubmitting ? null : _submit,
              child: Text(
                isSubmitting ? l10n.commonLoading : l10n.registerSubmit,
              ),
            ),
          ],
        ),
      ),
      footer: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.xs,
          children: <Widget>[
            Text(
              l10n.registerHaveAccountPrompt,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      ref.read(authControllerProvider.notifier).clearFeedback();
                      context.go('/login');
                    },
              child: Text(l10n.registerSignIn),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(AppLocalizations l10n, String? value) {
    final requiredError = _validateRequired(l10n, value);
    if (requiredError != null) {
      return requiredError;
    }

    final trimmed = value!.trim();
    if (!trimmed.contains('@') || !trimmed.contains('.')) {
      return l10n.authInvalidEmailError;
    }

    return null;
  }

  String? _validateRequired(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.authRequiredFieldError;
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
        );
  }
}
