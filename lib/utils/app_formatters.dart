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

/// Clock time when the invoice was **issued** (print / system time). Uses [DateTime.toLocal]
/// after parsing (handles UTC `Z` from API). Returns `null` for legacy rows with no `issuedAt`
/// — caller should hide the time line.
String? formatInvoiceIssuedAtClock(String? issuedAtIso) {
  final raw = issuedAtIso?.trim() ?? '';
  if (raw.isEmpty) return null;
  final d = DateTime.tryParse(raw);
  if (d == null) return null;
  return DateFormat.jm().format(d.toLocal());
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
