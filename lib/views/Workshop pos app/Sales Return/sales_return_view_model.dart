import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../services/session_service.dart';
import '../../../../data/repositories/pos_repository.dart';
import '../../../../models/create_invoice_model.dart';
import '../../../../models/submit_sales_return_model.dart';
import '../../../../utils/toast_service.dart';

class SalesReturnViewModel extends ChangeNotifier {
  final SessionService sessionService;
  final PosRepository posRepository;

  SalesReturnViewModel({
    required this.sessionService,
    required this.posRepository,
  });

  // Search State
  final searchController = TextEditingController();
  bool _isSearching = false;
  String? _searchError;
  List<Invoice> _searchResults = [];

  // Return Details State
  Invoice? _selectedInvoice;
  final Map<String, bool> _selectedItems = {};
  final Map<String, double> _returnQuantities = {};
  final Map<String, String> _returnReasons = {};
  File? _proofImage;
  bool _isSubmitting = false;

  final List<String> returnReasonOptions = [
    'Defective Product/Service',
    'Customer Cancellation',
    'Wrong Item / Service',
    'Other'
  ];

  // Getters
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;
  List<Invoice> get searchResults => _searchResults;
  
  Invoice? get selectedInvoice => _selectedInvoice;
  Map<String, bool> get selectedItems => _selectedItems;
  Map<String, double> get returnQuantities => _returnQuantities;
  Map<String, String> get returnReasons => _returnReasons;
  File? get proofImage => _proofImage;
  bool get isSubmitting => _isSubmitting;

  Future<void> searchInvoice() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;

    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');

      final response = await posRepository.getInvoicedOrdersByCustomer(query, token);

      if (response.success) {
        _searchResults = response.orders.map((order) {
          return Invoice(
            id: order.invoiceId,
            invoiceNo: order.invoiceNo.isNotEmpty ? order.invoiceNo : order.invoiceId,

            invoiceDate: order.createdAt,
            subtotal: order.totalAmount, // Assuming no other breakdown available
            vatAmount: 0,
            discountAmount: order.totalDiscountValue,
            totalAmount: order.totalAmount,
            paymentStatus: order.status,
            customerName: 'Customer ID: $query', // Emulate customer info if not fetched
            customerType: '',
            vehicleInfo: '',
            plateNo: '',
            items: order.items.map((item) {
              return InvoiceItem(
                id: item.id,
                productName: item.productName,
                qty: item.qty,
                unitPrice: item.unitPrice,
                lineTotal: item.lineTotal,
              );
            }).toList(),
            departments: [],
            payments: [],
          );
        }).toList();
      } else {
        _searchResults = [];
      }

    } catch (e) {
      _searchError = 'Error fetching invoices. Ensure customer ID is correct.';
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void selectInvoice(Invoice invoice) {
    _selectedInvoice = invoice;
    _selectedItems.clear();
    _returnQuantities.clear();
    _returnReasons.clear();
    _proofImage = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedInvoice = null;
    _selectedItems.clear();
    _returnQuantities.clear();
    _returnReasons.clear();
    _proofImage = null;
    notifyListeners();
  }

  void toggleItemSelection(String itemId, bool isSelected, double maxQty) {
    _selectedItems[itemId] = isSelected;
    if (isSelected) {
      _returnQuantities[itemId] = maxQty;
      _returnReasons[itemId] = returnReasonOptions.first;
    } else {
      _returnQuantities.remove(itemId);
      _returnReasons.remove(itemId);
    }
    notifyListeners();
  }

  void updateReturnQuantity(String itemId, double qty) {
    _returnQuantities[itemId] = qty;
    notifyListeners();
  }

  void updateReturnReason(String itemId, String reason) {
    _returnReasons[itemId] = reason;
    notifyListeners();
  }

  Future<void> pickProofImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _proofImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> submitReturnRequest(BuildContext context) async {
    if (_selectedInvoice == null) return;
    
    final selectedItemsCount = _selectedItems.values.where((v) => v).length;
    if (selectedItemsCount == 0) {
      ToastService.showError(context, 'Please select at least one item to return');
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Authentication token not found');

      final List<SalesReturnItem> returnItems = [];
      _selectedItems.forEach((itemId, isSelected) {
        if (isSelected && _returnQuantities.containsKey(itemId)) {
           returnItems.add(SalesReturnItem(
             salesOrderItemId: itemId,
             qty: _returnQuantities[itemId] ?? 1.0,
           ));
        }
      });

      // Just picking the first selected item's reason for the general reason string
      String generalReason = 'Defective Product/Service';
      if (_returnReasons.isNotEmpty) {
        generalReason = _returnReasons.values.first;
      }

      final request = SubmitSalesReturnRequest(
        invoiceId: _selectedInvoice!.id,
        reason: generalReason,
        proofUrl: null, // Image upload requires a distinct mechanism, leaving null for now based on API definition
        items: returnItems,
      );

      final response = await posRepository.submitSalesReturn(request, token);

      if (response.success) {
        if (context.mounted) {
          ToastService.showSuccess(context, 'Return request submitted successfully');
        }

        // Reset state on success
        clearSelection();
        searchController.clear();
        _searchResults = [];
      } else {
        throw Exception(response.message);
      }

    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to submit request: ${e.toString()}');
      }
    } finally {
      if (context.mounted) {
        _isSubmitting = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
