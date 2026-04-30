import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Cashier invoice payment options (individual vs corporate sets differ in UI).
enum PaymentMethod {
  cash,
  card,
  bankTransfer,
  monthlyBilling,
  wallet,
  tabby,
  tamara,
  employees,
}

extension PaymentMethodLabel on PaymentMethod {
  /// Localized human-readable label. Requires a BuildContext for l10n lookup.
  String localizedLabel(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (this) {
      case PaymentMethod.cash:
        return l.paymentMethodCash;
      case PaymentMethod.card:
        return l.paymentMethodCard;
      case PaymentMethod.bankTransfer:
        return l.paymentMethodBankTransfer;
      case PaymentMethod.monthlyBilling:
        return l.paymentMethodMonthlyBilling;
      case PaymentMethod.wallet:
        return l.paymentMethodWallet;
      case PaymentMethod.tabby:
        return l.paymentMethodTabby;
      case PaymentMethod.tamara:
        return l.paymentMethodTamara;
      case PaymentMethod.employees:
        return l.paymentMethodEmployees;
    }
  }

  /// Stable English API key sent to the backend — NEVER localised.
  /// Use this in network payloads instead of [localizedLabel].
  String get apiKey {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.monthlyBilling:
        return 'Monthly billing';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.tabby:
        return 'Tabby';
      case PaymentMethod.tamara:
        return 'Tamara';
      case PaymentMethod.employees:
        return 'Employees';
    }
  }

  /// Kept for backward-compat callers that don't have a context (e.g. pure
  /// ViewModel code).  New UI code should prefer [localizedLabel].
  String get label => apiKey;

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.money_rounded;
      case PaymentMethod.card:
        return Icons.credit_card_rounded;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_rounded;
      case PaymentMethod.monthlyBilling:
        return Icons.calendar_month_rounded;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet_rounded;
      case PaymentMethod.tabby:
        return Icons.splitscreen_rounded;
      case PaymentMethod.tamara:
        return Icons.shopping_bag_rounded;
      case PaymentMethod.employees:
        return Icons.groups_outlined;
    }
  }

  /// Individual / split flow — excludes corporate-only methods.
  bool get isRetailSelectable =>
      this != PaymentMethod.monthlyBilling && this != PaymentMethod.wallet;
}