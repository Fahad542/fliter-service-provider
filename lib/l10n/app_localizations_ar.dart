// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get ownerShellHome => 'الرئيسية';

  @override
  String get ownerShellBranches => 'الفروع';

  @override
  String get ownerShellDepartments => 'الأقسام';

  @override
  String get ownerShellEmployees => 'الموظفون';

  @override
  String get ownerShellCorporate => 'الشركات';

  @override
  String get ownerShellInventory => 'المخزون';

  @override
  String get ownerShellPosMonitoring => 'مراقبة نقاط البيع';

  @override
  String get ownerShellSuppliers => 'الموردون';

  @override
  String get ownerShellAccounting => 'المحاسبة';

  @override
  String get ownerShellPromoCodes => 'رموز العروض';

  @override
  String get ownerShellApprovals => 'الموافقات';

  @override
  String get ownerShellNotifications => 'الإشعارات';

  @override
  String get ownerShellLogout => 'تسجيل الخروج';

  @override
  String get ownerShellRoleLabel => 'مالك الورشة';

  @override
  String get ownerShellVersion => 'v1.0.0 • نظام الورشة';

  @override
  String get ownerShellLogoutTitle => 'تسجيل الخروج';

  @override
  String get ownerShellLogoutBody => 'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟';

  @override
  String get ownerShellLogoutCancel => 'إلغاء';

  @override
  String get ownerShellLogoutConfirm => 'تسجيل الخروج';

  @override
  String get lockerDefaultUser => 'المالك';

  @override
  String get billingDashboardTitle => 'لوحة الفوترة';

  @override
  String get billingGenerateTitle => 'إنشاء فواتير';

  @override
  String get billingMonthlyTitle => 'الفواتير الشهرية';

  @override
  String get billingOverdueTitle => 'المدفوعات المتأخرة';

  @override
  String get billingDefaultTitle => 'الفوترة';

  @override
  String get billingSummaryTotalBilled => 'إجمالي المفوتر';

  @override
  String get billingSummaryTotalReceived => 'إجمالي المستلم';

  @override
  String get billingSummaryOutstanding => 'المبالغ المعلقة';

  @override
  String get billingSummaryOverdue => 'المتأخرات';

  @override
  String get billingQuickActions => 'إجراءات سريعة';

  @override
  String get billingRecentActivity => 'آخر نشاط في الفوترة';

  @override
  String get billingSeeAll => 'عرض الكل';

  @override
  String get billingNoRecentActivity => 'لا يوجد نشاط حديث';

  @override
  String get billingActionGenerate => 'إنشاء فواتير';

  @override
  String get billingActionViewAll => 'عرض كل الفواتير';

  @override
  String get billingActionRecordPayment => 'تسجيل دفعة';

  @override
  String get billingActionSendReminders => 'إرسال تذكيرات';

  @override
  String get billingGeneratorStep1 => 'الخطوة 1: اختر فترة الفوترة';

  @override
  String get billingGeneratorStep2 => 'الخطوة 2: معاينة الفواتير المؤهلة';

  @override
  String get billingGeneratorPendingInvoices => 'فواتير معلقة: 15 • الإجمالي المتوقع: 12,450 ر.س';

  @override
  String get billingGeneratorPostAll => 'إنشاء وترحيل الكل';

  @override
  String billingPeriodLabel(String month, String year) {
    return 'فترة الفوترة: $month/$year';
  }

  @override
  String get billingStatusPaid => 'مدفوع';

  @override
  String get billingStatusOverdue => 'متأخر';

  @override
  String get billingStatusPartiallyPaid => 'مدفوع جزئياً';

  @override
  String get billingStatusPending => 'قيد الانتظار';

  @override
  String get branchManagementTitle => 'الفروع';

  @override
  String get branchSearchHint => 'البحث في الفروع…';

  @override
  String get branchAddButton => 'إضافة فرع';

  @override
  String get branchEditButton => 'تعديل';

  @override
  String get branchDeleteButton => 'حذف';

  @override
  String get branchNoBranches => 'لا توجد فروع';

  @override
  String get branchStatusActive => 'نشط';

  @override
  String get branchStatusInactive => 'غير نشط';

  @override
  String get branchFormTitleAdd => 'إضافة فرع';

  @override
  String get branchFormTitleEdit => 'تعديل الفرع';

  @override
  String get branchFormNameLabel => 'اسم الفرع';

  @override
  String get branchFormNameHint => 'أدخل اسم الفرع';

  @override
  String get branchFormAddressLabel => 'العنوان';

  @override
  String get branchFormAddressHint => 'ابحث عن العنوان…';

  @override
  String get branchFormLatLabel => 'خط العرض GPS';

  @override
  String get branchFormLngLabel => 'خط الطول GPS';

  @override
  String get branchFormStatusLabel => 'نشط';

  @override
  String get branchFormSaveButton => 'حفظ الفرع';

  @override
  String get branchFormUpdateButton => 'تحديث الفرع';

  @override
  String get branchFormValidationError => 'اسم الفرع والعنوان مطلوبان';

  @override
  String get branchCreateSuccess => 'تم إنشاء الفرع بنجاح';

  @override
  String get branchUpdateSuccess => 'تم تحديث الفرع بنجاح';

  @override
  String get branchDeleteSuccess => 'تم حذف الفرع بنجاح';

  @override
  String get branchSaveError => 'فشل حفظ الفرع';

  @override
  String get branchDeleteError => 'فشل حذف الفرع';

  @override
  String get branchDeleteConfirmTitle => 'حذف الفرع';

  @override
  String get branchDeleteConfirmBody => 'هل أنت متأكد من رغبتك في حذف هذا الفرع؟';

  @override
  String get branchDeleteConfirmCancel => 'إلغاء';

  @override
  String get branchDeleteConfirmDelete => 'حذف';

  @override
  String get lockerPortalTitle => 'بوابة الخزينة';

  @override
  String get lockerPortalSubtitle => 'إدارة الأصول الآمنة للفرع';

  @override
  String get lockerPortalAppBarTitle => 'بوابة الخزينة';

  @override
  String get lockerSecureAssetManagement => 'إدارة الأصول الآمنة';

  @override
  String get lockerEmail => 'البريد الإلكتروني';

  @override
  String get lockerEmailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get lockerEmailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get lockerPassword => 'كلمة المرور';

  @override
  String get lockerPasswordHint => 'أدخل كلمة المرور';

  @override
  String get lockerPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get lockerForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get lockerContinue => 'متابعة';

  @override
  String get lockerLoadingDashboard => 'جارٍ تحميل لوحة التحكم…';

  @override
  String get lockerFailedLoadDashboard => 'فشل تحميل لوحة التحكم';

  @override
  String get lockerUnexpectedError => 'حدث خطأ غير متوقع.';

  @override
  String get lockerRetry => 'إعادة المحاولة';

  @override
  String get lockerRefresh => 'تحديث';

  @override
  String get lockerSupervisorTab => 'المشرف';

  @override
  String get lockerCollectorTab => 'المحصِّل';

  @override
  String get lockerLogOut => 'تسجيل الخروج';

  @override
  String get lockerLogOutConfirm => 'هل أنت متأكد من تسجيل الخروج من بوابة الخزينة؟';

  @override
  String get lockerCancel => 'إلغاء';

  @override
  String get lockerLogOutButton => 'تسجيل الخروج';

  @override
  String get lockerWelcomeBack => 'مرحباً بعودتك';

  @override
  String get lockerRoleSupervisor => 'مشرف';

  @override
  String get lockerRoleManager => 'مدير';

  @override
  String get lockerRoleWorkshopOwner => 'صاحب الورشة';

  @override
  String get lockerRoleWorkshopSupervisor => 'مشرف الورشة';

  @override
  String get lockerRoleCollector => 'محصِّل';

  @override
  String get lockerRoleCollectionOfficer => 'موظف التحصيل';

  @override
  String get lockerRoleWorkshopCollector => 'محصِّل الورشة';

  @override
  String get lockerSupervisorOverview => 'نظرة عامة للمشرف';

  @override
  String get lockerMyPerformance => 'أدائي';

  @override
  String get lockerKpiPending => 'قيد الانتظار';

  @override
  String get lockerKpiAwaiting => 'في انتظار الموافقة';

  @override
  String get lockerKpiOverdue => 'متأخر';

  @override
  String get lockerKpiVariance => 'الفارق';

  @override
  String get lockerKpiOpenAssignments => 'المهام المفتوحة';

  @override
  String get lockerKpiPendingApproval => 'في انتظار الموافقة';

  @override
  String get lockerKpiTodaysCollections => 'تحصيلات اليوم';

  @override
  String get lockerKpiMonthlyCollected => 'المحصَّل الشهري';

  @override
  String get lockerCoreOperations => 'العمليات الأساسية';

  @override
  String get lockerManageAllRequests => 'إدارة جميع الطلبات';

  @override
  String get lockerStartCollection => 'بدء التحصيل';

  @override
  String get lockerAssignOfficers => 'تعيين الموظفين';

  @override
  String get lockerManageVarianceRequests => 'إدارة طلبات الفوارق';

  @override
  String get lockerFinancialAnalytics => 'التحليلات المالية';

  @override
  String get lockerSearchHint => 'البحث في الطلبات…';

  @override
  String get lockerLoadingRequests => 'جارٍ تحميل الطلبات…';

  @override
  String get lockerFailedLoadRequests => 'فشل تحميل الطلبات';

  @override
  String get lockerNoRequestsFound => 'لا توجد طلبات';

  @override
  String get lockerAdjustFilters => 'جرِّب تعديل البحث أو عوامل التصفية.';

  @override
  String get lockerLockedCashAsset => 'النقد المحفوظ';

  @override
  String get lockerTapToCollect => 'انقر للتحصيل';

  @override
  String get lockerStatusPending => 'قيد الانتظار';

  @override
  String get lockerStatusAssigned => 'معيَّن';

  @override
  String get lockerStatusAwaiting => 'في انتظار الموافقة';

  @override
  String get lockerStatusCollected => 'محصَّل';

  @override
  String get lockerStatusApproved => 'معتمد';

  @override
  String get lockerStatusRejected => 'مرفوض';

  @override
  String get lockerStatusMatched => 'مطابق';

  @override
  String get lockerLoadingRequest => 'جارٍ تحميل الطلب…';

  @override
  String get lockerFailedLoadDetails => 'فشل تحميل تفاصيل الطلب';

  @override
  String get lockerSystemStatus => 'حالة النظام';

  @override
  String get lockerTotalSecuredAsset => 'إجمالي الأصول المحفوظة';

  @override
  String get lockerCounterClosing => 'إغلاق الكاونتر';

  @override
  String get lockerPhysicalCash => 'النقد الفعلي';

  @override
  String get lockerSystemTotal => 'إجمالي النظام';

  @override
  String get lockerDifference => 'الفارق';

  @override
  String get lockerCollectionRecord => 'سجل التحصيل';

  @override
  String get lockerReceived => 'المستلَم';

  @override
  String get lockerInternalData => 'البيانات الداخلية';

  @override
  String get lockerSourceBranch => 'الفرع المصدر';

  @override
  String get lockerCashier => 'أمين الصندوق';

  @override
  String get lockerCashierIdentity => 'أمين الصندوق';

  @override
  String get lockerShiftCloseTime => 'وقت إغلاق الوردية';

  @override
  String get lockerSessionOpened => 'وقت فتح الجلسة';

  @override
  String get lockerSessionClosed => 'وقت إغلاق الجلسة';

  @override
  String get lockerAssignedOfficer => 'الموظف المعيَّن';

  @override
  String get lockerAssignCollectionOfficer => 'تعيين موظف التحصيل';

  @override
  String get lockerProceedToCollection => 'المتابعة للتحصيل';

  @override
  String get lockerGenerateAuditPdf => 'إنشاء تقرير PDF';

  @override
  String get lockerCollectionPendingApproval => 'التحصيل في انتظار موافقة المشرف.';

  @override
  String get lockerPendingSupervisorApproval => 'في انتظار موافقة المشرف';

  @override
  String get lockerCollectedSuccessfully => 'تم تسجيل التحصيل بنجاح';

  @override
  String get lockerVarianceApproved => 'تمت الموافقة على الفارق';

  @override
  String get lockerVarianceRejectedBanner => 'تم رفض الفارق';

  @override
  String get lockerVarianceDifferenceReview => 'يوجد فارق في هذا التحصيل. يرجى المراجعة والموافقة أو الرفض.';

  @override
  String get lockerApproveVariance => 'تمت الموافقة على الفارق بنجاح';

  @override
  String get lockerApprove => 'موافقة';

  @override
  String get lockerReject => 'رفض';

  @override
  String get lockerRejectVarianceTitle => 'رفض الفارق';

  @override
  String get lockerRejectVarianceBody => 'يمكنك تقديم سبب اختياري لرفض هذا الفارق.';

  @override
  String get lockerRejectionReasonHint => 'أدخل سبب الرفض (اختياري)';

  @override
  String get lockerConfirmReject => 'تأكيد الرفض';

  @override
  String get lockerVarianceRejected => 'تم رفض الفارق';

  @override
  String get lockerSelectOfficer => 'اختر الموظف';

  @override
  String get lockerSelectOfficerSubtitle => 'اختر موظفاً ميدانياً لتعيينه لهذا طلب التحصيل.';

  @override
  String get lockerOfficersLoadError => 'تعذّر تحميل قائمة الموظفين.';

  @override
  String get lockerAssignedTo => 'تم التعيين إلى';

  @override
  String get lockerLoaderAuditReport => 'تقرير تدقيق الخزينة';

  @override
  String get lockerGeneratedAt => 'تاريخ الإنشاء';

  @override
  String get lockerPage => 'صفحة';

  @override
  String get lockerOf => 'من';

  @override
  String get lockerRequestInformation => 'معلومات الطلب';

  @override
  String get lockerPosSession => 'جلسة نقطة البيع';

  @override
  String get lockerOpenedAt => 'وقت الفتح';

  @override
  String get lockerClosedAt => 'وقت الإغلاق';

  @override
  String get lockerSessionStatus => 'حالة الجلسة';

  @override
  String get lockerReceivedAmount => 'المبلغ المستلَم';

  @override
  String get lockerNotes => 'ملاحظات';

  @override
  String get lockerAuditFootnote => 'هذا التقرير مُولَّد آلياً ويُعدّ سجلاً رسمياً للتدقيق.';

  @override
  String lockerAuditFootnoteAmounts(String currency) {
    return 'جميع المبالغ بالعملة: $currency.';
  }

  @override
  String lockerCurrencyPrefix(String currency, String amount) {
    return '$currency $amount';
  }

  @override
  String get lockerSarCurrency => 'ريال';

  @override
  String get lockerLoadingVariance => 'جارٍ تحميل موافقات الفوارق…';

  @override
  String get lockerFailedLoadVariance => 'فشل تحميل موافقات الفوارق';

  @override
  String get lockerAllClear => 'لا توجد فوارق!';

  @override
  String get lockerNoPendingVariance => 'لا توجد موافقات فوارق معلّقة حالياً.';

  @override
  String get lockerVarianceReviewBanner => 'هذه التحصيلات تحتوي على فوارق نقدية وتتطلب موافقتك.';

  @override
  String get lockerShortLabel => 'ناقص';

  @override
  String get lockerOverLabel => 'زائد';

  @override
  String get lockerApproveVarianceTitle => 'الموافقة على الفارق';

  @override
  String lockerApproveVarianceConfirm(String type, String amount, String branch) {
    return 'الموافقة على فارق $type بمبلغ $amount ريال لـ$branch؟';
  }

  @override
  String get lockerApproveSuccess => 'تمت الموافقة على الفارق بنجاح';

  @override
  String get lockerRejectSuccess => 'تم رفض الفارق';

  @override
  String get lockerRejectVarianceDialogTitle => 'رفض الفارق';

  @override
  String lockerRejectingFor(String branch) {
    return 'رفض الفارق الخاص بـ$branch.';
  }

  @override
  String get lockerRejectionReasonOptional => 'السبب (اختياري)';

  @override
  String get lockerShortVariance => 'ناقص';

  @override
  String get lockerOverVariance => 'زائد';

  @override
  String get lockerCashierLabel => 'أمين الصندوق';

  @override
  String get lockerOfficerLabel => 'الموظف';

  @override
  String get lockerExpected => 'المتوقَّع';

  @override
  String get lockerReceivedLabel => 'المستلَم';

  @override
  String get lockerDiffLabel => 'الفارق';

  @override
  String get lockerRecordCollectionTitle => 'تسجيل التحصيل';

  @override
  String get lockerExpectedAmount => 'المبلغ المتوقَّع';

  @override
  String get lockerVerifiedReceivedAmount => 'المبلغ المستلَم الموثَّق';

  @override
  String get lockerLockedAmount => 'المبلغ المقفل';

  @override
  String get lockerReceivedAmountLabel => 'المبلغ المستلَم';

  @override
  String get lockerCollectionNotes => 'ملاحظات التحصيل';

  @override
  String get lockerCollectionNotesHint => 'أدخل أي ملاحظات أو سبب الفارق…';

  @override
  String get lockerCollectionEvidence => 'دليل التحصيل';

  @override
  String get lockerCapturePhoto => 'التقاط صورة';

  @override
  String get lockerAttachLogs => 'إرفاق السجلات';

  @override
  String get lockerConfirmFinalise => 'تأكيد وإنهاء الأصول';

  @override
  String get lockerEnterValidAmount => 'يرجى إدخال مبلغ مستلَم صحيح.';

  @override
  String get lockerSuccessPendingApproval => 'في انتظار الموافقة';

  @override
  String get lockerSuccessCollectionRecorded => 'تم تسجيل التحصيل';

  @override
  String get lockerStatusReview => 'مراجعة';

  @override
  String get lockerStatusOk => 'موافق';

  @override
  String get lockerStatusLabel => 'الحالة';

  @override
  String get lockerDone => 'تم';

  @override
  String get lockerNotificationsTitle => 'الإشعارات';

  @override
  String get lockerSessionExpired => 'انتهت الجلسة. يرجى تسجيل الدخول مجدداً.';

  @override
  String get lockerSomethingWentWrong => 'حدث خطأ ما.';

  @override
  String get lockerCouldNotRefresh => 'تعذّر التحديث.';

  @override
  String get lockerNoNotificationsYet => 'لا توجد إشعارات بعد.';

  @override
  String get lockerTryAgain => 'حاول مجدداً';

  @override
  String get lockerFinancialReports => 'التقارير المالية';

  @override
  String get lockerTabHistory => 'السجل';

  @override
  String get lockerTabAnalytics => 'التحليلات';

  @override
  String get lockerSearchByRefOrOfficer => 'البحث بالمرجع أو الموظف…';

  @override
  String get lockerAuditLogs => 'سجلات التدقيق';

  @override
  String lockerRecordsCount(int count) {
    return '$count سجل';
  }

  @override
  String get lockerExportPdf => 'PDF';

  @override
  String get lockerExportExcel => 'إكسل';

  @override
  String get lockerDifferencesSummary => 'ملخص الفوارق';

  @override
  String get lockerTotalShort => 'إجمالي الناقص';

  @override
  String get lockerTotalOver => 'إجمالي الزائد';

  @override
  String get lockerNetDifference => 'صافي الفارق';

  @override
  String get lockerTotalCollections => 'إجمالي التحصيلات';

  @override
  String get lockerMyCollectionPerformance => 'أداء تحصيلاتي';

  @override
  String get lockerCollectionPerformance => 'أداء التحصيل';

  @override
  String get lockerOfficerComplianceRatings => 'تقييمات امتثال الموظفين';

  @override
  String get lockerNoComplianceData => 'لا توجد بيانات امتثال لهذه الفترة.';

  @override
  String get lockerNoResultsMatchFilters => 'لا توجد نتائج تطابق عوامل التصفية.';

  @override
  String get lockerNoAuditLogsFound => 'لم يتم العثور على سجلات تدقيق.';

  @override
  String get lockerAnErrorOccurred => 'حدث خطأ.';

  @override
  String get lockerAllRecords => 'جميع السجلات';

  @override
  String get lockerFilterSearch => 'بحث';

  @override
  String get lockerFilterBranch => 'الفرع';

  @override
  String get lockerAllBranches => 'جميع الفروع';

  @override
  String get lockerFilterByBranch => 'تصفية حسب الفرع…';

  @override
  String get lockerLoadingBranches => 'جارٍ تحميل الفروع…';

  @override
  String get lockerSortBy => 'ترتيب حسب';

  @override
  String get lockerSortDate => 'التاريخ';

  @override
  String get lockerSortReceivedAmount => 'المبلغ المستلَم';

  @override
  String get lockerSortDifference => 'الفارق';

  @override
  String get lockerSortAsc => 'تصاعدي';

  @override
  String get lockerSortDesc => 'تنازلي';

  @override
  String get lockerSelectDateRange => 'اختر نطاقاً زمنياً';

  @override
  String get lockerDateFrom => 'من';

  @override
  String get lockerDateTo => 'إلى';

  @override
  String get lockerTapToSet => 'انقر للتحديد';

  @override
  String get lockerApplyFilter => 'تطبيق';

  @override
  String get lockerClearFilters => 'مسح';

  @override
  String get lockerNoData => 'لا توجد بيانات';

  @override
  String get lockerWeeklyCollectionVolume => 'حجم التحصيل الأسبوعي';

  @override
  String get lockerTransactionRef => 'مرجع المعاملة';

  @override
  String get lockerReceivedFundLabel => 'المبلغ المستلَم';

  @override
  String get lockerFailedToLoad => 'فشل التحميل';

  @override
  String get lockerOneCollection => 'تحصيل واحد';

  @override
  String lockerNCollections(int count) {
    return '$count تحصيلات';
  }

  @override
  String get lockerStoragePermissionRequired => 'إذن التخزين مطلوب';

  @override
  String get lockerStoragePermissionBody => 'إذن التخزين مطلوب لحفظ الملفات المُصدَّرة. يرجى تفعيله من إعدادات التطبيق.';

  @override
  String get lockerOpenSettings => 'فتح الإعدادات';

  @override
  String get lockerFinancialHistoryPdfTitle => 'السجل المالي للخزينة';

  @override
  String get lockerPdfGenerated => 'تاريخ الإنشاء';

  @override
  String get lockerPdfTotal => 'الإجمالي';

  @override
  String get lockerPdfRecords => 'سجل';

  @override
  String get lockerPdfRef => 'المرجع';

  @override
  String get lockerPdfDate => 'التاريخ';

  @override
  String get lockerPdfBranch => 'الفرع';

  @override
  String get lockerPdfReceived => 'المستلَم';

  @override
  String get lockerPdfExpected => 'المتوقَّع';

  @override
  String get lockerPdfDiff => 'الفارق';

  @override
  String get lockerPdfStatus => 'الحالة';

  @override
  String get lockerPdfExportFailed => 'فشل تصدير PDF';

  @override
  String get lockerExcelSheetName => 'سجل الخزينة';

  @override
  String get lockerExcelOfficer => 'الموظف';

  @override
  String get lockerExcelReceivedSar => 'المستلَم (ريال)';

  @override
  String get lockerExcelExpectedSar => 'المتوقَّع (ريال)';

  @override
  String get lockerExcelDiffSar => 'الفارق (ريال)';

  @override
  String get lockerExcelRequestRef => 'مرجع الطلب';

  @override
  String get lockerExcelExportFailed => 'فشل تصدير إكسل';

  @override
  String get accountingTitle => 'المحاسبة';

  @override
  String get accountingTabPayables => 'المستحقات';

  @override
  String get accountingTabReceivables => 'المديونيات';

  @override
  String get accountingTabExpenses => 'المصروفات';

  @override
  String get accountingTabAdvances => 'السلف';

  @override
  String get accountingPayables => 'المستحقات';

  @override
  String get accountingReceivables => 'المديونيات';

  @override
  String get accountingOverdue => 'المتأخرات';

  @override
  String get accountingNoEntries => 'لا توجد إدخالات';

  @override
  String accountingRefPrefix(String ref, String date) {
    return 'مرجع: $ref • $date';
  }

  @override
  String get accountingStatusOverdue => 'متأخر';

  @override
  String get accountingStatusSettled => 'مسوَّى';

  @override
  String get accountingStatusPending => 'قيد الانتظار';

  @override
  String get accountingLoadingError => 'فشل تحميل بيانات المحاسبة';

  @override
  String accountingAmountLabel(String amount) {
    return 'ر.س $amount';
  }

  @override
  String get approvalsTitle => 'الموافقات';

  @override
  String get approvalsQueueLabel => 'قائمة الانتظار';

  @override
  String get approvalsStatusLabel => 'الحالة';

  @override
  String get approvalsQueueAll => 'الكل';

  @override
  String get approvalsQueueTopUps => 'شحن الرصيد';

  @override
  String get approvalsQueueExpenses => 'المصروفات';

  @override
  String get approvalsStatusAll => 'الكل';

  @override
  String get approvalsStatusPending => 'قيد الانتظار';

  @override
  String get approvalsStatusApproved => 'معتمد';

  @override
  String get approvalsStatusRejected => 'مرفوض';

  @override
  String get approvalsEmptyExpenses => 'لا توجد موافقات مصروفات';

  @override
  String get approvalsEmptyPettyCash => 'لا توجد طلبات صندوق صغير';

  @override
  String get approvalsEmptySubtitle => 'لا توجد سجلات لهذه القائمة والحالة.';

  @override
  String get approvalsNoAddressesFound => 'لم يتم العثور على عناوين.';

  @override
  String get approvalsLoadingError => 'فشل تحميل الموافقات';

  @override
  String get approvalsApproveConfirm => 'الموافقة على هذا الطلب؟';

  @override
  String get approvalsRejectTitle => 'رفض الطلب';

  @override
  String get approvalsRejectHint => 'أدخل سبب الرفض (اختياري)';

  @override
  String get approvalsConfirmReject => 'تأكيد الرفض';

  @override
  String get approvalsCancel => 'إلغاء';

  @override
  String get ownerLoginTitle => 'صاحب الورشة';

  @override
  String get ownerLoginSubtitle => 'سجّل الدخول إلى لوحة التحكم';

  @override
  String get ownerLoginEmail => 'البريد الإلكتروني';

  @override
  String get ownerLoginEmailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get ownerLoginEmailRequired => 'يرجى إدخال البريد الإلكتروني';

  @override
  String get ownerLoginPassword => 'كلمة المرور';

  @override
  String get ownerLoginPasswordHint => 'أدخل كلمة المرور';

  @override
  String get ownerLoginPasswordRequired => 'يرجى إدخال كلمة المرور';

  @override
  String get ownerLoginForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get ownerLoginSignIn => 'تسجيل الدخول';

  @override
  String get ownerLoginSuccess => 'تم تسجيل الدخول بنجاح';

  @override
  String get ownerLoginFailed => 'فشل تسجيل الدخول';

  @override
  String get ownerLoginNoAccount => 'ليس لديك حساب؟ سجّل الآن';

  @override
  String get ownerRegisterTitle => 'إنشاء حساب';

  @override
  String get ownerRegisterSubtitle => 'تسجيل ورشتك';

  @override
  String get ownerRegisterWorkshopName => 'اسم الورشة';

  @override
  String get ownerRegisterWorkshopNameHint => 'أدخل اسم الورشة';

  @override
  String get ownerRegisterOwnerName => 'اسم المالك';

  @override
  String get ownerRegisterOwnerNameHint => 'أدخل الاسم الكامل';

  @override
  String get ownerRegisterEmail => 'البريد الإلكتروني';

  @override
  String get ownerRegisterEmailHint => 'أدخل البريد الإلكتروني';

  @override
  String get ownerRegisterMobile => 'رقم الجوال';

  @override
  String get ownerRegisterMobileHint => '+966...';

  @override
  String get ownerRegisterTaxId => 'الرقم الضريبي';

  @override
  String get ownerRegisterTaxIdHint => 'أدخل الرقم الضريبي';

  @override
  String get ownerRegisterAddress => 'العنوان';

  @override
  String get ownerRegisterAddressHint => 'ابحث عن العنوان الكامل واختره';

  @override
  String get ownerRegisterPassword => 'كلمة المرور';

  @override
  String get ownerRegisterPasswordHint => 'أنشئ كلمة مرور';

  @override
  String get ownerRegisterButton => 'تسجيل';

  @override
  String get ownerRegisterSuccess => 'تم التسجيل بنجاح. يرجى تسجيل الدخول.';

  @override
  String get ownerRegisterFailed => 'فشل التسجيل';

  @override
  String get ownerRegisterFieldRequired => 'مطلوب';

  @override
  String get ownerRegisterHaveAccount => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get corporateManagementTitle => 'إدارة الشركات';

  @override
  String get corporateSearchHint => 'البحث بالاسم أو الرقم الضريبي...';

  @override
  String get corporateAddButton => 'إضافة شركة';

  @override
  String get corporateNoneFound => 'لا يوجد عملاء شركات.';

  @override
  String corporateVatLabel(String vat) {
    return 'ض.ق.م: $vat';
  }

  @override
  String get corporateVehiclesLabel => 'المركبات';

  @override
  String get corporateRevenueLabel => 'الإيرادات';

  @override
  String get corporateAddUser => 'إضافة مستخدم';

  @override
  String get corporateEdit => 'تعديل';

  @override
  String get corporateRegisterTitle => 'تسجيل شريك مؤسسي';

  @override
  String get corporateRegisterSubtitle => 'أدخل التفاصيل لإنشاء حساب مؤسسي جديد.';

  @override
  String get corporateFieldCompanyName => 'اسم الشركة';

  @override
  String get corporateFieldCustomerName => 'اسم العميل';

  @override
  String get corporateFieldMobile => 'رقم الجوال';

  @override
  String get corporateFieldVat => 'الرقم الضريبي';

  @override
  String get corporateFieldEmail => 'البريد الإلكتروني';

  @override
  String get corporateFieldPassword => 'كلمة المرور';

  @override
  String get corporateFieldReferral => 'المحيل';

  @override
  String get corporateSelectBranches => 'اختر الفروع';

  @override
  String corporateSelectedCount(int count) {
    return '$count مختار';
  }

  @override
  String get corporateNoBranches => 'لا توجد فروع';

  @override
  String get corporateCreateButton => 'إنشاء الشريك';

  @override
  String get corporateAddUserTitle => 'إضافة مستخدم مؤسسي';

  @override
  String get corporateAddUserSubtitle => 'أنشئ بيانات اعتماد لمستخدم مرتبط بهذا الحساب المؤسسي.';

  @override
  String get corporateUserFieldName => 'الاسم الكامل';

  @override
  String get corporateUserFieldEmail => 'البريد الإلكتروني';

  @override
  String get corporateUserFieldPassword => 'كلمة المرور';

  @override
  String get corporateCreateUserButton => 'إنشاء المستخدم';

  @override
  String get corporateEditTitle => 'تعديل الحساب المؤسسي';

  @override
  String get corporateEditSubtitle => 'حدِّث التفاصيل أدناه. سيُرسَل فقط ما تم تغييره.';

  @override
  String get corporateFieldMobileMobile => 'الجوال';

  @override
  String get corporateFieldTaxId => 'الرقم الضريبي (ض.ق.م)';

  @override
  String get corporateFieldStatus => 'الحالة';

  @override
  String get corporateSaveChanges => 'حفظ التغييرات';

  @override
  String get corporateStatusPending => 'قيد الانتظار';

  @override
  String get corporateStatusActive => 'نشط';

  @override
  String get corporateStatusRejected => 'مرفوض';

  @override
  String get corporateCreateSuccess => 'تم إنشاء الحساب المؤسسي بنجاح';

  @override
  String get corporateCreateError => 'فشل إنشاء الحساب المؤسسي';

  @override
  String get corporateUpdateSuccess => 'تم تحديث الحساب المؤسسي بنجاح';

  @override
  String get corporateUpdateError => 'فشل تحديث الحساب المؤسسي';

  @override
  String get corporateUserCreateSuccess => 'تم إنشاء المستخدم المؤسسي بنجاح';

  @override
  String get corporateUserCreateError => 'فشل إنشاء المستخدم المؤسسي';

  @override
  String get corporateValidationRequired => 'يرجى ملء جميع الحقول المطلوبة';

  @override
  String get corporateValidationBranch => 'يرجى اختيار فرع واحد على الأقل';

  @override
  String get corporateValidationCompanyName => 'اسم الشركة مطلوب';

  @override
  String get dashboardAllBranches => 'جميع الفروع';

  @override
  String get dashboardViewingDataFor => 'عرض بيانات';

  @override
  String get dashboardAllBranchesAggregated => 'جميع الفروع مجمّعة';

  @override
  String get dashboardSelectBranch => 'اختر الفرع';

  @override
  String get dashboardKpiTotalSalesToday => 'إجمالي مبيعات اليوم';

  @override
  String get dashboardKpiThisMonth => 'هذا الشهر';

  @override
  String get dashboardKpiPendingInvoices => 'الفواتير المعلقة';

  @override
  String get dashboardKpiLowStockAlerts => 'تنبيهات نقص المخزون';

  @override
  String get dashboardKpiTodaysSales => 'مبيعات اليوم';

  @override
  String get dashboardKpiActiveOrders => 'الطلبات النشطة';

  @override
  String get dashboardKpiTechWorkload => 'حمل الفني';

  @override
  String get dashboardKpiPendingApproval => 'بانتظار الموافقة';

  @override
  String get dashboardPendingApprovalsTitle => 'الموافقات المعلقة';

  @override
  String get dashboardViewAll => 'عرض الكل';

  @override
  String get dashboardNoPendingApprovals => 'لا توجد طلبات صندوق صغير معلقة الآن.';

  @override
  String dashboardMoreApprovals(int count) {
    return '+$count أخرى في الموافقات';
  }

  @override
  String get dashboardBranchPerformance => 'أداء الفروع';

  @override
  String get dashboardBranchHighlights => 'أبرز الفرع';

  @override
  String get dashboardBranchStatus => 'حالة الفرع';

  @override
  String get dashboardTotalStaff => 'إجمالي الموظفين';

  @override
  String get dashboardSalesTarget => 'هدف المبيعات';

  @override
  String get dashboardSalesTargetValue => '85% محقق';

  @override
  String get branchPerformanceListTitle => 'أداء الفروع';

  @override
  String get branchPerformanceNoBranches => 'لا توجد فروع بعد.';

  @override
  String get deptMgmtTitle => 'إدارة الأقسام';

  @override
  String get deptMgmtSearchHint => 'بحث باسم القسم...';

  @override
  String get deptMgmtAddButton => 'إضافة قسم جديد';

  @override
  String get deptMgmtNoDepartments => 'لا توجد أقسام.';

  @override
  String get deptMgmtLabelDepartment => 'قسم';

  @override
  String get deptMgmtMenuEdit => 'تعديل';

  @override
  String get deptMgmtMenuDelete => 'حذف';

  @override
  String get deptMgmtConfirmDeleteTitle => 'تأكيد الحذف';

  @override
  String deptMgmtConfirmDeleteBody(String name) {
    return 'هل أنت متأكد من حذف \"$name\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get deptMgmtCancel => 'إلغاء';

  @override
  String get deptMgmtDelete => 'حذف';

  @override
  String get deptMgmtStatusActive => 'نشط';

  @override
  String get deptMgmtStatusInactive => 'غير نشط';

  @override
  String get deptMgmtSheetAddTitle => 'إضافة قسم';

  @override
  String get deptMgmtSheetUpdateTitle => 'تحديث القسم';

  @override
  String get deptMgmtSheetAddSubtitle => 'أدخل اسم القسم الجديد.';

  @override
  String get deptMgmtSheetUpdateSubtitle => 'تعديل تفاصيل القسم الحالي.';

  @override
  String get deptMgmtFieldName => 'اسم القسم';

  @override
  String get deptMgmtFieldActiveStatus => 'الحالة النشطة';

  @override
  String get deptMgmtSheetAddButton => 'إضافة قسم';

  @override
  String get deptMgmtSheetUpdateButton => 'تحديث القسم';

  @override
  String get deptMgmtValidationNameRequired => 'اسم القسم مطلوب';

  @override
  String get deptMgmtCreateSuccess => 'تم إنشاء القسم بنجاح';

  @override
  String get deptMgmtUpdateSuccess => 'تم تحديث القسم بنجاح';

  @override
  String get deptMgmtDeleteSuccess => 'تم حذف القسم بنجاح';

  @override
  String get deptMgmtSaveError => 'فشل حفظ القسم';

  @override
  String get deptMgmtDeleteError => 'فشل حذف القسم';

  @override
  String get empMgmtTitle => 'إدارة الموظفين';

  @override
  String get empMgmtSearchHint => 'بحث بالاسم أو البريد أو الجوال...';

  @override
  String get empMgmtAddButton => 'إضافة موظف';

  @override
  String get empMgmtFilterAllBranches => 'جميع الفروع';

  @override
  String get empMgmtNoEmployees => 'لا يوجد موظفون.';

  @override
  String empMgmtLastSeen(String time) {
    return 'آخر ظهور: $time';
  }

  @override
  String get empMgmtInfoBranch => 'الفرع';

  @override
  String get empMgmtInfoDept => 'القسم';

  @override
  String get empMgmtInfoRoleType => 'نوع الدور';

  @override
  String get empMgmtInfoTechType => 'نوع الفني';

  @override
  String get empMgmtInfoSalary => 'الراتب';

  @override
  String get empMgmtInfoCommission => 'العمولة';

  @override
  String get empMgmtInfoUnknown => 'غير محدد';

  @override
  String get empMgmtInfoNone => 'لا يوجد';

  @override
  String get empMgmtMenuEdit => 'تعديل';

  @override
  String get empMgmtMenuDelete => 'حذف';

  @override
  String get empMgmtDeleteTitle => 'حذف الموظف';

  @override
  String empMgmtDeleteBody(String name) {
    return 'هل أنت متأكد من حذف \"$name\"؟';
  }

  @override
  String get empMgmtDeleteCancel => 'إلغاء';

  @override
  String get empMgmtDeleteConfirm => 'حذف';

  @override
  String get empMgmtSheetAddTitle => 'إضافة موظف جديد';

  @override
  String get empMgmtSheetUpdateTitle => 'تحديث الموظف';

  @override
  String get empMgmtSheetAddSubtitle => 'أدخل التفاصيل لتسجيل عضو جديد.';

  @override
  String get empMgmtSheetUpdateSubtitle => 'تعديل بيانات الموظف الحالي.';

  @override
  String get empMgmtFieldRole => 'الدور';

  @override
  String get empMgmtFieldFullName => 'الاسم الكامل';

  @override
  String get empMgmtFieldMobile => 'رقم الجوال';

  @override
  String get empMgmtFieldEmail => 'البريد الإلكتروني';

  @override
  String get empMgmtFieldPassword => 'كلمة المرور';

  @override
  String get empMgmtFieldPasswordOptional => 'كلمة المرور (اختياري)';

  @override
  String get empMgmtFieldBranch => 'تعيين للفرع';

  @override
  String get empMgmtFieldDepartment => 'تعيين القسم';

  @override
  String get empMgmtFieldAddress => 'العنوان';

  @override
  String get empMgmtFieldOpeningBalance => 'الرصيد الافتتاحي';

  @override
  String get empMgmtFieldBaseSalary => 'الراتب الأساسي';

  @override
  String get empMgmtFieldCommission => 'نسبة العمولة %';

  @override
  String get empMgmtFieldActiveStatus => 'الحالة النشطة';

  @override
  String get empMgmtSectionTechSpecifics => 'تفاصيل الفني';

  @override
  String get empMgmtSectionSalary => 'الراتب والعمولة';

  @override
  String get empMgmtSectionAvailability => 'التوفر';

  @override
  String get empMgmtToggleWorkshop => 'فني ورشة';

  @override
  String get empMgmtToggleOnCall => 'فني عند الطلب';

  @override
  String get empMgmtNoAddressFound => 'لا توجد عناوين';

  @override
  String get empMgmtSaveButton => 'حفظ الموظف';

  @override
  String get empMgmtUpdateButton => 'تحديث الموظف';

  @override
  String get empMgmtRoleTechnician => 'فني';

  @override
  String get empMgmtRoleCashier => 'كاشير';

  @override
  String get empMgmtRoleSupplier => 'مورّد';

  @override
  String get empMgmtValidationRequired => 'يرجى ملء جميع الحقول المطلوبة.';

  @override
  String get empMgmtValidationTechType => 'يرجى اختيار نوع فني واحد على الأقل.';

  @override
  String get empMgmtValidationNoBranch => 'يرجى إنشاء فرع أولاً لتعيين هذا الموظف.';

  @override
  String get empMgmtValidationNoBranchCashier => 'يرجى إنشاء فرع أولاً لتعيين هذا الكاشير.';

  @override
  String get empMgmtValidationNoDepartment => 'يرجى إنشاء قسم أولاً لتعيين هذا الموظف.';

  @override
  String get empMgmtValidationSupplierRequired => 'يرجى ملء جميع الحقول المطلوبة';

  @override
  String get empMgmtApiNotIntegrated => 'الأنواع المتاحة للإنشاء: الفني، الكاشير، والمورّد فقط.';

  @override
  String get empMgmtTechnicianCreateSuccess => 'تم إنشاء الفني بنجاح';

  @override
  String get empMgmtTechnicianUpdateSuccess => 'تم تحديث الفني بنجاح';

  @override
  String get empMgmtTechnicianCreateError => 'فشل إنشاء الفني';

  @override
  String get empMgmtCashierCreateSuccess => 'تم إنشاء الكاشير بنجاح';

  @override
  String get empMgmtCashierUpdateSuccess => 'تم تحديث الكاشير بنجاح';

  @override
  String get empMgmtCashierCreateError => 'فشل إنشاء الكاشير';

  @override
  String get empMgmtSupplierCreateSuccess => 'تم إنشاء المورّد بنجاح';

  @override
  String get empMgmtSupplierCreateError => 'فشل إنشاء المورّد';

  @override
  String get empMgmtDeleteSuccess => 'تم حذف الموظف بنجاح';

  @override
  String get empMgmtDeleteError => 'فشل حذف الموظف';

  @override
  String get empStatusAvailable => 'متاح';

  @override
  String get empStatusOnline => 'متصل';

  @override
  String get empStatusBusy => 'مشغول';

  @override
  String get empStatusOffline => 'غير متصل';

  @override
  String get empLastSeenNever => 'أبداً';

  @override
  String get empLastSeenJustNow => 'الآن';

  @override
  String empLastSeenMinutes(int m) {
    return 'منذ $m د';
  }

  @override
  String empLastSeenHours(int h) {
    return 'منذ $h س';
  }

  @override
  String empLastSeenDays(int d) {
    return 'منذ $d ي';
  }

  @override
  String get empTechTypeWorkshop => 'ورشة';

  @override
  String get empTechTypeBoth => 'كلاهما';

  @override
  String get empTechTypeOnCall => 'عند الطلب';

  @override
  String get empRoleTechnician => 'فني';

  @override
  String get empRoleCashier => 'كاشير';

  @override
  String get empRoleSupplier => 'مورّد';

  @override
  String get invTitle => 'المخزون والمنتجات';

  @override
  String get invTabProducts => 'المنتجات';

  @override
  String get invTabServices => 'الخدمات';

  @override
  String get invTabCategory => 'الفئات';

  @override
  String get invAddProduct => 'إضافة منتج';

  @override
  String get invAddService => 'إضافة خدمة';

  @override
  String get invAddCategory => 'إضافة فئة';

  @override
  String get invAdd => 'إضافة';

  @override
  String get invSearchProductsHint => 'بحث بالاسم أو الفئة...';

  @override
  String get invSearchServicesHint => 'بحث في الخدمات...';

  @override
  String get invSearchCategoriesHint => 'بحث في الفئات...';

  @override
  String get invNoProductsFound => 'لا توجد منتجات.';

  @override
  String get invNoServicesFound => 'لا توجد خدمات.';

  @override
  String get invNoCategoriesFound => 'لا توجد فئات.';

  @override
  String get invNoProductsMatchSearch => 'لا توجد منتجات تطابق بحثك.';

  @override
  String get invNoServicesMatchSearch => 'لا توجد خدمات تطابق بحثك.';

  @override
  String get invNoCategoriesMatchSearch => 'لا توجد فئات تطابق بحثك.';

  @override
  String get invMetricStock => 'المخزون';

  @override
  String get invMetricPurchase => 'الشراء';

  @override
  String get invMetricRetail => 'البيع';

  @override
  String get invMetricPrice => 'السعر';

  @override
  String get invMetricCorpRange => 'نطاق الشركات';

  @override
  String get invMetricCorporate => 'الشركات';

  @override
  String get invEditTooltip => 'تعديل';

  @override
  String get invDeleteTooltip => 'حذف';

  @override
  String get invMenuEdit => 'تعديل';

  @override
  String get invMenuDelete => 'حذف';

  @override
  String get invConfirmDeleteTitle => 'تأكيد الحذف';

  @override
  String invConfirmDeleteBody(String name) => 'هل تريد حذف "$name"؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get invCancel => 'إلغاء';

  @override
  String get invConfirm => 'تأكيد';

  @override
  String get invCategoryTabProducts => 'المنتجات';

  @override
  String get invCategoryTabServices => 'الخدمات';

  @override
  String get invCreateProduct => 'إنشاء منتج';

  @override
  String get invUpdateProduct => 'تحديث المنتج';

  @override
  String get invCreateProductSubtitle => 'أدخل تفاصيل المنتج لإضافته إلى المخزون.';

  @override
  String get invUpdateProductSubtitle => 'تعديل تفاصيل المنتج الحالي.';

  @override
  String get invFieldBranch => 'الفرع';

  @override
  String get invFieldDepartment => 'القسم';

  @override
  String get invFieldCategory => 'الفئة';

  @override
  String get invFieldProductName => 'اسم المنتج';

  @override
  String get invFieldStockQty => 'كمية المخزون';

  @override
  String get invFieldUnit => 'الوحدة';

  @override
  String get invFieldCriticalStock => 'نقطة المخزون الحرجة';

  @override
  String get invSectionPricing => 'تفاصيل التسعير';

  @override
  String get invFieldPurchasePrice => 'سعر الشراء';

  @override
  String get invFieldSalePrice => 'سعر البيع';

  @override
  String get invFieldMinCorpPrice => 'أدنى سعر للشركات';

  @override
  String get invFieldMaxCorpPrice => 'أعلى سعر للشركات';

  @override
  String get invToggleDecimal => 'السماح بالكسور العشرية';

  @override
  String get invToggleActive => 'الحالة النشطة';

  @override
  String get invSaveProduct => 'حفظ المنتج';

  @override
  String get invProductCreateSuccess => 'تم إنشاء المنتج بنجاح';

  @override
  String get invProductUpdateSuccess => 'تم تحديث المنتج بنجاح';

  @override
  String get invProductCreateError => 'فشل إنشاء المنتج';

  @override
  String get invProductDeleteSuccess => 'تم حذف المنتج بنجاح';

  @override
  String get invProductDeleteError => 'فشل حذف المنتج';

  @override
  String get invValidationFillRequired => 'يرجى ملء جميع الحقول المطلوبة.';

  @override
  String get invValidationSelectDepartment => 'يرجى اختيار قسم.';

  @override
  String get invValidationCreateCategory => 'يرجى إنشاء فئة أولاً.';

  @override
  String get invValidationSelectBranch => 'يرجى اختيار فرع.';

  @override
  String get invCreateService => 'إنشاء خدمة';

  @override
  String get invUpdateService => 'تحديث الخدمة';

  @override
  String get invCreateServiceSubtitle => 'أدخل تفاصيل الخدمة.';

  @override
  String get invUpdateServiceSubtitle => 'تعديل تفاصيل الخدمة الحالية.';

  @override
  String get invFieldServiceName => 'اسم الخدمة';

  @override
  String get invFieldServicePrice => 'سعر الخدمة';

  @override
  String get invTogglePriceEditable => 'يمكن للكاشير تغيير السعر في نقطة البيع';

  @override
  String get invSaveService => 'حفظ الخدمة';

  @override
  String get invServiceCreateSuccess => 'تم إنشاء الخدمة بنجاح';

  @override
  String get invServiceUpdateSuccess => 'تم تحديث الخدمة بنجاح';

  @override
  String get invServiceCreateError => 'فشل إنشاء الخدمة';

  @override
  String get invServiceDeleteSuccess => 'تم حذف الخدمة بنجاح';

  @override
  String get invServiceDeleteError => 'فشل حذف الخدمة';

  @override
  String get invValidationFillServiceRequired => 'يرجى ملء الحقول المطلوبة.';

  @override
  String get invCreateCategory => 'إنشاء فئة';

  @override
  String get invUpdateCategory => 'تحديث الفئة';

  @override
  String get invCreateCategorySubtitle => 'أدخل تفاصيل الفئة الجديدة.';

  @override
  String get invUpdateCategorySubtitle => 'تعديل تفاصيل الفئة الحالية.';

  @override
  String get invFieldCategoryName => 'اسم الفئة';

  @override
  String get invSaveCategory => 'حفظ الفئة';

  @override
  String get invCategoryCreateSuccess => 'تم إنشاء الفئة بنجاح';

  @override
  String get invCategoryUpdateSuccess => 'تم تحديث الفئة بنجاح';

  @override
  String get invCategoryCreateError => 'فشل إنشاء الفئة';

  @override
  String get invCategoryDeleteSuccess => 'تم حذف الفئة بنجاح';

  @override
  String get invCategoryDeleteError => 'فشل حذف الفئة';

  @override
  String get invCreateSubCategory => 'إنشاء فئة فرعية';

  @override
  String get invCreateSubCategorySubtitle => 'أدخل تفاصيل الفئة الفرعية الجديدة.';

  @override
  String get invFieldSubCategoryName => 'اسم الفئة الفرعية';

  @override
  String get invSaveSubCategory => 'حفظ الفئة الفرعية';

  @override
  String get invSubCategoryCreateSuccess => 'تم إنشاء الفئة الفرعية بنجاح';

  @override
  String get invSubCategoryUpdateSuccess => 'تم تحديث الفئة الفرعية بنجاح';

  @override
  String get invSubCategoryCreateError => 'فشل إنشاء الفئة الفرعية';

  @override
  String get invSubCategoryDeleteSuccess => 'تم حذف الفئة الفرعية بنجاح';

  @override
  String get invSubCategoryDeleteError => 'فشل حذف الفئة الفرعية';

  // ── Notifications ─────────────────────────────────────────────────────────

  @override
  String get notifTitle => 'الإشعارات';

  @override
  String get notifMarkRead => 'تحديد الكل كمقروء';

  @override
  String get notifEmpty => 'لا توجد إشعارات بعد.';

  @override
  String notifTimeMinutes(int m) => 'منذ $m د';

  @override
  String notifTimeHours(int h) => 'منذ $h س';

  @override
  String notifTimeDays(int d) => 'منذ $d ي';

  @override
  String get posMonitoringTitle => 'مراقبة نقاط البيع';

  @override
  String get posMonitoringLiveCounters => 'الكاونترات المباشرة';

  @override
  String get posMonitoringClosingReports => 'تقارير الإغلاق';

  @override
  String get posMonitoringSummaryLiveCounters => 'الكاونترات المباشرة';

  @override
  String get posMonitoringSummaryOpenOrders => 'الطلبات المفتوحة';

  @override
  String get posMonitoringSummaryTodaySales => 'مبيعات اليوم';

  @override
  String get posMonitoringNoLiveCounters => 'لا توجد كاونترات مباشرة نشطة';

  @override
  String get posMonitoringNoClosingReports => 'لا توجد تقارير إغلاق متاحة';

  @override
  String get posMonitoringStatusOpen => 'مفتوح';

  @override
  String get posMonitoringStatusClosing => 'جارٍ الإغلاق';

  @override
  String get posMonitoringStatusClosed => 'مغلق';

  @override
  String get posMonitoringStatShiftSales => 'مبيعات الوردية';

  @override
  String get posMonitoringStatOpenOrders => 'الطلبات المفتوحة';

  @override
  String get posMonitoringStatElapsed => 'الوقت المنقضي';

  @override
  String posMonitoringElapsedFormat(int h, int m) => '${h}س ${m}د';

  @override
  String get posMonitoringClosed => 'مغلق';

  @override
  String get posMonitoringTableCategory => 'الفئة';

  @override
  String get posMonitoringTableSystem => 'النظام';

  @override
  String get posMonitoringTablePhysical => 'الفعلي';

  @override
  String get posMonitoringTableDiff => 'الفارق';

  @override
  String get posMonitoringTableTotalSales => 'إجمالي المبيعات';

  @override
  String get posMonitoringRowCash => 'نقد';

  @override
  String get posMonitoringRowBank => 'بنك/بطاقات';

  @override
  String get posMonitoringRowCorporate => 'شركات';

  @override
  String get posMonitoringRowTamara => 'تمارا';

  @override
  String get posMonitoringRowTabby => 'تابي';

  @override
  String get posMonitoringDiffShort => 'ناقص';

  @override
  String get posMonitoringDiffExcess => 'زائد';

  @override
  String get posMonitoringDiffBalanced => 'متوازن';

  @override
  String posMonitoringDiffShortSymbol(String amount) => '− ر.س $amount';

  @override
  String posMonitoringDiffExcessSymbol(String amount) => '+ ر.س $amount';

  @override
  String get posMonitoringDiffNone => '—';

  @override
  String get posMonitoringBackendWarning =>
      '⚠ التفاصيل الكاملة غير متاحة — يرجى تحديث الخادم للاطلاع على بيانات كل فئة';

  @override
  String posMonitoringAmountSar(String amount) => 'ر.س $amount';

  // ── Promo Codes ──────────────────────────────────────────────────────────────

  @override
  String get promoTitle => 'رموز العروض';

  @override
  String get promoNewButton => 'عرض جديد';

  @override
  String get promoNoCodesFound => 'لا توجد رموز عروض';

  @override
  String get promoMenuEdit => 'تعديل';

  @override
  String get promoMenuDelete => 'حذف';

  @override
  String promoDiscountOff(String value, String unit) => '$value $unit خصم';

  @override
  String get promoUnitPercent => '%';

  @override
  String get promoUnitSar => 'ر.س';

  @override
  String get promoStatUsage => 'الاستخدام';

  @override
  String get promoStatMinOrder => 'الحد الأدنى للطلب';

  @override
  String get promoStatValidTill => 'صالح حتى';

  @override
  String promoMinOrderAmount(String amount) => 'ر.س $amount';

  @override
  String get promoDeleteConfirmTitle => 'تأكيد الحذف';

  @override
  String promoDeleteConfirmBody(String code) =>
      'هل أنت متأكد من حذف "$code"؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get promoDeleteCancel => 'إلغاء';

  @override
  String get promoDeleteConfirm => 'حذف';

  @override
  String get promoSheetCreateTitle => 'إنشاء رمز عرض';

  @override
  String get promoSheetUpdateTitle => 'تحديث رمز العرض';

  @override
  String get promoSheetCreateSubtitle => 'قم بضبط رمز خصم جديد للعملاء.';

  @override
  String get promoSheetUpdateSubtitle => 'تعديل تفاصيل رمز العرض الحالي.';

  @override
  String get promoFieldCode => 'رمز العرض (مثال: SUMMER20)';

  @override
  String get promoFieldDiscountValue => 'قيمة الخصم';

  @override
  String get promoFieldUsageLimit => 'حد الاستخدام';

  @override
  String get promoFieldMinOrder => 'الحد الأدنى للطلب (ر.س)';

  @override
  String get promoFieldDescription => 'الوصف';

  @override
  String get promoFieldValidFrom => 'صالح من';

  @override
  String get promoFieldValidTo => 'صالح حتى';

  @override
  String get promoTypeFixed => 'مبلغ ثابت';

  @override
  String get promoTypePercent => 'نسبة مئوية (%)';

  @override
  String get promoSubmitCreate => 'إنشاء العرض';

  @override
  String get promoSubmitUpdate => 'تحديث العرض';

  @override
  String get promoValidationRequired =>
      'يرجى ملء الحقول المطلوبة (الرمز، القيمة)';

  @override
  String get promoCreateSuccess => 'تم إنشاء رمز العرض بنجاح!';

  @override
  String get promoUpdateSuccess => 'تم تحديث رمز العرض بنجاح!';

  @override
  String get promoDeleteSuccess => 'تم حذف رمز العرض بنجاح!';

  @override
  String get promoCreateError => 'فشل معالجة رمز العرض';

  @override
  String get promoDeleteError => 'فشل حذف رمز العرض';

  @override
  String get posAddCustomerTitle => 'إضافة عميل جديد';

  @override
  String get posAddCustomerTabNormal => 'عميل عادي';

  @override
  String get posAddCustomerTabCorporate => 'عميل مؤسسي';

  @override
  String get posAddCustomerSectionVehicleInfo => 'معلومات المركبة';

  @override
  String get posAddCustomerSectionCompanyDetails => 'تفاصيل الشركة (مُعبَّأة تلقائياً)';

  @override
  String get posAddCustomerSectionCorporateAccount => 'الحساب المؤسسي';

  @override
  String get posAddCustomerFieldVehicleNumber => 'رقم المركبة';

  @override
  String get posAddCustomerFieldVin => 'رقم الهيكل (VIN)';

  @override
  String get posAddCustomerFieldMake => 'الشركة المصنِّعة';

  @override
  String get posAddCustomerFieldModel => 'الطراز';

  @override
  String get posAddCustomerFieldOdometer => 'عداد المسافة';

  @override
  String get posAddCustomerFieldCompanyName => 'اسم الشركة';

  @override
  String get posAddCustomerFieldVatNumber => 'الرقم الضريبي';

  @override
  String get posAddCustomerFieldBillingAddress => 'عنوان الفوترة';

  @override
  String get posAddCustomerSelectCorporate => 'اختر الحساب المؤسسي';

  @override
  String get posAddCustomerNoCorporateFound => 'لا توجد حسابات مؤسسية';

  @override
  String get posAddCustomerSaveButton => 'حفظ والمتابعة إلى القسم';

  @override
  String get posAddCustomerFieldNA => 'غير متوفر';

  @override
  String get posAddCustomerValidationVehicleRequired => 'يرجى إدخال رقم المركبة';

  @override
  String get posAddCustomerValidationRequired => 'مطلوب';

  @override
  String get posAddCustomerValidationVinMax => 'الحد الأقصى 17 حرفاً';

  @override
  String get posAddCustomerValidationInvalidNumber => 'يرجى إدخال رقم صحيح';

  @override
  String get posAddCustomerValidationInvalidNumberShort => 'رقم غير صحيح';

  // ── Reports & Analytics ──────────────────────────────────────────────────
  @override
  String get reportsTitle => 'التقارير والتحليلات';

  @override
  String get reportsFinancialOverview => 'النظرة المالية العامة';

  @override
  String get reportsOperationalPerformance => 'الأداء التشغيلي';

  @override
  String get reportsInventoryValuation => 'تقييم المخزون';

  @override
  String get reportsTotalRevenue => 'إجمالي الإيرادات';

  @override
  String get reportsNoDataThisWeek => 'لا توجد بيانات لهذا الأسبوع';

  @override
  String reportsTotalJobs(int count) => 'إجمالي الأعمال: $count';

  @override
  String get reportsCommissionLabel => 'العمولة';

  @override
  String get reportsStockValueCost => 'قيمة المخزون (التكلفة)';

  @override
  String get reportsPotentialProfit => 'الربح المتوقع';

  @override
  String get reportsActiveSkus => 'المنتجات النشطة';

  @override
  String reportsItemsUnit(int count) => '$count منتج';

  @override
  String reportsAmountSar(String amount) => 'ر.س $amount';

  @override
  String get reportsNoOperationalData => 'لا توجد بيانات أداء تشغيلي';

  @override
  String reportsRevChangePositive(String pct) => '+$pct%';

  @override
  String reportsRevChangeNegative(String pct) => '$pct%';

  // ── Owner shared widgets / petty cash ────────────────────────────────────
  @override
  String get ownerCommonSearchHint => 'بحث...';

  @override
  String get ownerBottomHome => 'الرئيسية';

  @override
  String get ownerBottomReports => 'التقارير';

  @override
  String get ownerBottomBilling => 'الفوترة';

  @override
  String get ownerBottomProfile => 'الملف الشخصي';

  @override
  String get ownerDashboardRoleLabel => 'مالك الورشة';

  @override
  String get ownerMonthlySales => 'المبيعات الشهرية';

  @override
  String get ownerCurrencySar => 'ر.س';

  @override
  String ownerCurrencyAmount(String currency, String amount) => '$amount $currency';

  @override
  String get pettyCashQueueCashierExpense => 'مصروف أمين الصندوق';

  @override
  String get pettyCashQueueFundRequest => 'طلب تمويل';

  @override
  String get pettyCashRequestLabel => 'طلب عهدة نقدية';

  @override
  String get pettyCashApprove => 'موافقة';

  @override
  String get pettyCashReject => 'رفض';

  @override
  String get pettyCashConfirmReject => 'تأكيد الرفض';

  @override
  String get pettyCashRejectRequestTitle => 'رفض الطلب';

  @override
  String get pettyCashRejectRequestBody => 'يرجى إدخال سبب الرفض.';

  @override
  String get pettyCashRejectReasonHint => 'مثال: الميزانية غير معتمدة';

  @override
  String get pettyCashRejectReasonRequired => 'يرجى إدخال سبب الرفض';

  @override
  String get pettyCashRequestApprovedSuccess => 'تمت الموافقة على الطلب بنجاح';

  @override
  String get pettyCashRequestApproveFailed => 'فشل اعتماد الطلب';

  @override
  String get pettyCashRequestRejectedSuccess => 'تم رفض الطلب بنجاح';

  @override
  String get pettyCashRequestRejectFailed => 'فشل رفض الطلب';

  @override
  String get pettyCashStatusPending => 'قيد الانتظار';

  @override
  String get pettyCashStatusApproved => 'معتمد';

  @override
  String get pettyCashStatusRejected => 'مرفوض';

  @override
  String pettyCashStatusFallback(String status) => status;

}
