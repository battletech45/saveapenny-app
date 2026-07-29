import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/users/application/users_controller.dart';
import 'package:saveapenny/features/users/domain/user_profile.dart';
import 'package:saveapenny/features/users/presentation/widgets/profile_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
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
              Text(l10n.profileEditTitle, style: context.textTheme.title),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.profileEditSubtitle,
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
                initialValue: widget.profile.email,
                enabled: false,
                decoration: InputDecoration(labelText: l10n.profileEmailLabel),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _fullNameController,
                enabled: !isSubmitting,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.profileFullNameLabel,
                ),
                validator: (value) => _validateFullName(l10n, value),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submit,
                child: Text(
                  isSubmitting ? l10n.commonLoading : l10n.profileSaveCta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateFullName(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.authRequiredFieldError;
    }
    if (value.trim().length > 150) {
      return l10n.profileFullNameError;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(usersControllerProvider.notifier)
        .updateProfile(fullName: _fullNameController.text.trim());

    final state = ref.read(usersControllerProvider);
    if (!mounted || state.hasError) {
      return;
    }

    Navigator.of(context).pop();
  }
}
