import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../utils/app_colors.dart';
// import '../../utils/app_text_styles.dart';
// import '../../utils/toast_service.dart';
// import '../../widgets/widgets.dart';
import '../../../services/session_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../../../widgets/custom_auth_header.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/locker_translation_mixin.dart';

import '../Navbar/pos_shell.dart';
import 'login_view_model.dart';
import '../Home Screen/pos_view_model.dart'; // Add this import
// import '../Navbar/pos_shell.dart';
// import '../../services/session_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();

    super.dispose();
  }

  void _togglePasswordVisibility() {
    context.read<LoginViewModel>().togglePasswordVisibility();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final loginViewModel = context.read<LoginViewModel>();
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;

    // Proceed with login
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
          loginViewModel.errorMessage != null
              ? await AppTranslationService.localizedDynamicValueForLanguage(loginViewModel.errorMessage!, langCode)
              : l10n.posLoginFailed,
        );
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
        final l10n = AppLocalizations.of(context)!;
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
                  l10n.posLoginResetPasswordTitle,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.secondaryLight,
                    fontSize: isTablet ? 26 : 22,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.posLoginResetPasswordSubtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: l10n.posLoginResetPasswordEmailLabel,
                  hint: l10n.posLoginResetPasswordEmailHint,
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: l10n.posLoginResetPasswordSendButton,
                    onPressed: () {
                      Navigator.pop(context);
                      ToastService.showSuccess(context, l10n.posLoginResetPasswordSentSuccess);
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
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final keyboardOpen = media.viewInsets.bottom > 0;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? screenWidth * 0.18 : 40.0;
    final l10n = AppLocalizations.of(context)!;
    final loginVm = context.watch<LoginViewModel>();

    // Header shrinks when keyboard opens; card always overlaps it by a fixed amount
    final headerHeight = screenHeight *
        (keyboardOpen
            ? (isTablet ? 0.22 : 0.24)
            : (isTablet ? 0.34 : 0.38));
    const double cardOverlap = 48;

    final formPadding = keyboardOpen
        ? EdgeInsets.symmetric(
      horizontal: isTablet ? 32 : 16,
      vertical: isTablet ? 20 : 12,
    )
        : EdgeInsets.all(isTablet ? 44 : 18);
    final smallGap = keyboardOpen ? 10.0 : 16.0;
    final buttonTopGap = keyboardOpen ? 10.0 : 24.0;

    return MediaQuery(
      data: media.copyWith(
        textScaler: PosTabletLayout.textScaler(context),
      ),
      child: Scaffold(
        // Let Flutter naturally push content up when keyboard appears
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                height: headerHeight,
                child: CustomAuthHeader(
                  title: l10n.menuWorkshopPosAppPlain,
                  subtitle: l10n.posLoginTitle,
                  showBackButton: true,
                  height: headerHeight,
                ),
              ),

              // ── Card pulled up to overlap the header bottom ──────────
              Transform.translate(
                offset: const Offset(0, -cardOverlap),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    padding: formPadding,
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!keyboardOpen) const SizedBox(height: 8),
                          CustomTextField(
                            label: l10n.posLoginEmail,
                            hint: l10n.posLoginEmailHint,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            focusNode: _emailFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_passwordFocus);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.posLoginEmailRequired;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: smallGap),
                          CustomTextField(
                            label: l10n.posLoginPassword,
                            hint: l10n.posLoginPasswordHint,
                            controller: _passwordController,
                            obscureText: loginVm.obscurePassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                loginVm.obscurePassword
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
                            focusNode: _passwordFocus,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                          ),
                          SizedBox(height: keyboardOpen ? 6 : 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: keyboardOpen ? 6 : 8,
                                  vertical: keyboardOpen ? 2 : 6,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
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
                          SizedBox(height: buttonTopGap),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: l10n.posLoginSignIn,
                              isLoading: loginVm.isLoading,
                              onPressed: _handleLogin,
                            ),
                          ),
                          SizedBox(height: keyboardOpen ? 8 : 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: keyboardOpen ? 12 : 24),
            ],
          ),
        ),
      ),
    );
  }


}