import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';
import 'package:provider/provider.dart';
import 'suppliers_view_model.dart';

class SuppliersView extends StatefulWidget {
  const SuppliersView({super.key});

  @override
  State<SuppliersView> createState() => _SuppliersViewState();
}

class _SuppliersViewState extends State<SuppliersView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Supplier> _suppliers = [
    Supplier(id: '1', name: 'Al-Rashid Auto Parts', category: 'Parts', mobile: '+966501234567', vatNumber: '310012345678', outstanding: 12500, status: 'active'),
    Supplier(id: '2', name: 'Gulf Lubricants Co.', category: 'Lubricants', mobile: '+966507654321', vatNumber: '310098765432', outstanding: 0, status: 'active'),
    Supplier(id: '3', name: 'National Filters Supply', category: 'Filters', mobile: '+966509988776', vatNumber: '310011223344', outstanding: 3200, status: 'active'),
    Supplier(id: '4', name: 'Internal Warehouse', category: 'Internal', mobile: '-', outstanding: 0, status: 'active'),
  ];

  final List<PurchaseInvoice> _invoices = [
    PurchaseInvoice(id: 'PO-001', supplierId: '1', supplierName: 'Al-Rashid Auto Parts', date: DateTime.now().subtract(const Duration(days: 2)), items: [PurchaseItem(productName: 'Oil Filter', qty: 50, unit: 'pcs', unitPrice: 15), PurchaseItem(productName: 'Air Filter', qty: 30, unit: 'pcs', unitPrice: 25)], status: 'approved'),
    PurchaseInvoice(id: 'PO-002', supplierId: '2', supplierName: 'Gulf Lubricants Co.', date: DateTime.now().subtract(const Duration(days: 1)), items: [PurchaseItem(productName: 'Engine Oil 5W-30', qty: 100, unit: 'ltr', unitPrice: 18)], status: 'pending'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: OwnerAppBar(
        title: 'Suppliers & Purchases',
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddSupplierSheet(context),
              backgroundColor: AppColors.secondaryLight,
              icon: const Icon(Icons.person_add_rounded, color: Colors.white),
              label: const Text('Add Supplier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            )
          : FloatingActionButton.extended(
              onPressed: () => _showNewPurchaseSheet(context),
              backgroundColor: AppColors.secondaryLight,
              icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
              label: const Text('New Purchase', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
      body: Column(
        children: [
          _buildSummaryRow(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildSupplierList(), _buildInvoiceList()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    final totalOutstanding = _suppliers.fold(0.0, (s, sup) => s + sup.outstanding);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatCard('Suppliers', '${_suppliers.length}', Icons.store_rounded, AppColors.primaryLight),
          const SizedBox(width: 12),
          _buildStatCard('Outstanding', 'SAR ${totalOutstanding.toInt()}', Icons.account_balance_wallet_rounded, Colors.orange),
          const SizedBox(width: 12),
          _buildStatCard('Pending POs', '${_invoices.where((i) => i.status == 'pending').length}', Icons.pending_rounded, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.08)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.secondaryLight)),
            ),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        labelColor: AppColors.secondaryLight,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
        tabs: const [Tab(text: 'Suppliers'), Tab(text: 'Purchase Orders')],
      ),
    );
  }

  Widget _buildSupplierList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _suppliers.length,
      itemBuilder: (context, index) {
        final s = _suppliers[index];
        final isInternal = s.category == 'Internal';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isInternal ? AppColors.primaryLight.withOpacity(0.15) : AppColors.secondaryLight.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(isInternal ? Icons.warehouse_rounded : Icons.store_rounded, color: isInternal ? AppColors.primaryLight : AppColors.secondaryLight, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(s.name, style: AppTextStyles.h2.copyWith(fontSize: 14, color: AppColors.secondaryLight)),
                        if (isInternal) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                            child: const Text('INTERNAL', style: TextStyle(color: AppColors.primaryLight, fontSize: 8, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(s.category, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (s.outstanding > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('SAR ${s.outstanding.toInt()}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 13)),
                    const Text('Outstanding', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w600)),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvoiceList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _invoices.length,
      itemBuilder: (context, index) {
        final inv = _invoices[index];
        final isPending = inv.status == 'pending';
        final statusColor = isPending ? Colors.orange : Colors.green;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.receipt_long_rounded, color: statusColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(inv.id, style: AppTextStyles.h2.copyWith(fontSize: 14, color: AppColors.secondaryLight)),
                    const SizedBox(height: 2),
                    Text(inv.supplierName, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('SAR ${inv.totalAmount.toInt()}', style: AppTextStyles.h2.copyWith(fontSize: 14, color: AppColors.secondaryLight)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(inv.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNewPurchaseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _NewPurchaseSheet(),
    );
  }

  void _showAddSupplierSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider.value(
        value: context.read<SuppliersViewModel>(),
        child: const _AddSupplierSheet(),
      ),
    );
  }
}

class _NewPurchaseSheet extends StatefulWidget {
  const _NewPurchaseSheet();

  @override
  State<_NewPurchaseSheet> createState() => _NewPurchaseSheetState();
}

class _NewPurchaseSheetState extends State<_NewPurchaseSheet> {
  int _step = 0;
  String? _selectedSupplier;
  final List<Map<String, dynamic>> _items = [];

  final List<String> _suppliers = ['Al-Rashid Auto Parts', 'Gulf Lubricants Co.', 'National Filters Supply', 'Internal Warehouse'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        children: [
          _buildHandle(),
          _buildStepIndicator(),
          Expanded(child: _buildStepContent()),
          _buildNavButtons(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40, height: 5,
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Select Supplier', 'Add Items', 'Confirm'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _step;
          final isDone = i < _step;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: isDone ? Colors.green : isActive ? AppColors.primaryLight : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: isDone ? const Icon(Icons.check, color: Colors.white, size: 14) : Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: isActive ? AppColors.secondaryLight : Colors.grey))),
                    ),
                    const SizedBox(height: 4),
                    Text(steps[i], style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: isActive ? AppColors.secondaryLight : Colors.grey)),
                  ],
                ),
                if (i < steps.length - 1)
                  Expanded(child: Container(height: 1, color: i < _step ? Colors.green : Colors.grey.shade200, margin: const EdgeInsets.only(bottom: 16))),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _step == 0 ? _buildStep1() : _step == 1 ? _buildStep2() : _buildStep3(),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Supplier', style: AppTextStyles.h2.copyWith(fontSize: 18)),
        const SizedBox(height: 6),
        const Text('Choose from your registered suppliers.', style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 24),
        ..._suppliers.map((s) {
          final isInternal = s == 'Internal Warehouse';
          final isSelected = _selectedSupplier == s;
          return GestureDetector(
            onTap: () => setState(() => _selectedSupplier = s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight.withOpacity(0.1) : const Color(0xFFF8F9FD),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? AppColors.primaryLight : Colors.transparent, width: 2),
              ),
              child: Row(
                children: [
                  Icon(isInternal ? Icons.warehouse_rounded : Icons.store_rounded, color: isSelected ? AppColors.primaryLight : Colors.grey, size: 22),
                  const SizedBox(width: 14),
                  Text(s, style: TextStyle(fontWeight: FontWeight.w700, color: isSelected ? AppColors.secondaryLight : Colors.grey.shade700)),
                  if (isInternal) ...[
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: const Text('INTERNAL', style: TextStyle(color: AppColors.primaryLight, fontSize: 8, fontWeight: FontWeight.w900))),
                  ],
                  const Spacer(),
                  if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight, size: 20),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add Items', style: AppTextStyles.h2.copyWith(fontSize: 18)),
        const SizedBox(height: 6),
        Text('Supplier: $_selectedSupplier', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 24),
        ..._items.asMap().entries.map((e) => _buildItemRow(e.key, e.value)),
        OutlinedButton.icon(
          onPressed: () => setState(() => _items.add({'name': '', 'qty': '', 'unit': 'pcs', 'price': ''})),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Item'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
      ],
    );
  }

  Widget _buildItemRow(int index, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Product Name', border: InputBorder.none, isDense: true),
            style: const TextStyle(fontWeight: FontWeight.w700),
            onChanged: (v) => setState(() => _items[index]['name'] = v),
          ),
          Row(
            children: [
              Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Qty', border: InputBorder.none, isDense: true), keyboardType: TextInputType.number, onChanged: (v) => setState(() => _items[index]['qty'] = v))),
              Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Unit Price', border: InputBorder.none, isDense: true), keyboardType: TextInputType.number, onChanged: (v) => setState(() => _items[index]['price'] = v))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm Order', style: AppTextStyles.h2.copyWith(fontSize: 18)),
        const SizedBox(height: 6),
        const Text('Review before submitting for approval.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              _buildConfirmRow('Supplier', _selectedSupplier ?? '-'),
              _buildConfirmRow('Items', '${_items.length} items'),
              _buildConfirmRow('Status', 'Pending Approval'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('This PO will be submitted for manager approval before stock is updated.', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.secondaryLight)),
        ],
      ),
    );
  }

  Widget _buildNavButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step--),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Back'),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_step < 2) {
                  setState(() => _step++);
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _step == 2 ? Colors.green : AppColors.secondaryLight,
                minimumSize: const Size.fromHeight(52),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(_step == 2 ? 'Submit for Approval' : 'Next', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddSupplierSheet extends StatelessWidget {
  const _AddSupplierSheet();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SuppliersViewModel>();

    return FocusScope(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Register New Supplier', style: AppTextStyles.h2.copyWith(fontSize: 22)),
                    const SizedBox(height: 8),
                    const Text('Provide details to add a new supplier.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),
                    _buildTextField('Supplier Name', Icons.business_rounded, vm.nameController),
                    _buildTextField('Email Address', Icons.email_rounded, vm.emailController),
                    _buildTextField('Mobile Number', Icons.phone_android_rounded, vm.mobileController),
                    _buildTextField('Address', Icons.map_rounded, vm.addressController),
                    _buildTextField('Opening Balance', Icons.account_balance_wallet_rounded, vm.openingBalanceController, isNumber: true),
                    _buildTextField('Password', Icons.lock_rounded, vm.passwordController, obscureText: true),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: vm.isLoading ? null : () => vm.submitSupplierForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        minimumSize: const Size.fromHeight(56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: vm.isLoading
                          ? const CircularProgressIndicator(color: AppColors.secondaryLight)
                          : const Text(
                              'Save Supplier',
                              style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isNumber = false, bool obscureText = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.secondaryLight, size: 20),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
