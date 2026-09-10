import 'package:url_launcher/url_launcher.dart';

/// Opens a WhatsApp chat / the SMS composer for a customer's contact
/// number — shared by any page with a "message this customer" action
/// (Customer Detail today).
class ContactLauncher {
  ContactLauncher._();

  /// `wa.me` only resolves a number that's digits-only with its country
  /// code included (no `+`, no leading `0`/`00`) — this strips
  /// everything else a seller might have typed (spaces, dashes,
  /// parentheses, a leading `+`) but can't guess a missing country code,
  /// so a number saved in purely local format (e.g. a leading `0`) may
  /// not resolve. That's a data-entry concern, not something to silently
  /// "fix" here by guessing a country.
  static Future<void> openWhatsApp(String phoneNumber) async {
    final digits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;
    await launchUrl(Uri.parse('https://wa.me/$digits'), mode: LaunchMode.externalApplication);
  }

  /// The `sms:` scheme accepts the number largely as typed (unlike
  /// `wa.me`, no country-code normalization needed) — the device's own
  /// SMS app handles it the same way tapping a phone number anywhere
  /// else would.
  static Future<void> openSms(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) return;
    await launchUrl(Uri.parse('sms:$phoneNumber'));
  }
}
