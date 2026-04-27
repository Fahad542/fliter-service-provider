import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../../../widgets/widgets.dart';
import '../owner_shell.dart';
import 'owner_login_view_model.dart';
import '../../../services/session_service.dart';
import 'owner_registration_view.dart';

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
    final l10n      = AppLocalizations.of(context)!;
    final viewModel = context.read<OwnerLoginViewModel>();
    if (!viewModel.formKey.currentState!.validate()) return;
    final success = await viewModel.login();
    if (success) {
      if (mounted) {
        ToastService.showSuccess(context, l10n.ownerLoginSuccess);
        await context.read<SessionService>().saveLastPortal('owner');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OwnerShell()),
        );
      }
    } else {
      if (mounted) {
        ToastService.showError(
          context,
          viewModel.errorMessage ?? l10n.ownerLoginFailed,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n        = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet    = screenWidth > 600;
    final horizontalPadding = isTablet ? screenWidth * 0.1 : 24.0;
    final viewModel   = context.watch<OwnerLoginViewModel>();

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
                  title: l10n.ownerLoginTitle,
                  subtitle: l10n.ownerLoginSubtitle,
                  showBackButton: true,
                  height: MediaQuery.of(context).size.height *
                      (isTablet ? 0.37 : 0.42),
                ),
                // Floating white card
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height *
                        (isTablet ? 0.26 : 0.27),
                    left: horizontalPadding,
                    right: horizontalPadding,
                  ),
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
                            label: l10n.ownerLoginEmail,
                            hint: l10n.ownerLoginEmailHint,
                            controller: viewModel.emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.ownerLoginEmailRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: l10n.ownerLoginPassword,
                            hint: l10n.ownerLoginPasswordHint,
                            controller: viewModel.passwordController,
                            obscureText: viewModel.obscurePassword,
                            prefixIcon:
                            const Icon(Icons.lock_outline_rounded),
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
                                return l10n.ownerLoginPasswordRequired;
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
                                l10n.ownerLoginForgotPassword,
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
                              text: l10n.ownerLoginSignIn,
                              isLoading: viewModel.isLoading,
                              onPressed: _handleLogin,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const OwnerRegistrationView(),
                                  ),
                                );
                              },
                              child: Text(
                                l10n.ownerLoginNoAccount,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.backgroundDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
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
    );
  }
}