import 'package:flutter/material.dart';

/// Cashier invoice payment options (individual vs corporate sets differ in UI).
enum PaymentMethod {
  cash,
  card,
  bankTransfer,
  monthlyBilling,
  wallet,
  tabby,
  tamara,
}

extension PaymentMethodLabel on PaymentMethod {
  String get label {
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
    }
  }

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
    }
  }

  /// Individual / split flow — excludes corporate-only methods.
  bool get isRetailSelectable =>
      this != PaymentMethod.monthlyBilling && this != PaymentMethod.wallet;
}
