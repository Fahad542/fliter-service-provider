import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final Function(String) onChanged;
  final String? hintText;

  const CustomSearchBar({
    super.key,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TextField(
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      textDirection: Directionality.of(context),
      decoration: InputDecoration(
        hintText: hintText ?? l10n.ownerCommonSearchHint,
        hintStyle: const TextStyle(fontSize: 13.5, color: Colors.grey),
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
    );
  }
}
