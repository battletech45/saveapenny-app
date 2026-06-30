// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SaveAPenny';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonNotAvailable => 'Not available';

  @override
  String get homeTitle => 'Home';

  @override
  String get loginTitle => 'Login';

  @override
  String get phaseZeroPlaceholderTitle => 'Foundation ready';

  @override
  String get phaseZeroPlaceholderBody =>
      'Phase 0 shell is running with theme, routing, localization, and shared states wired.';

  @override
  String get phaseZeroBalanceLabel => 'Preview balance';

  @override
  String get emptyStateTitle => 'Nothing here yet';

  @override
  String get emptyStateMessage =>
      'This area will fill in as features are implemented.';

  @override
  String get failureGenericTitle => 'Something went wrong';

  @override
  String get failureGenericMessage => 'Please try again.';

  @override
  String get failureNetworkTitle => 'Connection problem';

  @override
  String get failureNetworkMessage =>
      'Check your internet connection and try again.';

  @override
  String get failureUnauthenticatedTitle => 'Session expired';

  @override
  String get failureUnauthenticatedMessage => 'Please sign in again.';

  @override
  String get failureRateLimitedTitle => 'Too many requests';

  @override
  String get failureRateLimitedMessage =>
      'Please wait a moment before trying again.';

  @override
  String get failureFeatureDisabledTitle => 'Feature unavailable';

  @override
  String get failureFeatureDisabledMessage =>
      'This feature is currently disabled on the server.';

  @override
  String get failureValidationFailedTitle => 'Please review your input';

  @override
  String get failureValidationFailedMessage =>
      'Some fields need attention before you can continue.';

  @override
  String get failureInvalidPasswordTitle => 'Invalid password';

  @override
  String get failureInvalidPasswordMessage =>
      'The password does not meet the server requirements.';

  @override
  String get failureInvalidCredentialsTitle => 'Incorrect credentials';

  @override
  String get failureInvalidCredentialsMessage =>
      'The email or password is incorrect.';

  @override
  String get failureResourceNotFoundTitle => 'Not found';

  @override
  String get failureResourceNotFoundMessage =>
      'The requested resource could not be found.';
}
