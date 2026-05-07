import 'package:shared_preferences/shared_preferences.dart';

/// Direct Bevatel Chat developer API credentials (stored on device).
///
/// Dart-define (compile-time):
/// ```text
/// BEVATEL_API_ACCOUNT_ID, BEVATEL_API_ACCESS_TOKEN, BEVATEL_WHATSAPP_INBOX_ID
/// BEVATEL_WHATSAPP_TEMPLATE_NAME, BEVATEL_WHATSAPP_TEMPLATE_LANGUAGE
/// BEVATEL_SEND_INVOICE_AS_PDF, BEVATEL_PDF_INCLUDE_CAPTION_LINES, BEVATEL_PDF_UPLOAD_URL
/// ```
abstract final class BevatelChatCredentials {
  static const prefAccountId = 'bevatel_chat_api_account_id';
  static const prefAccessToken = 'bevatel_chat_api_access_token';
  static const prefInboxId = 'bevatel_chat_whatsapp_inbox_id';
  static const prefTemplateName = 'bevatel_chat_template_name';
  static const prefTemplateLanguage = 'bevatel_chat_template_language';
  static const prefSendInvoicePdf = 'bevatel_send_invoice_as_pdf';
  static const prefPdfCaptionLines = 'bevatel_pdf_include_caption_lines';
  static const prefPdfUploadUrl = 'bevatel_pdf_custom_upload_post_url';

  /// WhatsApp Manager **Category** column values — not the API template **Name** (e.g. test4).
  static bool templateNameLooksLikeMetaCategory(String raw) {
    switch (raw.trim().toUpperCase()) {
      case 'MARKETING':
      case 'UTILITY':
      case 'AUTHENTICATION':
        return true;
      default:
        return false;
    }
  }

  static const String accountIdEnv =
      String.fromEnvironment('BEVATEL_API_ACCOUNT_ID', defaultValue: '');
  static const String accessTokenEnv =
      String.fromEnvironment('BEVATEL_API_ACCESS_TOKEN', defaultValue: '');
  static const String inboxIdEnv =
      String.fromEnvironment('BEVATEL_WHATSAPP_INBOX_ID', defaultValue: '');
  static const String templateNameEnv =
      String.fromEnvironment('BEVATEL_WHATSAPP_TEMPLATE_NAME', defaultValue: '');
  static const String templateLanguageEnv =
      String.fromEnvironment('BEVATEL_WHATSAPP_TEMPLATE_LANGUAGE', defaultValue: '');

  static const String pdfUploadUrlEnv =
      String.fromEnvironment('BEVATEL_PDF_UPLOAD_URL', defaultValue: '');

  static const bool sendInvoicePdfEnv =
      bool.fromEnvironment('BEVATEL_SEND_INVOICE_AS_PDF', defaultValue: true);
  static const bool pdfCaptionLinesEnv =
      bool.fromEnvironment('BEVATEL_PDF_INCLUDE_CAPTION_LINES', defaultValue: false);

  static Future<
      ({
        String accountId,
        String accessToken,
        String inboxId,
        String templateName,
        String templateLanguage,
        bool sendInvoicePdf,
        bool pdfIncludeCaptionLines,
        String pdfCustomUploadPostUrl,
      })?> resolve() async {
    final p = await SharedPreferences.getInstance();

    String pick(String env, String prefKey) {
      final e = env.trim();
      if (e.isNotEmpty) return e;
      return p.getString(prefKey)?.trim() ?? '';
    }

    final aid = pick(accountIdEnv, prefAccountId);
    final tok = pick(accessTokenEnv, prefAccessToken);
    final inbox = pick(inboxIdEnv, prefInboxId);

    var tname = templateNameEnv.trim();
    if (tname.isEmpty) {
      tname = p.getString(prefTemplateName)?.trim() ?? '';
    }
    var tlang = templateLanguageEnv.trim();
    if (tlang.isEmpty) {
      tlang = p.getString(prefTemplateLanguage)?.trim() ?? '';
    }
    if (tlang.isEmpty) tlang = 'en';

    final sendPdf = p.getBool(prefSendInvoicePdf) ?? sendInvoicePdfEnv;
    final pdfCaption = p.getBool(prefPdfCaptionLines) ?? pdfCaptionLinesEnv;

    var pdfUp = pdfUploadUrlEnv.trim();
    if (pdfUp.isEmpty) {
      pdfUp = p.getString(prefPdfUploadUrl)?.trim() ?? '';
    }

    if (aid.isEmpty || tok.isEmpty || inbox.isEmpty) return null;

    return (
      accountId: aid,
      accessToken: tok,
      inboxId: inbox,
      templateName: tname,
      templateLanguage: tlang,
      sendInvoicePdf: sendPdf,
      pdfIncludeCaptionLines: pdfCaption,
      pdfCustomUploadPostUrl: pdfUp,
    );
  }

  static Future<void> save({
    required String accountId,
    required String accessToken,
    required String inboxId,
    required String templateName,
    String templateLanguage = 'en',
    bool sendInvoicePdf = true,
    bool pdfIncludeCaptionLines = false,
    String pdfCustomUploadPostUrl = '',
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(prefAccountId, accountId.trim());
    await p.setString(prefAccessToken, accessToken.trim());
    await p.setString(prefInboxId, inboxId.trim());
    await p.setString(prefTemplateName, templateName.trim());
    await p.setString(prefTemplateLanguage, templateLanguage.trim());
    await p.setBool(prefSendInvoicePdf, sendInvoicePdf);
    await p.setBool(prefPdfCaptionLines, pdfIncludeCaptionLines);
    await p.setString(prefPdfUploadUrl, pdfCustomUploadPostUrl.trim());
  }
}
