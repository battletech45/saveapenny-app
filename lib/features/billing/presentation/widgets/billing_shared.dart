import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/l10n/generated/app_localizations.dart';

const String upgradeRoute = '/upgrade';

void openUpgrade(BuildContext context) {
  unawaited(context.push(upgradeRoute));
}

class BillingUpgradeTextButton extends StatelessWidget {
  const BillingUpgradeTextButton({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => openUpgrade(context),
      child: Text(label ?? AppLocalizations.of(context).paywallUpgradeCta),
    );
  }
}

class BillingUpgradeElevatedButton extends StatelessWidget {
  const BillingUpgradeElevatedButton({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => openUpgrade(context),
      child: Text(label ?? AppLocalizations.of(context).paywallUpgradeCta),
    );
  }
}
