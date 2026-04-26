// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get lockerPortalTitle => 'Locker Portal';

  @override
  String get lockerPortalSubtitle => 'Secure asset management for your branch';

  @override
  String get lockerPortalAppBarTitle => 'LOCKER PORTAL';

  @override
  String get lockerSecureAssetManagement => 'SECURE ASSET MANAGEMENT';

  @override
  String get lockerEmail => 'Email';

  @override
  String get lockerEmailHint => 'Enter your email';

  @override
  String get lockerEmailRequired => 'Email is required';

  @override
  String get lockerPassword => 'Password';

  @override
  String get lockerPasswordHint => 'Enter your password';

  @override
  String get lockerPasswordRequired => 'Password is required';

  @override
  String get lockerForgotPassword => 'Forgot Password?';

  @override
  String get lockerContinue => 'Continue';

  @override
  String get lockerLoadingDashboard => 'Loading dashboard…';

  @override
  String get lockerFailedLoadDashboard => 'Failed to load dashboard';

  @override
  String get lockerUnexpectedError => 'An unexpected error occurred.';

  @override
  String get lockerRetry => 'Retry';

  @override
  String get lockerRefresh => 'Refresh';

  @override
  String get lockerDefaultUser => 'User';

  @override
  String get lockerSupervisorTab => 'SUPERVISOR';

  @override
  String get lockerCollectorTab => 'COLLECTOR';

  @override
  String get lockerLogOut => 'Log Out';

  @override
  String get lockerLogOutConfirm =>
      'Are you sure you want to log out of the Locker Portal?';

  @override
  String get lockerCancel => 'Cancel';

  @override
  String get lockerLogOutButton => 'Log Out';

  @override
  String get lockerWelcomeBack => 'WELCOME BACK';

  @override
  String get lockerRoleSupervisor => 'SUPERVISOR';

  @override
  String get lockerRoleManager => 'MANAGER';

  @override
  String get lockerRoleWorkshopOwner => 'WORKSHOP OWNER';

  @override
  String get lockerRoleWorkshopSupervisor => 'WORKSHOP SUPERVISOR';

  @override
  String get lockerRoleCollector => 'COLLECTOR';

  @override
  String get lockerRoleCollectionOfficer => 'COLLECTION OFFICER';

  @override
  String get lockerRoleWorkshopCollector => 'WORKSHOP COLLECTOR';

  @override
  String get lockerSupervisorOverview => 'SUPERVISOR OVERVIEW';

  @override
  String get lockerMyPerformance => 'MY PERFORMANCE';

  @override
  String get lockerKpiPending => 'PENDING';

  @override
  String get lockerKpiAwaiting => 'AWAITING';

  @override
  String get lockerKpiOverdue => 'OVERDUE';

  @override
  String get lockerKpiVariance => 'VARIANCE';

  @override
  String get lockerKpiOpenAssignments => 'OPEN ASSIGNMENTS';

  @override
  String get lockerKpiPendingApproval => 'PENDING APPROVAL';

  @override
  String get lockerKpiTodaysCollections => 'TODAY\'S COLLECTIONS';

  @override
  String get lockerKpiMonthlyCollected => 'MONTHLY COLLECTED';

  @override
  String get lockerCoreOperations => 'CORE OPERATIONS';

  @override
  String get lockerManageAllRequests => 'Manage All Requests';

  @override
  String get lockerStartCollection => 'Start Collection';

  @override
  String get lockerAssignOfficers => 'Assign Officers';

  @override
  String get lockerManageVarianceRequests => 'Manage Variance Requests';

  @override
  String get lockerFinancialAnalytics => 'Financial Analytics';

  @override
  String get lockerSearchHint => 'Search requests…';

  @override
  String get lockerLoadingRequests => 'Loading requests…';

  @override
  String get lockerFailedLoadRequests => 'Failed to load requests';

  @override
  String get lockerNoRequestsFound => 'No requests found';

  @override
  String get lockerAdjustFilters => 'Try adjusting your search or filters.';

  @override
  String get lockerLockedCashAsset => 'LOCKED CASH ASSET';

  @override
  String get lockerTapToCollect => 'TAP TO COLLECT';

  @override
  String get lockerStatusPending => 'PENDING';

  @override
  String get lockerStatusAssigned => 'ASSIGNED';

  @override
  String get lockerStatusAwaiting => 'AWAITING';

  @override
  String get lockerStatusCollected => 'COLLECTED';

  @override
  String get lockerStatusApproved => 'APPROVED';

  @override
  String get lockerStatusRejected => 'REJECTED';

  @override
  String get lockerStatusMatched => 'MATCHED';

  @override
  String get lockerLoadingRequest => 'Loading request…';

  @override
  String get lockerFailedLoadDetails => 'Failed to load request details';

  @override
  String get lockerSystemStatus => 'SYSTEM STATUS';

  @override
  String get lockerTotalSecuredAsset => 'TOTAL SECURED ASSET';

  @override
  String get lockerCounterClosing => 'COUNTER CLOSING';

  @override
  String get lockerPhysicalCash => 'PHYSICAL CASH';

  @override
  String get lockerSystemTotal => 'SYSTEM TOTAL';

  @override
  String get lockerDifference => 'DIFFERENCE';

  @override
  String get lockerCollectionRecord => 'COLLECTION RECORD';

  @override
  String get lockerReceived => 'RECEIVED';

  @override
  String get lockerInternalData => 'INTERNAL DATA';

  @override
  String get lockerSourceBranch => 'SOURCE BRANCH';

  @override
  String get lockerCashier => 'CASHIER';

  @override
  String get lockerCashierIdentity => 'CASHIER';

  @override
  String get lockerShiftCloseTime => 'SHIFT CLOSE TIME';

  @override
  String get lockerSessionOpened => 'SESSION OPENED';

  @override
  String get lockerSessionClosed => 'SESSION CLOSED';

  @override
  String get lockerAssignedOfficer => 'ASSIGNED OFFICER';

  @override
  String get lockerAssignCollectionOfficer => 'Assign Collection Officer';

  @override
  String get lockerProceedToCollection => 'Proceed to Collection';

  @override
  String get lockerGenerateAuditPdf => 'Generate Audit PDF';

  @override
  String get lockerCollectionPendingApproval =>
      'Collection is pending supervisor approval.';

  @override
  String get lockerPendingSupervisorApproval => 'Pending supervisor approval';

  @override
  String get lockerCollectedSuccessfully => 'Collection recorded successfully';

  @override
  String get lockerVarianceApproved => 'Variance approved';

  @override
  String get lockerVarianceRejectedBanner => 'Variance rejected';

  @override
  String get lockerVarianceDifferenceReview =>
      'There is a variance in this collection. Please review and approve or reject.';

  @override
  String get lockerApproveVariance => 'Variance approved successfully';

  @override
  String get lockerApprove => 'Approve';

  @override
  String get lockerReject => 'Reject';

  @override
  String get lockerRejectVarianceTitle => 'Reject Variance';

  @override
  String get lockerRejectVarianceBody =>
      'Provide an optional reason for rejecting this variance.';

  @override
  String get lockerRejectionReasonHint => 'Enter rejection reason (optional)';

  @override
  String get lockerConfirmReject => 'Confirm Reject';

  @override
  String get lockerVarianceRejected => 'Variance rejected';

  @override
  String get lockerSelectOfficer => 'SELECT OFFICER';

  @override
  String get lockerSelectOfficerSubtitle =>
      'Choose a field officer to assign to this collection request.';

  @override
  String get lockerOfficersLoadError => 'Could not load officers.';

  @override
  String get lockerAssignedTo => 'Assigned to';

  @override
  String get lockerLoaderAuditReport => 'Locker Audit Report';

  @override
  String get lockerGeneratedAt => 'Generated at';

  @override
  String get lockerPage => 'Page';

  @override
  String get lockerOf => 'of';

  @override
  String get lockerRequestInformation => 'REQUEST INFORMATION';

  @override
  String get lockerPosSession => 'POS SESSION';

  @override
  String get lockerOpenedAt => 'Opened At';

  @override
  String get lockerClosedAt => 'Closed At';

  @override
  String get lockerSessionStatus => 'Session Status';

  @override
  String get lockerReceivedAmount => 'Received Amount';

  @override
  String get lockerNotes => 'Notes';

  @override
  String get lockerAuditFootnote =>
      'This report is system-generated and serves as an official audit record.';

  @override
  String lockerAuditFootnoteAmounts(String currency) {
    return 'All amounts are in $currency.';
  }

  @override
  String lockerCurrencyPrefix(String currency, String amount) {
    return '$currency $amount';
  }

  @override
  String get lockerSarCurrency => 'SAR';

  @override
  String get lockerLoadingVariance => 'Loading variance approvals…';

  @override
  String get lockerFailedLoadVariance => 'Failed to load variance approvals';

  @override
  String get lockerAllClear => 'All Clear!';

  @override
  String get lockerNoPendingVariance =>
      'No pending variance approvals at this time.';

  @override
  String get lockerVarianceReviewBanner =>
      'These collections have a cash variance and require your approval.';

  @override
  String get lockerShortLabel => 'SHORT';

  @override
  String get lockerOverLabel => 'OVER';

  @override
  String get lockerApproveVarianceTitle => 'Approve Variance';

  @override
  String lockerApproveVarianceConfirm(
    String type,
    String amount,
    String branch,
  ) {
    return 'Approve $type variance of SAR $amount for $branch?';
  }

  @override
  String get lockerApproveSuccess => 'Variance approved successfully';

  @override
  String get lockerRejectSuccess => 'Variance rejected';

  @override
  String get lockerRejectVarianceDialogTitle => 'Reject Variance';

  @override
  String lockerRejectingFor(String branch) {
    return 'Rejecting variance for $branch.';
  }

  @override
  String get lockerRejectionReasonOptional => 'Reason (optional)';

  @override
  String get lockerShortVariance => 'SHORT';

  @override
  String get lockerOverVariance => 'OVER';

  @override
  String get lockerCashierLabel => 'CASHIER';

  @override
  String get lockerOfficerLabel => 'OFFICER';

  @override
  String get lockerExpected => 'EXPECTED';

  @override
  String get lockerReceivedLabel => 'RECEIVED';

  @override
  String get lockerDiffLabel => 'DIFF';

  @override
  String get lockerRecordCollectionTitle => 'RECORD COLLECTION';

  @override
  String get lockerExpectedAmount => 'EXPECTED AMOUNT';

  @override
  String get lockerVerifiedReceivedAmount => 'VERIFIED RECEIVED AMOUNT';

  @override
  String get lockerLockedAmount => 'LOCKED AMOUNT';

  @override
  String get lockerReceivedAmountLabel => 'RECEIVED AMOUNT';

  @override
  String get lockerCollectionNotes => 'COLLECTION NOTES';

  @override
  String get lockerCollectionNotesHint =>
      'Enter any remarks or reason for difference…';

  @override
  String get lockerCollectionEvidence => 'COLLECTION EVIDENCE';

  @override
  String get lockerCapturePhoto => 'CAPTURE PHOTO';

  @override
  String get lockerAttachLogs => 'ATTACH LOGS';

  @override
  String get lockerConfirmFinalise => 'CONFIRM & FINALISE ASSET';

  @override
  String get lockerEnterValidAmount => 'Please enter a valid received amount.';

  @override
  String get lockerSuccessPendingApproval => 'PENDING APPROVAL';

  @override
  String get lockerSuccessCollectionRecorded => 'COLLECTION RECORDED';

  @override
  String get lockerStatusReview => 'REVIEW';

  @override
  String get lockerStatusOk => 'OK';

  @override
  String get lockerStatusLabel => 'STATUS';

  @override
  String get lockerDone => 'DONE';

  @override
  String get lockerNotificationsTitle => 'NOTIFICATIONS';

  @override
  String get lockerSessionExpired => 'Session expired. Please log in again.';

  @override
  String get lockerSomethingWentWrong => 'Something went wrong.';

  @override
  String get lockerCouldNotRefresh => 'Could not refresh.';

  @override
  String get lockerNoNotificationsYet => 'No notifications yet.';

  @override
  String get lockerTryAgain => 'TRY AGAIN';

  @override
  String get lockerFinancialReports => 'FINANCIAL REPORTS';

  @override
  String get lockerTabHistory => 'HISTORY';

  @override
  String get lockerTabAnalytics => 'ANALYTICS';

  @override
  String get lockerSearchByRefOrOfficer => 'Search by Ref or Officer…';

  @override
  String get lockerAuditLogs => 'AUDIT LOGS';

  @override
  String lockerRecordsCount(int count) {
    return '$count records';
  }

  @override
  String get lockerExportPdf => 'PDF';

  @override
  String get lockerExportExcel => 'EXCEL';

  @override
  String get lockerDifferencesSummary => 'DIFFERENCES SUMMARY';

  @override
  String get lockerTotalShort => 'TOTAL SHORT';

  @override
  String get lockerTotalOver => 'TOTAL OVER';

  @override
  String get lockerNetDifference => 'NET DIFFERENCE';

  @override
  String get lockerTotalCollections => 'TOTAL COLLECTIONS';

  @override
  String get lockerMyCollectionPerformance => 'MY COLLECTION PERFORMANCE';

  @override
  String get lockerCollectionPerformance => 'COLLECTION PERFORMANCE';

  @override
  String get lockerOfficerComplianceRatings => 'OFFICER COMPLIANCE RATINGS';

  @override
  String get lockerNoComplianceData => 'No compliance data for this period.';

  @override
  String get lockerNoResultsMatchFilters => 'No results match your filters.';

  @override
  String get lockerNoAuditLogsFound => 'No audit logs found.';

  @override
  String get lockerAnErrorOccurred => 'An error occurred.';

  @override
  String get lockerAllRecords => 'All records';

  @override
  String get lockerFilterSearch => 'Search';

  @override
  String get lockerFilterBranch => 'Branch';

  @override
  String get lockerAllBranches => 'All Branches';

  @override
  String get lockerFilterByBranch => 'Filter by Branch…';

  @override
  String get lockerLoadingBranches => 'Loading branches…';

  @override
  String get lockerSortBy => 'SORT BY';

  @override
  String get lockerSortDate => 'Date';

  @override
  String get lockerSortReceivedAmount => 'Received Amount';

  @override
  String get lockerSortDifference => 'Difference';

  @override
  String get lockerSortAsc => 'ASC';

  @override
  String get lockerSortDesc => 'DESC';

  @override
  String get lockerSelectDateRange => 'Select Date Range';

  @override
  String get lockerDateFrom => 'FROM';

  @override
  String get lockerDateTo => 'TO';

  @override
  String get lockerTapToSet => 'Tap to set';

  @override
  String get lockerApplyFilter => 'Apply';

  @override
  String get lockerClearFilters => 'CLEAR';

  @override
  String get lockerNoData => 'No data';

  @override
  String get lockerWeeklyCollectionVolume => 'WEEKLY COLLECTION VOLUME';

  @override
  String get lockerTransactionRef => 'TRANSACTION REF';

  @override
  String get lockerReceivedFundLabel => 'RECEIVED FUND';

  @override
  String get lockerFailedToLoad => 'Failed to Load';

  @override
  String get lockerOneCollection => '1 collection';

  @override
  String lockerNCollections(int count) {
    return '$count collections';
  }

  @override
  String get lockerStoragePermissionRequired => 'Storage Permission Required';

  @override
  String get lockerStoragePermissionBody =>
      'Storage permission is required to save exported files. Please enable it in app settings.';

  @override
  String get lockerOpenSettings => 'Open Settings';

  @override
  String get lockerFinancialHistoryPdfTitle => 'Locker Financial History';

  @override
  String get lockerPdfGenerated => 'Generated';

  @override
  String get lockerPdfTotal => 'Total';

  @override
  String get lockerPdfRecords => 'records';

  @override
  String get lockerPdfRef => 'REF';

  @override
  String get lockerPdfDate => 'DATE';

  @override
  String get lockerPdfBranch => 'BRANCH';

  @override
  String get lockerPdfReceived => 'RECEIVED';

  @override
  String get lockerPdfExpected => 'EXPECTED';

  @override
  String get lockerPdfDiff => 'DIFF';

  @override
  String get lockerPdfStatus => 'STATUS';

  @override
  String get lockerPdfExportFailed => 'PDF export failed';

  @override
  String get lockerExcelSheetName => 'Locker History';

  @override
  String get lockerExcelOfficer => 'Officer';

  @override
  String get lockerExcelReceivedSar => 'Received (SAR)';

  @override
  String get lockerExcelExpectedSar => 'Expected (SAR)';

  @override
  String get lockerExcelDiffSar => 'Difference (SAR)';

  @override
  String get lockerExcelRequestRef => 'Request Ref';

  @override
  String get lockerExcelExportFailed => 'Excel export failed';
}
