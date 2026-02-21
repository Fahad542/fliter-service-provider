class ApiConstants {

  //// workshop pos ////
  static const String baseUrl = 'https://filterbackend-production.up.railway.app';
  static const String loginEndpoint = '/auth/cashier/login';
  static const String servicesEndpoint = '/services';
  static const String departmentsEndpoint = '/workshop-staff/departments';
  static const String walkInCustomerEndpoint = '/cashier/walk-in-order';
  static const String techniciansEndpoint = '/workshop-staff/technicians';
  static String assignTechnicianEndpoint(String jobId) => '/cashier/job/$jobId/assign';
  static const String cashierOrdersEndpoint = '/cashier/orders';
  static const String searchCustomerEndpoint = '/cashier/customers/search';
  static const String productsEndpoint = '/workshop-staff/products';
  static const String createInvoiceEndpoint = '/cashier/invoice/create';
  static const String getInvoiceByOrderEndpoint = '/cashier/invoice/by-order';
  static const String promoCodeApplyEndpoint = '/cashier/promo-code/apply';
  static const String expenseCategoriesEndpoint = '/cashier/expense-categories';
  static const String expenseSubmitEndpoint = '/cashier/expense/submit';
  static const String walletBalanceEndpoint = '/cashier/wallet/balance';
}
