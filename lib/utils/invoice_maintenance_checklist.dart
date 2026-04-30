/// Same 6 bilingual items as printed on cashier [InvoiceDialog] checklist table
/// (`pos_widgets` PDF-style layout — left lane = rows `0–2`, right = `3–5`).
abstract final class InvoiceMaintenanceChecklist {
  const InvoiceMaintenanceChecklist._();

  static const List<({String en, String ar})> rows = <({String en, String ar})>[
    (en: 'Tire Pressure Check', ar: 'فحص هواء الاطارات'),
    (en: 'Brake Fluid Check', ar: 'فحص سائل الفرامل'),
    (en: 'Wipers Fluid Check', ar: 'فحص سائل المساحات'),
    (en: 'Power Steering Fluid Check', ar: 'فحص سائل المقود'),
    (en: 'Transmission Fluid Check', ar: 'فحص سائل نقل الحركة'),
    (en: 'Radiator Fluid Check', ar: 'فحص سائل مبرد المحرك'),
  ];

  static int get laneRowCount => 3;

  static ({String en, String ar}) cell(int tableRowIndex, {required bool leftColumn}) =>
      rows[tableRowIndex + (leftColumn ? 0 : 3)];
}
