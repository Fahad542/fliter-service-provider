import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/session_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../../../widgets/custom_auth_header.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

import '../Navbar/pos_shell.dart';
import 'login_view_model.dart';
import '../Home Screen/pos_view_model.dart';

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

    final l10n = AppLocalizations.of(context)!;
    final loginViewModel = context.read<LoginViewModel>();

    final success = await loginViewModel.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      if (mounted) {
        final autoClosed = loginViewModel.previousSessionAutoClosed;
        ToastService.showSuccess(context, l10n.posLoginSuccess);
        await context.read<SessionService>().saveLastPortal('cashier');
        context.read<PosViewModel>().setShellSelectedIndex(0);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PosShell()),
        );
        if (autoClosed && mounted) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              ToastService.showInfo(
                context,
                l10n.posLoginPreviousShiftAutoClosed,
              );
            }
          });
        }
      }
    } else {
      if (mounted) {
        ToastService.showError(
          context,
          loginViewModel.errorMessage ?? l10n.posLoginFailed,
        );
      }
    }
  }

  void _handleForgotPassword() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // Re-read l10n inside builder — context may differ but locale is same
        final sheetL10n = AppLocalizations.of(context)!;
        final isTablet = MediaQuery.of(context).size.width > 600;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: PosTabletLayout.textScaler(context),
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
                  sheetL10n.posLoginResetPasswordTitle,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.secondaryLight,
                    fontSize: isTablet ? 26 : 22,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  sheetL10n.posLoginResetPasswordSubtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: sheetL10n.posLoginResetPasswordEmailLabel,
                  hint: sheetL10n.posLoginResetPasswordEmailHint,
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: sheetL10n.posLoginResetPasswordSendButton,
                    onPressed: () {
                      Navigator.pop(context);
                      ToastService.showSuccess(
                        context,
                        sheetL10n.posLoginResetPasswordSentSuccess,
                      );
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
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? screenWidth * 0.18 : 40.0;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: PosTabletLayout.textScaler(context),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomAuthHeader(
                    title: widget.appName,
                    subtitle: l10n.posLoginTitle,
                    showBackButton: true,
                    height: MediaQuery.of(context).size.height *
                        (isTablet ? 0.37 : 0.42),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height *
                          (isTablet ? 0.31 : 0.34),
                      left: horizontalPadding,
                      right: horizontalPadding,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 44 : 18),
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
                              label: l10n.posLoginEmail,
                              hint: l10n.posLoginEmailHint,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.posLoginEmailRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: l10n.posLoginPassword,
                              hint: l10n.posLoginPasswordHint,
                              controller: _passwordController,
                              obscureText:
                              context.watch<LoginViewModel>().obscurePassword,
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
                                  return l10n.posLoginPasswordRequired;
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
                                  l10n.posLoginForgotPassword,
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
                                    text: l10n.posLoginSignIn,
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
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}