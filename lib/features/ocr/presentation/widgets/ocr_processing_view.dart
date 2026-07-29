import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/ocr/domain/ocr_models.dart';
import 'package:saveapenny/features/ocr/presentation/widgets/ocr_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class OcrProcessingView extends StatelessWidget {
  const OcrProcessingView({super.key, required this.fileName, this.job});

  final String fileName;
  final OcrJob? job;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const LoadingView(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.ocrProcessingTitle,
              style: context.textTheme.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              fileName.isEmpty
                  ? l10n.ocrProcessingMessage
                  : l10n.ocrProcessingFileMessage(fileName),
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (job != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                '${l10n.ocrStatusLabel}: ${ocrStatusLabel(context, job!.status)}',
                style: context.textTheme.label.copyWith(
                  color: context.colors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
