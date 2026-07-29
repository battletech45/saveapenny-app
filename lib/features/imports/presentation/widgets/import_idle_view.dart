import 'package:flutter/material.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/imports/presentation/widgets/import_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class ImportIdleView extends StatelessWidget {
  const ImportIdleView({super.key, required this.onPickFile, this.error});

  final VoidCallback onPickFile;
  final Failure? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.upload_file_rounded,
              size: 48,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.importsIdleTitle,
              style: context.textTheme.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.importsIdleMessage,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (error != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              ImportErrorNotice(failure: error!),
            ],
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: onPickFile,
              icon: const Icon(Icons.folder_open_rounded),
              label: Text(l10n.importsPickFileCta),
            ),
          ],
        ),
      ),
    );
  }
}
