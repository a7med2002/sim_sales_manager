import 'package:easy_localization/easy_localization.dart';

/// Which supplier's own (undocumented, reverse-engineered) refresh
/// endpoint a company maps to — see
/// `features/number_update/data/number_update_providers.dart` for the
/// actual HTTP calls. Lives in `core/` because both `features/companies/`
/// (where a seller picks a company's provider) and
/// `features/number_update/` (where it's actually called) need it.
enum NumberUpdateProviderKey { liyan, areen, quickline, aloha, smilesim, sky }

extension NumberUpdateProviderKeyLabel on NumberUpdateProviderKey {
  String get label {
    switch (this) {
      case NumberUpdateProviderKey.liyan:
        return 'numberUpdateProvider.liyan'.tr();
      case NumberUpdateProviderKey.areen:
        return 'numberUpdateProvider.areen'.tr();
      case NumberUpdateProviderKey.quickline:
        return 'numberUpdateProvider.quickline'.tr();
      case NumberUpdateProviderKey.aloha:
        return 'numberUpdateProvider.aloha'.tr();
      case NumberUpdateProviderKey.smilesim:
        return 'numberUpdateProvider.smilesim'.tr();
      case NumberUpdateProviderKey.sky:
        return 'numberUpdateProvider.sky'.tr();
    }
  }
}

String numberUpdateProviderToRow(NumberUpdateProviderKey? key) {
  switch (key) {
    case NumberUpdateProviderKey.liyan:
      return 'liyan';
    case NumberUpdateProviderKey.areen:
      return 'areen';
    case NumberUpdateProviderKey.quickline:
      return 'quickline';
    case NumberUpdateProviderKey.aloha:
      return 'aloha';
    case NumberUpdateProviderKey.smilesim:
      return 'smilesim';
    case NumberUpdateProviderKey.sky:
      return 'sky';
    case null:
      return '';
  }
}

NumberUpdateProviderKey? numberUpdateProviderFromRow(String? value) {
  switch (value) {
    case 'liyan':
      return NumberUpdateProviderKey.liyan;
    case 'areen':
      return NumberUpdateProviderKey.areen;
    case 'quickline':
      return NumberUpdateProviderKey.quickline;
    case 'aloha':
      return NumberUpdateProviderKey.aloha;
    case 'smilesim':
      return NumberUpdateProviderKey.smilesim;
    case 'sky':
      return NumberUpdateProviderKey.sky;
    default:
      return null;
  }
}
