class ApiConstants {

  static const String baseUrl = 'https://filterbackend-production.up.railway.app';
  //// workshop pos ////
  static const String loginEndpoint = '/auth/cashier/login';
  static const String servicesEndpoint = '/services';
  static const String walkInCustomerEndpoint = '/cashier/walk-in-order';
  static String assignTechnicianEndpoint(String jobId) => '/cashier/job/$jobId/assign';
  static const String cashierOrdersEndpoint = '/cashier/orders';
  static const String searchCustomerEndpoint = '/cashier/customers/search';
  static const String openSessionEndpoint = '/cashier/session/open';
  static const String closeSessionEndpoint = '/cashier/session/close';
  static const String currentSessionEndpoint = '/cashier/session/current';
  static const String createInvoiceEndpoint = '/cashier/invoice/create';
  static const String getInvoiceByOrderEndpoint = '/cashier/invoice/by-order';
  static const String promoCodeApplyEndpoint = '/cashier/promo-code/apply';
  static const String expenseCategoriesEndpoint = '/cashier/expense-categories';
  static const String expenseSubmitEndpoint = '/cashier/expense/submit';
  static const String walletBalanceEndpoint = '/cashier/wallet/balance';


  ///// admin //////
  static const String adminLoginEndpoint = '/auth/workshop/login';
  static const String adminRegisterEndpoint = '/auth/workshop/register';
  static const String createBranchEndpoint = '/workshop-staff/branch/create';
  static const String getBranchesEndpoint = '/workshop-staff/branches';
  static const String createProductEndpoint = '/workshop-staff/product/create';
  static const String createCategoryEndpoint = '/workshop-staff/category/create';
  static const String createDepartmentEndpoint = '/workshop-staff/department/create';
  static const String billingDashboardEndpoint = '/workshop-staff/billing-dashboard';
  static const String reportsAnalyticsEndpoint = '/workshop-staff/reports-analytics';
  static const String createCorporateAccountEndpoint = '/workshop-staff/corporate-account/create';
  static const String createCorporateUserEndpoint = '/workshop-staff/corporate-user/create';
  static const String corporateCustomersEndpoint = '/workshop-staff/corporate-customers';
  static const String createTechnicianEndpoint = '/workshop-staff/technician/create';
  static const String createCashierEndpoint = '/workshop-staff/cashier/create';
  static const String createSupplierEndpoint = '/workshop-staff/supplier/create';
  static const String departmentsEndpoint = '/workshop-staff/departments';
  static const String categoriesEndpoint = '/workshop-staff/categories';
  static const String techniciansEndpoint = '/workshop-staff/technicians';
  static const String productsEndpoint = '/workshop-staff/products';
  static const String dashboardEndpoint = '/workshop-staff/dashboard';
  static const String promoCodesEndpoint = '/workshop-staff/promo-codes';
  static const String createPromoCodeEndpoint = '/workshop-staff/promo-code/create';

  ///// technician /////
  static const String technicianLoginEndpoint = '/auth/technician/login';
}
