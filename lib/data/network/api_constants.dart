class ApiConstants {

  static const String baseUrl = 'https://filterbackend-production.up.railway.app';


  //// workshop pos ////
  static const String loginEndpoint = '/auth/cashier/login';
  static const String servicesEndpoint = '/services';
  static const String walkInCustomerEndpoint = '/cashier/walk-in-order';
  static String assignTechnicianEndpoint(String jobId) => '/cashier/job/$jobId/assign';
  static const String cashierOrdersEndpoint = '/cashier/orders';
  static const String searchCustomerEndpoint = '/cashier/customers/search';
  static const String createInvoiceEndpoint = '/cashier/invoice/create';
  static const String getInvoiceByOrderEndpoint = '/cashier/invoice/by-order';
  static const String promoCodeApplyEndpoint = '/cashier/promo-code/apply';
  static const String expenseCategoriesEndpoint = '/cashier/expense-categories';
  static const String expenseSubmitEndpoint = '/cashier/expense/submit';
  static const String walletBalanceEndpoint = '/cashier/wallet/balance';



  ///// admin //////
  static const String adminLoginEndpoint = '/auth/workshop/login';
  static const String createBranchEndpoint = '/workshop-staff/branch/create';
  static const String getBranchesEndpoint = '/workshop-staff/branches';
  static const String createProductEndpoint = '/workshop-products/products';
  static const String createDepartmentEndpoint = '/workshop-staff/department/create';
  static const String createCorporateAccountEndpoint = '/workshop-staff/corporate-account/create';
  static const String createCorporateUserEndpoint = '/workshop-staff/corporate-user/create';
  static const String createTechnicianEndpoint = '/workshop-staff/technician/create';
  static const String createCashierEndpoint = '/workshop-staff/cashier/create';
  static const String createSupplierEndpoint = '/workshop-staff/supplier/create';
  static const String departmentsEndpoint = '/workshop-staff/departments';
  static const String techniciansEndpoint = '/workshop-staff/technicians';
  static const String productsEndpoint = '/workshop-staff/products';



  ///// technician /////
  static const String technicianLoginEndpoint = '/auth/technician/login';
}
