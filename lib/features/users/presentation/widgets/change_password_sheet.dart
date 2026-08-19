import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
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

    return AppSheetScaffold(
      title: l10n.profileChangePasswordTitle,
      subtitle: l10n.profileChangePasswordSubtitle,
      failure: failure == null
          ? null
          : ProfileSheetFailureNotice(failure: failure),
      actionBar: AppSheetActionBar(
        primaryLabel: isSubmitting
            ? l10n.commonLoading
            : l10n.profileChangePasswordCta,
        onPrimaryPressed: isSubmitting ? null : _submit,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
                            _obscureCurrentPassword = !_obscureCurrentPassword;
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
            const SizedBox(height: AppSpacing.lg),
          ],
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
