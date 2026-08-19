import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/connectivity_service.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/cache_staleness_label.dart';
import 'package:saveapenny/core/ui/empty_view.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/core/ui/scroll_aware_fab.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/accounts/presentation/widgets/account_card.dart';
import 'package:saveapenny/features/accounts/presentation/widgets/account_form_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accountsState = ref.watch(accountsControllerProvider);

    final lastSyncedAt = ref.watch(accountsLastSyncedAtProvider).value;
    final isOnline = ref.watch(isOnlineProvider).value ?? true;
    final showStaleness = !isOnline && lastSyncedAt != null;

    return ScrollAwareFabVisibility(
      builder: (context, fabVisible) => Scaffold(
        appBar: AppBar(title: Text(l10n.accountsTitle)),
        floatingActionButton: ScrollAwareFab(
          visible: fabVisible,
          child: FloatingActionButton.extended(
            heroTag: 'accountsFab',
            onPressed: () => _showAccountSheet(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.accountsAddCta),
          ),
        ),
        body: SafeArea(
          child: accountsState.when(
            data: (accounts) {
              if (accounts.isEmpty) {
                return EmptyView(
                  icon: Icons.account_balance_outlined,
                  title: l10n.accountsEmptyTitle,
                  message: l10n.accountsEmptyMessage,
                  action: ElevatedButton(
                    onPressed: () => _showAccountSheet(context, ref),
                    child: Text(l10n.accountsAddFirstCta),
                  ),
                );
              }

              return Column(
                children: <Widget>[
                  if (showStaleness)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        0,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CacheStalenessLabel(lastSyncedAt: lastSyncedAt),
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => ref
                          .read(accountsControllerProvider.notifier)
                          .refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: accounts.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(height: AppSpacing.lg),
                        itemBuilder: (context, index) {
                          final account = accounts[index];
                          return AccountCard(
                            account: account,
                            onEdit: () => _showAccountSheet(
                              context,
                              ref,
                              existing: account,
                            ),
                            confirmDelete: () =>
                                _confirmDeleteDialog(context, account),
                            onDelete: () =>
                                _deleteAccount(context, ref, account),
                            onTap: () => GoRouter.of(
                              context,
                            ).push('/accounts/${account.id}/credit'),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const LoadingView(),
            error: (error, _) => FailureView(
              failure: error as Failure,
              onRetry: () =>
                  ref.read(accountsControllerProvider.notifier).refresh(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAccountSheet(
    BuildContext context,
    WidgetRef ref, {
    Account? existing,
  }) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => AccountFormSheet(existing: existing),
    );
  }

  Future<bool> _confirmDeleteDialog(
    BuildContext context,
    Account account,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.accountsDeleteTitle),
          content: Text(l10n.accountsDeleteMessage(account.name)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonBack),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.accountsDeleteCta),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  Future<void> _deleteAccount(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    await ref
        .read(accountsControllerProvider.notifier)
        .deleteAccount(account.id);
  }
}
