import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final void Function(String)? onChanged;
  final TextCapitalization textCapitalization;

  const CustomInput({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white.withAlpha(200) : AppColors.inputColor;
    final errorColor = isDark ? AppColors.errorColorLight : AppColors.errorColor;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller ?? TextEditingController(),
      builder: (context, value, child) {
        return TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => const SizedBox.shrink(),
          onChanged: onChanged,
          textCapitalization: textCapitalization,
          cursorColor: textColor,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            suffixIcon: maxLength != null ? Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${value.text.length}/$maxLength',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ) : suffixIcon,
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              color: textColor,
            ),
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? Colors.white.withAlpha(130) : AppColors.inputColor.withValues(alpha: 0.6),
            ),
            errorStyle: GoogleFonts.inter(
              fontSize: 12,
              color: errorColor,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: textColor,
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
                color: isDark ? Colors.white.withAlpha(200) : AppColors.inputColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withAlpha(200) : AppColors.borderColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withAlpha(200) : AppColors.inputColor,
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
                color: isDark ? Colors.white.withAlpha(100) : AppColors.inputColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
        );
      }
    );
  }
}
