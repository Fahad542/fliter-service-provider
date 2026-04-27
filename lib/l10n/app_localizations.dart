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

  /// No description provided for @lockerDefaultUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get lockerDefaultUser;

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
