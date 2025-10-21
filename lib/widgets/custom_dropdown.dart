import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final bool enabled;

  const CustomDropdown({
    super.key,
    required this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final errorColor = isDark ? AppColors.errorColorLight : AppColors.errorColor;

    return DropdownButtonFormField<T>(
      isExpanded: true,
      icon: Icon(
        Icons.arrow_drop_down,
        color: isDark ? Colors.white.withAlpha(200) : AppColors.inputColor,
      ),
      iconSize: 24,
      initialValue: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: isDark ? Colors.white.withAlpha(200) : AppColors.textColor,
      ),
      dropdownColor: isDark ? AppColors.primaryColor : Colors.white,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: isDark ? Colors.white.withAlpha(200) : AppColors.inputColor,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          color: isDark
              ? Colors.white.withAlpha(200)
              : AppColors.inputColor.withValues(alpha: 0.6),
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: 12,
          color: errorColor,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: isDark ? Colors.white.withAlpha(200) : AppColors.inputColor,
                size: 24,
              )
            : null,
        filled: true,
        fillColor: isDark ? AppColors.primaryColor : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withAlpha(200)
                : AppColors.inputColor,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withAlpha(200)
                : AppColors.borderColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.primaryButton
                : AppColors.inputColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: errorColor,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: errorColor,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.inputColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
    );
  }
}
