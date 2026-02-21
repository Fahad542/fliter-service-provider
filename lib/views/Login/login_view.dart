import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/toast_service.dart';
import '../../widgets/widgets.dart';
import 'login_view_model.dart';
import '../Navbar/pos_shell.dart';

class LoginView extends StatefulWidget {
  final String appName;

  const LoginView({super.key, required this.appName});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    context.read<LoginViewModel>().togglePasswordVisibility();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final loginViewModel = context.read<LoginViewModel>();

    // Proceed with login
    final success = await loginViewModel.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      if (mounted) {
        ToastService.showSuccess(context, 'Login successful');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PosShell()),
        );
      }
    } else {
      if (mounted) {
        ToastService.showError(context, loginViewModel.errorMessage ?? 'Login failed');
      }
    }
  }


  void _handleForgotPassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final isTablet = MediaQuery.of(context).size.width > 600;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(isTablet ? 1.4 : 1.0),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: isTablet ? MediaQuery.of(context).size.width * 0.1 : 24,
              right: isTablet ? MediaQuery.of(context).size.width * 0.1 : 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: isTablet ? 60 : 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Reset Password',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.secondaryLight,
                    fontSize: isTablet ? 26 : 22,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your email or mobile number and we\'ll send you a reset link.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Send Reset Link',
                    onPressed: () {
                      Navigator.pop(context);
                      ToastService.showSuccess(context, 'Reset link sent! Check your inbox.');
                    },
                  ),
                ),
                if (isTablet) const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? screenWidth * 0.1 : 24.0;
    
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(isTablet ? 1.4 : 1.0),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomAuthHeader(
              title: widget.appName,
              subtitle: 'Sign in to continue',
              showBackButton: true,
              height: MediaQuery.of(context).size.height * (isTablet ? 0.37 : 0.42),
            ),
          ),

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
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      CustomTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        obscureText: context.watch<LoginViewModel>().obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            context.watch<LoginViewModel>().obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),


                      const SizedBox(height: 24),

                      Consumer<LoginViewModel>(
                        builder: (context, viewModel, child) {
                          return SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Sign In',
                              isLoading: viewModel.isLoading,
                              onPressed: _handleLogin,
                            ),
                          );
                        },
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
    ));
  }


}
