import 'package:flutter/material.dart';

import 'package:saveapenny/features/auth/presentation/widgets/auth_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.enabled,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  var _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: l10n.commonPassword,
        hintText: l10n.authPasswordHint,
        suffixIcon: IconButton(
          onPressed: widget.enabled
              ? () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                }
              : null,
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
      ),
      validator: (value) => validateRequired(l10n, value),
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}
