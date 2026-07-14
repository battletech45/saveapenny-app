import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

/// Temporary flat navigation list for features not yet reachable from the
/// dashboard's primary sections (net worth, cash flow, attention, upcoming
/// bills, accounts) or a bottom-nav shell.
///
/// Remove this once the tabbed navigation shell (see
/// docs/PRODUCTION_PLAYBOOK.md, "Navigation shell") ships — every entry here
/// should move to a tab or the "More" destination instead.
class QuickLinksSection extends StatelessWidget {
  const QuickLinksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final links = <_QuickLink>[
      _QuickLink(l10n.transactionsHomeCardTitle, l10n.transactionsHomeCardSubtitle, '/transactions'),
      _QuickLink(l10n.budgetsHomeCardTitle, l10n.budgetsHomeCardSubtitle, '/budgets'),
      _QuickLink(l10n.goalsHomeCardTitle, l10n.goalsHomeCardSubtitle, '/goals'),
      _QuickLink(l10n.categoriesHomeCardTitle, l10n.categoriesHomeCardSubtitle, '/categories'),
      _QuickLink(l10n.reportsHomeCardTitle, l10n.reportsHomeCardSubtitle, '/reports'),
      _QuickLink(l10n.stocksHomeCardTitle, l10n.stocksHomeCardSubtitle, '/stocks'),
      _QuickLink(l10n.insightsHomeCardTitle, l10n.insightsHomeCardSubtitle, '/insights'),
      _QuickLink(l10n.assistantHomeCardTitle, l10n.assistantHomeCardSubtitle, '/assistant'),
      _QuickLink(l10n.ocrHomeCardTitle, l10n.ocrHomeCardSubtitle, '/ocr'),
      _QuickLink(l10n.importsHomeCardTitle, l10n.importsHomeCardSubtitle, '/imports'),
      _QuickLink(l10n.notificationsHomeCardTitle, l10n.notificationsHomeCardSubtitle, '/notifications'),
      _QuickLink(l10n.profileHomeCardTitle, l10n.profileHomeCardSubtitle, '/profile'),
    ];

    return Card(
      child: Column(
        children: <Widget>[
          for (final link in links)
            ListTile(
              onTap: () => GoRouter.of(context).go(link.route),
              title: Text(link.title, style: context.textTheme.body),
              subtitle: Text(
                link.subtitle,
                style: context.textTheme.label.copyWith(
                  color: context.colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: context.colors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickLink {
  const _QuickLink(this.title, this.subtitle, this.route);

  final String title;
  final String subtitle;
  final String route;
}
