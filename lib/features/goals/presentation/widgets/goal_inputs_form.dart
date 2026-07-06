import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class GoalInputsFormData {
  GoalInputsFormData(Map<String, dynamic> inputs)
    : monthlyContributionController = TextEditingController(
        text: _readNumber(_extractValues(inputs), 'monthlyContribution'),
      ),
      expectedAnnualReturnController = TextEditingController(
        text: _readNumber(_extractValues(inputs), 'expectedAnnualReturn'),
      ),
      startBalanceController = TextEditingController(
        text: _readNumber(_extractValues(inputs), 'startBalance'),
      ),
      monthlyPaymentController = TextEditingController(
        text: _readNumber(_extractValues(inputs), 'monthlyPayment'),
      ),
      interestRateController = TextEditingController(
        text: _readNumber(_extractValues(inputs), 'interestRate'),
      ),
      currentBalanceController = TextEditingController(
        text: _readNumber(_extractValues(inputs), 'currentBalance'),
      ),
      currentSavingsController = TextEditingController(
        text: _readNumber(_extractValues(inputs), 'currentSavings'),
      ),
      retirementAgeController = TextEditingController(
        text: _readInteger(_extractValues(inputs), 'retirementAge'),
      ),
      currentIncomeController = TextEditingController(
        text: _readNumber(_extractValues(inputs), 'currentIncome'),
      ),
      targetIncomeController = TextEditingController(
        text: _readNumber(_extractValues(inputs), 'targetIncome'),
      ),
      timeHorizonMonthsController = TextEditingController(
        text: _readInteger(_extractValues(inputs), 'timeHorizonMonths'),
      );

  final TextEditingController monthlyContributionController;
  final TextEditingController expectedAnnualReturnController;
  final TextEditingController startBalanceController;
  final TextEditingController monthlyPaymentController;
  final TextEditingController interestRateController;
  final TextEditingController currentBalanceController;
  final TextEditingController currentSavingsController;
  final TextEditingController retirementAgeController;
  final TextEditingController currentIncomeController;
  final TextEditingController targetIncomeController;
  final TextEditingController timeHorizonMonthsController;

  void dispose() {
    monthlyContributionController.dispose();
    expectedAnnualReturnController.dispose();
    startBalanceController.dispose();
    monthlyPaymentController.dispose();
    interestRateController.dispose();
    currentBalanceController.dispose();
    currentSavingsController.dispose();
    retirementAgeController.dispose();
    currentIncomeController.dispose();
    targetIncomeController.dispose();
    timeHorizonMonthsController.dispose();
  }

  void applyDefaultsFor(GoalType type) {
    final defaults = defaultGoalInputs(type);
    monthlyContributionController.text = _readNumber(
      defaults,
      'monthlyContribution',
    );
    expectedAnnualReturnController.text = _readNumber(
      defaults,
      'expectedAnnualReturn',
    );
    startBalanceController.text = _readNumber(defaults, 'startBalance');
    monthlyPaymentController.text = _readNumber(defaults, 'monthlyPayment');
    interestRateController.text = _readNumber(defaults, 'interestRate');
    currentBalanceController.text = _readNumber(defaults, 'currentBalance');
    currentSavingsController.text = _readNumber(defaults, 'currentSavings');
    retirementAgeController.text = _readInteger(defaults, 'retirementAge');
    currentIncomeController.text = _readNumber(defaults, 'currentIncome');
    targetIncomeController.text = _readNumber(defaults, 'targetIncome');
    timeHorizonMonthsController.text = _readInteger(
      defaults,
      'timeHorizonMonths',
    );
  }

  Map<String, dynamic> toInputs(GoalType type) {
    final values = switch (type) {
      GoalType.savings || GoalType.purchase => <String, dynamic>{
        'monthlyContribution': _parseDecimal(monthlyContributionController),
        'expectedAnnualReturn': _parseDecimal(expectedAnnualReturnController),
        'startBalance': _parseDecimal(startBalanceController),
      },
      GoalType.debtPayoff => <String, dynamic>{
        'monthlyPayment': _parseDecimal(monthlyPaymentController),
        'interestRate': _parseDecimal(interestRateController),
        'currentBalance': _parseDecimal(currentBalanceController),
      },
      GoalType.retirement => <String, dynamic>{
        'currentSavings': _parseDecimal(currentSavingsController),
        'monthlyContribution': _parseDecimal(monthlyContributionController),
        'expectedAnnualReturn': _parseDecimal(expectedAnnualReturnController),
        'retirementAge': _parseInteger(retirementAgeController),
      },
      GoalType.incomeTarget => <String, dynamic>{
        'currentIncome': _parseDecimal(currentIncomeController),
        'targetIncome': _parseDecimal(targetIncomeController),
        'timeHorizonMonths': _parseInteger(timeHorizonMonthsController),
      },
    };

    return <String, dynamic>{
      'version': 1,
      'type': _goalTypeToWire(type),
      'values': values,
    };
  }
}

class GoalInputsFields extends StatelessWidget {
  const GoalInputsFields({
    super.key,
    required this.type,
    required this.data,
    required this.enabled,
  });

  final GoalType type;
  final GoalInputsFormData data;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: switch (type) {
        GoalType.savings || GoalType.purchase => <Widget>[
          _decimalField(
            controller: data.monthlyContributionController,
            enabled: enabled,
            label: l10n.goalsMonthlyContributionLabel,
            l10n: l10n,
          ),
          const SizedBox(height: AppSpacing.lg),
          _decimalField(
            controller: data.expectedAnnualReturnController,
            enabled: enabled,
            label: l10n.goalsExpectedAnnualReturnLabel,
            l10n: l10n,
          ),
          const SizedBox(height: AppSpacing.lg),
          _decimalField(
            controller: data.startBalanceController,
            enabled: enabled,
            label: l10n.goalsStartBalanceLabel,
            l10n: l10n,
          ),
        ],
        GoalType.debtPayoff => <Widget>[
          _decimalField(
            controller: data.monthlyPaymentController,
            enabled: enabled,
            label: l10n.goalsMonthlyPaymentLabel,
            l10n: l10n,
          ),
          const SizedBox(height: AppSpacing.lg),
          _decimalField(
            controller: data.interestRateController,
            enabled: enabled,
            label: l10n.goalsInterestRateLabel,
            l10n: l10n,
          ),
          const SizedBox(height: AppSpacing.lg),
          _decimalField(
            controller: data.currentBalanceController,
            enabled: enabled,
            label: l10n.goalsCurrentBalanceLabel,
            l10n: l10n,
          ),
        ],
        GoalType.retirement => <Widget>[
          _decimalField(
            controller: data.currentSavingsController,
            enabled: enabled,
            label: l10n.goalsCurrentSavingsLabel,
            l10n: l10n,
          ),
          const SizedBox(height: AppSpacing.lg),
          _decimalField(
            controller: data.monthlyContributionController,
            enabled: enabled,
            label: l10n.goalsMonthlyContributionLabel,
            l10n: l10n,
          ),
          const SizedBox(height: AppSpacing.lg),
          _decimalField(
            controller: data.expectedAnnualReturnController,
            enabled: enabled,
            label: l10n.goalsExpectedAnnualReturnLabel,
            l10n: l10n,
          ),
          const SizedBox(height: AppSpacing.lg),
          _integerField(
            controller: data.retirementAgeController,
            enabled: enabled,
            label: l10n.goalsRetirementAgeLabel,
            l10n: l10n,
          ),
        ],
        GoalType.incomeTarget => <Widget>[
          _decimalField(
            controller: data.currentIncomeController,
            enabled: enabled,
            label: l10n.goalsCurrentIncomeLabel,
            l10n: l10n,
          ),
          const SizedBox(height: AppSpacing.lg),
          _decimalField(
            controller: data.targetIncomeController,
            enabled: enabled,
            label: l10n.goalsTargetIncomeLabel,
            l10n: l10n,
          ),
          const SizedBox(height: AppSpacing.lg),
          _integerField(
            controller: data.timeHorizonMonthsController,
            enabled: enabled,
            label: l10n.goalsTimeHorizonMonthsLabel,
            l10n: l10n,
          ),
        ],
      },
    );
  }

  Widget _decimalField({
    required TextEditingController controller,
    required bool enabled,
    required String label,
    required AppLocalizations l10n,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      validator: (value) => _validateDecimal(l10n, value),
    );
  }

  Widget _integerField({
    required TextEditingController controller,
    required bool enabled,
    required String label,
    required AppLocalizations l10n,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (value) => _validateInteger(l10n, value),
    );
  }

  String? _validateDecimal(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.authRequiredFieldError;
    }

    if (num.tryParse(value.trim()) == null) {
      return l10n.goalsInputNumberError;
    }

    return null;
  }

  String? _validateInteger(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.authRequiredFieldError;
    }

    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return l10n.goalsInputIntegerError;
    }

    return null;
  }
}

Map<String, dynamic> defaultGoalInputs(GoalType type) {
  return <String, dynamic>{
    'version': 1,
    'type': _goalTypeToWire(type),
    'values': switch (type) {
      GoalType.savings || GoalType.purchase => <String, dynamic>{
        'monthlyContribution': 0,
        'expectedAnnualReturn': 0,
        'startBalance': 0,
      },
      GoalType.debtPayoff => <String, dynamic>{
        'monthlyPayment': 0,
        'interestRate': 0,
        'currentBalance': 0,
      },
      GoalType.retirement => <String, dynamic>{
        'currentSavings': 0,
        'monthlyContribution': 0,
        'expectedAnnualReturn': 0,
        'retirementAge': 65,
      },
      GoalType.incomeTarget => <String, dynamic>{
        'currentIncome': 0,
        'targetIncome': 0,
        'timeHorizonMonths': 12,
      },
    },
  };
}

Map<String, dynamic> _extractValues(Map<String, dynamic> inputs) {
  final rawValues = inputs['values'];
  if (rawValues is Map<String, dynamic>) {
    return rawValues;
  }
  return inputs;
}

String _goalTypeToWire(GoalType value) {
  return switch (value) {
    GoalType.savings => 'SAVINGS',
    GoalType.debtPayoff => 'DEBT_PAYOFF',
    GoalType.purchase => 'PURCHASE',
    GoalType.retirement => 'RETIREMENT',
    GoalType.incomeTarget => 'INCOME_TARGET',
  };
}

String _readNumber(Map<String, dynamic> inputs, String key) {
  final value = inputs[key];
  if (value is num) {
    return value.toString();
  }
  return '';
}

String _readInteger(Map<String, dynamic> inputs, String key) {
  final value = inputs[key];
  if (value is int) {
    return value.toString();
  }
  if (value is num) {
    return value.toInt().toString();
  }
  return '';
}

num _parseDecimal(TextEditingController controller) {
  return num.parse(controller.text.trim());
}

int _parseInteger(TextEditingController controller) {
  return int.parse(controller.text.trim());
}
