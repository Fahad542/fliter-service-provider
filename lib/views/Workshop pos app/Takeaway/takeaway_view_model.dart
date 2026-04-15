import 'package:flutter/material.dart';
import 'dart:convert';

import '../../../../data/network/base_api_service.dart';
import '../../../../data/repositories/pos_repository.dart';
import '../../../../models/create_invoice_model.dart';
import '../../../../models/takeaway_models.dart';
import '../../../../services/session_service.dart';

class TakeawayCartLine {
  TakeawayCartLine({
    required this.product,
    required this.qty,
    required this.unitPrice,
    this.lineDiscountType,
    this.lineDiscountValue = 0,
  });

  final TakeawayProduct product;
  double qty;
  /// VAT-inclusive unit price.
  double unitPrice;
  String? lineDiscountType;
  double lineDiscountValue;

  /// VAT-exclusive unit price.
  double get unitPriceExclVat =>
      ((unitPrice / 1.15) * 100).roundToDouble() / 100;
}

class TakeawayViewModel extends ChangeNotifier {
  TakeawayViewModel({
    required this.posRepository,
    required this.sessionService,
  }) {
    // Keep invoice preview sheet reactive for every field edit.
    vatController.addListener(_onPreviewInputChanged);
    orderDiscountValueController.addListener(_onPreviewInputChanged);
    promoCodeController.addListener(_onPreviewInputChanged);
  }

  final PosRepository posRepository;
  final SessionService sessionService;
  
  void _onPreviewInputChanged() {
    notifyListeners();
  }

  TakeawayCatalogData? _catalog;
  bool _catalogLoading = false;
  String? _catalogError;

  final List<TakeawayCartLine> _cart = [];
  String? _selectedDepartmentId;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final TextEditingController searchController = TextEditingController();

  bool _checkoutLoading = false;
  String? _checkoutError;
  Invoice? _lastInvoice;
  String? _lastOrderId;
  String _appliedPromoCode = '';
  String? _appliedPromoCodeId;
  double _promoDiscountValue = 0;
  bool _isPromoPercent = false;

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerMobileController =
      TextEditingController();
  final TextEditingController customerTaxIdController =
      TextEditingController();
  final TextEditingController promoCodeController = TextEditingController();
  final TextEditingController vatController = TextEditingController();
  final TextEditingController invoiceDateController = TextEditingController();
  final TextEditingController discountAmountController =
      TextEditingController();
  final TextEditingController orderDiscountValueController =
      TextEditingController();

  String _orderDiscountType = '';
  String? _paymentMethod = 'Cash';
  List<Map<String, dynamic>>? _payments;

  TakeawayCatalogData? get catalog => _catalog;
  bool get catalogLoading => _catalogLoading;
  String? get catalogError => _catalogError;

  List<TakeawayCartLine> get cart => List.unmodifiable(_cart);
  int get cartLineCount => _cart.length;
  double get cartQtyTotal => _cart.fold<double>(0, (a, b) => a + b.qty);

  String? get selectedDepartmentId => _selectedDepartmentId;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  /// Matches POS [getCartCount]: sum of piece counts for the bottom bar label.
  int get cartItemCountDisplay => _cart.fold<int>(
        0,
        (sum, line) => sum + (line.qty >= 1 ? line.qty.round() : 1),
      );

  bool get catalogHasProducts {
    if (_catalog == null) return false;
    for (final c in _catalog!.categories) {
      if (c.products.isNotEmpty) return true;
    }
    return _catalog!.uncategorizedProducts.isNotEmpty;
  }

  bool get checkoutLoading => _checkoutLoading;
  String? get checkoutError => _checkoutError;
  Invoice? get lastInvoice => _lastInvoice;
  String? get lastOrderId => _lastOrderId;

  String get orderDiscountType => _orderDiscountType;
  String? get paymentMethod => _paymentMethod;
  List<Map<String, dynamic>>? get payments => _payments;
  String get appliedPromoCode => _appliedPromoCode;
  String? get appliedPromoCodeId => _appliedPromoCodeId;
  double get promoDiscountValue => _promoDiscountValue;
  bool get isPromoPercent => _isPromoPercent;

  static const List<String> paymentMethods = [
    'Cash',
    'Bank transfer',
    'tamara',
    'Tabby',
    'corporate credit',
  ];

  void setSelectedDepartmentId(String? id) {
    _selectedDepartmentId = id;
    _selectedCategory = 'All';
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setOrderDiscountType(String? type) {
    _orderDiscountType = type ?? '';
    notifyListeners();
  }

  void setPaymentMethod(String? m) {
    _paymentMethod = m;
    _payments = null;
    notifyListeners();
  }

  void setPayments(List<Map<String, dynamic>> p) {
    _paymentMethod = null;
    _payments = p;
    notifyListeners();
  }

  void setAppliedPromo({
    required String code,
    String? promoId,
    required double discount,
    required bool isPercent,
  }) {
    _appliedPromoCode = code;
    _appliedPromoCodeId = promoId;
    _promoDiscountValue = discount;
    _isPromoPercent = isPercent;
    promoCodeController.text = code;
    notifyListeners();
  }

  void clearAppliedPromo() {
    _appliedPromoCode = '';
    _appliedPromoCodeId = null;
    _promoDiscountValue = 0;
    _isPromoPercent = false;
    promoCodeController.clear();
    notifyListeners();
  }

  void setOrderDiscountValue(double v) {
    // Controller already holds latest typed value from the field.
    notifyListeners();
  }

  void clearCheckoutError() {
    _checkoutError = null;
    notifyListeners();
  }

  void refreshPreview() => notifyListeners();

  Future<void> loadCatalog() async {
    if (_catalogLoading) return;
    _catalogLoading = true;
    _catalogError = null;
    notifyListeners();
    try {
      final token = await sessionService.getToken();
      if (token == null || token.isEmpty) {
        _catalogError = 'Not logged in';
        _catalogLoading = false;
        notifyListeners();
        return;
      }
      _catalog = await posRepository.getTakeawayProductsCatalog(token);
      if (vatController.text.trim().isEmpty &&
          _catalog!.vatPercentDefault > 0) {
        final v = _catalog!.vatPercentDefault;
        vatController.text = v == v.roundToDouble()
            ? v.round().toString()
            : v.toStringAsFixed(2);
      }
    } on AppException catch (e) {
      _catalogError = e.toString();
    } catch (e) {
      _catalogError = e.toString();
    } finally {
      _catalogLoading = false;
      notifyListeners();
    }
  }

  /// Department + search only (used for category chip labels).
  List<TakeawayProduct> get _baseFilteredProducts {
    if (_catalog == null) return [];
    final q = _searchQuery.trim().toLowerCase();
    final deptId = _selectedDepartmentId;

    bool matchesDept(TakeawayProduct p) {
      if (deptId == null || deptId.isEmpty) return true;
      return p.department.id == deptId;
    }

    bool matchesSearch(TakeawayProduct p) {
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q);
    }

    final out = <TakeawayProduct>[];
    for (final c in _catalog!.categories) {
      for (final p in c.products) {
        if (matchesDept(p) && matchesSearch(p)) out.add(p);
      }
    }
    for (final p in _catalog!.uncategorizedProducts) {
      if (matchesDept(p) && matchesSearch(p)) out.add(p);
    }
    out.sort((a, b) {
      final da = a.department.name;
      final db = b.department.name;
      if (da != db) return da.compareTo(db);
      return a.name.compareTo(b.name);
    });
    return out;
  }

  List<String> get takeawayCategoryChipNames {
    final names = <String>{};
    for (final p in _baseFilteredProducts) {
      final n = p.category?.name;
      if (n != null && n.isNotEmpty) names.add(n);
    }
    return names.toList()..sort();
  }

  double qtyInCartForProduct(String productId) {
    final line = _lineForProduct(productId);
    return line?.qty ?? 0;
  }

  /// Browsing list: department + search + category chip (same idea as product grid).
  List<TakeawayProduct> get visibleProducts {
    if (_selectedCategory == 'All') return _baseFilteredProducts;
    return _baseFilteredProducts
        .where((p) => p.category?.name == _selectedCategory)
        .toList();
  }

  TakeawayCartLine? _lineForProduct(String productId) {
    for (final line in _cart) {
      if (line.product.id == productId) return line;
    }
    return null;
  }

  void addProduct(TakeawayProduct product) {
    bumpProductQuantity(product, product.allowDecimalQty ? 1.0 : 1.0);
  }

  void bumpProductQuantity(TakeawayProduct product, double delta) {
    if (!product.isActive) return;
    if (product.qtyOnHand <= 0) return;
    final line = _lineForProduct(product.id);
    final cur = line?.qty ?? 0;
    applyProductQuantity(product, cur + delta);
  }

  void applyProductQuantity(TakeawayProduct product, double qty) {
    if (!product.isActive && qty > 0) return;
    if (product.qtyOnHand <= 0 && qty > 0) return;
    if (qty <= 0) {
      removeLine(product.id);
      return;
    }
    final requested = product.allowDecimalQty ? qty : qty.roundToDouble();
    final q = requested > product.qtyOnHand ? product.qtyOnHand : requested;
    if (q <= 0) return;
    final existing = _lineForProduct(product.id);
    if (existing == null) {
      _cart.add(TakeawayCartLine(
        product: product,
        qty: q,
        unitPrice: product.salePrice,
      ));
    } else {
      existing.qty = q;
    }
    notifyListeners();
  }

  void removeLine(String productId) {
    _cart.removeWhere((l) => l.product.id == productId);
    notifyListeners();
  }

  void updateLineQty(String productId, double qty) {
    final line = _lineForProduct(productId);
    if (line == null) return;
    if (qty <= 0) {
      removeLine(productId);
      return;
    }
    if (!line.product.allowDecimalQty) {
      line.qty = qty.roundToDouble();
    } else {
      line.qty = qty;
    }
    notifyListeners();
  }

  void updateLineUnitPrice(String productId, double price) {
    final line = _lineForProduct(productId);
    if (line == null) return;
    line.unitPrice = price < 0 ? 0 : price;
    notifyListeners();
  }

  void updateLineDiscount(
    String productId, {
    String? discountType,
    required double discountValue,
  }) {
    final line = _lineForProduct(productId);
    if (line == null) return;
    line.lineDiscountType = (discountType == null || discountType.isEmpty)
        ? null
        : discountType;
    line.lineDiscountValue = discountValue < 0 ? 0 : discountValue;
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  /// Subtotal VAT-exclusive: sum of (unitPriceExclVat × qty - line discount).
  double get subtotalBeforeOrderDiscount {
    double sum = 0;
    for (final line in _cart) {
      final gross = line.unitPriceExclVat * line.qty;
      final type = line.lineDiscountType?.toLowerCase() ?? '';
      if (type == 'amount') {
        sum += (gross - line.lineDiscountValue).clamp(0, double.infinity);
      } else if (type == 'percent' || type == 'percentage') {
        sum += gross * (1 - (line.lineDiscountValue / 100).clamp(0, 1));
      } else {
        sum += gross;
      }
    }
    return sum;
  }

  /// Shown in bottom bar. Must match checkout sheet total:
  /// item-level discounts -> order discount -> promo -> VAT.
  double get estimatedDisplayTotal {
    final sub = subtotalBeforeOrderDiscount;

    final orderDiscInput =
        double.tryParse(orderDiscountValueController.text.trim()) ?? 0.0;
    final isOrderDiscPercent =
        _orderDiscountType == 'percent' || _orderDiscountType == 'percentage';
    final orderDisc = isOrderDiscPercent
        ? (sub * (orderDiscInput / 100)).clamp(0, sub).toDouble()
        : orderDiscInput.clamp(0, sub).toDouble();
    final afterOrderDiscount = (sub - orderDisc).clamp(0, double.infinity).toDouble();

    final promoDiscount = _isPromoPercent
        ? (afterOrderDiscount * (_promoDiscountValue / 100))
            .clamp(0, afterOrderDiscount)
            .toDouble()
        : _promoDiscountValue.clamp(0, afterOrderDiscount).toDouble();
    final taxable = (afterOrderDiscount - promoDiscount)
        .clamp(0, double.infinity)
        .toDouble();

    final vat = double.tryParse(vatController.text.trim()) ??
        _catalog?.vatPercentDefault ??
        0;
    final vatAmount = taxable * (vat / 100);
    return taxable + vatAmount;
  }

  Future<TakeawayCheckoutResponse?> submitCheckout() async {
    _checkoutError = null;
    _lastInvoice = null;
    _lastOrderId = null;
    if (_cart.isEmpty) {
      _checkoutError = 'Add at least one product';
      notifyListeners();
      return null;
    }
    final name = customerNameController.text.trim().isEmpty
        ? 'Walk-in Customer'
        : customerNameController.text.trim();

    double _lineDiscountAmount(TakeawayCartLine line) {
      final gross = line.unitPriceExclVat * line.qty;
      final type = (line.lineDiscountType ?? '').toLowerCase();
      if (type == 'percent' || type == 'percentage') {
        return (gross * (line.lineDiscountValue / 100)).clamp(0, gross);
      }
      if (type == 'amount') {
        return line.lineDiscountValue.clamp(0, gross);
      }
      return 0.0;
    }

    final amountBeforeDiscount = _cart.fold<double>(
      0.0,
      (sum, line) => sum + (line.unitPriceExclVat * line.qty),
    );

    final items = _cart.map((line) {
      final beforeDiscountPrice = line.unitPriceExclVat * line.qty;
      final lineDiscount = _lineDiscountAmount(line);
      final double afterDiscountPrice =
          (beforeDiscountPrice - lineDiscount).clamp(0, double.infinity).toDouble();
      return TakeawayCheckoutLinePayload(
        productId: line.product.id,
        qty: line.qty,
        discountType: line.lineDiscountType,
        discountValue: line.lineDiscountValue,
        unitPrice: line.unitPrice != line.product.salePrice ? line.unitPrice : null,
        beforeDiscountPrice: beforeDiscountPrice,
        afterDiscountPrice: afterDiscountPrice,
      );
    }).toList();

    final odType = _orderDiscountType.trim();
    final odVal =
        double.tryParse(orderDiscountValueController.text.trim()) ?? 0;

    final amountAfterLineDiscount = items.fold<double>(
      0.0,
      (sum, line) => sum + (line.afterDiscountPrice ?? 0.0),
    );
    final isOrderDiscountPercent =
        odType == 'percent' || odType == 'percentage';
    final double orderDiscountAmount = isOrderDiscountPercent
        ? (amountAfterLineDiscount * (odVal / 100)).clamp(0, amountAfterLineDiscount)
        : odVal.clamp(0, amountAfterLineDiscount);
    final double amountAfterDiscount =
        (amountAfterLineDiscount - orderDiscountAmount).clamp(0, double.infinity).toDouble();

    final double promoDiscountAmount = _isPromoPercent
        ? (amountAfterDiscount * (_promoDiscountValue / 100)).clamp(0, amountAfterDiscount)
        : _promoDiscountValue.clamp(0, amountAfterDiscount);
    final double amountAfterPromo =
        (amountAfterDiscount - promoDiscountAmount).clamp(0, double.infinity).toDouble();

    final vatParsed = double.tryParse(vatController.text.trim()) ??
        _catalog?.vatPercentDefault;
    final vatPercent = vatParsed ?? 0.0;
    final vatAmount = amountAfterPromo * (vatPercent / 100.0);
    final totalAmount = amountAfterPromo + vatAmount;
    final discAmt =
        double.tryParse(discountAmountController.text.trim()) ?? 0;

    final request = TakeawayCheckoutRequest(
      customerName: name,
      customerMobile: customerMobileController.text.trim().isEmpty
          ? null
          : customerMobileController.text.trim(),
      customerTaxId: customerTaxIdController.text.trim().isEmpty
          ? null
          : customerTaxIdController.text.trim(),
      items: items,
      totalDiscountType:
          odType.isEmpty || odVal <= 0 ? null : odType,
      totalDiscountValue: odVal > 0 ? odVal : 0,
      promoCode: _appliedPromoCode.isEmpty ? null : _appliedPromoCode,
      promoCodeId: _appliedPromoCodeId,
      amountBeforeDiscount: amountBeforeDiscount,
      amountAfterDiscount: amountAfterDiscount,
      amountAfterPromo: amountAfterPromo,
      vatPercent: vatPercent,
      totalAmount: totalAmount,
      paymentMethod: _paymentMethod,
      payments: _payments,
      invoiceDate: invoiceDateController.text.trim().isEmpty
          ? null
          : invoiceDateController.text.trim(),
      discountAmount: discAmt > 0 ? discAmt : 0,
    );

    // Dev trace: verify contract payload sent to takeaway checkout API.
    assert(() {
      debugPrint(
        '[Takeaway] Checkout payload: ${jsonEncode(request.toJson())}',
      );
      return true;
    }());

    _checkoutLoading = true;
    notifyListeners();
    try {
      final token = await sessionService.getToken();
      if (token == null || token.isEmpty) {
        _checkoutError = 'Not logged in';
        _checkoutLoading = false;
        notifyListeners();
        return null;
      }
      final res = await posRepository.postTakeawayCheckout(request, token);
      if (res.success) {
        _lastOrderId = res.orderId;
        Invoice? resolvedInvoice;
        if (res.orderId != null && res.orderId!.isNotEmpty) {
          // Always use same by-order invoice call as product flow.
          final invoiceByOrder = await posRepository.getInvoiceByOrder(
            res.orderId!,
            token,
          );
          resolvedInvoice = invoiceByOrder.invoice;
        }

        _lastInvoice = resolvedInvoice;
        if (resolvedInvoice != null) {
          clearCart();
          searchController.clear();
          _searchQuery = '';
          _selectedCategory = 'All';
          customerNameController.clear();
          customerMobileController.clear();
          customerTaxIdController.clear();
          promoCodeController.clear();
          orderDiscountValueController.clear();
          discountAmountController.clear();
          _orderDiscountType = '';
          clearAppliedPromo();
        } else {
          _checkoutError =
              res.message.isNotEmpty ? res.message : 'No invoice in response';
        }
      } else {
        _checkoutError =
            res.message.isNotEmpty ? res.message : 'Checkout failed';
      }
      _checkoutLoading = false;
      notifyListeners();
      return res;
    } on AppException catch (e) {
      _checkoutError = e.toString();
      _checkoutLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _checkoutError = e.toString();
      _checkoutLoading = false;
      notifyListeners();
      return null;
    }
  }

  void resetLastInvoice() {
    _lastInvoice = null;
    _lastOrderId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    vatController.removeListener(_onPreviewInputChanged);
    orderDiscountValueController.removeListener(_onPreviewInputChanged);
    promoCodeController.removeListener(_onPreviewInputChanged);
    searchController.dispose();
    customerNameController.dispose();
    customerMobileController.dispose();
    customerTaxIdController.dispose();
    promoCodeController.dispose();
    vatController.dispose();
    invoiceDateController.dispose();
    discountAmountController.dispose();
    orderDiscountValueController.dispose();
    super.dispose();
  }
}
