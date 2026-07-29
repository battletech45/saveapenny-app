import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/insights/application/insight_detail_controller.dart';
import 'package:saveapenny/features/insights/application/insights_controller.dart';
import 'package:saveapenny/features/insights/presentation/widgets/insight_detail_card.dart';
import 'package:saveapenny/features/insights/presentation/widgets/insight_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class InsightDetailScreen extends ConsumerWidget {
  const InsightDetailScreen({super.key, required this.insightId});

  final String insightId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detailState = ref.watch(insightDetailControllerProvider(insightId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => GoRouter.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(l10n.insightsDetailTitle),
      ),
      body: SafeArea(
        child: detailState.when(
          data: (insight) => RefreshIndicator(
            onRefresh: () => ref
                .read(insightDetailControllerProvider(insightId).notifier)
                .refresh(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: <Widget>[
                InsightDetailCard(insight: insight),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () => _dismissInsight(context, ref),
                  child: Text(l10n.insightsDismissCta),
                ),
              ],
            ),
          ),
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () => ref
                .read(insightDetailControllerProvider(insightId).notifier)
                .refresh(),
          ),
        ),
      ),
    );
  }

  Future<void> _dismissInsight(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(insightsControllerProvider.notifier).dismiss(insightId);
      if (!context.mounted) {
        return;
      }
      GoRouter.of(context).pop();
    } on Failure catch (failure) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(insightFailureMessage(context, failure))),
        );
    }
  }
}
