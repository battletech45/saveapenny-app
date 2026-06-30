import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SaveAPenny'**
  String get appTitle;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get commonNotAvailable;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @phaseZeroPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Foundation ready'**
  String get phaseZeroPlaceholderTitle;

  /// No description provided for @phaseZeroPlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Phase 0 shell is running with theme, routing, localization, and shared states wired.'**
  String get phaseZeroPlaceholderBody;

  /// No description provided for @phaseZeroBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview balance'**
  String get phaseZeroBalanceLabel;

  /// No description provided for @emptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyStateTitle;

  /// No description provided for @emptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **'This area will fill in as features are implemented.'**
  String get emptyStateMessage;

  /// No description provided for @failureGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get failureGenericTitle;

  /// No description provided for @failureGenericMessage.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get failureGenericMessage;

  /// No description provided for @failureNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection problem'**
  String get failureNetworkTitle;

  /// No description provided for @failureNetworkMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get failureNetworkMessage;

  /// No description provided for @failureUnauthenticatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get failureUnauthenticatedTitle;

  /// No description provided for @failureUnauthenticatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again.'**
  String get failureUnauthenticatedMessage;

  /// No description provided for @failureRateLimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Too many requests'**
  String get failureRateLimitedTitle;

  /// No description provided for @failureRateLimitedMessage.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment before trying again.'**
  String get failureRateLimitedMessage;

  /// No description provided for @failureFeatureDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Feature unavailable'**
  String get failureFeatureDisabledTitle;

  /// No description provided for @failureFeatureDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'This feature is currently disabled on the server.'**
  String get failureFeatureDisabledMessage;

  /// No description provided for @failureValidationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Please review your input'**
  String get failureValidationFailedTitle;

  /// No description provided for @failureValidationFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Some fields need attention before you can continue.'**
  String get failureValidationFailedMessage;

  /// No description provided for @failureInvalidPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid password'**
  String get failureInvalidPasswordTitle;

  /// No description provided for @failureInvalidPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'The password does not meet the server requirements.'**
  String get failureInvalidPasswordMessage;

  /// No description provided for @failureInvalidCredentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Incorrect credentials'**
  String get failureInvalidCredentialsTitle;

  /// No description provided for @failureInvalidCredentialsMessage.
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect.'**
  String get failureInvalidCredentialsMessage;

  /// No description provided for @failureResourceNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get failureResourceNotFoundTitle;

  /// No description provided for @failureResourceNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The requested resource could not be found.'**
  String get failureResourceNotFoundMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
