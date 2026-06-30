import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              width: AppSpacing.huge,
              height: AppSpacing.huge,
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.commonLoading, style: context.textTheme.body),
          ],
        ),
      ),
    );
  }
}
