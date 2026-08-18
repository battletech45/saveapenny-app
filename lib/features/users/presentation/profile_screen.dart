import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/settings/app_settings_controller.dart';
import 'package:saveapenny/core/storage/app_settings_store.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/initials_avatar.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/auth/application/auth_controller.dart';
import 'package:saveapenny/features/billing/application/entitlement_controller.dart';
import 'package:saveapenny/features/billing/domain/plan.dart';
import 'package:saveapenny/features/billing/presentation/widgets/upgrade_card.dart';
import 'package:saveapenny/features/feedback/presentation/widgets/feedback_form_sheet.dart';
import 'package:saveapenny/features/users/application/users_controller.dart';
import 'package:saveapenny/features/users/domain/user_profile.dart';
import 'package:saveapenny/features/users/presentation/widgets/change_password_sheet.dart';
import 'package:saveapenny/features/users/presentation/widgets/edit_profile_sheet.dart';
import 'package:saveapenny/features/users/presentation/widgets/profile_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileState = ref.watch(usersControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final appSettings = ref.watch(appSettingsControllerProvider);
    final entitlement = ref.watch(entitlementControllerProvider).value;
    final showUpgradeCard =
        entitlement != null && entitlement.plan != Plan.plus;
    final logoutFailure = authState.hasError
        ? authState.error as Failure
        : null;

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (!context.mounted || !next.hasError) {
        return;
      }

      final failure = next.error;
      if (failure is! Failure) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(profileFailureMessage(context, failure))),
        );
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SafeArea(
        child: profileState.when(
          data: (profile) {
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(usersControllerProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: <Widget>[
                  if (showUpgradeCard) ...<Widget>[
                    const UpgradeCard(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              InitialsAvatar(name: profile.fullName, size: 64),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          ProfileInfoRow(
                            label: l10n.profileStatusLabel,
                            value: profile.active
                                ? l10n.profileStatusActive
                                : l10n.profileStatusInactive,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ProfileInfoRow(
                            label: l10n.profileCreatedAtLabel,
                            value: formatProfileDateTime(
                              context,
                              profile.createdAt,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ProfileInfoRow(
                            label: l10n.profileUpdatedAtLabel,
                            value: formatProfileDateTime(
                              context,
                              profile.updatedAt,
                            ),
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
                  const SizedBox(height: AppSpacing.xl),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            l10n.profilePreferencesSectionTitle,
                            style: context.textTheme.title,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.profilePreferencesSectionSubtitle,
                            style: context.textTheme.body.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _ProfilePreferenceButton(
                            label: l10n.profileLanguageLabel,
                            value: _localeLabel(l10n, appSettings.locale),
                            onPressed: () =>
                                _showLanguageSheet(context, ref, appSettings),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ProfilePreferenceButton(
                            label: l10n.profileThemeLabel,
                            value: _themeLabel(l10n, appSettings.theme),
                            onPressed: () =>
                                _showThemeSheet(context, ref, appSettings),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            l10n.feedbackProfileSectionTitle,
                            style: context.textTheme.title,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.feedbackProfileSectionSubtitle,
                            style: context.textTheme.body.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: () => _showFeedbackSheet(context),
                            child: Text(l10n.feedbackSubmitCta),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton(
                            onPressed: () => context.push('/feedback'),
                            child: Text(l10n.feedbackHistoryCta),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            l10n.profileLogoutTitle,
                            style: context.textTheme.title,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.profileLogoutSubtitle,
                            style: context.textTheme.body.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          if (logoutFailure != null) ...<Widget>[
                            const SizedBox(height: AppSpacing.lg),
                            ProfileSheetFailureNotice(failure: logoutFailure),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : () => _confirmLogout(context, ref),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.finance.expense,
                              foregroundColor: context.colors.surface,
                            ),
                            child: Text(
                              authState.isLoading
                                  ? l10n.commonLoading
                                  : l10n.commonSignOut,
                            ),
                          ),
                        ],
                      ),
                    ),
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
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => EditProfileSheet(profile: profile),
    );
  }

  Future<void> _showChangePasswordSheet(BuildContext context) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => const ChangePasswordSheet(),
    );
  }

  Future<void> _showFeedbackSheet(BuildContext context) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => const FeedbackFormSheet(sourceScreen: 'profile'),
    );
  }

  Future<void> _showLanguageSheet(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final l10n = AppLocalizations.of(context);
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => _ProfileSelectionSheet<AppLocaleSetting>(
        title: l10n.profileLanguageLabel,
        options: <_ProfileSelectionOption<AppLocaleSetting>>[
          _ProfileSelectionOption(
            value: AppLocaleSetting.system,
            label: l10n.profileLanguageSystem,
          ),
          _ProfileSelectionOption(
            value: AppLocaleSetting.english,
            label: l10n.profileLanguageEnglish,
          ),
          _ProfileSelectionOption(
            value: AppLocaleSetting.turkish,
            label: l10n.profileLanguageTurkish,
          ),
        ],
        selectedValue: settings.locale,
        onSelected: (value) async {
          await ref
              .read(appSettingsControllerProvider.notifier)
              .setLocale(value);
        },
      ),
    );
  }

  Future<void> _showThemeSheet(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final l10n = AppLocalizations.of(context);
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => _ProfileSelectionSheet<AppThemeSetting>(
        title: l10n.profileThemeLabel,
        options: <_ProfileSelectionOption<AppThemeSetting>>[
          _ProfileSelectionOption(
            value: AppThemeSetting.system,
            label: l10n.profileThemeSystem,
          ),
          _ProfileSelectionOption(
            value: AppThemeSetting.light,
            label: l10n.profileThemeLight,
          ),
          _ProfileSelectionOption(
            value: AppThemeSetting.dark,
            label: l10n.profileThemeDark,
          ),
        ],
        selectedValue: settings.theme,
        onSelected: (value) async {
          await ref
              .read(appSettingsControllerProvider.notifier)
              .setTheme(value);
        },
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.profileLogoutConfirmTitle),
          content: Text(l10n.profileLogoutConfirmMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.commonSignOut),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(authControllerProvider.notifier).logout();
  }
}

String _localeLabel(AppLocalizations l10n, AppLocaleSetting setting) {
  return switch (setting) {
    AppLocaleSetting.system => l10n.profileLanguageSystem,
    AppLocaleSetting.english => l10n.profileLanguageEnglish,
    AppLocaleSetting.turkish => l10n.profileLanguageTurkish,
  };
}

String _themeLabel(AppLocalizations l10n, AppThemeSetting setting) {
  return switch (setting) {
    AppThemeSetting.system => l10n.profileThemeSystem,
    AppThemeSetting.light => l10n.profileThemeLight,
    AppThemeSetting.dark => l10n.profileThemeDark,
  };
}

class _ProfilePreferenceButton extends StatelessWidget {
  const _ProfilePreferenceButton({
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(AppSpacing.lg),
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: context.textTheme.label),
                const SizedBox(height: AppSpacing.xs),
                Text(value, style: context.textTheme.body),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Icon(
            Icons.chevron_right_rounded,
            color: context.colors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _ProfileSelectionOption<T> {
  const _ProfileSelectionOption({required this.value, required this.label});

  final T value;
  final String label;
}

class _ProfileSelectionSheet<T> extends StatelessWidget {
  const _ProfileSelectionSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final String title;
  final List<_ProfileSelectionOption<T>> options;
  final T selectedValue;
  final Future<void> Function(T value) onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: context.textTheme.title),
          const SizedBox(height: AppSpacing.lg),
          for (final option in options) ...<Widget>[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(option.label),
              trailing: option.value == selectedValue
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : const Icon(Icons.circle_outlined),
              onTap: () async {
                await onSelected(option.value);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
            if (option != options.last)
              Divider(color: context.colors.border, height: 1),
          ],
        ],
      ),
    );
  }
}
