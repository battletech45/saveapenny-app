import 'package:flutter/material.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/ocr/presentation/widgets/ocr_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class OcrIdleView extends StatelessWidget {
  const OcrIdleView({super.key, required this.onPickFile, this.error});

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
              Icons.document_scanner_rounded,
              size: 48,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.ocrIdleTitle,
              style: context.textTheme.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.ocrIdleMessage,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.ocrAcceptedFormatsMessage,
              style: context.textTheme.label.copyWith(
                color: context.colors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            if (error != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              OcrErrorNotice(failure: error!),
            ],
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: onPickFile,
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(l10n.ocrPickFileCta),
            ),
          ],
        ),
      ),
    );
  }
}
