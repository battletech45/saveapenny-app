import 'package:flutter/material.dart';

import 'package:saveapenny/features/auth/presentation/widgets/auth_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class AuthEmailField extends StatelessWidget {
  const AuthEmailField({
    super.key,
    required this.controller,
    required this.enabled,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final bool enabled;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: l10n.commonEmail,
        hintText: l10n.authEmailHint,
      ),
      validator: (value) => validateEmail(l10n, value),
    );
  }
}
