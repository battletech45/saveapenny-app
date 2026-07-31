import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/billing/application/entitlement_controller.dart';
import 'package:saveapenny/features/billing/presentation/widgets/plan_limit_banner.dart';
import 'package:saveapenny/features/reports/application/reports_controller.dart';
import 'package:saveapenny/features/reports/presentation/widgets/reports_cards.dart';
import 'package:saveapenny/features/reports/presentation/widgets/reports_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reportsState = ref.watch(reportsControllerProvider);
    final accounts =
        readReportsAsyncData(ref.watch(accountsControllerProvider)) ??
        const <Account>[];
    final currencyCode = accounts.isEmpty ? 'TRY' : accounts.first.currency;
    final entitlement = ref.watch(entitlementControllerProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportsTitle)),
      body: SafeArea(
        child: reportsState.when(
          data: (data) {
            final hasActivity =
                data.categorySpending.isNotEmpty || data.cashFlow.isNotEmpty;

            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(reportsControllerProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: <Widget>[
                  PlanLockedFeatureBanner(
                    isUnlocked: entitlement?.features.reportExport ?? true,
                    message: l10n.reportsHistoryLimitedMessage(
                      entitlement?.limits.reportHistoryMonths ?? 3,
                    ),
                  ),
                  ReportsMonthSwitcher(month: data.month),
                  const SizedBox(height: AppSpacing.lg),
                  ReportsSummaryCard(state: data, currencyCode: currencyCode),
                  const SizedBox(height: AppSpacing.lg),
                  ReportsNetWorthCard(state: data, currencyCode: currencyCode),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.reportsCashFlowTitle,
                    style: context.textTheme.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (data.cashFlow.isEmpty)
                    ReportsInlineEmptyState(
                      title: l10n.reportsCashFlowEmptyTitle,
                      message: l10n.reportsCashFlowEmptyMessage,
                    )
                  else
                    ...data.cashFlow.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ReportsCashFlowTile(
                          item: item,
                          currencyCode: currencyCode,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.reportsCategorySpendingTitle,
                    style: context.textTheme.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (data.categorySpending.isEmpty)
                    ReportsInlineEmptyState(
                      title: l10n.reportsCategorySpendingEmptyTitle,
                      message: l10n.reportsCategorySpendingEmptyMessage,
                    )
                  else
                    ...data.categorySpending.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ReportsCategorySpendingTile(
                          item: item,
                          currencyCode: currencyCode,
                        ),
                      ),
                    ),
                  if (!hasActivity) ...<Widget>[
                    const SizedBox(height: AppSpacing.xxl),
                    ReportsInlineEmptyState(
                      title: l10n.reportsEmptyTitle,
                      message: l10n.reportsEmptyMessage,
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () =>
                ref.read(reportsControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}
