import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  String get ownerShellHome;
  String get ownerShellBranches;
  String get ownerShellDepartments;
  String get ownerShellEmployees;
  String get ownerShellCorporate;
  String get ownerShellInventory;
  String get ownerShellPosMonitoring;
  String get ownerShellSuppliers;
  String get ownerShellAccounting;
  String get ownerShellPromoCodes;
  String get ownerShellApprovals;
  String get ownerShellNotifications;
  String get ownerShellLogout;
  String get ownerShellRoleLabel;
  String get ownerShellVersion;
  String get ownerShellLogoutTitle;
  String get ownerShellLogoutBody;
  String get ownerShellLogoutCancel;
  String get ownerShellLogoutConfirm;
  String get lockerDefaultUser;
  String get billingDashboardTitle;
  String get billingGenerateTitle;
  String get billingMonthlyTitle;
  String get billingOverdueTitle;
  String get billingDefaultTitle;
  String get billingSummaryTotalBilled;
  String get billingSummaryTotalReceived;
  String get billingSummaryOutstanding;
  String get billingSummaryOverdue;
  String get billingQuickActions;
  String get billingRecentActivity;
  String get billingSeeAll;
  String get billingNoRecentActivity;
  String get billingActionGenerate;
  String get billingActionViewAll;
  String get billingActionRecordPayment;
  String get billingActionSendReminders;
  String get billingGeneratorStep1;
  String get billingGeneratorStep2;
  String get billingGeneratorPendingInvoices;
  String get billingGeneratorPostAll;
  String billingPeriodLabel(String month, String year);
  String get billingStatusPaid;
  String get billingStatusOverdue;
  String get billingStatusPartiallyPaid;
  String get billingStatusPending;
  String get branchManagementTitle;
  String get branchSearchHint;
  String get branchAddButton;
  String get branchEditButton;
  String get branchDeleteButton;
  String get branchNoBranches;
  String get branchStatusActive;
  String get branchStatusInactive;
  String get branchFormTitleAdd;
  String get branchFormTitleEdit;
  String get branchFormNameLabel;
  String get branchFormNameHint;
  String get branchFormAddressLabel;
  String get branchFormAddressHint;
  String get branchFormLatLabel;
  String get branchFormLngLabel;
  String get branchFormStatusLabel;
  String get branchFormSaveButton;
  String get branchFormUpdateButton;
  String get branchFormValidationError;
  String get branchCreateSuccess;
  String get branchUpdateSuccess;
  String get branchDeleteSuccess;
  String get branchSaveError;
  String get branchDeleteError;
  String get branchDeleteConfirmTitle;
  String get branchDeleteConfirmBody;
  String get branchDeleteConfirmCancel;
  String get branchDeleteConfirmDelete;
  String get lockerPortalTitle;
  String get lockerPortalSubtitle;
  String get lockerPortalAppBarTitle;
  String get lockerSecureAssetManagement;
  String get lockerEmail;
  String get lockerEmailHint;
  String get lockerEmailRequired;
  String get lockerPassword;
  String get lockerPasswordHint;
  String get lockerPasswordRequired;
  String get lockerForgotPassword;
  String get lockerContinue;
  String get lockerLoadingDashboard;
  String get lockerFailedLoadDashboard;
  String get lockerUnexpectedError;
  String get lockerRetry;
  String get lockerRefresh;
  String get lockerSupervisorTab;
  String get lockerCollectorTab;
  String get lockerLogOut;
  String get lockerLogOutConfirm;
  String get lockerCancel;
  String get lockerLogOutButton;
  String get lockerWelcomeBack;
  String get lockerRoleSupervisor;
  String get lockerRoleManager;
  String get lockerRoleWorkshopOwner;
  String get lockerRoleWorkshopSupervisor;
  String get lockerRoleCollector;
  String get lockerRoleCollectionOfficer;
  String get lockerRoleWorkshopCollector;
  String get lockerSupervisorOverview;
  String get lockerMyPerformance;
  String get lockerKpiPending;
  String get lockerKpiAwaiting;
  String get lockerKpiOverdue;
  String get lockerKpiVariance;
  String get lockerKpiOpenAssignments;
  String get lockerKpiPendingApproval;
  String get lockerKpiTodaysCollections;
  String get lockerKpiMonthlyCollected;
  String get lockerCoreOperations;
  String get lockerManageAllRequests;
  String get lockerStartCollection;
  String get lockerAssignOfficers;
  String get lockerManageVarianceRequests;
  String get lockerFinancialAnalytics;
  String get lockerSearchHint;
  String get lockerLoadingRequests;
  String get lockerFailedLoadRequests;
  String get lockerNoRequestsFound;
  String get lockerAdjustFilters;
  String get lockerLockedCashAsset;
  String get lockerTapToCollect;
  String get lockerStatusPending;
  String get lockerStatusAssigned;
  String get lockerStatusAwaiting;
  String get lockerStatusCollected;
  String get lockerStatusApproved;
  String get lockerStatusRejected;
  String get lockerStatusMatched;
  String get lockerLoadingRequest;
  String get lockerFailedLoadDetails;
  String get lockerSystemStatus;
  String get lockerTotalSecuredAsset;
  String get lockerCounterClosing;
  String get lockerPhysicalCash;
  String get lockerSystemTotal;
  String get lockerDifference;
  String get lockerCollectionRecord;
  String get lockerReceived;
  String get lockerInternalData;
  String get lockerSourceBranch;
  String get lockerCashier;
  String get lockerCashierIdentity;
  String get lockerShiftCloseTime;
  String get lockerSessionOpened;
  String get lockerSessionClosed;
  String get lockerAssignedOfficer;
  String get lockerAssignCollectionOfficer;
  String get lockerProceedToCollection;
  String get lockerGenerateAuditPdf;
  String get lockerCollectionPendingApproval;
  String get lockerPendingSupervisorApproval;
  String get lockerCollectedSuccessfully;
  String get lockerVarianceApproved;
  String get lockerVarianceRejectedBanner;
  String get lockerVarianceDifferenceReview;
  String get lockerApproveVariance;
  String get lockerApprove;
  String get lockerReject;
  String get lockerRejectVarianceTitle;
  String get lockerRejectVarianceBody;
  String get lockerRejectionReasonHint;
  String get lockerConfirmReject;
  String get lockerVarianceRejected;
  String get lockerSelectOfficer;
  String get lockerSelectOfficerSubtitle;
  String get lockerOfficersLoadError;
  String get lockerAssignedTo;
  String get lockerLoaderAuditReport;
  String get lockerGeneratedAt;
  String get lockerPage;
  String get lockerOf;
  String get lockerRequestInformation;
  String get lockerPosSession;
  String get lockerOpenedAt;
  String get lockerClosedAt;
  String get lockerSessionStatus;
  String get lockerReceivedAmount;
  String get lockerNotes;
  String get lockerAuditFootnote;
  String lockerAuditFootnoteAmounts(String currency);
  String lockerCurrencyPrefix(String currency, String amount);
  String get lockerSarCurrency;
  String get lockerLoadingVariance;
  String get lockerFailedLoadVariance;
  String get lockerAllClear;
  String get lockerNoPendingVariance;
  String get lockerVarianceReviewBanner;
  String get lockerShortLabel;
  String get lockerOverLabel;
  String get lockerApproveVarianceTitle;
  String lockerApproveVarianceConfirm(String type, String amount, String branch);
  String get lockerApproveSuccess;
  String get lockerRejectSuccess;
  String get lockerRejectVarianceDialogTitle;
  String lockerRejectingFor(String branch);
  String get lockerRejectionReasonOptional;
  String get lockerShortVariance;
  String get lockerOverVariance;
  String get lockerCashierLabel;
  String get lockerOfficerLabel;
  String get lockerExpected;
  String get lockerReceivedLabel;
  String get lockerDiffLabel;
  String get lockerRecordCollectionTitle;
  String get lockerExpectedAmount;
  String get lockerVerifiedReceivedAmount;
  String get lockerLockedAmount;
  String get lockerReceivedAmountLabel;
  String get lockerCollectionNotes;
  String get lockerCollectionNotesHint;
  String get lockerCollectionEvidence;
  String get lockerCapturePhoto;
  String get lockerAttachLogs;
  String get lockerConfirmFinalise;
  String get lockerEnterValidAmount;
  String get lockerSuccessPendingApproval;
  String get lockerSuccessCollectionRecorded;
  String get lockerStatusReview;
  String get lockerStatusOk;
  String get lockerStatusLabel;
  String get lockerDone;
  String get lockerNotificationsTitle;
  String get lockerSessionExpired;
  String get lockerSomethingWentWrong;
  String get lockerCouldNotRefresh;
  String get lockerNoNotificationsYet;
  String get lockerTryAgain;
  String get lockerFinancialReports;
  String get lockerTabHistory;
  String get lockerTabAnalytics;
  String get lockerSearchByRefOrOfficer;
  String get lockerAuditLogs;
  String lockerRecordsCount(int count);
  String get lockerExportPdf;
  String get lockerExportExcel;
  String get lockerDifferencesSummary;
  String get lockerTotalShort;
  String get lockerTotalOver;
  String get lockerNetDifference;
  String get lockerTotalCollections;
  String get lockerMyCollectionPerformance;
  String get lockerCollectionPerformance;
  String get lockerOfficerComplianceRatings;
  String get lockerNoComplianceData;
  String get lockerNoResultsMatchFilters;
  String get lockerNoAuditLogsFound;
  String get lockerAnErrorOccurred;
  String get lockerAllRecords;
  String get lockerFilterSearch;
  String get lockerFilterBranch;
  String get lockerAllBranches;
  String get lockerFilterByBranch;
  String get lockerLoadingBranches;
  String get lockerSortBy;
  String get lockerSortDate;
  String get lockerSortReceivedAmount;
  String get lockerSortDifference;
  String get lockerSortAsc;
  String get lockerSortDesc;
  String get lockerSelectDateRange;
  String get lockerDateFrom;
  String get lockerDateTo;
  String get lockerTapToSet;
  String get lockerApplyFilter;
  String get lockerClearFilters;
  String get lockerNoData;
  String get lockerWeeklyCollectionVolume;
  String get lockerTransactionRef;
  String get lockerReceivedFundLabel;
  String get lockerFailedToLoad;
  String get lockerOneCollection;
  String lockerNCollections(int count);
  String get lockerStoragePermissionRequired;
  String get lockerStoragePermissionBody;
  String get lockerOpenSettings;
  String get lockerFinancialHistoryPdfTitle;
  String get lockerPdfGenerated;
  String get lockerPdfTotal;
  String get lockerPdfRecords;
  String get lockerPdfRef;
  String get lockerPdfDate;
  String get lockerPdfBranch;
  String get lockerPdfReceived;
  String get lockerPdfExpected;
  String get lockerPdfDiff;
  String get lockerPdfStatus;
  String get lockerPdfExportFailed;
  String get lockerExcelSheetName;
  String get lockerExcelOfficer;
  String get lockerExcelReceivedSar;
  String get lockerExcelExpectedSar;
  String get lockerExcelDiffSar;
  String get lockerExcelRequestRef;
  String get lockerExcelExportFailed;
  String get accountingTitle;
  String get accountingTabPayables;
  String get accountingTabReceivables;
  String get accountingTabExpenses;
  String get accountingTabAdvances;
  String get accountingPayables;
  String get accountingReceivables;
  String get accountingOverdue;
  String get accountingNoEntries;
  String accountingRefPrefix(String ref, String date);
  String get accountingStatusOverdue;
  String get accountingStatusSettled;
  String get accountingStatusPending;
  String get accountingLoadingError;
  String accountingAmountLabel(String amount);
  String get approvalsTitle;
  String get approvalsQueueLabel;
  String get approvalsStatusLabel;
  String get approvalsQueueAll;
  String get approvalsQueueTopUps;
  String get approvalsQueueExpenses;
  String get approvalsStatusAll;
  String get approvalsStatusPending;
  String get approvalsStatusApproved;
  String get approvalsStatusRejected;
  String get approvalsEmptyExpenses;
  String get approvalsEmptyPettyCash;
  String get approvalsEmptySubtitle;
  String get approvalsNoAddressesFound;
  String get approvalsLoadingError;
  String get approvalsApproveConfirm;
  String get approvalsRejectTitle;
  String get approvalsRejectHint;
  String get approvalsConfirmReject;
  String get approvalsCancel;
  String get ownerLoginTitle;
  String get ownerLoginSubtitle;
  String get ownerLoginEmail;
  String get ownerLoginEmailHint;
  String get ownerLoginEmailRequired;
  String get ownerLoginPassword;
  String get ownerLoginPasswordHint;
  String get ownerLoginPasswordRequired;
  String get ownerLoginForgotPassword;
  String get ownerLoginSignIn;
  String get ownerLoginSuccess;
  String get ownerLoginFailed;
  String get ownerLoginNoAccount;
  String get ownerRegisterTitle;
  String get ownerRegisterSubtitle;
  String get ownerRegisterWorkshopName;
  String get ownerRegisterWorkshopNameHint;
  String get ownerRegisterOwnerName;
  String get ownerRegisterOwnerNameHint;
  String get ownerRegisterEmail;
  String get ownerRegisterEmailHint;
  String get ownerRegisterMobile;
  String get ownerRegisterMobileHint;
  String get ownerRegisterTaxId;
  String get ownerRegisterTaxIdHint;
  String get ownerRegisterAddress;
  String get ownerRegisterAddressHint;
  String get ownerRegisterPassword;
  String get ownerRegisterPasswordHint;
  String get ownerRegisterButton;
  String get ownerRegisterSuccess;
  String get ownerRegisterFailed;
  String get ownerRegisterFieldRequired;
  String get ownerRegisterHaveAccount;
  String get corporateManagementTitle;
  String get corporateSearchHint;
  String get corporateAddButton;
  String get corporateNoneFound;
  String corporateVatLabel(String vat);
  String get corporateVehiclesLabel;
  String get corporateRevenueLabel;
  String get corporateAddUser;
  String get corporateEdit;
  String get corporateRegisterTitle;
  String get corporateRegisterSubtitle;
  String get corporateFieldCompanyName;
  String get corporateFieldCustomerName;
  String get corporateFieldMobile;
  String get corporateFieldVat;
  String get corporateFieldEmail;
  String get corporateFieldPassword;
  String get corporateFieldReferral;
  String get corporateSelectBranches;
  String corporateSelectedCount(int count);
  String get corporateNoBranches;
  String get corporateCreateButton;
  String get corporateAddUserTitle;
  String get corporateAddUserSubtitle;
  String get corporateUserFieldName;
  String get corporateUserFieldEmail;
  String get corporateUserFieldPassword;
  String get corporateCreateUserButton;
  String get corporateEditTitle;
  String get corporateEditSubtitle;
  String get corporateFieldMobileMobile;
  String get corporateFieldTaxId;
  String get corporateFieldStatus;
  String get corporateSaveChanges;
  String get corporateStatusPending;
  String get corporateStatusActive;
  String get corporateStatusRejected;
  String get corporateCreateSuccess;
  String get corporateCreateError;
  String get corporateUpdateSuccess;
  String get corporateUpdateError;
  String get corporateUserCreateSuccess;
  String get corporateUserCreateError;
  String get corporateValidationRequired;
  String get corporateValidationBranch;
  String get corporateValidationCompanyName;
  String get dashboardAllBranches;
  String get dashboardViewingDataFor;
  String get dashboardAllBranchesAggregated;
  String get dashboardSelectBranch;
  String get dashboardKpiTotalSalesToday;
  String get dashboardKpiThisMonth;
  String get dashboardKpiPendingInvoices;
  String get dashboardKpiLowStockAlerts;
  String get dashboardKpiTodaysSales;
  String get dashboardKpiActiveOrders;
  String get dashboardKpiTechWorkload;
  String get dashboardKpiPendingApproval;
  String get dashboardPendingApprovalsTitle;
  String get dashboardViewAll;
  String get dashboardNoPendingApprovals;
  String dashboardMoreApprovals(int count);
  String get dashboardBranchPerformance;
  String get dashboardBranchHighlights;
  String get dashboardBranchStatus;
  String get dashboardTotalStaff;
  String get dashboardSalesTarget;
  String get dashboardSalesTargetValue;
  String get branchPerformanceListTitle;
  String get branchPerformanceNoBranches;
  String get deptMgmtTitle;
  String get deptMgmtSearchHint;
  String get deptMgmtAddButton;
  String get deptMgmtNoDepartments;
  String get deptMgmtLabelDepartment;
  String get deptMgmtMenuEdit;
  String get deptMgmtMenuDelete;
  String get deptMgmtConfirmDeleteTitle;
  String deptMgmtConfirmDeleteBody(String name);
  String get deptMgmtCancel;
  String get deptMgmtDelete;
  String get deptMgmtStatusActive;
  String get deptMgmtStatusInactive;
  String get deptMgmtSheetAddTitle;
  String get deptMgmtSheetUpdateTitle;
  String get deptMgmtSheetAddSubtitle;
  String get deptMgmtSheetUpdateSubtitle;
  String get deptMgmtFieldName;
  String get deptMgmtFieldActiveStatus;
  String get deptMgmtSheetAddButton;
  String get deptMgmtSheetUpdateButton;
  String get deptMgmtValidationNameRequired;
  String get deptMgmtCreateSuccess;
  String get deptMgmtUpdateSuccess;
  String get deptMgmtDeleteSuccess;
  String get deptMgmtSaveError;
  String get deptMgmtDeleteError;
  String get empMgmtTitle;
  String get empMgmtSearchHint;
  String get empMgmtAddButton;
  String get empMgmtFilterAllBranches;
  String get empMgmtNoEmployees;
  String empMgmtLastSeen(String time);
  String get empMgmtInfoBranch;
  String get empMgmtInfoDept;
  String get empMgmtInfoRoleType;
  String get empMgmtInfoTechType;
  String get empMgmtInfoSalary;
  String get empMgmtInfoCommission;
  String get empMgmtInfoUnknown;
  String get empMgmtInfoNone;
  String get empMgmtMenuEdit;
  String get empMgmtMenuDelete;
  String get empMgmtDeleteTitle;
  String empMgmtDeleteBody(String name);
  String get empMgmtDeleteCancel;
  String get empMgmtDeleteConfirm;
  String get empMgmtSheetAddTitle;
  String get empMgmtSheetUpdateTitle;
  String get empMgmtSheetAddSubtitle;
  String get empMgmtSheetUpdateSubtitle;
  String get empMgmtFieldRole;
  String get empMgmtFieldFullName;
  String get empMgmtFieldMobile;
  String get empMgmtFieldEmail;
  String get empMgmtFieldPassword;
  String get empMgmtFieldPasswordOptional;
  String get empMgmtFieldBranch;
  String get empMgmtFieldDepartment;
  String get empMgmtFieldAddress;
  String get empMgmtFieldOpeningBalance;
  String get empMgmtFieldBaseSalary;
  String get empMgmtFieldCommission;
  String get empMgmtFieldActiveStatus;
  String get empMgmtSectionTechSpecifics;
  String get empMgmtSectionSalary;
  String get empMgmtSectionAvailability;
  String get empMgmtToggleWorkshop;
  String get empMgmtToggleOnCall;
  String get empMgmtNoAddressFound;
  String get empMgmtSaveButton;
  String get empMgmtUpdateButton;
  String get empMgmtRoleTechnician;
  String get empMgmtRoleCashier;
  String get empMgmtRoleSupplier;
  String get empMgmtValidationRequired;
  String get empMgmtValidationTechType;
  String get empMgmtValidationNoBranch;
  String get empMgmtValidationNoBranchCashier;
  String get empMgmtValidationNoDepartment;
  String get empMgmtValidationSupplierRequired;
  String get empMgmtApiNotIntegrated;
  String get empMgmtTechnicianCreateSuccess;
  String get empMgmtTechnicianUpdateSuccess;
  String get empMgmtTechnicianCreateError;
  String get empMgmtCashierCreateSuccess;
  String get empMgmtCashierUpdateSuccess;
  String get empMgmtCashierCreateError;
  String get empMgmtSupplierCreateSuccess;
  String get empMgmtSupplierCreateError;
  String get empMgmtDeleteSuccess;
  String get empMgmtDeleteError;
  String get empStatusAvailable;
  String get empStatusOnline;
  String get empStatusBusy;
  String get empStatusOffline;
  String get empLastSeenNever;
  String get empLastSeenJustNow;
  String empLastSeenMinutes(int m);
  String empLastSeenHours(int h);
  String empLastSeenDays(int d);
  String get empTechTypeWorkshop;
  String get empTechTypeBoth;
  String get empTechTypeOnCall;
  String get empRoleTechnician;
  String get empRoleCashier;
  String get empRoleSupplier;
  String get invTitle;
  String get invTabProducts;
  String get invTabServices;
  String get invTabCategory;
  String get invAddProduct;
  String get invAddService;
  String get invAddCategory;
  String get invAdd;
  String get invSearchProductsHint;
  String get invSearchServicesHint;
  String get invSearchCategoriesHint;
  String get invNoProductsFound;
  String get invNoServicesFound;
  String get invNoCategoriesFound;
  String get invNoProductsMatchSearch;
  String get invNoServicesMatchSearch;
  String get invNoCategoriesMatchSearch;
  String get invMetricStock;
  String get invMetricPurchase;
  String get invMetricRetail;
  String get invMetricPrice;
  String get invMetricCorpRange;
  String get invMetricCorporate;
  String get invEditTooltip;
  String get invDeleteTooltip;
  String get invMenuEdit;
  String get invMenuDelete;
  String get invConfirmDeleteTitle;
  String invConfirmDeleteBody(String name);
  String get invCancel;
  String get invConfirm;
  String get invCategoryTabProducts;
  String get invCategoryTabServices;
  String get invCreateProduct;
  String get invUpdateProduct;
  String get invCreateProductSubtitle;
  String get invUpdateProductSubtitle;
  String get invFieldBranch;
  String get invFieldDepartment;
  String get invFieldCategory;
  String get invFieldProductName;
  String get invFieldStockQty;
  String get invFieldUnit;
  String get invFieldCriticalStock;
  String get invSectionPricing;
  String get invFieldPurchasePrice;
  String get invFieldSalePrice;
  String get invFieldMinCorpPrice;
  String get invFieldMaxCorpPrice;
  String get invToggleDecimal;
  String get invToggleActive;
  String get invSaveProduct;
  String get invProductCreateSuccess;
  String get invProductUpdateSuccess;
  String get invProductCreateError;
  String get invProductDeleteSuccess;
  String get invProductDeleteError;
  String get invValidationFillRequired;
  String get invValidationSelectDepartment;
  String get invValidationCreateCategory;
  String get invValidationSelectBranch;
  String get invCreateService;
  String get invUpdateService;
  String get invCreateServiceSubtitle;
  String get invUpdateServiceSubtitle;
  String get invFieldServiceName;
  String get invFieldServicePrice;
  String get invTogglePriceEditable;
  String get invSaveService;
  String get invServiceCreateSuccess;
  String get invServiceUpdateSuccess;
  String get invServiceCreateError;
  String get invServiceDeleteSuccess;
  String get invServiceDeleteError;
  String get invValidationFillServiceRequired;
  String get invCreateCategory;
  String get invUpdateCategory;
  String get invCreateCategorySubtitle;
  String get invUpdateCategorySubtitle;
  String get invFieldCategoryName;
  String get invSaveCategory;
  String get invCategoryCreateSuccess;
  String get invCategoryUpdateSuccess;
  String get invCategoryCreateError;
  String get invCategoryDeleteSuccess;
  String get invCategoryDeleteError;
  String get invCreateSubCategory;
  String get invCreateSubCategorySubtitle;
  String get invFieldSubCategoryName;
  String get invSaveSubCategory;
  String get invSubCategoryCreateSuccess;
  String get invSubCategoryUpdateSuccess;
  String get invSubCategoryCreateError;
  String get invSubCategoryDeleteSuccess;
  String get invSubCategoryDeleteError;
  String get notifTitle;
  String get notifMarkRead;
  String get notifEmpty;
  String notifTimeMinutes(int m);
  String notifTimeHours(int h);
  String notifTimeDays(int d);
  String get posMonitoringTitle;
  String get posMonitoringLiveCounters;
  String get posMonitoringClosingReports;
  String get posMonitoringSummaryLiveCounters;
  String get posMonitoringSummaryOpenOrders;
  String get posMonitoringSummaryTodaySales;
  String get posMonitoringNoLiveCounters;
  String get posMonitoringNoClosingReports;
  String get posMonitoringStatusOpen;
  String get posMonitoringStatusClosing;
  String get posMonitoringStatusClosed;
  String get posMonitoringStatShiftSales;
  String get posMonitoringStatOpenOrders;
  String get posMonitoringStatElapsed;
  String posMonitoringElapsedFormat(int h, int m);
  String get posMonitoringClosed;
  String get posMonitoringTableCategory;
  String get posMonitoringTableSystem;
  String get posMonitoringTablePhysical;
  String get posMonitoringTableDiff;
  String get posMonitoringTableTotalSales;
  String get posMonitoringRowCash;
  String get posMonitoringRowBank;
  String get posMonitoringRowCorporate;
  String get posMonitoringRowTamara;
  String get posMonitoringRowTabby;
  String get posMonitoringDiffShort;
  String get posMonitoringDiffExcess;
  String get posMonitoringDiffBalanced;
  String posMonitoringDiffShortSymbol(String amount);
  String posMonitoringDiffExcessSymbol(String amount);
  String get posMonitoringDiffNone;
  String get posMonitoringBackendWarning;
  String posMonitoringAmountSar(String amount);
  String get promoTitle;
  String get promoNewButton;
  String get promoNoCodesFound;
  String get promoMenuEdit;
  String get promoMenuDelete;
  String promoDiscountOff(String value, String unit);
  String get promoUnitPercent;
  String get promoUnitSar;
  String get promoStatUsage;
  String get promoStatMinOrder;
  String get promoStatValidTill;
  String promoMinOrderAmount(String amount);
  String get promoDeleteConfirmTitle;
  String promoDeleteConfirmBody(String code);
  String get promoDeleteCancel;
  String get promoDeleteConfirm;
  String get promoSheetCreateTitle;
  String get promoSheetUpdateTitle;
  String get promoSheetCreateSubtitle;
  String get promoSheetUpdateSubtitle;
  String get promoFieldCode;
  String get promoFieldDiscountValue;
  String get promoFieldUsageLimit;
  String get promoFieldMinOrder;
  String get promoFieldDescription;
  String get promoFieldValidFrom;
  String get promoFieldValidTo;
  String get promoTypeFixed;
  String get promoTypePercent;
  String get promoSubmitCreate;
  String get promoSubmitUpdate;
  String get promoValidationRequired;
  String get promoCreateSuccess;
  String get promoUpdateSuccess;
  String get promoDeleteSuccess;
  String get promoCreateError;
  String get promoDeleteError;
  String get posAddCustomerTitle;
  String get posAddCustomerTabNormal;
  String get posAddCustomerTabCorporate;
  String get posAddCustomerSectionVehicleInfo;
  String get posAddCustomerSectionCompanyDetails;
  String get posAddCustomerSectionCorporateAccount;
  String get posAddCustomerFieldVehicleNumber;
  String get posAddCustomerFieldVin;
  String get posAddCustomerFieldMake;
  String get posAddCustomerFieldModel;
  String get posAddCustomerFieldOdometer;
  String get posAddCustomerFieldCompanyName;
  String get posAddCustomerFieldVatNumber;
  String get posAddCustomerFieldBillingAddress;
  String get posAddCustomerSelectCorporate;
  String get posAddCustomerNoCorporateFound;
  String get posAddCustomerSaveButton;
  String get posAddCustomerFieldNA;
  String get posAddCustomerValidationVehicleRequired;
  String get posAddCustomerValidationRequired;
  String get posAddCustomerValidationVinMax;
  String get posAddCustomerValidationInvalidNumber;
  String get posAddCustomerValidationInvalidNumberShort;

  // ── Reports & Analytics ──────────────────────────────────────────────────
  String get reportsTitle;
  String get reportsFinancialOverview;
  String get reportsOperationalPerformance;
  String get reportsInventoryValuation;
  String get reportsTotalRevenue;
  String get reportsNoDataThisWeek;
  String reportsTotalJobs(int count);
  String get reportsCommissionLabel;
  String get reportsStockValueCost;
  String get reportsPotentialProfit;
  String get reportsActiveSkus;
  String reportsItemsUnit(int count);
  String reportsAmountSar(String amount);
  String get reportsNoOperationalData;
  String reportsRevChangePositive(String pct);
  String reportsRevChangeNegative(String pct);

  // ── Owner shared widgets / petty cash ────────────────────────────────────
  String get ownerCommonSearchHint;
  String get ownerBottomHome;
  String get ownerBottomReports;
  String get ownerBottomBilling;
  String get ownerBottomProfile;
  String get ownerDashboardRoleLabel;
  String get ownerMonthlySales;
  String get ownerCurrencySar;
  String ownerCurrencyAmount(String currency, String amount);
  String get pettyCashQueueCashierExpense;
  String get pettyCashQueueFundRequest;
  String get pettyCashRequestLabel;
  String get pettyCashApprove;
  String get pettyCashReject;
  String get pettyCashConfirmReject;
  String get pettyCashRejectRequestTitle;
  String get pettyCashRejectRequestBody;
  String get pettyCashRejectReasonHint;
  String get pettyCashRejectReasonRequired;
  String get pettyCashRequestApprovedSuccess;
  String get pettyCashRequestApproveFailed;
  String get pettyCashRequestRejectedSuccess;
  String get pettyCashRequestRejectFailed;
  String get pettyCashStatusPending;
  String get pettyCashStatusApproved;
  String get pettyCashStatusRejected;
  String pettyCashStatusFallback(String status);
}


class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
