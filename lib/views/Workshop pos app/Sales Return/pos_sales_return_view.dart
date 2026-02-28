import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../models/create_invoice_model.dart';
import 'sales_return_view_model.dart';

class PosSalesReturnView extends StatefulWidget {
  const PosSalesReturnView({super.key});

  @override
  State<PosSalesReturnView> createState() => _PosSalesReturnViewState();
}

class _PosSalesReturnViewState extends State<PosSalesReturnView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesReturnViewModel>().clearSelection();
      context.read<SalesReturnViewModel>().searchController.clear();
      context.read<SalesReturnViewModel>().searchInvoice(); // clears results
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final vm = context.watch<SalesReturnViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PosScreenAppBar(
        title: (!isTablet && vm.selectedInvoice != null)
            ? 'Return - ${vm.selectedInvoice!.invoiceNo.isNotEmpty ? vm.selectedInvoice!.invoiceNo : vm.selectedInvoice!.id}'
            : 'Sales Return',
        showBackButton: (!isTablet && vm.selectedInvoice != null),
        showHamburger: !(!isTablet && vm.selectedInvoice != null),
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
        onBack: () {
          vm.clearSelection();
        },
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side: Search and Results
          if (isTablet || vm.selectedInvoice == null)
            Expanded(
              flex: isTablet ? 4 : 10,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildSearchHeader(vm),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        children: [
                          Container(width: 3, height: 14, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(1.5))),
                          const SizedBox(width: 8),
                          const Text('See Results', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E2124))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildSearchResults(vm),
                    ),
                  ],
                ),
              ),
            ),
          
          if (isTablet) const VerticalDivider(width: 1),
          
          // Right side: Return Form (visible if invoice selected)
          if (isTablet || vm.selectedInvoice != null)
            Expanded(
              flex: isTablet ? 6 : (vm.selectedInvoice != null ? 10 : 0),
              child: vm.selectedInvoice == null 
                  ? _buildEmptyState()
                  : _buildReturnDetails(vm, isTablet),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(SalesReturnViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Invoice to Return',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E2124), letterSpacing: -0.3),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: AppColors.secondaryLight.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, 5))
                    ]
                  ),
                  child: TextField(
                    controller: vm.searchController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'e.g. INV-123 or Name/Phone',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                    ),
                    onSubmitted: (_) => vm.searchInvoice(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppColors.secondaryLight.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))
                  ]
                ),
                child: SizedBox(
                  height: 52,
                  width: 52,
                  child: ElevatedButton(
                    onPressed: vm.isSearching ? null : vm.searchInvoice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryLight,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: vm.isSearching 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_rounded, size: 22),
                  ),
                ),
              ),
            ],
          ),
          if (vm.searchError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade100)),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.red.shade600, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(vm.searchError!, style: TextStyle(color: Colors.red.shade800, fontSize: 13, fontWeight: FontWeight.w600))),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildSearchResults(SalesReturnViewModel vm) {
    if (vm.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (vm.searchController.text.isNotEmpty && vm.searchResults.isEmpty && vm.searchError == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No invoices found for "${vm.searchController.text}"', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: vm.searchResults.length,
      itemBuilder: (context, index) {
        final inv = vm.searchResults[index];
        final isSelected = vm.selectedInvoice?.id == inv.id;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: isSelected 
                  ? LinearGradient(colors: [Colors.white, AppColors.primaryLight.withValues(alpha: 0.15)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                  : const LinearGradient(colors: [Colors.white, Colors.white]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.6) : Colors.transparent, width: 1.5),
              boxShadow: [
                BoxShadow(color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.04), blurRadius: isSelected ? 20 : 10, offset: const Offset(0, 4))
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => vm.selectInvoice(inv),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.2) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.receipt_long_rounded, size: 18, color: isSelected ? AppColors.primaryLight : Colors.grey.shade600),
                              ),
                              const SizedBox(width: 12),
                              Text(inv.invoiceNo.isNotEmpty ? inv.invoiceNo : inv.id, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E2124), letterSpacing: -0.3)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                            ),
                            child: Text('SAR ${inv.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.green.shade700, fontSize: 13)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), shape: BoxShape.circle),
                            child: Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey.shade600),
                          ),
                          const SizedBox(width: 6),
                          Text(inv.customerName.isNotEmpty ? inv.customerName : 'Walk-in Customer', style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 6),
                          Text(
                            inv.invoiceDate.isNotEmpty ? inv.invoiceDate.split('T')[0] : '',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))
              ]
            ),
            child: Icon(Icons.assignment_return_rounded, size: 64, color: AppColors.secondaryLight.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 32),
          const Text('Select an Invoice', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E2124), letterSpacing: -0.5)),
          const SizedBox(height: 12),
          Text(
            'Search and select an invoice from the left\nto initiate its sales return process.', 
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15, height: 1.5, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReturnDetails(SalesReturnViewModel vm, bool isTablet) {
    final inv = vm.selectedInvoice!;
    
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isTablet) ...[
                    Text('Return - ${inv.invoiceNo.isNotEmpty ? inv.invoiceNo : inv.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E2124))),
                    const SizedBox(height: 24),
                  ],
                  _buildSectionTitle('Select Items to Return', Icons.inventory_2_rounded),
                  const SizedBox(height: 16),
                  
                  // Item List
                  Column(
                    children: inv.items.map((item) => _buildReturnItemRow(item, vm)).toList(),
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionTitle('Return Proof (Optional)', Icons.add_photo_alternate_rounded),
                  const SizedBox(height: 16),
                  _buildImagePicker(vm),
                  const SizedBox(height: 60), // spacer
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, -8))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: vm.isSubmitting ? null : vm.clearSelection,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF1E2124), fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: vm.isSubmitting ? null : () => vm.submitReturnRequest(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: AppColors.secondaryLight,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: vm.isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.secondaryLight, strokeWidth: 2))
                          : const Text('Submit Return', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnItemRow(InvoiceItem item, SalesReturnViewModel vm) {
    final isSelected = vm.selectedItems[item.id] ?? false;
    final double qty = vm.returnQuantities[item.id] ?? 1.0;
    final reason = vm.returnReasons[item.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppColors.primaryLight : Colors.transparent, width: 1.5),
        boxShadow: [
          BoxShadow(color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.04), blurRadius: isSelected ? 20 : 10, offset: const Offset(0, 4))
        ]
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              onTap: () => vm.toggleItemSelection(item.id, !isSelected, item.qty),
              borderRadius: isSelected ? const BorderRadius.vertical(top: Radius.circular(16)) : BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? AppColors.primaryLight : Colors.grey.shade400, width: 2),
                        boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryLight.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))] : [],
                      ),
                      width: 24,
                      height: 24,
                      child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isSelected ? AppColors.primaryLight : const Color(0xFF1E2124))),
                          const SizedBox(height: 4),
                          Text('${item.qty.toStringAsFixed(0)}x @ SAR ${item.unitPrice.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.1) : Colors.grey.shade50, 
                        borderRadius: BorderRadius.circular(12), 
                        border: Border.all(color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.2) : Colors.grey.shade200)
                      ),
                      child: Text('SAR ${(item.qty * item.unitPrice).toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isSelected ? AppColors.primaryLight : const Color(0xFF1E2124))),
                    ),
                  ],
                ),
              ),
            ),
          
          // Expanded Return Config
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
                color: Colors.grey.shade50.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Qty Stepper
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: AppColors.primaryLight.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: Icon(Icons.numbers_rounded, size: 16, color: AppColors.primaryLight),
                            ),
                            const SizedBox(width: 12),
                            const Text('Return Qty', style: TextStyle(fontSize: 14, color: Color(0xFF1E2124), fontWeight: FontWeight.w800)),
                          ],
                        ),
                        _buildStepper(item.id, qty, item.qty, vm),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Reason Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: reason,
                        isExpanded: true,
                        hint: Text('Select Return Reason', style: TextStyle(fontSize: 15, color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                          child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600, size: 18),
                        ),
                        style: const TextStyle(fontSize: 15, color: Color(0xFF1E2124), fontWeight: FontWeight.w700),
                        items: vm.returnReasonOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            vm.updateReturnReason(item.id, newValue);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildStepper(String itemId, double currentQty, double maxQty, SalesReturnViewModel vm) {
    // Generate controller with the current value.
    final String displayVal = currentQty == currentQty.truncateToDouble()
        ? currentQty.toInt().toString()
        : currentQty.toString();

    final controller = TextEditingController(text: displayVal);

    // Moves cursor to the end when tapped/focused
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepButton(
          icon: Icons.remove_rounded,
          isEnabled: currentQty > 0.1,
          onPressed: () {
            double newQty = currentQty - 1;
            if (newQty < 0.1) newQty = 0.1;
            vm.updateReturnQuantity(itemId, newQty);
          },
        ),
        Container(
          width: 50,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                // Validate on blur
                final parsed = double.tryParse(controller.text);
                if (parsed != null && parsed > 0 && parsed <= maxQty) {
                  vm.updateReturnQuantity(itemId, parsed);
                } else {
                  // Revert to valid value
                  vm.updateReturnQuantity(itemId, currentQty);
                  controller.text = displayVal;
                }
              }
            },
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1E2124)),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onFieldSubmitted: (val) {
                final parsed = double.tryParse(val);
                if (parsed != null && parsed > 0 && parsed <= maxQty) {
                   vm.updateReturnQuantity(itemId, parsed);
                } else {
                  vm.updateReturnQuantity(itemId, currentQty);
                  controller.text = displayVal;
                }
              },
            ),
          ),
        ),
        _buildStepButton(
          icon: Icons.add_rounded,
          isEnabled: currentQty < maxQty,
          onPressed: () {
            double newQty = currentQty + 1;
            if (newQty > maxQty) newQty = maxQty;
            vm.updateReturnQuantity(itemId, newQty);
          },
        ),
      ],
    );
  }

  Widget _buildStepButton({required IconData icon, required bool isEnabled, required VoidCallback onPressed}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.primaryLight : Colors.grey.shade100,
        shape: BoxShape.circle,
        boxShadow: isEnabled ? [BoxShadow(color: AppColors.primaryLight.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: isEnabled ? Colors.white : Colors.grey.shade400),
        padding: EdgeInsets.zero,
        onPressed: isEnabled ? onPressed : null,
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(1.5))),
        const SizedBox(width: 8),
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E2124))),
      ],
    );
  }
  
  Widget _buildImagePicker(SalesReturnViewModel vm) {
    return GestureDetector(
      onTap: vm.pickProofImage,
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: vm.proofImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                   ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(vm.proofImage!, fit: BoxFit.cover)),
                   Positioned(
                     top: 8, right: 8,
                     child: GestureDetector(
                       onTap: vm.pickProofImage, // Allow changing image on tap
                       child: Container(
                         padding: const EdgeInsets.all(8),
                         decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                         child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                       ),
                     ),
                   )
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.secondaryLight.withValues(alpha: 0.05), shape: BoxShape.circle),
                    child: Icon(Icons.add_a_photo_rounded, color: AppColors.secondaryLight, size: 24),
                  ),
                  const SizedBox(height: 12),
                  const Text('Upload defect image or invoice proof', style: TextStyle(color: Color(0xFF1E2124), fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('JPG, PNG up to 5MB', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
      ),
    );
  }
}
