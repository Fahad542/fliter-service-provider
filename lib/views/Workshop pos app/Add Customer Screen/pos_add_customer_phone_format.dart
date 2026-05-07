import 'dart:math';

import 'package:flutter/services.dart';

/// Country calling code for Add Customer (Normal) mobile field.
enum PosAddCustomerMobileDial {
  saudiArabia,
  pakistan,
}

extension PosAddCustomerMobileDialX on PosAddCustomerMobileDial {
  String get dialDigits => switch (this) {
        PosAddCustomerMobileDial.saudiArabia => '966',
        PosAddCustomerMobileDial.pakistan => '92',
      };

  String get flagEmoji => switch (this) {
        PosAddCustomerMobileDial.saudiArabia => '🇸🇦',
        PosAddCustomerMobileDial.pakistan => '🇵🇰',
      };

  /// Placeholder sample (national digits only; user types without +country).
  String get inputHintSample => switch (this) {
        PosAddCustomerMobileDial.saudiArabia => '05X XXX XXXX',
        PosAddCustomerMobileDial.pakistan => '03XX XXXXXXX',
      };
}

/// National mobile display + validation for Saudi Arabia and Pakistan (Add Customer).
class PosAddCustomerPhoneFormat {
  PosAddCustomerPhoneFormat._();

  static String digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

  static String _digits(String s) => digitsOnly(s);

  /// Strips non-digits and caps length while typing.
  static String capDigits(PosAddCustomerMobileDial dial, String rawDigits) {
    var d = _digits(rawDigits);
    if (d.isEmpty) return d;
    switch (dial) {
      case PosAddCustomerMobileDial.saudiArabia:
        if (d.startsWith('05')) {
          return d.length > 10 ? d.substring(0, 10) : d;
        }
        if (d.startsWith('5')) {
          return d.length > 9 ? d.substring(0, 9) : d;
        }
        if (d.startsWith('0')) {
          return d.length > 10 ? d.substring(0, 10) : d;
        }
        return d.length > 9 ? d.substring(0, 9) : d;
      case PosAddCustomerMobileDial.pakistan:
        if (d.startsWith('0')) {
          return d.length > 11 ? d.substring(0, 11) : d;
        }
        return d.length > 10 ? d.substring(0, 10) : d;
    }
  }

  static String _chunk(String digits, List<int> sizes) {
    if (digits.isEmpty) return '';
    final buf = StringBuffer();
    var i = 0;
    var si = 0;
    while (i < digits.length && si < sizes.length) {
      final remain = digits.length - i;
      final take = min(sizes[si], remain);
      if (buf.isNotEmpty) buf.write(' ');
      buf.write(digits.substring(i, i + take));
      i += take;
      si++;
    }
    if (i < digits.length) {
      if (buf.isNotEmpty) buf.write(' ');
      buf.write(digits.substring(i));
    }
    return buf.toString();
  }

  /// Formats national digits (no country code) with spaces for display.
  static String formatDigits(PosAddCustomerMobileDial dial, String rawDigits) {
    final d = capDigits(dial, rawDigits);
    if (d.isEmpty) return '';
    switch (dial) {
      case PosAddCustomerMobileDial.saudiArabia:
        if (d.startsWith('05')) {
          return _chunk(d, [3, 3, 4]);
        }
        return _chunk(d, [2, 3, 4]);
      case PosAddCustomerMobileDial.pakistan:
        if (d.startsWith('0')) {
          return _chunk(d, [4, 7]);
        }
        return _chunk(d, [3, 3, 4]);
    }
  }

  /// Normalizes to national mobile digits only (no +country, no spaces).
  /// Saudi: `5XXXXXXXX` (9 digits). Pakistan: `3XXXXXXXXX` (10 digits).
  static String normalizeNational(PosAddCustomerMobileDial dial, String raw) {
    var d = _digits(raw);
    switch (dial) {
      case PosAddCustomerMobileDial.saudiArabia:
        if (d.startsWith('966')) {
          d = d.length > 3 ? d.substring(3) : '';
        }
        if (d.length == 10 && d.startsWith('05')) {
          d = d.substring(1);
        } else if (d.length > 9 && d.startsWith('05')) {
          d = d.substring(1, 10);
        }
        return d;
      case PosAddCustomerMobileDial.pakistan:
        if (d.startsWith('92')) {
          d = d.length > 2 ? d.substring(2) : '';
        }
        if (d.length == 11 && d.startsWith('0') && d.length > 1 && d[1] == '3') {
          d = d.substring(1);
        }
        return d;
    }
  }

  static bool isValidNational(PosAddCustomerMobileDial dial, String raw) {
    final n = normalizeNational(dial, raw);
    switch (dial) {
      case PosAddCustomerMobileDial.saudiArabia:
        return RegExp(r'^5\d{8}$').hasMatch(n);
      case PosAddCustomerMobileDial.pakistan:
        return RegExp(r'^3\d{9}$').hasMatch(n);
    }
  }
}

/// Keeps display formatted; strips non-digits and reapplies grouping for the selected country.
class PosAddCustomerNationalMobileFormatter extends TextInputFormatter {
  PosAddCustomerNationalMobileFormatter(this.dial);
  final PosAddCustomerMobileDial dial;

  static int _digitCountBefore(String s, int offset) {
    if (offset <= 0) return 0;
    final sub = s.substring(0, min(offset, s.length));
    return _digits(sub).length;
  }

  static String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');

  static int _offsetForDigitIndex(String formatted, int digitIndex) {
    if (digitIndex <= 0) return 0;
    var count = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(formatted[i])) {
        count++;
        if (count == digitIndex) return i + 1;
      }
    }
    return formatted.length;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final rawDigits =
        PosAddCustomerPhoneFormat.capDigits(dial, _digits(newValue.text));
    final formatted = PosAddCustomerPhoneFormat.formatDigits(dial, rawDigits);

    final oldOffset = newValue.selection.baseOffset;
    final digitsBefore = _digitCountBefore(newValue.text, oldOffset);
    final newOffset = _offsetForDigitIndex(formatted, digitsBefore);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: newOffset.clamp(0, formatted.length),
      ),
    );
  }

}
