import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../services/session_service.dart';
import '../../../../services/google_places_service.dart';

class OwnerRegistrationViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final SessionService sessionService;

  OwnerRegistrationViewModel({
    required this.authRepository,
    required this.sessionService,
  });

  final GooglePlacesService googlePlacesService = GooglePlacesService('AIzaSyDfxcDdlq5IDIHjpRQKeAHepYIFaSYvVMQ');

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
  double _gpsLat = 24.7136;
  double _gpsLng = 46.6753;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getAddressSuggestions(String input) async {
    return await googlePlacesService.getSuggestions(input);
  }

  Future<void> onAddressSelected(Map<String, dynamic> selection) async {
    final description = selection['description'] as String;
    addressController.text = description;
    
    final placeId = selection['place_id'] as String;
    final details = await googlePlacesService.getPlaceDetails(placeId);
    
    if (details != null) {
      _gpsLat = details['lat'];
      _gpsLng = details['lng'];
      notifyListeners();
    }
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
        gpsLat: _gpsLat,
        gpsLng: _gpsLng,
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
