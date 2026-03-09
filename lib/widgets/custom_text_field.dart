import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool showBorder;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
        floatingLabelStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
        errorStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.red, fontSize: 12),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: showBorder ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ) : InputBorder.none,
        enabledBorder: showBorder ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ) : InputBorder.none,
        focusedBorder: showBorder ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight),
        ) : InputBorder.none,
        errorBorder: showBorder ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ) : InputBorder.none,
        focusedErrorBorder: showBorder ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ) : InputBorder.none,
      ),
    );
  }
}
