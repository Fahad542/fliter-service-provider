import 'package:flutter/services.dart';

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
