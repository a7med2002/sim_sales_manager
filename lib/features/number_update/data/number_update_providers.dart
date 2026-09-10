import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';

import '../../../../core/number_update/number_update_provider.dart';
import '../domain/entities/number_update_entry.dart';

class NumberUpdateResult {
  final NumberUpdateStatus status;
  final String message;

  const NumberUpdateResult({required this.status, required this.message});
}

/// Calls the given provider's own (undocumented — no official API exists
/// for any of these, see PROGRESS.md) refresh endpoint for [phoneNumber].
/// Each provider's shape was reverse-engineered from its public web
/// page's own JavaScript — see PROGRESS.md's Number Update entry for how
/// each one was found and verified. Uses `dart:io`'s `HttpClient`
/// directly rather than adding an HTTP package: three plain JSON POSTs
/// don't need one.
Future<NumberUpdateResult> callNumberUpdateProvider(NumberUpdateProviderKey provider, String phoneNumber) async {
  switch (provider) {
    case NumberUpdateProviderKey.liyan:
      return _postPlainTextResponse(
        url: 'https://api.layan-t.net/api/Subscribtions/CustomersRefreshNumber',
        body: {'number': phoneNumber},
        headers: {'LANG': 'ar'},
      );
    case NumberUpdateProviderKey.quickline:
      return _postPlainTextResponse(
        url: 'https://api.quicklinecrm.com/api/Subscriptions/CustomersRefreshNumber/New',
        body: {'phoneNumber': phoneNumber},
        headers: {'LANG': 'ar'},
      );
    case NumberUpdateProviderKey.areen:
      return _postAreen(phoneNumber);
    case NumberUpdateProviderKey.aloha:
      return _postAloha(phoneNumber);
    case NumberUpdateProviderKey.smilesim:
    case NumberUpdateProviderKey.sky:
      // Both need a real browser context (reCAPTCHA v3) — handled by
      // `FormWebViewUpdater` instead, which `NumberUpdateCubit._callProvider`
      // routes to directly. These cases only exist so the switch stays
      // exhaustive; neither is ever actually reached.
      throw UnsupportedError('$provider is handled via FormWebViewUpdater, not callNumberUpdateProvider.');
  }
}

/// Liyan/QuickLine share the same backend template: a POST that replies
/// with a plain-text body — success on 2xx, an error message on
/// anything else (verified as 400 for "not found" on both, see
/// PROGRESS.md).
Future<NumberUpdateResult> _postPlainTextResponse({
  required String url,
  required Map<String, String> body,
  required Map<String, String> headers,
}) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    headers.forEach(request.headers.set);
    request.write(jsonEncode(body));
    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return NumberUpdateResult(status: NumberUpdateStatus.success, message: text.trim().isEmpty ? 'numberUpdate.status.success'.tr() : text.trim());
    }
    return NumberUpdateResult(status: NumberUpdateStatus.notFound, message: text.trim().isEmpty ? 'numberUpdate.errors.providerRejected'.tr() : text.trim());
  } catch (_) {
    return NumberUpdateResult(status: NumberUpdateStatus.failed, message: 'numberUpdate.errors.providerUnreachable'.tr());
  } finally {
    client.close(force: true);
  }
}

/// Aloha's form (not JSON — a plain jQuery `$.ajax` POST with no
/// `contentType` override, so it's `application/x-www-form-urlencoded`
/// like a normal HTML form) also carries a `website` honeypot field —
/// left empty here, same as a real visitor never fills it in. Replies
/// with JSON — `{"status": true/false, "message": "..."}`, `message`
/// itself already a 3-line Arabic/Hebrew/English string on failure
/// (verified with a real call).
Future<NumberUpdateResult> _postAloha(String phoneNumber) async {
  final client = HttpClient();
  try {
    final body = 'phone_number=${Uri.encodeQueryComponent(phoneNumber)}&website=';
    final request = await client.postUrl(Uri.parse('https://refresh.telecom.co.il/home/refreshNumber'));
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded');
    request.headers.set('X-Requested-With', 'XMLHttpRequest');
    request.write(body);
    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();

    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      return NumberUpdateResult(status: NumberUpdateStatus.failed, message: 'numberUpdate.errors.providerUnreachable'.tr());
    }
    final success = decoded['status'] == true;
    final message = (decoded['message'] as String?) ?? '';
    if (success) {
      return NumberUpdateResult(status: NumberUpdateStatus.success, message: message.isEmpty ? 'numberUpdate.status.success'.tr() : message);
    }
    return NumberUpdateResult(status: NumberUpdateStatus.notFound, message: message.isEmpty ? 'numberUpdate.errors.providerRejected'.tr() : message);
  } catch (_) {
    return NumberUpdateResult(status: NumberUpdateStatus.failed, message: 'numberUpdate.errors.providerUnreachable'.tr());
  } finally {
    client.close(force: true);
  }
}

/// Areen replies with JSON — `{"StatusCode": 23, "Message": "..."}`,
/// where 23 is success and anything else is a supplier-side message
/// (verified with a real call, see PROGRESS.md).
Future<NumberUpdateResult> _postAreen(String phoneNumber) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse('https://api.areen.net/api/common/RefreshMobileNumber'));
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.write(jsonEncode({'MobNumber': phoneNumber}));
    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();

    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      return NumberUpdateResult(status: NumberUpdateStatus.failed, message: 'numberUpdate.errors.providerUnreachable'.tr());
    }
    final statusCode = decoded['StatusCode'] as int?;
    final message = (decoded['Message'] as String?) ?? '';
    if (statusCode == 23) {
      return NumberUpdateResult(status: NumberUpdateStatus.success, message: message.isEmpty ? 'numberUpdate.status.success'.tr() : message);
    }
    return NumberUpdateResult(status: NumberUpdateStatus.notFound, message: message.isEmpty ? 'numberUpdate.errors.providerRejected'.tr() : message);
  } catch (_) {
    return NumberUpdateResult(status: NumberUpdateStatus.failed, message: 'numberUpdate.errors.providerUnreachable'.tr());
  } finally {
    client.close(force: true);
  }
}
