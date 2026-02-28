import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../widgets/widgets.dart';
import '../technician_shell.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/session_service.dart';
import '../../../utils/toast_service.dart';

class TechLoginView extends StatefulWidget {
  const TechLoginView({super.key});

  @override
  State<TechLoginView> createState() => _TechLoginViewState();
}

class _TechLoginViewState extends State<TechLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final repository = AuthRepository();
      final response = await repository.technicianLogin(
        _emailController.text.trim(),
        _passwordController.text,
      );

      final session = SessionService();
      await session.saveSession(response, role: 'tech');
      
      if (mounted) {
        ToastService.showSuccess(context, 'Login Successful');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TechShell()),
        );
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Invalid email or password');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? screenWidth * 0.1 : 24.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Yellow header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomAuthHeader(
              title: 'Technician Portal',
              subtitle: 'Sign in to your workspace',
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
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      CustomTextField(
                        label: 'Email',
                        hint: 'Enter your email address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                          isLoading: _isLoading,
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
