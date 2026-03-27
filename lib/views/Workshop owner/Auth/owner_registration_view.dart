import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../../../widgets/widgets.dart';
import 'owner_registration_view_model.dart';
import '../../../services/session_service.dart';

import '../../../data/repositories/auth_repository.dart';

class OwnerRegistrationView extends StatelessWidget {
  const OwnerRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OwnerRegistrationViewModel(
        authRepository: context.read<AuthRepository>(),
        sessionService: context.read<SessionService>(),
      )..clear(),
      child: const _OwnerRegistrationViewContent(),
    );
  }
}

class _OwnerRegistrationViewContent extends StatefulWidget {
  const _OwnerRegistrationViewContent();

  @override
  State<_OwnerRegistrationViewContent> createState() => _OwnerRegistrationViewContentState();
}

class _OwnerRegistrationViewContentState extends State<_OwnerRegistrationViewContent> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleRegistration() async {
    final viewModel = context.read<OwnerRegistrationViewModel>();
    if (!viewModel.formKey.currentState!.validate()) return;
    final success = await viewModel.register();
    if (success) {
      if (mounted) {
        ToastService.showSuccess(context, 'Registration successful. Please login.');
        Navigator.pop(context); // Go back to login screen
      }
    } else {
      if (mounted) {
        ToastService.showError(context, viewModel.errorMessage ?? 'Registration failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? screenWidth * 0.1 : 24.0;
    final viewModel = context.watch<OwnerRegistrationViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Yellow header
                CustomAuthHeader(
                  title: 'Create Account',
                  subtitle: 'Register your workshop',
                  showBackButton: true,
                  height: MediaQuery.of(context).size.height *
                      (isTablet ? 0.32 : 0.35),
                ),
                // Floating white card
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height *
                        (isTablet ? 0.25 : 0.26),
                    left: horizontalPadding,
                    right: horizontalPadding,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 48 : 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: viewModel.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          CustomTextField(
                            label: 'Workshop Name',
                            hint: 'Enter workshop name',
                            controller: viewModel.workshopNameController,
                            prefixIcon: const Icon(Icons.store_rounded),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Owner Name',
                            hint: 'Enter full name',
                            controller: viewModel.ownerNameController,
                            prefixIcon: const Icon(Icons.person_rounded),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Email Address',
                            hint: 'Enter email address',
                            controller: viewModel.emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_rounded),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Mobile Number',
                            hint: '+966...',
                            controller: viewModel.mobileController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone_rounded),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Tax ID',
                            hint: 'Enter Tax ID',
                            controller: viewModel.taxIdController,
                            prefixIcon: const Icon(Icons.assignment_rounded),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Address',
                            hint: 'Enter full address',
                            controller: viewModel.addressController,
                            prefixIcon: const Icon(Icons.location_on_rounded),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Password',
                            hint: 'Create a password',
                            controller: viewModel.passwordController,
                            obscureText: viewModel.obscurePassword,
                            prefixIcon: const Icon(Icons.lock_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                viewModel.obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                              ),
                              onPressed: viewModel.togglePasswordVisibility,
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Register',
                              isLoading: viewModel.isLoading,
                              onPressed: _handleRegistration,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                "Already have an account? Sign in",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.backgroundDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
