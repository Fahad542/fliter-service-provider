import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../../../widgets/widgets.dart';
import '../owner_shell.dart';
import 'owner_login_view_model.dart';
import '../../../services/session_service.dart';

class OwnerLoginView extends StatefulWidget {
  const OwnerLoginView({super.key});

  @override
  State<OwnerLoginView> createState() => _OwnerLoginViewState();
}

class _OwnerLoginViewState extends State<OwnerLoginView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerLoginViewModel>().clear();
    });
  }

  Future<void> _handleLogin() async {
    final viewModel = context.read<OwnerLoginViewModel>();
    final success = await viewModel.login();
    if (success) {
      if (mounted) {
        ToastService.showSuccess(context, 'Login successful');
        await context.read<SessionService>().saveLastPortal('owner');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OwnerShell()),
        );
      }
    } else {
      if (mounted) {
        ToastService.showError(context, viewModel.errorMessage ?? 'Login failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? screenWidth * 0.1 : 24.0;
    final viewModel = context.watch<OwnerLoginViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Yellow header — same as POS Login
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomAuthHeader(
              title: 'Workshop Owner',
              subtitle: 'Sign in to your dashboard',
              showBackButton: true,
              height: MediaQuery.of(context).size.height * (isTablet ? 0.37 : 0.42),
            ),
          ),

          // Floating white card
          Positioned(
            top: MediaQuery.of(context).size.height * (isTablet ? 0.26 : 0.27),
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: 0,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(isTablet ? 60 : 24),
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
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: viewModel.emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: viewModel.passwordController,
                        obscureText: viewModel.obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            viewModel.obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: viewModel.togglePasswordVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Sign In',
                          isLoading: viewModel.isLoading,
                          onPressed: _handleLogin,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
