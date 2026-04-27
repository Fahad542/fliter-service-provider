import 'package:translator/translator.dart';
import 'session_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// lib/services/translation_service.dart
//
// Handles dynamic API data translation for ALL modules in the app.
//
// Static UI strings are handled by AppLocalizations (ARB / gen-l10n).
// Dynamic strings — branch names, cashier names, officer names, notes, status
// labels from the DB — come back in English and are translated on the fly when
// the app locale is Arabic.
// ─────────────────────────────────────────────────────────────────────────────

// ── Core translation service ──────────────────────────────────────────────────

class AppTranslationService {
  AppTranslationService._();

  static final GoogleTranslator _translator = GoogleTranslator();

  /// In-memory LRU-style cache keyed by "targetLang:text".
  static final Map<String, String> _cache = {};

  /// Maximum cached entries — prevents unbounded growth.
  static const int _maxCache = 500;

  // ── Status map — instant lookup, no network call ──────────────────────────

  /// Canonical English status string → Arabic translation.
  /// Covers both raw API values and formatted UI labels across all modules.
  static const Map<String, String> _statusMapAr = {
    // Locker / Petty Cash / Approvals statuses
    'PENDING'           : 'قيد الانتظار',
    'ASSIGNED'          : 'معيَّن',
    'AWAITING'          : 'في انتظار الموافقة',
    'AWAITING APPROVAL' : 'في انتظار الموافقة',
    'COLLECTED'         : 'محصَّل',
    'APPROVED'          : 'معتمد',
    'REJECTED'          : 'مرفوض',
    'pending'           : 'قيد الانتظار',
    'assigned'          : 'معيَّن',
    'awaiting_approval' : 'في انتظار الموافقة',
    'pending_approval'  : 'في انتظار الموافقة',
    'collected'         : 'محصَّل',
    'approved'          : 'معتمد',
    'rejected'          : 'مرفوض',
    'SHORT'             : 'ناقص',
    'OVER'              : 'زائد',
    // Accounting statuses
    'overdue'           : 'متأخر',
    'settled'           : 'مسوَّى',
    'OVERDUE'           : 'متأخر',
    'SETTLED'           : 'مسوَّى',
    // Accounting transaction types
    'payable'           : 'مستحق الدفع',
    'receivable'        : 'مستحق القبض',
    'expense'           : 'مصروف',
    'advance'           : 'سلفة',
    'PAYABLE'           : 'مستحق الدفع',
    'RECEIVABLE'        : 'مستحق القبض',
    'EXPENSE'           : 'مصروف',
    'ADVANCE'           : 'سلفة',
    // Queue types (Approvals)
    'fund'              : 'شحن رصيد',
    'all'               : 'الكل',
    'FUND'              : 'شحن رصيد',
  };

  // ── Public API ────────────────────────────────────────────────────────────

  /// Translates a single text string to [targetLang] if not already that
  /// language. Returns original text on error, empty input, or numeric input.
  static Future<String> translate(
      String text, {
        String targetLang = 'ar',
        String sourceLang = 'en',
      }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;
    if (double.tryParse(trimmed) != null) return text; // numbers unchanged
    if (_containsArabic(trimmed)) return text;          // already Arabic

    // Status fast path
    if (targetLang == 'ar' && _statusMapAr.containsKey(trimmed)) {
      return _statusMapAr[trimmed]!;
    }

    final key = '$targetLang:$trimmed';
    if (_cache.containsKey(key)) return _cache[key]!;

    try {
      final result = await _translator.translate(
        trimmed,
        from: sourceLang,
        to: targetLang,
      );
      final out = result.text.trim();
      if (out.isNotEmpty) {
        if (_cache.length >= _maxCache) {
          _cache.remove(_cache.keys.first);
        }
        _cache[key] = out;
        return out;
      }
    } catch (_) {
      // Fall through to graceful fallback.
    }

    return text;
  }

  /// Translates only when the current session locale is Arabic.
  static Future<String> localizedText(String text) async {
    if (!await _isArabic()) return text;
    return translate(text);
  }

  /// Nullable variant — returns null when input is null.
  static Future<String?> localizedTextNullable(String? text) async {
    if (text == null) return null;
    return localizedText(text);
  }

  /// Translates a list of strings, returning originals on non-Arabic locale.
  static Future<List<String>> localizedAll(List<String> texts) async {
    if (!await _isArabic()) return texts;
    return Future.wait(texts.map(translate));
  }

  /// Translates a status string using the fast-path map first.
  static Future<String> localizedStatus(String status) async {
    if (!await _isArabic()) return status;
    return _statusMapAr[status] ?? translate(status);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Reads the locale from SharedPreferences via [SessionService.getLocale].
  /// Falls back to 'en' if prefs are unavailable.
  static Future<bool> _isArabic() async {
    final locale = await SessionService.getLocale();
    return locale == 'ar';
  }

  static bool _containsArabic(String text) =>
      text.runes.any((r) => r >= 0x0600 && r <= 0x06FF);

  static void clearCache() => _cache.clear();
  static int get cacheSize => _cache.length;
}

// ── Lightweight translated DTOs ───────────────────────────────────────────────

/// Holds only the translated display strings extracted from a request with
/// branch/cashier/officer fields. Used by Locker and similar modules.
class RequestTranslated {
  final String branchName;
  final String cashierName;
  final String? assignedOfficerName;

  const RequestTranslated({
    required this.branchName,
    required this.cashierName,
    this.assignedOfficerName,
  });
}

// ── Backward-compatibility alias (Locker module used LockerRequestTranslated) ─
typedef LockerRequestTranslated = RequestTranslated;

// ── Mixin for ChangeNotifier view-models ─────────────────────────────────────

/// Mix into any ChangeNotifier-based ViewModel across ANY module that loads
/// dynamic string data from the API and needs on-the-fly Arabic translation.
///
/// The mixin wraps [AppTranslationService] and is fully module-agnostic —
/// use it in Locker, Accounting, Approvals, Owner, POS, or any other module
/// without modification.
///
/// Example:
///
///   class AccountingViewModel extends ChangeNotifier
///       with TranslatableMixin {
///
///     Future<void> load() async {
///       final raw = await repo.fetchEntries();
///       _party = await t(raw.party);
///       notifyListeners();
///     }
///   }
mixin TranslatableMixin {
  // ── Core wrappers ─────────────────────────────────────────────────────────

  Future<String> t(String text) =>
      AppTranslationService.localizedText(text);

  Future<String?> tNullable(String? text) =>
      AppTranslationService.localizedTextNullable(text);

  Future<String> tStatus(String status) =>
      AppTranslationService.localizedStatus(status);

  Future<List<String>> tAll(List<String> texts) =>
      AppTranslationService.localizedAll(texts);

  // ── Domain helpers ────────────────────────────────────────────────────────

  /// Translates the human-readable fields of a dynamic request list.
  /// Fields translated: branchName, cashierName, assignedOfficerName.
  Future<List<RequestTranslated>> translateRequests(
      List<dynamic> rawRequests,
      ) async {
    return Future.wait(rawRequests.map((r) => _translateRequest(r)));
  }

  Future<RequestTranslated> _translateRequest(dynamic req) async {
    final branchName  = await t(req.branchName  as String);
    final cashierName = await t(req.cashierName as String);
    final officerName = await tNullable(req.assignedOfficerName as String?);

    return RequestTranslated(
      branchName          : branchName,
      cashierName         : cashierName,
      assignedOfficerName : officerName,
    );
  }

  /// Translates a branch name coming from the API.
  Future<String> tBranch(String name) => t(name);

  /// Translates a cashier / officer display name.
  Future<String> tPerson(String name) => t(name);

  /// Translates free-text notes entered by a cashier / officer.
  Future<String?> tNotes(String? notes) => tNullable(notes);

  /// Translates a UI status label (e.g. "Awaiting Approval", "overdue").
  Future<String> tUiStatus(String label) => tStatus(label);

  /// Batch-translates a map of display fields coming from a detail endpoint.
  /// Pass in only the string values you want translated.
  Future<Map<String, String>> tDetailFields(Map<String, String> fields) async {
    final keys   = fields.keys.toList();
    final values = await tAll(fields.values.toList());
    return Map.fromIterables(keys, values);
  }

  /// Translates a user/person display name (e.g. for welcome header or party name).
  Future<String?> translateUserName(String? name) async {
    if (name == null) return null;
    return t(name);
  }

  /// Translates an accounting party name (vendor, customer, employee).
  Future<String> tParty(String partyName) => t(partyName);

  /// Translates a reference string — skips translation if it looks like
  /// a reference code (alphanumeric + dashes only).
  Future<String> tReference(String ref) async {
    // Reference codes like "INV-001" or "REF#2024" should not be translated.
    final isCode = RegExp(r'^[A-Z0-9#\-_/]+$').hasMatch(ref.trim());
    if (isCode) return ref;
    return t(ref);
  }
}

// ── Type aliases for backward-compatibility ───────────────────────────────────

/// All previous Locker ViewModels that used [LockerTranslatableMixin] or
/// [LockerTranslationMixin] continue to work without any renaming.
typedef LockerTranslatableMixin = TranslatableMixin;
typedef LockerTranslationMixin  = TranslatableMixin;