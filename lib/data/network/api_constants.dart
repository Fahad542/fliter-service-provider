class ApiConstants {
  static const String baseUrl = 'https://filterbackend-production.up.railway.app';
  // Local: static const String baseUrl = 'http://localhost:3000';

  //// workshop pos ////
  static const String loginEndpoint = '/auth/cashier/login';
  static const String servicesEndpoint = '/services';
  static const String walkInCustomerEndpoint = '/cashier/walk-in-order';
  static const String cashierWalkInCorporateSubmitForApprovalEndpoint =
      '/cashier/walk-in-corporate/submit-for-approval';
  static String cashierWalkInCorporateStartDepartmentEndpoint(String orderId) =>
      '/cashier/walk-in-corporate/order/$orderId/start-department';
  static String cashierOrderDetailEndpoint(String orderId) => '/cashier/order/$orderId';
  static String assignTechnicianEndpoint(String jobId) =>
      '/cashier/job/$jobId/assign';
  /// Broadcast job to workshop / on-call technicians (plural `jobs` per backend).
  static String cashierJobBroadcastEndpoint(String jobId) =>
      '/cashier/jobs/$jobId/broadcast';
  static String cashierJobBroadcastCancelEndpoint(String jobId) =>
      '/cashier/jobs/$jobId/broadcast/cancel';
  static String cashierCompleteJobEndpoint(String jobId) =>
      '/cashier/job/$jobId/complete-cashier'; // newly added mapping
  static String cashierJobPricingEndpoint(String jobId) =>
      '/cashier/job/$jobId/pricing';
  static String cashierCompleteReadyEndpoint(String jobId) =>
      '/cashier/job/$jobId/complete-ready';
  static const String cashierOrdersEndpoint = '/cashier/orders';
  static String cancelOrderEndpoint(String orderId) =>
      '/cashier/order/$orderId/cancel';
  /// Standard walk-in only (no corporateAccountId): attach customer / vehicle before invoice.
  static String cashierOrderBillingEndpoint(String orderId) =>
      '/cashier/order/$orderId/billing';
  /// POST — add pending jobs for extra departments (walk_in / walk_in_corporate only).
  static String cashierOrderJobsEndpoint(String orderId) =>
      '/cashier/order/$orderId/jobs';
  /// GET — cashier assign picker; pass [departmentId] as query param.
  static const String cashierTechniciansEndpoint = '/cashier/technicians';
  /// PATCH — cancel a single job before invoice.
  static String cashierJobCancelEndpoint(String jobId) =>
      '/cashier/job/$jobId/cancel';
  static String editOrderEndpoint(String orderId, String jobId) =>
      '/cashier/order/$orderId/job/$jobId/edit';
  static String invoicedOrdersEndpoint(String customerId) =>
      '/cashier/orders/invoiced/$customerId';
  static const String searchCustomerEndpoint = '/cashier/customers/search';
  static const String openSessionEndpoint = '/cashier/session/open';
  static const String closeSessionEndpoint = '/cashier/session/close';
  static const String currentSessionEndpoint = '/cashier/session/current';
  static const String createInvoiceEndpoint = '/cashier/invoice/create';
  static const String getInvoiceByOrderEndpoint = '/cashier/invoice/by-order';
  static const String submitSalesReturnEndpoint = '/cashier/return/submit';
  static const String salesReturnListEndpoint = '/cashier/return/list';
  static const String promoCodeApplyEndpoint = '/cashier/promo-code/apply';
  static const String expenseCategoriesEndpoint = '/cashier/expense-categories';
  static const String expenseBranchEmployeesEndpoint = '/cashier/expense/branch-employees';
  static const String expenseHistoryEndpoint = '/cashier/expense/history';
  static const String expenseSubmitEndpoint = '/cashier/expense/submit';
  static const String pettyCashRequestFundEndpoint =
      '/cashier/petty-cash/request';
  static const String walletBalanceEndpoint = '/cashier/wallet/balance';
  static const String cashierCorporateAccountsEndpoint =
      '/cashier/corporate-accounts';
  static const String corporateBookingsEndpoint = '/cashier/corporate-bookings';
  static String approveCorporateBookingEndpoint(String id) =>
      '/cashier/corporate-bookings/$id/approve';
  static String rejectCorporateBookingEndpoint(String id) =>
      '/cashier/corporate-bookings/$id/reject';
  static const String storeClosingEndpoint = '/cashier/store-closing';
  static const String counterClosingEndpoint = '/cashier/counter-closing';
  static const String cashierPromoCodesEndpoint = '/cashier/promo-codes';
  static const String cashierTakeawayProductsCatalogEndpoint =
      '/cashier/takeaway/products-catalog';
  static const String cashierTakeawayCheckoutEndpoint =
      '/cashier/takeaway/checkout';

  ///// workshop-owner //////
  static const String adminLoginEndpoint = '/auth/workshop/login';
  static const String adminRegisterEndpoint = '/auth/workshop/register';
  static const String corporateRegisterEndpoint = '/auth/corporate/register';
  static const String createBranchEndpoint = '/workshop-staff/branch/create';
  static const String getBranchesEndpoint = '/workshop-staff/branches';
  static const String deleteBranchEndpoint = '/workshop-staff/branch';
  static const String deleteDepartmentEndpoint = '/workshop-staff/department';
  static const String createProductEndpoint = '/workshop-staff/product/create';
  static const String updateProductEndpoint = '/workshop-staff/product';
  static const String createCategoryEndpoint = '/workshop-staff/category/create';
  static const String createSubCategoryEndpoint = '/workshop-products/sub-categories';
  static const String createDepartmentEndpoint = '/workshop-staff/department/create';
  static const String billingDashboardEndpoint = '/workshop-staff/billing-dashboard';
  static const String reportsAnalyticsEndpoint = '/workshop-staff/reports-analytics';
  static const String createCorporateUserEndpoint = '/workshop-staff/corporate-user/create';
  static const String corporateCustomersEndpoint = '/workshop-staff/corporate-customers';
  static const String createTechnicianEndpoint = '/workshop-staff/technician/create';
  static const String createCashierEndpoint = '/workshop-staff/cashier/create';
  static const String createSupplierEndpoint = '/workshop-staff/supplier/create';
  static const String departmentsEndpoint = '/workshop-staff/departments';
  static const String getProductsCategoriesEndpoint = '/workshop-products/categories';
  static const String categoriesEndpoint = '/workshop-staff/categories';
  static const String getSubCategoriesEndpoint = '/workshop-staff/sub-categories';
  static const String techniciansEndpoint = '/workshop-staff/technicians';
  static const String employeesEndpoint = '/workshop-staff/employees';
  static const String referrersEndpoint = '/workshop-staff/referrers';
  static const String productsEndpoint = '/workshop-staff/products';
  static const String productUnitsEndpoint = '/workshop-staff/product-units';
  static const String workshopServicesEndpoint = '/workshop-products/services';
  static String branchCatalogEndpoint(String branchId) => '/workshop-staff/branches/$branchId/catalog';
  static const String dashboardEndpoint = '/workshop-staff/dashboard';
  static const String promoCodesEndpoint = '/workshop-staff/promo-codes';
  static const String createPromoCodeEndpoint = '/workshop-staff/promo-code/create';


  /// PATCH / DELETE single promo code by id
  static String workshopPromoCodeByIdEndpoint(String id) => '/workshop-staff/promo-code/$id';
  static const String suppliersStatsEndpoint = '/workshop-staff/suppliers-purchases/stats';
  static const String suppliersEndpoint = '/workshop-staff/suppliers';
  static const String accountingSummaryEndpoint = '/workshop-staff/accounting/summary';
  static const String purchaseOrdersEndpoint = '/workshop-staff/purchase-orders';
  static const String accountingTransactionsEndpoint = '/workshop-staff/accounting/transactions';
  static const String posMonitoringEndpoint = '/workshop-staff/pos-monitoring';
  static const String workshopPettyCashRequestsEndpoint = '/workshop-staff/petty-cash/requests';
  static const String workshopPettyCashHistoryEndpoint = '/workshop-staff/petty-cash/history';
  static String workshopPettyCashApproveEndpoint(String requestId) => '/workshop-staff/petty-cash/$requestId/approve';
  static String workshopPettyCashRejectEndpoint(String requestId) => '/workshop-staff/petty-cash/$requestId/reject';
  static String editCategoryEndpoint(String id) => '/workshop-staff/category/$id';
  static String editCorporateAccountEndpoint(String id) => '/workshop-staff/corporate-account/$id';

  ///// technician /////
  static const String technicianLoginEndpoint = '/auth/technician/login';
  static const String technicianDailyPerformanceEndpoint = '/technician/daily-performance';
  static const String technicianTodayPerformanceEndpoint = '/technician/today-performance';
  static const String technicianProfileEndpoint = '/technician/profile';
  static const String technicianOnlineStatusEndpoint = '/technician/online-status';
  static const String technicianDutyStatusEndpoint = '/technician/duty-status';
  static const String technicianAssignedOrdersEndpoint = '/technician/assigned-orders';
  static String technicianOrderDetailsEndpoint(String jobId) => '/technician/orders/$jobId';
  static String technicianCompleteOrderEndpoint(String jobId) =>
      '/technician/orders/$jobId/complete';
  static String technicianAcceptOrderEndpoint(String jobId) =>
      '/technician/orders/$jobId/accept';
  static String technicianCancelOrderEndpoint(String jobId) =>
      '/technician/orders/$jobId/cancel';
  static String technicianStartOrderEndpoint(String jobId) =>
      '/technician/orders/$jobId/start';
  static const String technicianCommissionHistoryEndpoint =
      '/technician/commission-history';
  static const String technicianBroadcastsEndpoint = '/technician/broadcasts';

  //// super admin /////
  static const String superAdminLoginEndpoint = '/auth/admin/login';
  static const String superAdminBrandsEndpoint = '/super-admin/brands';
  static const String superAdminCreateBrandEndpoint =
      '/super-admin/brand/create';
  static const String superAdminBranchesEndpoint = '/super-admin/branches';
  static const String superAdminUsersEndpoint = '/super-admin/users';
  static const String superAdminProductsEndpoint = '/super-admin/products';
  static const String superAdminDepartmentsEndpoint =
      '/super-admin/departments';
  static const String superAdminCorporateCustomersEndpoint =
      '/super-admin/corporate-customers';
}
