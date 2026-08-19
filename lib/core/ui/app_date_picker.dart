import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final normalizedFirstDate = DateUtils.dateOnly(firstDate);
  final normalizedLastDate = DateUtils.dateOnly(lastDate);
  final normalizedInitialDate = _clampDate(
    DateUtils.dateOnly(initialDate),
    normalizedFirstDate,
    normalizedLastDate,
  );
  var selectedDate = normalizedInitialDate;

  return showAppModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: false,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      final theme = Theme.of(context);

      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(
                  bottom: BorderSide(color: context.colors.border),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.commonCancel),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(selectedDate),
                      child: Text(l10n.commonContinue),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 216,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: theme.brightness,
                  primaryColor: theme.colorScheme.primary,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: context.textTheme.title,
                  ),
                ),
                child: CupertinoDatePicker(
                  backgroundColor: context.colors.surface,
                  initialDateTime: normalizedInitialDate,
                  maximumDate: normalizedLastDate,
                  minimumDate: normalizedFirstDate,
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (value) {
                    selectedDate = DateUtils.dateOnly(value);
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

DateTime _clampDate(DateTime value, DateTime firstDate, DateTime lastDate) {
  if (value.isBefore(firstDate)) {
    return firstDate;
  }
  if (value.isAfter(lastDate)) {
    return lastDate;
  }
  return value;
}
