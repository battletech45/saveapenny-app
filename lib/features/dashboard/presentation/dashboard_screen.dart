import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/dashboard/application/dashboard_controller.dart';
import 'package:saveapenny/features/dashboard/presentation/widgets/account_row.dart';
import 'package:saveapenny/features/dashboard/presentation/widgets/attention_strip.dart';
import 'package:saveapenny/features/dashboard/presentation/widgets/cash_flow_summary_card.dart';
import 'package:saveapenny/features/dashboard/presentation/widgets/net_worth_hero.dart';
import 'package:saveapenny/features/dashboard/presentation/widgets/upcoming_bills_list.dart';
import 'package:saveapenny/features/notifications/application/notifications_controller.dart';
import 'package:saveapenny/features/transactions/presentation/widgets/transaction_form_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapshot = ref.watch(dashboardControllerProvider);
    final unreadCount =
        ref.watch(notificationsControllerProvider).asData?.value.unreadCount ??
        0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: <Widget>[
          Badge(
            isLabelVisible: unreadCount > 0,
            label: Text('$unreadCount'),
            child: IconButton(
              onPressed: () => GoRouter.of(context).go('/notifications'),
              icon: const Icon(Icons.notifications_outlined),
              tooltip: l10n.notificationsHomeCardTitle,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboardFab',
        onPressed: () => _showTransactionSheet(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: snapshot.when(
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () =>
                ref.read(dashboardControllerProvider.notifier).refresh(),
          ),
          data: (data) => RefreshIndicator(
            onRefresh: () =>
                ref.read(dashboardControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: <Widget>[
                NetWorthHero(netWorth: data.netWorth),
                const SizedBox(height: AppSpacing.xl),
                CashFlowSummaryCard(summary: data.monthlySummary),
                if (data.atRiskBudgets.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  AttentionStrip(budgets: data.atRiskBudgets),
                ],
                if (data.upcomingBills.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.dashboardUpcomingBillsTitle,
                    style: context.textTheme.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  UpcomingBillsList(bills: data.upcomingBills),
                ],
                if (data.accounts.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.dashboardAccountsTitle,
                    style: context.textTheme.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Card(
                    child: Column(
                      children: <Widget>[
                        for (final account in data.accounts)
                          AccountRow(account: account),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.giant),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showTransactionSheet(BuildContext context) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => const TransactionFormSheet(),
    );
  }
}
