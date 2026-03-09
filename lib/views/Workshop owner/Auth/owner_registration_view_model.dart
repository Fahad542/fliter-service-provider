import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../services/session_service.dart';

class OwnerRegistrationViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final SessionService sessionService;

  OwnerRegistrationViewModel({
    required this.authRepository,
    required this.sessionService,
  });

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController workshopNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController taxIdController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clear() {
    workshopNameController.clear();
    emailController.clear();
    passwordController.clear();
    ownerNameController.clear();
    mobileController.clear();
    taxIdController.clear();
    addressController.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register() async {
    if (!formKey.currentState!.validate()) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await authRepository.registerWorkshopOwner(
        name: workshopNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        ownerName: ownerNameController.text.trim(),
        mobile: mobileController.text.trim(),
        taxId: taxIdController.text.trim(),
        address: addressController.text.trim(),
        gpsLat: 24.7136, // Default Riyadh coords for now
        gpsLng: 46.6753,
      );

      // Successfully registered.
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    workshopNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    ownerNameController.dispose();
    mobileController.dispose();
    taxIdController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
