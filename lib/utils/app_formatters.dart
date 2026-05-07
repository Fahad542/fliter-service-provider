import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Tax / legal invoice date — **date only** (`dd/MM/yyyy`). Ignores time on ISO strings
/// (avoids showing `00:00` when the backend sends midnight).
String formatInvoiceLegalDate(String? invoiceDateIso) {
  final raw = invoiceDateIso?.trim() ?? '';
  if (raw.isEmpty) return '—';
  final datePart = raw.split('T').first.split(' ').first.trim();
  var d = DateTime.tryParse(raw);
  if (d == null && datePart.length <= 10) {
    d = DateTime.tryParse('${datePart}T00:00:00');
  }
  if (d != null) {
    return DateFormat('dd/MM/yyyy').format(DateTime(d.year, d.month, d.day));
  }
  if (datePart.isNotEmpty) return datePart;
  return '—';
}

/// Full date+time when the invoice was **issued** (`dd/MM/yyyy hh:mm a` local; no seconds).
/// Returns `null` when [issuedAtIso] is empty or unparseable.
String? formatInvoiceIssuedAtDateTime(String? issuedAtIso) {
  final raw = issuedAtIso?.trim() ?? '';
  if (raw.isEmpty) return null;
  final d = DateTime.tryParse(raw);
  if (d == null) return null;
  return DateFormat('dd/MM/yyyy hh:mm a').format(d.toLocal());
}

/// Clock time only (`hh:mm a` local; no seconds). Returns `null` for legacy rows with no `issuedAt`.
String? formatInvoiceIssuedAtClock(String? issuedAtIso) {
  final raw = issuedAtIso?.trim() ?? '';
  if (raw.isEmpty) return null;
  final d = DateTime.tryParse(raw);
  if (d == null) return null;
  return DateFormat('hh:mm a').format(d.toLocal());
}

/// Same digit rules as WhatsApp/Bevatel E.164: returns `966` + NSN, digits only, or `null`.
String? normalizeSaudiMobileTo966Digits(String? raw) {
  var d = raw == null
      ? ''
      : RegExp(r'\d').allMatches(raw).map((m) => m.group(0)!).join();
  if (d.isEmpty) return null;
  if (d.length == 10 && d.startsWith('05')) {
    d = '966${d.substring(1)}';
  }
  if (d.length == 9 && d.startsWith('5')) {
    d = '966$d';
  }
  if (d.length == 10 && d.startsWith('5')) {
    d = '966$d';
  }
  if (d.length == 10 && d.startsWith('3') && !d.startsWith('35')) {
    d = '9665${d.substring(1)}';
  }
  if (!d.startsWith('966')) {
    return null;
  }
  if (d.length > 12) {
    d = d.substring(0, 12);
  }
  if (d.length < 11) {
    return null;
  }
  return d;
}

/// Shows **+966** with spacing (e.g. `+966 56 535 6263`) for KSA mobiles. Otherwise trimmed [raw] or `—`.
String formatInvoiceMobileForDisplay(String? raw) {
  final d = normalizeSaudiMobileTo966Digits(raw);
  if (d == null) {
    final t = raw?.trim() ?? '';
    return t.isEmpty ? '—' : t;
  }
  final nsn = d.substring(3);
  if (nsn.length == 9) {
    return '+966 ${nsn.substring(0, 2)} ${nsn.substring(2, 5)} ${nsn.substring(5, 9)}';
  }
  return '+$d';
}

/// Display helper: Saudi plates are usually stored as **digits then letters** (e.g. `1234 - DDS`).
/// UI can show **[letters] - [digits]** for quicker alphabet scanning.
///
/// Recognizes leading digits + trailing letters, or leading letters + trailing digits.
/// Otherwise returns [raw] trimmed unchanged.
String formatVehiclePlateLettersFirst(String? raw) {
  final original = (raw ?? '').trim();
  if (original.isEmpty) return original;

  final converted = EnglishNumberFormatter.convert(original);
  final n = converted.replaceAll(RegExp(r'[\s\-\|]'), '');
  if (n.isEmpty) return original;

  bool isDigit(String c) => RegExp(r'^[0-9]$').hasMatch(c);
  bool isLatinLetter(String c) => RegExp(r'^[A-Za-z]$').hasMatch(c);
  bool isArabicLetter(String c) => RegExp(r'^[\u0621-\u064A]$').hasMatch(c);
  bool isLetterChar(String c) => isLatinLetter(c) || isArabicLetter(c);

  String upperLatin(String s) {
    final b = StringBuffer();
    for (final ch in s.split('')) {
      if (RegExp(r'^[a-z]$').hasMatch(ch)) {
        b.write(ch.toUpperCase());
      } else {
        b.write(ch);
      }
    }
    return b.toString();
  }

  if (isDigit(n[0])) {
    var i = 0;
    while (i < n.length && isDigit(n[i])) i++;
    final digitPart = n.substring(0, i);
    final letterPart = n.substring(i);
    if (digitPart.isNotEmpty &&
        letterPart.isNotEmpty &&
        letterPart.split('').every(isLetterChar)) {
      return '${upperLatin(letterPart)} - $digitPart';
    }
  } else if (isLetterChar(n[0])) {
    var i = 0;
    while (i < n.length && isLetterChar(n[i])) i++;
    final letterPart = n.substring(0, i);
    final rest = n.substring(i);
    if (letterPart.isNotEmpty &&
        rest.isNotEmpty &&
        rest.split('').every(isDigit)) {
      return '${upperLatin(letterPart)} - $rest';
    }
  }

  return original;
}

/// Saudi plate as **digits (3–4) + letters (3)** for validation and APIs, regardless of UI order
/// (`1234 - ABC` vs `ABC - 1234`).
String canonicalSaudiPlateForApi(String? raw) {
  final converted = EnglishNumberFormatter.convert((raw ?? '').trim());
  if (converted.isEmpty) return '';
  final n = converted.replaceAll(RegExp(r'[\s\-\|]'), '');
  if (n.isEmpty) return '';

  final digits = StringBuffer();
  final letters = StringBuffer();
  for (final ch in n.split('')) {
    if (RegExp(r'^[0-9]$').hasMatch(ch)) {
      digits.write(ch);
      continue;
    }
    if (RegExp(r'^[a-zA-Z]$').hasMatch(ch)) {
      letters.write(ch.toUpperCase());
      continue;
    }
    if (RegExp(r'^[\u0621-\u064A]$').hasMatch(ch)) {
      letters.write(ch);
    }
  }
  if (letters.isEmpty) return digits.toString();
  if (digits.isEmpty) return letters.toString();
  return '${digits.toString()}${letters.toString()}';
}

/// Allows non-negative decimal quantities: digits, optional single `.`, limited fractional digits.
class DecimalQtyTextInputFormatter extends TextInputFormatter {
  final int maxFractionDigits;

  const DecimalQtyTextInputFormatter({this.maxFractionDigits = 2});

  static final _validChars = RegExp(r'^[0-9.]*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(',', '.');
    if (text.isEmpty) return newValue;
    if (!_validChars.hasMatch(text)) return oldValue;

    final firstDot = text.indexOf('.');
    if (firstDot != -1 && text.indexOf('.', firstDot + 1) != -1) {
      return oldValue;
    }
    if (firstDot != -1 && maxFractionDigits >= 0) {
      final frac = text.substring(firstDot + 1);
      if (frac.length > maxFractionDigits) return oldValue;
    }

    if (text != newValue.text) {
      return TextEditingValue(
        text: text,
        selection: newValue.selection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}

class EnglishNumberFormatter extends TextInputFormatter {
  static const Map<String, String> _mapping = {
    // Eastern Arabic numerals (Arabic)
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
    '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    // Persian numerals
    '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
    '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
    // Devanagari (Hindi) numerals
    '०': '0', '१': '1', '२': '2', '३': '3', '४': '4',
    '५': '5', '६': '6', '७': '7', '८': '8', '९': '9',
  };

  static String convert(String text) {
    if (text.isEmpty) return text;
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final String char = text[i];
      buffer.write(_mapping[char] ?? char);
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final String newText = convert(newValue.text);
    if (newText == newValue.text) return newValue;

    return TextEditingValue(
      text: newText,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}
