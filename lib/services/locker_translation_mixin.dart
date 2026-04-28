import 'package:translator/translator.dart';
import 'session_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// lib/services/locker_translation_mixin.dart
//
// App-wide dynamic translation service.
//
// Static UI strings → AppLocalizations (ARB / gen-l10n).
// Dynamic strings (names, notes, status labels from the DB/API) come back in
// English and are translated on the fly when the app locale is Arabic.
//
// Used by ALL modules: Locker, Owner, Accounting, Approvals, POS, etc.
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
  /// Covers raw API values and formatted UI labels across ALL modules.
  static const Map<String, String> _statusMapAr = {
    // ── Locker / Petty Cash / Approvals ──────────────────────────────────
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
    // ── Accounting ────────────────────────────────────────────────────────
    'overdue'           : 'متأخر',
    'settled'           : 'مسوَّى',
    'OVERDUE'           : 'متأخر',
    'SETTLED'           : 'مسوَّى',
    // ── Accounting transaction types ──────────────────────────────────────
    'payable'           : 'مستحق الدفع',
    'receivable'        : 'مستحق القبض',
    'expense'           : 'مصروف',
    'advance'           : 'سلفة',
    'PAYABLE'           : 'مستحق الدفع',
    'RECEIVABLE'        : 'مستحق القبض',
    'EXPENSE'           : 'مصروف',
    'ADVANCE'           : 'سلفة',
    // ── Approvals queue types ─────────────────────────────────────────────
    'fund'              : 'شحن رصيد',
    'all'               : 'الكل',
    'FUND'              : 'شحن رصيد',
    // ── Employee / POS statuses ───────────────────────────────────────────
    'active'            : 'نشط',
    'inactive'          : 'غير نشط',
    'ACTIVE'            : 'نشط',
    'INACTIVE'          : 'غير نشط',
    'online'            : 'متصل',
    'offline'           : 'غير متصل',
    'busy'              : 'مشغول',
    'available'         : 'متاح',
    'ONLINE'            : 'متصل',
    'OFFLINE'           : 'غير متصل',
    'BUSY'              : 'مشغول',
    'AVAILABLE'         : 'متاح',
    // ── Bill / Invoice statuses ───────────────────────────────────────────
    'Pending'           : 'قيد الانتظار',
    'Paid'              : 'مدفوع',
    'Partially Paid'    : 'مدفوع جزئياً',
    'Overdue'           : 'متأخر',
    'paid'              : 'مدفوع',
    'partially paid'    : 'مدفوع جزئياً',
  };

  // ── Public API ────────────────────────────────────────────────────────────

  /// Translates [text] to [targetLang].
  /// Returns the original on error, empty input, numeric input, or if the
  /// text is already in the target script.
  static Future<String> translate(
      String text, {
        String targetLang = 'ar',
        String sourceLang = 'en',
      }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;
    if (double.tryParse(trimmed) != null) return text; // numbers unchanged
    if (_containsArabic(trimmed)) return text;          // already Arabic

    // Status fast-path — no network call needed.
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
      // Fall through — return original below.
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

/// Holds translated display strings for any request that has
/// branch / cashier / officer fields (Locker, Approvals, etc.).
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

// ── Backward-compatibility alias ──────────────────────────────────────────────
typedef LockerRequestTranslated = RequestTranslated;

// ── Mixin for ChangeNotifier view-models ─────────────────────────────────────

/// Mix into any ChangeNotifier-based ViewModel that loads dynamic string data
/// from the API and needs on-the-fly Arabic translation.
///
/// Module-agnostic — use in Locker, Accounting, Approvals, Owner, POS, etc.
///
/// Usage:
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

  /// Translates branch / cashier / officer fields of a dynamic request list.
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

  /// Batch-translates a map of display fields.
  Future<Map<String, String>> tDetailFields(Map<String, String> fields) async {
    final keys   = fields.keys.toList();
    final values = await tAll(fields.values.toList());
    return Map.fromIterables(keys, values);
  }

  /// Translates a user / person display name (e.g. welcome header).
  Future<String?> translateUserName(String? name) async {
    if (name == null) return null;
    return t(name);
  }

  /// Translates an accounting party name (vendor, customer, employee).
  Future<String> tParty(String partyName) => t(partyName);

  /// Translates a reference string — skips translation for reference codes
  /// like "INV-001" or "REF#2024" that should stay unchanged.
  Future<String> tReference(String ref) async {
    final isCode = RegExp(r'^[A-Z0-9#\-_/]+$').hasMatch(ref.trim());
    if (isCode) return ref;
    return t(ref);
  }
}

// ── Type aliases for backward-compatibility ───────────────────────────────────
typedef LockerTranslatableMixin = TranslatableMixin;
typedef LockerTranslationMixin  = TranslatableMixin;