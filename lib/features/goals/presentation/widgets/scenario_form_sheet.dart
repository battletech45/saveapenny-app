import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/goals/application/goal_detail_controller.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/features/goals/presentation/widgets/goal_form_shared.dart';
import 'package:saveapenny/features/goals/presentation/widgets/goal_inputs_form.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class ScenarioFormSheet extends ConsumerStatefulWidget {
  const ScenarioFormSheet({
    super.key,
    required this.goalId,
    required this.goalType,
  });

  final String goalId;
  final GoalType goalType;

  @override
  ConsumerState<ScenarioFormSheet> createState() => _ScenarioFormSheetState();
}

class _ScenarioFormSheetState extends ConsumerState<ScenarioFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final GoalInputsFormData _inputsData;
  bool _isBaseline = false;
  bool _isSubmitting = false;
  Failure? _submissionFailure;

  @override
  void initState() {
    super.initState();
    _inputsData = GoalInputsFormData(defaultGoalInputs(widget.goalType));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _inputsData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                l10n.goalsScenarioCreateTitle,
                style: context.textTheme.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.goalsScenarioCreateSubtitle,
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              if (_submissionFailure != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                GoalSheetFailureNotice(failure: _submissionFailure!),
              ],
              const SizedBox(height: AppSpacing.xxl),
              TextFormField(
                controller: _nameController,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  labelText: l10n.goalsScenarioNameLabel,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      value.trim().length > 80) {
                    return l10n.goalsScenarioNameError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              SwitchListTile.adaptive(
                value: _isBaseline,
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        setState(() {
                          _isBaseline = value;
                        });
                      },
                title: Text(l10n.goalsScenarioBaselineLabel),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.goalsScenarioInputsLabel,
                style: context.textTheme.label.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GoalInputsFields(
                type: widget.goalType,
                data: _inputsData,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(
                  _isSubmitting
                      ? l10n.commonLoading
                      : l10n.goalsScenarioCreateCta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionFailure = null;
    });

    try {
      final inputs = _inputsData.toInputs(widget.goalType);

      await ref
          .read(goalDetailControllerProvider(widget.goalId).notifier)
          .createScenario(
            name: _nameController.text.trim(),
            inputs: inputs,
            isBaseline: _isBaseline,
          );
    } on Failure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _submissionFailure = failure;
      });
      return;
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _submissionFailure = Failure.unknown(message: error.toString());
      });
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }
}
