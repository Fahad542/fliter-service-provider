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
  String get ownerShellLogoutBody =>
      'Are you sure you want to logout from your account?';

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
  String get billingGeneratorPendingInvoices =>
      'Pending Invoices: 15 • Est. Total: SAR 12,450';

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
  String get branchFormValidationError =>
      'Branch Name and Address are required';

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
  String get branchDeleteConfirmBody =>
      'Are you sure you want to delete this branch?';

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
  String get corporateUserCreateSuccess =>
      'Corporate User Created Successfully';

  @override
  String get corporateUserCreateError => 'Failed to create corporate user';

  @override
  String get corporateValidationRequired =>
      'Please fill in all required fields';

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
  String get dashboardNoPendingApprovals =>
      'No pending petty-cash approvals right now.';

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
  String get deptMgmtSheetAddSubtitle =>
      'Enter the name of the new department.';

  @override
  String get deptMgmtSheetUpdateSubtitle =>
      'Modify existing department details.';

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
  String get empMgmtSheetAddSubtitle =>
      'Provide detailed Information to register a new member.';

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
  String get empMgmtValidationRequired =>
      'Please fill in all required text fields.';

  @override
  String get empMgmtValidationTechType =>
      'Please select at least one technician type.';

  @override
  String get empMgmtValidationNoBranch =>
      'Please create a branch first to assign this employee.';

  @override
  String get empMgmtValidationNoBranchCashier =>
      'Please create a branch first to assign this cashier.';

  @override
  String get empMgmtValidationNoDepartment =>
      'Please create a department first to assign this employee.';

  @override
  String get empMgmtValidationSupplierRequired =>
      'Please fill in all required fields';

  @override
  String get empMgmtApiNotIntegrated =>
      'Only Technician, Cashier, and Supplier creation APIs are integrated.';

  @override
  String get empMgmtTechnicianCreateSuccess =>
      'Technician Created Successfully';

  @override
  String get empMgmtTechnicianUpdateSuccess =>
      'Technician Updated Successfully';

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
  String get posAddCustomerTitle => 'Add New Customer';

  @override
  String get posAddCustomerTabNormal => 'Normal Customer';

  @override
  String get posAddCustomerTabCorporate => 'Corporate Customer';

  @override
  String get posAddCustomerSectionVehicleInfo => 'Vehicle Information';

  @override
  String get posAddCustomerSectionCompanyDetails =>
      'Company Details (Auto-filled)';

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
  String get posAddCustomerValidationVehicleRequired =>
      'Please enter vehicle number';

  @override
  String get posAddCustomerValidationRequired => 'Required';

  @override
  String get posAddCustomerValidationVinMax => 'Max 17 characters';

  @override
  String get posAddCustomerValidationInvalidNumber =>
      'Please enter a valid number';

  @override
  String get posAddCustomerValidationInvalidNumberShort => 'Invalid number';

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
  String posMonitoringElapsedFormat(int h, int m) {
    return '${h}h ${m}m';
  }

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
  String posMonitoringDiffShortSymbol(String amount) {
    return '− SAR $amount';
  }

  @override
  String posMonitoringDiffExcessSymbol(String amount) {
    return '+ SAR $amount';
  }

  @override
  String get posMonitoringDiffNone => '—';

  @override
  String get posMonitoringBackendWarning =>
      '⚠ Full breakdown unavailable — deploy latest backend to see per-category data';

  @override
  String posMonitoringAmountSar(String amount) {
    return 'SAR $amount';
  }

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
  String promoDiscountOff(String value, String unit) {
    return '$value $unit OFF';
  }

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
  String promoMinOrderAmount(String amount) {
    return 'SAR $amount';
  }

  @override
  String get promoDeleteConfirmTitle => 'Confirm Deletion';

  @override
  String promoDeleteConfirmBody(String code) {
    return 'Are you sure you want to delete \"$code\"? This action cannot be undone.';
  }

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
  String get corporateRegisterSubtitle =>
      'Fill in the details to create a new corporate account.';

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
  String get corporateAddUserSubtitle =>
      'Create credentials for a user associated with this corporate account.';

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
  String get corporateEditSubtitle =>
      'Update the details below. Only changed fields will be sent.';

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
  String get invNoProductsMatchSearch =>
      'No products found matching your search.';

  @override
  String get invNoServicesMatchSearch =>
      'No services found matching your search.';

  @override
  String get invNoCategoriesMatchSearch =>
      'No categories found matching your search.';

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
  String invConfirmDeleteBody(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

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
  String get invCreateProductSubtitle =>
      'Enter product details to add to inventory.';

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
  String get invValidationFillServiceRequired =>
      'Please fill in required fields.';

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
  String get invCreateSubCategorySubtitle =>
      'Enter details for the new sub category.';

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

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifMarkRead => 'Mark all as read';

  @override
  String get notifEmpty => 'No notifications yet.';

  @override
  String notifTimeMinutes(int m) {
    return '${m}m ago';
  }

  @override
  String notifTimeHours(int h) {
    return '${h}h ago';
  }

  @override
  String notifTimeDays(int d) {
    return '${d}d ago';
  }

  @override
  String get notifTypeExpense => 'expense';

  @override
  String get notifTypeStock => 'stock';

  @override
  String get notifTypePayment => 'payment';

  @override
  String get notifTypeLocker => 'locker';

  @override
  String get notifTypeInvoice => 'invoice';

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
  String reportsTotalJobs(int count) {
    return 'Total Jobs: $count';
  }

  @override
  String get reportsCommissionLabel => 'Commission';

  @override
  String get reportsStockValueCost => 'Stock Value (Cost)';

  @override
  String get reportsPotentialProfit => 'Potential Profit';

  @override
  String get reportsActiveSkus => 'Active SKUs';

  @override
  String reportsItemsUnit(int count) {
    return '$count Items';
  }

  @override
  String reportsAmountSar(String amount) {
    return 'SAR $amount';
  }

  @override
  String get reportsNoOperationalData => 'No operational performance data';

  @override
  String reportsRevChangePositive(String pct) {
    return '+$pct%';
  }

  @override
  String reportsRevChangeNegative(String pct) {
    return '$pct%';
  }

  @override
  String get posCurrentShiftTitle => 'Current Shift';

  @override
  String get posCurrentShiftDetails => 'SHIFT DETAILS';

  @override
  String get posCurrentShiftNoActiveSession => 'No active session.';

  @override
  String get posCurrentShiftNoActiveShiftFound => 'No active shift found.';

  @override
  String get posCurrentShiftRetry => 'Retry';

  @override
  String get posCurrentShiftSessionExpiredError =>
      'Session expired. Please sign in again.';

  @override
  String posCurrentShiftFetchError(String error) {
    return 'Failed to fetch shift details: $error';
  }

  @override
  String get posCurrentShiftLabelCashier => 'Cashier';

  @override
  String get posCurrentShiftLabelSessionId => 'Session ID';

  @override
  String get posCurrentShiftLabelBranch => 'Branch';

  @override
  String get posCurrentShiftLabelElapsedTime => 'Elapsed Time';

  @override
  String get posCurrentShiftLabelOpenedAt => 'Opened At';

  @override
  String get posCurrentShiftLabelBranchAddress => 'Branch Address';

  @override
  String get posBroadcastTitle => 'BROADCAST';

  @override
  String get posBroadcastHeading => 'Technician broadcasts';

  @override
  String get posBroadcastNoActive => 'No active broadcasts';

  @override
  String posBroadcastCountActive(int count, String window) {
    return '$count active · $window per item';
  }

  @override
  String get posBroadcastRetry => 'Retry';

  @override
  String get posBroadcastLabelSoon => 'Soon';

  @override
  String get posBroadcastLabelClosed => 'Closed';

  @override
  String get posBroadcastLabelRemaining => 'remaining';

  @override
  String get posBroadcastLabelExpired => 'Expired';

  @override
  String posBroadcastWindow(String m, String s) {
    return '$m:$s window';
  }

  @override
  String get posBroadcastTypeOnCall => 'On call';

  @override
  String get posBroadcastTypeWorkshop => 'Workshop';

  @override
  String get posBroadcastSessionExpired =>
      'Session expired. Please sign in again.';

  @override
  String get posCorporateBookingsTitle => 'Corporate Bookings';

  @override
  String get posCorporateFilterAll => 'All';

  @override
  String get posCorporateFilterToday => 'Today';

  @override
  String get posCorporateFilterPending => 'Pending';

  @override
  String get posCorporateNoBookingsTitle => 'No Bookings Found';

  @override
  String get posCorporateNoBookingsSubtitle =>
      'There are no corporate bookings for the selected filter.';

  @override
  String get posCorporateCardLabelVehicle => 'Vehicle';

  @override
  String get posCorporateCardLabelPlate => 'Plate';

  @override
  String get posCorporateCardLabelDepartment => 'Department';

  @override
  String get posCorporateCardLabelDate => 'Date';

  @override
  String get posCorporateActionDetails => 'Details';

  @override
  String get posCorporateActionReject => 'Reject';

  @override
  String get posCorporateActionApprove => 'Approve';

  @override
  String get posCorporateActionContinue => 'Continue';

  @override
  String get posCorporateActionApproveBooking => 'Approve Booking';

  @override
  String get posCorporateActionClose => 'Close';

  @override
  String get posCorporateActionSubmitReason => 'Submit Reason';

  @override
  String get posCorporateActionCancel => 'Cancel';

  @override
  String get posCorporateDialogDetailsTitle => 'Corporate Booking Details';

  @override
  String get posCorporateDialogRejectTitle => 'Booking Details';

  @override
  String posCorporateDialogRejectBody(String action, String company) {
    return 'Please provide a reason to $action this booking for $company. This information will be sent back to the corporate portal.';
  }

  @override
  String get posCorporateDialogReasonLabel => 'Reason';

  @override
  String get posCorporateDialogReasonHint => 'Enter your reason here...';

  @override
  String posCorporateDialogReasonRequired(String action) {
    return 'Please provide a reason to $action.';
  }

  @override
  String get posCorporateDetailsSectionBooking => 'Booking Details';

  @override
  String get posCorporateDetailsSectionVehicle => 'Vehicle Information';

  @override
  String get posCorporateDetailsSectionProducts => 'Requested Products';

  @override
  String get posCorporateDetailsBookingId => 'Booking ID';

  @override
  String get posCorporateDetailsScheduledTime => 'Scheduled Time';

  @override
  String get posCorporateDetailsDepartment => 'Department';

  @override
  String get posCorporateDetailsRejectionReason => 'Rejection reason';

  @override
  String get posCorporateDetailsVehicleName => 'Vehicle Name';

  @override
  String get posCorporateDetailsLicensePlate => 'License Plate';

  @override
  String get posCorporateDetailsNoProducts =>
      'No specific products requested. Open matching department.';

  @override
  String posCorporateDetailsQty(String qty) {
    return 'Qty: $qty';
  }

  @override
  String posCorporateDetailsProductId(String id) {
    return 'Product ID: $id';
  }

  @override
  String get posCorporateApproveError => 'Failed to approve booking';

  @override
  String get posCorporateRejectSuccess => 'Booking Rejected. Portal updated.';

  @override
  String get posCorporateRejectError => 'Failed to reject booking';

  @override
  String get posCorporateNoMatchingOrder =>
      'No matching order found for this booking yet. Please refresh and try again.';

  @override
  String get posCorporateStatusCancelled => 'Cancelled';

  @override
  String get posCorporateStatusRejected => 'Rejected';

  @override
  String get posCorporateStatusPending => 'Pending';

  @override
  String get posCorporateStatusApproved => 'Approved';

  @override
  String get posCorporateStatusInProgress => 'In Progress';

  @override
  String get posCorporateStatusCompleted => 'Completed';

  @override
  String get posCorporateStatusWaitingApproval => 'Waiting Approval';

  @override
  String get posBroadcastActionReject => 'Reject';

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
  String ownerCurrencyAmount(String currency, String amount) {
    return '$currency $amount';
  }

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
  String get pettyCashRejectRequestBody =>
      'Please provide a reason for rejection.';

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
  String pettyCashStatusFallback(String status) {
    return '$status';
  }

  @override
  String get posLoginAppName => 'POS System';

  @override
  String get posLoginTitle => 'Sign in to continue';

  @override
  String get posLoginEmail => 'Email';

  @override
  String get posLoginEmailHint => 'Enter your email';

  @override
  String get posLoginEmailRequired => 'Please enter email';

  @override
  String get posLoginPassword => 'Password';

  @override
  String get posLoginPasswordHint => 'Enter your password';

  @override
  String get posLoginPasswordRequired => 'Please enter password';

  @override
  String get posLoginForgotPassword => 'Forgot Password?';

  @override
  String get posLoginSignIn => 'Sign In';

  @override
  String get posLoginSuccess => 'Login successful';

  @override
  String get posLoginFailed => 'Login failed';

  @override
  String get posLoginResetPasswordTitle => 'Reset Password';

  @override
  String get posLoginResetPasswordSubtitle =>
      'Enter your email or mobile number and we\'ll send you a reset link.';

  @override
  String get posLoginResetPasswordEmailLabel => 'Email';

  @override
  String get posLoginResetPasswordEmailHint => 'Enter your email';

  @override
  String get posLoginResetPasswordSendButton => 'Send Reset Link';

  @override
  String get posLoginResetPasswordSentSuccess =>
      'Reset link sent! Check your inbox.';

  @override
  String get posLoginPreviousShiftAutoClosed =>
      'Previous shift was automatically closed. New shift started.';

  @override
  String get posLoginSessionExpiredError =>
      'Session expired. Please sign in again.';

  @override
  String get posYourJobsTitle => 'Your Jobs';

  @override
  String get posYourJobsNoDepartments => 'No departments selected.';

  @override
  String get posYourJobsDeptInvoiceTitle => 'Department-wise Invoice';

  @override
  String posYourJobsItems(int count) {
    return '$count items';
  }

  @override
  String get posYourJobsGrandTotal => 'Grand Total';

  @override
  String get posYourJobsSaveDraft => 'Save Draft';

  @override
  String get posYourJobsPlaceOrder => 'Place Order';

  @override
  String get posYourJobsAssignTechnicians => 'Assign Technicians';

  @override
  String get posYourJobsAddInventory => 'Add Inventory';

  @override
  String posYourJobsAmountSar(String amount) {
    return 'SAR $amount';
  }

  @override
  String get posInvSalesTitle => 'Inventory Sales';

  @override
  String get posInvSalesRefreshTooltip => 'Refresh';

  @override
  String get posInvSalesPeriodLabel => 'Period';

  @override
  String get posInvSalesPresetToday => 'Today';

  @override
  String get posInvSalesPresetYesterday => 'Yesterday';

  @override
  String get posInvSalesPresetLast7 => 'Last 7 days';

  @override
  String get posInvSalesPresetLast30 => 'Last 30 days';

  @override
  String get posInvSalesPresetThisMonth => 'This month';

  @override
  String get posInvSalesPresetCustom => 'Custom';

  @override
  String get posInvSalesFromLabel => 'From (y-MM-dd)';

  @override
  String get posInvSalesToLabel => 'To (y-MM-dd)';

  @override
  String get posInvSalesLoadButton => 'Load';

  @override
  String get posInvSalesLoadingButton => 'Loading…';

  @override
  String get posInvSalesStatTotalUnits => 'Total units sold';

  @override
  String get posInvSalesStatUniqueProducts => 'Unique products';

  @override
  String get posInvSalesStatDaysActive => 'Days with activity';

  @override
  String get posInvSalesDismissTooltip => 'Dismiss';

  @override
  String get posInvSalesNoSalesTitle => 'No sales in this period';

  @override
  String get posInvSalesNoSalesSubtitle =>
      'API returned successfully with no matching lines (200 + empty list).';

  @override
  String get posInvSalesRetry => 'Retry';

  @override
  String get posInvSalesColProduct => 'PRODUCT';

  @override
  String get posInvSalesColSku => 'SKU / CODE';

  @override
  String get posInvSalesColQty => 'SOLD QTY';

  @override
  String posInvSalesDayLines(int count) {
    return '$count line';
  }

  @override
  String posInvSalesDayLinesPlural(int count) {
    return '$count lines';
  }

  @override
  String posInvSalesDaySummary(String lines, String qty) {
    return '$lines · $qty units';
  }

  @override
  String get posInvSalesSessionExpiredError =>
      'Session expired. Please sign in again.';

  @override
  String get posInvSalesErrStartBeforeEnd =>
      'Start date must be on or before end date.';

  @override
  String posInvSalesErrRangeExceeded(int days) {
    return 'Date range cannot exceed $days days.';
  }

  @override
  String get moreMenuPettyCash => 'Petty Cash';

  @override
  String get moreMenuPromoCode => 'Promo Code';

  @override
  String get moreMenuStoreClosing => 'Store Closing';

  @override
  String get moreMenuSalesReturn => 'Sales Return';

  @override
  String get posOrdersTitle => 'Orders';

  @override
  String get posOrdersSearchHint => 'Search orders...';

  @override
  String get posOrdersTabletSearchHint => 'Search plate, name, ID...';

  @override
  String get posOrdersTabAll => 'All';

  @override
  String get posOrdersTabPending => 'Pending';

  @override
  String get posOrdersTabCompleted => 'Completed';

  @override
  String get posOrdersNoOrdersFound => 'No orders found';

  @override
  String get posOrdersNoPendingOrders => 'No pending orders found';

  @override
  String get posOrdersNoCompletedOrders => 'No completed orders found';

  @override
  String get posOrdersNewOrder => 'New Order';

  @override
  String get posOrdersNoOrderSelected => 'No Order Selected';

  @override
  String get posOrdersSelectFromList =>
      'Select an order from the list on the left to view details';

  @override
  String get posOrdersAddDepartment => 'ADD DEPARTMENT';

  @override
  String get posOrdersAddCustomerDetails => 'Add customer details';

  @override
  String get posOrdersSelectPaymentMethod => 'Select payment method';

  @override
  String get posOrdersCustomerDetailsSaved => 'Customer details saved';

  @override
  String get posOrdersPaymentMethodSaved => 'Payment method saved';

  @override
  String get posOrdersStatusRejected => 'REJECTED';

  @override
  String get posOrdersStatusCancelled => 'CANCELLED';

  @override
  String get posOrdersStatusComplete => 'COMPLETE';

  @override
  String get posOrdersStatusEdited => 'EDITED';

  @override
  String get posOrdersStatusInProgress => 'IN PROGRESS';

  @override
  String get posOrdersStatusPending => 'PENDING';

  @override
  String get posOrdersStatusUnapproved => 'UNAPPROVED';

  @override
  String get posOrdersStatusWaitingApproval => 'WAITING APPROVAL';

  @override
  String get posOrdersStatusCorpApproved => 'CORP APPROVED';

  @override
  String get posOrdersAssignTechnicians => 'Assign Technicians';

  @override
  String get posOrdersCancelBtn => 'Cancel';

  @override
  String get posOrdersMarkComplete => 'Mark Complete';

  @override
  String get posOrdersDeleteJob => 'Delete Job';

  @override
  String get posOrdersEditBtn => 'Edit';

  @override
  String get posOrdersCancelledBtn => 'Cancelled';

  @override
  String get posOrdersProductsServices => 'Products & Services';

  @override
  String get posOrdersSendForApproval => 'Send for Approval';

  @override
  String get posOrdersGenerateInvoice => 'Generate Invoice';

  @override
  String get posOrdersOrderSummary => 'ORDER SUMMARY';

  @override
  String get posOrdersOrderPromo => 'ORDER PROMO';

  @override
  String get posOrdersGrandTotal => 'Grand total';

  @override
  String get posOrdersNoTechniciansAssigned => 'No technicians assigned';

  @override
  String get posOrdersNoProducts => 'No products or services';

  @override
  String get posOrdersDeptPromo => 'Dept promo';

  @override
  String get posOrdersDeptDiscount => 'Dept discount';

  @override
  String get posOrdersOrderDiscount => 'Order discount';

  @override
  String get posOrdersLineDiscount => 'Line discount';

  @override
  String get posOrdersTotalBeforeVat => 'Total before VAT';

  @override
  String get posOrdersNoPlate => 'No Plate';

  @override
  String get posOrdersSplitPayment => 'Split Payment';

  @override
  String get posOrdersPayment => 'Payment';

  @override
  String get posOrdersInvoiceTotal => 'Invoice Total';

  @override
  String get posOrdersConfirmAmounts => 'Confirm amounts';

  @override
  String get posOrdersAmountSar => 'Amount (SAR)';

  @override
  String get posOrdersCancelDialog => 'Cancel';

  @override
  String get posOrdersNoDepartmentsAvailable =>
      'No departments available to add.';

  @override
  String get posOrdersJobIdMissing => 'Job ID missing.';

  @override
  String get posOrdersJobNoLineItems => 'This job has no line items.';

  @override
  String get posOrdersTechnicianRequired =>
      'Technician assignment is required.';

  @override
  String get posOrdersJobNotReadyForInvoice =>
      'Order is not ready for invoicing.';

  @override
  String get posOrdersSelectCustomerAndPayment =>
      'Select customer type and payment method first.';

  @override
  String get posOrdersDeleteJobTitle => 'Delete Job';

  @override
  String get posOrdersNoBtn => 'NO';

  @override
  String get posOrdersYesDeleteBtn => 'YES, DELETE';

  @override
  String get posReviewFinalReview => 'Final Review';

  @override
  String get posReviewInvoiceReady => 'Invoice Ready';

  @override
  String get posReviewBilling => 'Billing';

  @override
  String get posReviewVehicle => 'Vehicle';

  @override
  String get posReviewInvoiceDetails => 'Invoice details';

  @override
  String get posReviewCustomerDetails => 'Customer details';

  @override
  String get posReviewConfirmBillingAndVehicle =>
      'Confirm billing contact and vehicle before creating the invoice.';

  @override
  String get posReviewConfirmBillingOnly =>
      'Confirm billing contact before creating the invoice.';

  @override
  String get posReviewCustomerNameLabel => 'Customer name';

  @override
  String get posReviewMobileLabel => 'Mobile';

  @override
  String get posReviewVatLabel => 'VAT';

  @override
  String get posReviewPlateNumberLabel => 'Plate number';

  @override
  String get posReviewOdometerLabel => 'Odometer';

  @override
  String get posReviewMakeLabel => 'Make';

  @override
  String get posReviewModelLabel => 'Model';

  @override
  String get posReviewYearLabel => 'Year';

  @override
  String get posReviewVinLabel => 'VIN';

  @override
  String get posReviewRequiredError => 'Required';

  @override
  String get posReviewPlateRequiredError => 'Plate is required';

  @override
  String get posReviewInvalidYearError => 'Invalid year';

  @override
  String get posReviewCancelBtn => 'Cancel';

  @override
  String get posReviewContinueBtn => 'Continue';

  @override
  String get posReviewCorporateCustomerQuestion => 'Corporate Customer?';

  @override
  String get posReviewIsCorporateCustomer => 'Is this a corporate customer?';

  @override
  String get posReviewYesCorporate => 'Yes — Corporate';

  @override
  String get posReviewNoIndividual => 'No — Individual';

  @override
  String get posReviewPaymentMethod =>
      'Payment Method (Select multiple if splitting)';

  @override
  String get posReviewPaymentMethodCorporate => 'Payment Method';

  @override
  String get posReviewCompleteAndGenerateInvoice =>
      'Complete Order & Generate Invoice';

  @override
  String get posReviewInvoiceGeneratedLocked => 'Invoice Generated & Locked';

  @override
  String get posReviewNoFurtherEdits => 'No further edits allowed';

  @override
  String get posReviewCommissionsCredited => 'Commissions Credited';

  @override
  String get posReviewPrintInvoice => 'Print Invoice & Receipt';

  @override
  String get posReviewCommissionsNote =>
      'Commissions have been credited to technician accounts.';

  @override
  String posReviewOrderNo(Object id) {
    return 'Order #$id';
  }

  @override
  String get posReviewSplitPayment => 'Split Payment';

  @override
  String get posReviewInvoiceTotal => 'Invoice Total';

  @override
  String get posReviewConfirmAmounts => 'Confirm amounts';

  @override
  String get posReviewAmountSar => 'Amount (SAR)';

  @override
  String get posReviewCancelDialogBtn => 'Cancel';

  @override
  String get posReviewEmployeesPayment => 'Employees (payment)';

  @override
  String get posReviewSelectEmployee => 'Select employee';

  @override
  String get posReviewEmployeeInstructions =>
      'One employee for the Employees payment line. Tap the selected card again to clear.';

  @override
  String get posReviewCouldNotLoadEmployees =>
      'Could not load branch employees.';

  @override
  String get posReviewRetry => 'Retry';

  @override
  String get posReviewNoBranchEmployees => 'No branch employees listed.';

  @override
  String get posReviewGrossAmountExclVat => 'Gross Amount (Excl. VAT)';

  @override
  String get posReviewItemDiscounts => 'Item Discounts';

  @override
  String get posReviewInvoiceDiscount => 'Invoice Discount';

  @override
  String posReviewPromoDiscount(Object code) {
    return 'Promo Discount ($code)';
  }

  @override
  String get posReviewPromoDiscountNoCode => 'Promo Discount';

  @override
  String get posReviewPriceAfterDiscount => 'Price after discount';

  @override
  String get posReviewPriceAfterPromo => 'Price after promo';

  @override
  String get posReviewDiscount => 'Discount';

  @override
  String posReviewTaxPct(Object pct) {
    return 'Tax ($pct%)';
  }

  @override
  String get posReviewTotalAmount => 'Total amount';

  @override
  String get posReviewNoDeptData => 'No departmental data found.';

  @override
  String get posReviewDepartmentCol => 'Department';

  @override
  String get posReviewJobIdCol => 'Job ID';

  @override
  String get posReviewStatusCol => 'Status';

  @override
  String get posReviewProductServiceCol => 'Product / Service';

  @override
  String get posReviewQtyCol => 'Qty';

  @override
  String get posReviewAmountSarCol => 'Amount (SAR)';

  @override
  String get posReviewNoLineItems => 'No line items';

  @override
  String get posReviewGrossExclVat => 'Gross (Excl. VAT)';

  @override
  String get posReviewItemLineDiscounts => 'Item / line discounts';

  @override
  String posReviewVatPct(Object pct) {
    return 'VAT ($pct%)';
  }

  @override
  String get posReviewDepartmentTotal => 'Department total';

  @override
  String get posReviewOrderSummary => 'ORDER SUMMARY';

  @override
  String get posReviewTotalTaxable => 'Total Taxable Amount';

  @override
  String get posReviewVat15 => 'VAT (15%)';

  @override
  String get posReviewLineNetNote =>
      'Line totals are net of item-level discounts.';

  @override
  String get posReviewInvoicePromoNote =>
      'Invoice and promo discounts apply to the taxable subtotal.';

  @override
  String get posReviewConfirmAmountsNote =>
      'Confirm all amounts match the job before generating the invoice.';

  @override
  String get posReviewAssignedTechnicians => 'ASSIGNED TECHNICIANS';

  @override
  String posReviewJobHash(Object id) {
    return 'Job #$id';
  }

  @override
  String get posReviewNoTechAssigned => 'No technician assigned';

  @override
  String posReviewCommissionLabel(Object amount) {
    return 'Commission: $amount';
  }

  @override
  String get posReviewTotal => 'TOTAL';

  @override
  String get posReviewDone => 'Done';

  @override
  String get posReviewCorporateMustBeApproved =>
      'Corporate order must be approved before invoicing.';

  @override
  String get posReviewOrderNotReadyForInvoicing =>
      'Order is not ready for invoicing.';

  @override
  String get posReviewIndicateCorporate =>
      'Please indicate if this is a corporate customer.';

  @override
  String get posReviewSelectPaymentMethod => 'Please select a payment method.';

  @override
  String get posReviewSelectAtLeastOnePayment =>
      'Please select at least one payment method.';

  @override
  String get posReviewSelectOneEmployee =>
      'Select one employee for the Employees payment.';

  @override
  String posReviewSplitAmountsMustEqual(Object current, Object total) {
    return 'Split amounts must equal the total ($total SAR). Currently: $current SAR.';
  }

  @override
  String get posReviewFillRequiredInvoiceDetails =>
      'Please fill in the required invoice details.';

  @override
  String get posReviewInvoiceNotLoaded => 'Invoice could not be loaded.';

  @override
  String get posDetailsTitle => 'Order Details';

  @override
  String get posDetailsCustomerSection => 'Customer';

  @override
  String get posDetailsVehicleSection => 'Vehicle';

  @override
  String get posDetailsVehicleNo => 'Vehicle no.';

  @override
  String get posDetailsCustomer => 'Customer';

  @override
  String get posDetailsMobile => 'Mobile';

  @override
  String get posDetailsVat => 'VAT';

  @override
  String get posDetailsMakeModel => 'Make/Model';

  @override
  String get posDetailsPlate => 'Plate';

  @override
  String get posDetailsOdometer => 'Odometer';

  @override
  String posDetailsOdometerKm(Object reading) {
    return '$reading km';
  }

  @override
  String get posDetailsJobsSection => 'Jobs';

  @override
  String get posDetailsNoJobsFound => 'No jobs found';

  @override
  String posDetailsJobTitle(Object num, Object status) {
    return 'Job $num • $status';
  }

  @override
  String get posDetailsDepartment => 'Department';

  @override
  String get posDetailsTechnician => 'Technician';

  @override
  String get posDetailsSubtotal => 'Subtotal';

  @override
  String get posDetailsVat15 => 'VAT';

  @override
  String get posDetailsTotal => 'Total';

  @override
  String posDetailsItems(Object count) {
    return 'Items ($count)';
  }

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodCard => 'Card';

  @override
  String get paymentMethodBankTransfer => 'Bank Transfer';

  @override
  String get paymentMethodMonthlyBilling => 'Monthly billing';

  @override
  String get paymentMethodWallet => 'Wallet';

  @override
  String get paymentMethodTabby => 'Tabby';

  @override
  String get paymentMethodTamara => 'Tamara';

  @override
  String get paymentMethodEmployees => 'Employees';

  @override
  String get suppliersTitle => 'Suppliers & Purchases';

  @override
  String get suppliersTabSuppliers => 'Suppliers';

  @override
  String get suppliersTabPurchaseOrders => 'Purchase Orders';

  @override
  String get suppliersFabAddSupplier => 'Add Supplier';

  @override
  String get suppliersFabNewPurchase => 'New Purchase';

  @override
  String get suppliersStatSuppliers => 'Suppliers';

  @override
  String get suppliersStatOutstanding => 'Outstanding';

  @override
  String get suppliersStatPendingPos => 'Pending POs';

  @override
  String get suppliersNoSuppliersFound => 'No suppliers found';

  @override
  String get suppliersInternalBadge => 'INTERNAL';

  @override
  String get suppliersOutstandingLabel => 'Outstanding';

  @override
  String suppliersAmountSar(String amount) {
    return 'SAR $amount';
  }

  @override
  String suppliersAmountCurrency(String currency, String amount) {
    return '$currency $amount';
  }

  @override
  String get suppliersUnknown => 'Unknown';

  @override
  String get suppliersStatusPending => 'PENDING';

  @override
  String get suppliersStatusApproved => 'APPROVED';

  @override
  String get suppliersStatusRejected => 'REJECTED';

  @override
  String get suppliersPoStep1Title => 'Select Supplier';

  @override
  String get suppliersPoStep1Subtitle =>
      'Choose from your registered suppliers.';

  @override
  String get suppliersPoStep2Title => 'Add Items';

  @override
  String suppliersPoStep2Subtitle(String name) {
    return 'Supplier: $name';
  }

  @override
  String get suppliersPoStep3Title => 'Confirm Order';

  @override
  String get suppliersPoStep3Subtitle =>
      'Review before submitting for approval.';

  @override
  String get suppliersPoStepSelect => 'Select Supplier';

  @override
  String get suppliersPoStepAddItems => 'Add Items';

  @override
  String get suppliersPoStepConfirm => 'Confirm';

  @override
  String get suppliersPoAddItem => 'Add Item';

  @override
  String get suppliersPoItemProductName => 'Product Name';

  @override
  String get suppliersPoItemProductHint => 'e.g. Engine Oil';

  @override
  String get suppliersPoItemQty => 'Qty';

  @override
  String get suppliersPoItemUnitPrice => 'Unit Price';

  @override
  String get suppliersPoConfirmSupplier => 'Supplier';

  @override
  String suppliersPoConfirmItems(int count) {
    return '$count items';
  }

  @override
  String get suppliersPoConfirmStatus => 'Status';

  @override
  String get suppliersPoConfirmStatusValue => 'Pending Approval';

  @override
  String get suppliersPoConfirmNote =>
      'This PO will be submitted for manager approval before stock is updated.';

  @override
  String get suppliersPoNavNext => 'Next';

  @override
  String get suppliersPoNavSubmit => 'Submit';

  @override
  String get suppliersPoNavBack => 'Back';

  @override
  String get suppliersAddSheetTitle => 'Register New Supplier';

  @override
  String get suppliersAddSheetSubtitle =>
      'Provide details to add a new supplier.';

  @override
  String get suppliersAddFieldName => 'Supplier Name';

  @override
  String get suppliersAddFieldEmail => 'Email Address';

  @override
  String get suppliersAddFieldMobile => 'Mobile Number';

  @override
  String get suppliersAddFieldAddress => 'Address';

  @override
  String get suppliersAddFieldOpeningBalance => 'Opening Balance';

  @override
  String get suppliersAddFieldPassword => 'Password';

  @override
  String get suppliersAddSaveButton => 'Save Supplier';

  @override
  String get suppliersValidationRequired =>
      'Please fill in all required fields';

  @override
  String get suppliersCreateSuccess => 'Supplier Created Successfully';

  @override
  String get suppliersCreateError => 'Failed to create supplier';

  @override
  String get suppliersPoValidationEmpty => 'Please add at least one item';

  @override
  String get suppliersPoValidationItemDetails =>
      'Please fill all item details properly';

  @override
  String get suppliersPoValidationInvalidSupplier =>
      'Invalid supplier selected';

  @override
  String get suppliersPoCreateSuccess => 'Purchase Order Created Successfully';

  @override
  String get suppliersPoCreateError => 'Failed to create purchase order';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsRoleLabel => 'Workshop Owner';

  @override
  String get settingsMultiBranchBadge => 'MULTI-BRANCH ACCESS';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsSectionBusiness => 'Business';

  @override
  String get settingsSectionSupport => 'Support';

  @override
  String get settingsTogglePushNotif => 'Push Notifications';

  @override
  String get settingsTogglePushNotifSub => 'Receive in-app notifications';

  @override
  String get settingsToggleEmailAlerts => 'Email Alerts';

  @override
  String get settingsToggleEmailAlertsSub => 'Get critical alerts via email';

  @override
  String get settingsToggleStockAlerts => 'Stock Alerts';

  @override
  String get settingsToggleStockAlertsSub => 'Notify when stock is critical';

  @override
  String get settingsToggleLockerAlerts => 'Locker Difference Alerts';

  @override
  String get settingsToggleLockerAlertsSub => 'Notify on EOD locker variance';

  @override
  String get settingsToggleBiometric => 'Biometric Login';

  @override
  String get settingsToggleBiometricSub => 'Use fingerprint or face ID';

  @override
  String get settingsNavChangePassword => 'Change Password';

  @override
  String get settingsNavTwoFactor => 'Two-Factor Authentication';

  @override
  String get settingsNavWorkshopProfile => 'Workshop Profile';

  @override
  String get settingsNavBranchMgmt => 'Branch Management';

  @override
  String get settingsNavCommissionRules => 'Commission Rules';

  @override
  String get settingsNavVatSettings => 'VAT Settings';

  @override
  String get settingsNavHelp => 'Help & Documentation';

  @override
  String get settingsNavContactSupport => 'Contact Support';

  @override
  String get settingsNavReportIssue => 'Report an Issue';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsLogoutDialogTitle => 'Log out';

  @override
  String get settingsLogoutDialogBody =>
      'Are you sure you want to log out from your account?';

  @override
  String get settingsLogoutDialogCancel => 'Cancel';

  @override
  String get settingsLogoutDialogConfirm => 'Log out';

  @override
  String get settingsVersionLabel => 'Filter Workshop OS • Version 1.0.0';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLanguageLabel => 'App Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageArabic => 'Arabic';

  @override
  String get posCommonAll => 'All';

  @override
  String get posCommonProducts => 'Products';

  @override
  String get posCommonServices => 'Services';

  @override
  String get posCommonRetry => 'Retry';

  @override
  String get posCommonSave => 'Save';

  @override
  String get posCommonSar => 'SAR';

  @override
  String get posCommonPending => 'Pending';

  @override
  String get posCommonApproved => 'Approved';

  @override
  String get posCommonRejected => 'Rejected';

  @override
  String get posPettyCashTitle => 'Petty Cash';

  @override
  String get posPettyCashExpenseTab => 'Expense';

  @override
  String get posPettyCashFundTab => 'Fund';

  @override
  String get posPettyCashHistoryTab => 'History';

  @override
  String get posPettyCashSecureWallet => 'SECURE WALLET';

  @override
  String get posPettyCashAvailable => 'Available Petty Cash';

  @override
  String get posPettyCashLowBalanceMessage =>
      'Petty cash balance is low. Please request fund.';

  @override
  String get posPettyCashRequestFund => 'Request Fund';

  @override
  String get posPettyCashExpenseDetails => 'Expense Details';

  @override
  String get posPettyCashAmountSar => 'Amount (SAR)';

  @override
  String get posPettyCashExpenseCategory => 'Expense Category';

  @override
  String get posPettyCashEmployeeSalaryAdvance => 'Employee (Salary advance)';

  @override
  String get posPettyCashDescriptionNotes => 'Description / Notes';

  @override
  String get posPettyCashEnterDetailsHint => 'Enter details...';

  @override
  String get posPettyCashProofOfExpense => 'Proof of Expense';

  @override
  String get posPettyCashExpenseSubmitted =>
      'Expense submitted – pending approval';

  @override
  String get posPettyCashSubmitExpense => 'Submit Expense';

  @override
  String get posPettyCashFundRequest => 'Fund Request';

  @override
  String get posPettyCashRequestedAmountSar => 'Requested Amount (SAR)';

  @override
  String get posPettyCashReasonForRequest => 'Reason for Request';

  @override
  String get posPettyCashReasonHint => 'Explain why you need more funds...';

  @override
  String get posPettyCashFundRequestSubmitted =>
      'Fund request submitted – pending approval';

  @override
  String get posPettyCashSubmitRequest => 'Submit Request';

  @override
  String get posPettyCashSelectCategory => 'Select category';

  @override
  String get posPettyCashNoEmployees => 'No employees on file';

  @override
  String get posPettyCashSelectEmployee => 'Select employee';

  @override
  String get posPettyCashSelectDate => 'Select date';

  @override
  String get posPettyCashFrom => 'From:';

  @override
  String get posPettyCashTo => 'To:';

  @override
  String get posPettyCashAllCategories => 'All categories';

  @override
  String get posPettyCashReset => 'Reset';

  @override
  String get posPettyCashHistoryTitle => 'Expense & fund history';

  @override
  String get posPettyCashNoHistory => 'No history for this filter.';

  @override
  String get posPettyCashLoadMore => 'Load more';

  @override
  String posPettyCashEmployeePrefix(Object name) {
    return 'Employee: $name';
  }

  @override
  String posPettyCashRejectionPrefix(Object reason) {
    return 'Rejection: $reason';
  }

  @override
  String get posPettyCashTapUploadReceipt => 'Tap to upload receipt';

  @override
  String get posPettyCashRequestStatus => 'Request Status';

  @override
  String get posPettyCashPendingUpper => 'PENDING';

  @override
  String get posPettyCashRequestedAmount => 'Requested Amount';

  @override
  String get posPettyCashReason => 'Reason';

  @override
  String get posPettyCashRequestDate => 'Request Date';

  @override
  String get posPettyCashPendingReviewMessage =>
      'Your request is currently being reviewed by administration. You will be notified once it is approved.';

  @override
  String get posPettyCashSubmitNewRequest => 'Submit New Request';

  @override
  String get posPettyCashValidAmountError => 'Please enter a valid amount';

  @override
  String get posPettyCashSelectCategoryError => 'Please select a category';

  @override
  String get posPettyCashSelectEmployeeError =>
      'Please select an employee for Salary Advances';

  @override
  String get posPettyCashSubmitExpenseError =>
      'Failed to submit expense. Check balance or try again.';

  @override
  String get posPettyCashReasonError => 'Please enter a reason';

  @override
  String get posPettyCashSubmitRequestError => 'Failed to submit fund request';

  @override
  String get posPettyCashTokenNotFound => 'Token not found';

  @override
  String get posPettyCashLowBalanceError => 'Low balance - request fund first';

  @override
  String get posProductAddTechnician => 'Add Technician';

  @override
  String get posProductAddProducts => 'Add Products';

  @override
  String posProductItemsCount(Object count) {
    return '$count items';
  }

  @override
  String get posProductGrandTotal => 'Grand Total';

  @override
  String get posProductViewInvoice => 'View Invoice';

  @override
  String get posProductOrderItems => 'Order Items';

  @override
  String get posProductNoItemsInvoice => 'No items in invoice';

  @override
  String get posProductGrossAmountExclVat => 'Gross Amount (Excl. VAT)';

  @override
  String get posProductLineDiscount => 'Line discount';

  @override
  String get posProductPriceAfterLineDiscount => 'Price after line discount';

  @override
  String get posProductTotalDiscountApplied => 'Total discount applied';

  @override
  String get posProductPriceAfterTotalDiscount => 'Price after total discount';

  @override
  String get posProductAddPromoCode => 'Add Promo Code';

  @override
  String posProductPromoLabel(Object code) {
    return 'Promo: $code';
  }

  @override
  String get posProductPromoDiscount => 'Promo discount';

  @override
  String get posProductPriceAfterPromo => 'Price after promo';

  @override
  String get posProductVat15 => 'VAT (15%)';

  @override
  String get posProductTotal => 'Total';

  @override
  String get posProductTotalAmount => 'Total amount';

  @override
  String get posProductEmployeesUpper => 'EMPLOYEES';

  @override
  String get posProductSelectEmployeePayment =>
      'Select one employee for Employees payment (shown with type). Saves with your order.';

  @override
  String get posProductSelectEmployeePaymentShort =>
      'Select one employee for Employees payment (with type).';

  @override
  String get posProductNewOrderId => '#NEW-ORDER';

  @override
  String get posProductWalkInCustomer => 'Walk-in Customer';

  @override
  String get posProductNoVehicleDetails => 'No Vehicle Details';

  @override
  String get posProductNoPhone => 'No Phone';

  @override
  String get posProductDraft => 'Draft';

  @override
  String get posProductNoItemsAdded => 'No items added';

  @override
  String get posProductPendingAssignment => 'pending assignment';

  @override
  String get posProductCompleteSuccess =>
      'Order marked as completed successfully';

  @override
  String get posProductCompleteError => 'Failed to complete job';

  @override
  String get posProductMarkComplete => 'Mark as Complete';

  @override
  String get posProductSaveDraft => 'Save Draft';

  @override
  String get posProductForwardTechnician => 'Forward to Technician';

  @override
  String get posProductSearchHint => 'Search products & services...';

  @override
  String get posProductNoSearchMatch => 'No products match your search.';

  @override
  String get posProductDepartmentNotFound => 'Department not found';

  @override
  String get posProductAddDepartment => 'Add Department';

  @override
  String get posProductNoServicesFound => 'No services found';

  @override
  String get posProductNoProductsFound => 'No products found';

  @override
  String posProductUnitLabel(Object unit) {
    return 'Unit: $unit';
  }

  @override
  String get posProductDiscountShort => 'Dis.';

  @override
  String get posProductTotalDiscount => 'Total discount';

  @override
  String get posProductCouldNotLoadEmployees => 'Could not load employees.';

  @override
  String get posProductNoBranchEmployees => 'No branch employees.';

  @override
  String get posProductsFailedLoad => 'Failed to load products';

  @override
  String posProductsBranchLabel(Object branch) {
    return 'Branch: $branch';
  }

  @override
  String get posHomeTitleWorkshop => 'Workshop ';

  @override
  String get posHomeTitlePos => 'POS';

  @override
  String get posHomeSubtitle =>
      'Search by customer number, vehicle number,\nphone number or customer name';

  @override
  String get posHomeSearchHint =>
      'Search customer no / vehicle / mobile / plate...';

  @override
  String get posHomeNewWalkIn => 'New walk-in';

  @override
  String get posHomeCorporateBooking => 'Corporate booking';

  @override
  String posHomeBranchPrefix(String branch) {
    return 'Branch: $branch';
  }

  @override
  String get posHomeRecentSearches => 'Recent Searches';

  @override
  String get posHomeNoVehicle => 'No Vehicle';

  @override
  String get posHomeNoResults => 'No results found';

  @override
  String get posHomeNoResultsHint =>
      'Try searching with a different name or number';

  @override
  String get posDeptSelectTitle => 'Select Depart';

  @override
  String get posDeptAddTitle => 'Add Department';

  @override
  String get posDeptNoneFound => 'No departs found';

  @override
  String get posDeptAlreadyOnOrder =>
      'This department is already on this order.';

  @override
  String posDeptSelectedCount(int count) {
    return '$count departments selected';
  }

  @override
  String get posDeptAddToOrder => 'Add to order';

  @override
  String get posDeptOrderPlaced => 'Order Placed';

  @override
  String get posDeptSelectAtLeastOne =>
      'Select at least one department to add.';

  @override
  String get posDeptVehicleRequired =>
      'Please add vehicle number first (Add Customer)';

  @override
  String get posDeptChangeDeptTitle => 'Change Department?';

  @override
  String get posDeptChangeDeptBody =>
      'Do you really want to change your department?';

  @override
  String get posDeptChangeDeptRefresh => 'Your invoice data will be refreshed.';

  @override
  String get posDeptChangeDeptCancel => 'Cancel';

  @override
  String get posDeptChangeDeptContinue => 'Continue';

  @override
  String get posDeptRetry => 'Retry';

  @override
  String get posCustomerHistoryTitle => 'Customer History';

  @override
  String get posCustomerPastOrders => 'Past Orders';

  @override
  String get posCustomerNoHistory =>
      'No order history found for this customer.';

  @override
  String posCustomerVat(String vat) {
    return 'VAT: $vat';
  }

  @override
  String posCustomerOrderId(String id) {
    return 'Order #$id';
  }

  @override
  String posCustomerInvoice(String no) {
    return 'Invoice: $no';
  }

  @override
  String posCustomerVin(String vin) {
    return 'VIN $vin';
  }

  @override
  String posCustomerMoreItems(int count) {
    return '+$count more items';
  }

  @override
  String posCustomerAmountSar(String amount) {
    return 'SAR $amount';
  }

  @override
  String get posCustomerTypeRegular => 'REGULAR';

  @override
  String get posCustomerTypeCorporate => 'CORPORATE';

  @override
  String posProductStockInStock(int count) {
    return 'In Stock ($count)';
  }

  @override
  String posProductStockLow(int count) {
    return 'Low ($count)';
  }

  @override
  String get posProductStockOut => 'Out of Stock';

  @override
  String get posProductStockService => 'Service';

  @override
  String get posOrderStatusInvoiced => 'Invoiced';

  @override
  String get posOrderStatusCompleted => 'Completed';

  @override
  String get posOrderStatusPending => 'Pending';

  @override
  String get posOrderStatusWaiting => 'Waiting';

  @override
  String get posOrderStatusDraft => 'Draft';

  @override
  String get posOrderStatusInProgress => 'In Progress';

  @override
  String get posOrderStatusAccepted => 'Accepted';

  @override
  String get posSearchHistoryNoVehicle => 'No Vehicle';

  @override
  String get posSearchHistoryNa => 'N/A';

  @override
  String get posSearchHistoryContinue => 'Continue Order';

  @override
  String get posSearchHistoryHistory => 'History';

  @override
  String get posSearchHistorySalesReturn => 'Sales Return';

  @override
  String get posNavHome => 'Home';

  @override
  String get posNavProducts => 'Products';

  @override
  String get posNavOrders => 'Orders';

  @override
  String get posNavStoreClosing => 'Store Closing';

  @override
  String get posPromoViewTitle => 'Promo Code';

  @override
  String get posPromoViewEntryTitle => 'Apply Promo Code';

  @override
  String get posPromoViewEntrySubtitle =>
      'Check the validity of a customer provided code.';

  @override
  String get posPromoViewCheckValidity => 'Check Validity';

  @override
  String get posPromoViewAvailableTitle => 'Available Promotions';

  @override
  String get posPromoViewNoPromos => 'No promotions available';

  @override
  String get posPromoViewCheckConditions => 'Check Conditions';

  @override
  String get posPromoViewRemoveTooltip => 'Remove promo';

  @override
  String posPromoResultStore(String value) {
    return 'Store: $value';
  }

  @override
  String posPromoResultProducts(String value) {
    return 'Products: $value';
  }

  @override
  String posPromoResultPeriod(String value) {
    return 'Period: $value';
  }

  @override
  String get posPromoDialogTitle => 'Apply Promo Code';

  @override
  String get posPromoDialogSubtitle =>
      'Select any promo code below to apply discount instantly.';

  @override
  String get posPromoDialogNoCodesAvailable => 'No promo codes available.';

  @override
  String get posPromoDialogOrEnterManually => 'Or enter code manually';

  @override
  String get posPromoDialogHintText => 'e.g. SAVE10';

  @override
  String get posPromoDialogRemovePromo => 'Remove Promo';

  @override
  String get posPromoDialogValidCode => 'Valid Promo Code';

  @override
  String get posPromoDialogLabelDiscount => 'Discount:';

  @override
  String get posPromoDialogLabelStore => 'Store:';

  @override
  String get posPromoDialogLabelProducts => 'Products:';

  @override
  String get posPromoDialogLabelValidity => 'Validity:';

  @override
  String get posPromoDialogCancel => 'Cancel';

  @override
  String get posPromoDialogCheckCode => 'Check Code';

  @override
  String get posPromoDialogApplyDiscount => 'Apply Discount';

  @override
  String posPromoDiscountPercent(String value) {
    return '$value% Discount';
  }

  @override
  String posPromoDiscountSar(String value) {
    return 'SAR $value Discount';
  }

  @override
  String get posPromoAllBranches => 'All Branches';

  @override
  String get posPromoAllProducts => 'All Products';

  @override
  String get posPromoNoExpiry => 'No Expiry';

  @override
  String get posPromoInvalidCode => 'Invalid Promo Code';

  @override
  String get posPromoInvalidExpired => 'Invalid or Expired Promo Code';

  @override
  String get posTechAssignTitle => 'Technician Assignment';

  @override
  String get posTechAssignSearchHint => 'Search technicians...';

  @override
  String get posTechAssignShowAll => 'Show all';

  @override
  String get posTechAssignOnlineOnly => 'Online only';

  @override
  String get posTechAssignLoading => 'Loading technicians…';

  @override
  String get posTechAssignNoResults => 'No technicians found';

  @override
  String posTechAssignErrorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get posTechAssignRetry => 'Retry';

  @override
  String get posTechAssignStatusOnline => 'Online';

  @override
  String posTechAssignStatusLastSeen(String time) {
    return 'Last seen: $time';
  }

  @override
  String posTechAssignSlots(int used, int total) {
    return 'Slots: $used/$total';
  }

  @override
  String get posTechAssignBroadcast => 'Broadcast';

  @override
  String posTechAssignWait(String label) {
    return 'Wait $label';
  }

  @override
  String get posTechAssignSave => 'Save Technicians';

  @override
  String get posTechAssignSuccessEmpty =>
      'All technicians removed from this job';

  @override
  String get posTechAssignSuccess => 'Technicians assigned successfully';

  @override
  String get posTechAssignFailNoJob => 'Job not found for this assignment.';

  @override
  String get posTechAssignFailGetId => 'Failed to get order ID';

  @override
  String get posTechAssignFailEditId => 'Failed to get job ID for edit';

  @override
  String get posTechAssignFailGeneric => 'Failed to assign technicians';

  @override
  String get posTechAssignUnlockFail =>
      'Could not unlock job to change technicians. Try again.';

  @override
  String get posTechLastSeenNever => 'Never';

  @override
  String get posTechLastSeenJustNow => 'Just now';

  @override
  String posTechLastSeenMinutes(int count) {
    return '${count}m ago';
  }

  @override
  String posTechLastSeenHours(int count) {
    return '${count}h ago';
  }

  @override
  String posTechLastSeenDays(int count) {
    return '${count}d ago';
  }

  @override
  String get posTechViewTitle => 'Technicians';

  @override
  String get posTechViewSearchHint => 'Search technicians...';

  @override
  String get posTechViewTabAll => 'All';

  @override
  String get posTechViewTabOffline => 'Offline';

  @override
  String get posTechViewTabOnline => 'Online';

  @override
  String get posTechViewNoTechnicians => 'No technicians found';

  @override
  String get posTechViewNoOnline => 'No online technicians';

  @override
  String get posTechViewNoOffline => 'No offline technicians';

  @override
  String get posTechViewErrorRetry => 'Retry';

  @override
  String posTechViewErrorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get posTechCardOnlineNow => 'Online now';

  @override
  String posTechCardLastSeen(String time) {
    return 'Last seen: $time';
  }

  @override
  String get posTechCardNoDepartment => 'No department';

  @override
  String posTechCardSlots(int used, int total) {
    return 'Slots $used/$total';
  }

  @override
  String get posTechPresenceOnline => 'Technician marked online';

  @override
  String get posTechPresenceOffline => 'Technician marked offline';

  @override
  String get storeClosingPhysicalDrawerCount => 'Physical Drawer Count';

  @override
  String get storeClosingEnterAmounts =>
      'Enter the physical amounts you have counted for each payment category.';

  @override
  String get storeClosingLabelPhysicalCash => 'Physical Cash Amount';

  @override
  String get storeClosingLabelBankCard => 'Bank / Card Slips';

  @override
  String get storeClosingLabelCorporate => 'Corporate Invoices';

  @override
  String get storeClosingLabelTamara => 'Tamara Credits';

  @override
  String get storeClosingLabelTabby => 'Tabby Credits';

  @override
  String get storeClosingLabelNotes => 'Notes (Optional)';

  @override
  String get storeClosingTotalPhysical => 'Total Physical Sum';

  @override
  String storeClosingExpectedSar(String sar, String amount) {
    return 'Expected: $sar $amount';
  }

  @override
  String get storeClosingShiftBalanced => 'Shift Balanced';

  @override
  String get storeClosingDiscrepancy => 'Discrepancy Detected';

  @override
  String get storeClosingShiftClosedOk => 'Shift closed successfully.';

  @override
  String get storeClosingPositiveDiff => 'Positive diff = system > physical.';

  @override
  String get storeClosingClosingId => 'Closing ID';

  @override
  String get storeClosingTotalDiff => 'Total Difference';

  @override
  String get storeClosingSystemTotalSales => 'System Total Sales';

  @override
  String get posOrdersTotalInclVat => 'Total (incl. VAT)';

  @override
  String get currencySymbol => 'SAR';

  @override
  String get currencySymbolAr => 'ر.س';

  @override
  String get toastSuccess => 'Success';

  @override
  String get toastError => 'Error';

  @override
  String get toastInfo => 'Info';
}
