import 'package:flutter/services.dart';

class Formatters {
  // CPF formatter: 000.000.000-00
  static TextInputFormatter cpf() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

      if (text.isEmpty) return newValue;
      if (text.length > 11) {
        return oldValue;
      }

      StringBuffer formatted = StringBuffer();

      for (int i = 0; i < text.length; i++) {
        if (i == 3 || i == 6) {
          formatted.write('.');
        } else if (i == 9) {
          formatted.write('-');
        }
        formatted.write(text[i]);
      }

      return TextEditingValue(
        text: formatted.toString(),
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  // Date formatter: dd/mm/yyyy
  static TextInputFormatter date() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

      if (text.isEmpty) return newValue;
      if (text.length > 8) {
        return oldValue;
      }

      StringBuffer formatted = StringBuffer();

      for (int i = 0; i < text.length; i++) {
        if (i == 2 || i == 4) {
          formatted.write('/');
        }
        formatted.write(text[i]);
      }

      return TextEditingValue(
        text: formatted.toString(),
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  // Helper: Limpar CPF (remove formatação)
  static String cleanCpf(String cpf) {
    return cpf.replaceAll(RegExp(r'[^\d]'), '');
  }

  // Helper: Formatar CPF manualmente
  static String formatCpf(String cpf) {
    final cleaned = cleanCpf(cpf);
    if (cleaned.isEmpty) return '';

    if (cleaned.length <= 3) {
      return cleaned;
    } else if (cleaned.length <= 6) {
      return '${cleaned.substring(0, 3)}.${cleaned.substring(3)}';
    } else if (cleaned.length <= 9) {
      return '${cleaned.substring(0, 3)}.${cleaned.substring(3, 6)}.${cleaned.substring(6)}';
    } else {
      return '${cleaned.substring(0, 3)}.${cleaned.substring(3, 6)}.${cleaned.substring(6, 9)}-${cleaned.substring(9, cleaned.length > 11 ? 11 : cleaned.length)}';
    }
  }
}
