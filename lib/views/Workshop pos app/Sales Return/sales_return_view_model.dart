import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../services/session_service.dart';
import '../../../../data/repositories/pos_repository.dart';
import '../../../../models/create_invoice_model.dart';
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

      // Note: Backend might not support a global invoice search like this natively yet. 
      // For demonstration and to adhere to the flow, we will simulate matching an order/invoice by querying the PosViewModel or mocking it.
      // E.g. fetch single invoice if it matches
      
      // Mocking for now to emulate the search. A real API call `searchInvoices(query)` would go here.
      await Future.delayed(const Duration(seconds: 1));
      
      if (query.toLowerCase() == 'inv-123') {
        _searchResults = [
          Invoice(
            id: 'mock_inv_123',
            invoiceNo: 'INV-123',
            invoiceDate: DateTime.now().toIso8601String(),
            subtotal: 500,
            vatAmount: 75,
            discountAmount: 0,
            totalAmount: 575,
            paymentStatus: 'PAID',
            customerName: 'Mock Customer',
            vehicleInfo: 'Toyota Camry',
            plateNo: 'ABC-123',
            items: [
              InvoiceItem(id: 'item1', productName: 'Premium Oil Change', qty: 1, unitPrice: 300, lineTotal: 300),
              InvoiceItem(id: 'item2', productName: 'Oil Filter', qty: 1, unitPrice: 100, lineTotal: 100),
              InvoiceItem(id: 'item3', productName: 'Engine Flush', qty: 1, unitPrice: 100, lineTotal: 100),
            ],
          )
        ];
      } else {
        _searchResults = [];
      }

    } catch (e) {
      _searchError = e.toString().replaceFirst('Exception: ', '');
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
      // Mock network delay
      await Future.delayed(const Duration(seconds: 2));

      // Real implementation would gather _selectedItems, _returnQuantities, _returnReasons, _proofImage, and _selectedInvoice.id
      // and call posRepository.submitSalesReturn(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Return request submitted – pending approval');
      }

      // Reset state on success
      clearSelection();
      searchController.clear();
      _searchResults = [];

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
