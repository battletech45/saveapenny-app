import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/tokens.dart';

/// A circular avatar showing a name's initials, colored deterministically
/// from the name's hash so the same person always gets the same color. Used
/// wherever no profile photo exists (there is no asset pipeline for one).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 40});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = _initialsFor(name);
    final color = ChartPalette.forIndex(
      Theme.of(context).brightness == Brightness.dark
          ? ChartPalette.dark
          : ChartPalette.light,
      name.hashCode,
    );

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color.withValues(alpha: 0.18),
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontWeight: AppFontWeight.semibold,
          fontSize: size * 0.38,
        ),
      ),
    );
  }

  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0].toUpperCase());
    final initials = letters.join();
    return initials.isEmpty ? '?' : initials;
  }
}
