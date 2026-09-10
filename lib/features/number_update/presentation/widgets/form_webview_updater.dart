import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/number_update_providers.dart';
import '../../domain/entities/number_update_entry.dart';

/// Drives a supplier's own public "refresh number" page inside a real
/// `WebView` for any supplier whose form requires a Google reCAPTCHA v3
/// token — only a genuine page load on the registered domain can produce
/// one (see PROGRESS.md's Number Update entries for Sky and SmileSim,
/// both reverse-engineered this way). Loads [url], fills the number into
/// the page's own form and submits it through its own JavaScript (so
/// reCAPTCHA executes exactly as it would for a person using a browser),
/// then polls the same page's own result element until it reaches a
/// final state — no separate polling/status logic of our own needed,
/// since the page already does all of that itself.
///
/// Sky and SmileSim's pages turned out to share the exact same DOM
/// shape (`#ph` input, `#f` form, `#r` result element with an `'s'`/`'e'`
/// class for success/error, `#rm` message text) — evidently the same
/// underlying template — so one generic driver covers both instead of
/// duplicating this per supplier.
class FormWebViewUpdater {
  FormWebViewUpdater._();

  static Future<NumberUpdateResult> run(BuildContext context, String phoneNumber, {required String url}) async {
    final result = await showDialog<NumberUpdateResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FormWebViewDialog(phoneNumber: phoneNumber, url: url),
    );
    return result ?? const NumberUpdateResult(status: NumberUpdateStatus.failed, message: 'Cancelled.');
  }
}

class _FormWebViewDialog extends StatefulWidget {
  final String phoneNumber;
  final String url;

  const _FormWebViewDialog({required this.phoneNumber, required this.url});

  @override
  State<_FormWebViewDialog> createState() => _FormWebViewDialogState();
}

class _FormWebViewDialogState extends State<_FormWebViewDialog> {
  static const _pollInterval = Duration(seconds: 2);
  static const _timeoutSeconds = 220; // Both pages warn "1 to 3 minutes".

  late final WebViewController _controller;
  Timer? _pollTimer;
  bool _submitted = false;
  bool _finished = false;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (_) => _onPageLoaded()))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _onPageLoaded() async {
    if (_submitted) return;
    _submitted = true;
    final safeNumber = widget.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    try {
      await _controller.runJavaScript('''
        document.getElementById('ph').value = '$safeNumber';
        document.getElementById('f').onsubmit({preventDefault: function(){}});
      ''');
    } catch (_) {
      _finish(const NumberUpdateResult(status: NumberUpdateStatus.failed, message: 'Could not submit the form.'));
      return;
    }
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkResult());
  }

  Future<void> _checkResult() async {
    if (_finished) return;
    _elapsedSeconds += _pollInterval.inSeconds;
    if (_elapsedSeconds >= _timeoutSeconds) {
      _finish(NumberUpdateResult(status: NumberUpdateStatus.failed, message: 'numberUpdate.webviewDialog.timeout'.tr()));
      return;
    }

    try {
      final stateResult = await _controller.runJavaScriptReturningResult('''
        (function() {
          var r = document.getElementById('r');
          if (!r) return 'none';
          var classes = r.className.split(' ');
          if (classes.indexOf('s') !== -1) return 'success';
          if (classes.indexOf('e') !== -1) return 'error';
          return 'pending';
        })()
      ''');
      final state = _unwrapJsString(stateResult);
      if (state == 'success' || state == 'error') {
        final messageResult = await _controller.runJavaScriptReturningResult(
          "document.getElementById('rm') ? document.getElementById('rm').textContent : ''",
        );
        final message = _unwrapJsString(messageResult);
        _finish(NumberUpdateResult(
          status: state == 'success' ? NumberUpdateStatus.success : NumberUpdateStatus.notFound,
          message: message.isEmpty ? 'numberUpdate.errors.providerRejected'.tr() : message,
        ));
      }
    } catch (_) {
      // A transient JS-evaluation failure (page mid-navigation, etc.) —
      // just try again on the next tick rather than failing the whole
      // attempt over one missed poll.
    }
  }

  String _unwrapJsString(Object result) {
    final raw = result.toString();
    if (raw.length >= 2 && raw.startsWith('"') && raw.endsWith('"')) {
      try {
        return jsonDecode(raw) as String;
      } catch (_) {
        // Fall through to the raw value.
      }
    }
    return raw;
  }

  void _finish(NumberUpdateResult result) {
    if (_finished || !mounted) return;
    _finished = true;
    _pollTimer?.cancel();
    Navigator.of(context).pop(result);
  }

  void _cancel() {
    _finish(const NumberUpdateResult(status: NumberUpdateStatus.failed, message: 'Cancelled.'));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('numberUpdate.webviewDialog.title'.tr(), style: AppTextStyles.cardTitle(colors.textPrimary), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text('numberUpdate.webviewDialog.subtitle'.tr(), style: AppTextStyles.body(colors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 260,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.button),
                child: WebViewWidget(controller: _controller),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: _cancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.danger,
                side: BorderSide(color: colors.danger),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
              ),
              child: Text('common.cancel'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
