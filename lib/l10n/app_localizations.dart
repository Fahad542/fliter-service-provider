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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('ar'),
  ];

  /// No description provided for @ownerShellHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get ownerShellHome;

  /// No description provided for @ownerShellBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get ownerShellBranches;

  /// No description provided for @ownerShellDepartments.
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get ownerShellDepartments;

  /// No description provided for @ownerShellEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get ownerShellEmployees;

  /// No description provided for @ownerShellCorporate.
  ///
  /// In en, this message translates to:
  /// **'Corporate'**
  String get ownerShellCorporate;

  /// No description provided for @ownerShellInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get ownerShellInventory;

  /// No description provided for @ownerShellPosMonitoring.
  ///
  /// In en, this message translates to:
  /// **'POS Monitoring'**
  String get ownerShellPosMonitoring;

  /// No description provided for @ownerShellSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get ownerShellSuppliers;

  /// No description provided for @ownerShellAccounting.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get ownerShellAccounting;

  /// No description provided for @ownerShellPromoCodes.
  ///
  /// In en, this message translates to:
  /// **'Promo Codes'**
  String get ownerShellPromoCodes;

  /// No description provided for @ownerShellApprovals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get ownerShellApprovals;

  /// No description provided for @ownerShellNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get ownerShellNotifications;

  /// No description provided for @ownerShellLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get ownerShellLogout;

  /// No description provided for @ownerShellRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Workshop Owner'**
  String get ownerShellRoleLabel;

  /// No description provided for @ownerShellVersion.
  ///
  /// In en, this message translates to:
  /// **'v1.0.0 • Workshop OS'**
  String get ownerShellVersion;

  /// No description provided for @ownerShellLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get ownerShellLogoutTitle;

  /// No description provided for @ownerShellLogoutBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from your account?'**
  String get ownerShellLogoutBody;

  /// No description provided for @ownerShellLogoutCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get ownerShellLogoutCancel;

  /// No description provided for @ownerShellLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get ownerShellLogoutConfirm;

  /// No description provided for @lockerDefaultUser.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get lockerDefaultUser;

  /// No description provided for @billingDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Billing Dashboard'**
  String get billingDashboardTitle;

  /// No description provided for @billingGenerateTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate Bills'**
  String get billingGenerateTitle;

  /// No description provided for @billingMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Bills'**
  String get billingMonthlyTitle;

  /// No description provided for @billingOverdueTitle.
  ///
  /// In en, this message translates to:
  /// **'Overdue Payments'**
  String get billingOverdueTitle;

  /// No description provided for @billingDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get billingDefaultTitle;

  /// No description provided for @billingSummaryTotalBilled.
  ///
  /// In en, this message translates to:
  /// **'Total Billed'**
  String get billingSummaryTotalBilled;

  /// No description provided for @billingSummaryTotalReceived.
  ///
  /// In en, this message translates to:
  /// **'Total Received'**
  String get billingSummaryTotalReceived;

  /// No description provided for @billingSummaryOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get billingSummaryOutstanding;

  /// No description provided for @billingSummaryOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get billingSummaryOverdue;

  /// No description provided for @billingQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get billingQuickActions;

  /// No description provided for @billingRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Billing Activity'**
  String get billingRecentActivity;

  /// No description provided for @billingSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get billingSeeAll;

  /// No description provided for @billingNoRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get billingNoRecentActivity;

  /// No description provided for @billingActionGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate Bills'**
  String get billingActionGenerate;

  /// No description provided for @billingActionViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All Bills'**
  String get billingActionViewAll;

  /// No description provided for @billingActionRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get billingActionRecordPayment;

  /// No description provided for @billingActionSendReminders.
  ///
  /// In en, this message translates to:
  /// **'Send Reminders'**
  String get billingActionSendReminders;

  /// No description provided for @billingGeneratorStep1.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Select Billing Period'**
  String get billingGeneratorStep1;

  /// No description provided for @billingGeneratorStep2.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Preview Eligible Invoices'**
  String get billingGeneratorStep2;

  /// No description provided for @billingGeneratorPendingInvoices.
  ///
  /// In en, this message translates to:
  /// **'Pending Invoices: 15 • Est. Total: SAR 12,450'**
  String get billingGeneratorPendingInvoices;

  /// No description provided for @billingGeneratorPostAll.
  ///
  /// In en, this message translates to:
  /// **'Generate & Post All'**
  String get billingGeneratorPostAll;

  /// No description provided for @billingPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Billing Period: {month}/{year}'**
  String billingPeriodLabel(String month, String year);

  /// No description provided for @billingStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get billingStatusPaid;

  /// No description provided for @billingStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get billingStatusOverdue;

  /// No description provided for @billingStatusPartiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get billingStatusPartiallyPaid;

  /// No description provided for @billingStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get billingStatusPending;

  /// No description provided for @branchManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get branchManagementTitle;

  /// No description provided for @branchSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search branches…'**
  String get branchSearchHint;

  /// No description provided for @branchAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Branch'**
  String get branchAddButton;

  /// No description provided for @branchEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get branchEditButton;

  /// No description provided for @branchDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get branchDeleteButton;

  /// No description provided for @branchNoBranches.
  ///
  /// In en, this message translates to:
  /// **'No branches found'**
  String get branchNoBranches;

  /// No description provided for @branchStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get branchStatusActive;

  /// No description provided for @branchStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get branchStatusInactive;

  /// No description provided for @branchFormTitleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Branch'**
  String get branchFormTitleAdd;

  /// No description provided for @branchFormTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Branch'**
  String get branchFormTitleEdit;

  /// No description provided for @branchFormNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get branchFormNameLabel;

  /// No description provided for @branchFormNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter branch name'**
  String get branchFormNameHint;

  /// No description provided for @branchFormAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get branchFormAddressLabel;

  /// No description provided for @branchFormAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Search address…'**
  String get branchFormAddressHint;

  /// No description provided for @branchFormLatLabel.
  ///
  /// In en, this message translates to:
  /// **'GPS Latitude'**
  String get branchFormLatLabel;

  /// No description provided for @branchFormLngLabel.
  ///
  /// In en, this message translates to:
  /// **'GPS Longitude'**
  String get branchFormLngLabel;

  /// No description provided for @branchFormStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get branchFormStatusLabel;

  /// No description provided for @branchFormSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Branch'**
  String get branchFormSaveButton;

  /// No description provided for @branchFormUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Branch'**
  String get branchFormUpdateButton;

  /// No description provided for @branchFormValidationError.
  ///
  /// In en, this message translates to:
  /// **'Branch Name and Address are required'**
  String get branchFormValidationError;

  /// No description provided for @branchCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Branch Created Successfully'**
  String get branchCreateSuccess;

  /// No description provided for @branchUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Branch Updated Successfully'**
  String get branchUpdateSuccess;

  /// No description provided for @branchDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Branch Deleted Successfully'**
  String get branchDeleteSuccess;

  /// No description provided for @branchSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save branch'**
  String get branchSaveError;

  /// No description provided for @branchDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete branch'**
  String get branchDeleteError;

  /// No description provided for @branchDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Branch'**
  String get branchDeleteConfirmTitle;

  /// No description provided for @branchDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this branch?'**
  String get branchDeleteConfirmBody;

  /// No description provided for @branchDeleteConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get branchDeleteConfirmCancel;

  /// No description provided for @branchDeleteConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get branchDeleteConfirmDelete;

  /// No description provided for @lockerPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Locker Portal'**
  String get lockerPortalTitle;

  /// No description provided for @lockerPortalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Secure asset management for your branch'**
  String get lockerPortalSubtitle;

  /// No description provided for @lockerPortalAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'LOCKER PORTAL'**
  String get lockerPortalAppBarTitle;

  /// No description provided for @lockerSecureAssetManagement.
  ///
  /// In en, this message translates to:
  /// **'SECURE ASSET MANAGEMENT'**
  String get lockerSecureAssetManagement;

  /// No description provided for @lockerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get lockerEmail;

  /// No description provided for @lockerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get lockerEmailHint;

  /// No description provided for @lockerEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get lockerEmailRequired;

  /// No description provided for @lockerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get lockerPassword;

  /// No description provided for @lockerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get lockerPasswordHint;

  /// No description provided for @lockerPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get lockerPasswordRequired;

  /// No description provided for @lockerForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get lockerForgotPassword;

  /// No description provided for @lockerContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get lockerContinue;

  /// No description provided for @lockerLoadingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Loading dashboard…'**
  String get lockerLoadingDashboard;

  /// No description provided for @lockerFailedLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard'**
  String get lockerFailedLoadDashboard;

  /// No description provided for @lockerUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get lockerUnexpectedError;

  /// No description provided for @lockerRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get lockerRetry;

  /// No description provided for @lockerRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get lockerRefresh;

  /// No description provided for @lockerSupervisorTab.
  ///
  /// In en, this message translates to:
  /// **'SUPERVISOR'**
  String get lockerSupervisorTab;

  /// No description provided for @lockerCollectorTab.
  ///
  /// In en, this message translates to:
  /// **'COLLECTOR'**
  String get lockerCollectorTab;

  /// No description provided for @lockerLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get lockerLogOut;

  /// No description provided for @lockerLogOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of the Locker Portal?'**
  String get lockerLogOutConfirm;

  /// No description provided for @lockerCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get lockerCancel;

  /// No description provided for @lockerLogOutButton.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get lockerLogOutButton;

  /// No description provided for @lockerWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK'**
  String get lockerWelcomeBack;

  /// No description provided for @lockerRoleSupervisor.
  ///
  /// In en, this message translates to:
  /// **'SUPERVISOR'**
  String get lockerRoleSupervisor;

  /// No description provided for @lockerRoleManager.
  ///
  /// In en, this message translates to:
  /// **'MANAGER'**
  String get lockerRoleManager;

  /// No description provided for @lockerRoleWorkshopOwner.
  ///
  /// In en, this message translates to:
  /// **'WORKSHOP OWNER'**
  String get lockerRoleWorkshopOwner;

  /// No description provided for @lockerRoleWorkshopSupervisor.
  ///
  /// In en, this message translates to:
  /// **'WORKSHOP SUPERVISOR'**
  String get lockerRoleWorkshopSupervisor;

  /// No description provided for @lockerRoleCollector.
  ///
  /// In en, this message translates to:
  /// **'COLLECTOR'**
  String get lockerRoleCollector;

  /// No description provided for @lockerRoleCollectionOfficer.
  ///
  /// In en, this message translates to:
  /// **'COLLECTION OFFICER'**
  String get lockerRoleCollectionOfficer;

  /// No description provided for @lockerRoleWorkshopCollector.
  ///
  /// In en, this message translates to:
  /// **'WORKSHOP COLLECTOR'**
  String get lockerRoleWorkshopCollector;

  /// No description provided for @lockerSupervisorOverview.
  ///
  /// In en, this message translates to:
  /// **'SUPERVISOR OVERVIEW'**
  String get lockerSupervisorOverview;

  /// No description provided for @lockerMyPerformance.
  ///
  /// In en, this message translates to:
  /// **'MY PERFORMANCE'**
  String get lockerMyPerformance;

  /// No description provided for @lockerKpiPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get lockerKpiPending;

  /// No description provided for @lockerKpiAwaiting.
  ///
  /// In en, this message translates to:
  /// **'AWAITING'**
  String get lockerKpiAwaiting;

  /// No description provided for @lockerKpiOverdue.
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get lockerKpiOverdue;

  /// No description provided for @lockerKpiVariance.
  ///
  /// In en, this message translates to:
  /// **'VARIANCE'**
  String get lockerKpiVariance;

  /// No description provided for @lockerKpiOpenAssignments.
  ///
  /// In en, this message translates to:
  /// **'OPEN ASSIGNMENTS'**
  String get lockerKpiOpenAssignments;

  /// No description provided for @lockerKpiPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'PENDING APPROVAL'**
  String get lockerKpiPendingApproval;

  /// No description provided for @lockerKpiTodaysCollections.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S COLLECTIONS'**
  String get lockerKpiTodaysCollections;

  /// No description provided for @lockerKpiMonthlyCollected.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY COLLECTED'**
  String get lockerKpiMonthlyCollected;

  /// No description provided for @lockerCoreOperations.
  ///
  /// In en, this message translates to:
  /// **'CORE OPERATIONS'**
  String get lockerCoreOperations;

  /// No description provided for @lockerManageAllRequests.
  ///
  /// In en, this message translates to:
  /// **'Manage All Requests'**
  String get lockerManageAllRequests;

  /// No description provided for @lockerStartCollection.
  ///
  /// In en, this message translates to:
  /// **'Start Collection'**
  String get lockerStartCollection;

  /// No description provided for @lockerAssignOfficers.
  ///
  /// In en, this message translates to:
  /// **'Assign Officers'**
  String get lockerAssignOfficers;

  /// No description provided for @lockerManageVarianceRequests.
  ///
  /// In en, this message translates to:
  /// **'Manage Variance Requests'**
  String get lockerManageVarianceRequests;

  /// No description provided for @lockerFinancialAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Financial Analytics'**
  String get lockerFinancialAnalytics;

  /// No description provided for @lockerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search requests…'**
  String get lockerSearchHint;

  /// No description provided for @lockerLoadingRequests.
  ///
  /// In en, this message translates to:
  /// **'Loading requests…'**
  String get lockerLoadingRequests;

  /// No description provided for @lockerFailedLoadRequests.
  ///
  /// In en, this message translates to:
  /// **'Failed to load requests'**
  String get lockerFailedLoadRequests;

  /// No description provided for @lockerNoRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get lockerNoRequestsFound;

  /// No description provided for @lockerAdjustFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters.'**
  String get lockerAdjustFilters;

  /// No description provided for @lockerLockedCashAsset.
  ///
  /// In en, this message translates to:
  /// **'LOCKED CASH ASSET'**
  String get lockerLockedCashAsset;

  /// No description provided for @lockerTapToCollect.
  ///
  /// In en, this message translates to:
  /// **'TAP TO COLLECT'**
  String get lockerTapToCollect;

  /// No description provided for @lockerStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get lockerStatusPending;

  /// No description provided for @lockerStatusAssigned.
  ///
  /// In en, this message translates to:
  /// **'ASSIGNED'**
  String get lockerStatusAssigned;

  /// No description provided for @lockerStatusAwaiting.
  ///
  /// In en, this message translates to:
  /// **'AWAITING'**
  String get lockerStatusAwaiting;

  /// No description provided for @lockerStatusCollected.
  ///
  /// In en, this message translates to:
  /// **'COLLECTED'**
  String get lockerStatusCollected;

  /// No description provided for @lockerStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'APPROVED'**
  String get lockerStatusApproved;

  /// No description provided for @lockerStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get lockerStatusRejected;

  /// No description provided for @lockerStatusMatched.
  ///
  /// In en, this message translates to:
  /// **'MATCHED'**
  String get lockerStatusMatched;

  /// No description provided for @lockerLoadingRequest.
  ///
  /// In en, this message translates to:
  /// **'Loading request…'**
  String get lockerLoadingRequest;

  /// No description provided for @lockerFailedLoadDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load request details'**
  String get lockerFailedLoadDetails;

  /// No description provided for @lockerSystemStatus.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM STATUS'**
  String get lockerSystemStatus;

  /// No description provided for @lockerTotalSecuredAsset.
  ///
  /// In en, this message translates to:
  /// **'TOTAL SECURED ASSET'**
  String get lockerTotalSecuredAsset;

  /// No description provided for @lockerCounterClosing.
  ///
  /// In en, this message translates to:
  /// **'COUNTER CLOSING'**
  String get lockerCounterClosing;

  /// No description provided for @lockerPhysicalCash.
  ///
  /// In en, this message translates to:
  /// **'PHYSICAL CASH'**
  String get lockerPhysicalCash;

  /// No description provided for @lockerSystemTotal.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM TOTAL'**
  String get lockerSystemTotal;

  /// No description provided for @lockerDifference.
  ///
  /// In en, this message translates to:
  /// **'DIFFERENCE'**
  String get lockerDifference;

  /// No description provided for @lockerCollectionRecord.
  ///
  /// In en, this message translates to:
  /// **'COLLECTION RECORD'**
  String get lockerCollectionRecord;

  /// No description provided for @lockerReceived.
  ///
  /// In en, this message translates to:
  /// **'RECEIVED'**
  String get lockerReceived;

  /// No description provided for @lockerInternalData.
  ///
  /// In en, this message translates to:
  /// **'INTERNAL DATA'**
  String get lockerInternalData;

  /// No description provided for @lockerSourceBranch.
  ///
  /// In en, this message translates to:
  /// **'SOURCE BRANCH'**
  String get lockerSourceBranch;

  /// No description provided for @lockerCashier.
  ///
  /// In en, this message translates to:
  /// **'CASHIER'**
  String get lockerCashier;

  /// No description provided for @lockerCashierIdentity.
  ///
  /// In en, this message translates to:
  /// **'CASHIER'**
  String get lockerCashierIdentity;

  /// No description provided for @lockerShiftCloseTime.
  ///
  /// In en, this message translates to:
  /// **'SHIFT CLOSE TIME'**
  String get lockerShiftCloseTime;

  /// No description provided for @lockerSessionOpened.
  ///
  /// In en, this message translates to:
  /// **'SESSION OPENED'**
  String get lockerSessionOpened;

  /// No description provided for @lockerSessionClosed.
  ///
  /// In en, this message translates to:
  /// **'SESSION CLOSED'**
  String get lockerSessionClosed;

  /// No description provided for @lockerAssignedOfficer.
  ///
  /// In en, this message translates to:
  /// **'ASSIGNED OFFICER'**
  String get lockerAssignedOfficer;

  /// No description provided for @lockerAssignCollectionOfficer.
  ///
  /// In en, this message translates to:
  /// **'Assign Collection Officer'**
  String get lockerAssignCollectionOfficer;

  /// No description provided for @lockerProceedToCollection.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Collection'**
  String get lockerProceedToCollection;

  /// No description provided for @lockerGenerateAuditPdf.
  ///
  /// In en, this message translates to:
  /// **'Generate Audit PDF'**
  String get lockerGenerateAuditPdf;

  /// No description provided for @lockerCollectionPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Collection is pending supervisor approval.'**
  String get lockerCollectionPendingApproval;

  /// No description provided for @lockerPendingSupervisorApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending supervisor approval'**
  String get lockerPendingSupervisorApproval;

  /// No description provided for @lockerCollectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Collection recorded successfully'**
  String get lockerCollectedSuccessfully;

  /// No description provided for @lockerVarianceApproved.
  ///
  /// In en, this message translates to:
  /// **'Variance approved'**
  String get lockerVarianceApproved;

  /// No description provided for @lockerVarianceRejectedBanner.
  ///
  /// In en, this message translates to:
  /// **'Variance rejected'**
  String get lockerVarianceRejectedBanner;

  /// No description provided for @lockerVarianceDifferenceReview.
  ///
  /// In en, this message translates to:
  /// **'There is a variance in this collection. Please review and approve or reject.'**
  String get lockerVarianceDifferenceReview;

  /// No description provided for @lockerApproveVariance.
  ///
  /// In en, this message translates to:
  /// **'Variance approved successfully'**
  String get lockerApproveVariance;

  /// No description provided for @lockerApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get lockerApprove;

  /// No description provided for @lockerReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get lockerReject;

  /// No description provided for @lockerRejectVarianceTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Variance'**
  String get lockerRejectVarianceTitle;

  /// No description provided for @lockerRejectVarianceBody.
  ///
  /// In en, this message translates to:
  /// **'Provide an optional reason for rejecting this variance.'**
  String get lockerRejectVarianceBody;

  /// No description provided for @lockerRejectionReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter rejection reason (optional)'**
  String get lockerRejectionReasonHint;

  /// No description provided for @lockerConfirmReject.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reject'**
  String get lockerConfirmReject;

  /// No description provided for @corporateFieldMobileMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get corporateFieldMobileMobile;

  /// No description provided for @corporateFieldTaxId.
  ///
  /// In en, this message translates to:
  /// **'Tax ID (VAT)'**
  String get corporateFieldTaxId;

  /// No description provided for @corporateFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get corporateFieldStatus;

  /// No description provided for @corporateSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get corporateSaveChanges;

  /// No description provided for @corporateStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get corporateStatusPending;

  /// No description provided for @corporateStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get corporateStatusActive;

  /// No description provided for @corporateStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get corporateStatusRejected;

  /// No description provided for @corporateCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Corporate Account Created Successfully'**
  String get corporateCreateSuccess;

  /// No description provided for @corporateCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create corporate account'**
  String get corporateCreateError;

  /// No description provided for @corporateUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Corporate Account Updated Successfully'**
  String get corporateUpdateSuccess;

  /// No description provided for @corporateUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update corporate account'**
  String get corporateUpdateError;

  /// No description provided for @corporateUserCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Corporate User Created Successfully'**
  String get corporateUserCreateSuccess;

  /// No description provided for @corporateUserCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create corporate user'**
  String get corporateUserCreateError;

  /// No description provided for @corporateValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get corporateValidationRequired;

  /// No description provided for @corporateValidationBranch.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one branch'**
  String get corporateValidationBranch;

  /// No description provided for @corporateValidationCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company name is required'**
  String get corporateValidationCompanyName;

  /// No description provided for @dashboardAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All Branches'**
  String get dashboardAllBranches;

  /// No description provided for @dashboardViewingDataFor.
  ///
  /// In en, this message translates to:
  /// **'Viewing Data For'**
  String get dashboardViewingDataFor;

  /// No description provided for @dashboardAllBranchesAggregated.
  ///
  /// In en, this message translates to:
  /// **'All Branches Aggregated'**
  String get dashboardAllBranchesAggregated;

  /// No description provided for @dashboardSelectBranch.
  ///
  /// In en, this message translates to:
  /// **'Select Branch'**
  String get dashboardSelectBranch;

  /// No description provided for @dashboardKpiTotalSalesToday.
  ///
  /// In en, this message translates to:
  /// **'Total Sales Today'**
  String get dashboardKpiTotalSalesToday;

  /// No description provided for @dashboardKpiThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get dashboardKpiThisMonth;

  /// No description provided for @dashboardKpiPendingInvoices.
  ///
  /// In en, this message translates to:
  /// **'Pending Invoices'**
  String get dashboardKpiPendingInvoices;

  /// No description provided for @dashboardKpiLowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alerts'**
  String get dashboardKpiLowStockAlerts;

  /// No description provided for @dashboardKpiTodaysSales.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sales'**
  String get dashboardKpiTodaysSales;

  /// No description provided for @dashboardKpiActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get dashboardKpiActiveOrders;

  /// No description provided for @dashboardKpiTechWorkload.
  ///
  /// In en, this message translates to:
  /// **'Tech Workload'**
  String get dashboardKpiTechWorkload;

  /// No description provided for @dashboardKpiPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get dashboardKpiPendingApproval;

  /// No description provided for @dashboardPendingApprovalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get dashboardPendingApprovalsTitle;

  /// No description provided for @dashboardViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get dashboardViewAll;

  /// No description provided for @dashboardNoPendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'No pending petty-cash approvals right now.'**
  String get dashboardNoPendingApprovals;

  /// No description provided for @dashboardMoreApprovals.
  ///
  /// In en, this message translates to:
  /// **'+{count} more in Approvals'**
  String dashboardMoreApprovals(int count);

  /// No description provided for @dashboardBranchPerformance.
  ///
  /// In en, this message translates to:
  /// **'Branch Performance'**
  String get dashboardBranchPerformance;

  /// No description provided for @dashboardBranchHighlights.
  ///
  /// In en, this message translates to:
  /// **'Branch Highlights'**
  String get dashboardBranchHighlights;

  /// No description provided for @dashboardBranchStatus.
  ///
  /// In en, this message translates to:
  /// **'Branch Status'**
  String get dashboardBranchStatus;

  /// No description provided for @dashboardTotalStaff.
  ///
  /// In en, this message translates to:
  /// **'Total Staff'**
  String get dashboardTotalStaff;

  /// No description provided for @dashboardSalesTarget.
  ///
  /// In en, this message translates to:
  /// **'Sales Target'**
  String get dashboardSalesTarget;

  /// No description provided for @dashboardSalesTargetValue.
  ///
  /// In en, this message translates to:
  /// **'85% Achieved'**
  String get dashboardSalesTargetValue;

  /// No description provided for @branchPerformanceListTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch Performance'**
  String get branchPerformanceListTitle;

  /// No description provided for @branchPerformanceNoBranches.
  ///
  /// In en, this message translates to:
  /// **'No branches yet.'**
  String get branchPerformanceNoBranches;

  /// No description provided for @deptMgmtTitle.
  ///
  /// In en, this message translates to:
  /// **'Department Management'**
  String get deptMgmtTitle;

  /// No description provided for @deptMgmtSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by Department Name...'**
  String get deptMgmtSearchHint;

  /// No description provided for @deptMgmtAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add New Department'**
  String get deptMgmtAddButton;

  /// No description provided for @deptMgmtNoDepartments.
  ///
  /// In en, this message translates to:
  /// **'No departments found.'**
  String get deptMgmtNoDepartments;

  /// No description provided for @deptMgmtLabelDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get deptMgmtLabelDepartment;

  /// No description provided for @deptMgmtMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get deptMgmtMenuEdit;

  /// No description provided for @deptMgmtMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deptMgmtMenuDelete;

  /// No description provided for @deptMgmtConfirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get deptMgmtConfirmDeleteTitle;

  /// No description provided for @deptMgmtConfirmDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deptMgmtConfirmDeleteBody(String name);

  /// No description provided for @deptMgmtCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deptMgmtCancel;

  /// No description provided for @deptMgmtDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deptMgmtDelete;

  /// No description provided for @deptMgmtStatusActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get deptMgmtStatusActive;

  /// No description provided for @deptMgmtStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get deptMgmtStatusInactive;

  /// No description provided for @deptMgmtSheetAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Department'**
  String get deptMgmtSheetAddTitle;

  /// No description provided for @deptMgmtSheetUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Department'**
  String get deptMgmtSheetUpdateTitle;

  /// No description provided for @deptMgmtSheetAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the name of the new department.'**
  String get deptMgmtSheetAddSubtitle;

  /// No description provided for @deptMgmtSheetUpdateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Modify existing department details.'**
  String get deptMgmtSheetUpdateSubtitle;

  /// No description provided for @deptMgmtFieldName.
  ///
  /// In en, this message translates to:
  /// **'Department Name'**
  String get deptMgmtFieldName;

  /// No description provided for @deptMgmtFieldActiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Active Status'**
  String get deptMgmtFieldActiveStatus;

  /// No description provided for @deptMgmtSheetAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Department'**
  String get deptMgmtSheetAddButton;

  /// No description provided for @deptMgmtSheetUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Department'**
  String get deptMgmtSheetUpdateButton;

  /// No description provided for @deptMgmtValidationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Department Name is required'**
  String get deptMgmtValidationNameRequired;

  /// No description provided for @deptMgmtCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Department Created Successfully'**
  String get deptMgmtCreateSuccess;

  /// No description provided for @deptMgmtUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Department Updated Successfully'**
  String get deptMgmtUpdateSuccess;

  /// No description provided for @deptMgmtDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Department Deleted Successfully'**
  String get deptMgmtDeleteSuccess;

  /// No description provided for @deptMgmtSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save department'**
  String get deptMgmtSaveError;

  /// No description provided for @deptMgmtDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete department'**
  String get deptMgmtDeleteError;

  /// No description provided for @empMgmtTitle.
  ///
  /// In en, this message translates to:
  /// **'Employee Management'**
  String get empMgmtTitle;

  /// No description provided for @empMgmtSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by Name, Email or Mobile...'**
  String get empMgmtSearchHint;

  /// No description provided for @empMgmtAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Employee'**
  String get empMgmtAddButton;

  /// No description provided for @empMgmtFilterAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All Branches'**
  String get empMgmtFilterAllBranches;

  /// No description provided for @empMgmtNoEmployees.
  ///
  /// In en, this message translates to:
  /// **'No employees found.'**
  String get empMgmtNoEmployees;

  /// No description provided for @empMgmtLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen: {time}'**
  String empMgmtLastSeen(String time);

  /// No description provided for @empMgmtInfoBranch.
  ///
  /// In en, this message translates to:
  /// **'BRANCH'**
  String get empMgmtInfoBranch;

  /// No description provided for @empMgmtInfoDept.
  ///
  /// In en, this message translates to:
  /// **'DEPT'**
  String get empMgmtInfoDept;

  /// No description provided for @empMgmtInfoRoleType.
  ///
  /// In en, this message translates to:
  /// **'ROLE TYPE'**
  String get empMgmtInfoRoleType;

  /// No description provided for @empMgmtInfoTechType.
  ///
  /// In en, this message translates to:
  /// **'TECH TYPE'**
  String get empMgmtInfoTechType;

  /// No description provided for @empMgmtInfoSalary.
  ///
  /// In en, this message translates to:
  /// **'SALARY'**
  String get empMgmtInfoSalary;

  /// No description provided for @empMgmtInfoCommission.
  ///
  /// In en, this message translates to:
  /// **'COMMISSION'**
  String get empMgmtInfoCommission;

  /// No description provided for @empMgmtInfoUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get empMgmtInfoUnknown;

  /// No description provided for @empMgmtInfoNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get empMgmtInfoNone;

  /// No description provided for @empMgmtMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get empMgmtMenuEdit;

  /// No description provided for @empMgmtMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get empMgmtMenuDelete;

  /// No description provided for @empMgmtDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Employee'**
  String get empMgmtDeleteTitle;

  /// No description provided for @empMgmtDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String empMgmtDeleteBody(String name);

  /// No description provided for @empMgmtDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get empMgmtDeleteCancel;

  /// No description provided for @empMgmtDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get empMgmtDeleteConfirm;

  /// No description provided for @empMgmtSheetAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Employee'**
  String get empMgmtSheetAddTitle;

  /// No description provided for @empMgmtSheetUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Employee'**
  String get empMgmtSheetUpdateTitle;

  /// No description provided for @empMgmtSheetAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide detailed Information to register a new member.'**
  String get empMgmtSheetAddSubtitle;

  /// No description provided for @empMgmtSheetUpdateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Modify existing employee details.'**
  String get empMgmtSheetUpdateSubtitle;

  /// No description provided for @empMgmtFieldRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get empMgmtFieldRole;

  /// No description provided for @empMgmtFieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get empMgmtFieldFullName;

  /// No description provided for @empMgmtFieldMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get empMgmtFieldMobile;

  /// No description provided for @empMgmtFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get empMgmtFieldEmail;

  /// No description provided for @empMgmtFieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get empMgmtFieldPassword;

  /// No description provided for @empMgmtFieldPasswordOptional.
  ///
  /// In en, this message translates to:
  /// **'Password (Optional)'**
  String get empMgmtFieldPasswordOptional;

  /// No description provided for @empMgmtFieldBranch.
  ///
  /// In en, this message translates to:
  /// **'Assign to Branch'**
  String get empMgmtFieldBranch;

  /// No description provided for @empMgmtFieldDepartment.
  ///
  /// In en, this message translates to:
  /// **'Assign Department'**
  String get empMgmtFieldDepartment;

  /// No description provided for @empMgmtFieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get empMgmtFieldAddress;

  /// No description provided for @empMgmtFieldOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance'**
  String get empMgmtFieldOpeningBalance;

  /// No description provided for @empMgmtFieldBaseSalary.
  ///
  /// In en, this message translates to:
  /// **'Base Salary'**
  String get empMgmtFieldBaseSalary;

  /// No description provided for @empMgmtFieldCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission %'**
  String get empMgmtFieldCommission;

  /// No description provided for @empMgmtFieldActiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Active Status'**
  String get empMgmtFieldActiveStatus;

  /// No description provided for @empMgmtSectionTechSpecifics.
  ///
  /// In en, this message translates to:
  /// **'Technician Specifics'**
  String get empMgmtSectionTechSpecifics;

  /// No description provided for @empMgmtSectionSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary & Commission'**
  String get empMgmtSectionSalary;

  /// No description provided for @empMgmtSectionAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get empMgmtSectionAvailability;

  /// No description provided for @empMgmtToggleWorkshop.
  ///
  /// In en, this message translates to:
  /// **'Workshop Technician'**
  String get empMgmtToggleWorkshop;

  /// No description provided for @empMgmtToggleOnCall.
  ///
  /// In en, this message translates to:
  /// **'On-Call Technician'**
  String get empMgmtToggleOnCall;

  /// No description provided for @empMgmtNoAddressFound.
  ///
  /// In en, this message translates to:
  /// **'No addresses found'**
  String get empMgmtNoAddressFound;

  /// No description provided for @empMgmtSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Employee'**
  String get empMgmtSaveButton;

  /// No description provided for @empMgmtUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Employee'**
  String get empMgmtUpdateButton;

  /// No description provided for @empMgmtRoleTechnician.
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get empMgmtRoleTechnician;

  /// No description provided for @empMgmtRoleCashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get empMgmtRoleCashier;

  /// No description provided for @empMgmtRoleSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get empMgmtRoleSupplier;

  /// No description provided for @empMgmtValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required text fields.'**
  String get empMgmtValidationRequired;

  /// No description provided for @empMgmtValidationTechType.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one technician type.'**
  String get empMgmtValidationTechType;

  /// No description provided for @empMgmtValidationNoBranch.
  ///
  /// In en, this message translates to:
  /// **'Please create a branch first to assign this employee.'**
  String get empMgmtValidationNoBranch;

  /// No description provided for @empMgmtValidationNoBranchCashier.
  ///
  /// In en, this message translates to:
  /// **'Please create a branch first to assign this cashier.'**
  String get empMgmtValidationNoBranchCashier;

  /// No description provided for @empMgmtValidationNoDepartment.
  ///
  /// In en, this message translates to:
  /// **'Please create a department first to assign this employee.'**
  String get empMgmtValidationNoDepartment;

  /// No description provided for @empMgmtValidationSupplierRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get empMgmtValidationSupplierRequired;

  /// No description provided for @empMgmtApiNotIntegrated.
  ///
  /// In en, this message translates to:
  /// **'Only Technician, Cashier, and Supplier creation APIs are integrated.'**
  String get empMgmtApiNotIntegrated;

  /// No description provided for @empMgmtTechnicianCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Technician Created Successfully'**
  String get empMgmtTechnicianCreateSuccess;

  /// No description provided for @empMgmtTechnicianUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Technician Updated Successfully'**
  String get empMgmtTechnicianUpdateSuccess;

  /// No description provided for @empMgmtTechnicianCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create technician'**
  String get empMgmtTechnicianCreateError;

  /// No description provided for @empMgmtCashierCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cashier Created Successfully'**
  String get empMgmtCashierCreateSuccess;

  /// No description provided for @empMgmtCashierUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cashier Updated Successfully'**
  String get empMgmtCashierUpdateSuccess;

  /// No description provided for @empMgmtCashierCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create cashier'**
  String get empMgmtCashierCreateError;

  /// No description provided for @empMgmtSupplierCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Supplier Created Successfully'**
  String get empMgmtSupplierCreateSuccess;

  /// No description provided for @empMgmtSupplierCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create supplier'**
  String get empMgmtSupplierCreateError;

  /// No description provided for @empMgmtDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Employee Deleted Successfully'**
  String get empMgmtDeleteSuccess;

  /// No description provided for @empMgmtDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete employee'**
  String get empMgmtDeleteError;

  /// No description provided for @empStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE'**
  String get empStatusAvailable;

  /// No description provided for @empStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get empStatusOnline;

  /// No description provided for @empStatusBusy.
  ///
  /// In en, this message translates to:
  /// **'BUSY'**
  String get empStatusBusy;

  /// No description provided for @empStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get empStatusOffline;

  /// No description provided for @empLastSeenNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get empLastSeenNever;

  /// No description provided for @empLastSeenJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get empLastSeenJustNow;

  /// No description provided for @empLastSeenMinutes.
  ///
  /// In en, this message translates to:
  /// **'{m}m ago'**
  String empLastSeenMinutes(int m);

  /// No description provided for @empLastSeenHours.
  ///
  /// In en, this message translates to:
  /// **'{h}h ago'**
  String empLastSeenHours(int h);

  /// No description provided for @empLastSeenDays.
  ///
  /// In en, this message translates to:
  /// **'{d}d ago'**
  String empLastSeenDays(int d);

  /// No description provided for @empTechTypeWorkshop.
  ///
  /// In en, this message translates to:
  /// **'WORKSHOP'**
  String get empTechTypeWorkshop;

  /// No description provided for @empTechTypeBoth.
  ///
  /// In en, this message translates to:
  /// **'BOTH'**
  String get empTechTypeBoth;

  /// No description provided for @empTechTypeOnCall.
  ///
  /// In en, this message translates to:
  /// **'ON-CALL'**
  String get empTechTypeOnCall;

  /// No description provided for @empRoleTechnician.
  ///
  /// In en, this message translates to:
  /// **'TECHNICIAN'**
  String get empRoleTechnician;

  /// No description provided for @empRoleCashier.
  ///
  /// In en, this message translates to:
  /// **'CASHIER'**
  String get empRoleCashier;

  /// No description provided for @empRoleSupplier.
  ///
  /// In en, this message translates to:
  /// **'SUPPLIER'**
  String get empRoleSupplier;

  /// No description provided for @posAddCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Customer'**
  String get posAddCustomerTitle;

  /// No description provided for @posAddCustomerTabNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal Customer'**
  String get posAddCustomerTabNormal;

  /// No description provided for @posAddCustomerTabCorporate.
  ///
  /// In en, this message translates to:
  /// **'Corporate Customer'**
  String get posAddCustomerTabCorporate;

  /// No description provided for @posAddCustomerSectionVehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get posAddCustomerSectionVehicleInfo;

  /// No description provided for @posAddCustomerSectionCompanyDetails.
  ///
  /// In en, this message translates to:
  /// **'Company Details (Auto-filled)'**
  String get posAddCustomerSectionCompanyDetails;

  /// No description provided for @posAddCustomerSectionCorporateAccount.
  ///
  /// In en, this message translates to:
  /// **'Corporate Account'**
  String get posAddCustomerSectionCorporateAccount;

  /// No description provided for @posAddCustomerFieldVehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number'**
  String get posAddCustomerFieldVehicleNumber;

  /// No description provided for @posAddCustomerFieldVin.
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get posAddCustomerFieldVin;

  /// No description provided for @posAddCustomerFieldMake.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get posAddCustomerFieldMake;

  /// No description provided for @posAddCustomerFieldModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get posAddCustomerFieldModel;

  /// No description provided for @posAddCustomerFieldOdometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get posAddCustomerFieldOdometer;

  /// No description provided for @posAddCustomerFieldCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get posAddCustomerFieldCompanyName;

  /// No description provided for @posAddCustomerFieldVatNumber.
  ///
  /// In en, this message translates to:
  /// **'VAT Number'**
  String get posAddCustomerFieldVatNumber;

  /// No description provided for @posAddCustomerFieldBillingAddress.
  ///
  /// In en, this message translates to:
  /// **'Billing Address'**
  String get posAddCustomerFieldBillingAddress;

  /// No description provided for @posAddCustomerSelectCorporate.
  ///
  /// In en, this message translates to:
  /// **'Select Corporate Account'**
  String get posAddCustomerSelectCorporate;

  /// No description provided for @posAddCustomerNoCorporateFound.
  ///
  /// In en, this message translates to:
  /// **'No Corporate Accounts Found'**
  String get posAddCustomerNoCorporateFound;

  /// No description provided for @posAddCustomerSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save & Proceed to Department'**
  String get posAddCustomerSaveButton;

  /// No description provided for @posAddCustomerFieldNA.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get posAddCustomerFieldNA;

  /// No description provided for @posAddCustomerValidationVehicleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter vehicle number'**
  String get posAddCustomerValidationVehicleRequired;

  /// No description provided for @posAddCustomerValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get posAddCustomerValidationRequired;

  /// No description provided for @posAddCustomerValidationVinMax.
  ///
  /// In en, this message translates to:
  /// **'Max 17 characters'**
  String get posAddCustomerValidationVinMax;

  /// No description provided for @posAddCustomerValidationInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get posAddCustomerValidationInvalidNumber;

  /// No description provided for @posAddCustomerValidationInvalidNumberShort.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get posAddCustomerValidationInvalidNumberShort;

  /// No description provided for @posMonitoringTitle.
  ///
  /// In en, this message translates to:
  /// **'POS Monitoring'**
  String get posMonitoringTitle;

  /// No description provided for @posMonitoringLiveCounters.
  ///
  /// In en, this message translates to:
  /// **'Live Counters'**
  String get posMonitoringLiveCounters;

  /// No description provided for @posMonitoringClosingReports.
  ///
  /// In en, this message translates to:
  /// **'Closing Reports'**
  String get posMonitoringClosingReports;

  /// No description provided for @posMonitoringSummaryLiveCounters.
  ///
  /// In en, this message translates to:
  /// **'Live Counters'**
  String get posMonitoringSummaryLiveCounters;

  /// No description provided for @posMonitoringSummaryOpenOrders.
  ///
  /// In en, this message translates to:
  /// **'Open Orders'**
  String get posMonitoringSummaryOpenOrders;

  /// No description provided for @posMonitoringSummaryTodaySales.
  ///
  /// In en, this message translates to:
  /// **'Today Sales'**
  String get posMonitoringSummaryTodaySales;

  /// No description provided for @posMonitoringNoLiveCounters.
  ///
  /// In en, this message translates to:
  /// **'No active live counters'**
  String get posMonitoringNoLiveCounters;

  /// No description provided for @posMonitoringNoClosingReports.
  ///
  /// In en, this message translates to:
  /// **'No closing reports available'**
  String get posMonitoringNoClosingReports;

  /// No description provided for @posMonitoringStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get posMonitoringStatusOpen;

  /// No description provided for @posMonitoringStatusClosing.
  ///
  /// In en, this message translates to:
  /// **'CLOSING'**
  String get posMonitoringStatusClosing;

  /// No description provided for @posMonitoringStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'CLOSED'**
  String get posMonitoringStatusClosed;

  /// No description provided for @posMonitoringStatShiftSales.
  ///
  /// In en, this message translates to:
  /// **'SHIFT SALES'**
  String get posMonitoringStatShiftSales;

  /// No description provided for @posMonitoringStatOpenOrders.
  ///
  /// In en, this message translates to:
  /// **'OPEN ORDERS'**
  String get posMonitoringStatOpenOrders;

  /// No description provided for @posMonitoringStatElapsed.
  ///
  /// In en, this message translates to:
  /// **'ELAPSED'**
  String get posMonitoringStatElapsed;

  /// No description provided for @posMonitoringElapsedFormat.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m'**
  String posMonitoringElapsedFormat(int h, int m);

  /// No description provided for @posMonitoringClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get posMonitoringClosed;

  /// No description provided for @posMonitoringTableCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get posMonitoringTableCategory;

  /// No description provided for @posMonitoringTableSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get posMonitoringTableSystem;

  /// No description provided for @posMonitoringTablePhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get posMonitoringTablePhysical;

  /// No description provided for @posMonitoringTableDiff.
  ///
  /// In en, this message translates to:
  /// **'Diff'**
  String get posMonitoringTableDiff;

  /// No description provided for @posMonitoringTableTotalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get posMonitoringTableTotalSales;

  /// No description provided for @posMonitoringRowCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get posMonitoringRowCash;

  /// No description provided for @posMonitoringRowBank.
  ///
  /// In en, this message translates to:
  /// **'Bank/Cards'**
  String get posMonitoringRowBank;

  /// No description provided for @posMonitoringRowCorporate.
  ///
  /// In en, this message translates to:
  /// **'Corporate'**
  String get posMonitoringRowCorporate;

  /// No description provided for @posMonitoringRowTamara.
  ///
  /// In en, this message translates to:
  /// **'Tamara'**
  String get posMonitoringRowTamara;

  /// No description provided for @posMonitoringRowTabby.
  ///
  /// In en, this message translates to:
  /// **'Tabby'**
  String get posMonitoringRowTabby;

  /// No description provided for @posMonitoringDiffShort.
  ///
  /// In en, this message translates to:
  /// **'SHORT'**
  String get posMonitoringDiffShort;

  /// No description provided for @posMonitoringDiffExcess.
  ///
  /// In en, this message translates to:
  /// **'EXCESS'**
  String get posMonitoringDiffExcess;

  /// No description provided for @posMonitoringDiffBalanced.
  ///
  /// In en, this message translates to:
  /// **'BALANCED'**
  String get posMonitoringDiffBalanced;

  /// No description provided for @posMonitoringDiffShortSymbol.
  ///
  /// In en, this message translates to:
  /// **'− SAR {amount}'**
  String posMonitoringDiffShortSymbol(String amount);

  /// No description provided for @posMonitoringDiffExcessSymbol.
  ///
  /// In en, this message translates to:
  /// **'+ SAR {amount}'**
  String posMonitoringDiffExcessSymbol(String amount);

  /// No description provided for @posMonitoringDiffNone.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get posMonitoringDiffNone;

  /// No description provided for @posMonitoringBackendWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠ Full breakdown unavailable — deploy latest backend to see per-category data'**
  String get posMonitoringBackendWarning;

  /// No description provided for @posMonitoringAmountSar.
  ///
  /// In en, this message translates to:
  /// **'SAR {amount}'**
  String posMonitoringAmountSar(String amount);

  /// No description provided for @promoTitle.
  ///
  /// In en, this message translates to:
  /// **'Promo Codes'**
  String get promoTitle;

  /// No description provided for @promoNewButton.
  ///
  /// In en, this message translates to:
  /// **'New Promo'**
  String get promoNewButton;

  /// No description provided for @promoNoCodesFound.
  ///
  /// In en, this message translates to:
  /// **'No promo codes found'**
  String get promoNoCodesFound;

  /// No description provided for @promoMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get promoMenuEdit;

  /// No description provided for @promoMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get promoMenuDelete;

  /// No description provided for @promoDiscountOff.
  ///
  /// In en, this message translates to:
  /// **'{value} {unit} OFF'**
  String promoDiscountOff(String value, String unit);

  /// No description provided for @promoUnitPercent.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get promoUnitPercent;

  /// No description provided for @promoUnitSar.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get promoUnitSar;

  /// No description provided for @promoStatUsage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get promoStatUsage;

  /// No description provided for @promoStatMinOrder.
  ///
  /// In en, this message translates to:
  /// **'Min Order'**
  String get promoStatMinOrder;

  /// No description provided for @promoStatValidTill.
  ///
  /// In en, this message translates to:
  /// **'Valid Till'**
  String get promoStatValidTill;

  /// No description provided for @promoMinOrderAmount.
  ///
  /// In en, this message translates to:
  /// **'SAR {amount}'**
  String promoMinOrderAmount(String amount);

  /// No description provided for @promoDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get promoDeleteConfirmTitle;

  /// No description provided for @promoDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{code}\"? This action cannot be undone.'**
  String promoDeleteConfirmBody(String code);

  /// No description provided for @promoDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get promoDeleteCancel;

  /// No description provided for @promoDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get promoDeleteConfirm;

  /// No description provided for @promoSheetCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Promo Code'**
  String get promoSheetCreateTitle;

  /// No description provided for @promoSheetUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Promo Code'**
  String get promoSheetUpdateTitle;

  /// No description provided for @promoSheetCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure a new discount code for customers.'**
  String get promoSheetCreateSubtitle;

  /// No description provided for @promoSheetUpdateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Modify existing promo code details.'**
  String get promoSheetUpdateSubtitle;

  /// No description provided for @promoFieldCode.
  ///
  /// In en, this message translates to:
  /// **'Promo Code (e.g., SUMMER20)'**
  String get promoFieldCode;

  /// No description provided for @promoFieldDiscountValue.
  ///
  /// In en, this message translates to:
  /// **'Discount Value'**
  String get promoFieldDiscountValue;

  /// No description provided for @promoFieldUsageLimit.
  ///
  /// In en, this message translates to:
  /// **'Usage Limit'**
  String get promoFieldUsageLimit;

  /// No description provided for @promoFieldMinOrder.
  ///
  /// In en, this message translates to:
  /// **'Min Order (SAR)'**
  String get promoFieldMinOrder;

  /// No description provided for @promoFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get promoFieldDescription;

  /// No description provided for @promoFieldValidFrom.
  ///
  /// In en, this message translates to:
  /// **'Valid From'**
  String get promoFieldValidFrom;

  /// No description provided for @promoFieldValidTo.
  ///
  /// In en, this message translates to:
  /// **'Valid To'**
  String get promoFieldValidTo;

  /// No description provided for @promoTypeFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed Amount'**
  String get promoTypeFixed;

  /// No description provided for @promoTypePercent.
  ///
  /// In en, this message translates to:
  /// **'Percentage (%)'**
  String get promoTypePercent;

  /// No description provided for @promoSubmitCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Promo'**
  String get promoSubmitCreate;

  /// No description provided for @promoSubmitUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Promo'**
  String get promoSubmitUpdate;

  /// No description provided for @promoValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill required fields (Code, Value)'**
  String get promoValidationRequired;

  /// No description provided for @promoCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Promo Code created successfully!'**
  String get promoCreateSuccess;

  /// No description provided for @promoUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Promo Code updated successfully!'**
  String get promoUpdateSuccess;

  /// No description provided for @promoDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Promo Code deleted successfully!'**
  String get promoDeleteSuccess;

  /// No description provided for @promoCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to process promo code'**
  String get promoCreateError;

  /// No description provided for @promoDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete promo code'**
  String get promoDeleteError;

  /// No description provided for @lockerVarianceRejected.
  ///
  /// In en, this message translates to:
  /// **'Variance rejected'**
  String get lockerVarianceRejected;

  /// No description provided for @lockerSelectOfficer.
  ///
  /// In en, this message translates to:
  /// **'SELECT OFFICER'**
  String get lockerSelectOfficer;

  /// No description provided for @lockerSelectOfficerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a field officer to assign to this collection request.'**
  String get lockerSelectOfficerSubtitle;

  /// No description provided for @lockerOfficersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load officers.'**
  String get lockerOfficersLoadError;

  /// No description provided for @lockerAssignedTo.
  ///
  /// In en, this message translates to:
  /// **'Assigned to'**
  String get lockerAssignedTo;

  /// No description provided for @lockerLoaderAuditReport.
  ///
  /// In en, this message translates to:
  /// **'Locker Audit Report'**
  String get lockerLoaderAuditReport;

  /// No description provided for @lockerGeneratedAt.
  ///
  /// In en, this message translates to:
  /// **'Generated at'**
  String get lockerGeneratedAt;

  /// No description provided for @lockerPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get lockerPage;

  /// No description provided for @lockerOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get lockerOf;

  /// No description provided for @lockerRequestInformation.
  ///
  /// In en, this message translates to:
  /// **'REQUEST INFORMATION'**
  String get lockerRequestInformation;

  /// No description provided for @lockerPosSession.
  ///
  /// In en, this message translates to:
  /// **'POS SESSION'**
  String get lockerPosSession;

  /// No description provided for @lockerOpenedAt.
  ///
  /// In en, this message translates to:
  /// **'Opened At'**
  String get lockerOpenedAt;

  /// No description provided for @lockerClosedAt.
  ///
  /// In en, this message translates to:
  /// **'Closed At'**
  String get lockerClosedAt;

  /// No description provided for @lockerSessionStatus.
  ///
  /// In en, this message translates to:
  /// **'Session Status'**
  String get lockerSessionStatus;

  /// No description provided for @lockerReceivedAmount.
  ///
  /// In en, this message translates to:
  /// **'Received Amount'**
  String get lockerReceivedAmount;

  /// No description provided for @lockerNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get lockerNotes;

  /// No description provided for @lockerAuditFootnote.
  ///
  /// In en, this message translates to:
  /// **'This report is system-generated and serves as an official audit record.'**
  String get lockerAuditFootnote;

  /// No description provided for @lockerAuditFootnoteAmounts.
  ///
  /// In en, this message translates to:
  /// **'All amounts are in {currency}.'**
  String lockerAuditFootnoteAmounts(String currency);

  /// No description provided for @lockerCurrencyPrefix.
  ///
  /// In en, this message translates to:
  /// **'{currency} {amount}'**
  String lockerCurrencyPrefix(String currency, String amount);

  /// No description provided for @lockerSarCurrency.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get lockerSarCurrency;

  /// No description provided for @lockerLoadingVariance.
  ///
  /// In en, this message translates to:
  /// **'Loading variance approvals…'**
  String get lockerLoadingVariance;

  /// No description provided for @lockerFailedLoadVariance.
  ///
  /// In en, this message translates to:
  /// **'Failed to load variance approvals'**
  String get lockerFailedLoadVariance;

  /// No description provided for @lockerAllClear.
  ///
  /// In en, this message translates to:
  /// **'All Clear!'**
  String get lockerAllClear;

  /// No description provided for @lockerNoPendingVariance.
  ///
  /// In en, this message translates to:
  /// **'No pending variance approvals at this time.'**
  String get lockerNoPendingVariance;

  /// No description provided for @lockerVarianceReviewBanner.
  ///
  /// In en, this message translates to:
  /// **'These collections have a cash variance and require your approval.'**
  String get lockerVarianceReviewBanner;

  /// No description provided for @lockerShortLabel.
  ///
  /// In en, this message translates to:
  /// **'SHORT'**
  String get lockerShortLabel;

  /// No description provided for @lockerOverLabel.
  ///
  /// In en, this message translates to:
  /// **'OVER'**
  String get lockerOverLabel;

  /// No description provided for @lockerApproveVarianceTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve Variance'**
  String get lockerApproveVarianceTitle;

  /// No description provided for @lockerApproveVarianceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Approve {type} variance of SAR {amount} for {branch}?'**
  String lockerApproveVarianceConfirm(
    String type,
    String amount,
    String branch,
  );

  /// No description provided for @lockerApproveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Variance approved successfully'**
  String get lockerApproveSuccess;

  /// No description provided for @lockerRejectSuccess.
  ///
  /// In en, this message translates to:
  /// **'Variance rejected'**
  String get lockerRejectSuccess;

  /// No description provided for @lockerRejectVarianceDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Variance'**
  String get lockerRejectVarianceDialogTitle;

  /// No description provided for @lockerRejectingFor.
  ///
  /// In en, this message translates to:
  /// **'Rejecting variance for {branch}.'**
  String lockerRejectingFor(String branch);

  /// No description provided for @lockerRejectionReasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get lockerRejectionReasonOptional;

  /// No description provided for @lockerShortVariance.
  ///
  /// In en, this message translates to:
  /// **'SHORT'**
  String get lockerShortVariance;

  /// No description provided for @lockerOverVariance.
  ///
  /// In en, this message translates to:
  /// **'OVER'**
  String get lockerOverVariance;

  /// No description provided for @lockerCashierLabel.
  ///
  /// In en, this message translates to:
  /// **'CASHIER'**
  String get lockerCashierLabel;

  /// No description provided for @lockerOfficerLabel.
  ///
  /// In en, this message translates to:
  /// **'OFFICER'**
  String get lockerOfficerLabel;

  /// No description provided for @lockerExpected.
  ///
  /// In en, this message translates to:
  /// **'EXPECTED'**
  String get lockerExpected;

  /// No description provided for @lockerReceivedLabel.
  ///
  /// In en, this message translates to:
  /// **'RECEIVED'**
  String get lockerReceivedLabel;

  /// No description provided for @lockerDiffLabel.
  ///
  /// In en, this message translates to:
  /// **'DIFF'**
  String get lockerDiffLabel;

  /// No description provided for @lockerRecordCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'RECORD COLLECTION'**
  String get lockerRecordCollectionTitle;

  /// No description provided for @lockerExpectedAmount.
  ///
  /// In en, this message translates to:
  /// **'EXPECTED AMOUNT'**
  String get lockerExpectedAmount;

  /// No description provided for @lockerVerifiedReceivedAmount.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED RECEIVED AMOUNT'**
  String get lockerVerifiedReceivedAmount;

  /// No description provided for @lockerLockedAmount.
  ///
  /// In en, this message translates to:
  /// **'LOCKED AMOUNT'**
  String get lockerLockedAmount;

  /// No description provided for @lockerReceivedAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'RECEIVED AMOUNT'**
  String get lockerReceivedAmountLabel;

  /// No description provided for @lockerCollectionNotes.
  ///
  /// In en, this message translates to:
  /// **'COLLECTION NOTES'**
  String get lockerCollectionNotes;

  /// No description provided for @lockerCollectionNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter any remarks or reason for difference…'**
  String get lockerCollectionNotesHint;

  /// No description provided for @lockerCollectionEvidence.
  ///
  /// In en, this message translates to:
  /// **'COLLECTION EVIDENCE'**
  String get lockerCollectionEvidence;

  /// No description provided for @lockerCapturePhoto.
  ///
  /// In en, this message translates to:
  /// **'CAPTURE PHOTO'**
  String get lockerCapturePhoto;

  /// No description provided for @lockerAttachLogs.
  ///
  /// In en, this message translates to:
  /// **'ATTACH LOGS'**
  String get lockerAttachLogs;

  /// No description provided for @lockerConfirmFinalise.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM & FINALISE ASSET'**
  String get lockerConfirmFinalise;

  /// No description provided for @lockerEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid received amount.'**
  String get lockerEnterValidAmount;

  /// No description provided for @lockerSuccessPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'PENDING APPROVAL'**
  String get lockerSuccessPendingApproval;

  /// No description provided for @lockerSuccessCollectionRecorded.
  ///
  /// In en, this message translates to:
  /// **'COLLECTION RECORDED'**
  String get lockerSuccessCollectionRecorded;

  /// No description provided for @lockerStatusReview.
  ///
  /// In en, this message translates to:
  /// **'REVIEW'**
  String get lockerStatusReview;

  /// No description provided for @lockerStatusOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get lockerStatusOk;

  /// No description provided for @lockerStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get lockerStatusLabel;

  /// No description provided for @lockerDone.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get lockerDone;

  /// No description provided for @lockerNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get lockerNotificationsTitle;

  /// No description provided for @lockerSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get lockerSessionExpired;

  /// No description provided for @lockerSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get lockerSomethingWentWrong;

  /// No description provided for @lockerCouldNotRefresh.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh.'**
  String get lockerCouldNotRefresh;

  /// No description provided for @lockerNoNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get lockerNoNotificationsYet;

  /// No description provided for @lockerTryAgain.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN'**
  String get lockerTryAgain;

  /// No description provided for @lockerFinancialReports.
  ///
  /// In en, this message translates to:
  /// **'FINANCIAL REPORTS'**
  String get lockerFinancialReports;

  /// No description provided for @lockerTabHistory.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get lockerTabHistory;

  /// No description provided for @lockerTabAnalytics.
  ///
  /// In en, this message translates to:
  /// **'ANALYTICS'**
  String get lockerTabAnalytics;

  /// No description provided for @lockerSearchByRefOrOfficer.
  ///
  /// In en, this message translates to:
  /// **'Search by Ref or Officer…'**
  String get lockerSearchByRefOrOfficer;

  /// No description provided for @lockerAuditLogs.
  ///
  /// In en, this message translates to:
  /// **'AUDIT LOGS'**
  String get lockerAuditLogs;

  /// No description provided for @lockerRecordsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} records'**
  String lockerRecordsCount(int count);

  /// No description provided for @lockerExportPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get lockerExportPdf;

  /// No description provided for @lockerExportExcel.
  ///
  /// In en, this message translates to:
  /// **'EXCEL'**
  String get lockerExportExcel;

  /// No description provided for @lockerDifferencesSummary.
  ///
  /// In en, this message translates to:
  /// **'DIFFERENCES SUMMARY'**
  String get lockerDifferencesSummary;

  /// No description provided for @lockerTotalShort.
  ///
  /// In en, this message translates to:
  /// **'TOTAL SHORT'**
  String get lockerTotalShort;

  /// No description provided for @lockerTotalOver.
  ///
  /// In en, this message translates to:
  /// **'TOTAL OVER'**
  String get lockerTotalOver;

  /// No description provided for @lockerNetDifference.
  ///
  /// In en, this message translates to:
  /// **'NET DIFFERENCE'**
  String get lockerNetDifference;

  /// No description provided for @lockerTotalCollections.
  ///
  /// In en, this message translates to:
  /// **'TOTAL COLLECTIONS'**
  String get lockerTotalCollections;

  /// No description provided for @lockerMyCollectionPerformance.
  ///
  /// In en, this message translates to:
  /// **'MY COLLECTION PERFORMANCE'**
  String get lockerMyCollectionPerformance;

  /// No description provided for @lockerCollectionPerformance.
  ///
  /// In en, this message translates to:
  /// **'COLLECTION PERFORMANCE'**
  String get lockerCollectionPerformance;

  /// No description provided for @lockerOfficerComplianceRatings.
  ///
  /// In en, this message translates to:
  /// **'OFFICER COMPLIANCE RATINGS'**
  String get lockerOfficerComplianceRatings;

  /// No description provided for @lockerNoComplianceData.
  ///
  /// In en, this message translates to:
  /// **'No compliance data for this period.'**
  String get lockerNoComplianceData;

  /// No description provided for @lockerNoResultsMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No results match your filters.'**
  String get lockerNoResultsMatchFilters;

  /// No description provided for @lockerNoAuditLogsFound.
  ///
  /// In en, this message translates to:
  /// **'No audit logs found.'**
  String get lockerNoAuditLogsFound;

  /// No description provided for @lockerAnErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get lockerAnErrorOccurred;

  /// No description provided for @lockerAllRecords.
  ///
  /// In en, this message translates to:
  /// **'All records'**
  String get lockerAllRecords;

  /// No description provided for @lockerFilterSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get lockerFilterSearch;

  /// No description provided for @lockerFilterBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get lockerFilterBranch;

  /// No description provided for @lockerAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All Branches'**
  String get lockerAllBranches;

  /// No description provided for @lockerFilterByBranch.
  ///
  /// In en, this message translates to:
  /// **'Filter by Branch…'**
  String get lockerFilterByBranch;

  /// No description provided for @lockerLoadingBranches.
  ///
  /// In en, this message translates to:
  /// **'Loading branches…'**
  String get lockerLoadingBranches;

  /// No description provided for @lockerSortBy.
  ///
  /// In en, this message translates to:
  /// **'SORT BY'**
  String get lockerSortBy;

  /// No description provided for @lockerSortDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get lockerSortDate;

  /// No description provided for @lockerSortReceivedAmount.
  ///
  /// In en, this message translates to:
  /// **'Received Amount'**
  String get lockerSortReceivedAmount;

  /// No description provided for @lockerSortDifference.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get lockerSortDifference;

  /// No description provided for @lockerSortAsc.
  ///
  /// In en, this message translates to:
  /// **'ASC'**
  String get lockerSortAsc;

  /// No description provided for @lockerSortDesc.
  ///
  /// In en, this message translates to:
  /// **'DESC'**
  String get lockerSortDesc;

  /// No description provided for @lockerSelectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get lockerSelectDateRange;

  /// No description provided for @lockerDateFrom.
  ///
  /// In en, this message translates to:
  /// **'FROM'**
  String get lockerDateFrom;

  /// No description provided for @lockerDateTo.
  ///
  /// In en, this message translates to:
  /// **'TO'**
  String get lockerDateTo;

  /// No description provided for @lockerTapToSet.
  ///
  /// In en, this message translates to:
  /// **'Tap to set'**
  String get lockerTapToSet;

  /// No description provided for @lockerApplyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get lockerApplyFilter;

  /// No description provided for @lockerClearFilters.
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get lockerClearFilters;

  /// No description provided for @lockerNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get lockerNoData;

  /// No description provided for @lockerWeeklyCollectionVolume.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY COLLECTION VOLUME'**
  String get lockerWeeklyCollectionVolume;

  /// No description provided for @lockerTransactionRef.
  ///
  /// In en, this message translates to:
  /// **'TRANSACTION REF'**
  String get lockerTransactionRef;

  /// No description provided for @lockerReceivedFundLabel.
  ///
  /// In en, this message translates to:
  /// **'RECEIVED FUND'**
  String get lockerReceivedFundLabel;

  /// No description provided for @lockerFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load'**
  String get lockerFailedToLoad;

  /// No description provided for @lockerOneCollection.
  ///
  /// In en, this message translates to:
  /// **'1 collection'**
  String get lockerOneCollection;

  /// No description provided for @lockerNCollections.
  ///
  /// In en, this message translates to:
  /// **'{count} collections'**
  String lockerNCollections(int count);

  /// No description provided for @lockerStoragePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage Permission Required'**
  String get lockerStoragePermissionRequired;

  /// No description provided for @lockerStoragePermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Storage permission is required to save exported files. Please enable it in app settings.'**
  String get lockerStoragePermissionBody;

  /// No description provided for @lockerOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get lockerOpenSettings;

  /// No description provided for @lockerFinancialHistoryPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Locker Financial History'**
  String get lockerFinancialHistoryPdfTitle;

  /// No description provided for @lockerPdfGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get lockerPdfGenerated;

  /// No description provided for @lockerPdfTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get lockerPdfTotal;

  /// No description provided for @lockerPdfRecords.
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get lockerPdfRecords;

  /// No description provided for @lockerPdfRef.
  ///
  /// In en, this message translates to:
  /// **'REF'**
  String get lockerPdfRef;

  /// No description provided for @lockerPdfDate.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get lockerPdfDate;

  /// No description provided for @lockerPdfBranch.
  ///
  /// In en, this message translates to:
  /// **'BRANCH'**
  String get lockerPdfBranch;

  /// No description provided for @lockerPdfReceived.
  ///
  /// In en, this message translates to:
  /// **'RECEIVED'**
  String get lockerPdfReceived;

  /// No description provided for @lockerPdfExpected.
  ///
  /// In en, this message translates to:
  /// **'EXPECTED'**
  String get lockerPdfExpected;

  /// No description provided for @lockerPdfDiff.
  ///
  /// In en, this message translates to:
  /// **'DIFF'**
  String get lockerPdfDiff;

  /// No description provided for @lockerPdfStatus.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get lockerPdfStatus;

  /// No description provided for @lockerPdfExportFailed.
  ///
  /// In en, this message translates to:
  /// **'PDF export failed'**
  String get lockerPdfExportFailed;

  /// No description provided for @lockerExcelSheetName.
  ///
  /// In en, this message translates to:
  /// **'Locker History'**
  String get lockerExcelSheetName;

  /// No description provided for @lockerExcelOfficer.
  ///
  /// In en, this message translates to:
  /// **'Officer'**
  String get lockerExcelOfficer;

  /// No description provided for @lockerExcelReceivedSar.
  ///
  /// In en, this message translates to:
  /// **'Received (SAR)'**
  String get lockerExcelReceivedSar;

  /// No description provided for @lockerExcelExpectedSar.
  ///
  /// In en, this message translates to:
  /// **'Expected (SAR)'**
  String get lockerExcelExpectedSar;

  /// No description provided for @lockerExcelDiffSar.
  ///
  /// In en, this message translates to:
  /// **'Difference (SAR)'**
  String get lockerExcelDiffSar;

  /// No description provided for @lockerExcelRequestRef.
  ///
  /// In en, this message translates to:
  /// **'Request Ref'**
  String get lockerExcelRequestRef;

  /// No description provided for @lockerExcelExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Excel export failed'**
  String get lockerExcelExportFailed;

  /// No description provided for @accountingTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get accountingTitle;

  /// No description provided for @accountingTabPayables.
  ///
  /// In en, this message translates to:
  /// **'Payables'**
  String get accountingTabPayables;

  /// No description provided for @accountingTabReceivables.
  ///
  /// In en, this message translates to:
  /// **'Receivables'**
  String get accountingTabReceivables;

  /// No description provided for @accountingTabExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get accountingTabExpenses;

  /// No description provided for @accountingTabAdvances.
  ///
  /// In en, this message translates to:
  /// **'Advances'**
  String get accountingTabAdvances;

  /// No description provided for @accountingPayables.
  ///
  /// In en, this message translates to:
  /// **'Payables'**
  String get accountingPayables;

  /// No description provided for @accountingReceivables.
  ///
  /// In en, this message translates to:
  /// **'Receivables'**
  String get accountingReceivables;

  /// No description provided for @accountingOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get accountingOverdue;

  /// No description provided for @accountingNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries found'**
  String get accountingNoEntries;

  /// No description provided for @accountingRefPrefix.
  ///
  /// In en, this message translates to:
  /// **'Ref: {ref} • {date}'**
  String accountingRefPrefix(String ref, String date);

  /// No description provided for @accountingStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get accountingStatusOverdue;

  /// No description provided for @accountingStatusSettled.
  ///
  /// In en, this message translates to:
  /// **'SETTLED'**
  String get accountingStatusSettled;

  /// No description provided for @accountingStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get accountingStatusPending;

  /// No description provided for @accountingLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load accounting data'**
  String get accountingLoadingError;

  /// No description provided for @accountingAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'SAR {amount}'**
  String accountingAmountLabel(String amount);

  /// No description provided for @approvalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approvalsTitle;

  /// No description provided for @approvalsQueueLabel.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get approvalsQueueLabel;

  /// No description provided for @approvalsStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get approvalsStatusLabel;

  /// No description provided for @approvalsQueueAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get approvalsQueueAll;

  /// No description provided for @approvalsQueueTopUps.
  ///
  /// In en, this message translates to:
  /// **'Top-ups'**
  String get approvalsQueueTopUps;

  /// No description provided for @approvalsQueueExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get approvalsQueueExpenses;

  /// No description provided for @approvalsStatusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get approvalsStatusAll;

  /// No description provided for @approvalsStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get approvalsStatusPending;

  /// No description provided for @approvalsStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approvalsStatusApproved;

  /// No description provided for @approvalsStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get approvalsStatusRejected;

  /// No description provided for @approvalsEmptyExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expense approvals'**
  String get approvalsEmptyExpenses;

  /// No description provided for @approvalsEmptyPettyCash.
  ///
  /// In en, this message translates to:
  /// **'No petty cash requests'**
  String get approvalsEmptyPettyCash;

  /// No description provided for @approvalsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No records for this queue and status.'**
  String get approvalsEmptySubtitle;

  /// No description provided for @approvalsNoAddressesFound.
  ///
  /// In en, this message translates to:
  /// **'No addresses found.'**
  String get approvalsNoAddressesFound;

  /// No description provided for @approvalsLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load approvals'**
  String get approvalsLoadingError;

  /// No description provided for @approvalsApproveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Approve this request?'**
  String get approvalsApproveConfirm;

  /// No description provided for @approvalsRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Request'**
  String get approvalsRejectTitle;

  /// No description provided for @approvalsRejectHint.
  ///
  /// In en, this message translates to:
  /// **'Enter rejection reason (optional)'**
  String get approvalsRejectHint;

  /// No description provided for @approvalsConfirmReject.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reject'**
  String get approvalsConfirmReject;

  /// No description provided for @approvalsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get approvalsCancel;

  /// No description provided for @ownerLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Workshop Owner'**
  String get ownerLoginTitle;

  /// No description provided for @ownerLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your dashboard'**
  String get ownerLoginSubtitle;

  /// No description provided for @ownerLoginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get ownerLoginEmail;

  /// No description provided for @ownerLoginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get ownerLoginEmailHint;

  /// No description provided for @ownerLoginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get ownerLoginEmailRequired;

  /// No description provided for @ownerLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get ownerLoginPassword;

  /// No description provided for @ownerLoginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get ownerLoginPasswordHint;

  /// No description provided for @ownerLoginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get ownerLoginPasswordRequired;

  /// No description provided for @ownerLoginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get ownerLoginForgotPassword;

  /// No description provided for @ownerLoginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get ownerLoginSignIn;

  /// No description provided for @ownerLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get ownerLoginSuccess;

  /// No description provided for @ownerLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get ownerLoginFailed;

  /// No description provided for @ownerLoginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get ownerLoginNoAccount;

  /// No description provided for @ownerRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get ownerRegisterTitle;

  /// No description provided for @ownerRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register your workshop'**
  String get ownerRegisterSubtitle;

  /// No description provided for @ownerRegisterWorkshopName.
  ///
  /// In en, this message translates to:
  /// **'Workshop Name'**
  String get ownerRegisterWorkshopName;

  /// No description provided for @ownerRegisterWorkshopNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter workshop name'**
  String get ownerRegisterWorkshopNameHint;

  /// No description provided for @ownerRegisterOwnerName.
  ///
  /// In en, this message translates to:
  /// **'Owner Name'**
  String get ownerRegisterOwnerName;

  /// No description provided for @ownerRegisterOwnerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get ownerRegisterOwnerNameHint;

  /// No description provided for @ownerRegisterEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get ownerRegisterEmail;

  /// No description provided for @ownerRegisterEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get ownerRegisterEmailHint;

  /// No description provided for @ownerRegisterMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get ownerRegisterMobile;

  /// No description provided for @ownerRegisterMobileHint.
  ///
  /// In en, this message translates to:
  /// **'+966...'**
  String get ownerRegisterMobileHint;

  /// No description provided for @ownerRegisterTaxId.
  ///
  /// In en, this message translates to:
  /// **'Tax ID'**
  String get ownerRegisterTaxId;

  /// No description provided for @ownerRegisterTaxIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Tax ID'**
  String get ownerRegisterTaxIdHint;

  /// No description provided for @ownerRegisterAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get ownerRegisterAddress;

  /// No description provided for @ownerRegisterAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Search and select full address'**
  String get ownerRegisterAddressHint;

  /// No description provided for @ownerRegisterPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get ownerRegisterPassword;

  /// No description provided for @ownerRegisterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get ownerRegisterPasswordHint;

  /// No description provided for @ownerRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get ownerRegisterButton;

  /// No description provided for @ownerRegisterSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful. Please login.'**
  String get ownerRegisterSuccess;

  /// No description provided for @ownerRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get ownerRegisterFailed;

  /// No description provided for @ownerRegisterFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get ownerRegisterFieldRequired;

  /// No description provided for @ownerRegisterHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get ownerRegisterHaveAccount;

  /// No description provided for @corporateManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Corporate Management'**
  String get corporateManagementTitle;

  /// No description provided for @corporateSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by Company or VAT...'**
  String get corporateSearchHint;

  /// No description provided for @corporateAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Corporate'**
  String get corporateAddButton;

  /// No description provided for @corporateNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No corporate customers found.'**
  String get corporateNoneFound;

  /// No description provided for @corporateVatLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT: {vat}'**
  String corporateVatLabel(String vat);

  /// No description provided for @corporateVehiclesLabel.
  ///
  /// In en, this message translates to:
  /// **'VEHICLES'**
  String get corporateVehiclesLabel;

  /// No description provided for @corporateRevenueLabel.
  ///
  /// In en, this message translates to:
  /// **'REVENUE'**
  String get corporateRevenueLabel;

  /// No description provided for @corporateAddUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get corporateAddUser;

  /// No description provided for @corporateEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get corporateEdit;

  /// No description provided for @corporateRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Register Corporate Partner'**
  String get corporateRegisterTitle;

  /// No description provided for @corporateRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details to create a new corporate account.'**
  String get corporateRegisterSubtitle;

  /// No description provided for @corporateFieldCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get corporateFieldCompanyName;

  /// No description provided for @corporateFieldCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get corporateFieldCustomerName;

  /// No description provided for @corporateFieldMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get corporateFieldMobile;

  /// No description provided for @corporateFieldVat.
  ///
  /// In en, this message translates to:
  /// **'VAT Number'**
  String get corporateFieldVat;

  /// No description provided for @corporateFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get corporateFieldEmail;

  /// No description provided for @corporateFieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get corporateFieldPassword;

  /// No description provided for @corporateFieldReferral.
  ///
  /// In en, this message translates to:
  /// **'Referral'**
  String get corporateFieldReferral;

  /// No description provided for @corporateSelectBranches.
  ///
  /// In en, this message translates to:
  /// **'Select Branches'**
  String get corporateSelectBranches;

  /// No description provided for @corporateSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String corporateSelectedCount(int count);

  /// No description provided for @corporateNoBranches.
  ///
  /// In en, this message translates to:
  /// **'No branches found'**
  String get corporateNoBranches;

  /// No description provided for @corporateCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Partner'**
  String get corporateCreateButton;

  /// No description provided for @corporateAddUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Corporate User'**
  String get corporateAddUserTitle;

  /// No description provided for @corporateAddUserSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create credentials for a user associated with this corporate account.'**
  String get corporateAddUserSubtitle;

  /// No description provided for @corporateUserFieldName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get corporateUserFieldName;

  /// No description provided for @corporateUserFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get corporateUserFieldEmail;

  /// No description provided for @corporateUserFieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get corporateUserFieldPassword;

  /// No description provided for @corporateCreateUserButton.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get corporateCreateUserButton;

  /// No description provided for @corporateEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Corporate Account'**
  String get corporateEditTitle;

  /// No description provided for @corporateEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update the details below. Only changed fields will be sent.'**
  String get corporateEditSubtitle;

  /// No description provided for @invTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory & Products'**
  String get invTitle;

  /// No description provided for @invTabProducts.
  ///
  /// In en, this message translates to:
  /// **'PRODUCTS'**
  String get invTabProducts;

  /// No description provided for @invTabServices.
  ///
  /// In en, this message translates to:
  /// **'SERVICES'**
  String get invTabServices;

  /// No description provided for @invTabCategory.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get invTabCategory;

  /// No description provided for @invAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get invAddProduct;

  /// No description provided for @invAddService.
  ///
  /// In en, this message translates to:
  /// **'Add Service'**
  String get invAddService;

  /// No description provided for @invAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get invAddCategory;

  /// No description provided for @invAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get invAdd;

  /// No description provided for @invSearchProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or category...'**
  String get invSearchProductsHint;

  /// No description provided for @invSearchServicesHint.
  ///
  /// In en, this message translates to:
  /// **'Search services...'**
  String get invSearchServicesHint;

  /// No description provided for @invSearchCategoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get invSearchCategoriesHint;

  /// No description provided for @invNoProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found.'**
  String get invNoProductsFound;

  /// No description provided for @invNoServicesFound.
  ///
  /// In en, this message translates to:
  /// **'No services found.'**
  String get invNoServicesFound;

  /// No description provided for @invNoCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found.'**
  String get invNoCategoriesFound;

  /// No description provided for @invNoProductsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No products found matching your search.'**
  String get invNoProductsMatchSearch;

  /// No description provided for @invNoServicesMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No services found matching your search.'**
  String get invNoServicesMatchSearch;

  /// No description provided for @invNoCategoriesMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No categories found matching your search.'**
  String get invNoCategoriesMatchSearch;

  /// No description provided for @invMetricStock.
  ///
  /// In en, this message translates to:
  /// **'STOCK'**
  String get invMetricStock;

  /// No description provided for @invMetricPurchase.
  ///
  /// In en, this message translates to:
  /// **'PURCHASE'**
  String get invMetricPurchase;

  /// No description provided for @invMetricRetail.
  ///
  /// In en, this message translates to:
  /// **'RETAIL'**
  String get invMetricRetail;

  /// No description provided for @invMetricPrice.
  ///
  /// In en, this message translates to:
  /// **'PRICE'**
  String get invMetricPrice;

  /// No description provided for @invMetricCorpRange.
  ///
  /// In en, this message translates to:
  /// **'CORP RANGE'**
  String get invMetricCorpRange;

  /// No description provided for @invMetricCorporate.
  ///
  /// In en, this message translates to:
  /// **'CORPORATE'**
  String get invMetricCorporate;

  /// No description provided for @invEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get invEditTooltip;

  /// No description provided for @invDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get invDeleteTooltip;

  /// No description provided for @invMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get invMenuEdit;

  /// No description provided for @invMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get invMenuDelete;

  /// No description provided for @invConfirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get invConfirmDeleteTitle;

  /// No description provided for @invConfirmDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String invConfirmDeleteBody(String name);

  /// No description provided for @invCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get invCancel;

  /// No description provided for @invConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get invConfirm;

  /// No description provided for @invCategoryTabProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get invCategoryTabProducts;

  /// No description provided for @invCategoryTabServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get invCategoryTabServices;

  /// No description provided for @invCreateProduct.
  ///
  /// In en, this message translates to:
  /// **'Create Product'**
  String get invCreateProduct;

  /// No description provided for @invUpdateProduct.
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get invUpdateProduct;

  /// No description provided for @invCreateProductSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter product details to add to inventory.'**
  String get invCreateProductSubtitle;

  /// No description provided for @invUpdateProductSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Modify existing product details.'**
  String get invUpdateProductSubtitle;

  /// No description provided for @invFieldBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get invFieldBranch;

  /// No description provided for @invFieldDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get invFieldDepartment;

  /// No description provided for @invFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get invFieldCategory;

  /// No description provided for @invFieldProductName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get invFieldProductName;

  /// No description provided for @invFieldStockQty.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get invFieldStockQty;

  /// No description provided for @invFieldUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get invFieldUnit;

  /// No description provided for @invFieldCriticalStock.
  ///
  /// In en, this message translates to:
  /// **'Critical Stock Point'**
  String get invFieldCriticalStock;

  /// No description provided for @invSectionPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing Details'**
  String get invSectionPricing;

  /// No description provided for @invFieldPurchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price'**
  String get invFieldPurchasePrice;

  /// No description provided for @invFieldSalePrice.
  ///
  /// In en, this message translates to:
  /// **'Sale Price'**
  String get invFieldSalePrice;

  /// No description provided for @invFieldMinCorpPrice.
  ///
  /// In en, this message translates to:
  /// **'Min Corp Price'**
  String get invFieldMinCorpPrice;

  /// No description provided for @invFieldMaxCorpPrice.
  ///
  /// In en, this message translates to:
  /// **'Max Corp Price'**
  String get invFieldMaxCorpPrice;

  /// No description provided for @invToggleDecimal.
  ///
  /// In en, this message translates to:
  /// **'Allow Decimal Point'**
  String get invToggleDecimal;

  /// No description provided for @invToggleActive.
  ///
  /// In en, this message translates to:
  /// **'Active Status'**
  String get invToggleActive;

  /// No description provided for @invSaveProduct.
  ///
  /// In en, this message translates to:
  /// **'Save Product'**
  String get invSaveProduct;

  /// No description provided for @invProductCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product Created Successfully'**
  String get invProductCreateSuccess;

  /// No description provided for @invProductUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product Updated Successfully'**
  String get invProductUpdateSuccess;

  /// No description provided for @invProductCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create product'**
  String get invProductCreateError;

  /// No description provided for @invProductDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product Deleted Successfully'**
  String get invProductDeleteSuccess;

  /// No description provided for @invProductDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product'**
  String get invProductDeleteError;

  /// No description provided for @invValidationFillRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get invValidationFillRequired;

  /// No description provided for @invValidationSelectDepartment.
  ///
  /// In en, this message translates to:
  /// **'Please select a department.'**
  String get invValidationSelectDepartment;

  /// No description provided for @invValidationCreateCategory.
  ///
  /// In en, this message translates to:
  /// **'Please create a category first.'**
  String get invValidationCreateCategory;

  /// No description provided for @invValidationSelectBranch.
  ///
  /// In en, this message translates to:
  /// **'Please select a branch.'**
  String get invValidationSelectBranch;

  /// No description provided for @invCreateService.
  ///
  /// In en, this message translates to:
  /// **'Create Service'**
  String get invCreateService;

  /// No description provided for @invUpdateService.
  ///
  /// In en, this message translates to:
  /// **'Update Service'**
  String get invUpdateService;

  /// No description provided for @invCreateServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter service details.'**
  String get invCreateServiceSubtitle;

  /// No description provided for @invUpdateServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Modify existing service details.'**
  String get invUpdateServiceSubtitle;

  /// No description provided for @invFieldServiceName.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get invFieldServiceName;

  /// No description provided for @invFieldServicePrice.
  ///
  /// In en, this message translates to:
  /// **'Service Price'**
  String get invFieldServicePrice;

  /// No description provided for @invTogglePriceEditable.
  ///
  /// In en, this message translates to:
  /// **'Cashier can change price on POS'**
  String get invTogglePriceEditable;

  /// No description provided for @invSaveService.
  ///
  /// In en, this message translates to:
  /// **'Save Service'**
  String get invSaveService;

  /// No description provided for @invServiceCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Service Created Successfully'**
  String get invServiceCreateSuccess;

  /// No description provided for @invServiceUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Service Updated Successfully'**
  String get invServiceUpdateSuccess;

  /// No description provided for @invServiceCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create service'**
  String get invServiceCreateError;

  /// No description provided for @invServiceDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Service Deleted Successfully'**
  String get invServiceDeleteSuccess;

  /// No description provided for @invServiceDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete service'**
  String get invServiceDeleteError;

  /// No description provided for @invValidationFillServiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in required fields.'**
  String get invValidationFillServiceRequired;

  /// No description provided for @invCreateCategory.
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get invCreateCategory;

  /// No description provided for @invUpdateCategory.
  ///
  /// In en, this message translates to:
  /// **'Update Category'**
  String get invUpdateCategory;

  /// No description provided for @invCreateCategorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter details for the new category.'**
  String get invCreateCategorySubtitle;

  /// No description provided for @invUpdateCategorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Modify existing category details.'**
  String get invUpdateCategorySubtitle;

  /// No description provided for @invFieldCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get invFieldCategoryName;

  /// No description provided for @invSaveCategory.
  ///
  /// In en, this message translates to:
  /// **'Save Category'**
  String get invSaveCategory;

  /// No description provided for @invCategoryCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category Created Successfully'**
  String get invCategoryCreateSuccess;

  /// No description provided for @invCategoryUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category Updated Successfully'**
  String get invCategoryUpdateSuccess;

  /// No description provided for @invCategoryCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create category'**
  String get invCategoryCreateError;

  /// No description provided for @invCategoryDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category Deleted Successfully'**
  String get invCategoryDeleteSuccess;

  /// No description provided for @invCategoryDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete category'**
  String get invCategoryDeleteError;

  /// No description provided for @invCreateSubCategory.
  ///
  /// In en, this message translates to:
  /// **'Create Sub Category'**
  String get invCreateSubCategory;

  /// No description provided for @invCreateSubCategorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter details for the new sub category.'**
  String get invCreateSubCategorySubtitle;

  /// No description provided for @invFieldSubCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Sub Category Name'**
  String get invFieldSubCategoryName;

  /// No description provided for @invSaveSubCategory.
  ///
  /// In en, this message translates to:
  /// **'Save Sub Category'**
  String get invSaveSubCategory;

  /// No description provided for @invSubCategoryCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sub Category Created Successfully'**
  String get invSubCategoryCreateSuccess;

  /// No description provided for @invSubCategoryUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sub Category Updated Successfully'**
  String get invSubCategoryUpdateSuccess;

  /// No description provided for @invSubCategoryCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create sub category'**
  String get invSubCategoryCreateError;

  /// No description provided for @invSubCategoryDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sub Category Deleted Successfully'**
  String get invSubCategoryDeleteSuccess;

  /// No description provided for @invSubCategoryDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete sub category'**
  String get invSubCategoryDeleteError;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifTitle;

  /// No description provided for @notifMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notifMarkRead;

  /// No description provided for @notifEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get notifEmpty;

  /// No description provided for @notifTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{m}m ago'**
  String notifTimeMinutes(int m);

  /// No description provided for @notifTimeHours.
  ///
  /// In en, this message translates to:
  /// **'{h}h ago'**
  String notifTimeHours(int h);

  /// No description provided for @notifTimeDays.
  ///
  /// In en, this message translates to:
  /// **'{d}d ago'**
  String notifTimeDays(int d);

  /// No description provided for @notifTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'expense'**
  String get notifTypeExpense;

  /// No description provided for @notifTypeStock.
  ///
  /// In en, this message translates to:
  /// **'stock'**
  String get notifTypeStock;

  /// No description provided for @notifTypePayment.
  ///
  /// In en, this message translates to:
  /// **'payment'**
  String get notifTypePayment;

  /// No description provided for @notifTypeLocker.
  ///
  /// In en, this message translates to:
  /// **'locker'**
  String get notifTypeLocker;

  /// No description provided for @notifTypeInvoice.
  ///
  /// In en, this message translates to:
  /// **'invoice'**
  String get notifTypeInvoice;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports & Analytics'**
  String get reportsTitle;

  /// No description provided for @reportsFinancialOverview.
  ///
  /// In en, this message translates to:
  /// **'Financial Overview'**
  String get reportsFinancialOverview;

  /// No description provided for @reportsOperationalPerformance.
  ///
  /// In en, this message translates to:
  /// **'Operational Performance'**
  String get reportsOperationalPerformance;

  /// No description provided for @reportsInventoryValuation.
  ///
  /// In en, this message translates to:
  /// **'Inventory Valuation'**
  String get reportsInventoryValuation;

  /// No description provided for @reportsTotalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get reportsTotalRevenue;

  /// No description provided for @reportsNoDataThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No data for this week'**
  String get reportsNoDataThisWeek;

  /// No description provided for @reportsTotalJobs.
  ///
  /// In en, this message translates to:
  /// **'Total Jobs: {count}'**
  String reportsTotalJobs(int count);

  /// No description provided for @reportsCommissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get reportsCommissionLabel;

  /// No description provided for @reportsStockValueCost.
  ///
  /// In en, this message translates to:
  /// **'Stock Value (Cost)'**
  String get reportsStockValueCost;

  /// No description provided for @reportsPotentialProfit.
  ///
  /// In en, this message translates to:
  /// **'Potential Profit'**
  String get reportsPotentialProfit;

  /// No description provided for @reportsActiveSkus.
  ///
  /// In en, this message translates to:
  /// **'Active SKUs'**
  String get reportsActiveSkus;

  /// No description provided for @reportsItemsUnit.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String reportsItemsUnit(int count);

  /// No description provided for @reportsAmountSar.
  ///
  /// In en, this message translates to:
  /// **'SAR {amount}'**
  String reportsAmountSar(String amount);

  /// No description provided for @reportsNoOperationalData.
  ///
  /// In en, this message translates to:
  /// **'No operational performance data'**
  String get reportsNoOperationalData;

  /// No description provided for @reportsRevChangePositive.
  ///
  /// In en, this message translates to:
  /// **'+{pct}%'**
  String reportsRevChangePositive(String pct);

  /// No description provided for @reportsRevChangeNegative.
  ///
  /// In en, this message translates to:
  /// **'{pct}%'**
  String reportsRevChangeNegative(String pct);

  /// No description provided for @posCurrentShiftTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Shift'**
  String get posCurrentShiftTitle;

  /// No description provided for @posCurrentShiftDetails.
  ///
  /// In en, this message translates to:
  /// **'SHIFT DETAILS'**
  String get posCurrentShiftDetails;

  /// No description provided for @posCurrentShiftNoActiveSession.
  ///
  /// In en, this message translates to:
  /// **'No active session.'**
  String get posCurrentShiftNoActiveSession;

  /// No description provided for @posCurrentShiftNoActiveShiftFound.
  ///
  /// In en, this message translates to:
  /// **'No active shift found.'**
  String get posCurrentShiftNoActiveShiftFound;

  /// No description provided for @posCurrentShiftRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get posCurrentShiftRetry;

  /// No description provided for @posCurrentShiftSessionExpiredError.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get posCurrentShiftSessionExpiredError;

  /// No description provided for @posCurrentShiftFetchError.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch shift details: {error}'**
  String posCurrentShiftFetchError(String error);

  /// No description provided for @posCurrentShiftLabelCashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get posCurrentShiftLabelCashier;

  /// No description provided for @posCurrentShiftLabelSessionId.
  ///
  /// In en, this message translates to:
  /// **'Session ID'**
  String get posCurrentShiftLabelSessionId;

  /// No description provided for @posCurrentShiftLabelBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get posCurrentShiftLabelBranch;

  /// No description provided for @posCurrentShiftLabelElapsedTime.
  ///
  /// In en, this message translates to:
  /// **'Elapsed Time'**
  String get posCurrentShiftLabelElapsedTime;

  /// No description provided for @posCurrentShiftLabelOpenedAt.
  ///
  /// In en, this message translates to:
  /// **'Opened At'**
  String get posCurrentShiftLabelOpenedAt;

  /// No description provided for @posCurrentShiftLabelBranchAddress.
  ///
  /// In en, this message translates to:
  /// **'Branch Address'**
  String get posCurrentShiftLabelBranchAddress;

  /// No description provided for @posBroadcastTitle.
  ///
  /// In en, this message translates to:
  /// **'BROADCAST'**
  String get posBroadcastTitle;

  /// No description provided for @posBroadcastHeading.
  ///
  /// In en, this message translates to:
  /// **'Technician broadcasts'**
  String get posBroadcastHeading;

  /// No description provided for @posBroadcastNoActive.
  ///
  /// In en, this message translates to:
  /// **'No active broadcasts'**
  String get posBroadcastNoActive;

  /// No description provided for @posBroadcastCountActive.
  ///
  /// In en, this message translates to:
  /// **'{count} active · {window} per item'**
  String posBroadcastCountActive(int count, String window);

  /// No description provided for @posBroadcastRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get posBroadcastRetry;

  /// No description provided for @posBroadcastLabelSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get posBroadcastLabelSoon;

  /// No description provided for @posBroadcastLabelClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get posBroadcastLabelClosed;

  /// No description provided for @posBroadcastLabelRemaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get posBroadcastLabelRemaining;

  /// No description provided for @posBroadcastLabelExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get posBroadcastLabelExpired;

  /// No description provided for @posBroadcastWindow.
  ///
  /// In en, this message translates to:
  /// **'{m}:{s} window'**
  String posBroadcastWindow(String m, String s);

  /// No description provided for @posBroadcastTypeOnCall.
  ///
  /// In en, this message translates to:
  /// **'On call'**
  String get posBroadcastTypeOnCall;

  /// No description provided for @posBroadcastTypeWorkshop.
  ///
  /// In en, this message translates to:
  /// **'Workshop'**
  String get posBroadcastTypeWorkshop;

  /// No description provided for @posBroadcastSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get posBroadcastSessionExpired;

  /// No description provided for @posCorporateBookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Corporate Bookings'**
  String get posCorporateBookingsTitle;

  /// No description provided for @posCorporateFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get posCorporateFilterAll;

  /// No description provided for @posCorporateFilterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get posCorporateFilterToday;

  /// No description provided for @posCorporateFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get posCorporateFilterPending;

  /// No description provided for @posCorporateNoBookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Bookings Found'**
  String get posCorporateNoBookingsTitle;

  /// No description provided for @posCorporateNoBookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'There are no corporate bookings for the selected filter.'**
  String get posCorporateNoBookingsSubtitle;

  /// No description provided for @posCorporateCardLabelVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get posCorporateCardLabelVehicle;

  /// No description provided for @posCorporateCardLabelPlate.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get posCorporateCardLabelPlate;

  /// No description provided for @posCorporateCardLabelDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get posCorporateCardLabelDepartment;

  /// No description provided for @posCorporateCardLabelDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get posCorporateCardLabelDate;

  /// No description provided for @posCorporateActionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get posCorporateActionDetails;

  /// No description provided for @posCorporateActionReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get posCorporateActionReject;

  /// No description provided for @posCorporateActionApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get posCorporateActionApprove;

  /// No description provided for @posCorporateActionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get posCorporateActionContinue;

  /// No description provided for @posCorporateActionApproveBooking.
  ///
  /// In en, this message translates to:
  /// **'Approve Booking'**
  String get posCorporateActionApproveBooking;

  /// No description provided for @posCorporateActionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get posCorporateActionClose;

  /// No description provided for @posCorporateActionSubmitReason.
  ///
  /// In en, this message translates to:
  /// **'Submit Reason'**
  String get posCorporateActionSubmitReason;

  /// No description provided for @posCorporateActionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get posCorporateActionCancel;

  /// No description provided for @posCorporateDialogDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Corporate Booking Details'**
  String get posCorporateDialogDetailsTitle;

  /// No description provided for @posCorporateDialogRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get posCorporateDialogRejectTitle;

  /// No description provided for @posCorporateDialogRejectBody.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason to {action} this booking for {company}. This information will be sent back to the corporate portal.'**
  String posCorporateDialogRejectBody(String action, String company);

  /// No description provided for @posCorporateDialogReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get posCorporateDialogReasonLabel;

  /// No description provided for @posCorporateDialogReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your reason here...'**
  String get posCorporateDialogReasonHint;

  /// No description provided for @posCorporateDialogReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason to {action}.'**
  String posCorporateDialogReasonRequired(String action);

  /// No description provided for @posCorporateDetailsSectionBooking.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get posCorporateDetailsSectionBooking;

  /// No description provided for @posCorporateDetailsSectionVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get posCorporateDetailsSectionVehicle;

  /// No description provided for @posCorporateDetailsSectionProducts.
  ///
  /// In en, this message translates to:
  /// **'Requested Products'**
  String get posCorporateDetailsSectionProducts;

  /// No description provided for @posCorporateDetailsBookingId.
  ///
  /// In en, this message translates to:
  /// **'Booking ID'**
  String get posCorporateDetailsBookingId;

  /// No description provided for @posCorporateDetailsScheduledTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time'**
  String get posCorporateDetailsScheduledTime;

  /// No description provided for @posCorporateDetailsDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get posCorporateDetailsDepartment;

  /// No description provided for @posCorporateDetailsRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason'**
  String get posCorporateDetailsRejectionReason;

  /// No description provided for @posCorporateDetailsVehicleName.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Name'**
  String get posCorporateDetailsVehicleName;

  /// No description provided for @posCorporateDetailsLicensePlate.
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get posCorporateDetailsLicensePlate;

  /// No description provided for @posCorporateDetailsNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No specific products requested. Open matching department.'**
  String get posCorporateDetailsNoProducts;

  /// No description provided for @posCorporateDetailsQty.
  ///
  /// In en, this message translates to:
  /// **'Qty: {qty}'**
  String posCorporateDetailsQty(String qty);

  /// No description provided for @posCorporateDetailsProductId.
  ///
  /// In en, this message translates to:
  /// **'Product ID: {id}'**
  String posCorporateDetailsProductId(String id);

  /// No description provided for @posCorporateApproveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to approve booking'**
  String get posCorporateApproveError;

  /// No description provided for @posCorporateRejectSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking Rejected. Portal updated.'**
  String get posCorporateRejectSuccess;

  /// No description provided for @posCorporateRejectError.
  ///
  /// In en, this message translates to:
  /// **'Failed to reject booking'**
  String get posCorporateRejectError;

  /// No description provided for @posCorporateNoMatchingOrder.
  ///
  /// In en, this message translates to:
  /// **'No matching order found for this booking yet. Please refresh and try again.'**
  String get posCorporateNoMatchingOrder;

  /// No description provided for @posCorporateStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get posCorporateStatusCancelled;

  /// No description provided for @posCorporateStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get posCorporateStatusRejected;

  /// No description provided for @posCorporateStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get posCorporateStatusPending;

  /// No description provided for @posCorporateStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get posCorporateStatusApproved;

  /// No description provided for @posCorporateStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get posCorporateStatusInProgress;

  /// No description provided for @posCorporateStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get posCorporateStatusCompleted;

  /// No description provided for @posCorporateStatusWaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting Approval'**
  String get posCorporateStatusWaitingApproval;

  /// No description provided for @posBroadcastActionReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get posBroadcastActionReject;

  /// No description provided for @ownerCommonSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get ownerCommonSearchHint;

  /// No description provided for @ownerBottomHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get ownerBottomHome;

  /// No description provided for @ownerBottomReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get ownerBottomReports;

  /// No description provided for @ownerBottomBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get ownerBottomBilling;

  /// No description provided for @ownerBottomProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get ownerBottomProfile;

  /// No description provided for @ownerDashboardRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'WORKSHOP OWNER'**
  String get ownerDashboardRoleLabel;

  /// No description provided for @ownerMonthlySales.
  ///
  /// In en, this message translates to:
  /// **'Monthly Sales'**
  String get ownerMonthlySales;

  /// No description provided for @ownerCurrencySar.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get ownerCurrencySar;

  /// No description provided for @ownerCurrencyAmount.
  ///
  /// In en, this message translates to:
  /// **'{currency} {amount}'**
  String ownerCurrencyAmount(String currency, String amount);

  /// No description provided for @pettyCashQueueCashierExpense.
  ///
  /// In en, this message translates to:
  /// **'CASHIER EXPENSE'**
  String get pettyCashQueueCashierExpense;

  /// No description provided for @pettyCashQueueFundRequest.
  ///
  /// In en, this message translates to:
  /// **'FUND REQUEST'**
  String get pettyCashQueueFundRequest;

  /// No description provided for @pettyCashRequestLabel.
  ///
  /// In en, this message translates to:
  /// **'Petty cash request'**
  String get pettyCashRequestLabel;

  /// No description provided for @pettyCashApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get pettyCashApprove;

  /// No description provided for @pettyCashReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get pettyCashReject;

  /// No description provided for @pettyCashConfirmReject.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reject'**
  String get pettyCashConfirmReject;

  /// No description provided for @pettyCashRejectRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Request'**
  String get pettyCashRejectRequestTitle;

  /// No description provided for @pettyCashRejectRequestBody.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason for rejection.'**
  String get pettyCashRejectRequestBody;

  /// No description provided for @pettyCashRejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Budget not approved'**
  String get pettyCashRejectReasonHint;

  /// No description provided for @pettyCashRejectReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a rejection reason'**
  String get pettyCashRejectReasonRequired;

  /// No description provided for @pettyCashRequestApprovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request approved successfully'**
  String get pettyCashRequestApprovedSuccess;

  /// No description provided for @pettyCashRequestApproveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to approve request'**
  String get pettyCashRequestApproveFailed;

  /// No description provided for @pettyCashRequestRejectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request rejected successfully'**
  String get pettyCashRequestRejectedSuccess;

  /// No description provided for @pettyCashRequestRejectFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reject request'**
  String get pettyCashRequestRejectFailed;

  /// No description provided for @pettyCashStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pettyCashStatusPending;

  /// No description provided for @pettyCashStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'APPROVED'**
  String get pettyCashStatusApproved;

  /// No description provided for @pettyCashStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get pettyCashStatusRejected;

  /// No description provided for @pettyCashStatusFallback.
  ///
  /// In en, this message translates to:
  /// **'{status}'**
  String pettyCashStatusFallback(String status);

  /// No description provided for @posLoginAppName.
  ///
  /// In en, this message translates to:
  /// **'POS System'**
  String get posLoginAppName;

  /// No description provided for @posLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get posLoginTitle;

  /// No description provided for @posLoginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get posLoginEmail;

  /// No description provided for @posLoginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get posLoginEmailHint;

  /// No description provided for @posLoginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get posLoginEmailRequired;

  /// No description provided for @posLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get posLoginPassword;

  /// No description provided for @posLoginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get posLoginPasswordHint;

  /// No description provided for @posLoginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get posLoginPasswordRequired;

  /// No description provided for @posLoginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get posLoginForgotPassword;

  /// No description provided for @posLoginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get posLoginSignIn;

  /// No description provided for @posLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get posLoginSuccess;

  /// No description provided for @posLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get posLoginFailed;

  /// No description provided for @posLoginResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get posLoginResetPasswordTitle;

  /// No description provided for @posLoginResetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or mobile number and we\'ll send you a reset link.'**
  String get posLoginResetPasswordSubtitle;

  /// No description provided for @posLoginResetPasswordEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get posLoginResetPasswordEmailLabel;

  /// No description provided for @posLoginResetPasswordEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get posLoginResetPasswordEmailHint;

  /// No description provided for @posLoginResetPasswordSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get posLoginResetPasswordSendButton;

  /// No description provided for @posLoginResetPasswordSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent! Check your inbox.'**
  String get posLoginResetPasswordSentSuccess;

  /// No description provided for @posLoginPreviousShiftAutoClosed.
  ///
  /// In en, this message translates to:
  /// **'Previous shift was automatically closed. New shift started.'**
  String get posLoginPreviousShiftAutoClosed;

  /// No description provided for @posLoginSessionExpiredError.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get posLoginSessionExpiredError;

  /// No description provided for @posYourJobsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Jobs'**
  String get posYourJobsTitle;

  /// No description provided for @posYourJobsNoDepartments.
  ///
  /// In en, this message translates to:
  /// **'No departments selected.'**
  String get posYourJobsNoDepartments;

  /// No description provided for @posYourJobsDeptInvoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Department-wise Invoice'**
  String get posYourJobsDeptInvoiceTitle;

  /// No description provided for @posYourJobsItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String posYourJobsItems(int count);

  /// No description provided for @posYourJobsGrandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get posYourJobsGrandTotal;

  /// No description provided for @posYourJobsSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get posYourJobsSaveDraft;

  /// No description provided for @posYourJobsPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get posYourJobsPlaceOrder;

  /// No description provided for @posYourJobsAssignTechnicians.
  ///
  /// In en, this message translates to:
  /// **'Assign Technicians'**
  String get posYourJobsAssignTechnicians;

  /// No description provided for @posYourJobsAddInventory.
  ///
  /// In en, this message translates to:
  /// **'Add Inventory'**
  String get posYourJobsAddInventory;

  /// No description provided for @posYourJobsAmountSar.
  ///
  /// In en, this message translates to:
  /// **'SAR {amount}'**
  String posYourJobsAmountSar(String amount);

  /// No description provided for @posInvSalesTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory Sales'**
  String get posInvSalesTitle;

  /// No description provided for @posInvSalesRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get posInvSalesRefreshTooltip;

  /// No description provided for @posInvSalesPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get posInvSalesPeriodLabel;

  /// No description provided for @posInvSalesPresetToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get posInvSalesPresetToday;

  /// No description provided for @posInvSalesPresetYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get posInvSalesPresetYesterday;

  /// No description provided for @posInvSalesPresetLast7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get posInvSalesPresetLast7;

  /// No description provided for @posInvSalesPresetLast30.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get posInvSalesPresetLast30;

  /// No description provided for @posInvSalesPresetThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get posInvSalesPresetThisMonth;

  /// No description provided for @posInvSalesPresetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get posInvSalesPresetCustom;

  /// No description provided for @posInvSalesFromLabel.
  ///
  /// In en, this message translates to:
  /// **'From (y-MM-dd)'**
  String get posInvSalesFromLabel;

  /// No description provided for @posInvSalesToLabel.
  ///
  /// In en, this message translates to:
  /// **'To (y-MM-dd)'**
  String get posInvSalesToLabel;

  /// No description provided for @posInvSalesLoadButton.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get posInvSalesLoadButton;

  /// No description provided for @posInvSalesLoadingButton.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get posInvSalesLoadingButton;

  /// No description provided for @posInvSalesStatTotalUnits.
  ///
  /// In en, this message translates to:
  /// **'Total units sold'**
  String get posInvSalesStatTotalUnits;

  /// No description provided for @posInvSalesStatUniqueProducts.
  ///
  /// In en, this message translates to:
  /// **'Unique products'**
  String get posInvSalesStatUniqueProducts;

  /// No description provided for @posInvSalesStatDaysActive.
  ///
  /// In en, this message translates to:
  /// **'Days with activity'**
  String get posInvSalesStatDaysActive;

  /// No description provided for @posInvSalesDismissTooltip.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get posInvSalesDismissTooltip;

  /// No description provided for @posInvSalesNoSalesTitle.
  ///
  /// In en, this message translates to:
  /// **'No sales in this period'**
  String get posInvSalesNoSalesTitle;

  /// No description provided for @posInvSalesNoSalesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'API returned successfully with no matching lines (200 + empty list).'**
  String get posInvSalesNoSalesSubtitle;

  /// No description provided for @posInvSalesRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get posInvSalesRetry;

  /// No description provided for @posInvSalesColProduct.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT'**
  String get posInvSalesColProduct;

  /// No description provided for @posInvSalesColSku.
  ///
  /// In en, this message translates to:
  /// **'SKU / CODE'**
  String get posInvSalesColSku;

  /// No description provided for @posInvSalesColQty.
  ///
  /// In en, this message translates to:
  /// **'SOLD QTY'**
  String get posInvSalesColQty;

  /// No description provided for @posInvSalesDayLines.
  ///
  /// In en, this message translates to:
  /// **'{count} line'**
  String posInvSalesDayLines(int count);

  /// No description provided for @posInvSalesDayLinesPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} lines'**
  String posInvSalesDayLinesPlural(int count);

  /// No description provided for @posInvSalesDaySummary.
  ///
  /// In en, this message translates to:
  /// **'{lines} · {qty} units'**
  String posInvSalesDaySummary(String lines, String qty);

  /// No description provided for @posInvSalesSessionExpiredError.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get posInvSalesSessionExpiredError;

  /// No description provided for @posInvSalesErrStartBeforeEnd.
  ///
  /// In en, this message translates to:
  /// **'Start date must be on or before end date.'**
  String get posInvSalesErrStartBeforeEnd;

  /// No description provided for @posInvSalesErrRangeExceeded.
  ///
  /// In en, this message translates to:
  /// **'Date range cannot exceed {days} days.'**
  String posInvSalesErrRangeExceeded(int days);

  /// No description provided for @moreMenuPettyCash.
  ///
  /// In en, this message translates to:
  /// **'Petty Cash'**
  String get moreMenuPettyCash;

  /// No description provided for @moreMenuPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Promo Code'**
  String get moreMenuPromoCode;

  /// No description provided for @moreMenuStoreClosing.
  ///
  /// In en, this message translates to:
  /// **'Store Closing'**
  String get moreMenuStoreClosing;

  /// No description provided for @moreMenuSalesReturn.
  ///
  /// In en, this message translates to:
  /// **'Sales Return'**
  String get moreMenuSalesReturn;

  /// No description provided for @posOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get posOrdersTitle;

  /// No description provided for @posOrdersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search orders...'**
  String get posOrdersSearchHint;

  /// No description provided for @posOrdersTabletSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search plate, name, ID...'**
  String get posOrdersTabletSearchHint;

  /// No description provided for @posOrdersTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get posOrdersTabAll;

  /// No description provided for @posOrdersTabPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get posOrdersTabPending;

  /// No description provided for @posOrdersTabCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get posOrdersTabCompleted;

  /// No description provided for @posOrdersNoOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get posOrdersNoOrdersFound;

  /// No description provided for @posOrdersNoPendingOrders.
  ///
  /// In en, this message translates to:
  /// **'No pending orders found'**
  String get posOrdersNoPendingOrders;

  /// No description provided for @posOrdersNoCompletedOrders.
  ///
  /// In en, this message translates to:
  /// **'No completed orders found'**
  String get posOrdersNoCompletedOrders;

  /// No description provided for @posOrdersNewOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get posOrdersNewOrder;

  /// No description provided for @posOrdersNoOrderSelected.
  ///
  /// In en, this message translates to:
  /// **'No Order Selected'**
  String get posOrdersNoOrderSelected;

  /// No description provided for @posOrdersSelectFromList.
  ///
  /// In en, this message translates to:
  /// **'Select an order from the list on the left to view details'**
  String get posOrdersSelectFromList;

  /// No description provided for @posOrdersAddDepartment.
  ///
  /// In en, this message translates to:
  /// **'ADD DEPARTMENT'**
  String get posOrdersAddDepartment;

  /// No description provided for @posOrdersAddCustomerDetails.
  ///
  /// In en, this message translates to:
  /// **'Add customer details'**
  String get posOrdersAddCustomerDetails;

  /// No description provided for @posOrdersSelectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select payment method'**
  String get posOrdersSelectPaymentMethod;

  /// No description provided for @posOrdersCustomerDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Customer details saved'**
  String get posOrdersCustomerDetailsSaved;

  /// No description provided for @posOrdersPaymentMethodSaved.
  ///
  /// In en, this message translates to:
  /// **'Payment method saved'**
  String get posOrdersPaymentMethodSaved;

  /// No description provided for @posOrdersStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get posOrdersStatusRejected;

  /// No description provided for @posOrdersStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get posOrdersStatusCancelled;

  /// No description provided for @posOrdersStatusComplete.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE'**
  String get posOrdersStatusComplete;

  /// No description provided for @posOrdersStatusEdited.
  ///
  /// In en, this message translates to:
  /// **'EDITED'**
  String get posOrdersStatusEdited;

  /// No description provided for @posOrdersStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS'**
  String get posOrdersStatusInProgress;

  /// No description provided for @posOrdersStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get posOrdersStatusPending;

  /// No description provided for @posOrdersStatusUnapproved.
  ///
  /// In en, this message translates to:
  /// **'UNAPPROVED'**
  String get posOrdersStatusUnapproved;

  /// No description provided for @posOrdersStatusWaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'WAITING APPROVAL'**
  String get posOrdersStatusWaitingApproval;

  /// No description provided for @posOrdersStatusCorpApproved.
  ///
  /// In en, this message translates to:
  /// **'CORP APPROVED'**
  String get posOrdersStatusCorpApproved;

  /// No description provided for @posOrdersAssignTechnicians.
  ///
  /// In en, this message translates to:
  /// **'Assign Technicians'**
  String get posOrdersAssignTechnicians;

  /// No description provided for @posOrdersCancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get posOrdersCancelBtn;

  /// No description provided for @posOrdersMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get posOrdersMarkComplete;

  /// No description provided for @posOrdersDeleteJob.
  ///
  /// In en, this message translates to:
  /// **'Delete Job'**
  String get posOrdersDeleteJob;

  /// No description provided for @posOrdersEditBtn.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get posOrdersEditBtn;

  /// No description provided for @posOrdersCancelledBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get posOrdersCancelledBtn;

  /// No description provided for @posOrdersProductsServices.
  ///
  /// In en, this message translates to:
  /// **'Products & Services'**
  String get posOrdersProductsServices;

  /// No description provided for @posOrdersSendForApproval.
  ///
  /// In en, this message translates to:
  /// **'Send for Approval'**
  String get posOrdersSendForApproval;

  /// No description provided for @posOrdersGenerateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Generate Invoice'**
  String get posOrdersGenerateInvoice;

  /// No description provided for @posOrdersOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'ORDER SUMMARY'**
  String get posOrdersOrderSummary;

  /// No description provided for @posOrdersOrderPromo.
  ///
  /// In en, this message translates to:
  /// **'ORDER PROMO'**
  String get posOrdersOrderPromo;

  /// No description provided for @posOrdersGrandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand total'**
  String get posOrdersGrandTotal;

  /// No description provided for @posOrdersNoTechniciansAssigned.
  ///
  /// In en, this message translates to:
  /// **'No technicians assigned'**
  String get posOrdersNoTechniciansAssigned;

  /// No description provided for @posOrdersNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No products or services'**
  String get posOrdersNoProducts;

  /// No description provided for @posOrdersDeptPromo.
  ///
  /// In en, this message translates to:
  /// **'Dept promo'**
  String get posOrdersDeptPromo;

  /// No description provided for @posOrdersDeptDiscount.
  ///
  /// In en, this message translates to:
  /// **'Dept discount'**
  String get posOrdersDeptDiscount;

  /// No description provided for @posOrdersOrderDiscount.
  ///
  /// In en, this message translates to:
  /// **'Order discount'**
  String get posOrdersOrderDiscount;

  /// No description provided for @posOrdersLineDiscount.
  ///
  /// In en, this message translates to:
  /// **'Line discount'**
  String get posOrdersLineDiscount;

  /// No description provided for @posOrdersTotalBeforeVat.
  ///
  /// In en, this message translates to:
  /// **'Total before VAT'**
  String get posOrdersTotalBeforeVat;

  /// No description provided for @posOrdersNoPlate.
  ///
  /// In en, this message translates to:
  /// **'No Plate'**
  String get posOrdersNoPlate;

  /// No description provided for @posOrdersSplitPayment.
  ///
  /// In en, this message translates to:
  /// **'Split Payment'**
  String get posOrdersSplitPayment;

  /// No description provided for @posOrdersPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get posOrdersPayment;

  /// No description provided for @posOrdersInvoiceTotal.
  ///
  /// In en, this message translates to:
  /// **'Invoice Total'**
  String get posOrdersInvoiceTotal;

  /// No description provided for @posOrdersConfirmAmounts.
  ///
  /// In en, this message translates to:
  /// **'Confirm amounts'**
  String get posOrdersConfirmAmounts;

  /// No description provided for @posOrdersAmountSar.
  ///
  /// In en, this message translates to:
  /// **'Amount (SAR)'**
  String get posOrdersAmountSar;

  /// No description provided for @posOrdersCancelDialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get posOrdersCancelDialog;

  /// No description provided for @posOrdersNoDepartmentsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No departments available to add.'**
  String get posOrdersNoDepartmentsAvailable;

  /// No description provided for @posOrdersJobIdMissing.
  ///
  /// In en, this message translates to:
  /// **'Job ID missing.'**
  String get posOrdersJobIdMissing;

  /// No description provided for @posOrdersJobNoLineItems.
  ///
  /// In en, this message translates to:
  /// **'This job has no line items.'**
  String get posOrdersJobNoLineItems;

  /// No description provided for @posOrdersTechnicianRequired.
  ///
  /// In en, this message translates to:
  /// **'Technician assignment is required.'**
  String get posOrdersTechnicianRequired;

  /// No description provided for @posOrdersJobNotReadyForInvoice.
  ///
  /// In en, this message translates to:
  /// **'Order is not ready for invoicing.'**
  String get posOrdersJobNotReadyForInvoice;

  /// No description provided for @posOrdersSelectCustomerAndPayment.
  ///
  /// In en, this message translates to:
  /// **'Select customer type and payment method first.'**
  String get posOrdersSelectCustomerAndPayment;

  /// No description provided for @posOrdersDeleteJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Job'**
  String get posOrdersDeleteJobTitle;

  /// No description provided for @posOrdersNoBtn.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get posOrdersNoBtn;

  /// No description provided for @posOrdersYesDeleteBtn.
  ///
  /// In en, this message translates to:
  /// **'YES, DELETE'**
  String get posOrdersYesDeleteBtn;

  /// No description provided for @posReviewFinalReview.
  ///
  /// In en, this message translates to:
  /// **'Final Review'**
  String get posReviewFinalReview;

  /// No description provided for @posReviewInvoiceReady.
  ///
  /// In en, this message translates to:
  /// **'Invoice Ready'**
  String get posReviewInvoiceReady;

  /// No description provided for @posReviewBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get posReviewBilling;

  /// No description provided for @posReviewVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get posReviewVehicle;

  /// No description provided for @posReviewInvoiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Invoice details'**
  String get posReviewInvoiceDetails;

  /// No description provided for @posReviewCustomerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer details'**
  String get posReviewCustomerDetails;

  /// No description provided for @posReviewConfirmBillingAndVehicle.
  ///
  /// In en, this message translates to:
  /// **'Confirm billing contact and vehicle before creating the invoice.'**
  String get posReviewConfirmBillingAndVehicle;

  /// No description provided for @posReviewConfirmBillingOnly.
  ///
  /// In en, this message translates to:
  /// **'Confirm billing contact before creating the invoice.'**
  String get posReviewConfirmBillingOnly;

  /// No description provided for @posReviewCustomerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get posReviewCustomerNameLabel;

  /// No description provided for @posReviewMobileLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get posReviewMobileLabel;

  /// No description provided for @posReviewVatLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get posReviewVatLabel;

  /// No description provided for @posReviewPlateNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Plate number'**
  String get posReviewPlateNumberLabel;

  /// No description provided for @posReviewOdometerLabel.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get posReviewOdometerLabel;

  /// No description provided for @posReviewMakeLabel.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get posReviewMakeLabel;

  /// No description provided for @posReviewModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get posReviewModelLabel;

  /// No description provided for @posReviewYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get posReviewYearLabel;

  /// No description provided for @posReviewVinLabel.
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get posReviewVinLabel;

  /// No description provided for @posReviewRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get posReviewRequiredError;

  /// No description provided for @posReviewPlateRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Plate is required'**
  String get posReviewPlateRequiredError;

  /// No description provided for @posReviewInvalidYearError.
  ///
  /// In en, this message translates to:
  /// **'Invalid year'**
  String get posReviewInvalidYearError;

  /// No description provided for @posReviewCancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get posReviewCancelBtn;

  /// No description provided for @posReviewContinueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get posReviewContinueBtn;

  /// No description provided for @posReviewCorporateCustomerQuestion.
  ///
  /// In en, this message translates to:
  /// **'Corporate Customer?'**
  String get posReviewCorporateCustomerQuestion;

  /// No description provided for @posReviewIsCorporateCustomer.
  ///
  /// In en, this message translates to:
  /// **'Is this a corporate customer?'**
  String get posReviewIsCorporateCustomer;

  /// No description provided for @posReviewYesCorporate.
  ///
  /// In en, this message translates to:
  /// **'Yes — Corporate'**
  String get posReviewYesCorporate;

  /// No description provided for @posReviewNoIndividual.
  ///
  /// In en, this message translates to:
  /// **'No — Individual'**
  String get posReviewNoIndividual;

  /// No description provided for @posReviewPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method (Select multiple if splitting)'**
  String get posReviewPaymentMethod;

  /// No description provided for @posReviewPaymentMethodCorporate.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get posReviewPaymentMethodCorporate;

  /// No description provided for @posReviewCompleteAndGenerateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Complete Order & Generate Invoice'**
  String get posReviewCompleteAndGenerateInvoice;

  /// No description provided for @posReviewInvoiceGeneratedLocked.
  ///
  /// In en, this message translates to:
  /// **'Invoice Generated & Locked'**
  String get posReviewInvoiceGeneratedLocked;

  /// No description provided for @posReviewNoFurtherEdits.
  ///
  /// In en, this message translates to:
  /// **'No further edits allowed'**
  String get posReviewNoFurtherEdits;

  /// No description provided for @posReviewCommissionsCredited.
  ///
  /// In en, this message translates to:
  /// **'Commissions Credited'**
  String get posReviewCommissionsCredited;

  /// No description provided for @posReviewPrintInvoice.
  ///
  /// In en, this message translates to:
  /// **'Print Invoice & Receipt'**
  String get posReviewPrintInvoice;

  /// No description provided for @posReviewCommissionsNote.
  ///
  /// In en, this message translates to:
  /// **'Commissions have been credited to technician accounts.'**
  String get posReviewCommissionsNote;

  /// No description provided for @posReviewOrderNo.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String posReviewOrderNo(Object id);

  /// No description provided for @posReviewSplitPayment.
  ///
  /// In en, this message translates to:
  /// **'Split Payment'**
  String get posReviewSplitPayment;

  /// No description provided for @posReviewInvoiceTotal.
  ///
  /// In en, this message translates to:
  /// **'Invoice Total'**
  String get posReviewInvoiceTotal;

  /// No description provided for @posReviewConfirmAmounts.
  ///
  /// In en, this message translates to:
  /// **'Confirm amounts'**
  String get posReviewConfirmAmounts;

  /// No description provided for @posReviewAmountSar.
  ///
  /// In en, this message translates to:
  /// **'Amount (SAR)'**
  String get posReviewAmountSar;

  /// No description provided for @posReviewCancelDialogBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get posReviewCancelDialogBtn;

  /// No description provided for @posReviewEmployeesPayment.
  ///
  /// In en, this message translates to:
  /// **'Employees (payment)'**
  String get posReviewEmployeesPayment;

  /// No description provided for @posReviewSelectEmployee.
  ///
  /// In en, this message translates to:
  /// **'Select employee'**
  String get posReviewSelectEmployee;

  /// No description provided for @posReviewEmployeeInstructions.
  ///
  /// In en, this message translates to:
  /// **'One employee for the Employees payment line. Tap the selected card again to clear.'**
  String get posReviewEmployeeInstructions;

  /// No description provided for @posReviewCouldNotLoadEmployees.
  ///
  /// In en, this message translates to:
  /// **'Could not load branch employees.'**
  String get posReviewCouldNotLoadEmployees;

  /// No description provided for @posReviewRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get posReviewRetry;

  /// No description provided for @posReviewNoBranchEmployees.
  ///
  /// In en, this message translates to:
  /// **'No branch employees listed.'**
  String get posReviewNoBranchEmployees;

  /// No description provided for @posReviewGrossAmountExclVat.
  ///
  /// In en, this message translates to:
  /// **'Gross Amount (Excl. VAT)'**
  String get posReviewGrossAmountExclVat;

  /// No description provided for @posReviewItemDiscounts.
  ///
  /// In en, this message translates to:
  /// **'Item Discounts'**
  String get posReviewItemDiscounts;

  /// No description provided for @posReviewInvoiceDiscount.
  ///
  /// In en, this message translates to:
  /// **'Invoice Discount'**
  String get posReviewInvoiceDiscount;

  /// No description provided for @posReviewPromoDiscount.
  ///
  /// In en, this message translates to:
  /// **'Promo Discount ({code})'**
  String posReviewPromoDiscount(Object code);

  /// No description provided for @posReviewPromoDiscountNoCode.
  ///
  /// In en, this message translates to:
  /// **'Promo Discount'**
  String get posReviewPromoDiscountNoCode;

  /// No description provided for @posReviewPriceAfterDiscount.
  ///
  /// In en, this message translates to:
  /// **'Price after discount'**
  String get posReviewPriceAfterDiscount;

  /// No description provided for @posReviewPriceAfterPromo.
  ///
  /// In en, this message translates to:
  /// **'Price after promo'**
  String get posReviewPriceAfterPromo;

  /// No description provided for @posReviewDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get posReviewDiscount;

  /// No description provided for @posReviewTaxPct.
  ///
  /// In en, this message translates to:
  /// **'Tax ({pct}%)'**
  String posReviewTaxPct(Object pct);

  /// No description provided for @posReviewTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get posReviewTotalAmount;

  /// No description provided for @posReviewNoDeptData.
  ///
  /// In en, this message translates to:
  /// **'No departmental data found.'**
  String get posReviewNoDeptData;

  /// No description provided for @posReviewDepartmentCol.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get posReviewDepartmentCol;

  /// No description provided for @posReviewJobIdCol.
  ///
  /// In en, this message translates to:
  /// **'Job ID'**
  String get posReviewJobIdCol;

  /// No description provided for @posReviewStatusCol.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get posReviewStatusCol;

  /// No description provided for @posReviewProductServiceCol.
  ///
  /// In en, this message translates to:
  /// **'Product / Service'**
  String get posReviewProductServiceCol;

  /// No description provided for @posReviewQtyCol.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get posReviewQtyCol;

  /// No description provided for @posReviewAmountSarCol.
  ///
  /// In en, this message translates to:
  /// **'Amount (SAR)'**
  String get posReviewAmountSarCol;

  /// No description provided for @posReviewNoLineItems.
  ///
  /// In en, this message translates to:
  /// **'No line items'**
  String get posReviewNoLineItems;

  /// No description provided for @posReviewGrossExclVat.
  ///
  /// In en, this message translates to:
  /// **'Gross (Excl. VAT)'**
  String get posReviewGrossExclVat;

  /// No description provided for @posReviewItemLineDiscounts.
  ///
  /// In en, this message translates to:
  /// **'Item / line discounts'**
  String get posReviewItemLineDiscounts;

  /// No description provided for @posReviewVatPct.
  ///
  /// In en, this message translates to:
  /// **'VAT ({pct}%)'**
  String posReviewVatPct(Object pct);

  /// No description provided for @posReviewDepartmentTotal.
  ///
  /// In en, this message translates to:
  /// **'Department total'**
  String get posReviewDepartmentTotal;

  /// No description provided for @posReviewOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'ORDER SUMMARY'**
  String get posReviewOrderSummary;

  /// No description provided for @posReviewTotalTaxable.
  ///
  /// In en, this message translates to:
  /// **'Total Taxable Amount'**
  String get posReviewTotalTaxable;

  /// No description provided for @posReviewVat15.
  ///
  /// In en, this message translates to:
  /// **'VAT (15%)'**
  String get posReviewVat15;

  /// No description provided for @posReviewLineNetNote.
  ///
  /// In en, this message translates to:
  /// **'Line totals are net of item-level discounts.'**
  String get posReviewLineNetNote;

  /// No description provided for @posReviewInvoicePromoNote.
  ///
  /// In en, this message translates to:
  /// **'Invoice and promo discounts apply to the taxable subtotal.'**
  String get posReviewInvoicePromoNote;

  /// No description provided for @posReviewConfirmAmountsNote.
  ///
  /// In en, this message translates to:
  /// **'Confirm all amounts match the job before generating the invoice.'**
  String get posReviewConfirmAmountsNote;

  /// No description provided for @posReviewAssignedTechnicians.
  ///
  /// In en, this message translates to:
  /// **'ASSIGNED TECHNICIANS'**
  String get posReviewAssignedTechnicians;

  /// No description provided for @posReviewJobHash.
  ///
  /// In en, this message translates to:
  /// **'Job #{id}'**
  String posReviewJobHash(Object id);

  /// No description provided for @posReviewNoTechAssigned.
  ///
  /// In en, this message translates to:
  /// **'No technician assigned'**
  String get posReviewNoTechAssigned;

  /// No description provided for @posReviewCommissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Commission: {amount}'**
  String posReviewCommissionLabel(Object amount);

  /// No description provided for @posReviewTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get posReviewTotal;

  /// No description provided for @posReviewDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get posReviewDone;

  /// No description provided for @posReviewCorporateMustBeApproved.
  ///
  /// In en, this message translates to:
  /// **'Corporate order must be approved before invoicing.'**
  String get posReviewCorporateMustBeApproved;

  /// No description provided for @posReviewOrderNotReadyForInvoicing.
  ///
  /// In en, this message translates to:
  /// **'Order is not ready for invoicing.'**
  String get posReviewOrderNotReadyForInvoicing;

  /// No description provided for @posReviewIndicateCorporate.
  ///
  /// In en, this message translates to:
  /// **'Please indicate if this is a corporate customer.'**
  String get posReviewIndicateCorporate;

  /// No description provided for @posReviewSelectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Please select a payment method.'**
  String get posReviewSelectPaymentMethod;

  /// No description provided for @posReviewSelectAtLeastOnePayment.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one payment method.'**
  String get posReviewSelectAtLeastOnePayment;

  /// No description provided for @posReviewSelectOneEmployee.
  ///
  /// In en, this message translates to:
  /// **'Select one employee for the Employees payment.'**
  String get posReviewSelectOneEmployee;

  /// No description provided for @posReviewSplitAmountsMustEqual.
  ///
  /// In en, this message translates to:
  /// **'Split amounts must equal the total ({total} SAR). Currently: {current} SAR.'**
  String posReviewSplitAmountsMustEqual(Object current, Object total);

  /// No description provided for @posReviewFillRequiredInvoiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the required invoice details.'**
  String get posReviewFillRequiredInvoiceDetails;

  /// No description provided for @posReviewInvoiceNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Invoice could not be loaded.'**
  String get posReviewInvoiceNotLoaded;

  /// No description provided for @posDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get posDetailsTitle;

  /// No description provided for @posDetailsCustomerSection.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get posDetailsCustomerSection;

  /// No description provided for @posDetailsVehicleSection.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get posDetailsVehicleSection;

  /// No description provided for @posDetailsVehicleNo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle no.'**
  String get posDetailsVehicleNo;

  /// No description provided for @posDetailsCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get posDetailsCustomer;

  /// No description provided for @posDetailsMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get posDetailsMobile;

  /// No description provided for @posDetailsVat.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get posDetailsVat;

  /// No description provided for @posDetailsMakeModel.
  ///
  /// In en, this message translates to:
  /// **'Make/Model'**
  String get posDetailsMakeModel;

  /// No description provided for @posDetailsPlate.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get posDetailsPlate;

  /// No description provided for @posDetailsOdometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get posDetailsOdometer;

  /// No description provided for @posDetailsOdometerKm.
  ///
  /// In en, this message translates to:
  /// **'{reading} km'**
  String posDetailsOdometerKm(Object reading);

  /// No description provided for @posDetailsJobsSection.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get posDetailsJobsSection;

  /// No description provided for @posDetailsNoJobsFound.
  ///
  /// In en, this message translates to:
  /// **'No jobs found'**
  String get posDetailsNoJobsFound;

  /// No description provided for @posDetailsJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job {num} • {status}'**
  String posDetailsJobTitle(Object num, Object status);

  /// No description provided for @posDetailsDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get posDetailsDepartment;

  /// No description provided for @posDetailsTechnician.
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get posDetailsTechnician;

  /// No description provided for @posDetailsSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get posDetailsSubtotal;

  /// No description provided for @posDetailsVat15.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get posDetailsVat15;

  /// No description provided for @posDetailsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get posDetailsTotal;

  /// No description provided for @posDetailsItems.
  ///
  /// In en, this message translates to:
  /// **'Items ({count})'**
  String posDetailsItems(Object count);

  /// No description provided for @paymentMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get paymentMethodBankTransfer;

  /// No description provided for @paymentMethodMonthlyBilling.
  ///
  /// In en, this message translates to:
  /// **'Monthly billing'**
  String get paymentMethodMonthlyBilling;

  /// No description provided for @paymentMethodWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get paymentMethodWallet;

  /// No description provided for @paymentMethodTabby.
  ///
  /// In en, this message translates to:
  /// **'Tabby'**
  String get paymentMethodTabby;

  /// No description provided for @paymentMethodTamara.
  ///
  /// In en, this message translates to:
  /// **'Tamara'**
  String get paymentMethodTamara;

  /// No description provided for @paymentMethodEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get paymentMethodEmployees;

  /// No description provided for @suppliersTitle.
  ///
  /// In en, this message translates to:
  /// **'Suppliers & Purchases'**
  String get suppliersTitle;

  /// No description provided for @suppliersTabSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliersTabSuppliers;

  /// No description provided for @suppliersTabPurchaseOrders.
  ///
  /// In en, this message translates to:
  /// **'Purchase Orders'**
  String get suppliersTabPurchaseOrders;

  /// No description provided for @suppliersFabAddSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get suppliersFabAddSupplier;

  /// No description provided for @suppliersFabNewPurchase.
  ///
  /// In en, this message translates to:
  /// **'New Purchase'**
  String get suppliersFabNewPurchase;

  /// No description provided for @suppliersStatSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliersStatSuppliers;

  /// No description provided for @suppliersStatOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get suppliersStatOutstanding;

  /// No description provided for @suppliersStatPendingPos.
  ///
  /// In en, this message translates to:
  /// **'Pending POs'**
  String get suppliersStatPendingPos;

  /// No description provided for @suppliersNoSuppliersFound.
  ///
  /// In en, this message translates to:
  /// **'No suppliers found'**
  String get suppliersNoSuppliersFound;

  /// No description provided for @suppliersInternalBadge.
  ///
  /// In en, this message translates to:
  /// **'INTERNAL'**
  String get suppliersInternalBadge;

  /// No description provided for @suppliersOutstandingLabel.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get suppliersOutstandingLabel;

  /// No description provided for @suppliersAmountSar.
  ///
  /// In en, this message translates to:
  /// **'SAR {amount}'**
  String suppliersAmountSar(String amount);

  /// No description provided for @suppliersAmountCurrency.
  ///
  /// In en, this message translates to:
  /// **'{currency} {amount}'**
  String suppliersAmountCurrency(String currency, String amount);

  /// No description provided for @suppliersUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get suppliersUnknown;

  /// No description provided for @suppliersStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get suppliersStatusPending;

  /// No description provided for @suppliersStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'APPROVED'**
  String get suppliersStatusApproved;

  /// No description provided for @suppliersStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get suppliersStatusRejected;

  /// No description provided for @suppliersPoStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Select Supplier'**
  String get suppliersPoStep1Title;

  /// No description provided for @suppliersPoStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose from your registered suppliers.'**
  String get suppliersPoStep1Subtitle;

  /// No description provided for @suppliersPoStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Add Items'**
  String get suppliersPoStep2Title;

  /// No description provided for @suppliersPoStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Supplier: {name}'**
  String suppliersPoStep2Subtitle(String name);

  /// No description provided for @suppliersPoStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get suppliersPoStep3Title;

  /// No description provided for @suppliersPoStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Review before submitting for approval.'**
  String get suppliersPoStep3Subtitle;

  /// No description provided for @suppliersPoStepSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Supplier'**
  String get suppliersPoStepSelect;

  /// No description provided for @suppliersPoStepAddItems.
  ///
  /// In en, this message translates to:
  /// **'Add Items'**
  String get suppliersPoStepAddItems;

  /// No description provided for @suppliersPoStepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get suppliersPoStepConfirm;

  /// No description provided for @suppliersPoAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get suppliersPoAddItem;

  /// No description provided for @suppliersPoItemProductName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get suppliersPoItemProductName;

  /// No description provided for @suppliersPoItemProductHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Engine Oil'**
  String get suppliersPoItemProductHint;

  /// No description provided for @suppliersPoItemQty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get suppliersPoItemQty;

  /// No description provided for @suppliersPoItemUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get suppliersPoItemUnitPrice;

  /// No description provided for @suppliersPoConfirmSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get suppliersPoConfirmSupplier;

  /// No description provided for @suppliersPoConfirmItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String suppliersPoConfirmItems(int count);

  /// No description provided for @suppliersPoConfirmStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get suppliersPoConfirmStatus;

  /// No description provided for @suppliersPoConfirmStatusValue.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get suppliersPoConfirmStatusValue;

  /// No description provided for @suppliersPoConfirmNote.
  ///
  /// In en, this message translates to:
  /// **'This PO will be submitted for manager approval before stock is updated.'**
  String get suppliersPoConfirmNote;

  /// No description provided for @suppliersPoNavNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get suppliersPoNavNext;

  /// No description provided for @suppliersPoNavSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get suppliersPoNavSubmit;

  /// No description provided for @suppliersPoNavBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get suppliersPoNavBack;

  /// No description provided for @suppliersAddSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Register New Supplier'**
  String get suppliersAddSheetTitle;

  /// No description provided for @suppliersAddSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide details to add a new supplier.'**
  String get suppliersAddSheetSubtitle;

  /// No description provided for @suppliersAddFieldName.
  ///
  /// In en, this message translates to:
  /// **'Supplier Name'**
  String get suppliersAddFieldName;

  /// No description provided for @suppliersAddFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get suppliersAddFieldEmail;

  /// No description provided for @suppliersAddFieldMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get suppliersAddFieldMobile;

  /// No description provided for @suppliersAddFieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get suppliersAddFieldAddress;

  /// No description provided for @suppliersAddFieldOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance'**
  String get suppliersAddFieldOpeningBalance;

  /// No description provided for @suppliersAddFieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get suppliersAddFieldPassword;

  /// No description provided for @suppliersAddSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Supplier'**
  String get suppliersAddSaveButton;

  /// No description provided for @suppliersValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get suppliersValidationRequired;

  /// No description provided for @suppliersCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Supplier Created Successfully'**
  String get suppliersCreateSuccess;

  /// No description provided for @suppliersCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create supplier'**
  String get suppliersCreateError;

  /// No description provided for @suppliersPoValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one item'**
  String get suppliersPoValidationEmpty;

  /// No description provided for @suppliersPoValidationItemDetails.
  ///
  /// In en, this message translates to:
  /// **'Please fill all item details properly'**
  String get suppliersPoValidationItemDetails;

  /// No description provided for @suppliersPoValidationInvalidSupplier.
  ///
  /// In en, this message translates to:
  /// **'Invalid supplier selected'**
  String get suppliersPoValidationInvalidSupplier;

  /// No description provided for @suppliersPoCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchase Order Created Successfully'**
  String get suppliersPoCreateSuccess;

  /// No description provided for @suppliersPoCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create purchase order'**
  String get suppliersPoCreateError;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Workshop Owner'**
  String get settingsRoleLabel;

  /// No description provided for @settingsMultiBranchBadge.
  ///
  /// In en, this message translates to:
  /// **'MULTI-BRANCH ACCESS'**
  String get settingsMultiBranchBadge;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsSectionNotifications;

  /// No description provided for @settingsSectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSectionSecurity;

  /// No description provided for @settingsSectionBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get settingsSectionBusiness;

  /// No description provided for @settingsSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSectionSupport;

  /// No description provided for @settingsTogglePushNotif.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get settingsTogglePushNotif;

  /// No description provided for @settingsTogglePushNotifSub.
  ///
  /// In en, this message translates to:
  /// **'Receive in-app notifications'**
  String get settingsTogglePushNotifSub;

  /// No description provided for @settingsToggleEmailAlerts.
  ///
  /// In en, this message translates to:
  /// **'Email Alerts'**
  String get settingsToggleEmailAlerts;

  /// No description provided for @settingsToggleEmailAlertsSub.
  ///
  /// In en, this message translates to:
  /// **'Get critical alerts via email'**
  String get settingsToggleEmailAlertsSub;

  /// No description provided for @settingsToggleStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Stock Alerts'**
  String get settingsToggleStockAlerts;

  /// No description provided for @settingsToggleStockAlertsSub.
  ///
  /// In en, this message translates to:
  /// **'Notify when stock is critical'**
  String get settingsToggleStockAlertsSub;

  /// No description provided for @settingsToggleLockerAlerts.
  ///
  /// In en, this message translates to:
  /// **'Locker Difference Alerts'**
  String get settingsToggleLockerAlerts;

  /// No description provided for @settingsToggleLockerAlertsSub.
  ///
  /// In en, this message translates to:
  /// **'Notify on EOD locker variance'**
  String get settingsToggleLockerAlertsSub;

  /// No description provided for @settingsToggleBiometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get settingsToggleBiometric;

  /// No description provided for @settingsToggleBiometricSub.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face ID'**
  String get settingsToggleBiometricSub;

  /// No description provided for @settingsNavChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsNavChangePassword;

  /// No description provided for @settingsNavTwoFactor.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get settingsNavTwoFactor;

  /// No description provided for @settingsNavWorkshopProfile.
  ///
  /// In en, this message translates to:
  /// **'Workshop Profile'**
  String get settingsNavWorkshopProfile;

  /// No description provided for @settingsNavBranchMgmt.
  ///
  /// In en, this message translates to:
  /// **'Branch Management'**
  String get settingsNavBranchMgmt;

  /// No description provided for @settingsNavCommissionRules.
  ///
  /// In en, this message translates to:
  /// **'Commission Rules'**
  String get settingsNavCommissionRules;

  /// No description provided for @settingsNavVatSettings.
  ///
  /// In en, this message translates to:
  /// **'VAT Settings'**
  String get settingsNavVatSettings;

  /// No description provided for @settingsNavHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & Documentation'**
  String get settingsNavHelp;

  /// No description provided for @settingsNavContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get settingsNavContactSupport;

  /// No description provided for @settingsNavReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get settingsNavReportIssue;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogoutDialogTitle;

  /// No description provided for @settingsLogoutDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out from your account?'**
  String get settingsLogoutDialogBody;

  /// No description provided for @settingsLogoutDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsLogoutDialogCancel;

  /// No description provided for @settingsLogoutDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogoutDialogConfirm;

  /// No description provided for @settingsVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter Workshop OS • Version 1.0.0'**
  String get settingsVersionLabel;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get settingsLanguageArabic;

  /// No description provided for @posCommonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get posCommonAll;

  /// No description provided for @posCommonProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get posCommonProducts;

  /// No description provided for @posCommonServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get posCommonServices;

  /// No description provided for @posCommonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get posCommonRetry;

  /// No description provided for @posCommonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get posCommonSave;

  /// No description provided for @posCommonSar.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get posCommonSar;

  /// No description provided for @posCommonPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get posCommonPending;

  /// No description provided for @posCommonApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get posCommonApproved;

  /// No description provided for @posCommonRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get posCommonRejected;

  /// No description provided for @posPettyCashTitle.
  ///
  /// In en, this message translates to:
  /// **'Petty Cash'**
  String get posPettyCashTitle;

  /// No description provided for @posPettyCashExpenseTab.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get posPettyCashExpenseTab;

  /// No description provided for @posPettyCashFundTab.
  ///
  /// In en, this message translates to:
  /// **'Fund'**
  String get posPettyCashFundTab;

  /// No description provided for @posPettyCashHistoryTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get posPettyCashHistoryTab;

  /// No description provided for @posPettyCashSecureWallet.
  ///
  /// In en, this message translates to:
  /// **'SECURE WALLET'**
  String get posPettyCashSecureWallet;

  /// No description provided for @posPettyCashAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available Petty Cash'**
  String get posPettyCashAvailable;

  /// No description provided for @posPettyCashLowBalanceMessage.
  ///
  /// In en, this message translates to:
  /// **'Petty cash balance is low. Please request fund.'**
  String get posPettyCashLowBalanceMessage;

  /// No description provided for @posPettyCashRequestFund.
  ///
  /// In en, this message translates to:
  /// **'Request Fund'**
  String get posPettyCashRequestFund;

  /// No description provided for @posPettyCashExpenseDetails.
  ///
  /// In en, this message translates to:
  /// **'Expense Details'**
  String get posPettyCashExpenseDetails;

  /// No description provided for @posPettyCashAmountSar.
  ///
  /// In en, this message translates to:
  /// **'Amount (SAR)'**
  String get posPettyCashAmountSar;

  /// No description provided for @posPettyCashExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense Category'**
  String get posPettyCashExpenseCategory;

  /// No description provided for @posPettyCashEmployeeSalaryAdvance.
  ///
  /// In en, this message translates to:
  /// **'Employee (Salary advance)'**
  String get posPettyCashEmployeeSalaryAdvance;

  /// No description provided for @posPettyCashDescriptionNotes.
  ///
  /// In en, this message translates to:
  /// **'Description / Notes'**
  String get posPettyCashDescriptionNotes;

  /// No description provided for @posPettyCashEnterDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter details...'**
  String get posPettyCashEnterDetailsHint;

  /// No description provided for @posPettyCashProofOfExpense.
  ///
  /// In en, this message translates to:
  /// **'Proof of Expense'**
  String get posPettyCashProofOfExpense;

  /// No description provided for @posPettyCashExpenseSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Expense submitted – pending approval'**
  String get posPettyCashExpenseSubmitted;

  /// No description provided for @posPettyCashSubmitExpense.
  ///
  /// In en, this message translates to:
  /// **'Submit Expense'**
  String get posPettyCashSubmitExpense;

  /// No description provided for @posPettyCashFundRequest.
  ///
  /// In en, this message translates to:
  /// **'Fund Request'**
  String get posPettyCashFundRequest;

  /// No description provided for @posPettyCashRequestedAmountSar.
  ///
  /// In en, this message translates to:
  /// **'Requested Amount (SAR)'**
  String get posPettyCashRequestedAmountSar;

  /// No description provided for @posPettyCashReasonForRequest.
  ///
  /// In en, this message translates to:
  /// **'Reason for Request'**
  String get posPettyCashReasonForRequest;

  /// No description provided for @posPettyCashReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Explain why you need more funds...'**
  String get posPettyCashReasonHint;

  /// No description provided for @posPettyCashFundRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Fund request submitted – pending approval'**
  String get posPettyCashFundRequestSubmitted;

  /// No description provided for @posPettyCashSubmitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get posPettyCashSubmitRequest;

  /// No description provided for @posPettyCashSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get posPettyCashSelectCategory;

  /// No description provided for @posPettyCashNoEmployees.
  ///
  /// In en, this message translates to:
  /// **'No employees on file'**
  String get posPettyCashNoEmployees;

  /// No description provided for @posPettyCashSelectEmployee.
  ///
  /// In en, this message translates to:
  /// **'Select employee'**
  String get posPettyCashSelectEmployee;

  /// No description provided for @posPettyCashSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get posPettyCashSelectDate;

  /// No description provided for @posPettyCashFrom.
  ///
  /// In en, this message translates to:
  /// **'From:'**
  String get posPettyCashFrom;

  /// No description provided for @posPettyCashTo.
  ///
  /// In en, this message translates to:
  /// **'To:'**
  String get posPettyCashTo;

  /// No description provided for @posPettyCashAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get posPettyCashAllCategories;

  /// No description provided for @posPettyCashReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get posPettyCashReset;

  /// No description provided for @posPettyCashHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense & fund history'**
  String get posPettyCashHistoryTitle;

  /// No description provided for @posPettyCashNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No history for this filter.'**
  String get posPettyCashNoHistory;

  /// No description provided for @posPettyCashLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get posPettyCashLoadMore;

  /// No description provided for @posPettyCashEmployeePrefix.
  ///
  /// In en, this message translates to:
  /// **'Employee: {name}'**
  String posPettyCashEmployeePrefix(Object name);

  /// No description provided for @posPettyCashRejectionPrefix.
  ///
  /// In en, this message translates to:
  /// **'Rejection: {reason}'**
  String posPettyCashRejectionPrefix(Object reason);

  /// No description provided for @posPettyCashTapUploadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload receipt'**
  String get posPettyCashTapUploadReceipt;

  /// No description provided for @posPettyCashRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get posPettyCashRequestStatus;

  /// No description provided for @posPettyCashPendingUpper.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get posPettyCashPendingUpper;

  /// No description provided for @posPettyCashRequestedAmount.
  ///
  /// In en, this message translates to:
  /// **'Requested Amount'**
  String get posPettyCashRequestedAmount;

  /// No description provided for @posPettyCashReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get posPettyCashReason;

  /// No description provided for @posPettyCashRequestDate.
  ///
  /// In en, this message translates to:
  /// **'Request Date'**
  String get posPettyCashRequestDate;

  /// No description provided for @posPettyCashPendingReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Your request is currently being reviewed by administration. You will be notified once it is approved.'**
  String get posPettyCashPendingReviewMessage;

  /// No description provided for @posPettyCashSubmitNewRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit New Request'**
  String get posPettyCashSubmitNewRequest;

  /// No description provided for @posPettyCashValidAmountError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get posPettyCashValidAmountError;

  /// No description provided for @posPettyCashSelectCategoryError.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get posPettyCashSelectCategoryError;

  /// No description provided for @posPettyCashSelectEmployeeError.
  ///
  /// In en, this message translates to:
  /// **'Please select an employee for Salary Advances'**
  String get posPettyCashSelectEmployeeError;

  /// No description provided for @posPettyCashSubmitExpenseError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit expense. Check balance or try again.'**
  String get posPettyCashSubmitExpenseError;

  /// No description provided for @posPettyCashReasonError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason'**
  String get posPettyCashReasonError;

  /// No description provided for @posPettyCashSubmitRequestError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit fund request'**
  String get posPettyCashSubmitRequestError;

  /// No description provided for @posPettyCashTokenNotFound.
  ///
  /// In en, this message translates to:
  /// **'Token not found'**
  String get posPettyCashTokenNotFound;

  /// No description provided for @posPettyCashLowBalanceError.
  ///
  /// In en, this message translates to:
  /// **'Low balance - request fund first'**
  String get posPettyCashLowBalanceError;

  /// No description provided for @posProductAddTechnician.
  ///
  /// In en, this message translates to:
  /// **'Add Technician'**
  String get posProductAddTechnician;

  /// No description provided for @posProductAddProducts.
  ///
  /// In en, this message translates to:
  /// **'Add Products'**
  String get posProductAddProducts;

  /// No description provided for @posProductItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String posProductItemsCount(Object count);

  /// No description provided for @posProductGrandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get posProductGrandTotal;

  /// No description provided for @posProductViewInvoice.
  ///
  /// In en, this message translates to:
  /// **'View Invoice'**
  String get posProductViewInvoice;

  /// No description provided for @posProductOrderItems.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get posProductOrderItems;

  /// No description provided for @posProductNoItemsInvoice.
  ///
  /// In en, this message translates to:
  /// **'No items in invoice'**
  String get posProductNoItemsInvoice;

  /// No description provided for @posProductGrossAmountExclVat.
  ///
  /// In en, this message translates to:
  /// **'Gross Amount (Excl. VAT)'**
  String get posProductGrossAmountExclVat;

  /// No description provided for @posProductLineDiscount.
  ///
  /// In en, this message translates to:
  /// **'Line discount'**
  String get posProductLineDiscount;

  /// No description provided for @posProductPriceAfterLineDiscount.
  ///
  /// In en, this message translates to:
  /// **'Price after line discount'**
  String get posProductPriceAfterLineDiscount;

  /// No description provided for @posProductTotalDiscountApplied.
  ///
  /// In en, this message translates to:
  /// **'Total discount applied'**
  String get posProductTotalDiscountApplied;

  /// No description provided for @posProductPriceAfterTotalDiscount.
  ///
  /// In en, this message translates to:
  /// **'Price after total discount'**
  String get posProductPriceAfterTotalDiscount;

  /// No description provided for @posProductAddPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Add Promo Code'**
  String get posProductAddPromoCode;

  /// No description provided for @posProductPromoLabel.
  ///
  /// In en, this message translates to:
  /// **'Promo: {code}'**
  String posProductPromoLabel(Object code);

  /// No description provided for @posProductPromoDiscount.
  ///
  /// In en, this message translates to:
  /// **'Promo discount'**
  String get posProductPromoDiscount;

  /// No description provided for @posProductPriceAfterPromo.
  ///
  /// In en, this message translates to:
  /// **'Price after promo'**
  String get posProductPriceAfterPromo;

  /// No description provided for @posProductVat15.
  ///
  /// In en, this message translates to:
  /// **'VAT (15%)'**
  String get posProductVat15;

  /// No description provided for @posProductTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get posProductTotal;

  /// No description provided for @posProductTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get posProductTotalAmount;

  /// No description provided for @posProductEmployeesUpper.
  ///
  /// In en, this message translates to:
  /// **'EMPLOYEES'**
  String get posProductEmployeesUpper;

  /// No description provided for @posProductSelectEmployeePayment.
  ///
  /// In en, this message translates to:
  /// **'Select one employee for Employees payment (shown with type). Saves with your order.'**
  String get posProductSelectEmployeePayment;

  /// No description provided for @posProductSelectEmployeePaymentShort.
  ///
  /// In en, this message translates to:
  /// **'Select one employee for Employees payment (with type).'**
  String get posProductSelectEmployeePaymentShort;

  /// No description provided for @posProductNewOrderId.
  ///
  /// In en, this message translates to:
  /// **'#NEW-ORDER'**
  String get posProductNewOrderId;

  /// No description provided for @posProductWalkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in Customer'**
  String get posProductWalkInCustomer;

  /// No description provided for @posProductNoVehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'No Vehicle Details'**
  String get posProductNoVehicleDetails;

  /// No description provided for @posProductNoPhone.
  ///
  /// In en, this message translates to:
  /// **'No Phone'**
  String get posProductNoPhone;

  /// No description provided for @posProductDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get posProductDraft;

  /// No description provided for @posProductNoItemsAdded.
  ///
  /// In en, this message translates to:
  /// **'No items added'**
  String get posProductNoItemsAdded;

  /// No description provided for @posProductPendingAssignment.
  ///
  /// In en, this message translates to:
  /// **'pending assignment'**
  String get posProductPendingAssignment;

  /// No description provided for @posProductCompleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order marked as completed successfully'**
  String get posProductCompleteSuccess;

  /// No description provided for @posProductCompleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete job'**
  String get posProductCompleteError;

  /// No description provided for @posProductMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get posProductMarkComplete;

  /// No description provided for @posProductSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get posProductSaveDraft;

  /// No description provided for @posProductForwardTechnician.
  ///
  /// In en, this message translates to:
  /// **'Forward to Technician'**
  String get posProductForwardTechnician;

  /// No description provided for @posProductSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products & services...'**
  String get posProductSearchHint;

  /// No description provided for @posProductNoSearchMatch.
  ///
  /// In en, this message translates to:
  /// **'No products match your search.'**
  String get posProductNoSearchMatch;

  /// No description provided for @posProductDepartmentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Department not found'**
  String get posProductDepartmentNotFound;

  /// No description provided for @posProductAddDepartment.
  ///
  /// In en, this message translates to:
  /// **'Add Department'**
  String get posProductAddDepartment;

  /// No description provided for @posProductNoServicesFound.
  ///
  /// In en, this message translates to:
  /// **'No services found'**
  String get posProductNoServicesFound;

  /// No description provided for @posProductNoProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get posProductNoProductsFound;

  /// No description provided for @posProductUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit: {unit}'**
  String posProductUnitLabel(Object unit);

  /// No description provided for @posProductDiscountShort.
  ///
  /// In en, this message translates to:
  /// **'Dis.'**
  String get posProductDiscountShort;

  /// No description provided for @posProductTotalDiscount.
  ///
  /// In en, this message translates to:
  /// **'Total discount'**
  String get posProductTotalDiscount;

  /// No description provided for @posProductCouldNotLoadEmployees.
  ///
  /// In en, this message translates to:
  /// **'Could not load employees.'**
  String get posProductCouldNotLoadEmployees;

  /// No description provided for @posProductNoBranchEmployees.
  ///
  /// In en, this message translates to:
  /// **'No branch employees.'**
  String get posProductNoBranchEmployees;

  /// No description provided for @posProductsFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products'**
  String get posProductsFailedLoad;

  /// No description provided for @posProductsBranchLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch: {branch}'**
  String posProductsBranchLabel(Object branch);

  /// No description provided for @posHomeTitleWorkshop.
  ///
  /// In en, this message translates to:
  /// **'Workshop '**
  String get posHomeTitleWorkshop;

  /// No description provided for @posHomeTitlePos.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get posHomeTitlePos;

  /// No description provided for @posHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search by customer number, vehicle number,\nphone number or customer name'**
  String get posHomeSubtitle;

  /// No description provided for @posHomeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search customer no / vehicle / mobile / plate...'**
  String get posHomeSearchHint;

  /// No description provided for @posHomeNewWalkIn.
  ///
  /// In en, this message translates to:
  /// **'New walk-in'**
  String get posHomeNewWalkIn;

  /// No description provided for @posHomeCorporateBooking.
  ///
  /// In en, this message translates to:
  /// **'Corporate booking'**
  String get posHomeCorporateBooking;

  /// No description provided for @posHomeBranchPrefix.
  ///
  /// In en, this message translates to:
  /// **'Branch: {branch}'**
  String posHomeBranchPrefix(String branch);

  /// No description provided for @posHomeRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get posHomeRecentSearches;

  /// No description provided for @posHomeNoVehicle.
  ///
  /// In en, this message translates to:
  /// **'No Vehicle'**
  String get posHomeNoVehicle;

  /// No description provided for @posHomeNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get posHomeNoResults;

  /// No description provided for @posHomeNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different name or number'**
  String get posHomeNoResultsHint;

  /// No description provided for @posDeptSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Depart'**
  String get posDeptSelectTitle;

  /// No description provided for @posDeptAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Department'**
  String get posDeptAddTitle;

  /// No description provided for @posDeptNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No departs found'**
  String get posDeptNoneFound;

  /// No description provided for @posDeptAlreadyOnOrder.
  ///
  /// In en, this message translates to:
  /// **'This department is already on this order.'**
  String get posDeptAlreadyOnOrder;

  /// No description provided for @posDeptSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} departments selected'**
  String posDeptSelectedCount(int count);

  /// No description provided for @posDeptAddToOrder.
  ///
  /// In en, this message translates to:
  /// **'Add to order'**
  String get posDeptAddToOrder;

  /// No description provided for @posDeptOrderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get posDeptOrderPlaced;

  /// No description provided for @posDeptSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Select at least one department to add.'**
  String get posDeptSelectAtLeastOne;

  /// No description provided for @posDeptVehicleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please add vehicle number first (Add Customer)'**
  String get posDeptVehicleRequired;

  /// No description provided for @posDeptChangeDeptTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Department?'**
  String get posDeptChangeDeptTitle;

  /// No description provided for @posDeptChangeDeptBody.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to change your department?'**
  String get posDeptChangeDeptBody;

  /// No description provided for @posDeptChangeDeptRefresh.
  ///
  /// In en, this message translates to:
  /// **'Your invoice data will be refreshed.'**
  String get posDeptChangeDeptRefresh;

  /// No description provided for @posDeptChangeDeptCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get posDeptChangeDeptCancel;

  /// No description provided for @posDeptChangeDeptContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get posDeptChangeDeptContinue;

  /// No description provided for @posDeptRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get posDeptRetry;

  /// No description provided for @posCustomerHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer History'**
  String get posCustomerHistoryTitle;

  /// No description provided for @posCustomerPastOrders.
  ///
  /// In en, this message translates to:
  /// **'Past Orders'**
  String get posCustomerPastOrders;

  /// No description provided for @posCustomerNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No order history found for this customer.'**
  String get posCustomerNoHistory;

  /// No description provided for @posCustomerVat.
  ///
  /// In en, this message translates to:
  /// **'VAT: {vat}'**
  String posCustomerVat(String vat);

  /// No description provided for @posCustomerOrderId.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String posCustomerOrderId(String id);

  /// No description provided for @posCustomerInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice: {no}'**
  String posCustomerInvoice(String no);

  /// No description provided for @posCustomerVin.
  ///
  /// In en, this message translates to:
  /// **'VIN {vin}'**
  String posCustomerVin(String vin);

  /// No description provided for @posCustomerMoreItems.
  ///
  /// In en, this message translates to:
  /// **'+{count} more items'**
  String posCustomerMoreItems(int count);

  /// No description provided for @posCustomerAmountSar.
  ///
  /// In en, this message translates to:
  /// **'SAR {amount}'**
  String posCustomerAmountSar(String amount);

  /// No description provided for @posCustomerTypeRegular.
  ///
  /// In en, this message translates to:
  /// **'REGULAR'**
  String get posCustomerTypeRegular;

  /// No description provided for @posCustomerTypeCorporate.
  ///
  /// In en, this message translates to:
  /// **'CORPORATE'**
  String get posCustomerTypeCorporate;

  /// No description provided for @posProductStockInStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock ({count})'**
  String posProductStockInStock(int count);

  /// No description provided for @posProductStockLow.
  ///
  /// In en, this message translates to:
  /// **'Low ({count})'**
  String posProductStockLow(int count);

  /// No description provided for @posProductStockOut.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get posProductStockOut;

  /// No description provided for @posProductStockService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get posProductStockService;

  /// No description provided for @posOrderStatusInvoiced.
  ///
  /// In en, this message translates to:
  /// **'Invoiced'**
  String get posOrderStatusInvoiced;

  /// No description provided for @posOrderStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get posOrderStatusCompleted;

  /// No description provided for @posOrderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get posOrderStatusPending;

  /// No description provided for @posOrderStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get posOrderStatusWaiting;

  /// No description provided for @posOrderStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get posOrderStatusDraft;

  /// No description provided for @posOrderStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get posOrderStatusInProgress;

  /// No description provided for @posOrderStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get posOrderStatusAccepted;

  /// No description provided for @posSearchHistoryNoVehicle.
  ///
  /// In en, this message translates to:
  /// **'No Vehicle'**
  String get posSearchHistoryNoVehicle;

  /// No description provided for @posSearchHistoryNa.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get posSearchHistoryNa;

  /// No description provided for @posSearchHistoryContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue Order'**
  String get posSearchHistoryContinue;

  /// No description provided for @posSearchHistoryHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get posSearchHistoryHistory;

  /// No description provided for @posSearchHistorySalesReturn.
  ///
  /// In en, this message translates to:
  /// **'Sales Return'**
  String get posSearchHistorySalesReturn;

  /// No description provided for @posNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get posNavHome;

  /// No description provided for @posNavProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get posNavProducts;

  /// No description provided for @posNavOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get posNavOrders;

  /// No description provided for @posNavStoreClosing.
  ///
  /// In en, this message translates to:
  /// **'Store Closing'**
  String get posNavStoreClosing;

  /// No description provided for @posPromoViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Promo Code'**
  String get posPromoViewTitle;

  /// No description provided for @posPromoViewEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply Promo Code'**
  String get posPromoViewEntryTitle;

  /// No description provided for @posPromoViewEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check the validity of a customer provided code.'**
  String get posPromoViewEntrySubtitle;

  /// No description provided for @posPromoViewCheckValidity.
  ///
  /// In en, this message translates to:
  /// **'Check Validity'**
  String get posPromoViewCheckValidity;

  /// No description provided for @posPromoViewAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Promotions'**
  String get posPromoViewAvailableTitle;

  /// No description provided for @posPromoViewNoPromos.
  ///
  /// In en, this message translates to:
  /// **'No promotions available'**
  String get posPromoViewNoPromos;

  /// No description provided for @posPromoViewCheckConditions.
  ///
  /// In en, this message translates to:
  /// **'Check Conditions'**
  String get posPromoViewCheckConditions;

  /// No description provided for @posPromoViewRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove promo'**
  String get posPromoViewRemoveTooltip;

  /// No description provided for @posPromoResultStore.
  ///
  /// In en, this message translates to:
  /// **'Store: {value}'**
  String posPromoResultStore(String value);

  /// No description provided for @posPromoResultProducts.
  ///
  /// In en, this message translates to:
  /// **'Products: {value}'**
  String posPromoResultProducts(String value);

  /// No description provided for @posPromoResultPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period: {value}'**
  String posPromoResultPeriod(String value);

  /// No description provided for @posPromoDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply Promo Code'**
  String get posPromoDialogTitle;

  /// No description provided for @posPromoDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select any promo code below to apply discount instantly.'**
  String get posPromoDialogSubtitle;

  /// No description provided for @posPromoDialogNoCodesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No promo codes available.'**
  String get posPromoDialogNoCodesAvailable;

  /// No description provided for @posPromoDialogOrEnterManually.
  ///
  /// In en, this message translates to:
  /// **'Or enter code manually'**
  String get posPromoDialogOrEnterManually;

  /// No description provided for @posPromoDialogHintText.
  ///
  /// In en, this message translates to:
  /// **'e.g. SAVE10'**
  String get posPromoDialogHintText;

  /// No description provided for @posPromoDialogRemovePromo.
  ///
  /// In en, this message translates to:
  /// **'Remove Promo'**
  String get posPromoDialogRemovePromo;

  /// No description provided for @posPromoDialogValidCode.
  ///
  /// In en, this message translates to:
  /// **'Valid Promo Code'**
  String get posPromoDialogValidCode;

  /// No description provided for @posPromoDialogLabelDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount:'**
  String get posPromoDialogLabelDiscount;

  /// No description provided for @posPromoDialogLabelStore.
  ///
  /// In en, this message translates to:
  /// **'Store:'**
  String get posPromoDialogLabelStore;

  /// No description provided for @posPromoDialogLabelProducts.
  ///
  /// In en, this message translates to:
  /// **'Products:'**
  String get posPromoDialogLabelProducts;

  /// No description provided for @posPromoDialogLabelValidity.
  ///
  /// In en, this message translates to:
  /// **'Validity:'**
  String get posPromoDialogLabelValidity;

  /// No description provided for @posPromoDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get posPromoDialogCancel;

  /// No description provided for @posPromoDialogCheckCode.
  ///
  /// In en, this message translates to:
  /// **'Check Code'**
  String get posPromoDialogCheckCode;

  /// No description provided for @posPromoDialogApplyDiscount.
  ///
  /// In en, this message translates to:
  /// **'Apply Discount'**
  String get posPromoDialogApplyDiscount;

  /// No description provided for @posPromoDiscountPercent.
  ///
  /// In en, this message translates to:
  /// **'{value}% Discount'**
  String posPromoDiscountPercent(String value);

  /// No description provided for @posPromoDiscountSar.
  ///
  /// In en, this message translates to:
  /// **'SAR {value} Discount'**
  String posPromoDiscountSar(String value);

  /// No description provided for @posPromoAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All Branches'**
  String get posPromoAllBranches;

  /// No description provided for @posPromoAllProducts.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get posPromoAllProducts;

  /// No description provided for @posPromoNoExpiry.
  ///
  /// In en, this message translates to:
  /// **'No Expiry'**
  String get posPromoNoExpiry;

  /// No description provided for @posPromoInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid Promo Code'**
  String get posPromoInvalidCode;

  /// No description provided for @posPromoInvalidExpired.
  ///
  /// In en, this message translates to:
  /// **'Invalid or Expired Promo Code'**
  String get posPromoInvalidExpired;

  /// No description provided for @posTechAssignTitle.
  ///
  /// In en, this message translates to:
  /// **'Technician Assignment'**
  String get posTechAssignTitle;

  /// No description provided for @posTechAssignSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search technicians...'**
  String get posTechAssignSearchHint;

  /// No description provided for @posTechAssignShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get posTechAssignShowAll;

  /// No description provided for @posTechAssignOnlineOnly.
  ///
  /// In en, this message translates to:
  /// **'Online only'**
  String get posTechAssignOnlineOnly;

  /// No description provided for @posTechAssignLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading technicians…'**
  String get posTechAssignLoading;

  /// No description provided for @posTechAssignNoResults.
  ///
  /// In en, this message translates to:
  /// **'No technicians found'**
  String get posTechAssignNoResults;

  /// No description provided for @posTechAssignErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String posTechAssignErrorPrefix(String message);

  /// No description provided for @posTechAssignRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get posTechAssignRetry;

  /// No description provided for @posTechAssignStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get posTechAssignStatusOnline;

  /// No description provided for @posTechAssignStatusLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen: {time}'**
  String posTechAssignStatusLastSeen(String time);

  /// No description provided for @posTechAssignSlots.
  ///
  /// In en, this message translates to:
  /// **'Slots: {used}/{total}'**
  String posTechAssignSlots(int used, int total);

  /// No description provided for @posTechAssignBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Broadcast'**
  String get posTechAssignBroadcast;

  /// No description provided for @posTechAssignWait.
  ///
  /// In en, this message translates to:
  /// **'Wait {label}'**
  String posTechAssignWait(String label);

  /// No description provided for @posTechAssignSave.
  ///
  /// In en, this message translates to:
  /// **'Save Technicians'**
  String get posTechAssignSave;

  /// No description provided for @posTechAssignSuccessEmpty.
  ///
  /// In en, this message translates to:
  /// **'All technicians removed from this job'**
  String get posTechAssignSuccessEmpty;

  /// No description provided for @posTechAssignSuccess.
  ///
  /// In en, this message translates to:
  /// **'Technicians assigned successfully'**
  String get posTechAssignSuccess;

  /// No description provided for @posTechAssignFailNoJob.
  ///
  /// In en, this message translates to:
  /// **'Job not found for this assignment.'**
  String get posTechAssignFailNoJob;

  /// No description provided for @posTechAssignFailGetId.
  ///
  /// In en, this message translates to:
  /// **'Failed to get order ID'**
  String get posTechAssignFailGetId;

  /// No description provided for @posTechAssignFailEditId.
  ///
  /// In en, this message translates to:
  /// **'Failed to get job ID for edit'**
  String get posTechAssignFailEditId;

  /// No description provided for @posTechAssignFailGeneric.
  ///
  /// In en, this message translates to:
  /// **'Failed to assign technicians'**
  String get posTechAssignFailGeneric;

  /// No description provided for @posTechAssignUnlockFail.
  ///
  /// In en, this message translates to:
  /// **'Could not unlock job to change technicians. Try again.'**
  String get posTechAssignUnlockFail;

  /// No description provided for @posTechLastSeenNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get posTechLastSeenNever;

  /// No description provided for @posTechLastSeenJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get posTechLastSeenJustNow;

  /// No description provided for @posTechLastSeenMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String posTechLastSeenMinutes(int count);

  /// No description provided for @posTechLastSeenHours.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String posTechLastSeenHours(int count);

  /// No description provided for @posTechLastSeenDays.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String posTechLastSeenDays(int count);

  /// No description provided for @posTechViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Technicians'**
  String get posTechViewTitle;

  /// No description provided for @posTechViewSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search technicians...'**
  String get posTechViewSearchHint;

  /// No description provided for @posTechViewTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get posTechViewTabAll;

  /// No description provided for @posTechViewTabOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get posTechViewTabOffline;

  /// No description provided for @posTechViewTabOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get posTechViewTabOnline;

  /// No description provided for @posTechViewNoTechnicians.
  ///
  /// In en, this message translates to:
  /// **'No technicians found'**
  String get posTechViewNoTechnicians;

  /// No description provided for @posTechViewNoOnline.
  ///
  /// In en, this message translates to:
  /// **'No online technicians'**
  String get posTechViewNoOnline;

  /// No description provided for @posTechViewNoOffline.
  ///
  /// In en, this message translates to:
  /// **'No offline technicians'**
  String get posTechViewNoOffline;

  /// No description provided for @posTechViewErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get posTechViewErrorRetry;

  /// No description provided for @posTechViewErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String posTechViewErrorPrefix(String message);

  /// No description provided for @posTechCardOnlineNow.
  ///
  /// In en, this message translates to:
  /// **'Online now'**
  String get posTechCardOnlineNow;

  /// No description provided for @posTechCardLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen: {time}'**
  String posTechCardLastSeen(String time);

  /// No description provided for @posTechCardNoDepartment.
  ///
  /// In en, this message translates to:
  /// **'No department'**
  String get posTechCardNoDepartment;

  /// No description provided for @posTechCardSlots.
  ///
  /// In en, this message translates to:
  /// **'Slots {used}/{total}'**
  String posTechCardSlots(int used, int total);

  /// No description provided for @posTechPresenceOnline.
  ///
  /// In en, this message translates to:
  /// **'Technician marked online'**
  String get posTechPresenceOnline;

  /// No description provided for @posTechPresenceOffline.
  ///
  /// In en, this message translates to:
  /// **'Technician marked offline'**
  String get posTechPresenceOffline;
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
