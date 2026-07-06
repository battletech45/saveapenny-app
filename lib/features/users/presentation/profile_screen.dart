import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/users/application/users_controller.dart';
import 'package:saveapenny/features/users/domain/user_profile.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileState = ref.watch(usersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => GoRouter.of(context).go('/home'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(l10n.profileTitle),
      ),
      body: SafeArea(
        child: profileState.when(
          data: (profile) {
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(usersControllerProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            profile.fullName,
                            style: context.textTheme.headline,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            profile.email,
                            style: context.textTheme.body.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          _ProfileInfoRow(
                            label: l10n.profileStatusLabel,
                            value: profile.active
                                ? l10n.profileStatusActive
                                : l10n.profileStatusInactive,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _ProfileInfoRow(
                            label: l10n.profileCreatedAtLabel,
                            value: _formatDateTime(context, profile.createdAt),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _ProfileInfoRow(
                            label: l10n.profileUpdatedAtLabel,
                            value: _formatDateTime(context, profile.updatedAt),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedButton(
                    onPressed: () => _showEditProfileSheet(context, profile),
                    child: Text(l10n.profileEditCta),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => _showChangePasswordSheet(context),
                    child: Text(l10n.profileChangePasswordCta),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.profileChangePasswordHint,
                    style: context.textTheme.label.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () => ref.read(usersControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditProfileSheet(
    BuildContext context,
    UserProfile profile,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _EditProfileSheet(profile: profile),
    );
  }

  Future<void> _showChangePasswordSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _ChangePasswordSheet(),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: context.textTheme.label.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: context.textTheme.body),
      ],
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
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
                _SheetFailureNotice(failure: failure),
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

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
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
                _SheetFailureNotice(failure: failure),
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

class _SheetFailureNotice extends StatelessWidget {
  const _SheetFailureNotice({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = switch (failure) {
      NetworkFailure() => l10n.failureNetworkMessage,
      UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
      RateLimitedFailure() => l10n.failureRateLimitedMessage,
      UnknownFailure() => l10n.failureGenericMessage,
      ApiFailure(code: final code) => switch (code) {
        ApiErrorCode.invalidPassword => l10n.failureInvalidPasswordMessage,
        ApiErrorCode.passwordReuseNotAllowed =>
          l10n.failurePasswordReuseNotAllowedMessage,
        ApiErrorCode.validationFailed => l10n.failureValidationFailedMessage,
        _ => l10n.failureGenericMessage,
      },
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.finance.expenseSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.finance.expense),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          message,
          style: context.textTheme.body.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

String _formatDateTime(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final date = DateFormat.yMMMd(locale).format(value);
  final time = DateFormat.Hm(locale).format(value);
  return '$date $time';
}
