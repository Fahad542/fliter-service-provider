// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get ownerShellHome => 'Home';

  @override
  String get ownerShellBranches => 'Branches';

  @override
  String get ownerShellDepartments => 'Departments';

  @override
  String get ownerShellEmployees => 'Employees';

  @override
  String get ownerShellCorporate => 'Corporate';

  @override
  String get ownerShellInventory => 'Inventory';

  @override
  String get ownerShellPosMonitoring => 'POS Monitoring';

  @override
  String get ownerShellSuppliers => 'Suppliers';

  @override
  String get ownerShellAccounting => 'Accounting';

  @override
  String get ownerShellPromoCodes => 'Promo Codes';

  @override
  String get ownerShellApprovals => 'Approvals';

  @override
  String get ownerShellNotifications => 'Notifications';

  @override
  String get ownerShellLogout => 'Logout';

  @override
  String get ownerShellRoleLabel => 'Workshop Owner';

  @override
  String get ownerShellVersion => 'v1.0.0 • Workshop OS';

  @override
  String get ownerShellLogoutTitle => 'Logout';

  @override
  String get ownerShellLogoutBody => 'Are you sure you want to logout from your account?';

  @override
  String get ownerShellLogoutCancel => 'Cancel';

  @override
  String get ownerShellLogoutConfirm => 'Logout';

  @override
  String get lockerDefaultUser => 'Owner';

  @override
  String get billingDashboardTitle => 'Billing Dashboard';

  @override
  String get billingGenerateTitle => 'Generate Bills';

  @override
  String get billingMonthlyTitle => 'Monthly Bills';

  @override
  String get billingOverdueTitle => 'Overdue Payments';

  @override
  String get billingDefaultTitle => 'Billing';

  @override
  String get billingSummaryTotalBilled => 'Total Billed';

  @override
  String get billingSummaryTotalReceived => 'Total Received';

  @override
  String get billingSummaryOutstanding => 'Outstanding';

  @override
  String get billingSummaryOverdue => 'Overdue';

  @override
  String get billingQuickActions => 'Quick Actions';

  @override
  String get billingRecentActivity => 'Recent Billing Activity';

  @override
  String get billingSeeAll => 'See All';

  @override
  String get billingNoRecentActivity => 'No recent activity';

  @override
  String get billingActionGenerate => 'Generate Bills';

  @override
  String get billingActionViewAll => 'View All Bills';

  @override
  String get billingActionRecordPayment => 'Record Payment';

  @override
  String get billingActionSendReminders => 'Send Reminders';

  @override
  String get billingGeneratorStep1 => 'Step 1: Select Billing Period';

  @override
  String get billingGeneratorStep2 => 'Step 2: Preview Eligible Invoices';

  @override
  String get billingGeneratorPendingInvoices => 'Pending Invoices: 15 • Est. Total: SAR 12,450';

  @override
  String get billingGeneratorPostAll => 'Generate & Post All';

  @override
  String billingPeriodLabel(String month, String year) {
    return 'Billing Period: $month/$year';
  }

  @override
  String get billingStatusPaid => 'Paid';

  @override
  String get billingStatusOverdue => 'Overdue';

  @override
  String get billingStatusPartiallyPaid => 'Partially Paid';

  @override
  String get billingStatusPending => 'Pending';

  @override
  String get branchManagementTitle => 'Branches';

  @override
  String get branchSearchHint => 'Search branches…';

  @override
  String get branchAddButton => 'Add Branch';

  @override
  String get branchEditButton => 'Edit';

  @override
  String get branchDeleteButton => 'Delete';

  @override
  String get branchNoBranches => 'No branches found';

  @override
  String get branchStatusActive => 'Active';

  @override
  String get branchStatusInactive => 'Inactive';

  @override
  String get branchFormTitleAdd => 'Add Branch';

  @override
  String get branchFormTitleEdit => 'Edit Branch';

  @override
  String get branchFormNameLabel => 'Branch Name';

  @override
  String get branchFormNameHint => 'Enter branch name';

  @override
  String get branchFormAddressLabel => 'Address';

  @override
  String get branchFormAddressHint => 'Search address…';

  @override
  String get branchFormLatLabel => 'GPS Latitude';

  @override
  String get branchFormLngLabel => 'GPS Longitude';

  @override
  String get branchFormStatusLabel => 'Active';

  @override
  String get branchFormSaveButton => 'Save Branch';

  @override
  String get branchFormUpdateButton => 'Update Branch';

  @override
  String get branchFormValidationError => 'Branch Name and Address are required';

  @override
  String get branchCreateSuccess => 'Branch Created Successfully';

  @override
  String get branchUpdateSuccess => 'Branch Updated Successfully';

  @override
  String get branchDeleteSuccess => 'Branch Deleted Successfully';

  @override
  String get branchSaveError => 'Failed to save branch';

  @override
  String get branchDeleteError => 'Failed to delete branch';

  @override
  String get branchDeleteConfirmTitle => 'Delete Branch';

  @override
  String get branchDeleteConfirmBody => 'Are you sure you want to delete this branch?';

  @override
  String get branchDeleteConfirmCancel => 'Cancel';

  @override
  String get branchDeleteConfirmDelete => 'Delete';

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
  String get lockerSupervisorTab => 'SUPERVISOR';

  @override
  String get lockerCollectorTab => 'COLLECTOR';

  @override
  String get lockerLogOut => 'Log Out';

  @override
  String get lockerLogOutConfirm => 'Are you sure you want to log out of the Locker Portal?';

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
  String get lockerCollectionPendingApproval => 'Collection is pending supervisor approval.';

  @override
  String get lockerPendingSupervisorApproval => 'Pending supervisor approval';

  @override
  String get lockerCollectedSuccessfully => 'Collection recorded successfully';

  @override
  String get lockerVarianceApproved => 'Variance approved';

  @override
  String get lockerVarianceRejectedBanner => 'Variance rejected';

  @override
  String get lockerVarianceDifferenceReview => 'There is a variance in this collection. Please review and approve or reject.';

  @override
  String get lockerApproveVariance => 'Variance approved successfully';

  @override
  String get lockerApprove => 'Approve';

  @override
  String get lockerReject => 'Reject';

  @override
  String get lockerRejectVarianceTitle => 'Reject Variance';

  @override
  String get lockerRejectVarianceBody => 'Provide an optional reason for rejecting this variance.';

  @override
  String get lockerRejectionReasonHint => 'Enter rejection reason (optional)';

  @override
  String get lockerConfirmReject => 'Confirm Reject';

  @override
  String get lockerVarianceRejected => 'Variance rejected';

  @override
  String get lockerSelectOfficer => 'SELECT OFFICER';

  @override
  String get lockerSelectOfficerSubtitle => 'Choose a field officer to assign to this collection request.';

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
  String get lockerAuditFootnote => 'This report is system-generated and serves as an official audit record.';

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
  String get lockerNoPendingVariance => 'No pending variance approvals at this time.';

  @override
  String get lockerVarianceReviewBanner => 'These collections have a cash variance and require your approval.';

  @override
  String get lockerShortLabel => 'SHORT';

  @override
  String get lockerOverLabel => 'OVER';

  @override
  String get lockerApproveVarianceTitle => 'Approve Variance';

  @override
  String lockerApproveVarianceConfirm(String type, String amount, String branch) {
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
  String get lockerCollectionNotesHint => 'Enter any remarks or reason for difference…';

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
  String get lockerStoragePermissionBody => 'Storage permission is required to save exported files. Please enable it in app settings.';

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

  @override
  String get accountingTitle => 'Accounting';

  @override
  String get accountingTabPayables => 'Payables';

  @override
  String get accountingTabReceivables => 'Receivables';

  @override
  String get accountingTabExpenses => 'Expenses';

  @override
  String get accountingTabAdvances => 'Advances';

  @override
  String get accountingPayables => 'Payables';

  @override
  String get accountingReceivables => 'Receivables';

  @override
  String get accountingOverdue => 'Overdue';

  @override
  String get accountingNoEntries => 'No entries found';

  @override
  String accountingRefPrefix(String ref, String date) {
    return 'Ref: $ref • $date';
  }

  @override
  String get accountingStatusOverdue => 'OVERDUE';

  @override
  String get accountingStatusSettled => 'SETTLED';

  @override
  String get accountingStatusPending => 'PENDING';

  @override
  String get accountingLoadingError => 'Failed to load accounting data';

  @override
  String accountingAmountLabel(String amount) {
    return 'SAR $amount';
  }

  @override
  String get approvalsTitle => 'Approvals';

  @override
  String get approvalsQueueLabel => 'Queue';

  @override
  String get approvalsStatusLabel => 'Status';

  @override
  String get approvalsQueueAll => 'All';

  @override
  String get approvalsQueueTopUps => 'Top-ups';

  @override
  String get approvalsQueueExpenses => 'Expenses';

  @override
  String get approvalsStatusAll => 'All';

  @override
  String get approvalsStatusPending => 'Pending';

  @override
  String get approvalsStatusApproved => 'Approved';

  @override
  String get approvalsStatusRejected => 'Rejected';

  @override
  String get approvalsEmptyExpenses => 'No expense approvals';

  @override
  String get approvalsEmptyPettyCash => 'No petty cash requests';

  @override
  String get approvalsEmptySubtitle => 'No records for this queue and status.';

  @override
  String get approvalsNoAddressesFound => 'No addresses found.';

  @override
  String get approvalsLoadingError => 'Failed to load approvals';

  @override
  String get approvalsApproveConfirm => 'Approve this request?';

  @override
  String get approvalsRejectTitle => 'Reject Request';

  @override
  String get approvalsRejectHint => 'Enter rejection reason (optional)';

  @override
  String get approvalsConfirmReject => 'Confirm Reject';

  @override
  String get approvalsCancel => 'Cancel';

  @override
  String get ownerLoginTitle => 'Workshop Owner';

  @override
  String get ownerLoginSubtitle => 'Sign in to your dashboard';

  @override
  String get ownerLoginEmail => 'Email';

  @override
  String get ownerLoginEmailHint => 'Enter your email';

  @override
  String get ownerLoginEmailRequired => 'Please enter your email';

  @override
  String get ownerLoginPassword => 'Password';

  @override
  String get ownerLoginPasswordHint => 'Enter your password';

  @override
  String get ownerLoginPasswordRequired => 'Please enter your password';

  @override
  String get ownerLoginForgotPassword => 'Forgot Password?';

  @override
  String get ownerLoginSignIn => 'Sign In';

  @override
  String get ownerLoginSuccess => 'Login successful';

  @override
  String get ownerLoginFailed => 'Login failed';

  @override
  String get ownerLoginNoAccount => 'Don\'t have an account? Sign up';

  @override
  String get ownerRegisterTitle => 'Create Account';

  @override
  String get ownerRegisterSubtitle => 'Register your workshop';

  @override
  String get ownerRegisterWorkshopName => 'Workshop Name';

  @override
  String get ownerRegisterWorkshopNameHint => 'Enter workshop name';

  @override
  String get ownerRegisterOwnerName => 'Owner Name';

  @override
  String get ownerRegisterOwnerNameHint => 'Enter full name';

  @override
  String get ownerRegisterEmail => 'Email Address';

  @override
  String get ownerRegisterEmailHint => 'Enter email address';

  @override
  String get ownerRegisterMobile => 'Mobile Number';

  @override
  String get ownerRegisterMobileHint => '+966...';

  @override
  String get ownerRegisterTaxId => 'Tax ID';

  @override
  String get ownerRegisterTaxIdHint => 'Enter Tax ID';

  @override
  String get ownerRegisterAddress => 'Address';

  @override
  String get ownerRegisterAddressHint => 'Search and select full address';

  @override
  String get ownerRegisterPassword => 'Password';

  @override
  String get ownerRegisterPasswordHint => 'Create a password';

  @override
  String get ownerRegisterButton => 'Register';

  @override
  String get ownerRegisterSuccess => 'Registration successful. Please login.';

  @override
  String get ownerRegisterFailed => 'Registration failed';

  @override
  String get ownerRegisterFieldRequired => 'Required';

  @override
  String get ownerRegisterHaveAccount => 'Already have an account? Sign in';

  @override
  String get corporateManagementTitle => 'Corporate Management';

  @override
  String get corporateSearchHint => 'Search by Company or VAT...';

  @override
  String get corporateAddButton => 'Add Corporate';

  @override
  String get corporateNoneFound => 'No corporate customers found.';

  @override
  String corporateVatLabel(String vat) {
    return 'VAT: $vat';
  }

  @override
  String get corporateVehiclesLabel => 'VEHICLES';

  @override
  String get corporateRevenueLabel => 'REVENUE';

  @override
  String get corporateAddUser => 'Add User';

  @override
  String get corporateEdit => 'Edit';

  @override
  String get corporateRegisterTitle => 'Register Corporate Partner';

  @override
  String get corporateRegisterSubtitle => 'Fill in the details to create a new corporate account.';

  @override
  String get corporateFieldCompanyName => 'Company Name';

  @override
  String get corporateFieldCustomerName => 'Customer Name';

  @override
  String get corporateFieldMobile => 'Mobile Number';

  @override
  String get corporateFieldVat => 'VAT Number';

  @override
  String get corporateFieldEmail => 'Email Address';

  @override
  String get corporateFieldPassword => 'Password';

  @override
  String get corporateFieldReferral => 'Referral';

  @override
  String get corporateSelectBranches => 'Select Branches';

  @override
  String corporateSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get corporateNoBranches => 'No branches found';

  @override
  String get corporateCreateButton => 'Create Partner';

  @override
  String get corporateAddUserTitle => 'Add Corporate User';

  @override
  String get corporateAddUserSubtitle => 'Create credentials for a user associated with this corporate account.';

  @override
  String get corporateUserFieldName => 'Full Name';

  @override
  String get corporateUserFieldEmail => 'Email Address';

  @override
  String get corporateUserFieldPassword => 'Password';

  @override
  String get corporateCreateUserButton => 'Create User';

  @override
  String get corporateEditTitle => 'Edit Corporate Account';

  @override
  String get corporateEditSubtitle => 'Update the details below. Only changed fields will be sent.';

  @override
  String get corporateFieldMobileMobile => 'Mobile';

  @override
  String get corporateFieldTaxId => 'Tax ID (VAT)';

  @override
  String get corporateFieldStatus => 'Status';

  @override
  String get corporateSaveChanges => 'Save Changes';

  @override
  String get corporateStatusPending => 'Pending';

  @override
  String get corporateStatusActive => 'Active';

  @override
  String get corporateStatusRejected => 'Rejected';

  @override
  String get corporateCreateSuccess => 'Corporate Account Created Successfully';

  @override
  String get corporateCreateError => 'Failed to create corporate account';

  @override
  String get corporateUpdateSuccess => 'Corporate Account Updated Successfully';

  @override
  String get corporateUpdateError => 'Failed to update corporate account';

  @override
  String get corporateUserCreateSuccess => 'Corporate User Created Successfully';

  @override
  String get corporateUserCreateError => 'Failed to create corporate user';

  @override
  String get corporateValidationRequired => 'Please fill in all required fields';

  @override
  String get corporateValidationBranch => 'Please select at least one branch';

  @override
  String get corporateValidationCompanyName => 'Company name is required';

  @override
  String get dashboardAllBranches => 'All Branches';

  @override
  String get dashboardViewingDataFor => 'Viewing Data For';

  @override
  String get dashboardAllBranchesAggregated => 'All Branches Aggregated';

  @override
  String get dashboardSelectBranch => 'Select Branch';

  @override
  String get dashboardKpiTotalSalesToday => 'Total Sales Today';

  @override
  String get dashboardKpiThisMonth => 'This Month';

  @override
  String get dashboardKpiPendingInvoices => 'Pending Invoices';

  @override
  String get dashboardKpiLowStockAlerts => 'Low Stock Alerts';

  @override
  String get dashboardKpiTodaysSales => 'Today\'s Sales';

  @override
  String get dashboardKpiActiveOrders => 'Active Orders';

  @override
  String get dashboardKpiTechWorkload => 'Tech Workload';

  @override
  String get dashboardKpiPendingApproval => 'Pending Approval';

  @override
  String get dashboardPendingApprovalsTitle => 'Pending Approvals';

  @override
  String get dashboardViewAll => 'View All';

  @override
  String get dashboardNoPendingApprovals => 'No pending petty-cash approvals right now.';

  @override
  String dashboardMoreApprovals(int count) {
    return '+$count more in Approvals';
  }

  @override
  String get dashboardBranchPerformance => 'Branch Performance';

  @override
  String get dashboardBranchHighlights => 'Branch Highlights';

  @override
  String get dashboardBranchStatus => 'Branch Status';

  @override
  String get dashboardTotalStaff => 'Total Staff';

  @override
  String get dashboardSalesTarget => 'Sales Target';

  @override
  String get dashboardSalesTargetValue => '85% Achieved';

  @override
  String get branchPerformanceListTitle => 'Branch Performance';

  @override
  String get branchPerformanceNoBranches => 'No branches yet.';

  @override
  String get deptMgmtTitle => 'Department Management';

  @override
  String get deptMgmtSearchHint => 'Search by Department Name...';

  @override
  String get deptMgmtAddButton => 'Add New Department';

  @override
  String get deptMgmtNoDepartments => 'No departments found.';

  @override
  String get deptMgmtLabelDepartment => 'Department';

  @override
  String get deptMgmtMenuEdit => 'Edit';

  @override
  String get deptMgmtMenuDelete => 'Delete';

  @override
  String get deptMgmtConfirmDeleteTitle => 'Confirm Deletion';

  @override
  String deptMgmtConfirmDeleteBody(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get deptMgmtCancel => 'Cancel';

  @override
  String get deptMgmtDelete => 'Delete';

  @override
  String get deptMgmtStatusActive => 'ACTIVE';

  @override
  String get deptMgmtStatusInactive => 'INACTIVE';

  @override
  String get deptMgmtSheetAddTitle => 'Add Department';

  @override
  String get deptMgmtSheetUpdateTitle => 'Update Department';

  @override
  String get deptMgmtSheetAddSubtitle => 'Enter the name of the new department.';

  @override
  String get deptMgmtSheetUpdateSubtitle => 'Modify existing department details.';

  @override
  String get deptMgmtFieldName => 'Department Name';

  @override
  String get deptMgmtFieldActiveStatus => 'Active Status';

  @override
  String get deptMgmtSheetAddButton => 'Add Department';

  @override
  String get deptMgmtSheetUpdateButton => 'Update Department';

  @override
  String get deptMgmtValidationNameRequired => 'Department Name is required';

  @override
  String get deptMgmtCreateSuccess => 'Department Created Successfully';

  @override
  String get deptMgmtUpdateSuccess => 'Department Updated Successfully';

  @override
  String get deptMgmtDeleteSuccess => 'Department Deleted Successfully';

  @override
  String get deptMgmtSaveError => 'Failed to save department';

  @override
  String get deptMgmtDeleteError => 'Failed to delete department';

  @override
  String get empMgmtTitle => 'Employee Management';

  @override
  String get empMgmtSearchHint => 'Search by Name, Email or Mobile...';

  @override
  String get empMgmtAddButton => 'Add Employee';

  @override
  String get empMgmtFilterAllBranches => 'All Branches';

  @override
  String get empMgmtNoEmployees => 'No employees found.';

  @override
  String empMgmtLastSeen(String time) {
    return 'Last seen: $time';
  }

  @override
  String get empMgmtInfoBranch => 'BRANCH';

  @override
  String get empMgmtInfoDept => 'DEPT';

  @override
  String get empMgmtInfoRoleType => 'ROLE TYPE';

  @override
  String get empMgmtInfoTechType => 'TECH TYPE';

  @override
  String get empMgmtInfoSalary => 'SALARY';

  @override
  String get empMgmtInfoCommission => 'COMMISSION';

  @override
  String get empMgmtInfoUnknown => 'Unknown';

  @override
  String get empMgmtInfoNone => 'None';

  @override
  String get empMgmtMenuEdit => 'Edit';

  @override
  String get empMgmtMenuDelete => 'Delete';

  @override
  String get empMgmtDeleteTitle => 'Delete Employee';

  @override
  String empMgmtDeleteBody(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get empMgmtDeleteCancel => 'Cancel';

  @override
  String get empMgmtDeleteConfirm => 'Delete';

  @override
  String get empMgmtSheetAddTitle => 'Add New Employee';

  @override
  String get empMgmtSheetUpdateTitle => 'Update Employee';

  @override
  String get empMgmtSheetAddSubtitle => 'Provide detailed Information to register a new member.';

  @override
  String get empMgmtSheetUpdateSubtitle => 'Modify existing employee details.';

  @override
  String get empMgmtFieldRole => 'Role';

  @override
  String get empMgmtFieldFullName => 'Full Name';

  @override
  String get empMgmtFieldMobile => 'Mobile Number';

  @override
  String get empMgmtFieldEmail => 'Email Address';

  @override
  String get empMgmtFieldPassword => 'Password';

  @override
  String get empMgmtFieldPasswordOptional => 'Password (Optional)';

  @override
  String get empMgmtFieldBranch => 'Assign to Branch';

  @override
  String get empMgmtFieldDepartment => 'Assign Department';

  @override
  String get empMgmtFieldAddress => 'Address';

  @override
  String get empMgmtFieldOpeningBalance => 'Opening Balance';

  @override
  String get empMgmtFieldBaseSalary => 'Base Salary';

  @override
  String get empMgmtFieldCommission => 'Commission %';

  @override
  String get empMgmtFieldActiveStatus => 'Active Status';

  @override
  String get empMgmtSectionTechSpecifics => 'Technician Specifics';

  @override
  String get empMgmtSectionSalary => 'Salary & Commission';

  @override
  String get empMgmtSectionAvailability => 'Availability';

  @override
  String get empMgmtToggleWorkshop => 'Workshop Technician';

  @override
  String get empMgmtToggleOnCall => 'On-Call Technician';

  @override
  String get empMgmtNoAddressFound => 'No addresses found';

  @override
  String get empMgmtSaveButton => 'Save Employee';

  @override
  String get empMgmtUpdateButton => 'Update Employee';

  @override
  String get empMgmtRoleTechnician => 'Technician';

  @override
  String get empMgmtRoleCashier => 'Cashier';

  @override
  String get empMgmtRoleSupplier => 'Supplier';

  @override
  String get empMgmtValidationRequired => 'Please fill in all required text fields.';

  @override
  String get empMgmtValidationTechType => 'Please select at least one technician type.';

  @override
  String get empMgmtValidationNoBranch => 'Please create a branch first to assign this employee.';

  @override
  String get empMgmtValidationNoBranchCashier => 'Please create a branch first to assign this cashier.';

  @override
  String get empMgmtValidationNoDepartment => 'Please create a department first to assign this employee.';

  @override
  String get empMgmtValidationSupplierRequired => 'Please fill in all required fields';

  @override
  String get empMgmtApiNotIntegrated => 'Only Technician, Cashier, and Supplier creation APIs are integrated.';

  @override
  String get empMgmtTechnicianCreateSuccess => 'Technician Created Successfully';

  @override
  String get empMgmtTechnicianUpdateSuccess => 'Technician Updated Successfully';

  @override
  String get empMgmtTechnicianCreateError => 'Failed to create technician';

  @override
  String get empMgmtCashierCreateSuccess => 'Cashier Created Successfully';

  @override
  String get empMgmtCashierUpdateSuccess => 'Cashier Updated Successfully';

  @override
  String get empMgmtCashierCreateError => 'Failed to create cashier';

  @override
  String get empMgmtSupplierCreateSuccess => 'Supplier Created Successfully';

  @override
  String get empMgmtSupplierCreateError => 'Failed to create supplier';

  @override
  String get empMgmtDeleteSuccess => 'Employee Deleted Successfully';

  @override
  String get empMgmtDeleteError => 'Failed to delete employee';

  @override
  String get empStatusAvailable => 'AVAILABLE';

  @override
  String get empStatusOnline => 'ONLINE';

  @override
  String get empStatusBusy => 'BUSY';

  @override
  String get empStatusOffline => 'OFFLINE';

  @override
  String get empLastSeenNever => 'Never';

  @override
  String get empLastSeenJustNow => 'Just now';

  @override
  String empLastSeenMinutes(int m) {
    return '${m}m ago';
  }

  @override
  String empLastSeenHours(int h) {
    return '${h}h ago';
  }

  @override
  String empLastSeenDays(int d) {
    return '${d}d ago';
  }

  @override
  String get empTechTypeWorkshop => 'WORKSHOP';

  @override
  String get empTechTypeBoth => 'BOTH';

  @override
  String get empTechTypeOnCall => 'ON-CALL';

  @override
  String get empRoleTechnician => 'TECHNICIAN';

  @override
  String get empRoleCashier => 'CASHIER';

  @override
  String get empRoleSupplier => 'SUPPLIER';

  @override
  String get invTitle => 'Inventory & Products';

  @override
  String get invTabProducts => 'PRODUCTS';

  @override
  String get invTabServices => 'SERVICES';

  @override
  String get invTabCategory => 'CATEGORY';

  @override
  String get invAddProduct => 'Add Product';

  @override
  String get invAddService => 'Add Service';

  @override
  String get invAddCategory => 'Add Category';

  @override
  String get invAdd => 'Add';

  @override
  String get invSearchProductsHint => 'Search by name or category...';

  @override
  String get invSearchServicesHint => 'Search services...';

  @override
  String get invSearchCategoriesHint => 'Search categories...';

  @override
  String get invNoProductsFound => 'No products found.';

  @override
  String get invNoServicesFound => 'No services found.';

  @override
  String get invNoCategoriesFound => 'No categories found.';

  @override
  String get invNoProductsMatchSearch => 'No products found matching your search.';

  @override
  String get invNoServicesMatchSearch => 'No services found matching your search.';

  @override
  String get invNoCategoriesMatchSearch => 'No categories found matching your search.';

  @override
  String get invMetricStock => 'STOCK';

  @override
  String get invMetricPurchase => 'PURCHASE';

  @override
  String get invMetricRetail => 'RETAIL';

  @override
  String get invMetricPrice => 'PRICE';

  @override
  String get invMetricCorpRange => 'CORP RANGE';

  @override
  String get invMetricCorporate => 'CORPORATE';

  @override
  String get invEditTooltip => 'Edit';

  @override
  String get invDeleteTooltip => 'Delete';

  @override
  String get invMenuEdit => 'Edit';

  @override
  String get invMenuDelete => 'Delete';

  @override
  String get invConfirmDeleteTitle => 'Confirm Deletion';

  @override
  String invConfirmDeleteBody(String name) => 'Are you sure you want to delete "$name"? This action cannot be undone.';

  @override
  String get invCancel => 'Cancel';

  @override
  String get invConfirm => 'Confirm';

  @override
  String get invCategoryTabProducts => 'Products';

  @override
  String get invCategoryTabServices => 'Services';

  @override
  String get invCreateProduct => 'Create Product';

  @override
  String get invUpdateProduct => 'Update Product';

  @override
  String get invCreateProductSubtitle => 'Enter product details to add to inventory.';

  @override
  String get invUpdateProductSubtitle => 'Modify existing product details.';

  @override
  String get invFieldBranch => 'Branch';

  @override
  String get invFieldDepartment => 'Department';

  @override
  String get invFieldCategory => 'Category';

  @override
  String get invFieldProductName => 'Product Name';

  @override
  String get invFieldStockQty => 'Stock Quantity';

  @override
  String get invFieldUnit => 'Unit';

  @override
  String get invFieldCriticalStock => 'Critical Stock Point';

  @override
  String get invSectionPricing => 'Pricing Details';

  @override
  String get invFieldPurchasePrice => 'Purchase Price';

  @override
  String get invFieldSalePrice => 'Sale Price';

  @override
  String get invFieldMinCorpPrice => 'Min Corp Price';

  @override
  String get invFieldMaxCorpPrice => 'Max Corp Price';

  @override
  String get invToggleDecimal => 'Allow Decimal Point';

  @override
  String get invToggleActive => 'Active Status';

  @override
  String get invSaveProduct => 'Save Product';

  @override
  String get invProductCreateSuccess => 'Product Created Successfully';

  @override
  String get invProductUpdateSuccess => 'Product Updated Successfully';

  @override
  String get invProductCreateError => 'Failed to create product';

  @override
  String get invProductDeleteSuccess => 'Product Deleted Successfully';

  @override
  String get invProductDeleteError => 'Failed to delete product';

  @override
  String get invValidationFillRequired => 'Please fill in all required fields.';

  @override
  String get invValidationSelectDepartment => 'Please select a department.';

  @override
  String get invValidationCreateCategory => 'Please create a category first.';

  @override
  String get invValidationSelectBranch => 'Please select a branch.';

  @override
  String get invCreateService => 'Create Service';

  @override
  String get invUpdateService => 'Update Service';

  @override
  String get invCreateServiceSubtitle => 'Enter service details.';

  @override
  String get invUpdateServiceSubtitle => 'Modify existing service details.';

  @override
  String get invFieldServiceName => 'Service Name';

  @override
  String get invFieldServicePrice => 'Service Price';

  @override
  String get invTogglePriceEditable => 'Cashier can change price on POS';

  @override
  String get invSaveService => 'Save Service';

  @override
  String get invServiceCreateSuccess => 'Service Created Successfully';

  @override
  String get invServiceUpdateSuccess => 'Service Updated Successfully';

  @override
  String get invServiceCreateError => 'Failed to create service';

  @override
  String get invServiceDeleteSuccess => 'Service Deleted Successfully';

  @override
  String get invServiceDeleteError => 'Failed to delete service';

  @override
  String get invValidationFillServiceRequired => 'Please fill in required fields.';

  @override
  String get invCreateCategory => 'Create Category';

  @override
  String get invUpdateCategory => 'Update Category';

  @override
  String get invCreateCategorySubtitle => 'Enter details for the new category.';

  @override
  String get invUpdateCategorySubtitle => 'Modify existing category details.';

  @override
  String get invFieldCategoryName => 'Category Name';

  @override
  String get invSaveCategory => 'Save Category';

  @override
  String get invCategoryCreateSuccess => 'Category Created Successfully';

  @override
  String get invCategoryUpdateSuccess => 'Category Updated Successfully';

  @override
  String get invCategoryCreateError => 'Failed to create category';

  @override
  String get invCategoryDeleteSuccess => 'Category Deleted Successfully';

  @override
  String get invCategoryDeleteError => 'Failed to delete category';

  @override
  String get invCreateSubCategory => 'Create Sub Category';

  @override
  String get invCreateSubCategorySubtitle => 'Enter details for the new sub category.';

  @override
  String get invFieldSubCategoryName => 'Sub Category Name';

  @override
  String get invSaveSubCategory => 'Save Sub Category';

  @override
  String get invSubCategoryCreateSuccess => 'Sub Category Created Successfully';

  @override
  String get invSubCategoryUpdateSuccess => 'Sub Category Updated Successfully';

  @override
  String get invSubCategoryCreateError => 'Failed to create sub category';

  @override
  String get invSubCategoryDeleteSuccess => 'Sub Category Deleted Successfully';

  @override
  String get invSubCategoryDeleteError => 'Failed to delete sub category';

  // ── Notifications ─────────────────────────────────────────────────────────

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifMarkRead => 'Mark all as read';

  @override
  String get notifEmpty => 'No notifications yet.';

  @override
  String notifTimeMinutes(int m) => '${m}m ago';

  @override
  String notifTimeHours(int h) => '${h}h ago';

  @override
  String notifTimeDays(int d) => '${d}d ago';

  @override
  String get posMonitoringTitle => 'POS Monitoring';

  @override
  String get posMonitoringLiveCounters => 'Live Counters';

  @override
  String get posMonitoringClosingReports => 'Closing Reports';

  @override
  String get posMonitoringSummaryLiveCounters => 'Live Counters';

  @override
  String get posMonitoringSummaryOpenOrders => 'Open Orders';

  @override
  String get posMonitoringSummaryTodaySales => 'Today Sales';

  @override
  String get posMonitoringNoLiveCounters => 'No active live counters';

  @override
  String get posMonitoringNoClosingReports => 'No closing reports available';

  @override
  String get posMonitoringStatusOpen => 'OPEN';

  @override
  String get posMonitoringStatusClosing => 'CLOSING';

  @override
  String get posMonitoringStatusClosed => 'CLOSED';

  @override
  String get posMonitoringStatShiftSales => 'SHIFT SALES';

  @override
  String get posMonitoringStatOpenOrders => 'OPEN ORDERS';

  @override
  String get posMonitoringStatElapsed => 'ELAPSED';

  @override
  String posMonitoringElapsedFormat(int h, int m) => '${h}h ${m}m';

  @override
  String get posMonitoringClosed => 'Closed';

  @override
  String get posMonitoringTableCategory => 'Category';

  @override
  String get posMonitoringTableSystem => 'System';

  @override
  String get posMonitoringTablePhysical => 'Physical';

  @override
  String get posMonitoringTableDiff => 'Diff';

  @override
  String get posMonitoringTableTotalSales => 'Total Sales';

  @override
  String get posMonitoringRowCash => 'Cash';

  @override
  String get posMonitoringRowBank => 'Bank/Cards';

  @override
  String get posMonitoringRowCorporate => 'Corporate';

  @override
  String get posMonitoringRowTamara => 'Tamara';

  @override
  String get posMonitoringRowTabby => 'Tabby';

  @override
  String get posMonitoringDiffShort => 'SHORT';

  @override
  String get posMonitoringDiffExcess => 'EXCESS';

  @override
  String get posMonitoringDiffBalanced => 'BALANCED';

  @override
  String posMonitoringDiffShortSymbol(String amount) => '− SAR $amount';

  @override
  String posMonitoringDiffExcessSymbol(String amount) => '+ SAR $amount';

  @override
  String get posMonitoringDiffNone => '—';

  @override
  String get posMonitoringBackendWarning =>
      '⚠ Full breakdown unavailable — deploy latest backend to see per-category data';

  @override
  String posMonitoringAmountSar(String amount) => 'SAR $amount';

  // ── Promo Codes ──────────────────────────────────────────────────────────────

  @override
  String get promoTitle => 'Promo Codes';

  @override
  String get promoNewButton => 'New Promo';

  @override
  String get promoNoCodesFound => 'No promo codes found';

  @override
  String get promoMenuEdit => 'Edit';

  @override
  String get promoMenuDelete => 'Delete';

  @override
  String promoDiscountOff(String value, String unit) => '$value $unit OFF';

  @override
  String get promoUnitPercent => '%';

  @override
  String get promoUnitSar => 'SAR';

  @override
  String get promoStatUsage => 'Usage';

  @override
  String get promoStatMinOrder => 'Min Order';

  @override
  String get promoStatValidTill => 'Valid Till';

  @override
  String promoMinOrderAmount(String amount) => 'SAR $amount';

  @override
  String get promoDeleteConfirmTitle => 'Confirm Deletion';

  @override
  String promoDeleteConfirmBody(String code) =>
      'Are you sure you want to delete "$code"? This action cannot be undone.';

  @override
  String get promoDeleteCancel => 'Cancel';

  @override
  String get promoDeleteConfirm => 'Delete';

  @override
  String get promoSheetCreateTitle => 'Create Promo Code';

  @override
  String get promoSheetUpdateTitle => 'Update Promo Code';

  @override
  String get promoSheetCreateSubtitle =>
      'Configure a new discount code for customers.';

  @override
  String get promoSheetUpdateSubtitle => 'Modify existing promo code details.';

  @override
  String get promoFieldCode => 'Promo Code (e.g., SUMMER20)';

  @override
  String get promoFieldDiscountValue => 'Discount Value';

  @override
  String get promoFieldUsageLimit => 'Usage Limit';

  @override
  String get promoFieldMinOrder => 'Min Order (SAR)';

  @override
  String get promoFieldDescription => 'Description';

  @override
  String get promoFieldValidFrom => 'Valid From';

  @override
  String get promoFieldValidTo => 'Valid To';

  @override
  String get promoTypeFixed => 'Fixed Amount';

  @override
  String get promoTypePercent => 'Percentage (%)';

  @override
  String get promoSubmitCreate => 'Create Promo';

  @override
  String get promoSubmitUpdate => 'Update Promo';

  @override
  String get promoValidationRequired =>
      'Please fill required fields (Code, Value)';

  @override
  String get promoCreateSuccess => 'Promo Code created successfully!';

  @override
  String get promoUpdateSuccess => 'Promo Code updated successfully!';

  @override
  String get promoDeleteSuccess => 'Promo Code deleted successfully!';

  @override
  String get promoCreateError => 'Failed to process promo code';

  @override
  String get promoDeleteError => 'Failed to delete promo code';

  @override
  String get posAddCustomerTitle => 'Add New Customer';

  @override
  String get posAddCustomerTabNormal => 'Normal Customer';

  @override
  String get posAddCustomerTabCorporate => 'Corporate Customer';

  @override
  String get posAddCustomerSectionVehicleInfo => 'Vehicle Information';

  @override
  String get posAddCustomerSectionCompanyDetails => 'Company Details (Auto-filled)';

  @override
  String get posAddCustomerSectionCorporateAccount => 'Corporate Account';

  @override
  String get posAddCustomerFieldVehicleNumber => 'Vehicle Number';

  @override
  String get posAddCustomerFieldVin => 'VIN';

  @override
  String get posAddCustomerFieldMake => 'Make';

  @override
  String get posAddCustomerFieldModel => 'Model';

  @override
  String get posAddCustomerFieldOdometer => 'Odometer';

  @override
  String get posAddCustomerFieldCompanyName => 'Company Name';

  @override
  String get posAddCustomerFieldVatNumber => 'VAT Number';

  @override
  String get posAddCustomerFieldBillingAddress => 'Billing Address';

  @override
  String get posAddCustomerSelectCorporate => 'Select Corporate Account';

  @override
  String get posAddCustomerNoCorporateFound => 'No Corporate Accounts Found';

  @override
  String get posAddCustomerSaveButton => 'Save & Proceed to Department';

  @override
  String get posAddCustomerFieldNA => 'N/A';

  @override
  String get posAddCustomerValidationVehicleRequired => 'Please enter vehicle number';

  @override
  String get posAddCustomerValidationRequired => 'Required';

  @override
  String get posAddCustomerValidationVinMax => 'Max 17 characters';

  @override
  String get posAddCustomerValidationInvalidNumber => 'Please enter a valid number';

  @override
  String get posAddCustomerValidationInvalidNumberShort => 'Invalid number';

  // ── Reports & Analytics ──────────────────────────────────────────────────
  @override
  String get reportsTitle => 'Reports & Analytics';

  @override
  String get reportsFinancialOverview => 'Financial Overview';

  @override
  String get reportsOperationalPerformance => 'Operational Performance';

  @override
  String get reportsInventoryValuation => 'Inventory Valuation';

  @override
  String get reportsTotalRevenue => 'Total Revenue';

  @override
  String get reportsNoDataThisWeek => 'No data for this week';

  @override
  String reportsTotalJobs(int count) => 'Total Jobs: $count';

  @override
  String get reportsCommissionLabel => 'Commission';

  @override
  String get reportsStockValueCost => 'Stock Value (Cost)';

  @override
  String get reportsPotentialProfit => 'Potential Profit';

  @override
  String get reportsActiveSkus => 'Active SKUs';

  @override
  String reportsItemsUnit(int count) => '$count Items';

  @override
  String reportsAmountSar(String amount) => 'SAR $amount';

  @override
  String get reportsNoOperationalData => 'No operational performance data';

  @override
  String reportsRevChangePositive(String pct) => '+$pct%';

  @override
  String reportsRevChangeNegative(String pct) => '$pct%';

  // ── Owner shared widgets / petty cash ────────────────────────────────────
  @override
  String get ownerCommonSearchHint => 'Search...';

  @override
  String get ownerBottomHome => 'Home';

  @override
  String get ownerBottomReports => 'Reports';

  @override
  String get ownerBottomBilling => 'Billing';

  @override
  String get ownerBottomProfile => 'Profile';

  @override
  String get ownerDashboardRoleLabel => 'WORKSHOP OWNER';

  @override
  String get ownerMonthlySales => 'Monthly Sales';

  @override
  String get ownerCurrencySar => 'SAR';

  @override
  String ownerCurrencyAmount(String currency, String amount) => '$currency $amount';

  @override
  String get pettyCashQueueCashierExpense => 'CASHIER EXPENSE';

  @override
  String get pettyCashQueueFundRequest => 'FUND REQUEST';

  @override
  String get pettyCashRequestLabel => 'Petty cash request';

  @override
  String get pettyCashApprove => 'Approve';

  @override
  String get pettyCashReject => 'Reject';

  @override
  String get pettyCashConfirmReject => 'Confirm Reject';

  @override
  String get pettyCashRejectRequestTitle => 'Reject Request';

  @override
  String get pettyCashRejectRequestBody => 'Please provide a reason for rejection.';

  @override
  String get pettyCashRejectReasonHint => 'e.g. Budget not approved';

  @override
  String get pettyCashRejectReasonRequired => 'Please enter a rejection reason';

  @override
  String get pettyCashRequestApprovedSuccess => 'Request approved successfully';

  @override
  String get pettyCashRequestApproveFailed => 'Failed to approve request';

  @override
  String get pettyCashRequestRejectedSuccess => 'Request rejected successfully';

  @override
  String get pettyCashRequestRejectFailed => 'Failed to reject request';

  @override
  String get pettyCashStatusPending => 'PENDING';

  @override
  String get pettyCashStatusApproved => 'APPROVED';

  @override
  String get pettyCashStatusRejected => 'REJECTED';

  @override
  String pettyCashStatusFallback(String status) => status;

}
