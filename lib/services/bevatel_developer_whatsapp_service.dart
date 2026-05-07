import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/app_formatters.dart';
import '../models/create_invoice_model.dart';
import '../widgets/whatsapp_a4_tax_invoice_pdf.dart';
import 'bevatel_chat_credentials.dart';
import 'bevatel_invoice_pdf_host.dart';

/// Direct **Bevatel Chat** developer API (no Filter backend).
///
/// `POST https://chat.bevatel.com/developer/api/v1/messages`
///
/// - **PDF**: prefers **`pdfDocumentOverride`** (colourful cashier preview raster PDF). If omitted,
///   builds a bilingual **vector A4** fallback, uploads HTTPS, then sends `parameters.media`.
///   Requires a Meta‑approved template whose **header is a document** (name must match).
/// - **Text only**: sends `parameters.body` lines (requires a matching text template).
class BevatelDeveloperWhatsappService {
  BevatelDeveloperWhatsappService._();

  static const String _messagesUrl = String.fromEnvironment(
    'BEVATEL_DEVELOPER_API_URL',
    defaultValue: 'https://chat.bevatel.com/developer/api/v1/messages',
  );

  /// Dashboard often shows **EN** / **AR** — Meta API expects locales like `en`, `en_US`, `ar`.
  static String _normalizeTemplateLocale(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return 'en';
    final noDash = s.replaceAll('-', '_');
    final up = noDash.toUpperCase();
    if (up == 'EN') return 'en';
    if (up == 'AR') return 'ar';
    final m = RegExp(r'^([a-zA-Z]{2})_([a-zA-Z]{2})$').firstMatch(noDash);
    if (m != null) {
      return '${m[1]!.toLowerCase()}_${m[2]!.toUpperCase()}';
    }
    if (RegExp(r'^[a-zA-Z]{2}$').hasMatch(noDash)) {
      return noDash.toLowerCase();
    }
    return s;
  }

  /// Prefer user’s value first, then common Meta variants when Bevatel returns template 404.
  static List<String> _templateLocaleFallbacks(String normalized) {
    final n = normalized.trim();
    final out = <String>[];
    void add(String x) {
      final t = x.trim();
      if (t.isEmpty || out.contains(t)) return;
      out.add(t);
    }

    add(n);
    final lower = n.toLowerCase();
    if (lower == 'en') {
      add('en_US');
      add('en_GB');
    } else if (lower == 'en_us' || n == 'en_US') {
      add('en');
      add('en_GB');
    } else if (lower == 'en_gb' || n == 'en_GB') {
      add('en');
      add('en_US');
    } else if (lower == 'ar') {
      add('ar_SA');
    } else if (lower == 'ar_sa' || n == 'ar_SA') {
      add('ar');
    }
    return out;
  }

  static bool _responseLooksLikeMissingTemplate(http.Response res) {
    if (res.statusCode != 404) return false;
    try {
      final j = jsonDecode(res.body);
      if (j is! Map) return false;
      final err = '${j['error'] ?? ''} ${j['message'] ?? ''}'.toLowerCase();
      return err.contains('template');
    } catch (_) {
      return res.body.toLowerCase().contains('template');
    }
  }

  static String? _hintIfTemplateParameterMismatch(String responseBody) {
    final s = responseBody.toLowerCase();
    if (!s.contains('132000') && !s.contains('number of parameters')) {
      return null;
    }
    return '\n\nWhatsApp #132000 = **parameter count mismatch**. Your template defines how many '
        '{{n}} placeholders exist.\n• **test4**-style templates (fixed Arabic/English body, no {{1}}) '
        '→ long-press Done and turn **OFF** “Also send caption lines”; only send the PDF (**media**).\n• '
        'If that switch is ON, add the same number of body variables to the template as lines we send, '
        'in order.';
  }

  static String? _normalizePhoneE164(String? raw) {
    final d = normalizeSaudiMobileTo966Digits(raw);
    if (d == null) return null;
    return '+$d';
  }

  static Future<void> sendInvoiceTemplate({
    required Invoice invoice,
    required String paymentMethodText,
    List<bool>? maintenanceChecksFallback,
    /// Prefer **cashier colourful preview raster** → PDF (popup); if `null`, builds vector PDF fallback.
    Uint8List? pdfDocumentOverride,
  }) async {
    final creds = await BevatelChatCredentials.resolve();
    if (creds == null) {
      throw StateError(
        'Bevatel not configured. Long‑press **Done** and save api_account_id, '
        'api_access_token, inbox_id, template name.',
      );
    }

    if (creds.templateName.trim().isEmpty) {
      throw StateError(
        'Template name is empty. Long‑press Done and enter the **exact** name of your '
        'approved WhatsApp template (e.g. invoice with DOCUMENT header for PDF).',
      );
    }

    if (creds.templateName.trim().toLowerCase() == 'hello_world') {
      throw StateError(
        'Template name "hello_world" is only a Meta sample — it is not on your WhatsApp '
        'Business account, so Bevatel returns 404. Long‑press **Done** and replace it with '
        'the exact name of your approved template from WhatsApp Manager (PDF: header **Document**).',
      );
    }

    if (BevatelChatCredentials.templateNameLooksLikeMetaCategory(
        creds.templateName)) {
      throw StateError(
        'Template name looks like a **Category** (MARKETING / UTILITY / AUTHENTICATION), not '
        'the template **Name**. In WhatsApp Manager use the **Name** column (e.g. test4, '
        'invoice_2) — not the category. Long‑press **Done** and fix.',
      );
    }

    final inboxInt = int.tryParse(creds.inboxId.trim());
    if (inboxInt == null || inboxInt < 1) {
      throw StateError('Invalid Bevatel inbox_id.');
    }

    final phone = _normalizePhoneE164(invoice.customerMobile);
    if (phone == null) {
      throw StateError(
        'Customer mobile missing or invalid (need valid KSA-style number).',
      );
    }

    final brand = (invoice.workshopName?.trim().isNotEmpty ?? false)
        ? invoice.workshopName!.trim()
        : 'FILTER Car Services';
    final captionLines = <String>[
      brand,
      'Invoice ${invoice.invoiceNo}',
      'Total: ${invoice.totalAmount.toStringAsFixed(2)} SAR',
      if (invoice.customerName.trim().isNotEmpty)
        'Customer: ${invoice.customerName.trim()}',
    ];

    final Map<String, dynamic> parameters;
    final uri = Uri.parse(_messagesUrl.trim());

    if (creds.sendInvoicePdf) {
      final safeNo =
          invoice.invoiceNo.replaceAll(RegExp(r'[^\w\-\.]'), '_');
      final fname = 'Invoice_$safeNo.pdf';

      Uint8List pdfBytes;
      if (pdfDocumentOverride != null && pdfDocumentOverride.isNotEmpty) {
        pdfBytes = pdfDocumentOverride;
        debugPrint(
          '[Bevatel PDF] Using on-screen cashier preview bitmap PDF '
          '(${pdfBytes.length} bytes).',
        );
      } else {
        debugPrint('[Bevatel PDF] Building fallback vector invoice PDF…');
        pdfBytes = await buildWhatsAppSimplifiedTaxInvoicePdfBytes(
          invoice: invoice,
          paymentMethodText: paymentMethodText,
          maintenanceChecksFallback: maintenanceChecksFallback,
        );
      }

      debugPrint('[Bevatel PDF] Uploading public HTTPS link (multi-host fallback)…');
      final pdfUrl = await BevatelInvoicePdfHost.uploadPublicPdfHttps(
        pdfBytes: pdfBytes,
        filename: fname,
        customUploadPostUrl:
            creds.pdfCustomUploadPostUrl.trim().isEmpty ? null : creds.pdfCustomUploadPostUrl.trim(),
      );

      parameters = <String, dynamic>{
        'media': <String, dynamic>{
          'link': pdfUrl,
          'type': 'DOCUMENT',
          'filename': fname,
        },
      };
      if (creds.pdfIncludeCaptionLines && captionLines.isNotEmpty) {
        parameters['body'] = captionLines;
      }
    } else {
      parameters = <String, dynamic>{
        'body': captionLines,
      };
    }

    final templateNameResolved = creds.templateName.trim();
    final localeRaw = creds.templateLanguage.trim();
    final localePrimary = _normalizeTemplateLocale(localeRaw);
    final localeCandidates = _templateLocaleFallbacks(localePrimary);

    final payload = <String, dynamic>{
      'inbox_id': inboxInt,
      'contact': <String, dynamic>{
        'phone_number': phone,
      },
      'message': <String, dynamic>{
        'template': <String, dynamic>{
          'name': templateNameResolved,
          'language': localeCandidates.first,
          'parameters': parameters,
        },
      },
    };

    void logDirect(String msg) {
      debugPrint('[Bevatel direct → chat.bevatel.com] $msg');
    }

    logDirect('POST $uri');
    logDirect(
      'PDF mode=${creds.sendInvoicePdf}; template="$templateNameResolved" '
      '(stored language="$localeRaw" → tries ${localeCandidates.join(", ")}); '
      'api_account_id len=${creds.accountId.length}, token len=${creds.accessToken.length}',
    );

    http.Response res =
        http.Response('', 599, reasonPhrase: 'not sent');

    for (var i = 0; i < localeCandidates.length; i++) {
      final langTry = localeCandidates[i];
      final msgMap = payload['message']! as Map<String, dynamic>;
      final tplMap = msgMap['template']! as Map<String, dynamic>;
      tplMap['language'] = langTry;

      final bodyJson = JsonEncoder.withIndent('  ').convert(payload);
      if (i == 0) {
        logDirect('JSON body:\n$bodyJson');
      } else {
        logDirect('Retry with language="$langTry"…');
      }

      res = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'api_account_id': creds.accountId,
              'api_access_token': creds.accessToken,
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 120));

      final respPreview = res.body.length > 3500
          ? '${res.body.substring(0, 3500)}… (${res.body.length} chars)'
          : res.body;
      logDirect('HTTP ${res.statusCode} response:\n$respPreview');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final mismatch = _hintIfTemplateParameterMismatch(res.body);
        if (mismatch != null) {
          throw Exception(
            'Bevatel HTTP ${res.statusCode}: response contains WhatsApp/template error.$mismatch',
          );
        }
        if (i > 0) {
          logDirect('Succeeded with fallback language="$langTry" (update settings to match).');
        }
        return;
      }

      final canRetryLang = i + 1 < localeCandidates.length &&
          _responseLooksLikeMissingTemplate(res);
      if (!canRetryLang) {
        break;
      }
      logDirect('Template/locale mismatch — trying next locale…');
    }

    var msg = res.body;
    try {
      final j = jsonDecode(res.body);
      if (j is Map && j['message'] != null) {
        msg = j['message'].toString();
      }
      if (j is Map && j['error'] != null) {
        msg = j['error'].toString();
      }
    } catch (_) {}
    final templateHint =
        res.statusCode == 404 && msg.toLowerCase().contains('template')
            ? '\n\nTemplate="$templateNameResolved" locales tried: ${localeCandidates.join(", ")}. '
                'Must match WhatsApp Manager (same WhatsApp number as inbox $inboxInt). '
                'For PDF, template needs header **Document**.'
            : '';
    final paramHint = _hintIfTemplateParameterMismatch(res.body) ?? '';
    throw Exception('Bevatel HTTP ${res.statusCode}: $msg$templateHint$paramHint');
  }
}
