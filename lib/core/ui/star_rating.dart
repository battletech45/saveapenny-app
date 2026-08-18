import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';

/// A tap-to-rate row of 5 stars, replacing a numeric rating dropdown. Used
/// read-only (no [onChanged]) or interactively in the feedback form.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    this.onChanged,
    this.starSize = 32,
    this.maxStars = 5,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final double starSize;
  final int maxStars;

  @override
  Widget build(BuildContext context) {
    final color = context.finance.warning;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var i = 1; i <= maxStars; i++)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: GestureDetector(
              onTap: onChanged == null ? null : () => onChanged!(i),
              child: Icon(
                i <= value ? Icons.star_rounded : Icons.star_outline_rounded,
                color: color,
                size: starSize,
              ),
            ),
          ),
      ],
    );
  }
}
