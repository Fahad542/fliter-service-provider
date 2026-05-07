import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Public HTTPS URL for invoice PDF — WhatsApp/Bevatel `parameters.media.link`.
///
/// Tries: [optional custom POST] → litterbox.catbox.moe → file.io (`www` + redirects) →
/// 0x0.st → transfer.sh. Public mirrors are unreliable; prefer **PDF upload URL** in settings.
abstract final class BevatelInvoicePdfHost {
  static String _normalizeUrl(String raw) {
    final u = raw.trim().split(RegExp(r'\s+')).first;
    if (!u.startsWith('https://')) {
      throw StateError('Uploader did not return an https URL: $u');
    }
    return u;
  }

  /// Your server: `POST` multipart field `file`; response plain https URL OR JSON `url` / `link`.
  static Future<String> _uploadCustomMultipart(
    String postUrl,
    Uint8List pdfBytes,
    String filename,
  ) async {
    final uri = Uri.parse(postUrl.trim());
    final req = http.MultipartRequest('POST', uri);
    req.files.add(
      http.MultipartFile.fromBytes(
        'file',
        pdfBytes,
        filename: filename.replaceAll(RegExp(r'[^\w\-\.]'), '_'),
      ),
    );
    final streamed = await req.send().timeout(const Duration(seconds: 120));
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError(
        'Custom upload HTTP ${res.statusCode}: ${res.body.length > 150 ? '${res.body.substring(0, 150)}…' : res.body}',
      );
    }
    final text = res.body.trim();
    if (text.startsWith('https://')) return _normalizeUrl(text);
    if (text.startsWith('http://')) {
      return _normalizeUrl('https${text.substring(4)}');
    }
    try {
      final j = jsonDecode(text);
      if (j is Map) {
        final u = j['url'] ?? j['link'] ?? j['public_url'];
        if (u != null && u.toString().trim().startsWith('http')) {
          return _normalizeUrl(u.toString());
        }
      }
    } catch (_) {}
    throw StateError(
      'Custom upload response has no URL: ${text.length > 200 ? '${text.substring(0, 200)}…' : text}',
    );
  }

  /// Multipart POST with manual redirect hops (301/302/307/308). Recreates the request each hop
  /// because [http.MultipartRequest.send] is one-shot and the package may not re-POST to `www`.
  static Future<http.Response> _multipartPostFollowRedirect({
    required Uri initialUri,
    required List<http.MultipartFile> files,
    Map<String, String> fields = const {},
    int maxHops = 6,
  }) async {
    var uri = initialUri;
    for (var hop = 0; hop < maxHops; hop++) {
      final req = http.MultipartRequest('POST', uri);
      req.fields.addAll(fields);
      req.files.addAll(files);
      final streamed = await req.send().timeout(const Duration(seconds: 120));
      final res = await http.Response.fromStream(streamed);
      final code = res.statusCode;
      if (code == 301 ||
          code == 302 ||
          code == 303 ||
          code == 307 ||
          code == 308) {
        final loc = res.headers['location'];
        if (loc == null || loc.isEmpty) {
          throw StateError('HTTP $code redirect without Location header');
        }
        uri = uri.resolveUri(Uri.parse(loc));
        continue;
      }
      return res;
    }
    throw StateError('Too many redirects (more than $maxHops)');
  }

  /// `curl -F'file=@x.pdf' https://0x0.st` — often 503 when service disables uploads.
  static Future<String> _upload0x0St(
      Uint8List pdfBytes, String filename) async {
    final file = http.MultipartFile.fromBytes(
      'file',
      pdfBytes,
      filename: filename.replaceAll(RegExp(r'[^\w\-\.]'), '_'),
    );
    final res = await _multipartPostFollowRedirect(
      initialUri: Uri.parse('https://0x0.st'),
      files: [file],
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError(
        '0x0.st HTTP ${res.statusCode}: ${res.body.length > 120 ? '${res.body.substring(0, 120)}…' : res.body}',
      );
    }
    return _normalizeUrl(res.body);
  }

  /// file.io — follow redirects; may return HTML if the legacy API stopped working.
  static Future<String> _uploadFileIo(
      Uint8List pdfBytes, String filename) async {
    final file = http.MultipartFile.fromBytes(
      'file',
      pdfBytes,
      filename: filename.replaceAll(RegExp(r'[^\w\-\.]'), '_'),
    );
    final res = await _multipartPostFollowRedirect(
      initialUri: Uri.parse('https://file.io/'),
      files: [file],
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError(
        'file.io HTTP ${res.statusCode}: ${res.body.length > 100 ? '${res.body.substring(0, 100)}…' : res.body}',
      );
    }
    if (res.body.trim().startsWith('<') ||
        res.body.toLowerCase().contains('<!doctype html')) {
      throw StateError('file.io returned HTML instead of JSON (upload API may have moved)');
    }
    dynamic j;
    try {
      j = jsonDecode(res.body);
    } catch (_) {
      throw StateError(
        'file.io bad JSON: ${res.body.length > 160 ? '${res.body.substring(0, 160)}…' : res.body}',
      );
    }
    if (j is Map) {
      if (j['success'] == false) {
        throw StateError('file.io: ${j['message'] ?? res.body}');
      }
      final link = j['link'];
      if (link != null && link.toString().startsWith('http')) {
        return _normalizeUrl(link.toString());
      }
    }
    throw StateError(
      'file.io bad JSON: ${res.body.length > 160 ? '${res.body.substring(0, 160)}…' : res.body}',
    );
  }

  /// Litterbox temp upload (24h). Field names per catbox API.
  static Future<String> _uploadLitterbox(
      Uint8List pdfBytes, String filename) async {
    final file = http.MultipartFile.fromBytes(
      'fileToUpload',
      pdfBytes,
      filename: filename.replaceAll(RegExp(r'[^\w\-\.]'), '_'),
    );
    final res = await _multipartPostFollowRedirect(
      initialUri: Uri.parse(
        'https://litterbox.catbox.moe/resources/internals/api.php',
      ),
      files: [file],
      fields: const {
        'reqtype': 'fileupload',
        'time': '24h',
      },
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError(
        'litterbox HTTP ${res.statusCode}: ${res.body.length > 120 ? '${res.body.substring(0, 120)}…' : res.body}',
      );
    }
    final text = res.body.trim();
    return _normalizeUrl(text);
  }

  /// PUT transfer.sh — last fallback.
  static Future<String> uploadViaTransferSh({
    required Uint8List pdfBytes,
    required String filename,
  }) async {
    final safe = filename.replaceAll(RegExp(r'[^\w\-\.]'), '_');
    if (!safe.toLowerCase().endsWith('.pdf')) {
      throw StateError('Filename must end with .pdf');
    }
    final uri = Uri.parse('https://transfer.sh/$safe');
    final res = await http
        .put(
          uri,
          headers: {'Content-Type': 'application/pdf'},
          body: pdfBytes,
        )
        .timeout(const Duration(seconds: 120));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError(
        'transfer.sh HTTP ${res.statusCode}: ${res.body.length > 120 ? '${res.body.substring(0, 120)}…' : res.body}',
      );
    }
    return _normalizeUrl(res.body);
  }

  static Future<String> uploadPublicPdfHttps({
    required Uint8List pdfBytes,
    required String filename,
    String? customUploadPostUrl,
  }) async {
    final errs = <String>[];
    var safeName =
        filename.replaceAll(RegExp(r'[^\w\-\.]'), '_');
    if (!safeName.toLowerCase().endsWith('.pdf')) {
      safeName = '$safeName.pdf';
    }

    if (customUploadPostUrl != null && customUploadPostUrl.trim().isNotEmpty) {
      try {
        return await _uploadCustomMultipart(
            customUploadPostUrl.trim(), pdfBytes, safeName);
      } catch (e) {
        errs.add('custom: $e');
      }
    }

    try {
      return await _uploadLitterbox(pdfBytes, safeName);
    } catch (e) {
      errs.add('litterbox: $e');
    }
    try {
      return await _uploadFileIo(pdfBytes, safeName);
    } catch (e) {
      errs.add('file.io: $e');
    }
    try {
      return await _upload0x0St(pdfBytes, safeName);
    } catch (e) {
      errs.add('0x0.st: $e');
    }
    try {
      return await uploadViaTransferSh(pdfBytes: pdfBytes, filename: safeName);
    } catch (e) {
      errs.add('transfer.sh: $e');
    }

    throw StateError(
      'Invoice PDF upload failed (all mirrors blocked). Set **PDF upload URL** (long‑press Done) '
      'to your own HTTPS upload, use another network/device, or turn off PDF mode. '
      'Details: ${errs.join(' | ')}',
    );
  }
}
