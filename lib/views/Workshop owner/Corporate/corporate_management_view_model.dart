import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../utils/toast_service.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';

class ReferralOption {
  final String id;
  final String name;
  final String category;

  ReferralOption({
    required this.id,
    required this.name,
    required this.category,
  });

  factory ReferralOption.fromJson(Map<String, dynamic> json) {
    return ReferralOption(
      id: json['id']?.toString() ?? '',
      name: (json['fullName'] ?? json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
    );
  }
}

class CorporateManagementViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController vatNumberController = TextEditingController();
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();
  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  bool _isListLoading = false;
  bool get isListLoading => _isListLoading;

  List<CorporateCustomer> _corporateCustomers = [];
  List<CorporateCustomer> get corporateCustomers => _corporateCustomers;

  List<Branch> _branches = [];
  List<Branch> get branches => _branches;
  final Set<String> _selectedBranchIds = <String>{};
  List<String> get selectedBranchIds => _selectedBranchIds.toList();

  List<ReferralOption> _referrals = [];
  List<ReferralOption> get referrals => _referrals;
  String? _selectedReferralId;
  String? get selectedReferralId => _selectedReferralId;

  CorporateManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
  }) {
    Future.microtask(_init);
  }

  Future<void> _init() async {
    _isListLoading = true;
    notifyListeners();
    
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token != null) {
        final response = await ownerRepository.getCorporateCustomers(token);
        if (response['success'] == true && response['corporateCustomers'] != null) {
          _corporateCustomers = (response['corporateCustomers'] as List)
              .map((e) => CorporateCustomer.fromJson(e))
              .toList();
        }
        await _loadBranches(token);
        await _loadReferrals(token);
      }
    } catch (e) {
      debugPrint('Error fetching corporate customers: $e');
    }

    _isListLoading = false;
    notifyListeners();
  }

  void clearForm() {
    companyNameController.clear();
    vatNumberController.clear();
    contactNameController.clear();
    mobileController.clear();
    emailController.clear();
    passwordController.clear();
    _selectedBranchIds.clear();
    _selectedReferralId = _referrals.isNotEmpty ? _referrals.first.id : null;

    userNameController.clear();
    userEmailController.clear();
    userPasswordController.clear();
  }

  Future<void> _loadBranches(String token) async {
    final branchResponse = await ownerRepository.getBranches(token);
    if (branchResponse is! Map<String, dynamic>) return;

    final dynamic rawBranches = branchResponse['branches'] ?? branchResponse['data'];
    if (rawBranches is List) {
      _branches = rawBranches
          .whereType<Map<String, dynamic>>()
          .map(Branch.fromJson)
          .toList();
    }
  }

  Future<void> _loadReferrals(String token) async {
    final referralsResponse = await ownerRepository.getReferrers(token);
    if (referralsResponse is! Map<String, dynamic>) return;

    final dynamic rawReferrers = referralsResponse['referrers'] ?? referralsResponse['data'];
    if (rawReferrers is List) {
      _referrals = rawReferrers
          .whereType<Map<String, dynamic>>()
          .map(ReferralOption.fromJson)
          .where((r) => r.id.isNotEmpty)
          .toList();
      if (_selectedReferralId == null && _referrals.isNotEmpty) {
        _selectedReferralId = _referrals.first.id;
      }
    }
  }

  void setSelectedReferralId(String? id) {
    _selectedReferralId = id;
    notifyListeners();
  }

  void toggleBranchSelection(String branchId) {
    if (_selectedBranchIds.contains(branchId)) {
      _selectedBranchIds.remove(branchId);
    } else {
      _selectedBranchIds.add(branchId);
    }
    notifyListeners();
  }

  Future<void> submitCorporateForm(BuildContext context) async {
    if (companyNameController.text.trim().isEmpty || 
        contactNameController.text.trim().isEmpty ||
        mobileController.text.trim().isEmpty ||
        vatNumberController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ToastService.showError(context, 'Please fill in all required fields');
      return;
    }
    if (_selectedBranchIds.isEmpty) {
      ToastService.showError(context, 'Please select at least one branch');
      return;
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final referralId = _selectedReferralId ?? '1';
      final data = <String, dynamic>{
        'companyName': companyNameController.text.trim(),
        'vatNumber': vatNumberController.text.trim(),
        'contactPerson': contactNameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'selectedStoreIds':
            _selectedBranchIds.map((id) => id.toString()).toList(),
        'referralId': referralId,
        'referrerId': referralId,
        'mobile': mobileController.text.trim(),
      };

      await ownerRepository.createCorporateAccount(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Corporate Account Created Successfully');
        clearForm();
        Navigator.pop(context); // Close the sheet
        _init();
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to create corporate account');
      }
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitCorporateUserForm(BuildContext context, String corporateAccountId) async {
    if (userNameController.text.trim().isEmpty || 
        userEmailController.text.trim().isEmpty ||
        userPasswordController.text.trim().isEmpty) {
      ToastService.showError(context, 'Please fill in all required fields');
      return;
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        "name": userNameController.text.trim(),
        "email": userEmailController.text.trim(),
        "password": userPasswordController.text.trim(),
        "corporateAccountId": corporateAccountId,
      };

      await ownerRepository.createCorporateUser(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Corporate User Created Successfully');
        clearForm();
        Navigator.pop(context); // Close the sheet
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to create corporate user');
      }
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    companyNameController.dispose();
    vatNumberController.dispose();
    contactNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    userNameController.dispose();
    userEmailController.dispose();
    userPasswordController.dispose();
    super.dispose();
  }
}
