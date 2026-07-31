import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/users/application/users_controller.dart';
import 'package:saveapenny/features/users/presentation/widgets/profile_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class ChangePasswordSheet extends ConsumerStatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  ConsumerState<ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileState = ref.watch(usersControllerProvider);
    final isSubmitting = profileState.isLoading;
    final failure = profileState.hasError
        ? profileState.error as Failure
        : null;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                l10n.profileChangePasswordTitle,
                style: context.textTheme.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.profileChangePasswordSubtitle,
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              if (failure != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                ProfileSheetFailureNotice(failure: failure),
              ],
              const SizedBox(height: AppSpacing.xxl),
              TextFormField(
                controller: _currentPasswordController,
                enabled: !isSubmitting,
                obscureText: _obscureCurrentPassword,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.password],
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: l10n.profileCurrentPasswordLabel,
                  suffixIcon: IconButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            setState(() {
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword;
                            });
                          },
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                  ),
                ),
                validator: (value) => _validateRequired(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _newPasswordController,
                enabled: !isSubmitting,
                obscureText: _obscureNewPassword,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.newPassword],
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: l10n.profileNewPasswordLabel,
                  suffixIcon: IconButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                  ),
                ),
                validator: (value) => _validateRequired(l10n, value),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submit,
                child: Text(
                  isSubmitting
                      ? l10n.commonLoading
                      : l10n.profileChangePasswordCta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        .read(usersControllerProvider.notifier)
        .changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

    if (!mounted || ref.read(usersControllerProvider).hasError) {
      return;
    }

    Navigator.of(context).pop();
  }
}
