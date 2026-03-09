import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';

class OwnerPromoViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PromoCode> _promoCodes = [];
  List<PromoCode> get promoCodes => _promoCodes;

  // Controllers for creating a promo code
  final codeController = TextEditingController();
  final discountValueController = TextEditingController();
  final validFromController = TextEditingController();
  final validToController = TextEditingController();
  final usageLimitController = TextEditingController();
  final minOrderAmountController = TextEditingController();
  final descriptionController = TextEditingController();
  String _discountType = 'fixed'; // 'fixed' or 'percent'
  String get discountType => _discountType;

  OwnerPromoViewModel({
    required this.ownerRepository,
    required this.sessionService,
  }) {
    fetchPromoCodes();
  }

  void setDiscountType(String type) {
    _discountType = type;
    notifyListeners();
  }

  Future<void> fetchPromoCodes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final response = await ownerRepository.getPromoCodes(token);
      if (response != null && response['success'] == true) {
        final parsed = PromoCodesResponse.fromJson(response);
        _promoCodes = parsed.promoCodes;
      }
    } catch (e) {
      debugPrint('Error fetching promo codes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitPromoCode(BuildContext context) async {
    if (codeController.text.trim().isEmpty || discountValueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields (Code, Value)')),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        "code": codeController.text.trim(),
        "discountType": _discountType,
        "discountValue": double.tryParse(discountValueController.text) ?? 0,
        "validFrom": validFromController.text.trim().isNotEmpty ? validFromController.text.trim() : DateTime.now().toIso8601String().split('T').first,
        "validTo": validToController.text.trim().isNotEmpty ? validToController.text.trim() : DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T').first,
        "usageLimit": int.tryParse(usageLimitController.text) ?? 100,
        "minOrderAmount": double.tryParse(minOrderAmountController.text) ?? 0,
        "description": descriptionController.text.trim()
      };

      final response = await ownerRepository.createPromoCode(token, data);
      
      if (response != null && response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Promo Code created successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Close sheet
        
        // Clear fields
        codeController.clear();
        discountValueController.clear();
        validFromController.clear();
        validToController.clear();
        usageLimitController.clear();
        minOrderAmountController.clear();
        descriptionController.clear();
        
        // Refresh list
        fetchPromoCodes();
      } else {
        throw Exception(response?['message'] ?? 'Failed to create promo code');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    discountValueController.dispose();
    validFromController.dispose();
    validToController.dispose();
    usageLimitController.dispose();
    minOrderAmountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
