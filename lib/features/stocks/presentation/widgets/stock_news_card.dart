import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/stocks/domain/stock_news.dart';

class StockNewsCard extends StatelessWidget {
  const StockNewsCard({super.key, required this.article});

  final StockNewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(article.title, style: context.textTheme.body),
            const SizedBox(height: AppSpacing.xs),
            Text(
              [article.source, article.timePublished]
                  .whereType<String>()
                  .where((item) => item.isNotEmpty)
                  .join(' · '),
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            if (article.summary != null &&
                article.summary!.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(article.summary!, style: context.textTheme.body),
            ],
          ],
        ),
      ),
    );
  }
}
