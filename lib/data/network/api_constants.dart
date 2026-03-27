class ApiConstants {
  // static const String baseUrl = 'https://filterbackend-production.up.railway.app';
  static const String baseUrl = 'http://localhost:3000';

  //// workshop pos ////
  static const String loginEndpoint = '/auth/cashier/login';
  static const String servicesEndpoint = '/services';
  static const String walkInCustomerEndpoint = '/cashier/walk-in-order';
  static String assignTechnicianEndpoint(String jobId) =>
      '/cashier/job/$jobId/assign';
  static String cashierCompleteJobEndpoint(String jobId) =>
      '/cashier/job/$jobId/complete-cashier'; // newly added mapping
  static const String cashierOrdersEndpoint = '/cashier/orders';
  static String invoicedOrdersEndpoint(String customerId) =>
      '/cashier/orders/invoiced/$customerId';
  static const String searchCustomerEndpoint = '/cashier/customers/search';
  static const String openSessionEndpoint = '/cashier/session/open';
  static const String closeSessionEndpoint = '/cashier/session/close';
  static const String currentSessionEndpoint = '/cashier/session/current';
  static const String createInvoiceEndpoint = '/cashier/invoice/create';
  static const String getInvoiceByOrderEndpoint = '/cashier/invoice/by-order';
  static const String submitSalesReturnEndpoint = '/cashier/return/submit';
  static const String promoCodeApplyEndpoint = '/cashier/promo-code/apply';
  static const String expenseCategoriesEndpoint = '/cashier/expense-categories';
  static const String expenseSubmitEndpoint = '/cashier/expense/submit';
  static const String walletBalanceEndpoint = '/cashier/wallet/balance';
  static const String cashierCorporateAccountsEndpoint =
      '/cashier/corporate-accounts';
  static const String corporateBookingsEndpoint = '/cashier/corporate-bookings';
  static String approveCorporateBookingEndpoint(String id) =>
      '/cashier/corporate-bookings/$id/approve';
  static String rejectCorporateBookingEndpoint(String id) =>
      '/cashier/corporate-bookings/$id/reject';
  static const String storeClosingEndpoint = '/cashier/store-closing';
  static const String cashierPromoCodesEndpoint = '/cashier/promo-codes';

  ///// workshop-owner //////
  static const String adminLoginEndpoint = '/auth/workshop/login';
  static const String adminRegisterEndpoint = '/auth/workshop/register';
  static const String createBranchEndpoint = '/workshop-staff/branch/create';
  static const String getBranchesEndpoint = '/workshop-staff/branches';
  static const String createProductEndpoint = '/workshop-staff/product/create';
  static const String createCategoryEndpoint =
      '/workshop-staff/category/create';
  static const String createSubCategoryEndpoint =
      '/workshop-products/sub-categories';
  static const String createDepartmentEndpoint =
      '/workshop-staff/department/create';
  static const String billingDashboardEndpoint =
      '/workshop-staff/billing-dashboard';
  static const String reportsAnalyticsEndpoint =
      '/workshop-staff/reports-analytics';
  static const String createCorporateAccountEndpoint =
      '/workshop-staff/corporate-account/create';
  static const String createCorporateUserEndpoint =
      '/workshop-staff/corporate-user/create';
  static const String corporateCustomersEndpoint =
      '/workshop-staff/corporate-customers';
  static const String createTechnicianEndpoint =
      '/workshop-staff/technician/create';
  static const String createCashierEndpoint = '/workshop-staff/cashier/create';
  static const String createSupplierEndpoint =
      '/workshop-staff/supplier/create';
  static const String departmentsEndpoint = '/workshop-staff/departments';
  static const String getProductsCategoriesEndpoint =
      '/workshop-products/categories';
  static const String categoriesEndpoint = '/workshop-staff/categories';
  static const String getSubCategoriesEndpoint =
      '/workshop-staff/sub-categories';
  static const String techniciansEndpoint = '/workshop-staff/technicians';
  static const String employeesEndpoint = '/workshop-staff/employees';
  static const String productsEndpoint = '/workshop-staff/products';
  static const String workshopServicesEndpoint = '/workshop-products/services';
  static String branchCatalogEndpoint(String branchId) =>
      '/workshop-staff/branches/$branchId/catalog';
  static const String dashboardEndpoint = '/workshop-staff/dashboard';
  static const String promoCodesEndpoint = '/workshop-staff/promo-codes';
  static const String createPromoCodeEndpoint =
      '/workshop-staff/promo-code/create';
  static const String suppliersStatsEndpoint =
      '/workshop-staff/suppliers-purchases/stats';
  static const String suppliersEndpoint = '/workshop-staff/suppliers';
  static const String accountingSummaryEndpoint =
      '/workshop-staff/accounting/summary';
  static const String purchaseOrdersEndpoint =
      '/workshop-staff/purchase-orders';
  static const String accountingTransactionsEndpoint =
      '/workshop-staff/accounting/transactions';
  static const String posMonitoringEndpoint = '/workshop-staff/pos-monitoring';

  ///// technician /////
  static const String technicianLoginEndpoint = '/auth/technician/login';
  static const String technicianDailyPerformanceEndpoint =
      '/technician/daily-performance';
  static const String technicianTodayPerformanceEndpoint =
      '/technician/today-performance';
  static const String technicianProfileEndpoint = '/technician/profile';
  static const String technicianDutyStatusEndpoint = '/technician/duty-status';
  static const String technicianAssignedOrdersEndpoint =
      '/technician/assigned-orders';
  static String technicianOrderDetailsEndpoint(String jobId) =>
      '/technician/orders/$jobId';
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
