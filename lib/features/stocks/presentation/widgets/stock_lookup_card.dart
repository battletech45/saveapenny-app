import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class StockLookupCard extends StatelessWidget {
  const StockLookupCard({super.key, required this.onLookup});

  final ValueChanged<String> onLookup;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.stocksLookupTitle, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.stocksLookupSubtitle,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => _showLookupDialog(context),
              child: Text(l10n.stocksLookupCta),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLookupDialog(BuildContext context) async {
    final symbol = await showDialog<String>(
      context: context,
      builder: (context) => const _StockLookupDialog(),
    );

    if (symbol == null || symbol.isEmpty || !context.mounted) {
      return;
    }

    onLookup(symbol);
  }
}

class _StockLookupDialog extends StatefulWidget {
  const _StockLookupDialog();

  @override
  State<_StockLookupDialog> createState() => _StockLookupDialogState();
}

class _StockLookupDialogState extends State<_StockLookupDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.stocksLookupTitle),
      content: TextField(
        controller: _controller,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          labelText: l10n.stocksLookupLabel,
          hintText: l10n.stocksLookupHint,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonBack),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.of(context).pop(_controller.text.trim().toUpperCase()),
          child: Text(l10n.stocksLookupCta),
        ),
      ],
    );
  }
}
