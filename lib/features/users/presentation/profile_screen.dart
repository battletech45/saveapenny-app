import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/billing/application/entitlement_controller.dart';
import 'package:saveapenny/features/billing/domain/plan.dart';
import 'package:saveapenny/features/billing/presentation/widgets/upgrade_card.dart';
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
    final entitlement = ref.watch(entitlementControllerProvider).value;
    final showUpgradeCard =
        entitlement != null && entitlement.plan != Plan.plus;

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
}
