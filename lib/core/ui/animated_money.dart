import 'package:flutter/material.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/tokens.dart';

class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney({
    super.key,
    required this.amount,
    required this.currencyCode,
    required this.style,
  });

  final num amount;
  final String currencyCode;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<num>(
      tween: Tween<num>(begin: 0, end: amount),
      duration: AppDuration.slow,
      curve: Curves.easeInOutCubic,
      builder: (context, value, _) {
        final formatted = MoneyFormatter.format(
          context: context,
          amount: value,
          currencyCode: currencyCode,
        );
        return Text(
          formatted.text,
          style: style.copyWith(color: formatted.color),
        );
      },
    );
  }
}
