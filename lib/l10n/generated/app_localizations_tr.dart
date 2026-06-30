// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'SaveAPenny';

  @override
  String get commonRetry => 'Tekrar dene';

  @override
  String get commonContinue => 'Devam et';

  @override
  String get commonBack => 'Geri';

  @override
  String get commonLoading => 'Yukleniyor...';

  @override
  String get commonNotAvailable => 'Kullanilamiyor';

  @override
  String get homeTitle => 'Ana Sayfa';

  @override
  String get loginTitle => 'Giris';

  @override
  String get phaseZeroPlaceholderTitle => 'Temel hazir';

  @override
  String get phaseZeroPlaceholderBody =>
      'Faz 0 kabugu tema, yonlendirme, yerlestirme ve ortak durum bilesenleriyle calisiyor.';

  @override
  String get phaseZeroBalanceLabel => 'Onizleme bakiyesi';

  @override
  String get emptyStateTitle => 'Henuz bir sey yok';

  @override
  String get emptyStateMessage => 'Ozellikler uygulandikca bu alan dolacak.';

  @override
  String get failureGenericTitle => 'Bir sorun olustu';

  @override
  String get failureGenericMessage => 'Lutfen tekrar deneyin.';

  @override
  String get failureNetworkTitle => 'Baglanti sorunu';

  @override
  String get failureNetworkMessage =>
      'Internet baglantinizi kontrol edip tekrar deneyin.';

  @override
  String get failureUnauthenticatedTitle => 'Oturum suresi doldu';

  @override
  String get failureUnauthenticatedMessage => 'Lutfen yeniden giris yapin.';

  @override
  String get failureRateLimitedTitle => 'Cok fazla istek';

  @override
  String get failureRateLimitedMessage =>
      'Tekrar denemeden once biraz bekleyin.';

  @override
  String get failureFeatureDisabledTitle => 'Ozellik kullanilamiyor';

  @override
  String get failureFeatureDisabledMessage =>
      'Bu ozellik su anda sunucuda devre disi.';

  @override
  String get failureValidationFailedTitle => 'Girdinizi kontrol edin';

  @override
  String get failureValidationFailedMessage =>
      'Devam etmeden once bazi alanlar duzeltilmeli.';

  @override
  String get failureInvalidPasswordTitle => 'Gecersiz sifre';

  @override
  String get failureInvalidPasswordMessage =>
      'Sifre sunucu gereksinimlerini karsilamiyor.';

  @override
  String get failureInvalidCredentialsTitle => 'Hatali kimlik bilgileri';

  @override
  String get failureInvalidCredentialsMessage => 'E-posta veya sifre hatali.';

  @override
  String get failureResourceNotFoundTitle => 'Bulunamadi';

  @override
  String get failureResourceNotFoundMessage => 'Istenen kaynak bulunamadi.';
}
