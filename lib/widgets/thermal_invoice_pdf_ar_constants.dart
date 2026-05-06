// Bilingual labels for thermal invoice PDF matching common KSA bilingual receipts.

abstract final class ThermalInvoicePdfLabels {

  // Customer detail labels
  static const customerNameAr     = 'الاسم';
  static const customerMobileAr   = 'الجوال';
  static const customerTaxIdAr    = 'الرقم الضريبي للعميل';
  static const customerTypeAr     = 'نوع العميل';
  static const vehicleAr          = 'المركبة';
  static const vehicleMakeAr      = 'الماركة';
  static const vehicleModelAr     = 'الموديل';
  static const vehicleYearAr      = 'السنة';
  static const vehiclePlateAr     = 'اللوحة';
  static const vehicleVinAr       = 'رقم الهيكل';
  static const vehicleOdometerAr  = 'عداد المسافة';

  // Meta block labels
  static const branchAr           = 'الفرع';
  static const vatNoAr            = 'الرقم الضريبي';
  static const addressAr          = 'العنوان';
  static const invoiceNoAr        = 'رقم الفاتورة';
  static const dateAr             = 'التاريخ';
  static const cashierAr          = 'الكاشير';

  // Section headers
  static const customerDetailsSectionAr   = 'بيانات العميل';
  static const customerDetailsSectionEn   = 'CUSTOMER DETAILS';
  static const maintenanceSectionAr       = 'قائمة الصيانة';
  static const maintenanceSectionEn       = 'MAINTENANCE CHECKLIST';
  static const thankYouAr                 = 'شكراً';
  static const thankYouEn                 = 'Thank you';

  static const documentTitleAr = 'فاتورة ضريبية مبسطة';
  static const documentTitleEn = 'Simplified Tax Invoice';

  /// Column headers (Arabic stacked above English in table).
  static const columnItemAr = 'الصنف';
  static const columnItemEn = 'Item';

  static const columnQtyAr = 'عدد';
  static const columnQtyEn = 'Qty';

  static const columnUnitAr = 'سعر الوحدة';
  static const columnUnitEn = 'Unit Price';

  static const columnTotalAr = 'الإجمالي';
  static const columnTotalEn = 'Total';

  /// Summary section — Arabic paragraph(s) then English line + trailing amount row.
  static const totalExclVatAr = 'الإجمالي\n(غير شاملة ضريبة القيمة المضافة)';
  static const totalExclVatEn = 'Total (Excluding VAT)';

  /// Line-item / per-article discounts (excludes invoice-level & promo).
  static const itemDiscountAr = 'خصم الأصناف';
  static const itemDiscountEn = 'Item Discount';

  /// Department-level invoice discount (excludes line-item and promo).
  static const invoiceDiscountAr = 'خصم الفاتورة';
  static const invoiceDiscountEn = 'Invoice Discount';

  /// Department promo amount only ([ThermalInvoiceTotals.promoDiscount]).
  static const promoDiscountAr = 'خصم الرمز الترويجي';
  static const promoDiscountEn = 'Promo Code Discount';

  static const taxableAr =
      'الإجمالي الخاضع للضريبة\n(غير شاملة ضريبة القيمة المضافة)';
  static const taxableEn = 'Total Taxable Amount (Excluding VAT)';

  static const totalVatAr = 'مجموع ضريبة القيمة المضافة';
  static const totalVatEn = 'Total VAT';

  static const totalDueAr = 'إجمالي المبلغ المستحق';
  static const totalDueEn = 'Total Amount Due';

  /// Same labels as cashier digital invoice grid (`Next oil change (km)`).
  static const nextOilChangeAr = 'التغيير القادم للزيت (كم)';
  static const nextOilChangeEn = 'Next oil change (km)';

  /// Arabic line above payment (no trailing colon).
  static String paymentArabicLine(String normalizedPaymentEnglish) {
    final p = normalizedPaymentEnglish.toLowerCase().trim();
    String inner;
    if (p.contains('card') ||
        p.contains('visa') ||
        p.contains('mada') ||
        p.contains('master')) {
      inner = 'البطاقة';
    } else if (p.contains('cash')) {
      inner = 'نقداً';
    } else if (p.contains('employee')) {
      inner = 'الموظفين';
    } else if (p.contains('split')) {
      inner = 'مشترك';
    } else if (p.contains('bank') || p.contains('transfer')) {
      inner = 'تحويل بنكي';
    } else if (p.contains('corporate') ||
        p.contains('company') ||
        p.contains('billing') ||
        p.contains('monthly')) {
      inner = 'الشركات';
    } else {
      final raw = normalizedPaymentEnglish.trim();
      inner = raw.isEmpty ? '-' : raw;
    }
    return 'نوع الدفع ( $inner )';
  }
}