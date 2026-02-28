import 'package:flutter/material.dart';
import '../Dashboard/locker_dashboard_view.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../widgets/widgets.dart';

class LockerLoginView extends StatefulWidget {
  const LockerLoginView({super.key});

  @override
  State<LockerLoginView> createState() => _LockerLoginViewState();
}

class _LockerLoginViewState extends State<LockerLoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _showOTP = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
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
          // Yellow header — same as POS Login
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomAuthHeader(
              title: 'Locker Portal',
              subtitle: 'Authorized Personnel Only',
              showBackButton: true,
              height: MediaQuery.of(context).size.height * (isTablet ? 0.37 : 0.42),
            ),
          ),

          // Floating white card — same layout as POS Login
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
                        label: 'Username / Mobile',
                        hint: 'Enter your username or mobile',
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
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
                      if (_showOTP) ...[
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: '2FA Security Code',
                          hint: 'Enter 6-digit code',
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.shield_outlined),
                        ),
                      ],
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
                      const SizedBox(height: 8),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: _showOTP ? 'Authorize Access' : 'Continue',
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

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (!_showOTP) {
        setState(() => _showOTP = true);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LockerDashboardView()),
        );
      }
    });
  }
}
