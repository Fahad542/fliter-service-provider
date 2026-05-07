import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/bevatel_chat_credentials.dart';

/// Long‑press **Done** on invoice → Bevatel Chat API (direct chat.bevatel.com).
Future<bool> showBevatelChatSettingsDialog(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final aidPref =
      prefs.getString(BevatelChatCredentials.prefAccountId)?.trim() ?? '';
  final tokPref =
      prefs.getString(BevatelChatCredentials.prefAccessToken)?.trim() ?? '';
  final inboxPref =
      prefs.getString(BevatelChatCredentials.prefInboxId)?.trim() ?? '';
  final tnamePref =
      prefs.getString(BevatelChatCredentials.prefTemplateName)?.trim() ?? '';
  final tlangPref =
      prefs.getString(BevatelChatCredentials.prefTemplateLanguage)?.trim() ??
          'en';

  final pdfPref =
      prefs.getString(BevatelChatCredentials.prefPdfUploadUrl)?.trim() ?? '';

  bool sendPdf = prefs.getBool(BevatelChatCredentials.prefSendInvoicePdf) ??
      BevatelChatCredentials.sendInvoicePdfEnv;
  bool captionLines =
      prefs.getBool(BevatelChatCredentials.prefPdfCaptionLines) ??
          BevatelChatCredentials.pdfCaptionLinesEnv;

  var aid =
      BevatelChatCredentials.accountIdEnv.trim().isNotEmpty
          ? BevatelChatCredentials.accountIdEnv.trim()
          : aidPref;
  var tok =
      BevatelChatCredentials.accessTokenEnv.trim().isNotEmpty
          ? BevatelChatCredentials.accessTokenEnv.trim()
          : tokPref;
  var inbox =
      BevatelChatCredentials.inboxIdEnv.trim().isNotEmpty
          ? BevatelChatCredentials.inboxIdEnv.trim()
          : inboxPref;

  var tname = BevatelChatCredentials.templateNameEnv.trim().isNotEmpty
      ? BevatelChatCredentials.templateNameEnv.trim()
      : tnamePref;
  var tlang = BevatelChatCredentials.templateLanguageEnv.trim().isNotEmpty
      ? BevatelChatCredentials.templateLanguageEnv.trim()
      : tlangPref;

  var pdfUpload = BevatelChatCredentials.pdfUploadUrlEnv.trim().isNotEmpty
      ? BevatelChatCredentials.pdfUploadUrlEnv.trim()
      : pdfPref;

  if (!context.mounted) return false;

  final aidCtrl = TextEditingController(text: aid);
  final tokCtrl = TextEditingController(text: tok);
  final inboxCtrl = TextEditingController(text: inbox);
  final nameCtrl = TextEditingController(text: tname);
  final langCtrl = TextEditingController(text: tlang);
  final pdfUpCtrl = TextEditingController(text: pdfUpload);

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: const Text('Bevatel Chat API'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'POST chat.bevatel.com/developer/api/v1/messages\n'
                'Headers: api_account_id, api_access_token',
                style: TextStyle(fontSize: 12.5),
              ),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Send invoice as PDF (WhatsApp template)'),
                subtitle: const Text(
                  'Sends the **same colourful cashier invoice** you see in the popup (PNG → PDF). '
                  'Fallback: bilingual A4 vector PDF → public link → DOCUMENT header in Meta.',
                  style: TextStyle(fontSize: 11),
                ),
                value: sendPdf,
                onChanged: (v) => setLocal(() => sendPdf = v),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Also send caption lines (parameters.body)'),
                subtitle: const Text(
                  'Only if body has {{1}}, {{2}}, … (one placeholder per caption line). '
                  'Fixed body text only (e.g. test4) → keep **OFF** or WhatsApp returns #132000.',
                  style: TextStyle(fontSize: 11),
                ),
                value: captionLines,
                onChanged:
                    sendPdf ? (v) => setLocal(() => captionLines = v) : null,
              ),
              if (sendPdf) ...[
                const SizedBox(height: 4),
                TextField(
                  controller: pdfUpCtrl,
                  decoration: const InputDecoration(
                    labelText:
                        'PDF upload URL (optional, recommended on simulator)',
                    hintText: 'https://your-server.com/upload',
                    helperText:
                        'POST multipart field "file"; response = https URL or JSON {url|link}. '
                        'If empty, app tries 0x0.st → file.io → transfer.sh',
                    border: OutlineInputBorder(),
                  ),
                  autocorrect: false,
                  keyboardType: TextInputType.url,
                ),
              ],
              const SizedBox(height: 8),
              TextField(
                controller: aidCtrl,
                decoration: const InputDecoration(
                  labelText: 'api_account_id',
                  border: OutlineInputBorder(),
                ),
                autocorrect: false,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: tokCtrl,
                decoration: const InputDecoration(
                  labelText: 'api_access_token',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                autocorrect: false,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: inboxCtrl,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp inbox_id',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                autocorrect: false,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Template name (Meta — exact spelling)',
                  hintText: 'Must match approved template',
                  helperText:
                      'Use the **Name** column (test4, invoice_2) — not Category (MARKETING).',
                  border: OutlineInputBorder(),
                ),
                autocorrect: false,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: langCtrl,
                decoration: const InputDecoration(
                  labelText: 'Template language (e.g. EN, en, ar, en_US)',
                  border: OutlineInputBorder(),
                ),
                autocorrect: false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final a = aidCtrl.text.trim();
              final t = tokCtrl.text.trim();
              final i = inboxCtrl.text.trim();
              final tn = nameCtrl.text.trim();
              final tl =
                  langCtrl.text.trim().isEmpty ? 'en' : langCtrl.text.trim();
              if (a.isEmpty || t.isEmpty || i.isEmpty) return;
              if (tn.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Template name required (your approved WhatsApp template).'),
                  ),
                );
                return;
              }
              if (BevatelChatCredentials.templateNameLooksLikeMetaCategory(
                  tn)) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'That is a Category (MARKETING/UTILITY), not the template Name. '
                      'Use e.g. test4 from the Name column.',
                    ),
                  ),
                );
                return;
              }
              await BevatelChatCredentials.save(
                accountId: a,
                accessToken: t,
                inboxId: i,
                templateName: tn,
                templateLanguage: tl,
                sendInvoicePdf: sendPdf,
                pdfIncludeCaptionLines: captionLines && sendPdf,
                pdfCustomUploadPostUrl: pdfUpCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );

  aidCtrl.dispose();
  tokCtrl.dispose();
  inboxCtrl.dispose();
  nameCtrl.dispose();
  langCtrl.dispose();
  pdfUpCtrl.dispose();

  return ok ?? false;
}
